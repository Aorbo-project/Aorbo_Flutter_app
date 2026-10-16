package com.aorbotreks.app

import android.app.Application
import android.content.Context

/**
 * Installs the native crash recorder as early as Android allows: before any
 * ContentProvider runs (1.0.0+27 died inside androidx.startup's provider, which
 * Aorbo's own crash reports never saw). Nothing else happens here.
 */
class AorboApplication : Application() {
    override fun attachBaseContext(base: Context) {
        super.attachBaseContext(base)
        NativeCrashRecorder.install(base)
    }
}
