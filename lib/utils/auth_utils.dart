import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:package_info_plus/package_info_plus.dart';



class AuthUtils {

  AuthUtils._();



  static String? validateRequestFields(List<String> requiredFields, Map<String, dynamic> body) {
    if (requiredFields.contains('mobile') && body['mobile']?.toString().length != 10) {
      return 'Check Your Mobile Number';
    }

    if (requiredFields.contains('otp') && body['otp']?.toString().length != 6) {
      return 'Check Your Otp';
    }

    if (requiredFields.contains('email') && !(body['email']?.toString().contains('@gmail.com') ?? false)) {
      return 'Check Your Email Id';
    }

    List<String> missingFields = requiredFields.where((field) {
      var value = body[field];
      return value == null ||
          value == '' ||
          (value is List && value.isEmpty);
    }).toList();

    if (missingFields.isNotEmpty) {
      return 'Missing required fields: ${missingFields.join(", ")}';
    }

    return null;
  }

  static Future<String?> getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  static Future<String?> getDeviceId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (kIsWeb) {
      WebBrowserInfo webInfo = await deviceInfo.webBrowserInfo;
      return webInfo.userAgent;
    }

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id;
    }

    if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor;
    }

    return null;
  }

  static String getSource() {
    if (kIsWeb) return "web";
    if (Platform.isAndroid) return "android";
    if (Platform.isIOS) return "ios";
    return "unknown";
  }

  static String formatPrice(String price) {
    final number = double.tryParse(price) ?? 0;
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    return formatter.format(number);
  }

  static String formatDateTime(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return '-';
    }

    try {
      // Parse the input (adjust if your format is different)
      final dateTime = DateTime.parse(dateString);

      // Format: 22/12/2024 03:30 PM
      return DateFormat('dd/MM/yyyy hh:mm a').format(dateTime);
    } catch (e) {
      return dateString;
    }
  }

  static String formatDateTimeWithHourDecrease(String? dateString, int hoursToDecrease) {
    if (dateString == null || dateString.isEmpty) {
      return '-';
    }

    try {
      // Parse the input date string
      final dateTime = DateTime.parse(dateString);

      // Decrease hours from the dateTime
      final decreasedDateTime = dateTime.subtract(Duration(hours: hoursToDecrease));

      // Format: 22/12/2024 03:30 PM
      return DateFormat('dd/MM/yyyy hh:mm a').format(decreasedDateTime);
    } catch (e) {
      return dateString;
    }
  }

}