package com.aorbotreks.app

import android.content.Context
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.os.Build
import android.os.Debug
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.security.keystore.StrongBoxUnavailableException
import android.util.Base64
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.net.InetSocketAddress
import java.net.Socket
import java.security.KeyPairGenerator
import java.security.KeyStore
import java.security.MessageDigest
import java.security.PrivateKey
import java.security.Signature
import java.security.spec.ECGenParameterSpec
import java.util.concurrent.Executors

/**
 * Device security primitives for the Dart side.
 *
 * 1. Device-bound session key (Backend services/deviceBinding.js)
 *    deviceKeyPublic  -> base64 SPKI of a P-256 key in the Android Keystore
 *                        (StrongBox when the phone has one), created on first
 *                        use. The private key is non-exportable: it cannot be
 *                        read by the app, a backup, or root-less malware.
 *    deviceKeySign    -> base64 DER ECDSA-SHA256 signature over given bytes
 *    deviceKeyReset   -> delete the key (logout) so the next login binds a
 *                        brand-new one
 *
 * 2. Runtime tamper checks (RASP)
 *    riskScan -> list of flags: root | hook | debugger | emulator | tamper |
 *                untrusted_installer, plus the signing-cert SHA-256.
 *    These are *signals*, not proof: a skilled attacker can hide from any
 *    in-app check. The server-side authority is Play Integrity; these add
 *    Frida/Xposed/debugger detection Play does not report, and corroborate.
 *
 * All work runs off the main thread; results are posted back on it.
 */
class DeviceSecurityChannel(private val context: Context, messenger: BinaryMessenger) :
    MethodChannel.MethodCallHandler {

    companion object {
        const val CHANNEL = "com.aorbotreks.app/device_security"
        private const val KEY_ALIAS = "aorbo_device_binding_v1"
        private const val ANDROID_KEYSTORE = "AndroidKeyStore"

        private val SU_PATHS = listOf(
            "/system/bin/su", "/system/xbin/su", "/sbin/su", "/su/bin/su",
            "/system/sd/xbin/su", "/system/bin/failsafe/su", "/data/local/su",
            "/data/local/bin/su", "/data/local/xbin/su", "/system/app/Superuser.apk",
            "/data/adb/magisk", "/sbin/.magisk", "/cache/.disable_magisk",
            "/data/adb/ksu", "/data/adb/ap",
        )
        // Substrings of mapped library paths injected hooking frameworks leave behind.
        private val HOOK_MARKERS = listOf(
            "frida", "linjector", "xposed", "lsposed", "edxposed",
            "substrate", "riru", "zygisk", "lspd",
        )
        private val FRIDA_PORTS = intArrayOf(27042, 27043)
        private val HOOK_CLASSES = listOf(
            "de.robv.android.xposed.XposedBridge",
            "de.robv.android.xposed.XC_MethodHook",
            "com.saurik.substrate.MS\$2",
        )
    }

    private val channel = MethodChannel(messenger, CHANNEL)
    private val worker = Executors.newSingleThreadExecutor()
    private val main = android.os.Handler(android.os.Looper.getMainLooper())

    init {
        channel.setMethodCallHandler(this)
    }

    fun dispose() {
        channel.setMethodCallHandler(null)
        worker.shutdown()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "deviceKeyPublic" -> background(result) { publicKeyB64() }
            "deviceKeySign" -> {
                val data = call.argument<ByteArray>("data")
                if (data == null) {
                    result.error("BAD_ARGS", "data missing", null)
                    return
                }
                background(result) { sign(data) }
            }
            "deviceKeyReset" -> background(result) {
                keyStore().deleteEntry(KEY_ALIAS)
                true
            }
            "riskScan" -> {
                val release = call.argument<Boolean>("release") ?: true
                background(result) { riskScan(release) }
            }
            else -> result.notImplemented()
        }
    }

    private fun background(result: MethodChannel.Result, block: () -> Any?) {
        worker.execute {
            try {
                val value = block()
                main.post { result.success(value) }
            } catch (e: Exception) {
                main.post { result.error("DEVICE_SECURITY_ERROR", e.javaClass.simpleName + ": " + e.message, null) }
            }
        }
    }

    // ── Device-bound key ─────────────────────────────────────────────────────

    private fun keyStore(): KeyStore = KeyStore.getInstance(ANDROID_KEYSTORE).apply { load(null) }

    private fun ensureKey() {
        if (keyStore().containsAlias(KEY_ALIAS)) return
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            try {
                generateKey(strongBox = true)
                return
            } catch (_: StrongBoxUnavailableException) {
                // fall through to the regular TEE-backed keystore
            } catch (_: Exception) {
            }
        }
        generateKey(strongBox = false)
    }

    private fun generateKey(strongBox: Boolean) {
        val spec = KeyGenParameterSpec.Builder(KEY_ALIAS, KeyProperties.PURPOSE_SIGN)
            .setAlgorithmParameterSpec(ECGenParameterSpec("secp256r1"))
            .setDigests(KeyProperties.DIGEST_SHA256)
            .apply {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) setIsStrongBoxBacked(strongBox)
            }
            .build()
        KeyPairGenerator.getInstance(KeyProperties.KEY_ALGORITHM_EC, ANDROID_KEYSTORE).apply {
            initialize(spec)
            generateKeyPair()
        }
    }

    private fun publicKeyB64(): String {
        ensureKey()
        val cert = keyStore().getCertificate(KEY_ALIAS)
        return Base64.encodeToString(cert.publicKey.encoded, Base64.NO_WRAP) // X.509 SPKI DER
    }

    private fun sign(data: ByteArray): String {
        ensureKey()
        val key = keyStore().getKey(KEY_ALIAS, null) as PrivateKey
        val sig = Signature.getInstance("SHA256withECDSA").apply {
            initSign(key)
            update(data)
        }.sign() // DER-encoded, what the backend verifies
        return Base64.encodeToString(sig, Base64.NO_WRAP)
    }

    // ── RASP ─────────────────────────────────────────────────────────────────

    private fun riskScan(release: Boolean): Map<String, Any?> {
        val flags = mutableListOf<String>()
        if (isRooted()) flags.add("root")
        if (isHooked()) flags.add("hook")
        if (release && isDebugged()) flags.add("debugger")
        if (isEmulator()) flags.add("emulator")
        if (release && isDebuggable()) flags.add("tamper")
        val installer = installerPackage()
        if (installer != "com.android.vending") flags.add("untrusted_installer")
        return mapOf(
            "flags" to flags,
            "installer" to installer,
            "signingCertSha256" to signingCertSha256(),
        )
    }

    private fun isRooted(): Boolean {
        if (SU_PATHS.any { File(it).exists() }) return true
        if (Build.TAGS?.contains("test-keys") == true) return true
        return try {
            val p = Runtime.getRuntime().exec(arrayOf("/system/bin/sh", "-c", "command -v su"))
            val out = p.inputStream.bufferedReader().readText()
            p.destroy()
            out.isNotBlank()
        } catch (_: Exception) {
            false
        }
    }

    private fun isHooked(): Boolean {
        // Injected agents show up as mapped libraries / threads in our own process.
        try {
            val maps = File("/proc/self/maps").readText().lowercase()
            if (HOOK_MARKERS.any { maps.contains(it) }) return true
        } catch (_: Exception) {
        }
        try {
            File("/proc/self/task").listFiles()?.forEach { task ->
                val name = try { File(task, "comm").readText().trim().lowercase() } catch (_: Exception) { "" }
                if (name == "gum-js-loop" || name == "pool-frida") return true
            }
        } catch (_: Exception) {
        }
        for (cls in HOOK_CLASSES) {
            try {
                Class.forName(cls)
                return true
            } catch (_: ClassNotFoundException) {
            } catch (_: Throwable) {
            }
        }
        // Default frida-server ports on loopback.
        for (port in FRIDA_PORTS) {
            try {
                Socket().use { s ->
                    s.connect(InetSocketAddress("127.0.0.1", port), 80)
                    return true
                }
            } catch (_: Exception) {
            }
        }
        return false
    }

    private fun isDebugged(): Boolean {
        if (Debug.isDebuggerConnected() || Debug.waitingForDebugger()) return true
        // TracerPid != 0 → something (gdb, strace, frida in ptrace mode) is attached.
        return try {
            File("/proc/self/status").readLines()
                .firstOrNull { it.startsWith("TracerPid:") }
                ?.substringAfter(":")?.trim()?.toIntOrNull()?.let { it != 0 } ?: false
        } catch (_: Exception) {
            false
        }
    }

    private fun isEmulator(): Boolean {
        val fp = Build.FINGERPRINT.lowercase()
        val model = Build.MODEL.lowercase()
        val product = Build.PRODUCT.lowercase()
        val hw = Build.HARDWARE.lowercase()
        return fp.startsWith("generic") || fp.startsWith("unknown") || fp.contains("emulator") ||
            model.contains("google_sdk") || model.contains("emulator") || model.contains("android sdk built for") ||
            product.contains("sdk_gphone") || product.contains("google_sdk") || product == "sdk" ||
            product.contains("vbox") || product.contains("genymotion") ||
            hw == "goldfish" || hw == "ranchu" || hw.contains("vbox") ||
            Build.MANUFACTURER.lowercase().contains("genymotion") ||
            (Build.BRAND.startsWith("generic") && Build.DEVICE.startsWith("generic"))
    }

    /** A release build must never be debuggable; if it is, it was repackaged. */
    private fun isDebuggable(): Boolean =
        (context.applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE) != 0

    private fun installerPackage(): String? = try {
        val pm = context.packageManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            pm.getInstallSourceInfo(context.packageName).installingPackageName
        } else {
            @Suppress("DEPRECATION")
            pm.getInstallerPackageName(context.packageName)
        }
    } catch (_: Exception) {
        null
    }

    private fun signingCertSha256(): List<String> = try {
        val pm = context.packageManager
        val signatures = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            val info = pm.getPackageInfo(context.packageName, PackageManager.GET_SIGNING_CERTIFICATES)
            val si = info.signingInfo
            if (si == null) emptyArray()
            else if (si.hasMultipleSigners()) si.apkContentsSigners else si.signingCertificateHistory
        } else {
            @Suppress("DEPRECATION")
            pm.getPackageInfo(context.packageName, PackageManager.GET_SIGNATURES).signatures
        }
        (signatures ?: emptyArray()).map { sig ->
            MessageDigest.getInstance("SHA-256").digest(sig.toByteArray())
                .joinToString(":") { "%02X".format(it) }
        }
    } catch (_: Exception) {
        emptyList()
    }
}
