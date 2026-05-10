import 'dart:developer';

// import 'package:arobo_app/screens/login_screen.dart';
import 'package:arobo_app/screens/splash_screen.dart';
import 'package:arobo_app/utils/shared_preferences.dart';
import 'package:get/get.dart';
import '../main.dart';

class CommonLogics {
  static void logOut() async {
    sp!.clear();

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
