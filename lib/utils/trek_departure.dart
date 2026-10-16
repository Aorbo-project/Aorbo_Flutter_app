// The departure the cards show, the same way the server's search does it
// (controllers/v1/trekController.js, 17 Oct 2026): the boarding stage of this
// batch in the city the customer searched from — its date and "05:00 AM" time.
// The checkout card showed only the batch's start date ("2026-10-17") while the
// search card said "2026-10-17 05:00 AM".
import '../freezed_models/treks/trek_detail_model.dart' show TrekStages;

class TrekDeparture {
  const TrekDeparture(this.date, this.time);
  final String date;
  final String? time;
}

final _dateRe = RegExp(r'(\d{4}-\d{2}-\d{2})');
final _timeRe = RegExp(r'(\d{1,2}:\d{2}\s*(?:AM|PM)?)', caseSensitive: false);

TrekDeparture trekDeparture({
  required List<TrekStages>? stages,
  int? batchId,
  int? cityId,
  String? fallbackDate,
}) {
  bool boarding(TrekStages s) =>
      s.isBoardingPoint == true && (s.dateTime ?? '').isNotEmpty && (batchId == null || batchId == 0 || s.batchId == batchId);
  final list = (stages ?? const <TrekStages>[]).where(boarding).toList();
  TrekStages? stage;
  if (cityId != null && cityId != 0) {
    for (final s in list) {
      if (s.cityId == cityId) {
        stage = s;
        break;
      }
    }
  }
  stage ??= list.isNotEmpty ? list.first : null;
  final raw = stage?.dateTime ?? '';
  final date = _dateRe.firstMatch(raw)?.group(1) ?? (fallbackDate ?? '-');
  final time = _timeRe.firstMatch(raw)?.group(1)?.trim();
  return TrekDeparture(date, time);
}
