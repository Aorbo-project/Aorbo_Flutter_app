// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CalculateFareResponseModelImpl _$$CalculateFareResponseModelImplFromJson(
        Map<String, dynamic> json) =>
    _$CalculateFareResponseModelImpl(
      success: json['success'] as bool?,
      fareToken: json['fareToken'] as String?,
      data: json['data'] == null
          ? null
          : BreakDownDataModel.fromJson(json['data'] as Map<String, dynamic>),
      couponDetails: json['coupon_details'],
      expiresAt: json['expires_at'],
    );

Map<String, dynamic> _$$CalculateFareResponseModelImplToJson(
        _$CalculateFareResponseModelImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'fareToken': instance.fareToken,
      'data': instance.data,
      'coupon_details': instance.couponDetails,
      'expires_at': instance.expiresAt,
    };

_$BreakDownDataModelImpl _$$BreakDownDataModelImplFromJson(
        Map<String, dynamic> json) =>
    _$BreakDownDataModelImpl(
      id: json['id'] as int?,
      basePrice: json['base_price'],
      travelerCount: json['traveler_count'],
      baseTotal: json['base_total'],
      discount: json['discount'],
      couponCode: json['coupon_code'],
      amountAfterDiscount: json['amount_after_discount'],
      taxes: json['taxes'],
      totalTax: json['total_tax'],
      gst: json['gst'],
      platformFee: json['platform_fee'],
      insuranceFee: json['insurance_fee'],
      cancellationFee: json['cancellation_fee'],
      finalAmount: json['final_amount'],
      cancellationPolicyType: json['cancellation_policy_type'],
      advanceAmount: json['advance_amount'],
      amountToPayNow: json['amount_to_pay_now'],
      remainingAmount: json['remaining_amount'],
    );

Map<String, dynamic> _$$BreakDownDataModelImplToJson(
        _$BreakDownDataModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'base_price': instance.basePrice,
      'traveler_count': instance.travelerCount,
      'base_total': instance.baseTotal,
      'discount': instance.discount,
      'coupon_code': instance.couponCode,
      'amount_after_discount': instance.amountAfterDiscount,
      'taxes': instance.taxes,
      'total_tax': instance.totalTax,
      'gst': instance.gst,
      'platform_fee': instance.platformFee,
      'insurance_fee': instance.insuranceFee,
      'cancellation_fee': instance.cancellationFee,
      'final_amount': instance.finalAmount,
      'cancellation_policy_type': instance.cancellationPolicyType,
      'advance_amount': instance.advanceAmount,
      'amount_to_pay_now': instance.amountToPayNow,
      'remaining_amount': instance.remainingAmount,
    };
