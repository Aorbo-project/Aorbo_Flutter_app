import 'package:freezed_annotation/freezed_annotation.dart';

part 'coupon_code_model.freezed.dart';
part 'coupon_code_model.g.dart';

@freezed
class CouponCodeModel with _$CouponCodeModel {
  const factory CouponCodeModel({
    bool? success,
    String? message,
    List<CouponCardData>? data,
    int? count,
    @JsonKey(name: 'vendor_info') VendorInfo? vendorInfo,
  }) = _CouponCodeModel;

  factory CouponCodeModel.fromJson(Map<String, dynamic> json) =>
      _$CouponCodeModelFromJson(json);
}


@freezed
class CouponCardData with _$CouponCardData {
  const factory CouponCardData({
    int? id,
    String? title,
    @JsonKey(name: 'image_url') String? imagePath,
    String? code,
    String? description,
    String? color,

    @JsonKey(name: 'discount_type') String? discountType,
    @JsonKey(name: 'discount_value') String? discountValue,
    @JsonKey(name: 'min_amount') String? minAmount,
    @JsonKey(name: 'max_discount_amount') String? maxDiscountAmount,
    @JsonKey(name: 'max_uses') String? maxUses,
    @JsonKey(name: 'current_uses') int? currentUses,
    @JsonKey(name: 'valid_from') String? validFrom,
    @JsonKey(name: 'valid_until') String? validUntil,

    String? status,
    @JsonKey(name: 'approval_status') String? approvalStatus,
    @JsonKey(name: 'admin_notes') String? adminNotes,

    @JsonKey(name: 'terms_and_conditions')
    List<String>? termsAndConditions,

    @JsonKey(name: 'vendor_id') int? vendorId,
    Vendor? vendor,

    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,

    @JsonKey(name: 'is_expired') bool? isExpired,
    @JsonKey(name: 'is_active') bool? isActive,
    @JsonKey(name: 'usage_percentage') int? usagePercentage,
    @JsonKey(name: 'remaining_uses') String? remainingUses,
  }) = _CouponCardData;

  factory CouponCardData.fromJson(Map<String, dynamic> json) =>
      _$CouponCardDataFromJson(json);
}


@freezed
class Vendor with _$Vendor {
  const factory Vendor({
    int? id,
    @JsonKey(name: 'company_info') String? companyInfo,
    String? status,
    User? user,
  }) = _Vendor;

  factory Vendor.fromJson(Map<String, dynamic> json) =>
      _$VendorFromJson(json);
}


@freezed
class User with _$User {
  const factory User({
    int? id,
    String? name,
    String? email,
    String? phone,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) =>
      _$UserFromJson(json);
}


@freezed
class VendorInfo with _$VendorInfo {
  const factory VendorInfo({
    @JsonKey(name: 'vendor_id') String? vendorId,
    @JsonKey(name: 'total_coupons') int? totalCoupons,
    @JsonKey(name: 'active_coupons') int? activeCoupons,
    @JsonKey(name: 'pending_coupons') int? pendingCoupons,
    @JsonKey(name: 'approved_coupons') int? approvedCoupons,
    @JsonKey(name: 'rejected_coupons') int? rejectedCoupons,
    @JsonKey(name: 'expired_coupons') int? expiredCoupons,
  }) = _VendorInfo;

  factory VendorInfo.fromJson(Map<String, dynamic> json) =>
      _$VendorInfoFromJson(json);
}