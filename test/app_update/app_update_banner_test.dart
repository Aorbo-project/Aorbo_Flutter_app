import 'package:arobo_app/app_update/app_update_banner.dart';
import 'package:arobo_app/app_update/app_update_gate.dart';
import 'package:arobo_app/app_update/app_update_policy.dart';
import 'package:arobo_app/main.dart' show sp;
import 'package:arobo_app/services/app_feedback.dart';
import 'package:arobo_app/utils/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import 'app_update_fakes.dart';

const _availableTitle = 'A new version of Aorbo is available';

AppUpdatePolicy _available(int latestBuild) => AppUpdatePolicy.fromJson({
  'latest_version': '1.2.$latestBuild',
  'latest_build': latestBuild,
  'update_available': true,
  'store_url':
      'https://play.google.com/store/apps/details?id=com.aorbotreks.app',
});

AppUpdatePolicy _announced({
  String? requiredFrom = '2026-10-20T00:00:00.000Z',
  String? message,
}) => AppUpdatePolicy.fromJson({
  'latest_build': 26,
  'min_supported_build': 25,
  'update_available': true,
  'update_announced': true,
  'required_from': requiredFrom,
  'update_message': message,
});

void main() {
  late DateTime now;
  late AppUpdateGate gate;
  late FakeUpdater updater;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    sp = await SpUtil.getInstance();
  });

  setUp(() async {
    Get.testMode = true;
    await sp!.clear();
    now = DateTime.utc(2026, 10, 5, 6); // 5 Oct, 11:30 IST
    gate = AppUpdateGate(
      clock: () => now,
      fetchPolicy: () async => null,
      present: (_) {},
    );
    updater = FakeUpdater();
  });

  tearDown(() {
    gate.dispose();
    AppFeedback.muted = false;
    Get.reset();
  });

  // Phone-sized, like the dashboard's floating card.
  Future<void> pumpBanner(WidgetTester tester) async {
    tester.view.physicalSize = const Size(360 * 3, 780 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      Sizer(
        builder: (context, orientation, deviceType) => GetMaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.all(4.w),
                child: AppUpdateBanner(gate: gate, updater: updater),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('nothing to say: no banner', (tester) async {
    await pumpBanner(tester);
    expect(find.text(_availableTitle), findsNothing);
    expect(find.textContaining('Please update'), findsNothing);

    gate.policy.value = AppUpdatePolicy.fromJson({'update_available': false});
    await tester.pumpAndSettle();
    expect(find.text(_availableTitle), findsNothing);
  });

  testWidgets('update available: shown; Update calls the updater', (
    tester,
  ) async {
    await pumpBanner(tester);
    gate.policy.value = _available(26);
    await tester.pumpAndSettle();

    expect(find.text(_availableTitle), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Update'));
    await tester.pump();
    expect(updater.calls, [
      'https://play.google.com/store/apps/details?id=com.aorbotreks.app',
    ]);
  });

  testWidgets('dismissing is remembered per latest_build', (tester) async {
    gate.policy.value = _available(26);
    await pumpBanner(tester);
    expect(find.text(_availableTitle), findsOneWidget);

    await tester.tap(find.byTooltip('Dismiss'));
    await tester.pumpAndSettle();
    expect(find.text(_availableTitle), findsNothing);
    expect(sp!.getString(SpUtil.dismissedUpdateBuild), 'b26');

    // Next cold start (fresh gate, same prefs): still hidden for build 26.
    gate.dispose();
    gate = AppUpdateGate(
      clock: () => now,
      fetchPolicy: () async => null,
      present: (_) {},
    );
    gate.policy.value = _available(26);
    await pumpBanner(tester);
    expect(find.text(_availableTitle), findsNothing);

    // A newer build is published: back.
    gate.policy.value = _available(27);
    await tester.pumpAndSettle();
    expect(find.text(_availableTitle), findsOneWidget);
  });

  testWidgets(
    'announced: "Please update by <IST date>", hidden for today only',
    (tester) async {
      gate.policy.value = _announced(message: 'We fixed a security issue.');
      await pumpBanner(tester);

      expect(find.text('Please update by 20 Oct 2026'), findsOneWidget);
      expect(find.text('We fixed a security issue.'), findsOneWidget);
      expect(
        find.text(_availableTitle),
        findsNothing,
        reason: 'announced wins over available',
      );

      await tester.tap(find.byTooltip('Hide for today'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Please update by'), findsNothing);
      expect(
        sp!.getString(SpUtil.dismissedUpdateBuild),
        isNull,
        reason: 'not the optional dismissal',
      );

      // Later the same IST day: still hidden.
      now = DateTime.utc(2026, 10, 5, 18, 0); // 23:30 IST
      gate.policy.refresh();
      await tester.pumpAndSettle();
      expect(find.textContaining('Please update by'), findsNothing);

      // Just past IST midnight: back.
      now = DateTime.utc(2026, 10, 5, 18, 31); // 6 Oct, 00:01 IST
      gate.policy.refresh();
      await tester.pumpAndSettle();
      expect(find.text('Please update by 20 Oct 2026'), findsOneWidget);
    },
  );

  testWidgets('announced date is the IST calendar day', (tester) async {
    // 19 Oct 20:00 UTC is already 20 Oct (01:30) in India.
    gate.policy.value = _announced(requiredFrom: '2026-10-19T20:00:00.000Z');
    await pumpBanner(tester);
    expect(find.text('Please update by 20 Oct 2026'), findsOneWidget);

    gate.policy.value = _announced(requiredFrom: null);
    await tester.pumpAndSettle();
    expect(find.text('Please update Aorbo soon'), findsOneWidget);
  });

  testWidgets('update required or blocked: the banner steps aside', (
    tester,
  ) async {
    gate.policy.value = AppUpdatePolicy.fromJson({
      'update_available': true,
      'update_required': true,
      'latest_build': 26,
    });
    await pumpBanner(tester);
    expect(find.text(_availableTitle), findsNothing);

    gate.policy.value = _available(26);
    await tester.pumpAndSettle();
    expect(find.text(_availableTitle), findsOneWidget);

    gate.forceBlock(message: 'Too old');
    await tester.pumpAndSettle();
    expect(find.text(_availableTitle), findsNothing);
  });
}
