import 'package:freezed_annotation/freezed_annotation.dart';

import '../profile/user_profile_model.dart';

part 'booking_data_model.freezed.dart';
part 'booking_data_model.g.dart';

@freezed
class CreateRazorpayRequestModel with _$CreateRazorpayRequestModel {
  const factory CreateRazorpayRequestModel({
    @JsonKey(name: 'fare_token') required String fareToken,
    required List<Traveler> travelers
  }) = _CreateRazorpayRequestModel;

  factory CreateRazorpayRequestModel.fromJson(Map<String, dynamic> json) =>
      _$CreateRazorpayRequestModelFromJson(json);
}

@freezed
class BookingResponse with _$BookingResponse {
  const factory BookingResponse({
    bool? success,
    String? message,
    Order? order,
    @JsonKey(name: 'key_id') String? keyId,
    BookingData? bookingData,
  }) = _BookingResponse;

  factory BookingResponse.fromJson(Map<String, dynamic> json) =>
      _$BookingResponseFromJson(json);
}

@freezed
class Order with _$Order {
  const factory Order({
    dynamic amount,
    @JsonKey(name: 'amount_due')  dynamic amountDue,
    @JsonKey(name: 'amount_paid') dynamic amountPaid,
    int? attempts,
    @JsonKey(name: 'created_at')  dynamic createdAt,
    String? currency,
    String? entity,
    String? id,
    List<dynamic>? notes,
    @JsonKey(name: 'offer_id') String? offerId,
    @JsonKey(name: 'booking_number') String? bookingNumber,
    String? receipt,
    BatchModel? batch,
    String? status,
  }) = _Order;

  factory Order.fromJson(Map<String, dynamic> json) =>
      _$OrderFromJson(json);
}

@freezed
class BatchModel with _$BatchModel {
  const factory BatchModel({
    int? id,
    @JsonKey(name: 'tbr_id') String? tbrId,
    @JsonKey(name: 'start_date') String? startDate,
    @JsonKey(name: 'end_date') String? endDate,
    @JsonKey(name: 'booked_slots') int? bookedSlots,
    @JsonKey(name: 'available_slots') int? availableSlots,
    @JsonKey(name: 'capacity') int? capacity,
  }) = _BatchModel;

  factory BatchModel.fromJson(Map<String, dynamic> json) =>
      _$BatchModelFromJson(json);
}

@freezed
class BookingData with _$BookingData {
  const factory BookingData({
    int? trekId,
    int? customerId,
    List<Traveler>? travelers,
    dynamic totalAmount,
    dynamic discountAmount,
    dynamic finalAmount,
  }) = _BookingData;

  factory BookingData.fromJson(Map<String, dynamic> json) =>
      _$BookingDataFromJson(json);
}






@freezed
class CalculateFareRequestModel with _$CalculateFareRequestModel {
  const factory CalculateFareRequestModel({
    @JsonKey(name: 'batch_id') required int? batchId,
    @JsonKey(name: 'traveler_count') required int travelerCount,
    @JsonKey(name : 'coupon_code') required String? couponCode,
    @JsonKey(name: 'cancellation_policy_type') String? cancellationPolicyType,
    @JsonKey(name: 'add_insurance') required bool addInsurance,
    @JsonKey(name: 'add_cancellation_protection') required bool addFreeCancellationProtection
  }) = _CalculateFareRequestModel;

  factory CalculateFareRequestModel.fromJson(Map<String, dynamic> json) =>
      _$CalculateFareRequestModelFromJson(json);
}

@freezed
class CalculateFareResponseModel with _$CalculateFareResponseModel {
  const factory CalculateFareResponseModel({
    bool? success,
    String? message,
    String? fareToken,
    BreakDownDataModel? breakdown,
    @JsonKey(name: 'coupon_details') dynamic couponDetails,
    @JsonKey(name: 'expires_at') dynamic expiresAt,
    @JsonKey(name: 'allow_cancellation') dynamic allowCancellation,
    @JsonKey(name: 'allow_insurance') dynamic allowInsurance
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