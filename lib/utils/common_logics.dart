import 'dart:developer';

import 'package:arobo_app/repository/network_url.dart';
// import 'package:arobo_app/screens/login_screen.dart';
import 'package:arobo_app/screens/splash_screen.dart';
import 'package:arobo_app/utils/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../main.dart';

class CommonLogics {
  static Future<void> logOut() async {
    // Best-effort server-side token revocation — non-fatal if it fails
    try {
      final token = sp!.getString(SpUtil.accessToken);
      if (token != null && token.isNotEmpty) {
        final dio = Dio(BaseOptions(
          baseUrl: NetworkUrl.baseUrl,
          connectTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 8),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ));
        await dio.post(NetworkUrl.logoutPath, data: '{}');
      }
    } catch (_) {}

    await sp!.clear();
    await Get.deleteAll(force: true);
    Get.offAll(() => SplashWithLoginScreen());
  }

  static bool checkUserLogin() {
    bool isLoggedIn = sp!.getBool(SpUtil.isLoggedIn) ?? false;
    if (isLoggedIn) {
      log('token: :::${sp!.getString(SpUtil.accessToken)}');
      return true;
    } else {
      return false;
    }
  }
}
