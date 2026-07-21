import 'package:freezed_annotation/freezed_annotation.dart';

part 'coupon_code_model.freezed.dart';
part 'coupon_code_model.g.dart';

@freezed
class ValidateCouponCodeRequestModel with _$ValidateCouponCodeRequestModel {
  const factory ValidateCouponCodeRequestModel({
    required String code,
    required dynamic trekId,
    @JsonKey(name: 'amount') required dynamic bookingAmount,
    /// Number of travelers — required for group-discount minimum participant validation.
    @JsonKey(name: 'travelerCount') int? travelerCount,
    /// TBR batch id — the same coupon can be assigned to multiple TBRs, and
    /// "already used" is scoped per TBR, not globally per customer.
    @JsonKey(name: 'batchId') int? batchId,
  }) = _ValidateCouponCodeRequestModel;

  factory ValidateCouponCodeRequestModel.fromJson(Map<String, dynamic> json) =>
      _$ValidateCouponCodeRequestModelFromJson(json);
}

@freezed
class ValidateCouponCodeResponseModel with _$ValidateCouponCodeResponseModel {
  const factory ValidateCouponCodeResponseModel({
    bool? success,
    String? message,
    ValidateCouponCodeDataModel? coupon
  }) = _ValidateCouponCodeResponseModel;

  factory ValidateCouponCodeResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ValidateCouponCodeResponseModelFromJson(json);
}

@freezed
class ValidateCouponCodeDataModel with _$ValidateCouponCodeDataModel {
  const factory ValidateCouponCodeDataModel({
    bool? valid,
    @JsonKey(name: 'coupon_details') CouponCardData? couponDetails
  }) = _ValidateCouponCodeDataModel;

  factory ValidateCouponCodeDataModel.fromJson(Map<String, dynamic> json) =>
      _$ValidateCouponCodeDataModelFromJson(json);
}

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
    String? description,
    @JsonKey(name: 'image_path') String? imagePath,
    List<String>? gradient,
    @JsonKey(name: 'text_colour') String? textColour,
    String? code,
    @JsonKey(name: 'discount_type') String? discountType,
    @JsonKey(name: 'discount_value') String? discountValue,

    @JsonKey(name: 'terms_and_conditions')
    List<String>? termsAndConditions,

    /// Detailed marketing description (e.g. "Trekking is better with friends…")
    @JsonKey(name: 'detailed_description')
    String? detailedDescription,

    /// Plain-text instructions on how to redeem the coupon
    @JsonKey(name: 'how_to_apply')
    String? howToApply,

    /// Footer note shown at the bottom of the T&C modal
    @JsonKey(name: 'footer_note')
    String? footerNote,

    @JsonKey(name: 'is_expired') bool? isExpired,
    @JsonKey(name: 'is_active') bool? isActive,

    /// True once this customer has hit the coupon's per-user usage limit —
    /// drives the "Already used" blocked state, separate from expiry/active.
    @JsonKey(name: 'is_used') bool? isUsed,
    @JsonKey(name: 'valid_from') String? validFrom,
    @JsonKey(name: 'valid_until') String? validUntil,

    /// Coupon scope, e.g. "PLATFORM" — determines global vs vendor/trek-scoped visibility.
    String? scope,

    /// Minimum order value required to apply this coupon.
    @JsonKey(name: 'min_amount') String? minAmount,

    /// Cap on the discount amount for percentage-based coupon types.
    @JsonKey(name: 'max_discount_amount') String? maxDiscountAmount,

    /// Category tag (e.g. "Seasonal", "New trekker") shown above the headline.
    CouponStyling? styling,

  }) = _CouponCardData;

  factory CouponCardData.fromJson(Map<String, dynamic> json) =>
      _$CouponCardDataFromJson(json);
}

@freezed
class CouponStyling with _$CouponStyling {
  const factory CouponStyling({
    String? badge,
    String? icon,
  }) = _CouponStyling;

  factory CouponStyling.fromJson(Map<String, dynamic> json) =>
      _$CouponStylingFromJson(json);
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