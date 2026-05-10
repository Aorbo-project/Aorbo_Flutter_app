# PHASE 1: CRITICAL FIXES - AUTOMATED REMEDIATION

## Fix 1: Replace All `.withValues(alpha:)` with `.withOpacity()`

### Files to Fix (47 instances across 20+ files)

```bash
# Automated replacement command (PowerShell)
Get-ChildItem -Path "lib" -Recurse -Include "*.dart" | 
  ForEach-Object {
    (Get-Content $_.FullName) -replace '\.withValues\(alpha:\s*([0-9.]+)\)', '.withOpacity($1)' |
    Set-Content $_.FullName
  }
```

### Manual Verification Checklist

**lib/utils/ files**:
- [ ] trek_shorts.dart (1 instance)
- [ ] seasonal_forecast.dart (1 instance)
- [ ] loader_dialog.dart (1 instance)
- [ ] know_more_card.dart (1 instance)
- [ ] filter_modal.dart (1 instance)
- [ ] coupon_card.dart (2 instances)
- [ ] common_safety_card.dart (1 instance)
- [ ] common_trek_card.dart (2 instances)
- [ ] common_btn.dart (3 instances)
- [ ] common_bottom_nav.dart (1 instance)
- [ ] common_booked_details_card.dart (1 instance)
- [ ] common_booked_card.dart (6 instances)
- [ ] bottom_navigation.dart (1 instance)

**lib/screens/ files**:
- [ ] booking_cancle_screen.dart (2 instances)
- [ ] claims_screen.dart (2 instances)
- [ ] dashboard_widget.dart (5 instances)
- [ ] know_more_details_screen.dart (2 instances)
- [ ] login_screen.dart (3 instances)
- [ ] otp_screen.dart (1 instance)
- [ ] payment_screen.dart (2 instances)
- [ ] trek_details_screen.dart (2 instances)
- [ ] traveller_information_screen.dart (2 instances)
- [ ] weekend_treks_screen.dart (1 instance)

---

## Fix 2: Remove Duplicate Dependencies from pubspec.yaml

### Current Issues:
```yaml
# ❌ REMOVE: Duplicate shimmer package
shimmer_ai: ^1.3.0  # Remove - conflicts with shimmer: ^3.0.0

# ❌ REMOVE: Conflicts with flutter_screenutil
auto_size_text: ^3.0.0  # Remove - use flutter_screenutil instead

# ❌ REMOVE: Already removed from code
sizer: ^2.0.15  # Remove - replaced with flutter_screenutil
```

### Action:
1. Open `pubspec.yaml`
2. Remove lines for: `shimmer_ai`, `auto_size_text`, `sizer`
3. Run: `flutter pub get`
4. Run: `flutter analyze` (should show fewer warnings)

---

## Fix 3: Centralize Hardcoded Asset Paths

### Extend CommonImages class

**File**: `lib/utils/common_images.dart`

**Add these constants**:
```dart
// Image Assets - Booking & Claims
static const String womanWithPlaque = '$basePath/img/womanwithplaque.png';
static const String medicalExpensesInsurance = '$basePath/img/medicalexpensesinsurance.png';
static const String carAccident = '$basePath/img/caraccident.png';
static const String approval = '$basePath/img/approval.png';
static const String knowMore1 = '$basePath/img/knowmore1.png';
static const String knowMore2 = '$basePath/img/knowmore2.png';
static const String knowMore3 = '$basePath/img/knowmore3.png';
static const String knowMore4 = '$basePath/img/knowmore4.png';
static const String knowMore5 = '$basePath/img/knowmore5.png';

// Cover Assets
static const String womanSpeak = '$basePath/cover/womanspeak.png';
static const String mobilePhone = '$basePath/cover/mobilephone.png';
static const String moneyTransfer = '$basePath/cover/moneytransfer.png';

// Animation Assets
static const String tickAnimation = 'assets/animations/tick_animation.json';
static const String busAnimation = 'assets/animations/bus_animation.json';
static const String hikingAnimation = 'assets/animations/hiking_animation.json';
```

### Files to Update:

**lib/screens/booking_upcoming_screen.dart**:
```dart
// ❌ BEFORE
Image.asset('assets/images/img/womanwithplaque.png', ...)

// ✅ AFTER
Image.asset(CommonImages.womanWithPlaque, ...)
```

**lib/screens/claims_screen.dart**:
```dart
// ❌ BEFORE
iconPath: 'assets/images/img/medicalexpensesinsurance.png'
iconPath: 'assets/images/img/caraccident.png'

// ✅ AFTER
iconPath: CommonImages.medicalExpensesInsurance
iconPath: CommonImages.carAccident
```

**lib/screens/refer&earn_screen.dart**:
```dart
// ❌ BEFORE
imagePath: "assets/images/cover/womanspeak.png"
imagePath: "assets/images/cover/mobilephone.png"
imagePath: "assets/images/img/approval.png"
imagePath: "assets/images/cover/moneytransfer.png"

// ✅ AFTER
imagePath: CommonImages.womanSpeak
imagePath: CommonImages.mobilePhone
imagePath: CommonImages.approval
imagePath: CommonImages.moneyTransfer
```

**lib/screens/rate_review_screen.dart**:
```dart
// ❌ BEFORE
Image.asset('assets/images/img/womanwithplaque.png', ...)

// ✅ AFTER
Image.asset(CommonImages.womanWithPlaque, ...)
```

**lib/screens/payment_success_screen.dart**:
```dart
// ❌ BEFORE
Lottie.asset('assets/animations/tick_animation.json', ...)
Lottie.asset('assets/animations/bus_animation.json', ...)

// ✅ AFTER
Lottie.asset(CommonImages.tickAnimation, ...)
Lottie.asset(CommonImages.busAnimation, ...)
```

**lib/models/know_more_data.dart**:
```dart
// ❌ BEFORE
'imagePath': 'assets/images/img/knowmore1.png'
'imagePath': 'assets/images/img/knowmore2.png'
// ... etc

// ✅ AFTER
'imagePath': CommonImages.knowMore1
'imagePath': CommonImages.knowMore2
// ... etc
```

---

## Fix 4: Implement Global Error Handler

### Create new file: `lib/services/error_handler.dart`

```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:arobo_app/utils/custom_snackbar.dart';
import 'package:arobo_app/widgets/logger.dart';

class AppErrorHandler {
  static void setupGlobalErrorHandler() {
    runZonedGuarded(() {
      // Your app initialization here
    }, (error, stackTrace) {
      _handleError(error, stackTrace);
    });
  }

  static void _handleError(Object error, StackTrace stackTrace) {
    logger.e('Uncaught Exception: $error');
    logger.e('Stack Trace: $stackTrace');

    // Log to backend (implement based on your backend)
    _logToBackend(error, stackTrace);

    // Show user-friendly error dialog
    _showErrorDialog(error);
  }

  static void _logToBackend(Object error, StackTrace stackTrace) {
    // TODO: Implement backend logging
    // Example: Send to Sentry, Firebase Crashlytics, or custom backend
  }

  static void _showErrorDialog(Object error) {
    if (Get.context != null) {
      CustomSnackBar.show(
        Get.context!,
        message: 'Something went wrong. Please try again.',
      );
    }
  }
}
```

### Update `lib/main.dart`:

```dart
// ❌ BEFORE
void main() {
  runApp(const MyApp());
}

// ✅ AFTER
void main() {
  AppErrorHandler.setupGlobalErrorHandler();
  runApp(const MyApp());
}
```

---

## Verification Checklist

After applying all Phase 1 fixes:

- [ ] Run `flutter analyze` - should show 0 errors
- [ ] Run `flutter pub get` - should complete without warnings
- [ ] Run `flutter build apk --analyze-size` - should build successfully
- [ ] Search codebase for `.withValues(alpha:` - should return 0 results
- [ ] Search codebase for hardcoded `assets/` paths - should return 0 results
- [ ] Verify all imports of `CommonImages` are correct
- [ ] Test app on Android and iOS - should run without crashes

---

## Expected Outcome

✅ **Zero-Warning Build**
✅ **No Deprecated API Usage**
✅ **Centralized Asset Management**
✅ **Global Error Handling**
✅ **Production-Ready Codebase**

---

**Estimated Time**: 2-3 hours
**Difficulty**: LOW (mostly automated replacements)
**Risk Level**: LOW (no logic changes, only refactoring)
