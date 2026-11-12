import 'dart:io';

import 'package:arobo_app/freezed_models/treks/trek_detail_model.dart';
import 'package:arobo_app/utils/route_stop_tags.dart';
import 'package:arobo_app/widgets/trek_page/trek_page_parts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Trek page redesign (owner, 13 Nov 2026: eye-catching, brand colours only, softly).
void main() {
  TrekStages st(String name, int city, String dt, {String? cityName, String? role, bool boarding = false}) => TrekStages(
        stageName: name,
        cityId: city,
        dateTime: dt,
        isBoardingPoint: boarding,
        city: cityName == null ? null : City(id: city, cityName: cityName),
        routeRole: role,
      );

  TrekDetailData trek({List<TrekStages>? stages, int? days = 3, int? nights = 2, String? start = '2026-11-26'}) => TrekDetailData(
        durationDays: days,
        durationNights: nights,
        startDate: start,
        trekStages: stages,
      );

  final oneCity = [
    st('boarding', 1, '2026-11-26 07:00 PM', cityName: 'Hyderabad', role: 'boarding', boarding: true),
    st('meeting', 1, '2026-11-27 06:00 AM', role: 'meeting_point'),
    st('return', 1, '2026-11-30 07:30 AM', cityName: 'Hyderabad', role: 'arrival'),
  ];
  final twoCities = [
    st('boarding', 1, '2026-11-26 07:00 PM', cityName: 'Hyderabad', role: 'boarding', boarding: true),
    st('boarding', 2, '2026-11-26 09:00 PM', cityName: 'Bangalore', role: 'boarding', boarding: true),
    st('return', 1, '2026-11-30 07:30 AM', role: 'arrival'),
    st('return', 2, '2026-11-30 05:30 AM', role: 'arrival'),
  ];

  group('key facts', () {
    test('one city: date, days, departure time, city, back home', () {
      final f = trekKeyFacts(trek(stages: oneCity));
      expect(f.date, 'Thu 26 Nov');
      expect(f.duration, '3 days · 2 nights');
      expect(f.departTime, '7:00 PM');
      expect(f.fromCity, 'From Hyderabad');
      expect(f.backDate, 'Mon 30 Nov');
      expect(f.backTime, 'Back 7:30 AM');
    });

    test('several cities, none picked: no single time or arrival is claimed', () {
      final f = trekKeyFacts(trek(stages: twoCities));
      expect(f.date, 'Thu 26 Nov');
      expect(f.departTime, isNull);
      expect(f.fromCity, 'From 2 cities');
      expect(f.backDate, isNull);
    });

    test('several cities, one picked: that city\'s own time and arrival', () {
      final f = trekKeyFacts(trek(stages: twoCities), cityId: 2);
      expect(f.departTime, '9:00 PM');
      expect(f.fromCity, 'From Bangalore');
      expect(f.backTime, 'Back 5:30 AM');
    });

    test('a 1-day trek, singular words; no nights sent → days − 1', () {
      expect(trekKeyFacts(trek(stages: oneCity, days: 1, nights: 0)).duration, '1 day · 0 nights');
      expect(trekKeyFacts(trek(stages: oneCity, days: 2, nights: null)).duration, '2 days · 1 night');
    });

    test('nothing usable sent: every item null, never a crash', () {
      final f = trekKeyFacts(const TrekDetailData());
      expect([f.date, f.duration, f.departTime, f.fromCity, f.backDate, f.backTime].every((v) => v == null), isTrue);
      final bad = trekKeyFacts(trek(stages: [st('boarding', 1, 'zzz', boarding: true)], start: 'not-a-date', days: 0));
      expect(bad.date, isNull);
      expect(bad.departTime, isNull);
    });

    test('no server arrival tag (older server): no back-home claim', () {
      final noTags = oneCity.map((s) => s.copyWith(routeRole: null)).toList();
      expect(trekKeyFacts(trek(stages: noTags)).backDate, isNull);
    });
  });

  group('widgets', () {
    Future<void> pump(WidgetTester t, Widget w) => t.pumpWidget(MaterialApp(home: Scaffold(body: Center(child: SizedBox(width: 360, child: w)))));

    testWidgets('key facts card: hidden when there is nothing to say; no overflow at large text', (t) async {
      await pump(t, const TrekKeyFactsCard(facts: TrekKeyFacts()));
      expect(find.byKey(const ValueKey('trek-key-facts')), findsNothing);
      await t.pumpWidget(MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(1.6)),
        child: MaterialApp(home: Scaffold(body: SizedBox(width: 320, child: TrekKeyFactsCard(facts: trekKeyFacts(trek(stages: oneCity)))))),
      ));
      expect(find.text('Thu 26 Nov'), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    testWidgets('photo header: destination on the photo, no photos → a calm placeholder', (t) async {
      await t.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 390,
            height: 380,
            child: TrekHeroPhotos(imageUrls: [], destination: 'Gokarna Dandeli', organiser: 'AORBO INFOCOM', tags: ['Trekking', 'Camping', 'Rafting']),
          ),
        ),
      ));
      expect(find.text('Gokarna Dandeli'), findsOneWidget);
      expect(find.text('Trekking · Camping'), findsOneWidget);
      expect(find.text('AORBO INFOCOM'), findsOneWidget);
      expect(t.takeException(), isNull);
    });
  });

  test('brand colours only, softly: every route tag is a forest or yellow tint', () {
    const brand = {0xFFE8F3ED, 0xFF2D6A4F, 0xFFFFFBD6, 0xFF5C5200, 0xFFFFF4A3, 0xFFD3E6DA, 0xFF1B4332, 0xFFF4F7F5, 0xFF374151};
    for (final r in ['boarding', 'meeting_point', 'meeting_and_return', 'return_start', 'arrival', null]) {
      final (bg, fg) = routeTagColors(r);
      expect(brand.contains(bg.toARGB32()), isTrue, reason: '$r background');
      expect(brand.contains(fg.toARGB32()), isTrue, reason: '$r text');
    }
  });

  test('guard: the trek page uses the redesigned parts and keeps its booking logic', () {
    final src = File('lib/screens/trek_details_screen.dart').readAsStringSync();
    expect(src, contains('_buildHeroSliver()'));
    expect(src, contains('TrekKeyFactsCard('));
    // the bottom keeps the app's own Continue button (owner, 13 Nov 2026)
    expect(src, contains('CommonButton('));
    expect(src.contains('TrekPriceBar('), isFalse);
    expect(src, contains('await _continueBooking();'));
    expect(src, contains('_buildBoardingCityPicker(ctrl, boardingByCityId)'));
    expect(src, contains('trekDiscountedPrice('));
    // no dark icon squares left in the section titles
    expect(src.contains('color: _C.iconBadge'), isFalse);
  });
}
