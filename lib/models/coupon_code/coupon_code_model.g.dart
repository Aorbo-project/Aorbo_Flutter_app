// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coupon_code_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CouponCodeModelImpl _$$CouponCodeModelImplFromJson(
        Map<String, dynamic> json) =>
    _$CouponCodeModelImpl(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => CouponCardData.fromJson(e as Map<String, dynamic>))
          .toList(),
      count: json['count'] as int?,
      vendorInfo: json['vendor_info'] == null
          ? null
          : VendorInfo.fromJson(json['vendor_info'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$CouponCodeModelImplToJson(
        _$CouponCodeModelImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
      'count': instance.count,
      'vendor_info': instance.vendorInfo,
    };

_$CouponCardDataImpl _$$CouponCardDataImplFromJson(Map<String, dynamic> json) =>
    _$CouponCardDataImpl(
      id: json['id'] as int?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      imagePath: json['image_url'] as String?,
      gradient: (json['gradient'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      textColour: json['textColour'] as String?,
      code: json['code'] as String?,
      discountType: json['discount_type'] as String?,
      discountValue: json['discount_value'] as String?,
      termsAndConditions: (json['terms_and_conditions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      isExpired: json['is_expired'] as bool?,
      isActive: json['is_active'] as bool?,
    );

Map<String, dynamic> _$$CouponCardDataImplToJson(
        _$CouponCardDataImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'image_url': instance.imagePath,
      'gradient': instance.gradient,
      'textColour': instance.textColour,
      'code': instance.code,
      'discount_type': instance.discountType,
      'discount_value': instance.discountValue,
      'terms_and_conditions': instance.termsAndConditions,
      'is_expired': instance.isExpired,
      'is_active': instance.isActive,
    };

_$VendorImpl _$$VendorImplFromJson(Map<String, dynamic> json) => _$VendorImpl(
      id: json['id'] as int?,
      companyInfo: json['company_info'] as String?,
      status: json['status'] as String?,
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$VendorImplToJson(_$VendorImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'company_info': instance.companyInfo,
      'status': instance.status,
      'user': instance.user,
    };

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
      id: json['id'] as int?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
    );

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
    };

_$VendorInfoImpl _$$VendorInfoImplFromJson(Map<String, dynamic> json) =>
    _$VendorInfoImpl(
      vendorId: json['vendor_id'] as String?,
      totalCoupons: json['total_coupons'] as int?,
      activeCoupons: json['active_coupons'] as int?,
      pendingCoupons: json['pending_coupons'] as int?,
      approvedCoupons: json['approved_coupons'] as int?,
      rejectedCoupons: json['rejected_coupons'] as int?,
      expiredCoupons: json['expired_coupons'] as int?,
    );

Map<String, dynamic> _$$VendorInfoImplToJson(_$VendorInfoImpl instance) =>
    <String, dynamic>{
      'vendor_id': instance.vendorId,
      'total_coupons': instance.totalCoupons,
      'active_coupons': instance.activeCoupons,
      'pending_coupons': instance.pendingCoupons,
      'approved_coupons': instance.approvedCoupons,
      'rejected_coupons': instance.rejectedCoupons,
      'expired_coupons': instance.expiredCoupons,
    };
