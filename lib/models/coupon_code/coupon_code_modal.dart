class CouponCodeModal {
  bool? success;
  List<CouponCardData>? data;
  int? count;
  VendorInfo? vendorInfo;

  CouponCodeModal({this.success, this.data, this.count, this.vendorInfo});

  CouponCodeModal.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <CouponCardData>[];
      json['data'].forEach((v) {
        data!.add(new CouponCardData.fromJson(v));
      });
    }
    count = json['count'];
    vendorInfo = json['vendor_info'] != null
        ? new VendorInfo.fromJson(json['vendor_info'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['count'] = this.count;
    if (this.vendorInfo != null) {
      data['vendor_info'] = this.vendorInfo!.toJson();
    }
    return data;
  }
}

class CouponCardData {
  int? id;
  String? title;
  String? code;
  String? description;
  String? color;
  String? discountType;
  String? discountValue;
  String? minAmount;
  String? maxDiscountAmount;
  String? maxUses;
  int? currentUses;
  String? validFrom;
  String? validUntil;
  String? status;
  String? approvalStatus;
  String? adminNotes;
  List<String>? termsAndConditions;
  int? vendorId;
  Vendor? vendor;
  String? createdAt;
  String? updatedAt;
  bool? isExpired;
  bool? isActive;
  int? usagePercentage;
  String? remainingUses;

  CouponCardData({
    this.id,
    this.title,
    this.code,
    this.description,
    this.color,
    this.discountType,
    this.discountValue,
    this.minAmount,
    this.maxDiscountAmount,
    this.maxUses,
    this.currentUses,
    this.validFrom,
    this.validUntil,
    this.status,
    this.approvalStatus,
    this.adminNotes,
    this.termsAndConditions,
    this.vendorId,
    this.vendor,
    this.createdAt,
    this.updatedAt,
    this.isExpired,
    this.isActive,
    this.usagePercentage,
    this.remainingUses,
  });

  CouponCardData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    code = json['code'];
    description = json['description'];
    color = json['color'];
    discountType = json['discount_type'];
    discountValue = json['discount_value'];
    minAmount = json['min_amount'];
    maxDiscountAmount = json['max_discount_amount'];
    maxUses = json['max_uses'];
    currentUses = json['current_uses'];
    validFrom = json['valid_from'];
    validUntil = json['valid_until'];
    status = json['status'];
    approvalStatus = json['approval_status'];
    adminNotes = json['admin_notes'];
    termsAndConditions = json['terms_and_conditions'].cast<String>();
    vendorId = json['vendor_id'];
    vendor = json['vendor'] != null
        ? new Vendor.fromJson(json['vendor'])
        : null;
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    isExpired = json['is_expired'];
    isActive = json['is_active'];
    usagePercentage = json['usage_percentage'];
    remainingUses = json['remaining_uses'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['code'] = this.code;
    data['description'] = this.description;
    data['color'] = this.color;
    data['discount_type'] = this.discountType;
    data['discount_value'] = this.discountValue;
    data['min_amount'] = this.minAmount;
    data['max_discount_amount'] = this.maxDiscountAmount;
    data['max_uses'] = this.maxUses;
    data['current_uses'] = this.currentUses;
    data['valid_from'] = this.validFrom;
    data['valid_until'] = this.validUntil;
    data['status'] = this.status;
    data['approval_status'] = this.approvalStatus;
    data['admin_notes'] = this.adminNotes;
    data['terms_and_conditions'] = this.termsAndConditions;
    data['vendor_id'] = this.vendorId;
    if (this.vendor != null) {
      data['vendor'] = this.vendor!.toJson();
    }
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['is_expired'] = this.isExpired;
    data['is_active'] = this.isActive;
    data['usage_percentage'] = this.usagePercentage;
    data['remaining_uses'] = this.remainingUses;
    return data;
  }
}

class Vendor {
  int? id;
  String? companyInfo;
  String? status;
  User? user;

  Vendor({this.id, this.companyInfo, this.status, this.user});

  Vendor.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    companyInfo = json['company_info'];
    status = json['status'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['company_info'] = this.companyInfo;
    data['status'] = this.status;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    return data;
  }
}

class User {
  int? id;
  String? name;
  String? email;
  String? phone;

  User({this.id, this.name, this.email, this.phone});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    data['phone'] = this.phone;
    return data;
  }
}

class VendorInfo {
  String? vendorId;
  int? totalCoupons;
  int? activeCoupons;
  int? pendingCoupons;
  int? approvedCoupons;
  int? rejectedCoupons;
  int? expiredCoupons;

  VendorInfo({
    this.vendorId,
    this.totalCoupons,
    this.activeCoupons,
    this.pendingCoupons,
    this.approvedCoupons,
    this.rejectedCoupons,
    this.expiredCoupons,
  });

  VendorInfo.fromJson(Map<String, dynamic> json) {
    vendorId = json['vendor_id'];
    totalCoupons = json['total_coupons'];
    activeCoupons = json['active_coupons'];
    pendingCoupons = json['pending_coupons'];
    approvedCoupons = json['approved_coupons'];
    rejectedCoupons = json['rejected_coupons'];
    expiredCoupons = json['expired_coupons'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['vendor_id'] = this.vendorId;
    data['total_coupons'] = this.totalCoupons;
    data['active_coupons'] = this.activeCoupons;
    data['pending_coupons'] = this.pendingCoupons;
    data['approved_coupons'] = this.approvedCoupons;
    data['rejected_coupons'] = this.rejectedCoupons;
    data['expired_coupons'] = this.expiredCoupons;
    return data;
  }
}
