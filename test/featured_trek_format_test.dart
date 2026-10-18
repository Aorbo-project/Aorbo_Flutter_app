import 'package:arobo_app/utils/featured_trek_format.dart';
import 'package:flutter_test/flutter_test.dart';

// The website's treks read the same in the app as on aorbotreks.com (18 Oct 2026):
// same rule as the website's aorbo-frontend/src/utils/format.js durationOptions.
void main() {
  test('price: Indian digit grouping, like the website', () {
    expect(FeaturedTrekFormat.rupees(15000), '₹15,000');
    expect(FeaturedTrekFormat.rupees('123456'), '₹1,23,456');
    expect(FeaturedTrekFormat.rupees('4,899'), '₹4,899');
    expect(FeaturedTrekFormat.amount(7999), '7,999');
    expect(FeaturedTrekFormat.rupees('N/A'), isNull);
    expect(FeaturedTrekFormat.rupees(null), isNull);
    expect(FeaturedTrekFormat.rupees(0), isNull);
  });

  test('durations: every option in full, shortest first, no duplicates', () {
    expect(FeaturedTrekFormat.durationOptions('3D/2N, 4D/3N,5D/4N'),
        ['3 Days / 2 Nights', '4 Days / 3 Nights', '5 Days / 4 Nights']);
    expect(FeaturedTrekFormat.durationOptions('4D/3N, 2D/1N, 4D/3N'), ['2 Days / 1 Night', '4 Days / 3 Nights']);
    expect(FeaturedTrekFormat.durationOptions('2D/1N Days'), ['2 Days / 1 Night']);
    expect(FeaturedTrekFormat.durationOptions('1D'), ['1 Day']);
    expect(FeaturedTrekFormat.durationOptions('6 Days'), ['6 Days']);
    expect(FeaturedTrekFormat.durationOptions('6'), ['6 Days']);
    expect(FeaturedTrekFormat.durationOptions('10D/9N, 11D/10N'), ['10 Days / 9 Nights', '11 Days / 10 Nights']);
    expect(FeaturedTrekFormat.durationOptions('Flexible'), ['Flexible']);
    expect(FeaturedTrekFormat.durationOptions(null), isEmpty);
    expect(FeaturedTrekFormat.durationText('2D/1N, 3D/2N'), '2 Days / 1 Night, 3 Days / 2 Nights');
  });

  test('never a range like "3-5 Days" (the owner had it removed from the website)', () {
    for (final raw in ['3D/2N, 4D/3N, 5D/4N', '2D/1N,3D/2N,4D/3N,5D/4N', '10D/9N, 11D/10N']) {
      expect(FeaturedTrekFormat.durationText(raw), isNot(matches(RegExp(r'\d\s*[–-]\s*\d'))), reason: raw);
    }
  });

  test('departure days: "THU, FRI, SAT" reads "Thu, Fri, Sat"', () {
    expect(FeaturedTrekFormat.weekdays('THU, FRI, SAT'), ['Thu', 'Fri', 'Sat']);
    expect(FeaturedTrekFormat.weekdays('fri,sat'), ['Fri', 'Sat']);
    expect(FeaturedTrekFormat.weekdays('DAILY'), ['Daily']);
    expect(FeaturedTrekFormat.weekdays(null), isEmpty);
  });
}
