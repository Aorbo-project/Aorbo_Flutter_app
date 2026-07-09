import 'dart:io';
import 'dart:ui';

import 'package:arobo_app/firebase_options.dart';
import 'package:arobo_app/repository/repository.dart';
import 'package:arobo_app/routes/routes.dart';
import 'package:arobo_app/utils/Preferences.dart';
import 'package:arobo_app/utils/app_theme.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import 'utils/shared_preferences.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Message received while app is terminated/in background — system tray handles display.
  // No action needed here; navigation is handled in onMessageOpenedApp when user taps.
}

SpUtil? sp;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // TEMP DIAGNOSTIC — force full stack traces for zone errors that are
  // otherwise reported tersely ("Another exception was thrown: ..." with no
  // detail). Remove once the "Null is not a subtype of int" crash is found.
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('╔══ TEMP DIAGNOSTIC — UNCAUGHT ZONE ERROR ══╗');
    debugPrint('$error');
    debugPrint('$stack');
    debugPrint('╚════════════════════════════════════════╝');
    return true;
  };

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // --- ONLY the bare minimum needed before first frame ---
  // Firebase core init is required before any firebase.* call anywhere in
  // the widget tree, and it's normally fast (local SDK setup, no network).
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Local prefs read — fast, and routes/screens likely depend on it
  // immediately (e.g. checkUserLogin()), so keep this blocking.
  await Preferences.initPref();
  sp = await SpUtil.getInstance();

  // --- Launch the UI now. Everything below this line is slow/network-bound
  // and must NOT block the first frame. ---
  runApp(const MyApp());

  // --- Deferred, non-blocking init. Runs after the UI is already visible. ---
  _deferredInit();
}

void _deferredInit() {
  // Fire-and-forget; none of this blocks the splash/login screen from showing.
  Future(() async {
    try {
      await FirebaseAppCheck.instance.activate(
        // TODO: Replace 'recaptcha-v3-site-key' with your actual reCAPTCHA v3 site key
        // from Google Cloud Console → APIs & Services → Credentials
        webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
        androidProvider: AndroidProvider.playIntegrity,
        appleProvider: AppleProvider.appAttest,
      );
    } catch (e) {
      // Don't let App Check failures crash startup
      debugPrint('AppCheck activation failed: $e');
    }

    try {
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
            alert: true,
            badge: true,
            sound: true,
          );
    } catch (e) {
      debugPrint('FCM foreground options failed: $e');
    }

    try {
      await Repository().initRepo();
    } catch (e) {
      debugPrint('Repository init failed: $e');
    }

    try {
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
    } catch (e) {
      debugPrint('Notification permission request failed: $e');
    }

    if (!Platform.isIOS) {
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );
    }

    // Foreground: system already shows the notification via
    // setForegroundNotificationPresentationOptions.
    FirebaseMessaging.onMessage.listen((_) {});

    // Tapped from background: navigate to the relevant screen based on payload type.
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final type = message.data['type'];
      final id = message.data['id'];
      if (type == 'booking' && id != null) {
        Get.toNamed(
          '/booking-upcoming',
          arguments: {'booking_id': int.tryParse(id.toString())},
        );
      }
    });
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          initialRoute: '/',
          getPages: routes,
        );
      },
    );
  }
}
