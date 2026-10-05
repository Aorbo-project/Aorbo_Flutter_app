import 'dart:developer';

import 'package:arobo_app/repository/network_url.dart';
import 'package:arobo_app/repository/repository.dart';
import 'package:arobo_app/screens/splash_screen.dart';
import 'package:arobo_app/services/session_teardown.dart';
import 'package:arobo_app/utils/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../main.dart';

class CommonLogics {
  static Future<void> logOut() async {
    // Best-effort server-side sign-out (revokes the refresh tokens, clears
    // this phone's push token on the account) — non-fatal if it fails.
    // Scan E3: it used a separate Dio with no refresh handling, so with the
    // 30-min access token an expired token got 401 TOKEN_EXPIRED and the
    // server never ran it. The main client silently refreshes and replays.
    try {
      final token = sp!.getString(SpUtil.accessToken);
      if (token != null && token.isNotEmpty) {
        await Repository().dio
            .post(
              NetworkUrl.logoutPath,
              data: '{}',
              options: Options(
                headers: {'Authorization': 'Bearer $token'},
                // A refused session is handled right here; the network layer
                // must not navigate on its own as well.
                extra: {noSignOutNavigationExtra: true},
              ),
            )
            .timeout(const Duration(seconds: 10));
      }
    } catch (e) {
      log('CommonLogics.logOut: server-side sign-out failed (non-fatal): $e');
    }

    // Always, whatever the server said: stored session, push token, device
    // key, crash-report id.
    await SessionTeardown.clearLocalSession();
    await Get.deleteAll(force: true);
    Get.offAll(() => SplashWithLoginScreen());
  }

  static bool checkUserLogin() {
    bool isLoggedIn = sp!.getBool(SpUtil.isLoggedIn) ?? false;
    if (isLoggedIn) {
      return true;
    } else {
      return false;
    }
  }
}
