class VerifyOtpModal {
  bool? success;
  String? message;
  Data? data;

  VerifyOtpModal({
    this.success,
    this.message,
    this.data,
  });

  VerifyOtpModal.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
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

class Data {
  String? token;
  // null when the backend predates refresh-token support
  String? refreshToken;
  Customer? customer;
  // null when no referral code was sent / the backend predates this
  ReferralResult? referral;
  String? expiresIn;

  Data({
    this.token,
    this.refreshToken,
    this.customer,
    this.referral,
    this.expiresIn,
  });

  Data.fromJson(Map<String, dynamic> json) {
    token = json['token'];
    refreshToken = json['refreshToken'] ?? json['refresh_token'];
    customer =
        json['customer'] != null ? Customer.fromJson(json['customer']) : null;
    referral = json['referral'] != null
        ? ReferralResult.fromJson(Map<String, dynamic>.from(json['referral']))
        : null;
    expiresIn = json['expiresIn'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['token'] = token;
    data['refreshToken'] = refreshToken;
    if (customer != null) {
      data['customer'] = customer!.toJson();
    }
    if (referral != null) {
      data['referral'] = referral!.toJson();
    }
    data['expiresIn'] = expiresIn;
    return data;
  }
}

/// Outcome of redeeming a friend's referral code during verify-otp.
class ReferralResult {
  final bool applied;
  final String message;
  final String? couponCode;
  final num? value;
  final bool isPercent;
  final String? expiresAt;

  ReferralResult({
    required this.applied,
    required this.message,
    this.couponCode,
    this.value,
    this.isPercent = false,
    this.expiresAt,
  });

  factory ReferralResult.fromJson(Map<String, dynamic> json) => ReferralResult(
        applied: json['applied'] == true,
        message: (json['message'] ?? '').toString(),
        couponCode: json['couponCode']?.toString(),
        value: json['value'] is num ? json['value'] as num : null,
        isPercent: json['isPercent'] == true,
        expiresAt: json['expiresAt']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'applied': applied,
        'message': message,
        'couponCode': couponCode,
        'value': value,
        'isPercent': isPercent,
        'expiresAt': expiresAt,
      };
}

class Customer {
  int? id;
  String? name;
  String? phone;
  String? email;
  bool? profileCompleted;
  bool? isNewCustomer;

  Customer({
    this.id,
    this.name,
    this.phone,
    this.email,
    this.profileCompleted,
    this.isNewCustomer,
  });

  Customer.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    phone = json['phone'];
    email = json['email'];
    profileCompleted = json['profileCompleted'];
    isNewCustomer = json['isNewCustomer'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['phone'] = phone;
    data['email'] = email;
    data['profileCompleted'] = profileCompleted;
    data['isNewCustomer'] = isNewCustomer;
    return data;
  }
}
