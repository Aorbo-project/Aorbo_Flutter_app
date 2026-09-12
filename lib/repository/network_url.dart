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

  static String baseUrl = '${AppEnv().apiBaseUrl}/api/v1/';

  static String imageUrl = AppEnv().imageUrl;

  //#region Auth
  static const String loginPath = 'customer/auth/request-otp';
  static const String resendOtpPath = 'customer/auth/resend-otp';
  static const String verifyOtpPath = 'customer/auth/verify-otp';
  static const String refreshTokenPath = 'customer/auth/refresh';
  static const String logoutPath = 'customer/auth/logout';
  static const String deviceToken = 'customer/device-token';
  static const String notifications = 'customer/notifications';
  static String notificationRead(int id) => 'customer/notifications/$id/read';
  static const String notificationReadAll = 'customer/read-all';
  static const String getFaqs = 'customer/faqs';
  static String chatbotReply(String msg) =>
      'customer/chatbot/reply?message=${Uri.encodeComponent(msg)}';

  //#endregion

  // Cities & destinations
  static const String getCitiesList = 'cities';
  static const String getTreksList = 'destinations';
  static const String getStateList = 'states';

  // Dashboard
  static String fetchWhatsNew = 'discovery/whats-new';
  static String fetchTopTreks = 'discovery/top-treks';
  static String fetchSeasonalForcasts = 'discovery/seasonal-forecast';
  static String fetchSeasonalPicks = 'discovery/seasonal-picks';
  static String topTrekFavorite(int id) => 'discovery/top-treks/$id/favorite';
  static String fetchSponsoredSlots = 'discovery/sponsored-slots';
  // cityId/date scope the sponsored trek card to the CURRENT search —
  // without them the backend can't require an exact route+date match and
  // treats the sponsored trek slot as ineligible (see sponsoredSlotController.js).
  static String searchSponsored(
    int? destinationId, {
    int? cityId,
    String? date,
  }) {
    final params = <String, String>{
      if (destinationId != null && destinationId > 0)
        'destination_id': destinationId.toString(),
      if (cityId != null && cityId > 0) 'city_id': cityId.toString(),
      if (date != null && date.isNotEmpty) 'date': date,
    };
    if (params.isEmpty) return 'discovery/search-sponsored';
    final query = params.entries.map((e) => '${e.key}=${e.value}').join('&');
    return 'discovery/search-sponsored?$query';
  }
  static String detailScreenAds(String screen) =>
      'discovery/detail-screen-ads?screen=$screen';
  static String sponsoredSlotImpression(int id) =>
      'discovery/sponsored-slots/$id/impression';
  static String sponsoredSlotClick(int id) =>
      'discovery/sponsored-slots/$id/click';

  // Coupons
  static const String fetchPlatformCoupons = 'coupons/platform';
  static String validateVersion(String? version, String platform) =>
      'version/check?current_version=$version&platform=$platform';
  static String fetchCouponsForTrek(int trekId) => 'coupons/trek/$trekId';
  static String fetchCouponsForBatch({
    required int batchId,
    required int trekId,
  }) => 'coupons/available?batch_id=$batchId&trek_id=$trekId';

  // Trek search & detail
  static String searchTrek(
    String cityId,
    String destinationId,
    String startDate,
    bool? weekEndTreks,
    int page,
    int limit, {
    String filterQuery = '',
  }) {
    final filters = filterQuery.isNotEmpty ? '&$filterQuery' : '';
    final weekend = weekEndTreks != null ? '&weekend_mode=true' : '';
    return 'treks?city_id=$cityId'
        '&destination_id=$destinationId'
        '&start_date=$startDate'
        '$weekend'
        '&page=$page'
        '&limit=$limit'
        '$filters';
  }

  static String searchCalenderTrekDates(
    String cityId,
    String destinationId,
    String startDate,
    String endDate,
  ) => cityId.isNotEmpty && destinationId.isNotEmpty
      ? 'treks/calendar-dates?city_id=$cityId&destination_id=$destinationId&start_date=$startDate&end_date=$endDate'
      : 'treks/calendar-dates?start_date=$startDate&end_date=$endDate';

  static const String getTrekDetail = 'treks/';

  static String getTrekBatches(int trekId) => 'treks/$trekId/batches';

  static String calculateFare = 'bookings/calculate-fare';

  // Notify Me Route Subscriptions
  static const String notifySubscription = 'routes/notify-subscription';
  static String notifyStatus(int fromCityId, int toTrekId) =>
      'routes/notify-status?from_city_id=$fromCityId&to_trek_id=$toTrekId';

  //#region User & Bookings
  static const String getUserProfile = 'customer/auth/profile';
  static const String addTraveller = 'customer/travelers';
  static const String addBooking = 'bookings/create-order';
  static const String verifyBooking = 'bookings/verify-payment';

  static String orderStatus(String orderId) => 'bookings/order-status/$orderId';

  static String bookingHistoryWithStatus({
    required int page,
    String? trekStatus,
  }) =>
      'bookings?page=$page&limit=20'
      '${trekStatus == null ? '' : "&trek_status=$trekStatus"}';

  static const String failedBookingAttempts = 'bookings/failed-attempts';

  static const String review = 'ratings';

  static String couponCode(String vendorId) => 'coupons/vendor/$vendorId';
  static String validateCoupon = 'coupons/validate';

  // Cancellation & refund
  static String refundDetail(String bookingId) =>
      'bookings/cancellation-refund/$bookingId';

  static const String refund = 'bookings/confirm-cancellation';

  static String refundStatus(String bookingId) =>
      'bookings/$bookingId/refund-status';

  // Dispute / issue reporting
  static const String submitIssue = 'issues/submit';
  static String bookingDispute(String bookingId) =>
      'booking-dispute/$bookingId';

  static String bookingDetails(dynamic bookingId) =>
      'booking-details/$bookingId';

  static String invoiceUpload(String bookingNumber) =>
      'customer/bookings/$bookingNumber/invoice';

  // Emergency contacts
  static const String emergencyContacts = 'customer/emergency-contacts';
  static String deleteEmergencyContact(int id) =>
      'customer/emergency-contacts/$id';
  //#endregion

  //#region Chat
  static String socketUrl = AppEnv().socketUrl;

  static const String createOrGetChat = 'customer/chats';
  static String getChatMessages(int chatId) =>
      'customer/chats/$chatId/messages';
  static String markMessagesAsRead(int chatId) => 'customer/chats/$chatId/read';
  //#endregion

  //#region Referral
  // GET  → my code, share text, live reward config, stats, milestone, history.
  //        The backend generates the customer's code lazily on this call.
  static const String referralInfo = 'customer/referral';
  // POST { code } → applies a referrer's code to my account (pre-first-booking only).
  static const String referralApply = 'customer/referral/apply';
  // GET ?code=&phone= → pre-check for the login-screen field. Passing the
  // typed phone lets the backend say "new accounts only" for an existing user
  // instead of a false "you'll get ₹50 off".
  static String referralValidate(String code, {String? phone}) {
    final q = StringBuffer('customer/referral/validate?code=')
      ..write(Uri.encodeComponent(code));
    if (phone != null && phone.trim().isNotEmpty) {
      q.write('&phone=${Uri.encodeComponent(phone.trim())}');
    }
    return q.toString();
  }
  //#endregion
}
