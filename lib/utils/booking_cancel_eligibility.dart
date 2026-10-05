import '../freezed_models/booking/booking_history_model.dart';

/// Whether the server allows cancelling a booking, and its reason when not
/// (e.g. the 6-hours-before-departure lock).
class CancelEligibility {
  const CancelEligibility({required this.allowed, this.message});

  final bool allowed;

  /// The server's cancellation_message; null when it sent none.
  final String? message;
}

/// The booking-detail reply's can_cancel / cancellation_message win; a
/// detail without them falls back to the same booking in the bookings list;
/// with neither, cancelling is allowed (the server re-checks on submit).
CancelEligibility resolveCancelEligibility({
  required BookingHistoryData detail,
  BookingHistoryData? listItem,
}) {
  final source = detail.canCancel != null
      ? detail
      : (listItem?.canCancel != null ? listItem : null);
  if (source == null) return const CancelEligibility(allowed: true);
  final message = source.cancellationMessage?.trim();
  return CancelEligibility(
    allowed: source.canCancel!,
    message: (message == null || message.isEmpty) ? null : message,
  );
}
