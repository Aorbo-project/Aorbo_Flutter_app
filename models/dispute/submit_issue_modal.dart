class SubmitIssueModal {
  bool? success;
  String? message;
  SubmitIssueData? data;

  SubmitIssueModal({this.success, this.message, this.data});

  SubmitIssueModal.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null
        ? SubmitIssueData.fromJson(json['data'])
        : null;
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

class SubmitIssueData {
  int? issueId;
  int? bookingId;
  String? issueType;
  String? issueCategory;
  String? status;
  String? priority;
  int? sla;
  double? disputedAmount;
  String? createdAt;
  BookingInfo? bookingInfo;

  SubmitIssueData({
    this.issueId,
    this.bookingId,
    this.issueType,
    this.issueCategory,
    this.status,
    this.priority,
    this.sla,
    this.disputedAmount,
    this.createdAt,
    this.bookingInfo,
  });

  SubmitIssueData.fromJson(Map<String, dynamic> json) {
    issueId = json['issue_id'] is int
        ? json['issue_id']
        : int.tryParse(json['issue_id']?.toString() ?? '');
    bookingId = json['booking_id'] is int
        ? json['booking_id']
        : int.tryParse(json['booking_id']?.toString() ?? '');
    issueType = json['issue_type'];
    issueCategory = json['issue_category'];
    status = json['status'];
    priority = json['priority'];
    sla = json['sla'] is int
        ? json['sla']
        : int.tryParse(json['sla']?.toString() ?? '');
    disputedAmount = json['disputed_amount'] != null
        ? double.tryParse(json['disputed_amount'].toString())
        : null;
    createdAt = json['created_at'];
    bookingInfo = json['booking_info'] != null
        ? BookingInfo.fromJson(json['booking_info'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['issue_id'] = issueId;
    data['booking_id'] = bookingId;
    data['issue_type'] = issueType;
    data['issue_category'] = issueCategory;
    data['status'] = status;
    data['priority'] = priority;
    data['sla'] = sla;
    data['disputed_amount'] = disputedAmount;
    data['created_at'] = createdAt;
    if (bookingInfo != null) {
      data['booking_info'] = bookingInfo!.toJson();
    }
    return data;
  }
}

class BookingInfo {
  String? trekName;
  String? vendorName;
  String? bookingDate;
  double? bookingAmount;

  BookingInfo({
    this.trekName,
    this.vendorName,
    this.bookingDate,
    this.bookingAmount,
  });

  BookingInfo.fromJson(Map<String, dynamic> json) {
    trekName = json['trek_name'];
    vendorName = json['vendor_name'];
    bookingDate = json['booking_date'];
    bookingAmount = json['booking_amount'] != null
        ? double.tryParse(json['booking_amount'].toString())
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['trek_name'] = trekName;
    data['vendor_name'] = vendorName;
    data['booking_date'] = bookingDate;
    data['booking_amount'] = bookingAmount;
    return data;
  }
}
