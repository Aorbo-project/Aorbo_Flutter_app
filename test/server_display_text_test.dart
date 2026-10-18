import 'package:arobo_app/controller/dashboard_controller.dart';
import 'package:arobo_app/models/featured_destination_detail.dart';
import 'package:flutter_test/flutter_test.dart';

// The app shows the server's ready-to-show text as is (aorboweb display.py, 18 Oct 2026):
// wording changes on the server need no app release.
void main() {
  final display = {
    'card': {
      'kicker': '₹8,000 onwards',
      'title': 'Chopta Trek',
      'meta': 'Uttarakhand · Fri, Sat, Sun',
      'description': '2 Days / 1 Night, 3 Days / 2 Nights',
    },
    'detail': {
      'price_label': '₹8,000 onwards',
      'facts': [
        {'key': 'duration', 'label': 'Duration', 'options': ['2 Days / 1 Night', '3 Days / 2 Nights']},
        {'key': 'departure', 'label': 'Departure', 'options': ['Fri', 'Sat', 'Sun']},
        {'key': 'season', 'label': 'Best time', 'options': ['Dec', 'Jan']},
      ],
    },
  };

  test('card: the server lines, exactly as sent', () {
    final data = mapFeaturedDestinationJson({
      'id': 'chopta-trek', 'name': 'raw name', 'state': 'raw', 'price_start': 1,
      'duration_days': '9D/8N', 'operating_days': 'MON', 'display': display,
    });
    expect(data.kicker, '₹8,000 onwards');
    expect(data.title, 'Chopta Trek');
    expect(data.meta, 'Uttarakhand · Fri, Sat, Sun');
    expect(data.description, '2 Days / 1 Night, 3 Days / 2 Nights');
    expect(data.detailUrl, 'https://www.aorbotreks.com/treks/chopta-trek');
    expect(data.trekId, isNull);
  });

  test('card: an older server without display still reads like the website', () {
    final data = mapFeaturedDestinationJson({
      'id': 'x', 'name': 'Chopta Trek', 'state': 'Uttarakhand', 'price_start': 8000,
      'duration_days': '3D/2N,2D/1N', 'operating_days': 'FRI, SAT, SUN',
    });
    expect(data.kicker, '₹8,000 ONWARDS');
    expect(data.description, '2 Days / 1 Night, 3 Days / 2 Nights');
  });

  test('detail: server price label and every row it sends, new rows included', () {
    final d = FeaturedDestinationDetail.fromJson({'name': 'Chopta Trek', 'display': display});
    expect(d.priceLabel, '₹8,000 onwards');
    expect(d.facts.map((f) => f.label), ['Duration', 'Departure', 'Best time']);
    expect(d.facts.last.options, ['Dec', 'Jan']);
  });

  test('detail: an older server -> no server text, the app formats it itself', () {
    final d = FeaturedDestinationDetail.fromJson({'name': 'Chopta Trek', 'price_start': 8000});
    expect(d.priceLabel, isNull);
    expect(d.facts, isEmpty);
  });

  test('detail: broken rows are skipped, not a crash', () {
    expect(DisplayFact.listFrom([{'label': 'Duration'}, 'x', {'label': '', 'options': ['a']}, null]), isEmpty);
    expect(DisplayFact.listFrom('nope'), isEmpty);
  });
}
