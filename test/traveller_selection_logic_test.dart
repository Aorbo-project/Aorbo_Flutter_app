import 'package:arobo_app/utils/traveller_selection_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Traveller selection count', () {
    test('keeps the higher required count when selected travellers are fewer', () {
      expect(
        resolveRequiredTravelerCount(
          currentRequiredCount: 2,
          selectedCount: 1,
        ),
        2,
      );
    });

    test('raises the count when the selected travellers exceed the current requirement', () {
      expect(
        resolveRequiredTravelerCount(
          currentRequiredCount: 2,
          selectedCount: 3,
        ),
        3,
      );
    });
  });
}
