import '../repository/app_env.dart';

/// Constants used throughout the booking flow for business logic and UI values
class BookingConstants {


  // Payment Constants
  // Pass at build time: flutter build apk --dart-define=RAZORPAY_KEY=rzp_live_XXXX
  static final String razorpayKey = AppEnv().razorpayKey;
  static const String partialPayment = 'partial';

  // UI Constants
  static const double cardBorderRadius = 4.0;
  static const double buttonHeight = 48.0;
  static const double iconSize = 6.0;
  static const double largeFontSize = 15.0;
  static const double mediumFontSize = 11.0;
  static const double smallFontSize = 9.0;

  // Validation Constants
  static const int phoneNumberLength = 10;
  static const String phoneRegex = r'^[0-9]{10}$';
  static const String emailRegex = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';

  // Default Values
  static const String defaultState = 'Telangana';
  static const String defaultGender = '';
  static const int defaultAdultCount = 1;
}

/// Payment method identifiers
class PaymentMethods {
  static const String razorpay = 'razorpay';
  static const String phonepe = 'phonepe';
  static const String paytm = 'paytm';
  static const String whatsapp = 'whatsapp';
}

/// Route names for navigation
class BookingRoutes {
  static const String couponCode = '/coupon-code';
  static const String payment = '/payment';
  static const String paymentSuccess = '/payment-success';
}

/// Common text messages
class BookingMessages {
  static const String enterCouponCode = 'Enter Coupon Code';
  static const String invalidCouponCode = 'Invalid coupon code';
  static const String paymentSuccessful = 'Payment Successful!';
  static const String paymentFailed = 'Payment Failed!';
  static const String taxIncluded = 'Tax Included';
  static const String totalFare = 'Total Fare';
  static const String payNow = 'Pay Now';
  static const String apply = 'Apply';
  static const String remove = 'Remove';
}