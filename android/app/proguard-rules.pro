# Keep GetX core classes
-keep class io.fotoapparat.** { *; }

# Keep GetX-related classes
-keep class com.getcapacitor.** { *; }
-keep class com.getx.** { *; }
-keep class com.github.getx.** { *; }

# Keep all annotations
-keepattributes *Annotation*

# Prevent warnings
-dontwarn io.fotoapparat.**
-dontwarn com.getx.**
-dontwarn com.github.getx.**

-keep class com.razorpay.** { *; }
-dontwarn com.google.android.apps.nbu.paisa.inapp.client.api.PaymentsClient
-dontwarn com.google.android.apps.nbu.paisa.inapp.client.api.Wallet
-dontwarn com.google.android.apps.nbu.paisa.inapp.client.api.WalletUtils
-dontwarn proguard.annotation.Keep
-dontwarn proguard.annotation.KeepClassMembers



-keep class com.google.j2objc.annotations.** { *; }
-dontwarn com.google.j2objc.annotations.**


-keepattributes *Annotation*
-dontwarn com.razorpay.**
-keep class com.razorpay.** {*;}
-optimizations !method/inlining/
-keepclasseswithmembers class * {
    public void onPayment*(...);
}


# Startup crash in 1.0.0+27 (16 Oct 2026): classes created by reflection need
# their constructors kept explicitly (R8 full mode does not keep them implicitly).
# Room databases (WorkManager's WorkDatabase) are built from <Name>_Impl by name.
-keep class * extends androidx.room.RoomDatabase { <init>(); }
-keep class **_Impl { <init>(...); }
# WorkManager workers and input mergers are created by class name.
-keep class * extends androidx.work.ListenableWorker { <init>(android.content.Context, androidx.work.WorkerParameters); }
-keep class * extends androidx.work.InputMerger { <init>(); }
# androidx.startup initializers listed in the manifest.
-keep class * implements androidx.startup.Initializer { <init>(); }
