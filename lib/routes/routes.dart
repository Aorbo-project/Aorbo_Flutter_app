import 'package:arobo_app/screens/booking_cancellation_success_screen.dart';
import 'package:arobo_app/screens/dashboard_main.dart';
import 'package:arobo_app/screens/issue_report_screen.dart';
import 'package:arobo_app/screens/login_screen.dart';
import 'package:arobo_app/screens/notifications_screen.dart';
import 'package:arobo_app/screens/otp_screen.dart';
import 'package:arobo_app/screens/payment_screen.dart';
import 'package:arobo_app/screens/payment_success_screen.dart';
import 'package:arobo_app/screens/personalized_treks_screen.dart';
import 'package:arobo_app/screens/popular_treks_screen.dart';
import 'package:arobo_app/screens/search_summary_screen.dart';
import 'package:arobo_app/screens/splash_screen.dart';
import 'package:arobo_app/screens/thank_you_screen.dart';
import 'package:arobo_app/screens/coupon_code_screen.dart';
import 'package:arobo_app/screens/traveller_info_screen.dart';

// import 'package:arobo_app/screens/test.dart';
import 'package:arobo_app/screens/trek_details_screen.dart';
import 'package:arobo_app/screens/traveller_information_screen.dart';
import 'package:arobo_app/screens/weekend_treks_screen.dart';
import 'package:arobo_app/screens/my_account_screen.dart';
import 'package:arobo_app/screens/bookings_history_screen.dart';
import 'package:arobo_app/screens/safety_screen.dart';
import 'package:arobo_app/screens/emergency_contacts.dart';
import 'package:arobo_app/screens/selected_emergency_contacts.dart';
import 'package:arobo_app/screens/discount_card_details_screen.dart';
import 'package:arobo_app/screens/know_more_details_screen.dart';
import 'package:arobo_app/screens/about_us_screen.dart';
import 'package:arobo_app/screens/know_more_screen.dart';
import 'package:arobo_app/screens/trek_shorts_screen.dart';
import 'package:arobo_app/screens/seasonal_forecast_screen.dart';

// import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../screens/booking_cancle_screen.dart';
import '../screens/booking_upcoming_screen.dart';
import '../screens/chatboat_screen.dart';
import '../screens/claims_screen.dart';
import '../screens/help_screen.dart';
import '../screens/logout_screen.dart';
import '../screens/refer&earn_screen.dart';
import '../screens/rate_review_screen.dart';

final routes = [
  GetPage(name: '/', page: () => const SplashWithLoginScreen()),
  GetPage(name: '/login', page: () => const LoginScreen()),
  GetPage(name: '/otp', page: () => OTPScreen()),
  GetPage(name: '/dashboard', page: () => const DashboardMain()),
  GetPage(name: '/search', page: () => SearchSummaryScreen()),
  GetPage(name: '/trek-details', page: () => TrekDetailsScreen()),
  GetPage(name: '/traveller-info', page: () => TravellerInformationScreen()),
  GetPage(
    name: '/personalized-treks',
    page: () {
      final args = Get.arguments as Map<String, dynamic>;
      return PersonalizedTreksScreen(arguments: args);
    },
  ),
  GetPage(name: '/thank-you', page: () => const ThankYouScreen()),
  GetPage(
    name: '/weekend-treks',
    page: () {
      final args = Get.arguments as Map<String, dynamic>;
      return WeekendTreksScreen(
        city: args['city'] ?? '',
        trek: args['trek'] ?? '',
        date: args['date'] ?? '',
        weekendDates: (args['weekendDates'] as List<DateTime>?) ?? [],
      );
    },
  ),
  GetPage(name: '/popular-treks', page: () => const PopularTreksScreen()),
  GetPage(name: '/my-account', page: () => const MyAccountScreen()),
  GetPage(name: '/coupon-code', page: () => const CouponCodeScreen()),
  GetPage(
    name: '/traveller-information',
    page: () => const TravellerInfoScreen(),
  ),
  GetPage(name: '/my-bookings', page: () => const BookingsScreen()),
  GetPage(
    name: '/bookingsupcoming',
    page: () => const BookingsUpcomingScreen(),
  ),
  GetPage(name: '/bookingscancel', page: () => const BookingsCancelScreen()),
  GetPage(name: '/safety', page: () => const SafetyScreen()),
  GetPage(name: '/emergency-contacts', page: () => EmergencyContactsScreen()),
  GetPage(
    name: '/selected-emergency-contacts',
    page: () => const SelectedEmergencyContactsScreen(),
  ),
  GetPage(
    name: '/discount-details',
    page: () {
      final args = Get.arguments as Map<String, dynamic>;
      return DiscountCardDetailsScreen(discountCard: args['discountCard']);
    },
  ),
  GetPage(
    name: '/know-more-details',
    page: () {
      final args = Get.arguments as Map<String, dynamic>;
      return KnowMoreDetailsScreen(knowMoreData: args['knowMoreData']);
    },
  ),
  GetPage(name: '/about-us', page: () => const AboutUsScreen()),
  GetPage(name: '/help', page: () => const HelpScreen()),
  GetPage(name: '/notifications', page: () => const NotificationScreen()),
  GetPage(name: '/logout', page: () => const LogoutScreen()),
  GetPage(name: '/chatboat', page: () => const ChatScreen()),
  GetPage(name: '/refers', page: () => const refer()),
  GetPage(name: '/claim', page: () => const claims()),
  GetPage(
    name: '/know-more-screen',
    page: () => const KnowMoreScreen(),
    transition: Transition.rightToLeft,
  ),
  GetPage(name: '/trek-shorts', page: () => const TrekShortsScreen()),
  GetPage(
    name: '/seasonal-forecast',
    page: () => const SeasonalForecastScreen(),
  ),
  GetPage(name: '/payment', page: () => const PaymentScreen()),
  GetPage(name: '/payment-success', page: () => const PaymentSuccessPage()),
  GetPage(name: '/rate-review', page: () => const RateReviewScreen()),
  GetPage(name: '/issue-report', page: () => const IssueReportScreen()),

  GetPage(
    name: '/booking-cancellation-success',
    page: () => const BookingCancellationSuccessScreen(),
  ),
];
