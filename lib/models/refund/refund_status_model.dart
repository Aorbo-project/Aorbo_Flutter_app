class RefundStatusModel {
  bool? success;
  RefundStatusData? data;
  String? nextAction;
  RefundStatusNextActionParams? nextActionParams;

  RefundStatusModel({this.success, this.data, this.nextAction, this.nextActionParams});

  RefundStatusModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? RefundStatusData.fromJson(json['data']) : null;
    nextAction = json['next_action'];
    nextActionParams = json['next_action_params'] != null
        ? RefundStatusNextActionParams.fromJson(json['next_action_params'])
        : null;
  }
}

class RefundStatusData {
  int? bookingId;
  int? cancellationId;
  String? cancellationNumber;
  String? cancellationDate;
  double? refundAmount;
  bool? refundApplicable;

  // All refund fields are driven by Razorpay webhooks — never assumed
  String? refundStatus;       // null | 'initiated' | 'processing' | 'processed' | 'failed'
  String? refundId;           // rfnd_XXXXX
  String? refundSpeed;        // 'instant' | 'normal'
  String? refundInitiatedAt;
  String? refundProcessedAt;
  String? refundFailureReason;
  String? statusMessage;      // Human-readable — show directly in UI

  RefundStatusData({
    this.bookingId,
    this.cancellationId,
    this.cancellationNumber,
    this.cancellationDate,
    this.refundAmount,
    this.refundApplicable,
    this.refundStatus,
    this.refundId,
    this.refundSpeed,
    this.refundInitiatedAt,
    this.refundProcessedAt,
    this.refundFailureReason,
    this.statusMessage,
  });

  RefundStatusData.fromJson(Map<String, dynamic> json) {
    // Defensive parsing, matching refundAmount below — the backend always
    // sends these as real JSON numbers today (parseInt(booking_id) in
    // getRefundStatus), but a direct `bookingId = json['booking_id']`
    // assignment is an implicit dynamic->int downcast that throws a
    // TypeError at parse time the moment that ever changes (e.g. a raw SQL
    // query returning a BIGINT id as a string, which some MySQL drivers do).
    bookingId = json['booking_id'] != null
        ? int.tryParse(json['booking_id'].toString())
        : null;
    cancellationId = json['cancellation_id'] != null
        ? int.tryParse(json['cancellation_id'].toString())
        : null;
    cancellationNumber = json['cancellation_number'];
    cancellationDate = json['cancellation_date'];
    refundAmount = json['refund_amount'] != null
        ? double.tryParse(json['refund_amount'].toString())
        : null;
    refundApplicable = json['refund_applicable'];
    refundStatus = json['refund_status'];
    refundId = json['refund_id'];
    refundSpeed = json['refund_speed'];
    refundInitiatedAt = json['refund_initiated_at'];
    refundProcessedAt = json['refund_processed_at'];
    refundFailureReason = json['refund_failure_reason'];
    statusMessage = json['status_message'];
  }

  bool get isProcessed => refundStatus == 'processed';
  bool get isFailed => refundStatus == 'failed';
  bool get isPending => refundStatus == 'initiated' || refundStatus == 'processing';
}

class RefundStatusNextActionParams {
  int? pollIntervalSeconds;

  RefundStatusNextActionParams({this.pollIntervalSeconds});

  RefundStatusNextActionParams.fromJson(Map<String, dynamic> json) {
    pollIntervalSeconds = json['poll_interval_seconds'] != null
        ? int.tryParse(json['poll_interval_seconds'].toString())
        : null;
  }
}
