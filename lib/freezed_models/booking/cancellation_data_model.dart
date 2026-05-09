
import 'package:freezed_annotation/freezed_annotation.dart';

part 'cancellation_data_model.freezed.dart';
part 'cancellation_data_model.g.dart';

@freezed
class RequestCancellationResponseModel with _$RequestCancellationResponseModel {
  const factory RequestCancellationResponseModel({
    bool? success,
    String? message,
  }) = _RequestCancellationResponseModel;

  factory RequestCancellationResponseModel.fromJson(Map<String, dynamic> json) =>
      _$RequestCancellationResponseModelFromJson(json);
}

@freezed
class CancellationDetailsResponseModel with _$CancellationDetailsResponseModel {
  const factory CancellationDetailsResponseModel({
    bool? success,
    String? message,
    CancellationDataModel? data,
  }) = _CancellationDetailsResponseModel;

  factory CancellationDetailsResponseModel.fromJson(Map<String, dynamic> json) =>
      _$CancellationDetailsResponseModelFromJson(json);
}

@freezed
class CancellationDataModel with _$CancellationDataModel {
  const factory CancellationDataModel({
    @JsonKey(name: 'booking_id') int? bookingId,
    @JsonKey(name: 'trek_id') int? trekId,
    @JsonKey(name: 'batch_id') int? batchId,
    @JsonKey(name: 'customer_id') int? customerId,
    @JsonKey(name: 'customer_name') String? customerName,
    @JsonKey(name: 'final_amount') double? finalAmount,
    @JsonKey(name: 'advance_amount') int? advanceAmount,
    @JsonKey(name: 'cancellation_policy_id') int? cancellationPolicyId,
    @JsonKey(name: 'cancellation_policy_name') String? cancellationPolicyName,
    @JsonKey(name: 'cancellation_policy_type') String? cancellationPolicyType,
    @JsonKey(name: 'current_date') DateTime? currentDate,
    @JsonKey(name: 'boarding_date_time') DateTime? boardingDateTime,
    @JsonKey(name: 'time_remaining_hours') double? timeRemainingHours,
    @JsonKey(name: 'can_cancel') bool? canCancel,
    @JsonKey(name: 'cancellation_message') dynamic cancellationMessage,
    @JsonKey(name: 'refund_calculation') RefundCalculation? refundCalculation,
    @JsonKey(name: 'trek_details') TrekDetails? trekDetails,
    @JsonKey(name: 'batch_details') BatchDetails? batchDetails,
  }) = _CancellationDataModel;

  factory CancellationDataModel.fromJson(Map<String, dynamic> json) =>
      _$CancellationDataModelFromJson(json);
}

@freezed
class RefundCalculation with _$RefundCalculation {
  const factory RefundCalculation({
    double? refund,
    double? deduction,
    @JsonKey(name: 'policy_type') String? policyType,
    @JsonKey(name: 'policy_name') String? policyName,
    @JsonKey(name: 'time_remaining_hours') double? timeRemainingHours,
    @JsonKey(name: 'within_24_hours') bool? within24Hours,
    @JsonKey(name: 'free_cancellation') bool? freeCancellation,
    @JsonKey(name: 'refund_items') List<RefundItem>? refundItems,
    @JsonKey(name: 'lose_items') List<LoseItem>? loseItems,
    @JsonKey(name: 'total_final_amount') double? totalFinalAmount,
  }) = _RefundCalculation;

  factory RefundCalculation.fromJson(Map<String, dynamic> json) =>
      _$RefundCalculationFromJson(json);
}

@freezed
class RefundItem with _$RefundItem {
  const factory RefundItem({
    String? item,
    double? amount,
  }) = _RefundItem;

  factory RefundItem.fromJson(Map<String, dynamic> json) =>
      _$RefundItemFromJson(json);
}

@freezed
class LoseItem with _$LoseItem {
  const factory LoseItem({
    String? item,
    double? amount,
  }) = _LoseItem;

  factory LoseItem.fromJson(Map<String, dynamic> json) =>
      _$LoseItemFromJson(json);
}

@freezed
class TrekDetails with _$TrekDetails {
  const factory TrekDetails({
    int? id,
    String? title,
    @JsonKey(name: 'base_price') String? basePrice,
  }) = _TrekDetails;

  factory TrekDetails.fromJson(Map<String, dynamic> json) =>
      _$TrekDetailsFromJson(json);
}

@freezed
class BatchDetails with _$BatchDetails {
  const factory BatchDetails({
    int? id,
    @JsonKey(name: 'tbr_id') String? tbrId,
    @JsonKey(name: 'start_date') String? startDate,
    @JsonKey(name: 'end_date') String? endDate,
  }) = _BatchDetails;

  factory BatchDetails.fromJson(Map<String, dynamic> json) =>
      _$BatchDetailsFromJson(json);
}