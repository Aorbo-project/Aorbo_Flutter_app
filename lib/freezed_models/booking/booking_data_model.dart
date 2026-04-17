import 'package:freezed_annotation/freezed_annotation.dart';

part 'booking_data_model.freezed.dart';
part 'booking_data_model.g.dart';

@freezed
class CalculateFareResponseModel with _$CalculateFareResponseModel {
  const factory CalculateFareResponseModel({
    bool? success,
    String? fareToken,
    BreakDownDataModel? data,
    @JsonKey(name: 'coupon_details') dynamic couponDetails,
    @JsonKey(name: 'expires_at') dynamic expiresAt
  }) = _CalculateFareResponseModel;

  factory CalculateFareResponseModel.fromJson(Map<String, dynamic> json) =>
      _$CalculateFareResponseModelFromJson(json);
}

@freezed
class BreakDownDataModel with _$BreakDownDataModel {
  const factory BreakDownDataModel({
    int? id,
    @JsonKey(name: 'base_price') dynamic basePrice,
    @JsonKey(name: 'traveler_count') dynamic travelerCount,
    @JsonKey(name: 'base_total') dynamic baseTotal,
    dynamic discount,
    @JsonKey(name: 'coupon_code') dynamic couponCode,
    @JsonKey(name: 'amount_after_discount') dynamic amountAfterDiscount,
    dynamic taxes,
    @JsonKey(name: 'total_tax') dynamic totalTax,
    dynamic gst,
    @JsonKey(name: 'platform_fee') dynamic platformFee,
    @JsonKey(name: 'insurance_fee') dynamic insuranceFee,
    @JsonKey(name: 'cancellation_fee') dynamic cancellationFee,
    @JsonKey(name: 'final_amount') dynamic finalAmount,
    @JsonKey(name: 'cancellation_policy_type') dynamic cancellationPolicyType,
    @JsonKey(name: 'advance_amount') dynamic advanceAmount,
    @JsonKey(name: 'amount_to_pay_now') dynamic amountToPayNow,
    @JsonKey(name: 'remaining_amount') dynamic remainingAmount,
  }) = _BreakDownDataModel;

  factory BreakDownDataModel.fromJson(Map<String, dynamic> json) =>
      _$BreakDownDataModelFromJson(json);
}