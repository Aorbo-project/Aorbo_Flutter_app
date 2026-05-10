# Quick Start: Responsive Architecture

**TL;DR** - Use these 3 files for all responsive UI:
1. `ResponsiveHelper` - For spacing and sizing
2. `AppText` - For typography
3. `ScreenConstant` - For constants

---

## 30-Second Setup

### Add Imports
```dart
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:arobo_app/utils/responsive_helper.dart';
import 'package:arobo_app/utils/app_text.dart';
import 'package:arobo_app/utils/screen_constants.dart';
```

### Done! Now use:
```dart
// Spacing
ResponsiveHelper.vSpace16    // Vertical space
ResponsiveHelper.hSpace12    // Horizontal space

// Typography
AppText.heading4             // Large heading
AppText.body2                // Body text

// Sizing
ScreenConstant.size48        // Width/height
ResponsiveHelper.radius10    // Border radius
```

---

## Common Patterns (Copy-Paste Ready)

### Pattern 1: Card
```dart
Container(
  padding: ResponsiveHelper.padding16,
  decoration: BoxDecoration(
    borderRadius: ResponsiveHelper.radius12,
    color: Colors.white,
  ),
  child: Column(
    children: [
      Text('Title', style: AppText.heading4),
      ResponsiveHelper.vSpace12,
      Text('Content', style: AppText.body2),
    ],
  ),
)
```

### Pattern 2: Button
```dart
ElevatedButton(
  onPressed: () {},
  style: ElevatedButton.styleFrom(
    padding: ResponsiveHelper.paddingSymmetric(h: 20, v: 12),
    shape: RoundedRectangleBorder(
      borderRadius: ResponsiveHelper.radius10,
    ),
  ),
  child: Text('Button', style: AppText.buttonMedium),
)
```

### Pattern 3: List Item
```dart
ListTile(
  contentPadding: ResponsiveHelper.padding12,
  title: Text('Title', style: AppText.subHeading2),
  subtitle: Text('Subtitle', style: AppText.caption1),
  trailing: Icon(Icons.arrow_right, size: ResponsiveHelper.iconSmall),
)
```

### Pattern 4: Form Field
```dart
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

### Pattern 5: Grid
```dart
GridView.builder(
  padding: ResponsiveHelper.padding16,
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    crossAxisSpacing: 12.w,
    mainAxisSpacing: 12.h,
  ),
  itemBuilder: (context, index) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: ResponsiveHelper.radius12,
      ),
      child: Center(
        child: Text('Item', style: AppText.body2),
      ),
    );
  },
)
```

---

## Cheat Sheet

### Spacing
```dart
ResponsiveHelper.vSpace3      // 3.h
ResponsiveHelper.vSpace5      // 5.h
ResponsiveHelper.vSpace8      // 8.h
ResponsiveHelper.vSpace10     // 10.h
ResponsiveHelper.vSpace12     // 12.h
ResponsiveHelper.vSpace16     // 16.h
ResponsiveHelper.vSpace20     // 20.h
ResponsiveHelper.vSpace24     // 24.h
ResponsiveHelper.vSpace30     // 30.h

ResponsiveHelper.hSpace4      // 4.w
ResponsiveHelper.hSpace8      // 8.w
ResponsiveHelper.hSpace12     // 12.w
ResponsiveHelper.hSpace16     // 16.w
ResponsiveHelper.hSpace20     // 20.w
```

### Border Radius
```dart
ResponsiveHelper.radius4      // 4.r
ResponsiveHelper.radius8      // 8.r
ResponsiveHelper.radius10     // 10.r
ResponsiveHelper.radius12     // 12.r
ResponsiveHelper.radius15     // 15.r
ResponsiveHelper.radius20     // 20.r
```

### Padding
```dart
ResponsiveHelper.padding8     // EdgeInsets.all(8.w)
ResponsiveHelper.padding12    // EdgeInsets.all(12.w)
ResponsiveHelper.padding16    // EdgeInsets.all(16.w)
ResponsiveHelper.padding20    // EdgeInsets.all(20.w)
ResponsiveHelper.padding30    // EdgeInsets.all(30.w)
```

### Typography
```dart
AppText.heading1              // 36.sp, w900
AppText.heading2              // 30.sp, w900
AppText.heading3              // 24.sp, w700
AppText.heading4              // 20.sp, w700

AppText.subHeading1           // 18.sp, w600
AppText.subHeading2           // 16.sp, w600
AppText.subHeading3           // 14.sp, w600

AppText.body1                 // 16.sp, w400
AppText.body2                 // 14.sp, w400
AppText.body3                 // 13.sp, w400

AppText.caption1              // 12.sp, w400
AppText.caption2              // 11.sp, w400
AppText.caption3              // 10.sp, w400

AppText.buttonLarge           // 16.sp, w600
AppText.buttonMedium          // 14.sp, w600
AppText.buttonSmall           // 12.sp, w600

AppText.label                 // 12.sp, w500
AppText.labelSmall            // 10.sp, w500
```

### Icon Sizes
```dart
ResponsiveHelper.iconXSmall   // 12.sp
ResponsiveHelper.iconSmall    // 16.sp
ResponsiveHelper.iconMedium   // 24.sp
ResponsiveHelper.iconLarge    // 32.sp
ResponsiveHelper.iconXLarge   // 48.sp
```

---

## DO's ✅

```dart
// ✅ DO: Use ResponsiveHelper
ResponsiveHelper.vSpace16

// ✅ DO: Use AppText
AppText.heading4

// ✅ DO: Use extensions
SizedBox(height: 20.h)
BorderRadius.circular(10.r)

// ✅ DO: Use ScreenConstant
ScreenConstant.size48

// ✅ DO: Use responsive padding
padding: ResponsiveHelper.padding16
```

---

## DON'Ts ❌

```dart
// ❌ DON'T: Hardcoded values
SizedBox(height: 2.h)
BorderRadius.circular(10.r)
padding: EdgeInsets.all(16)

// ❌ DON'T: Mix systems
height: 20,
width: 20.w

// ❌ DON'T: Forget extensions
fontSize: 14
height: 20

// ❌ DON'T: Use const with responsive
const SizedBox(height: 20.h)
```

---

## Testing Devices

Test on these sizes:
- **Small:** 375x667 (iPhone SE)
- **Medium:** 390x844 (iPhone 12)
- **Large:** 430x932 (iPhone 14 Pro Max)
- **Tablet:** 768x1024 (iPad)

---

## Troubleshooting

### Issue: "Member not found: ResponsiveHelper"
**Fix:** Add import
```dart
import 'package:arobo_app/utils/responsive_helper.dart';
```

### Issue: "Can't use const with .h extension"
**Fix:** Remove const
```dart
// ❌ WRONG
const SizedBox(height: 20.h)

// ✅ CORRECT
SizedBox(height: 20.h)
```

### Issue: "Hardcoded value not scaling"
**Fix:** Add extension
```dart
// ❌ WRONG
height: 20

// ✅ CORRECT
height: 20.h
```

### Issue: "Text too small/large on different devices"
**Fix:** Use AppText or .sp
```dart
// ❌ WRONG
fontSize: 14

// ✅ CORRECT
fontSize: 14.sp
// or
style: AppText.body2
```

---

## Real Example: Complete Screen

```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:arobo_app/utils/responsive_helper.dart';
import 'package:arobo_app/utils/app_text.dart';

class ExampleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Example', style: AppText.heading4),
      ),
      body: SingleChildScrollView(
        padding: ResponsiveHelper.padding16,
        child: Column(
          children: [
            // Header
            Text('Welcome', style: AppText.heading3),
            ResponsiveHelper.vSpace20,
            
            // Card
            Container(
              padding: ResponsiveHelper.padding16,
              decoration: BoxDecoration(
                borderRadius: ResponsiveHelper.radius12,
                color: Colors.grey[100],
              ),
              child: Column(
                children: [
                  Text('Card Title', style: AppText.subHeading2),
                  ResponsiveHelper.vSpace12,
                  Text('Card content', style: AppText.body2),
                ],
              ),
            ),
            ResponsiveHelper.vSpace20,
            
            // Button
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                padding: ResponsiveHelper.paddingSymmetric(h: 20, v: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: ResponsiveHelper.radius10,
                ),
              ),
              child: Text('Click Me', style: AppText.buttonMedium),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## Need More Help?

1. **Quick Reference:** `.kiro/RESPONSIVE_ARCHITECTURE_GUIDE.md`
2. **Full Audit:** `.kiro/UI_ARCHITECTURE_AUDIT_REPORT.md`
3. **Examples:** `lib/screens/logout_screen.dart`
4. **Ask Team:** Slack or team meeting

---

**Version:** 1.0  
**Last Updated:** March 11, 2026  
**Status:** Ready to use
