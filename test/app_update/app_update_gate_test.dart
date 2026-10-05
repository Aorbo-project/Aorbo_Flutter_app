import 'dart:async';

import 'package:arobo_app/app_update/app_update_gate.dart';
import 'package:arobo_app/app_update/app_update_policy.dart';
import 'package:arobo_app/app_update/update_required_screen.dart';
import 'package:arobo_app/services/app_feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

const _storeUrl =
    'https://play.google.com/store/apps/details?id=com.aorbotreks.app';

AppUpdatePolicy _required({
  String? message = 'Please update to keep using Aorbo.',
}) => AppUpdatePolicy.fromJson({
  'update_available': true,
  'update_required': true,
  'update_message': message,
  'store_url': _storeUrl,
});

final _upToDate = AppUpdatePolicy.fromJson({'update_available': false});

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DateTime now;
  late int fetches;
  late Future<AppUpdatePolicy?> Function() reply;
  late List<AppUpdateBlock> presented;
  late AppUpdateGate gate;

  AppUpdateGate makeGate({void Function(AppUpdateBlock)? present}) =>
      AppUpdateGate(
        clock: () => now,
        fetchPolicy: () {
          fetches++;
          return reply();
        },
        present: present ?? presented.add,
      );

  setUp(() {
    Get.testMode = true;
    now = DateTime.utc(2026, 10, 5, 6);
    fetches = 0;
    reply = () async => _upToDate;
    presented = [];
    gate = makeGate();
  });

  tearDown(() {
    gate.dispose();
    AppFeedback.muted = false;
    Get.reset();
  });

  group('check()', () {
    test('up to date: carries on', () async {
      expect(await gate.check(), isNotNull);
      expect(gate.isBlocked, isFalse);
      expect(presented, isEmpty);
      expect(gate.policy.value?.updateAvailable, isFalse);
    });

    test(
      'update_required: blocks with the server message and store link',
      () async {
        reply = () async => _required();
        await gate.check();
        expect(gate.isBlocked, isTrue);
        expect(presented, hasLength(1));
        expect(presented.single.message, 'Please update to keep using Aorbo.');
        expect(presented.single.storeUrl, _storeUrl);
        expect(
          AppFeedback.muted,
          isTrue,
          reason: 'stale toasts must not cover it',
        );
      },
    );

    test(
      'fails open: an error or no answer never blocks, last policy kept',
      () async {
        reply = () async => AppUpdatePolicy.fromJson({
          'update_available': true,
          'latest_build': 26,
        });
        await gate.check();

        reply = () async => throw Exception('offline');
        now = now.add(const Duration(hours: 1));
        expect(await gate.check(), isNull);
        reply = () async => null;
        expect(await gate.check(), isNull);

        expect(gate.isBlocked, isFalse);
        expect(presented, isEmpty);
        expect(gate.policy.value?.latestBuild, 26);
      },
    );

    test('concurrent calls share one request', () async {
      final pending = Completer<AppUpdatePolicy?>();
      reply = () => pending.future;
      final a = gate.check();
      final b = gate.check();
      pending.complete(_upToDate);
      await Future.wait([a, b]);
      expect(fetches, 1);
    });
  });

  group('re-check on resume', () {
    test('at most once per 30 minutes', () async {
      await gate.check();
      expect(fetches, 1);

      now = now.add(const Duration(minutes: 10));
      gate.didChangeAppLifecycleState(AppLifecycleState.resumed);
      await gate.recheckIfStale();
      expect(fetches, 1);

      now = now.add(const Duration(minutes: 21)); // 31 min after the check
      await gate.recheckIfStale();
      expect(fetches, 2);

      // Other lifecycle changes never check.
      now = now.add(const Duration(hours: 2));
      gate.didChangeAppLifecycleState(AppLifecycleState.paused);
      gate.didChangeAppLifecycleState(AppLifecycleState.inactive);
      await Future<void>.delayed(Duration.zero);
      expect(fetches, 2);
    });

    test('a resume can block', () async {
      await gate.check();
      reply = () async => _required();
      now = now.add(const Duration(hours: 1));
      await gate.recheckIfStale();
      expect(gate.isBlocked, isTrue);
      expect(presented, hasLength(1));
    });

    test('once blocked, no more checks', () async {
      gate.forceBlock();
      now = now.add(const Duration(days: 1));
      await gate.recheckIfStale();
      expect(fetches, 0);
    });
  });

  group('forceBlock()', () {
    test('only the first call does anything', () async {
      gate.forceBlock(message: 'Too old', storeUrl: _storeUrl);
      gate.forceBlock(message: 'Again');
      reply = () async => _required(message: 'From the check');
      await gate.check();

      expect(presented, hasLength(1));
      expect(gate.block!.message, 'Too old');
    });

    test(
      'no message / unsafe link from the network: falls back to the last policy',
      () async {
        reply = () async => AppUpdatePolicy.fromJson({
          'update_announced': true,
          'update_message': 'Security fix — please update.',
          'store_url': _storeUrl,
        });
        await gate.check();
        expect(gate.isBlocked, isFalse);

        gate.forceBlock(message: '  ', storeUrl: 'intent://x#Intent;end');
        expect(presented.single.message, 'Security fix — please update.');
        expect(presented.single.storeUrl, _storeUrl);
      },
    );

    test(
      'no policy at all: the screen uses its own text and the default store',
      () {
        gate.forceBlock();
        expect(presented.single.message, isNull);
        expect(presented.single.storeUrl, isNull);
      },
    );
  });

  group('the real navigation (Get.offAll)', () {
    Widget app(AppUpdateGate g) => Sizer(
      builder: (context, orientation, deviceType) => GetMaterialApp(
        home: const Scaffold(body: Text('home')),
        // Same hook as main.dart.
        routingCallback: (routing) => g.onRouteChanged(routing?.current),
      ),
    );

    testWidgets('one update screen, and nothing can navigate away from it', (
      tester,
    ) async {
      gate.dispose();
      gate = AppUpdateGate(clock: () => now, fetchPolicy: () async => null);
      AppUpdateGate.instance = gate;
      await tester.pumpWidget(app(gate));

      gate.forceBlock(message: 'Too old');
      gate.forceBlock(message: 'Again');
      await tester.pumpAndSettle();
      expect(find.byType(UpdateRequiredScreen), findsOneWidget);
      expect(find.text('Too old'), findsOneWidget);
      expect(find.text('home'), findsNothing);

      // A notification tap / stray navigation is undone.
      Get.to(() => const Scaffold(body: Text('my bookings')));
      await tester.pumpAndSettle();
      expect(find.text('my bookings'), findsNothing);
      expect(find.byType(UpdateRequiredScreen), findsOneWidget);
      expect(find.text('Too old'), findsOneWidget);

      Get.offAllNamed('/', arguments: {'forcedLogout': true});
      await tester.pumpAndSettle();
      expect(find.byType(UpdateRequiredScreen), findsOneWidget);

      // System back does nothing.
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(UpdateRequiredScreen), findsOneWidget);
      expect(Get.currentRoute, UpdateRequiredScreen.routeName);
    });

    testWidgets('update_required at start-up replaces the current screen', (
      tester,
    ) async {
      gate.dispose();
      gate = AppUpdateGate(
        clock: () => now,
        fetchPolicy: () async => _required(),
      );
      AppUpdateGate.instance = gate;
      await tester.pumpWidget(app(gate));

      await gate.check();
      await tester.pumpAndSettle();
      expect(find.byType(UpdateRequiredScreen), findsOneWidget);
      expect(find.text('Please update to keep using Aorbo.'), findsOneWidget);
      expect(find.text('home'), findsNothing);
    });
  });
}
