// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CreateRazorpayRequestModelImpl _$$CreateRazorpayRequestModelImplFromJson(
        Map<String, dynamic> json) =>
    _$CreateRazorpayRequestModelImpl(
      fareToken: json['fare_token'] as String,
      travelers: (json['travelers'] as List<dynamic>)
          .map((e) => Traveler.fromJson(e as Map<String, dynamic>))
          .toList(),
      payFull: json['pay_full'] as bool? ?? false,
    );

Map<String, dynamic> _$$CreateRazorpayRequestModelImplToJson(
        _$CreateRazorpayRequestModelImpl instance) =>
    <String, dynamic>{
      'fare_token': instance.fareToken,
      'travelers': instance.travelers,
      'pay_full': instance.payFull,
    };

_$BookingResponseImpl _$$BookingResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$BookingResponseImpl(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      order: json['order'] == null
          ? null
          : Order.fromJson(json['order'] as Map<String, dynamic>),
      keyId: json['key_id'] as String?,
      bookingData: json['bookingData'] == null
          ? null
          : BookingData.fromJson(json['bookingData'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$BookingResponseImplToJson(
        _$BookingResponseImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'order': instance.order,
      'key_id': instance.keyId,
      'bookingData': instance.bookingData,
    };

_$OrderImpl _$$OrderImplFromJson(Map<String, dynamic> json) => _$OrderImpl(
      amount: json['amount'],
      amountDue: json['amount_due'],
      amountPaid: json['amount_paid'],
      attempts: json['attempts'] as int?,
      createdAt: json['created_at'],
      currency: json['currency'] as String?,
      entity: json['entity'] as String?,
      id: json['id'] as String?,
      notes: json['notes'] as List<dynamic>?,
      offerId: json['offer_id'] as String?,
      bookingNumber: json['booking_number'] as String?,
      receipt: json['receipt'] as String?,
      batch: json['batch'] == null
          ? null
          : BatchModel.fromJson(json['batch'] as Map<String, dynamic>),
      status: json['status'] as String?,
    );

Map<String, dynamic> _$$OrderImplToJson(_$OrderImpl instance) =>
    <String, dynamic>{
      'amount': instance.amount,
      'amount_due': instance.amountDue,
      'amount_paid': instance.amountPaid,
      'attempts': instance.attempts,
      'created_at': instance.createdAt,
      'currency': instance.currency,
      'entity': instance.entity,
      'id': instance.id,
      'notes': instance.notes,
      'offer_id': instance.offerId,
      'booking_number': instance.bookingNumber,
      'receipt': instance.receipt,
      'batch': instance.batch,
      'status': instance.status,
    };

_$BatchModelImpl _$$BatchModelImplFromJson(Map<String, dynamic> json) =>
    _$BatchModelImpl(
      id: json['id'] as int?,
      tbrId: json['tbr_id'] as String?,
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
      bookedSlots: json['booked_slots'] as int?,
      availableSlots: json['available_slots'] as int?,
      capacity: json['capacity'] as int?,
    );

Map<String, dynamic> _$$BatchModelImplToJson(_$BatchModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tbr_id': instance.tbrId,
      'start_date': instance.startDate,
      'end_date': instance.endDate,
      'booked_slots': instance.bookedSlots,
      'available_slots': instance.availableSlots,
      'capacity': instance.capacity,
    };

_$BookingDataImpl _$$BookingDataImplFromJson(Map<String, dynamic> json) =>
    _$BookingDataImpl(
      trekId: json['trekId'] as int?,
      customerId: json['customerId'] as int?,
      travelers: (json['travelers'] as List<dynamic>?)
          ?.map((e) => Traveler.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalAmount: json['totalAmount'],
      discountAmount: json['discountAmount'],
      finalAmount: json['finalAmount'],
    );

Map<String, dynamic> _$$BookingDataImplToJson(_$BookingDataImpl instance) =>
    <String, dynamic>{
      'trekId': instance.trekId,
      'customerId': instance.customerId,
      'travelers': instance.travelers,
      'totalAmount': instance.totalAmount,
      'discountAmount': instance.discountAmount,
      'finalAmount': instance.finalAmount,
    };

_$CalculateFareRequestModelImpl _$$CalculateFareRequestModelImplFromJson(
        Map<String, dynamic> json) =>
    _$CalculateFareRequestModelImpl(
      batchId: json['batch_id'] as int?,
      travelerCount: json['traveler_count'] as int,
      couponCode: json['coupon_code'] as String?,
      cancellationPolicyType: json['cancellation_policy_type'] as String?,
      addInsurance: json['add_insurance'] as bool,
      addFreeCancellationProtection:
          json['add_cancellation_protection'] as bool,
    );

Map<String, dynamic> _$$CalculateFareRequestModelImplToJson(
        _$CalculateFareRequestModelImpl instance) =>
    <String, dynamic>{
      'batch_id': instance.batchId,
      'traveler_count': instance.travelerCount,
      'coupon_code': instance.couponCode,
      'cancellation_policy_type': instance.cancellationPolicyType,
      'add_insurance': instance.addInsurance,
      'add_cancellation_protection': instance.addFreeCancellationProtection,
    };

_$CalculateFareResponseModelImpl _$$CalculateFareResponseModelImplFromJson(
        Map<String, dynamic> json) =>
    _$CalculateFareResponseModelImpl(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      fareToken: json['fareToken'] as String?,
      breakdown: json['breakdown'] == null
          ? null
          : BreakDownDataModel.fromJson(
              json['breakdown'] as Map<String, dynamic>),
      couponDetails: json['coupon_details'],
      expiresAt: json['expires_at'],
      allowCancellation: json['allow_cancellation'],
      allowInsurance: json['allow_insurance'],
    );

Map<String, dynamic> _$$CalculateFareResponseModelImplToJson(
        _$CalculateFareResponseModelImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'fareToken': instance.fareToken,
      'breakdown': instance.breakdown,
      'coupon_details': instance.couponDetails,
      'expires_at': instance.expiresAt,
      'allow_cancellation': instance.allowCancellation,
      'allow_insurance': instance.allowInsurance,
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
