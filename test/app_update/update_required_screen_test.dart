import 'dart:async';

import 'package:arobo_app/app_update/app_updater.dart';
import 'package:arobo_app/app_update/update_required_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import 'app_update_fakes.dart';

Widget _app(Widget home) => Sizer(
  builder: (context, orientation, deviceType) => GetMaterialApp(home: home),
);

void main() {
  late FakeUpdater updater;

  setUp(() {
    Get.testMode = true;
    updater = FakeUpdater();
  });

  tearDown(() {
    Get.reset();
  });

  Future<void> openOverHome(
    WidgetTester tester, {
    String? message,
    String? storeUrl,
  }) async {
    await tester.pumpWidget(_app(const Scaffold(body: Text('home'))));
    Get.to(
      () => UpdateRequiredScreen(
        message: message,
        storeUrl: storeUrl,
        updater: updater,
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows the server message; back cannot leave it', (tester) async {
    await openOverHome(
      tester,
      message: 'We fixed a security issue. Please update.',
    );

    expect(find.text('Update required'), findsOneWidget);
    expect(
      find.text('We fixed a security issue. Please update.'),
      findsOneWidget,
    );
    expect(find.text(UpdateRequiredScreen.fallbackMessage), findsNothing);

    await tester.binding.handlePopRoute(); // system back
    await tester.pumpAndSettle();
    expect(find.text('Update required'), findsOneWidget);
    expect(find.text('home'), findsNothing);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Update required'), findsOneWidget);
  });

  testWidgets('no (or a blank) message: the fallback text', (tester) async {
    await tester.pumpWidget(_app(UpdateRequiredScreen(updater: updater)));
    expect(find.text(UpdateRequiredScreen.fallbackMessage), findsOneWidget);

    await tester.pumpWidget(
      _app(UpdateRequiredScreen(message: '   ', updater: updater)),
    );
    await tester.pumpAndSettle();
    expect(find.text(UpdateRequiredScreen.fallbackMessage), findsOneWidget);
  });

  testWidgets(
    '"Update now" calls the updater with the store_url, once at a time',
    (tester) async {
      const storeUrl =
          'https://play.google.com/store/apps/details?id=com.aorbotreks.app';
      updater.gate = Completer<void>();
      await tester.pumpWidget(
        _app(UpdateRequiredScreen(storeUrl: storeUrl, updater: updater)),
      );

      await tester.tap(find.text('Update now'));
      await tester.pump();
      expect(updater.calls, [storeUrl]);
      // Busy: spinner instead of the label, a second tap does nothing.
      expect(find.text('Update now'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      expect(updater.calls, hasLength(1));

      updater.gate!.complete();
      await tester.pumpAndSettle();
      expect(find.text('Update now'), findsOneWidget);
      expect(find.textContaining("Couldn't open"), findsNothing);
    },
  );

  testWidgets('nothing could be opened: says so, and stays', (tester) async {
    updater.outcome = AppUpdateOutcome.failed;
    await tester.pumpWidget(_app(UpdateRequiredScreen(updater: updater)));
    await tester.tap(find.text('Update now'));
    await tester.pumpAndSettle();
    expect(find.textContaining("Couldn't open the Play Store"), findsOneWidget);
    expect(find.text('Update now'), findsOneWidget);
  });

  testWidgets('"Close app" closes the app', (tester) async {
    final platformCalls = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        platformCalls.add(call.method);
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );

    await tester.pumpWidget(_app(UpdateRequiredScreen(updater: updater)));
    await tester.tap(find.text('Close app'));
    await tester.pump();
    expect(platformCalls, contains('SystemNavigator.pop'));
    expect(updater.calls, isEmpty);
  });

  testWidgets('fits a small phone with large text', (tester) async {
    tester.view.physicalSize = const Size(320 * 3, 568 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      Sizer(
        builder: (context, orientation, deviceType) => GetMaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.15)),
            child: child!,
          ),
          home: UpdateRequiredScreen(
            message: 'A long message. ' * 12,
            updater: updater,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Update now'), findsOneWidget);
  });
}
