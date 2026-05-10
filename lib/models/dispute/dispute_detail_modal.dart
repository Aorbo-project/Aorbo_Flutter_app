class DisputeDetailModal {
  bool? success;
  DisputeDetailData? data;

  DisputeDetailModal({this.success, this.data});

  DisputeDetailModal.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? new DisputeDetailData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class DisputeDetailData {
  int? bookingId;
  int? totalDisputes;
  String? totalDisputedAmount;
  String? overallStatus;
  String? overallPriority;
  String? bookingStatus;
  String? bookingAmount;
  List<Disputes>? disputes;
  LatestDispute? latestDispute;

  DisputeDetailData(
      {this.bookingId,
        this.totalDisputes,
        this.totalDisputedAmount,
        this.overallStatus,
        this.overallPriority,
        this.bookingStatus,
        this.bookingAmount,
        this.disputes,
        this.latestDispute});

  DisputeDetailData.fromJson(Map<String, dynamic> json) {
    bookingId = json['booking_id'] is int
        ? json['booking_id']
        : int.tryParse(json['booking_id']?.toString() ?? '');
    totalDisputes = json['total_disputes'] is int
        ? json['total_disputes']
        : int.tryParse(json['total_disputes']?.toString() ?? '');
    totalDisputedAmount = json['total_disputed_amount']?.toString();
    overallStatus = json['overall_status'];
    overallPriority = json['overall_priority'];
    bookingStatus = json['booking_status'];
    bookingAmount = json['booking_amount']?.toString();
    if (json['disputes'] != null) {
      disputes = <Disputes>[];
      json['disputes'].forEach((v) {
        disputes!.add(new Disputes.fromJson(v));
      });
    }
    latestDispute = json['latest_dispute'] != null
        ? new LatestDispute.fromJson(json['latest_dispute'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['booking_id'] = this.bookingId;
    data['total_disputes'] = this.totalDisputes;
    data['total_disputed_amount'] = this.totalDisputedAmount;
    data['overall_status'] = this.overallStatus;
    data['overall_priority'] = this.overallPriority;
    data['booking_status'] = this.bookingStatus;
    data['booking_amount'] = this.bookingAmount;
    if (this.disputes != null) {
      data['disputes'] = this.disputes!.map((v) => v.toJson()).toList();
    }
    if (this.latestDispute != null) {
      data['latest_dispute'] = this.latestDispute!.toJson();
    }
    return data;
  }
}

class Disputes {
  int? disputeId;
  String? issueType;
  String? issueCategory;
  String? status;
  String? priority;
  String? disputedAmount;
  String? description;
  String? createdAt;
  String? updatedAt;
  String? resolvedAt;

  Disputes(
      {this.disputeId,
        this.issueType,
        this.issueCategory,
        this.status,
        this.priority,
        this.disputedAmount,
        this.description,
        this.createdAt,
        this.updatedAt,
        this.resolvedAt});

  Disputes.fromJson(Map<String, dynamic> json) {
    disputeId = json['dispute_id'] is int
        ? json['dispute_id']
        : int.tryParse(json['dispute_id']?.toString() ?? '');
    issueType = json['issue_type'];
    issueCategory = json['issue_category'];
    status = json['status'];
    priority = json['priority'];
    disputedAmount = json['disputed_amount']?.toString();
    description = json['description'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    resolvedAt = json['resolved_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['dispute_id'] = this.disputeId;
    data['issue_type'] = this.issueType;
    data['issue_category'] = this.issueCategory;
    data['status'] = this.status;
    data['priority'] = this.priority;
    data['disputed_amount'] = this.disputedAmount;
    data['description'] = this.description;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['resolved_at'] = this.resolvedAt;
    return data;
  }
}

class LatestDispute {
  int? disputeId;
  String? issueType;
  String? status;
  String? priority;
  String? createdAt;

  LatestDispute(
      {this.disputeId,
        this.issueType,
        this.status,
        this.priority,
        this.createdAt});

  LatestDispute.fromJson(Map<String, dynamic> json) {
    disputeId = json['dispute_id'] is int
        ? json['dispute_id']
        : int.tryParse(json['dispute_id']?.toString() ?? '');
    issueType = json['issue_type'];
    status = json['status'];
    priority = json['priority'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['dispute_id'] = this.disputeId;
    data['issue_type'] = this.issueType;
    data['status'] = this.status;
    data['priority'] = this.priority;
    data['created_at'] = this.createdAt;
    return data;
  }
}
