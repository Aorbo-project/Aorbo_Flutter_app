// Guard (28 Nov 2026): the payment "Payment cancelled" card showed two EMPTY
// buttons. Cause: AppTheme.lightTheme / AppTextStyles were static fields,
// computed once; if Sizer's first layout saw a 0-wide screen (Android can
// report 0x0 before real metrics) every theme button label was cached at
// font size 0 for the whole session. They are getters now, so sizes follow
// the real screen. This test fails if a cached size ever comes back.
import 'dart:io';

import 'package:arobo_app/utils/app_text_styles.dart';
import 'package:arobo_app/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sizer/sizer.dart';

void main() {
  testWidgets('button labels are visible even if the first frame is 0 wide', (t) async {
    t.view.physicalSize = Size.zero;
    t.view.devicePixelRatio = 1;
    await t.pumpWidget(Sizer(builder: (c, o, d) {
      AppTheme.lightTheme; // touched while the screen is still 0 wide
      AppTextStyles.buttonText;
      return const SizedBox();
    }));
    t.view.physicalSize = const Size(360, 780);
    await t.pumpWidget(Sizer(builder: (c, o, d) => MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 150,
                child: ElevatedButton(onPressed: () {}, child: const Text('RETRY')),
              ),
            ),
          ),
        )));
    await t.pump();
    expect(AppTextStyles.buttonText.fontSize, greaterThan(10));
    expect(t.getSize(find.text('RETRY')).height, greaterThan(10));
    t.view.reset();
  });

  test('no screen-scaled style is cached in a static field', () {
    final bad = <String>[];
    for (final f in ['lib/utils/app_text_styles.dart', 'lib/utils/app_theme.dart']) {
      for (final line in File(f).readAsLinesSync()) {
        if (RegExp(r'static\s+(final\s+)?(TextStyle|ThemeData)\s+\w+\s*=').hasMatch(line)) bad.add('$f: $line');
      }
    }
    expect(bad, isEmpty, reason: 'use "static TextStyle get x => ..." so sizes follow the real screen');
  });
}
