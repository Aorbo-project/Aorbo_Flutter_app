import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class SpUtil {
  //pref- value
  static const String isLoggedIn       = 'is_logged_in';
  static const String userID           = 'user_id';
  static const String userEmail        = 'user_email';
  static const String accessToken      = 'access_token';
  // Rotating refresh token — exchanged at customer/auth/refresh for a new
  // access token when the old one expires (401 + code TOKEN_EXPIRED), so the
  // user is not bounced to the login screen mid-session. Absent when the
  // backend predates refresh-token support.
  static const String refreshToken     = 'refresh_token';
  // True when this login sent a device key (verify-otp devicePublicKey), so
  // every refresh must be signed — an unsigned refresh of a bound session is
  // treated as theft by the backend and ends it. Absent for older logins.
  static const String sessionDeviceBound = 'session_device_bound';
  static const String profileCompleted = 'profile_completed';
  static const String isNewCustomer    = 'is_new_customer';
  static const String deviceId         = 'device_id';
  // Razorpay order_id stored the instant an order is created — BEFORE Razorpay
  // checkout opens — so a killed/crashed app can resume and ask the backend
  // whether this order already succeeded, instead of blindly reopening
  // checkout (or a duplicate charge attempt) on next launch.
  static const String pendingOrderId   = 'pending_razorpay_order_id';
  // Last FCM token the backend confirmed it saved — compared against the
  // current device token on every app open so a failed/skipped registration
  // (flaky network, brief backend outage) gets retried on the next launch
  // instead of leaving that customer without push forever.
  static const String fcmTokenSynced   = 'fcm_token_synced';
  // The "update available" dashboard banner the user closed, keyed by
  // latest_build (AppUpdatePolicy.dismissKey) — it stays hidden until a
  // newer build is published (app_update/app_update_gate.dart).
  static const String dismissedUpdateBuild = 'dismissed_update_build';

  // Last legal-document list from GET legal/documents (JSON), so the
  // Terms / Privacy links still open the server's URLs when offline.
  static const String legalDocuments = 'legal_documents';

  static SpUtil? _instance;

  static Future<SpUtil> get instance async {
    return await getInstance();
  }

  static SharedPreferences? _spf;

  SpUtil._();

  Future _init() async {
    _spf = await SharedPreferences.getInstance();
  }

  static Future<SpUtil> getInstance() async {
    _instance ??= SpUtil._();
    if (_spf == null) {
      await _instance!._init();
    }
    return _instance!;
  }

  bool hasKey(String key) {
    Set keys = getKeys();
    return keys.contains(key);
  }

  Set<String> getKeys() {
    return _spf!.getKeys();
  }

  get(String key) {
    return _spf!.get(key);
  }

  getString(String key) {
    return _spf!.getString(key);
  }

  Future<bool> putString(String key, String value) {
    return _spf!.setString(key, value);
  }

  bool? getBool(String key) {
    return _spf!.getBool(key);
  }

  Future<bool> putBool(String key, bool value) {
    return _spf!.setBool(key, value);
  }

  int? getInt(String key) {
    return _spf!.getInt(key);
  }

  Future<bool> putInt(String key, int value) {
    return _spf!.setInt(key, value);
  }

  double? getDouble(String key) {
    return _spf!.getDouble(key);
  }

  Future<bool> putDouble(String key, double value) {
    return _spf!.setDouble(key, value);
  }

  List<String>? getStringList(String key) {
    return _spf!.getStringList(key);
  }

  Future<bool> putStringList(String key, List<String> value) {
    return _spf!.setStringList(key, value);
  }

  dynamic getDynamic(String key) {
    return _spf!.get(key);
  }

  Future<bool> remove(String key) {
    return _spf!.remove(key);
  }

  Future<bool> clear() {
    return _spf!.clear();
  }

  clearImportantKeys() {}
}
