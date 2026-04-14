// ============================================================
// ENVIRONMENT CONFIGURATION
// Pass these at build time using --dart-define flags:
//
//   flutter run \
//     --dart-define=API_BASE_URL=https://your-server.com/api/v1/ \
//     --dart-define=API_IMAGE_URL=https://your-server.com/ \
//     --dart-define=API_SOCKET_URL=https://your-server.com/
//
// For release builds:
//   flutter build apk \
//     --dart-define=API_BASE_URL=https://your-server.com/api/v1/ \
//     --dart-define=API_IMAGE_URL=https://your-server.com/ \
//     --dart-define=API_SOCKET_URL=https://your-server.com/
// ============================================================

import 'package:arobo_app/repository/app_env.dart';

class NetworkUrl {
  NetworkUrl._();

  static  String baseUrl = '${AppEnv().apiBaseUrl}/api/v1/';

  static  String imageUrl = AppEnv().imageUrl;

  //#region Auth
  static const String loginPath = 'customer/auth/request-otp';
  static const String firebaseVerify = 'customer/auth/firebase-verify';

  //#endregion

  // Cities & destinations
  static const String getCitiesList = 'cities';
  static const String getTreksList = 'destinations';
  static const String getStateList = 'states';

  //dashboard

  static String fetchWhatsNew = 'coupons/whatsNew';
  static String fetchTopTreks = 'coupons/topTreks';
  static String fetchShotsTreks = 'coupons/shotsTreks';
  static String fetchSeasonalForcasts = 'coupons/seasonalForcasts';


  //coupons

  static String fetchAdminCoupons(int trekId) => 'coupons/trek/$trekId';

  static String validateVersion(String? version,String platform) => 'version/check?current_version=$version&platform=$platform';

  // Trek search & detail
  static String searchTrek(
    String cityId,
    String destinationId,
    String startDate,
  ) =>
      'treks';
      // 'treks?city_id=$cityId&destination_id=$destinationId&start_date=$startDate';

  static const String getTrekDetail = 'treks/';

  //#region User & Bookings
  static const String getUserProfile = 'customer/auth/profile';
  static const String addTraveller = 'customer/travelers';
  static const String addBooking = 'customer/bookings/create-trek-order';
  static const String verifyBooking = 'customer/bookings/verify-payment';

  static String bookingHistoryWithStatus({
    required int page,
    String? trekStatus,
  }) =>
      'customer/bookings?page=$page&limit=10'
      '${trekStatus == null ? '' : "&trek_status=$trekStatus"}';

  static const String review = 'ratings';

  static String couponCode(String vendorId) => 'coupons/vendor/$vendorId';
  static const String validatedCoupon = 'coupons/validate';

  // Cancellation & refund
  static String refundDetail(String bookingId) =>
      'customer/bookings/cancellation-refund/$bookingId';
  static const String refund = 'customer/bookings/confirm-cancellation';

  // Dispute / issue reporting
  static const String submitIssue = 'issues/submit';
  static String bookingDispute(String bookingId) =>
      'booking-dispute/$bookingId';

  // Emergency contacts
  static const String emergencyContacts = 'customer/emergency-contacts';
  static String deleteEmergencyContact(int id) =>
      'customer/emergency-contacts/$id';
  //#endregion

  //#region Chat
  static  String socketUrl = AppEnv().socketUrl;

  static const String createOrGetChat = 'customer/chats';
  static String getChatMessages(int chatId) =>
      'customer/chats/$chatId/messages';
  static String markMessagesAsRead(int chatId) =>
      'customer/chats/$chatId/read';
  //#endregion
}
