import 'dart:io';
import 'dart:ui';

import 'package:arobo_app/controller/auth_controller.dart';
import 'package:arobo_app/firebase_options.dart';
import 'package:arobo_app/repository/repository.dart';
import 'package:arobo_app/routes/routes.dart';
import 'package:arobo_app/utils/Preferences.dart';
import 'package:arobo_app/utils/app_theme.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import 'utils/shared_preferences.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Message received while app is terminated/in background — system tray handles display.
}

SpUtil? sp;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint(
      '╔══ UNCAUGHT ZONE ERROR ══╗\n$error\n$stack\n╚═════════════════════════╝',
    );
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    // Swallow only in debug. In release, let it surface so OS/store vitals
    // report it — silent swallowing ships invisible crashes.
    return kDebugMode;
  };

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!kDebugMode);
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  await Preferences.initPref();
  sp = await SpUtil.getInstance();

  // Moved from _deferredInit — it's synchronous interceptor wiring.
  await Repository().initRepo();

  runApp(const MyApp());

  _deferredInit();
}

void _deferredInit() {
  Future(() async {
    try {
      await FirebaseAppCheck.instance.activate(
        webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
        androidProvider: AndroidProvider.playIntegrity,
        appleProvider: AppleProvider.appAttest,
      );
    } catch (e) {
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

    FirebaseMessaging.onMessage.listen((_) {});

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      try {
        Get.find<AuthController>().registerFcmToken(newToken);
      } catch (e) {
        debugPrint('onTokenRefresh: AuthController not available yet: $e');
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final event = message.data['event'];
      final bookingId = message.data['bookingId'] ?? message.data['id'];

      switch (event) {
        case 'BOOKING_CONFIRMED':
        case 'TREK_REMINDER':
        case 'TREK_DEPARTURE_SOON':
        case 'TREK_CANCELLED_BY_VENDOR':
        case 'BOOKING_PAYMENT_FAILED':
          Get.toNamed(
            '/my-bookings',
            arguments: {
              'booking_id': int.tryParse(bookingId?.toString() ?? ''),
            },
          );
          return;
        case 'REFUND_INITIATED':
        case 'REFUND_COMPLETED':
        case 'REFUND_ISSUED':
        case 'SLOT_SOLD_OUT_REFUND':
          Get.toNamed(
            '/my-bookings',
            arguments: {
              'booking_id': int.tryParse(bookingId?.toString() ?? ''),
            },
          );
          return;
        case 'COUPON_EXPIRING':
          Get.toNamed('/coupon-code');
          return;
      }

      final type = message.data['type'];
      final id = message.data['id'];
      if (type == 'booking' && id != null) {
        Get.toNamed(
          '/my-bookings',
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
          routingCallback: (routing) {
            final screen = routing?.current;
            if (screen != null && screen.isNotEmpty) {
              FirebaseCrashlytics.instance.log('Screen: $screen');
            }
          },
        );
      },
    );
  }
}
