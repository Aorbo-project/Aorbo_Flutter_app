// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cancellation_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RequestCancellationResponseModelImpl
    _$$RequestCancellationResponseModelImplFromJson(
            Map<String, dynamic> json) =>
        _$RequestCancellationResponseModelImpl(
          success: json['success'] as bool?,
          message: json['message'] as String?,
        );

Map<String, dynamic> _$$RequestCancellationResponseModelImplToJson(
        _$RequestCancellationResponseModelImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
    };

_$CancellationDetailsResponseModelImpl
    _$$CancellationDetailsResponseModelImplFromJson(
            Map<String, dynamic> json) =>
        _$CancellationDetailsResponseModelImpl(
          success: json['success'] as bool?,
          message: json['message'] as String?,
          data: json['data'] == null
              ? null
              : CancellationDataModel.fromJson(
                  json['data'] as Map<String, dynamic>),
        );

Map<String, dynamic> _$$CancellationDetailsResponseModelImplToJson(
        _$CancellationDetailsResponseModelImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

_$CancellationDataModelImpl _$$CancellationDataModelImplFromJson(
        Map<String, dynamic> json) =>
    _$CancellationDataModelImpl(
      bookingId: json['booking_id'] as int?,
      trekId: json['trek_id'] as int?,
      batchId: json['batch_id'] as int?,
      customerId: json['customer_id'] as int?,
      customerName: json['customer_name'] as String?,
      finalAmount: (json['final_amount'] as num?)?.toDouble(),
      advanceAmount: json['advance_amount'] as int?,
      cancellationPolicyId: json['cancellation_policy_id'] as int?,
      cancellationPolicyName: json['cancellation_policy_name'] as String?,
      cancellationPolicyType: json['cancellation_policy_type'] as String?,
      currentDate: json['current_date'] == null
          ? null
          : DateTime.parse(json['current_date'] as String),
      boardingDateTime: json['boarding_date_time'] == null
          ? null
          : DateTime.parse(json['boarding_date_time'] as String),
      timeRemainingHours: (json['time_remaining_hours'] as num?)?.toDouble(),
      canCancel: json['can_cancel'] as bool?,
      cancellationMessage: json['cancellation_message'],
      refundCalculation: json['refund_calculation'] == null
          ? null
          : RefundCalculation.fromJson(
              json['refund_calculation'] as Map<String, dynamic>),
      trekDetails: json['trek_details'] == null
          ? null
          : TrekDetails.fromJson(json['trek_details'] as Map<String, dynamic>),
      batchDetails: json['batch_details'] == null
          ? null
          : BatchDetails.fromJson(
              json['batch_details'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$CancellationDataModelImplToJson(
        _$CancellationDataModelImpl instance) =>
    <String, dynamic>{
      'booking_id': instance.bookingId,
      'trek_id': instance.trekId,
      'batch_id': instance.batchId,
      'customer_id': instance.customerId,
      'customer_name': instance.customerName,
      'final_amount': instance.finalAmount,
      'advance_amount': instance.advanceAmount,
      'cancellation_policy_id': instance.cancellationPolicyId,
      'cancellation_policy_name': instance.cancellationPolicyName,
      'cancellation_policy_type': instance.cancellationPolicyType,
      'current_date': instance.currentDate?.toIso8601String(),
      'boarding_date_time': instance.boardingDateTime?.toIso8601String(),
      'time_remaining_hours': instance.timeRemainingHours,
      'can_cancel': instance.canCancel,
      'cancellation_message': instance.cancellationMessage,
      'refund_calculation': instance.refundCalculation,
      'trek_details': instance.trekDetails,
      'batch_details': instance.batchDetails,
    };

_$RefundCalculationImpl _$$RefundCalculationImplFromJson(
        Map<String, dynamic> json) =>
    _$RefundCalculationImpl(
      refund: (json['refund'] as num?)?.toDouble(),
      deduction: (json['deduction'] as num?)?.toDouble(),
      policyType: json['policy_type'] as String?,
      policyName: json['policy_name'] as String?,
      timeRemainingHours: (json['time_remaining_hours'] as num?)?.toDouble(),
      within24Hours: json['within_24_hours'] as bool?,
      freeCancellation: json['free_cancellation'] as bool?,
      refundItems: (json['refund_items'] as List<dynamic>?)
          ?.map((e) => RefundItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      loseItems: (json['lose_items'] as List<dynamic>?)
          ?.map((e) => LoseItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalFinalAmount: (json['total_final_amount'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$RefundCalculationImplToJson(
        _$RefundCalculationImpl instance) =>
    <String, dynamic>{
      'refund': instance.refund,
      'deduction': instance.deduction,
      'policy_type': instance.policyType,
      'policy_name': instance.policyName,
      'time_remaining_hours': instance.timeRemainingHours,
      'within_24_hours': instance.within24Hours,
      'free_cancellation': instance.freeCancellation,
      'refund_items': instance.refundItems,
      'lose_items': instance.loseItems,
      'total_final_amount': instance.totalFinalAmount,
    };

_$RefundItemImpl _$$RefundItemImplFromJson(Map<String, dynamic> json) =>
    _$RefundItemImpl(
      item: json['item'] as String?,
      amount: (json['amount'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$RefundItemImplToJson(_$RefundItemImpl instance) =>
    <String, dynamic>{
      'item': instance.item,
      'amount': instance.amount,
    };

_$LoseItemImpl _$$LoseItemImplFromJson(Map<String, dynamic> json) =>
    _$LoseItemImpl(
      item: json['item'] as String?,
      amount: (json['amount'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$LoseItemImplToJson(_$LoseItemImpl instance) =>
    <String, dynamic>{
      'item': instance.item,
      'amount': instance.amount,
    };

_$TrekDetailsImpl _$$TrekDetailsImplFromJson(Map<String, dynamic> json) =>
    _$TrekDetailsImpl(
      id: json['id'] as int?,
      title: json['title'] as String?,
      basePrice: json['base_price'] as String?,
    );

Map<String, dynamic> _$$TrekDetailsImplToJson(_$TrekDetailsImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'base_price': instance.basePrice,
    };

_$BatchDetailsImpl _$$BatchDetailsImplFromJson(Map<String, dynamic> json) =>
    _$BatchDetailsImpl(
      id: json['id'] as int?,
      tbrId: json['tbr_id'] as String?,
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
    );

Map<String, dynamic> _$$BatchDetailsImplToJson(_$BatchDetailsImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tbr_id': instance.tbrId,
      'start_date': instance.startDate,
      'end_date': instance.endDate,
    };
