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
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:sizer/sizer.dart';

import 'config/ad_config.dart';
import 'services/ad_consent_service.dart';
import 'utils/shared_preferences.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Message received while app is terminated/in background — system tray handles display.
}

SpUtil? sp;

final FlutterLocalNotificationsPlugin _localNotifications =
    FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel _fcmChannel = AndroidNotificationChannel(
  'trek_platform_events',
  'Aorbo Notifications',
  description: 'Booking, payment, and trek updates',
  importance: Importance.high,
);

Future<void> _initLocalNotifications() async {
  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidInit);
  await _localNotifications.initialize(initSettings);

  await _localNotifications
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(_fcmChannel);
}

// Resolves once Firebase/Preferences/Repository are ready. runApp() no
// longer waits on this — splash_screen.dart awaits it right before it first
// needs `sp`/the network stack, which is ~800ms into its own animation,
// comfortably after this normally finishes. Previously all of this was
// awaited BEFORE runApp(), so Flutter couldn't draw its first frame until
// it completed — the native splash sat on a blank screen for ~900ms with
// zero visual activity before the logo even appeared.
late Future<void> appBootstrapFuture;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint(
      '╔══ UNCAUGHT ZONE ERROR ══╗\n$error\n$stack\n╚═════════════════════════╝',
    );
    // Firebase may not be initialized yet this early in the timeline now —
    // guard so a startup-time error doesn't throw again inside its own
    // handler.
    try {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    } catch (_) {}
    // Swallow only in debug. In release, let it surface so OS/store vitals
    // report it — silent swallowing ships invisible crashes.
    return kDebugMode;
  };

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  appBootstrapFuture = _bootstrap();

  runApp(const MyApp());
}

Future<void> _bootstrap() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!kDebugMode);
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  await Preferences.initPref();
  sp = await SpUtil.getInstance();
  await Repository().initRepo();

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

    // AdMob — off the critical path. Test ads only until AdConfig.useRealAds.
    // UMP consent is resolved first; nothing requests an ad until
    // AdConsentService.instance.canRequestAds is true.
    try {
      MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(testDeviceIds: AdConfig.testDeviceIds),
      );
      await MobileAds.instance.initialize();
      await AdConsentService.instance.ensureConsent();
      debugPrint('AdMob initialised');
    } catch (e) {
      debugPrint('AdMob init failed: $e');
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

      try {
        await _initLocalNotifications();
      } catch (e) {
        debugPrint('Local notifications init failed: $e');
      }
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (Platform.isIOS) return;

      final notification = message.notification;
      final title = notification?.title ?? message.data['title'];
      final body = notification?.body ?? message.data['body'];
      if (title == null && body == null) return;

      try {
        await _localNotifications.show(
          message.hashCode,
          title,
          body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              _fcmChannel.id,
              _fcmChannel.name,
              channelDescription: _fcmChannel.description,
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
        );
      } catch (e) {
        debugPrint('Failed to show foreground notification: $e');
      }
    });

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

  // The layout is dense and built on fixed `sizer` sizes with no reflow, so
  // an unbounded OS "Font size" setting (Android goes to ~1.3–2.0x) tears
  // screens apart — and ~150 Text widgets already pin TextScaler.linear(1.0)
  // individually, which just makes a large-font device look half-scaled.
  // Clamp app-wide to a small band instead: a little accessibility headroom,
  // no blow-out. Raise the ceiling once per-screen layouts are reflow-safe.
  static const double _minTextScale = 1.0;
  static const double _maxTextScale = 1.15;

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          initialRoute: '/',
          getPages: routes,
          builder: (context, child) {
            final mq = MediaQuery.of(context);
            return MediaQuery(
              data: mq.copyWith(
                textScaler: mq.textScaler.clamp(
                  minScaleFactor: _minTextScale,
                  maxScaleFactor: _maxTextScale,
                ),
              ),
              child: child ?? const SizedBox.shrink(),
            );
          },
          routingCallback: (routing) {
            final screen = routing?.current;
            if (screen == null || screen.isEmpty) return;
            // The very first route push happens synchronously during
            // runApp()'s initial build — now potentially before
            // appBootstrapFuture's Firebase.initializeApp() has completed,
            // since that no longer blocks runApp(). Accessing
            // FirebaseCrashlytics.instance before Firebase is ready throws,
            // which in release mode renders as a blank gray ErrorWidget —
            // this guard is what keeps that from ever surfacing to the user.
            try {
              FirebaseCrashlytics.instance.log('Screen: $screen');
            } catch (_) {}
          },
        );
      },
    );
  }
}
