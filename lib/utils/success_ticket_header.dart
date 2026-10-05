import '../freezed_models/booking/booking_history_model.dart' as history;
import '../freezed_models/treks/trek_detail_model.dart' show TrekDetailData;
import '../models/treaks/verify_order_modal.dart' as verify;

/// The success ticket's header: trek name, dates, duration, destination.
///
/// The verify-payment reply normally carries all of it. When it carries a
/// bare booking (on older servers, when the webhook completed the booking
/// first), each value falls back to the booking-detail reply, then to the
/// trek the customer was booking — only if it is the same trek (and, for
/// the dates, the same batch).
class SuccessTicketHeader {
  const SuccessTicketHeader({
    this.title,
    this.duration,
    this.destination,
    this.startDate,
    this.endDate,
  });

  factory SuccessTicketHeader.resolve({
    verify.Data? data,
    history.BookingHistoryData? booking,
    TrekDetailData? trek,
  }) {
    final sameTrek = trek != null &&
        (data?.trekId == null || trek.id == null || data!.trekId == trek.id);
    final sameBatch = sameTrek &&
        data?.batchId != null &&
        trek.batchId != null &&
        data!.batchId == trek.batchId;
    final t = sameTrek ? trek : null;
    final b = sameBatch ? trek : null;
    return SuccessTicketHeader(
      title: _first([data?.trek?.title, booking?.trek?.title, t?.title]),
      duration:
          _first([data?.trek?.duration, booking?.trek?.duration, t?.duration]),
      destination: _first([
        data?.trek?.destinationData?.name,
        booking?.trek?.destination?.name,
        booking?.trek?.destinationName,
        t?.destinationData?.name,
      ]),
      startDate: _first(
          [data?.batch?.startDate, booking?.batch?.startDate, b?.startDate]),
      endDate:
          _first([data?.batch?.endDate, booking?.batch?.endDate, b?.endDate]),
    );
  }

  final String? title;
  final String? duration;
  final String? destination;
  final String? startDate;
  final String? endDate;

  static String? _first(List<String?> values) {
    for (final v in values) {
      if (v != null && v.trim().isNotEmpty) return v;
    }
    return null;
  }
}
