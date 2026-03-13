# PHASE 2: HIGH-PRIORITY FIXES - BUSINESS LOGIC EXTRACTION

## Overview
Extract business logic from UI widgets into dedicated service layers. This enables testability, reusability, and maintainability.

---

## Fix 1: Extract Payment Calculations to Service Layer

### Create: `lib/services/payment_service.dart`

```dart
import 'package:arobo_app/utils/booking_constants.dart';

class PaymentService {
  /// Calculates exact final amount including all fees and taxes
  static double calculateFinalAmount({
    required double baseFare,
    required double vendorDiscount,
    required double couponDiscount,
    required int adultCount,
    required bool addInsurance,
    required bool addFreeCancellation,
    required String paymentOption,
  }) {
    final insuranceFee = addInsurance
        ? (BookingConstants.insuranceFeePerPerson * adultCount)
        : 0.0;
    
    final cancellationFee = addFreeCancellation
        ? (BookingConstants.cancellationFeePerPerson * adultCount)
        : 0.0;

    // Calculate NET FARE for GST calculation
    double netFare = baseFare - vendorDiscount - couponDiscount;
    final gst = netFare * BookingConstants.gstRate;

    // Calculate total
    double total = netFare + 
        BookingConstants.platformFee + 
        gst + 
        insuranceFee + 
        cancellationFee;

    // Apply payment option logic
    if (paymentOption == BookingConstants.partialPayment) {
      return total * BookingConstants.advancePaymentPercentage;
    }

    return total;
  }

  /// Calculates remaining amount for partial payments
  static double calculateRemainingAmount({
    required double totalAmount,
    required String paymentOption,
  }) {
    if (paymentOption == BookingConstants.partialPayment) {
      final advanceAmount = totalAmount * BookingConstants.advancePaymentPercentage;
      return totalAmount - advanceAmount;
    }
    return 0.0;
  }

  /// Builds fare breakup for API submission
  static Map<String, dynamic> buildFareBreakup({
    required double baseFare,
    required double vendorDiscount,
    required double couponDiscount,
    required int adultCount,
    required bool addInsurance,
    required bool addFreeCancellation,
  }) {
    final insuranceFee = addInsurance
        ? (BookingConstants.insuranceFeePerPerson * adultCount)
        : 0.0;
    
    final cancellationFee = addFreeCancellation
        ? (BookingConstants.cancellationFeePerPerson * adultCount)
        : 0.0;

    double netFare = baseFare - vendorDiscount - couponDiscount;
    final gst = netFare * BookingConstants.gstRate;

    return {
      'baseFare': baseFare,
      'vendorDiscount': vendorDiscount,
      'couponDiscount': couponDiscount,
      'netFare': netFare,
      'platformFee': BookingConstants.platformFee,
      'gst': gst,
      'insuranceFee': insuranceFee,
      'cancellationFee': cancellationFee,
      'total': netFare + BookingConstants.platformFee + gst + insuranceFee + cancellationFee,
    };
  }
}
```

### Update: `lib/screens/payment_screen.dart`

```dart
// ❌ BEFORE
void _openRazorpay() async {
  final finalAmount = _calculateExactFinalAmount();
  final insuranceFee = _selectedInsuranceOption == BookingConstants.addInsurance
      ? (BookingConstants.insuranceFeePerPerson * _adultCount)
      : 0.0;
  // ... 20+ lines of calculation logic
}

// ✅ AFTER
void _openRazorpay() async {
  final finalAmount = PaymentService.calculateFinalAmount(
    baseFare: _totalBaseFare,
    vendorDiscount: _vendorDiscount,
    couponDiscount: _discountAmount,
    adultCount: _adultCount,
    addInsurance: _selectedInsuranceOption == BookingConstants.addInsurance,
    addFreeCancellation: _freeCancellation,
    paymentOption: _selectedPaymentOption,
  );

  var options = {
    'key': BookingConstants.razorpayTestKey,
    'order_id': '${_trekControllerC.orderData.value.id}',
    'amount': (finalAmount * 100).toInt(),
    // ... rest of options
  };

  try {
    _razorpay.open(options);
  } catch (e) {
    logger.e('Razorpay Error: $e');
  }
}
```

---

## Fix 2: Extract Date Formatting to Service Layer

### Create: `lib/services/date_util_service.dart`

```dart
import 'package:intl/intl.dart';

class DateUtilService {
  /// Converts date string to yyyy-MM-dd format
  static String convertToYYYYMMDD(String date) {
    if (date.isEmpty) return '';

    try {
      DateFormat inputFormat;

      // Detect the format
      if (date.contains('/')) {
        inputFormat = DateFormat('dd/MM/yyyy');
      } else if (date.contains('-')) {
        inputFormat = DateFormat('dd-MM-yyyy');
      } else {
        throw FormatException('Unknown date separator');
      }

      final inputDate = inputFormat.parse(date);
      final outputFormat = DateFormat('yyyy-MM-dd');
      return outputFormat.format(inputDate);
    } catch (e) {
      print('Invalid date format: $e');
      return date;
    }
  }

  /// Calculates end date based on start date and duration
  static String calculateEndDate(String startDate, String duration) {
    try {
      DateTime start;
      if (startDate.contains('-')) {
        start = DateFormat('yyyy-MM-dd').parse(startDate);
      } else {
        start = DateFormat('dd/MM/yyyy').parse(startDate);
      }

      String daysStr = duration.split(' ')[0].replaceAll('D', '');
      final int days = int.parse(daysStr);
      final DateTime end = start.add(Duration(days: days));

      return DateFormat('yyyy-MM-dd').format(end);
    } catch (e) {
      print('Error calculating end date: $e');
      return startDate;
    }
  }

  /// Formats duration string (e.g., "5 D" -> "5|D")
  static String formatDuration(String duration) {
    try {
      if (duration.contains(' ')) {
        return duration.replaceAll(' ', '|');
      }
      return duration;
    } catch (e) {
      return duration;
    }
  }

  /// Parses date with flexible format detection
  static DateTime parseDate(String dateString) {
    try {
      if (dateString.contains('/')) {
        return DateFormat('dd/MM/yyyy').parse(dateString);
      } else if (dateString.contains('-')) {
        return DateFormat('yyyy-MM-dd').parse(dateString);
      } else {
        throw FormatException('Unknown date format');
      }
    } catch (e) {
      throw FormatException('Failed to parse date: $dateString');
    }
  }
}
```

### Update: `lib/widgets/slot_booking_details_modal.dart`

```dart
// ❌ BEFORE
String _calculateEndDate(String startDate, String duration) {
  try {
    DateTime start;
    if (startDate.contains('-')) {
      start = DateFormat('yyyy-MM-dd').parse(startDate);
    } else {
      start = DateFormat('dd/MM/yyyy').parse(startDate);
    }
    // ... 10+ lines
  } catch (e) {
    return startDate;
  }
}

// ✅ AFTER
String _calculateEndDate(String startDate, String duration) {
  return DateUtilService.calculateEndDate(startDate, duration);
}
```

### Update: `lib/controller/trek_controller.dart`

```dart
// ❌ BEFORE
static String convertDateYYYYMMDD(String date) {
  if (date.isEmpty) return '';
  try {
    DateFormat inputFormat;
    if (date.contains('/')) {
      inputFormat = DateFormat('dd/MM/yyyy');
    } else if (date.contains('-')) {
      inputFormat = DateFormat('dd-MM-yyyy');
    } else {
      throw FormatException('Unknown date separator');
    }
    // ... 10+ lines
  } catch (e) {
    print('Invalid date format: $e');
  }
}

// ✅ AFTER
static String convertDateYYYYMMDD(String date) {
  return DateUtilService.convertToYYYYMMDD(date);
}
```

---

## Fix 3: Consolidate State Management Patterns

### Issue: Inconsistent state management across screens

**Current Patterns**:
1. Some screens use `Rx<T>` from GetX
2. Some screens use local `bool` state
3. Some screens use `TextEditingController` directly

### Solution: Create `lib/services/state_management_guide.md`

**Standard Pattern for All Screens**:

```dart
// ✅ CORRECT: Use GetX Rx for reactive state
class MyController extends GetxController {
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;
  Rx<MyData> data = MyData().obs;
  
  void updateData(MyData newData) {
    data.value = newData;
  }
}

// ✅ CORRECT: Use Obx for reactive UI
class MyScreen extends StatelessWidget {
  final MyController controller = Get.put(MyController());
  
  @override
  Widget build(BuildContext context) {
    return Obx(() => controller.isLoading.value
        ? LoadingWidget()
        : DataWidget(data: controller.data.value));
  }
}
```

**Files to Update**:
- [ ] `lib/screens/traveller_information_screen.dart` - Mix of Rx and local state
- [ ] `lib/screens/payment_screen.dart` - Mix of Rx and local state
- [ ] `lib/screens/booking_cancle_screen.dart` - Local state only

---

## Fix 4: Create Centralized Validation Service

### Create: `lib/services/validation_service.dart`

```dart
class ValidationService {
  /// Validates phone number (10 digits)
  static bool isValidPhoneNumber(String phone) {
    return phone.length == 10 && RegExp(r'^\d{10}$').hasMatch(phone);
  }

  /// Validates email
  static bool isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email);
  }

  /// Validates traveller name
  static bool isValidName(String name) {
    return name.isNotEmpty && name.length >= 2;
  }

  /// Validates age
  static bool isValidAge(String age) {
    try {
      final ageInt = int.parse(age);
      return ageInt >= 5 && ageInt <= 120;
    } catch (e) {
      return false;
    }
  }

  /// Validates payment amount
  static bool isValidAmount(double amount) {
    return amount > 0;
  }
}
```

---

## Fix 5: Create Centralized Logger Service

### Update: `lib/services/logger_service.dart`

```dart
import 'package:arobo_app/widgets/logger.dart';

class LoggerService {
  static void logInfo(String message) {
    logger.i(message);
  }

  static void logWarning(String message) {
    logger.w(message);
  }

  static void logError(String message, [Object? error, StackTrace? stackTrace]) {
    logger.e(message, error: error, stackTrace: stackTrace);
  }

  static void logDebug(String message) {
    logger.d(message);
  }

  /// Log payment details for debugging
  static void logPaymentDetails({
    required double baseFare,
    required double finalAmount,
    required String paymentOption,
  }) {
    logInfo('Payment Details:');
    logInfo('  Base Fare: $baseFare');
    logInfo('  Final Amount: $finalAmount');
    logInfo('  Payment Option: $paymentOption');
  }

  /// Log API request/response
  static void logApiCall({
    required String endpoint,
    required String method,
    required Map<String, dynamic> data,
  }) {
    logInfo('API Call: $method $endpoint');
    logDebug('Request Data: $data');
  }
}
```

---

## Verification Checklist

After applying Phase 2 fixes:

- [ ] All payment calculations moved to `PaymentService`
- [ ] All date formatting moved to `DateUtilService`
- [ ] All validation logic moved to `ValidationService`
- [ ] State management patterns standardized across all screens
- [ ] No business logic remains in UI widgets
- [ ] All services have unit tests (create `test/services/` directory)
- [ ] App builds without warnings
- [ ] Payment flow works end-to-end

---

## Expected Outcome

✅ **Testable Business Logic**
✅ **Reusable Service Layer**
✅ **Consistent State Management**
✅ **Maintainable Codebase**
✅ **Separation of Concerns**

---

**Estimated Time**: 4-5 hours
**Difficulty**: MEDIUM (requires refactoring and testing)
**Risk Level**: MEDIUM (logic changes, but well-tested)
