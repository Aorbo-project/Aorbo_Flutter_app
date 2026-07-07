class BookingCancelledModal {
  bool? success;
  String? message;
  BookingCancelledData? data;

  BookingCancelledModal({this.success, this.message, this.data});

  BookingCancelledModal.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? BookingCancelledData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class BookingCancelledData {
  int? cancellationId;
  int? bookingId;
  String? status;
  double? totalRefundableAmount;
  double? deduction;
  double? deductionAdmin;
  double? deductionVendor;
  String? cancellationDate;
  TrekDetails? trekDetails;
  BatchDetails? batchDetails;

  String? cancellationNumber;  // Human-readable CAN ID (e.g. CXL-2026-00042)

  // Refund tracking — driven by Razorpay webhooks + reconciliation cron
  bool? isAdvanceOnly;        // FLEX-01: advance forfeited, no cash refund, credit note issued
  bool? creditNoteEligible;   // GST reversal credit note will be generated
  String? refundStatus;       // null | 'initiated' | 'processing' | 'processed' | 'failed'
  String? refundId;           // rfnd_XXXXX — populated after refund.created webhook
  String? refundSpeed;        // 'instant' | 'normal' — populated after refund.created webhook
  String? refundInitiatedAt;
  String? refundProcessedAt;
  int? pollIntervalSeconds;   // Flutter should poll /refund-status at this interval (300 = 5 min)

  BookingCancelledData({
    this.cancellationId,
    this.bookingId,
    this.status,
    this.cancellationNumber,
    this.totalRefundableAmount,
    this.deduction,
    this.deductionAdmin,
    this.deductionVendor,
    this.cancellationDate,
    this.trekDetails,
    this.batchDetails,
    this.isAdvanceOnly,
    this.creditNoteEligible,
    this.refundStatus,
    this.refundId,
    this.refundSpeed,
    this.refundInitiatedAt,
    this.refundProcessedAt,
    this.pollIntervalSeconds,
  });

  BookingCancelledData.fromJson(Map<String, dynamic> json) {
    cancellationId = json['cancellation_id'] != null
        ? int.tryParse(json['cancellation_id'].toString())
        : null;
    bookingId = json['booking_id'] != null
        ? int.tryParse(json['booking_id'].toString())
        : null;
    status = json['status'];
    cancellationNumber = json['cancellation_number'];
    totalRefundableAmount = json['total_refundable_amount'] != null
        ? double.parse(json['total_refundable_amount'].toString())
        : null;
    deduction = json['deduction'] != null
        ? double.parse(json['deduction'].toString())
        : null;
    deductionAdmin = json['deduction_admin'] != null
        ? double.parse(json['deduction_admin'].toString())
        : null;
    deductionVendor = json['deduction_vendor'] != null
        ? double.parse(json['deduction_vendor'].toString())
        : null;
    cancellationDate = json['cancellation_date'];
    trekDetails = json['trek_details'] != null
        ? TrekDetails.fromJson(json['trek_details'])
        : null;
    batchDetails = json['batch_details'] != null
        ? BatchDetails.fromJson(json['batch_details'])
        : null;
    isAdvanceOnly = json['is_advance_only'];
    creditNoteEligible = json['credit_note_eligible'];
    refundStatus = json['refund_status'];
    refundId = json['refund_id'];
    refundSpeed = json['refund_speed'];
    refundInitiatedAt = json['refund_initiated_at'];
    refundProcessedAt = json['refund_processed_at'];
    pollIntervalSeconds = json['poll_interval_seconds'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['cancellation_id'] = cancellationId;
    data['booking_id'] = bookingId;
    data['status'] = status;
    data['cancellation_number'] = cancellationNumber;
    data['total_refundable_amount'] = totalRefundableAmount;
    data['deduction'] = deduction;
    data['deduction_admin'] = deductionAdmin;
    data['deduction_vendor'] = deductionVendor;
    data['cancellation_date'] = cancellationDate;
    if (trekDetails != null) data['trek_details'] = trekDetails!.toJson();
    if (batchDetails != null) data['batch_details'] = batchDetails!.toJson();
    data['is_advance_only'] = isAdvanceOnly;
    data['credit_note_eligible'] = creditNoteEligible;
    data['refund_status'] = refundStatus;
    data['refund_id'] = refundId;
    data['refund_speed'] = refundSpeed;
    data['refund_initiated_at'] = refundInitiatedAt;
    data['refund_processed_at'] = refundProcessedAt;
    data['poll_interval_seconds'] = pollIntervalSeconds;
    return data;
  }
}

class TrekDetails {
  int? id;
  String? title;
  String? basePrice;
  String? mtrId;

  TrekDetails({this.id, this.title, this.basePrice, this.mtrId});

  TrekDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'] != null ? int.tryParse(json['id'].toString()) : null;
    title = json['title'];
    basePrice = json['base_price']?.toString();
    mtrId = (json['mtr_id'] ?? json['display_trek_id'])?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['base_price'] = basePrice;
    data['mtr_id'] = mtrId;
    return data;
  }
}

class BatchDetails {
  int? id;
  String? tbrId;
  String? startDate;
  String? endDate;

  BatchDetails({this.id, this.tbrId, this.startDate, this.endDate});

  BatchDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    tbrId = json['tbr_id'];
    startDate = json['start_date'];
    endDate = json['end_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['tbr_id'] = tbrId;
    data['start_date'] = startDate;
    data['end_date'] = endDate;
    return data;
  }
}
