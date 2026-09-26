package com.aorbotreks.app

import android.content.Context
import com.google.android.play.core.integrity.IntegrityManagerFactory
import com.google.android.play.core.integrity.StandardIntegrityException
import com.google.android.play.core.integrity.StandardIntegrityManager
import com.google.android.play.core.integrity.StandardIntegrityManager.PrepareIntegrityTokenRequest
import com.google.android.play.core.integrity.StandardIntegrityManager.StandardIntegrityTokenProvider
import com.google.android.play.core.integrity.StandardIntegrityManager.StandardIntegrityTokenRequest
import com.google.android.play.core.integrity.model.StandardIntegrityErrorCode
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Bridge to the Play Integrity API *standard request* flow.
 *
 *   prepare(cloudProjectNumber)  warm up a token provider (a few seconds; do
 *                                it at app start, off the critical path)
 *   request(requestHash)         mint a token bound to one exact request
 *                                (~hundreds of ms once prepared)
 *
 * The provider can expire (INTEGRITY_TOKEN_PROVIDER_INVALID); request()
 * transparently re-prepares once and retries. Concurrent prepare calls share
 * one in-flight preparation.
 *
 * Errors are returned to Dart as PlatformException(code = stable NAME) so the
 * app can forward them to the backend (X-Play-Integrity-Error) and decide
 * whether a retry makes sense.
 */
class PlayIntegrityChannel(context: Context, messenger: BinaryMessenger) :
    MethodChannel.MethodCallHandler {

    companion object {
        const val CHANNEL = "com.aorbotreks.app/play_integrity"

        fun errorName(code: Int): String = when (code) {
            StandardIntegrityErrorCode.API_NOT_AVAILABLE -> "API_NOT_AVAILABLE"
            StandardIntegrityErrorCode.PLAY_STORE_NOT_FOUND -> "PLAY_STORE_NOT_FOUND"
            StandardIntegrityErrorCode.NETWORK_ERROR -> "NETWORK_ERROR"
            StandardIntegrityErrorCode.APP_NOT_INSTALLED -> "APP_NOT_INSTALLED"
            StandardIntegrityErrorCode.PLAY_SERVICES_NOT_FOUND -> "PLAY_SERVICES_NOT_FOUND"
            StandardIntegrityErrorCode.APP_UID_MISMATCH -> "APP_UID_MISMATCH"
            StandardIntegrityErrorCode.TOO_MANY_REQUESTS -> "TOO_MANY_REQUESTS"
            StandardIntegrityErrorCode.CANNOT_BIND_TO_SERVICE -> "CANNOT_BIND_TO_SERVICE"
            StandardIntegrityErrorCode.GOOGLE_SERVER_UNAVAILABLE -> "GOOGLE_SERVER_UNAVAILABLE"
            StandardIntegrityErrorCode.PLAY_STORE_VERSION_OUTDATED -> "PLAY_STORE_VERSION_OUTDATED"
            StandardIntegrityErrorCode.PLAY_SERVICES_VERSION_OUTDATED -> "PLAY_SERVICES_VERSION_OUTDATED"
            StandardIntegrityErrorCode.CLOUD_PROJECT_NUMBER_IS_INVALID -> "CLOUD_PROJECT_NUMBER_IS_INVALID"
            StandardIntegrityErrorCode.REQUEST_HASH_TOO_LONG -> "REQUEST_HASH_TOO_LONG"
            StandardIntegrityErrorCode.CLIENT_TRANSIENT_ERROR -> "CLIENT_TRANSIENT_ERROR"
            StandardIntegrityErrorCode.INTEGRITY_TOKEN_PROVIDER_INVALID -> "INTEGRITY_TOKEN_PROVIDER_INVALID"
            StandardIntegrityErrorCode.INTERNAL_ERROR -> "INTERNAL_ERROR"
            else -> "PI_ERROR_$code"
        }
    }

    private val manager: StandardIntegrityManager =
        IntegrityManagerFactory.createStandard(context.applicationContext)
    private val channel = MethodChannel(messenger, CHANNEL)

    private var provider: StandardIntegrityTokenProvider? = null
    private var projectNumber: Long? = null
    private var preparing = false
    private val waiters = mutableListOf<(StandardIntegrityTokenProvider?, Exception?) -> Unit>()

    init {
        channel.setMethodCallHandler(this)
    }

    fun dispose() {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "prepare" -> {
                val number = parseProjectNumber(call.argument<Any>("cloudProjectNumber"))
                if (number == null) {
                    result.error("CLOUD_PROJECT_NUMBER_IS_INVALID", "cloudProjectNumber missing", null)
                    return
                }
                projectNumber = number
                ensureProvider(forceFresh = false) { p, e ->
                    if (p != null) result.success(true) else reply(result, e)
                }
            }
            "request" -> {
                val hash = call.argument<String>("requestHash")
                if (hash.isNullOrEmpty()) {
                    result.error("REQUEST_HASH_MISSING", "requestHash missing", null)
                    return
                }
                requestToken(hash, retried = false, result = result)
            }
            else -> result.notImplemented()
        }
    }

    private fun requestToken(hash: String, retried: Boolean, result: MethodChannel.Result) {
        ensureProvider(forceFresh = false) { p, e ->
            if (p == null) {
                reply(result, e)
                return@ensureProvider
            }
            p.request(StandardIntegrityTokenRequest.builder().setRequestHash(hash).build())
                .addOnSuccessListener { token -> result.success(token.token()) }
                .addOnFailureListener { ex ->
                    val expired = ex is StandardIntegrityException &&
                        ex.errorCode == StandardIntegrityErrorCode.INTEGRITY_TOKEN_PROVIDER_INVALID
                    if (expired && !retried) {
                        provider = null
                        requestToken(hash, retried = true, result = result)
                    } else {
                        reply(result, ex)
                    }
                }
        }
    }

    private fun ensureProvider(
        forceFresh: Boolean,
        callback: (StandardIntegrityTokenProvider?, Exception?) -> Unit,
    ) {
        val existing = provider
        if (existing != null && !forceFresh) {
            callback(existing, null)
            return
        }
        val number = projectNumber
        if (number == null) {
            callback(null, IllegalStateException("prepare() was never called"))
            return
        }
        waiters.add(callback)
        if (preparing) return
        preparing = true

        manager.prepareIntegrityToken(
            PrepareIntegrityTokenRequest.builder().setCloudProjectNumber(number).build()
        )
            .addOnSuccessListener { p ->
                provider = p
                drain(p, null)
            }
            .addOnFailureListener { ex ->
                provider = null
                drain(null, ex)
            }
    }

    private fun drain(p: StandardIntegrityTokenProvider?, e: Exception?) {
        preparing = false
        val pending = waiters.toList()
        waiters.clear()
        pending.forEach { it(p, e) }
    }

    private fun reply(result: MethodChannel.Result, e: Exception?) {
        when (e) {
            is StandardIntegrityException -> result.error(errorName(e.errorCode), e.message, e.errorCode)
            is IllegalStateException -> result.error("NOT_PREPARED", e.message, null)
            null -> result.error("UNKNOWN", "unknown Play Integrity failure", null)
            else -> result.error("UNKNOWN", e.message, null)
        }
    }

    private fun parseProjectNumber(raw: Any?): Long? = when (raw) {
        is Long -> raw
        is Int -> raw.toLong()
        is String -> raw.trim().toLongOrNull()
        else -> null
    }?.takeIf { it > 0 }
}
