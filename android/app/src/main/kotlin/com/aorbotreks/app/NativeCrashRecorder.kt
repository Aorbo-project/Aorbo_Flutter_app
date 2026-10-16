package com.aorbotreks.app

import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject
import java.io.File
import java.io.PrintWriter
import java.io.StringWriter

/**
 * Android-level (Java / Kotlin) crashes, for Aorbo's own crash reports
 * (16 Oct 2026). Flutter errors already reach the server; a crash below Flutter
 * reached only Firebase. On a crash the stack is written to one small file,
 * then the previous handler (Firebase Crashlytics, then Android) runs as before.
 * On the next launch lib/services/native_crash_reporter.dart takes the file
 * (channel "com.aorbotreks.app/native_crash") and sends it. Never throws.
 */
object NativeCrashRecorder {
    private const val FILE_NAME = "pending_native_crash.json"
    private const val MAX_STACK = 20000

    @Volatile private var installed = false

    fun install(context: Context) {
        if (installed) return
        installed = true
        val filesDir = try { context.filesDir } catch (_: Throwable) { null } ?: return
        val previous = Thread.getDefaultUncaughtExceptionHandler()
        Thread.setDefaultUncaughtExceptionHandler { thread, error ->
            try {
                write(filesDir, thread.name, error)
            } catch (_: Throwable) {
                // never stand in the way of the real crash handling
            }
            if (previous != null) {
                previous.uncaughtException(thread, error)
            } else {
                android.os.Process.killProcess(android.os.Process.myPid())
                kotlin.system.exitProcess(10)
            }
        }
    }

    private fun write(filesDir: File, threadName: String, error: Throwable) {
        val sw = StringWriter()
        error.printStackTrace(PrintWriter(sw))
        val root = generateSequence(error) { it.cause }.last()
        val json = JSONObject()
            .put("message", "${error.javaClass.name}: ${error.message ?: ""}".take(500))
            .put("root_cause", "${root.javaClass.name}: ${root.message ?: ""}".take(500))
            .put("stack", sw.toString().take(MAX_STACK))
            .put("thread", threadName)
            .put("at", System.currentTimeMillis())
        File(filesDir, FILE_NAME).writeText(json.toString())
    }

    /** The saved crash (JSON) and removes it, or null. */
    fun take(context: Context): String? = try {
        val f = File(context.filesDir, FILE_NAME)
        if (!f.exists()) null else f.readText().also { f.delete() }
    } catch (_: Throwable) {
        null
    }

    fun channel(context: Context, messenger: BinaryMessenger): MethodChannel =
        MethodChannel(messenger, "com.aorbotreks.app/native_crash").also { ch ->
            ch.setMethodCallHandler { call, result ->
                when (call.method) {
                    "takePendingCrash" -> result.success(take(context))
                    else -> result.notImplemented()
                }
            }
        }
}
