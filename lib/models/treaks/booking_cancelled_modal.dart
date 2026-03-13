class BookingCancelledModal {
  bool? success;
  String? message;
  BookingCancelledData? data;

  BookingCancelledModal({this.success, this.message, this.data});

  BookingCancelledModal.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? new BookingCancelledData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
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

  BookingCancelledData({
    this.cancellationId,
    this.bookingId,
    this.status,
    this.totalRefundableAmount,
    this.deduction,
    this.deductionAdmin,
    this.deductionVendor,
    this.cancellationDate,
    this.trekDetails,
    this.batchDetails,
  });

  BookingCancelledData.fromJson(Map<String, dynamic> json) {
    cancellationId = json['cancellation_id'];
    bookingId = json['booking_id'];
    status = json['status'];
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
        ? new TrekDetails.fromJson(json['trek_details'])
        : null;
    batchDetails = json['batch_details'] != null
        ? new BatchDetails.fromJson(json['batch_details'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['cancellation_id'] = this.cancellationId;
    data['booking_id'] = this.bookingId;
    data['status'] = this.status;
    data['total_refundable_amount'] = this.totalRefundableAmount;
    data['deduction'] = this.deduction;
    data['deduction_admin'] = this.deductionAdmin;
    data['deduction_vendor'] = this.deductionVendor;
    data['cancellation_date'] = this.cancellationDate;
    if (this.trekDetails != null) {
      data['trek_details'] = this.trekDetails!.toJson();
    }
    if (this.batchDetails != null) {
      data['batch_details'] = this.batchDetails!.toJson();
    }
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
    id = json['id'];
    title = json['title'];
    basePrice = json['base_price'];
    mtrId = json['mtr_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['base_price'] = this.basePrice;
    data['mtr_id'] = this.mtrId;
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['tbr_id'] = this.tbrId;
    data['start_date'] = this.startDate;
    data['end_date'] = this.endDate;
    return data;
  }
}
