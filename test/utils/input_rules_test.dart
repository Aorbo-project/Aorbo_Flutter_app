// Owner, 17 Oct 2026: "€£€¥=}}\%®✓]<>©®{" went into emails, coupon codes,
// searches and names. Each field now blocks what it can't contain.
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arobo_app/utils/input_rules.dart';
import 'package:arobo_app/utils/location_search.dart';

String through(List<TextInputFormatter> rules, String text) {
  var value = TextEditingValue(text: text);
  for (final r in rules) {
    value = r.formatEditUpdate(TextEditingValue.empty, value);
  }
  return value.text;
}

const junk = r'€£€¥=}}\%®✓]<>©®{€|÷∆€§^';

void main() {
  test('names keep letters (any script) and . \' - ; junk is dropped', () {
    expect(through(InputRules.personName, "Ravi D'Souza-Rao"), "Ravi D'Souza-Rao");
    expect(through(InputRules.personName, 'रवि कुमार'), 'रवि कुमार');
    expect(through(InputRules.personName, 'Ra$junk vi1'), 'Ra vi');
  });

  test('emails keep only address characters', () {
    expect(through(InputRules.email, 'abhi.ram+1@gmail.com'), 'abhi.ram+1@gmail.com');
    expect(through(InputRules.email, '$junk@gmail.com'), '%@gmail.com');
    expect(InputRules.emailProblem('%@gmail.com'), isNotNull);
    expect(InputRules.emailProblem('abhi@gmail.com'), isNull);
  });

  test('coupon codes: letters / digits / - _ in capitals', () {
    expect(through(InputRules.couponCode, 'first20'), 'FIRST20');
    expect(through(InputRules.couponCode, '%©™✓[{^¢¢√×∆º™><'), '');
  });

  test('searches keep letters, digits and . , \' - ( ) & /', () {
    expect(through(InputRules.searchText, 'Leh (Ladakh)'), 'Leh (Ladakh)');
    expect(through(InputRules.searchText, '÷º©™™¥€º§✓®\®®©€¢¥=™[]{}<><>^€º✓'), '');
  });

  test('free text keeps anything readable except < > and control characters', () {
    expect(through(InputRules.freeText(), 'Great trek! ₹999 well spent 👍'), 'Great trek! ₹999 well spent 👍');
    expect(through(InputRules.freeText(), '<script>alert(1)</script>'), 'scriptalert(1)/script');
  });

  test('name sentences match the server', () {
    expect(InputRules.nameProblem('R'), 'Name must be 2–60 characters.');
    expect(InputRules.nameProblem('Ravi1'), "Name can have only letters, spaces and . ' -");
    expect(InputRules.nameProblem('Ravi Kumar'), isNull);
  });

  test('a city search of only symbols matches nothing (it listed all 6,582 places)', () {
    final places = [
      LocationEntry(id: 1, name: 'Hyderabad', normalized: normalizeLocationName('Hyderabad')),
      LocationEntry(id: 2, name: 'Goa', normalized: normalizeLocationName('Goa')),
    ];
    expect(filterLocations(places, '÷º©™'), isEmpty);
    expect(filterLocations(places, ''), hasLength(2));
    expect(filterLocations(places, 'goa').map((e) => e.name), ['Goa']);
  });

  test('every typing field in the app has input rules', () {
    const fields = {
      'lib/screens/coupon_code_screen.dart': 'InputRules.couponCode',
      'lib/screens/popular_treks_screen.dart': 'InputRules.searchText',
      'lib/screens/source_location_screen.dart': 'InputRules.searchText',
      'lib/utils/state_selection_bottom_sheet.dart': 'InputRules.searchText',
      'lib/screens/booking_cancle_screen.dart': 'InputRules.freeText',
      'lib/screens/rate_review_screen.dart': 'InputRules.freeText',
      'lib/screens/safety_screen.dart': 'InputRules.personName',
      'lib/screens/contact_support_screen.dart': 'InputRules.email',
      'lib/screens/traveller_information_screen.dart': 'InputRules.email',
      'lib/screens/traveller_info_screen.dart': 'InputRules.personName',
    };
    fields.forEach((file, rule) => expect(File(file).readAsStringSync(), contains(rule), reason: file));
  });
}
