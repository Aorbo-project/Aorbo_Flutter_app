class RefundDetailModal {
  bool? success;
  RefundDetailData? data;

  RefundDetailModal({this.success, this.data});

  RefundDetailModal.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null
        ? RefundDetailData.fromJson(json['data'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class RefundDetailData {
  int? bookingId;
  int? trekId;
  int? batchId;
  int? customerId;
  String? customerName;
  double? finalAmount;
  double? advanceAmount;
  String? paymentStatus;
  String? cancellationPolicyType;
  String? currentDate;
  String? batchStartDate;
  bool? canCancel;
  String? cancellationMessage;
  RefundCalculation? refundCalculation;
  TrekDetails? trekDetails;
  BatchDetails? batchDetails;

  RefundDetailData({
    this.bookingId,
    this.trekId,
    this.batchId,
    this.customerId,
    this.customerName,
    this.finalAmount,
    this.advanceAmount,
    this.paymentStatus,
    this.cancellationPolicyType,
    this.currentDate,
    this.batchStartDate,
    this.canCancel,
    this.cancellationMessage,
    this.refundCalculation,
    this.trekDetails,
    this.batchDetails,
  });

  RefundDetailData.fromJson(Map<String, dynamic> json) {
    bookingId = json['booking_id'];
    trekId = json['trek_id'];
    batchId = json['batch_id'];
    customerId = json['customer_id'];
    customerName = json['customer_name'];
    finalAmount = json['final_amount'] != null
        ? double.parse(json['final_amount'].toString())
        : null;
    advanceAmount = json['advance_amount'] != null
        ? double.parse(json['advance_amount'].toString())
        : null;
    paymentStatus = json['payment_status'];
    cancellationPolicyType = json['cancellation_policy_type'];
    currentDate = json['current_date'];
    batchStartDate = json['batch_start_date'];
    canCancel = json['can_cancel'];
    cancellationMessage = json['cancellation_message'];
    refundCalculation = json['refund_calculation'] != null
        ? RefundCalculation.fromJson(json['refund_calculation'])
        : null;
    trekDetails = json['trek_details'] != null
        ? TrekDetails.fromJson(json['trek_details'])
        : null;
    batchDetails = json['batch_details'] != null
        ? BatchDetails.fromJson(json['batch_details'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['booking_id'] = bookingId;
    data['trek_id'] = trekId;
    data['batch_id'] = batchId;
    data['customer_id'] = customerId;
    data['customer_name'] = customerName;
    data['final_amount'] = finalAmount;
    data['advance_amount'] = advanceAmount;
    data['payment_status'] = paymentStatus;
    data['cancellation_policy_type'] = cancellationPolicyType;
    data['current_date'] = currentDate;
    data['batch_start_date'] = batchStartDate;
    data['can_cancel'] = canCancel;
    data['cancellation_message'] = cancellationMessage;
    if (refundCalculation != null) {
      data['refund_calculation'] = refundCalculation!.toJson();
    }
    if (trekDetails != null) {
      data['trek_details'] = trekDetails!.toJson();
    }
    if (batchDetails != null) {
      data['batch_details'] = batchDetails!.toJson();
    }
    return data;
  }
}

class RefundCalculation {
  double? deduction;
  double? refund;
  int? deductionPercent;
  String? policyType;
  String? slabInfo;
  double? timeRemainingHours;
  String? message;
  double? trekPrice;

  RefundCalculation({
    this.deduction,
    this.refund,
    this.deductionPercent,
    this.policyType,
    this.slabInfo,
    this.timeRemainingHours,
    this.message,
    this.trekPrice,
  });

  RefundCalculation.fromJson(Map<String, dynamic> json) {
    deduction = json['deduction'] != null
        ? double.parse(json['deduction'].toString())
        : null;
    refund = json['refund'] != null
        ? double.parse(json['refund'].toString())
        : null;
    deductionPercent = json['deduction_percent'];
    policyType = json['policy_type'];
    slabInfo = json['slab_info'];
    timeRemainingHours = json['time_remaining_hours'] != null
        ? double.parse(json['time_remaining_hours'].toString())
        : null;
    message = json['message'];
    trekPrice = json['trek_price'] != null
        ? double.parse(json['trek_price'].toString())
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['deduction'] = deduction;
    data['refund'] = refund;
    data['deduction_percent'] = deductionPercent;
    data['policy_type'] = policyType;
    data['slab_info'] = slabInfo;
    data['time_remaining_hours'] = timeRemainingHours;
    data['message'] = message;
    data['trek_price'] = trekPrice;
    return data;
  }
}

class TrekDetails {
  int? id;
  String? title;
  String? basePrice;

  TrekDetails({this.id, this.title, this.basePrice});

  TrekDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    basePrice = json['base_price']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['base_price'] = basePrice;
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
