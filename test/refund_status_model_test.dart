// RefundStatusModel — the poll-response model driving Module M's refund
// status tracker. Hand-written (non-freezed) fromJson with direct field
// assignment for booking_id/cancellation_id/poll_interval_seconds — this
// is an IMPLICIT DYNAMIC DOWNCAST in Dart: it only works because the
// backend (getRefundStatus in newBookingController.js) always sends these
// as real JSON numbers (`parseInt(booking_id)`, `poll_interval_seconds: 300`).
// If that ever changed to a string, this model would throw at parse time,
// not fail gracefully — the last test below demonstrates exactly that.

import 'package:arobo_app/models/refund/refund_status_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RefundStatusModel.fromJson — realistic backend payload', () {
    test('parses a "processing" refund status response', () {
      final json = {
        'success': true,
        'data': {
          'booking_id': 42,
          'cancellation_id': 7,
          'cancellation_number': 'CN20260007',
          'cancellation_date': '2026-08-08T10:00:00.000Z',
          'refund_amount': 3450,
          'refund_applicable': true,
          'refund_status': 'processing',
          'refund_id': null,
          'refund_speed': null,
          'refund_initiated_at': null,
          'refund_processed_at': null,
          'refund_failure_reason': null,
          'status_message': 'Refund is being processed by your bank',
        },
        'next_action': 'POLL_REFUND_STATUS',
        'next_action_params': {'poll_interval_seconds': 300},
      };
      final model = RefundStatusModel.fromJson(json);
      expect(model.data!.bookingId, 42);
      expect(model.data!.refundAmount, 3450.0);
      expect(model.data!.isPending, true);
      expect(model.data!.isProcessed, false);
      expect(model.nextActionParams!.pollIntervalSeconds, 300);
    });

    test('refund_amount arrives as a String -> double.tryParse handles it defensively (no crash)', () {
      final json = {
        'success': true,
        'data': {'booking_id': 1, 'refund_amount': '1409.50', 'refund_status': 'initiated'},
      };
      final model = RefundStatusModel.fromJson(json);
      expect(model.data!.refundAmount, 1409.5);
    });

    test('zero-refund cancellation: refund_status null, next_action NO_REFUND_APPLICABLE (artifact #193)', () {
      final json = {
        'success': true,
        'data': {
          'booking_id': 1, 'refund_amount': 0, 'refund_applicable': false,
          'refund_status': null, 'status_message': 'No refund applicable (full deduction)',
        },
        'next_action': 'NO_REFUND_APPLICABLE',
        'next_action_params': {'poll_interval_seconds': 300},
      };
      final model = RefundStatusModel.fromJson(json);
      expect(model.nextAction, 'NO_REFUND_APPLICABLE');
      expect(model.data!.isPending, false);
      expect(model.data!.isProcessed, false);
      expect(model.data!.isFailed, false);
    });

    test('refund credited: isProcessed true, timestamps present', () {
      final json = {
        'success': true,
        'data': {
          'booking_id': 1, 'refund_amount': 7000, 'refund_status': 'processed',
          'refund_id': 'rfnd_abc', 'refund_processed_at': '2026-08-10T12:00:00.000Z',
        },
        'next_action': 'SHOW_REFUND_CREDITED',
      };
      final model = RefundStatusModel.fromJson(json);
      expect(model.data!.isProcessed, true);
      expect(model.data!.refundId, 'rfnd_abc');
    });

    test('refund failed: isFailed true, failure reason present', () {
      final json = {
        'success': true,
        'data': {
          'booking_id': 1, 'refund_amount': 7000, 'refund_status': 'failed',
          'refund_failure_reason': 'Bank account closed',
        },
        'next_action': 'CONTACT_SUPPORT',
      };
      final model = RefundStatusModel.fromJson(json);
      expect(model.data!.isFailed, true);
      expect(model.data!.refundFailureReason, 'Bank account closed');
    });

    test('data entirely absent (404-shaped error response) -> data is null, no crash', () {
      final model = RefundStatusModel.fromJson({'success': false, 'message': 'Booking not found'});
      expect(model.data, isNull);
    });

    // FIXED 2026-08-08: booking_id/cancellation_id/poll_interval_seconds now
    // parse defensively (int.tryParse(x.toString())), matching the pattern
    // refund_amount already used. Previously a direct dynamic->int downcast
    // that would throw a TypeError the moment the backend ever sent one of
    // these as a String instead of a number (e.g. a raw SQL query returning
    // a BIGINT id as a string, which some MySQL drivers do).
    test('booking_id as a String no longer throws — parses defensively like refund_amount', () {
      final json = {
        'data': {'booking_id': '42', 'refund_amount': 100},
      };
      final model = RefundStatusModel.fromJson(json);
      expect(model.data!.bookingId, 42);
    });

    test('cancellation_id and poll_interval_seconds as Strings also parse defensively', () {
      final json = {
        'data': {'booking_id': 1, 'cancellation_id': '7'},
        'next_action_params': {'poll_interval_seconds': '300'},
      };
      final model = RefundStatusModel.fromJson(json);
      expect(model.data!.cancellationId, 7);
      expect(model.nextActionParams!.pollIntervalSeconds, 300);
    });

    test('a genuinely unparseable id string -> null, not a crash', () {
      final json = {
        'data': {'booking_id': 'not-a-number'},
      };
      final model = RefundStatusModel.fromJson(json);
      expect(model.data!.bookingId, isNull);
    });
  });
}
