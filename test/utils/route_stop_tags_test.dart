import 'dart:io';

import 'package:arobo_app/freezed_models/treks/trek_detail_model.dart';
import 'package:arobo_app/utils/route_stop_tags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Trek Route card tags (owner, 12 Nov 2026: "with test cases … so never fails at any
/// case"). The server sends route_role / route_label / travel_after per stop
/// (Backend utils/returnJourney.js routeTags); the app only shows them.
void main() {
  Map<String, dynamic> stop(Map<String, dynamic> extra) => {
        'id': 1,
        'stage_name': 'boarding',
        'destination': 'MGBS',
        'date_time': '2026-11-26 07:00 PM',
        ...extra,
      };

  group('reading the server fields', () {
    test('a tagged stop with a travel line', () {
      final s = TrekStages.fromJson(stop({
        'route_role': 'boarding',
        'route_label': 'Boarding',
        'travel_after': {'minutes': 660, 'label': '≈ 11 h overnight bus'},
      }));
      expect(s.routeRole, 'boarding');
      expect(s.routeLabel, 'Boarding');
      expect(s.travelAfterLabel, '≈ 11 h overnight bus');
    });

    test('an older server (no fields) or nulls: nothing to show, nothing breaks', () {
      final s = TrekStages.fromJson(stop({}));
      expect(s.routeRole, isNull);
      expect(s.routeLabel, isNull);
      expect(s.travelAfterLabel, isNull);
      final n = TrekStages.fromJson(stop({'route_role': null, 'route_label': null, 'travel_after': null}));
      expect(n.routeLabel, isNull);
      expect(n.travelAfterLabel, isNull);
    });

    test('bad data never throws: wrong types, blanks, a label-less travel object', () {
      for (final bad in <dynamic>[42, true, '', '   ', <String, dynamic>{}, <dynamic>[], {'minutes': 5}, {'label': 7}, {'label': '  '}]) {
        final s = TrekStages.fromJson(stop({'route_role': bad, 'route_label': bad, 'travel_after': bad}));
        expect(s.routeRole, isNull, reason: 'role $bad');
        expect(s.routeLabel, isNull, reason: 'label $bad');
        expect(s.travelAfterLabel, isNull, reason: 'travel $bad');
      }
    });

    test('a trek saved on the phone and read back keeps its tag and travel line', () {
      final s = TrekStages.fromJson(stop({
        'route_role': 'return_start',
        'route_label': 'Return starts',
        'travel_after': {'minutes': 660, 'label': '≈ 11 h overnight bus'},
      }));
      final again = TrekStages.fromJson(s.toJson());
      expect(again.routeRole, 'return_start');
      expect(again.routeLabel, 'Return starts');
      expect(again.travelAfterLabel, '≈ 11 h overnight bus');
    });
  });

  group('day + date', () {
    test('"Thu 26 Nov" from the stored stop time; across month and year end', () {
      expect(routeStopDate('2026-11-26 07:00 PM'), 'Thu 26 Nov');
      expect(routeStopDate('2026-11-30 07:30 AM'), 'Mon 30 Nov');
      expect(routeStopDate('2026-12-31 11:59 PM'), 'Thu 31 Dec');
      expect(routeStopDate('2027-01-01 12:00 AM'), 'Fri 1 Jan');
    });

    test('unreadable times give "" (the card then falls back to the old date)', () {
      for (final bad in [null, '', '  ', 'zzz', '2026-11-26', '2026-02-30 06:00 AM', '2026-11-26 13:00 PM']) {
        expect(routeStopDate(bad), '', reason: '$bad');
      }
    });
  });

  group('colours', () {
    test('each role has its own colour; unknown roles get a neutral one', () {
      final roles = ['boarding', 'meeting_point', 'return_start', 'arrival'];
      final colours = roles.map((r) => routeTagColors(r).$1.toARGB32()).toSet();
      expect(colours.length, roles.length);
      expect(routeTagColors('meeting_and_return'), routeTagColors('meeting_point'));
      expect(routeTagColors('something-new'), routeTagColors(null));
    });
  });

  group('what the card shows', () {
    Future<void> pump(WidgetTester t, Widget w) => t.pumpWidget(MaterialApp(home: Scaffold(body: SizedBox(width: 300, child: w))));

    testWidgets('tag and travel line', (t) async {
      await pump(t, const RouteStopExtras(role: 'boarding', label: 'Boarding', travelLabel: '≈ 11 h overnight bus', isLast: false));
      expect(find.text('Boarding'), findsOneWidget);
      expect(find.text('≈ 11 h overnight bus'), findsOneWidget);
    });

    testWidgets('the last stop never shows a travel line (it leads nowhere)', (t) async {
      await pump(t, const RouteStopExtras(role: 'arrival', label: 'Arrival · back home', travelLabel: '≈ 3 h by bus', isLast: true));
      expect(find.text('Arrival · back home'), findsOneWidget);
      expect(find.byKey(const ValueKey('route-stop-travel')), findsNothing);
    });

    testWidgets('nothing sent: nothing shown (older server)', (t) async {
      await pump(t, const RouteStopExtras(role: null, label: null, travelLabel: null, isLast: false));
      expect(find.byKey(const ValueKey('route-stop-tag')), findsNothing);
      expect(find.byKey(const ValueKey('route-stop-travel')), findsNothing);
      await pump(t, const RouteStopExtras(role: 'boarding', label: '  ', travelLabel: '', isLast: false));
      expect(find.byKey(const ValueKey('route-stop-tag')), findsNothing);
    });

    testWidgets('a travel line without a tag still shows; a very long one fits without overflow', (t) async {
      await pump(t, RouteStopExtras(role: null, label: null, travelLabel: '≈ 11 h overnight bus ${'x' * 200}', isLast: false));
      expect(find.byKey(const ValueKey('route-stop-travel')), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    testWidgets('large text setting does not overflow the tag', (t) async {
      await t.pumpWidget(MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
        child: MaterialApp(home: Scaffold(body: SizedBox(width: 120, child: RouteStopExtras(role: 'meeting_and_return', label: 'Meeting point · Return starts', travelLabel: '≈ 25 h by bus', isLast: false)))),
      ));
      expect(t.takeException(), isNull);
    });
  });

  test('guard: the Trek Route card uses the server tags, the day name, and grows its line', () {
    final src = File('lib/screens/trek_details_screen.dart').readAsStringSync();
    expect(src, contains('RouteStopExtras('));
    expect(src, contains('travelLabel: stop.travelAfterLabel,'));
    expect(src, contains('final dayDate = routeStopDate(stop.dateTime);'));
    expect(src, contains('height: lineHeight,'));
    // the app never works the tags out itself
    expect(src.contains("routeRole ==") || src.contains("'Meeting point'"), isFalse);
  });
}
