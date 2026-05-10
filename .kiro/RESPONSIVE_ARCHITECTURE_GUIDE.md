# Responsive Architecture Quick Reference Guide

## Overview
This project uses **flutter_screenutil** for responsive scaling. All dimensions must use responsive extensions (`.w`, `.h`, `.sp`, `.r`) or helper utilities.

---

## Quick Start

### 1. Import Required Utilities
```dart
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:arobo_app/utils/screen_constants.dart';
import 'package:arobo_app/utils/responsive_helper.dart';
import 'package:arobo_app/utils/app_text.dart';
```

### 2. Design Size Reference
- **Base Design:** 360 x 690 (configured in main.dart)
- **1.w** = 1% of screen width
- **1.h** = 1% of screen height
- **1.sp** = 1% of screen width (for font sizes)

---

## Common Patterns

### Spacing (Vertical)
```dart
// ✅ CORRECT
ResponsiveHelper.vSpace10        // 10.h
ResponsiveHelper.vSpace20        // 20.h
SizedBox(height: 15.h)           // Custom height

// ❌ WRONG
const SizedBox(height: 10)       // Hardcoded
SizedBox(height: 10)             // No extension
```

### Spacing (Horizontal)
```dart
// ✅ CORRECT
ResponsiveHelper.hSpace8         // 8.w
ResponsiveHelper.hSpace20        // 20.w
SizedBox(width: 15.w)            // Custom width

// ❌ WRONG
const SizedBox(width: 8)         // Hardcoded
SizedBox(width: 8)               // No extension
```

### Border Radius
```dart
// ✅ CORRECT
ResponsiveHelper.radius10        // 10.r
ResponsiveHelper.radius15        // 15.r
BorderRadius.circular(12.r)      // Custom radius

// ❌ WRONG
BorderRadius.circular(10.r)        // Hardcoded
BorderRadius.circular(10.0)      // No extension
```

### Padding
```dart
// ✅ CORRECT
ResponsiveHelper.padding16       // EdgeInsets.all(16.w)
ResponsiveHelper.padding20       // EdgeInsets.all(20.w)
padding: EdgeInsets.all(12.w)    // Custom padding

// ❌ WRONG
padding: EdgeInsets.all(16)      // Hardcoded
padding: EdgeInsets.all(16.0)    // No extension
```

### Font Sizes
```dart
// ✅ CORRECT
fontSize: FontSize.s14           // 14.sp
fontSize: 16.sp                  // Direct extension
style: AppText.heading4          // Predefined style

// ❌ WRONG
fontSize: 14                      // Hardcoded
fontSize: 14.0                    // No extension
```

### Typography
```dart
// ✅ CORRECT
Text('Title', style: AppText.heading4)
Text('Body', style: AppText.body2)
Text('Caption', style: AppText.caption1)

// ❌ WRONG
Text('Title', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700))
```

### Container Dimensions
```dart
// ✅ CORRECT
Container(
  width: 100.w,
  height: 50.h,
  padding: ResponsiveHelper.padding16,
  decoration: BoxDecoration(
    borderRadius: ResponsiveHelper.radius10,
  ),
)

// ❌ WRONG
Container(
  width: 100,
  height: 50,
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(10.r),
  ),
)
```

---

## Available Constants

### ScreenConstant Sizes
```dart
// Width-based (.w)
ScreenConstant.size1 through size100
ScreenConstant.size48  // Common button height

// Height-based (.h)
ScreenConstant.size150
ScreenConstant.size180
ScreenConstant.size320

// Border Radius (.r)
ScreenConstant.circleRadius4
ScreenConstant.circleRadius5
ScreenConstant.circleRadius8
ScreenConstant.circleRadius10
ScreenConstant.circleRadius12
ScreenConstant.circleRadius15
ScreenConstant.circleRadius18
ScreenConstant.circleRadius20
ScreenConstant.circleRadius45

// Icon Sizes
ScreenConstant.defaultIconSize    // 80.w
ScreenConstant.texIconSize        // 30.w
ScreenConstant.drawerIconSize     // 25.w
ScreenConstant.smallIconSize      // 18.w
ScreenConstant.tinyIconSize       // 6.w

// Padding
ScreenConstant.spacingAllSmall    // EdgeInsets.all(10.w)
ScreenConstant.spacingAllMedium   // EdgeInsets.all(16.w)
ScreenConstant.spacingAllLarge    // EdgeInsets.all(20.w)
ScreenConstant.spacingAll30       // EdgeInsets.all(30.w)
```

### FontSize Constants
```dart
FontSize.s6 through FontSize.s50
// All use .sp extension internally
```

### ResponsiveHelper Methods
```dart
// Vertical Spacing
ResponsiveHelper.vSpace3 through vSpace39

// Horizontal Spacing
ResponsiveHelper.hSpace4 through hSpace85

// Border Radius
ResponsiveHelper.radius4 through radius45

// Padding
ResponsiveHelper.padding4 through padding30
ResponsiveHelper.paddingSymmetric(h: 16, v: 8)

// Icon Sizes
ResponsiveHelper.iconXSmall    // 12.sp
ResponsiveHelper.iconSmall     // 16.sp
ResponsiveHelper.iconMedium    // 24.sp
ResponsiveHelper.iconLarge     // 32.sp
ResponsiveHelper.iconXLarge    // 48.sp
```

### AppText Styles
```dart
// Headings
AppText.heading1 (36.sp, w900)
AppText.heading2 (30.sp, w900)
AppText.heading3 (24.sp, w700)
AppText.heading4 (20.sp, w700)

// Subheadings
AppText.subHeading1 (18.sp, w600)
AppText.subHeading2 (16.sp, w600)
AppText.subHeading3 (14.sp, w600)

// Body
AppText.body1 (16.sp, w400)
AppText.body2 (14.sp, w400)
AppText.body3 (13.sp, w400)

// Captions
AppText.caption1 (12.sp, w400)
AppText.caption2 (11.sp, w400)
AppText.caption3 (10.sp, w400)

// Small
AppText.small (9.sp, w400)
AppText.tiny (8.sp, w400)

// Buttons
AppText.buttonLarge (16.sp, w600)
AppText.buttonMedium (14.sp, w600)
AppText.buttonSmall (12.sp, w600)

// Labels
AppText.label (12.sp, w500)
AppText.labelSmall (10.sp, w500)
```

---

## Real-World Examples

### Example 1: Card Widget
```dart
// ✅ CORRECT
Card(
  child: Container(
    padding: ResponsiveHelper.padding16,
    decoration: BoxDecoration(
      borderRadius: ResponsiveHelper.radius12,
      color: Colors.white,
    ),
    child: Column(
      children: [
        Text('Card Title', style: AppText.heading4),
        ResponsiveHelper.vSpace12,
        Text('Card content', style: AppText.body2),
      ],
    ),
  ),
)
```

### Example 2: Button with Icon
```dart
// ✅ CORRECT
ElevatedButton.icon(
  onPressed: () {},
  icon: Icon(Icons.add, size: ResponsiveHelper.iconMedium),
  label: Text('Add Item', style: AppText.buttonMedium),
  style: ElevatedButton.styleFrom(
    padding: ResponsiveHelper.paddingSymmetric(h: 20, v: 12),
    shape: RoundedRectangleBorder(
      borderRadius: ResponsiveHelper.radius10,
    ),
  ),
)
```

### Example 3: List Item
```dart
// ✅ CORRECT
ListTile(
  contentPadding: ResponsiveHelper.padding12,
  title: Text('Item Title', style: AppText.subHeading2),
  subtitle: Text('Subtitle', style: AppText.caption1),
  trailing: Icon(Icons.arrow_right, size: ResponsiveHelper.iconSmall),
  shape: RoundedRectangleBorder(
    borderRadius: ResponsiveHelper.radius8,
  ),
)
```

### Example 4: Form Field
```dart
// ✅ CORRECT
TextFormField(
  decoration: InputDecoration(
    hintText: 'Enter text',
    hintStyle: AppText.caption1,
    contentPadding: ResponsiveHelper.paddingSymmetric(h: 16, v: 12),
    border: OutlineInputBorder(
      borderRadius: ResponsiveHelper.radius10,
    ),
  ),
  style: AppText.body2,
)
```

### Example 5: Grid Layout
```dart
// ✅ CORRECT
GridView.builder(
  padding: ResponsiveHelper.padding16,
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    crossAxisSpacing: 12.w,
    mainAxisSpacing: 12.h,
    childAspectRatio: 1,
  ),
  itemBuilder: (context, index) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: ResponsiveHelper.radius12,
        color: Colors.grey[200],
      ),
      child: Center(
        child: Text('Item $index', style: AppText.body2),
      ),
    );
  },
)
```

---

## Common Mistakes to Avoid

### ❌ Mistake 1: Mixing Hardcoded and Responsive
```dart
// WRONG
SizedBox(
  height: 20,           // Hardcoded
  width: 20.w,          // Responsive
)

// CORRECT
SizedBox(
  height: 20.h,         // Responsive
  width: 20.w,          // Responsive
)
```

### ❌ Mistake 2: Using const with Responsive Values
```dart
// WRONG
const SizedBox(height: 20.h)  // Can't use const with .h

// CORRECT
SizedBox(height: 20.h)        // Remove const
```

### ❌ Mistake 3: Forgetting Extensions
```dart
// WRONG
padding: EdgeInsets.all(16)   // No extension

// CORRECT
padding: EdgeInsets.all(16.w) // With extension
```

### ❌ Mistake 4: Mixing Different Scaling Systems
```dart
// WRONG
width: 100.w,
height: 50,              // Missing extension

// CORRECT
width: 100.w,
height: 50.h,            // Consistent
```

### ❌ Mistake 5: Not Using Predefined Styles
```dart
// WRONG
TextStyle(
  fontSize: 20.sp,
  fontWeight: FontWeight.w700,
  letterSpacing: -0.5,
)

// CORRECT
AppText.heading4
```

---

## Testing Responsive Layouts

### Device Sizes to Test
- **Small:** iPhone SE (375x667)
- **Medium:** iPhone 12 (390x844)
- **Large:** iPhone 14 Pro Max (430x932)
- **Tablet:** iPad (768x1024)
- **Landscape:** All devices in landscape

### Testing Checklist
- [ ] Text scales appropriately
- [ ] Spacing is consistent
- [ ] No overflow errors
- [ ] Buttons are tappable (min 48x48)
- [ ] Images scale correctly
- [ ] Landscape orientation works
- [ ] System text scaling respected

---

## Performance Tips

1. **Use const where possible** (but not with responsive values)
2. **Avoid rebuilding responsive values** in build methods
3. **Cache complex calculations** if needed
4. **Use ResponsiveHelper** for common patterns (faster than calculating)
5. **Profile on real devices** for accurate measurements

---

## Migration Checklist

When updating existing screens:

- [ ] Replace `const SizedBox(height: X)` with `ResponsiveHelper.vSpaceX`
- [ ] Replace `const SizedBox(width: X)` with `ResponsiveHelper.hSpaceX`
- [ ] Replace `BorderRadius.circular(X)` with `ResponsiveHelper.radiusX`
- [ ] Replace `EdgeInsets.all(X)` with `ResponsiveHelper.paddingX`
- [ ] Replace `TextStyle(fontSize: X.sp, ...)` with `AppText.styleX`
- [ ] Add `.w`, `.h`, `.sp`, `.r` extensions to all hardcoded values
- [ ] Test on multiple device sizes
- [ ] Verify no hardcoded pixels remain

---

## Support & Questions

For questions about responsive architecture:
1. Check this guide first
2. Review examples in existing screens
3. Consult the full audit report: `.kiro/UI_ARCHITECTURE_AUDIT_REPORT.md`
4. Ask the team lead

---

**Last Updated:** March 11, 2026  
**Version:** 1.0  
**Status:** Active
