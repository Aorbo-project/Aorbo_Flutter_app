// Checkout card = search card departure (17 Oct 2026): "2026-10-17 05:00 AM".
import 'package:flutter_test/flutter_test.dart';
import 'package:arobo_app/freezed_models/treks/trek_detail_model.dart' show TrekStages;
import 'package:arobo_app/utils/trek_departure.dart';

void main() {
  const stages = [
    TrekStages(stageName: 'boarding', isBoardingPoint: true, batchId: 7, cityId: 1, dateTime: '2026-10-17 05:00 AM'),
    TrekStages(stageName: 'boarding', isBoardingPoint: true, batchId: 7, cityId: 2, dateTime: '2026-10-17 07:30 AM'),
    TrekStages(stageName: 'boarding', isBoardingPoint: true, batchId: 8, cityId: 1, dateTime: '2026-10-24 05:00 AM'),
    TrekStages(stageName: 'return', isBoardingPoint: false, batchId: 7, cityId: 1, dateTime: '2026-10-19 09:00 PM'),
  ];

  test('the searched city\'s boarding point of this batch', () {
    final d = trekDeparture(stages: stages, batchId: 7, cityId: 2, fallbackDate: '2026-10-16');
    expect([d.date, d.time], ['2026-10-17', '07:30 AM']);
  });

  test('unknown city: the batch\'s first boarding point; never another batch', () {
    final d = trekDeparture(stages: stages, batchId: 7, cityId: 99);
    expect([d.date, d.time], ['2026-10-17', '05:00 AM']);
    expect(trekDeparture(stages: stages, batchId: 8, cityId: 1).date, '2026-10-24');
  });

  test('no boarding stage: the batch date, no time', () {
    final d = trekDeparture(stages: const [], batchId: 7, cityId: 1, fallbackDate: '2026-10-17');
    expect([d.date, d.time], ['2026-10-17', null]);
    expect(trekDeparture(stages: null).date, '-');
  });
}
