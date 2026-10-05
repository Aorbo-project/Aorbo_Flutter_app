// Reusable fake Firebase Core + Crashlytics platform chain for widget tests
// that pump screens touching FirebaseCrashlytics.instance (directly, or via
// AppFeedback's toast layer, which logs every toast to Crashlytics).
//
// Firebase.app() throws synchronously with no real app registered, and that
// throw happens inside an async event handler (Razorpay's callback, in
// PaymentProcessingScreen's case) — so it surfaces as an unhandled Future
// rejection that fails the test, not a caught exception (confirmed by
// isolated repro). Faking the whole chain is the only way to safely pump a
// screen that calls FirebaseCrashlytics.instance.*.
//
// Route taken: fake FirebaseCoreHostApi.initializeCore() at the Pigeon-host
// -api boundary (a plain overridable Dart class, @visibleForTesting per
// firebase_core_platform_interface) rather than a raw MethodChannel mock —
// this is the level the real MethodChannelFirebase already expects to talk
// to, so no channel/codec plumbing is needed. FirebaseCrashlyticsPlatform is
// then swapped directly via its own public settable `.instance`.
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
// ignore: implementation_imports
import 'package:firebase_core_platform_interface/src/pigeon/messages.pigeon.dart';
import 'package:firebase_crashlytics_platform_interface/firebase_crashlytics_platform_interface.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_messaging_platform_interface/firebase_messaging_platform_interface.dart';

class _FakeFirebaseCoreHostApi extends FirebaseCoreHostApi {
  @override
  Future<List<CoreInitializeResponse>> initializeCore() async {
    return [
      CoreInitializeResponse(
        name: defaultFirebaseAppName,
        options: CoreFirebaseOptions(
          apiKey: 'fake-key',
          appId: 'fake-app-id',
          messagingSenderId: 'fake-sender',
          projectId: 'fake-project',
        ),
        isAutomaticDataCollectionEnabled: false,
        pluginConstants: {
          'plugins.flutter.io/firebase_crashlytics': {
            'isCrashlyticsCollectionEnabled': false,
          },
        },
      ),
    ];
  }
}

class FakeCrashlyticsPlatform extends FirebaseCrashlyticsPlatform {
  FakeCrashlyticsPlatform(FirebaseApp app) : super(appInstance: app);

  final List<String> recordedExceptions = [];

  @override
  FirebaseCrashlyticsPlatform setInitialValues({
    required bool isCrashlyticsCollectionEnabled,
  }) => this;

  @override
  Future<void> recordError({
    required String exception,
    required String information,
    required String? reason,
    bool fatal = false,
    String? buildId,
    List<String> loadingUnits = const [],
    List<Map<String, String>>? stackTraceElements,
  }) async {
    recordedExceptions.add(exception);
  }

  @override
  Future<void> log(String message) async {}

  final List<String> userIdentifiers = [];

  @override
  Future<void> setUserIdentifier(String identifier) async {
    userIdentifiers.add(identifier);
  }
}

/// FirebaseMessaging without a device: counts deleteToken() calls and
/// serves a scripted getInitialMessage().
class FakeMessagingPlatform extends FirebaseMessagingPlatform {
  FakeMessagingPlatform() : super();

  int deleteTokenCalls = 0;
  RemoteMessage? initialMessage;

  @override
  FirebaseMessagingPlatform delegateFor({required FirebaseApp app}) => this;

  @override
  FirebaseMessagingPlatform setInitialValues({bool? isAutoInitEnabled}) => this;

  @override
  bool get isAutoInitEnabled => true;

  @override
  Future<void> deleteToken() async {
    deleteTokenCalls++;
  }

  @override
  Future<String?> getToken({String? vapidKey}) async => 'fake-fcm-token';

  @override
  Future<RemoteMessage?> getInitialMessage() async {
    final m = initialMessage;
    initialMessage = null;
    return m;
  }
}

FakeMessagingPlatform? _fakeMessaging;

/// Installs [FakeMessagingPlatform] once per test process (FirebaseMessaging
/// caches its delegate) and resets its counters. Call after
/// [setUpFakeFirebase].
FakeMessagingPlatform setUpFakeMessaging() {
  final fake = _fakeMessaging ??= FakeMessagingPlatform();
  FirebaseMessagingPlatform.instance = fake;
  fake.deleteTokenCalls = 0;
  fake.initialMessage = null;
  return fake;
}

bool _firebaseCoreInitialized = false;

/// Idempotent: safe to call in every test's setup. Firebase.initializeApp()
/// only needs to run once per process (MethodChannelFirebase.appInstances
/// persists across tests, same as SpUtil's caching behavior elsewhere in
/// this suite) — but the crashlytics fake is re-installed each call so each
/// test gets its own recordedExceptions log.
Future<FakeCrashlyticsPlatform> setUpFakeFirebase() async {
  if (!_firebaseCoreInitialized) {
    MethodChannelFirebase.api = _FakeFirebaseCoreHostApi();
    await Firebase.initializeApp();
    _firebaseCoreInitialized = true;
  }
  final fake = FakeCrashlyticsPlatform(Firebase.app());
  FirebaseCrashlyticsPlatform.instance = fake;
  return fake;
}
