class RefundDetailModal {
  bool? success;
  RefundDetailData? data;
  String? nextAction;
  NextActionParams? nextActionParams;

  RefundDetailModal({this.success, this.data, this.nextAction, this.nextActionParams});

  RefundDetailModal.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? RefundDetailData.fromJson(json['data']) : null;
    nextAction = json['next_action'];
    nextActionParams = json['next_action_params'] != null
        ? NextActionParams.fromJson(json['next_action_params'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (this.data != null) data['data'] = this.data!.toJson();
    data['next_action'] = nextAction;
    if (nextActionParams != null) data['next_action_params'] = nextActionParams!.toJson();
    return data;
  }
}

class NextActionParams {
  String? reason;
  int? bookingId;
  String? warning;
  double? refundAmount;
  double? deductionAmount;

  NextActionParams({
    this.reason,
    this.bookingId,
    this.warning,
    this.refundAmount,
    this.deductionAmount,
  });

  NextActionParams.fromJson(Map<String, dynamic> json) {
    reason = json['reason'];
    bookingId = json['booking_id'];
    warning = json['warning'];
    refundAmount = json['refund_amount'] != null
        ? double.parse(json['refund_amount'].toString())
        : null;
    deductionAmount = json['deduction_amount'] != null
        ? double.parse(json['deduction_amount'].toString())
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['reason'] = reason;
    data['booking_id'] = bookingId;
    data['warning'] = warning;
    data['refund_amount'] = refundAmount;
    data['deduction_amount'] = deductionAmount;
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
  int? cancellationPolicyId;
  String? cancellationPolicyName;
  String? cancellationPolicyType;
  String? paymentStatus;
  String? currentDate;
  String? batchStartDate;
  double? timeRemainingHours;
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
    this.cancellationPolicyId,
    this.cancellationPolicyName,
    this.cancellationPolicyType,
    this.paymentStatus,
    this.currentDate,
    this.batchStartDate,
    this.timeRemainingHours,
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
    cancellationPolicyId = json['cancellation_policy_id'];
    cancellationPolicyName = json['cancellation_policy_name'];
    cancellationPolicyType = json['cancellation_policy_type'];
    paymentStatus = json['payment_status'];
    currentDate = json['current_date'];
    batchStartDate = json['batch_start_date'];
    timeRemainingHours = json['time_remaining_hours'] != null
        ? double.parse(json['time_remaining_hours'].toString())
        : null;
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
    data['cancellation_policy_id'] = cancellationPolicyId;
    data['cancellation_policy_name'] = cancellationPolicyName;
    data['cancellation_policy_type'] = cancellationPolicyType;
    data['payment_status'] = paymentStatus;
    data['current_date'] = currentDate;
    data['batch_start_date'] = batchStartDate;
    data['time_remaining_hours'] = timeRemainingHours;
    data['can_cancel'] = canCancel;
    data['cancellation_message'] = cancellationMessage;
    if (refundCalculation != null) data['refund_calculation'] = refundCalculation!.toJson();
    if (trekDetails != null) data['trek_details'] = trekDetails!.toJson();
    if (batchDetails != null) data['batch_details'] = batchDetails!.toJson();
    return data;
  }
}

class RefundCalculation {
  double? deduction;
  double? refund;
  int? deductionPercent;
  String? policyType;
  String? policyName;
  String? slabInfo;
  double? timeRemainingHours;
  bool? within24Hours;
  bool? freeCancellation;
  double? totalFinalAmount;
  String? message;
  double? trekPrice;
  RefundBreakdown? breakdown;
  List<RefundItem>? refundItems;
  List<RefundItem>? loseItems;

  RefundCalculation({
    this.deduction,
    this.refund,
    this.deductionPercent,
    this.policyType,
    this.policyName,
    this.slabInfo,
    this.timeRemainingHours,
    this.within24Hours,
    this.freeCancellation,
    this.totalFinalAmount,
    this.message,
    this.trekPrice,
    this.breakdown,
    this.refundItems,
    this.loseItems,
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
    policyName = json['policy_name'];
    slabInfo = json['slab_info'];
    timeRemainingHours = json['time_remaining_hours'] != null
        ? double.parse(json['time_remaining_hours'].toString())
        : null;
    within24Hours = json['within_24_hours'];
    freeCancellation = json['free_cancellation'];
    totalFinalAmount = json['total_final_amount'] != null
        ? double.parse(json['total_final_amount'].toString())
        : null;
    message = json['message'];
    trekPrice = json['trek_price'] != null
        ? double.parse(json['trek_price'].toString())
        : null;
    breakdown = json['breakdown'] != null
        ? RefundBreakdown.fromJson(json['breakdown'])
        : null;
    refundItems = json['refund_items'] != null
        ? List<RefundItem>.from(
            (json['refund_items'] as List).map((e) => RefundItem.fromJson(e)))
        : null;
    loseItems = json['lose_items'] != null
        ? List<RefundItem>.from(
            (json['lose_items'] as List).map((e) => RefundItem.fromJson(e)))
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['deduction'] = deduction;
    data['refund'] = refund;
    data['deduction_percent'] = deductionPercent;
    data['policy_type'] = policyType;
    data['policy_name'] = policyName;
    data['slab_info'] = slabInfo;
    data['time_remaining_hours'] = timeRemainingHours;
    data['within_24_hours'] = within24Hours;
    data['free_cancellation'] = freeCancellation;
    data['total_final_amount'] = totalFinalAmount;
    data['message'] = message;
    data['trek_price'] = trekPrice;
    if (breakdown != null) data['breakdown'] = breakdown!.toJson();
    if (refundItems != null) {
      data['refund_items'] = refundItems!.map((e) => e.toJson()).toList();
    }
    if (loseItems != null) {
      data['lose_items'] = loseItems!.map((e) => e.toJson()).toList();
    }
    return data;
  }
}

class RefundBreakdown {
  double? totalPaid;
  double? basePrice;
  double? gstPaid;
  double? platformFee;
  double? deductionAmount;
  double? cancellationGst;
  double? commission;
  double? commissionGst;
  double? vendorFromDeduction;
  double? razorpayFee;
  String? paymentMethod;
  bool? creditNoteEligible;
  bool? isAdvanceOnly;

  RefundBreakdown({
    this.totalPaid,
    this.basePrice,
    this.gstPaid,
    this.platformFee,
    this.deductionAmount,
    this.cancellationGst,
    this.commission,
    this.commissionGst,
    this.vendorFromDeduction,
    this.razorpayFee,
    this.paymentMethod,
    this.creditNoteEligible,
    this.isAdvanceOnly,
  });

  RefundBreakdown.fromJson(Map<String, dynamic> json) {
    totalPaid = json['total_paid'] != null
        ? double.parse(json['total_paid'].toString())
        : null;
    basePrice = json['base_price'] != null
        ? double.parse(json['base_price'].toString())
        : null;
    gstPaid = json['gst_paid'] != null
        ? double.parse(json['gst_paid'].toString())
        : null;
    platformFee = json['platform_fee'] != null
        ? double.parse(json['platform_fee'].toString())
        : null;
    deductionAmount = json['deduction_amount'] != null
        ? double.parse(json['deduction_amount'].toString())
        : null;
    cancellationGst = json['cancellation_gst'] != null
        ? double.parse(json['cancellation_gst'].toString())
        : null;
    commission = json['commission'] != null
        ? double.parse(json['commission'].toString())
        : null;
    commissionGst = json['commission_gst'] != null
        ? double.parse(json['commission_gst'].toString())
        : null;
    vendorFromDeduction = json['vendor_from_deduction'] != null
        ? double.parse(json['vendor_from_deduction'].toString())
        : null;
    razorpayFee = json['razorpay_fee'] != null
        ? double.parse(json['razorpay_fee'].toString())
        : null;
    paymentMethod = json['payment_method'];
    creditNoteEligible = json['credit_note_eligible'];
    isAdvanceOnly = json['is_advance_only'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_paid'] = totalPaid;
    data['base_price'] = basePrice;
    data['gst_paid'] = gstPaid;
    data['platform_fee'] = platformFee;
    data['deduction_amount'] = deductionAmount;
    data['cancellation_gst'] = cancellationGst;
    data['commission'] = commission;
    data['commission_gst'] = commissionGst;
    data['vendor_from_deduction'] = vendorFromDeduction;
    data['razorpay_fee'] = razorpayFee;
    data['payment_method'] = paymentMethod;
    data['credit_note_eligible'] = creditNoteEligible;
    data['is_advance_only'] = isAdvanceOnly;
    return data;
  }
}

class RefundItem {
  String? item;
  double? amount;

  RefundItem({this.item, this.amount});

  RefundItem.fromJson(Map<String, dynamic> json) {
    item = json['item'];
    amount = json['amount'] != null
        ? double.parse(json['amount'].toString())
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['item'] = item;
    data['amount'] = amount;
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
