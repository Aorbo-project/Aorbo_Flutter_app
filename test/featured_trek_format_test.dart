import 'package:arobo_app/utils/featured_trek_format.dart';
import 'package:flutter_test/flutter_test.dart';

// The website's treks read the same in the app as on aorbotreks.com (18 Oct 2026).
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

  test('durations: "3D/2N" reads "3 Days / 2 Nights"', () {
    expect(FeaturedTrekFormat.durationOptions('3D/2N, 4D/3N,5D/4N'),
        ['3 Days / 2 Nights', '4 Days / 3 Nights', '5 Days / 4 Nights']);
    expect(FeaturedTrekFormat.durationOptions('2D/1N Days'), ['2 Days / 1 Night']);
    expect(FeaturedTrekFormat.durationOption('1D'), '1 Day');
    expect(FeaturedTrekFormat.durationOption('6 Days'), '6 Days');
    expect(FeaturedTrekFormat.durationOption('10D/9N'), '10 Days / 9 Nights');
    expect(FeaturedTrekFormat.durationOption('Flexible'), 'Flexible');
    expect(FeaturedTrekFormat.durationOptions(null), isEmpty);
  });

  test('card line: shortest to longest trip', () {
    expect(FeaturedTrekFormat.durationRange('3D/2N, 4D/3N, 5D/4N'), '3–5 Days');
    expect(FeaturedTrekFormat.durationRange('2D/1N'), '2 Days');
    expect(FeaturedTrekFormat.durationRange('10D/9N, 11D/10N'), '10–11 Days');
    expect(FeaturedTrekFormat.durationRange('6'), '6 Days');
    expect(FeaturedTrekFormat.durationRange(''), isNull);
  });

  test('departure days: "THU, FRI, SAT" reads "Thu, Fri, Sat"', () {
    expect(FeaturedTrekFormat.weekdays('THU, FRI, SAT'), ['Thu', 'Fri', 'Sat']);
    expect(FeaturedTrekFormat.weekdays('fri,sat'), ['Fri', 'Sat']);
    expect(FeaturedTrekFormat.weekdays('DAILY'), ['Daily']);
    expect(FeaturedTrekFormat.weekdays(null), isEmpty);
  });
}
