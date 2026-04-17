// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'booking_data_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

CalculateFareResponseModel _$CalculateFareResponseModelFromJson(
    Map<String, dynamic> json) {
  return _CalculateFareResponseModel.fromJson(json);
}

/// @nodoc
mixin _$CalculateFareResponseModel {
  bool? get success => throw _privateConstructorUsedError;
  String? get fareToken => throw _privateConstructorUsedError;
  BreakDownDataModel? get data => throw _privateConstructorUsedError;
  @JsonKey(name: 'coupon_details')
  dynamic get couponDetails => throw _privateConstructorUsedError;
  @JsonKey(name: 'expires_at')
  dynamic get expiresAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CalculateFareResponseModelCopyWith<CalculateFareResponseModel>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CalculateFareResponseModelCopyWith<$Res> {
  factory $CalculateFareResponseModelCopyWith(CalculateFareResponseModel value,
          $Res Function(CalculateFareResponseModel) then) =
      _$CalculateFareResponseModelCopyWithImpl<$Res,
          CalculateFareResponseModel>;
  @useResult
  $Res call(
      {bool? success,
      String? fareToken,
      BreakDownDataModel? data,
      @JsonKey(name: 'coupon_details') dynamic couponDetails,
      @JsonKey(name: 'expires_at') dynamic expiresAt});

  $BreakDownDataModelCopyWith<$Res>? get data;
}

/// @nodoc
class _$CalculateFareResponseModelCopyWithImpl<$Res,
        $Val extends CalculateFareResponseModel>
    implements $CalculateFareResponseModelCopyWith<$Res> {
  _$CalculateFareResponseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = freezed,
    Object? fareToken = freezed,
    Object? data = freezed,
    Object? couponDetails = freezed,
    Object? expiresAt = freezed,
  }) {
    return _then(_value.copyWith(
      success: freezed == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool?,
      fareToken: freezed == fareToken
          ? _value.fareToken
          : fareToken // ignore: cast_nullable_to_non_nullable
              as String?,
      data: freezed == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as BreakDownDataModel?,
      couponDetails: freezed == couponDetails
          ? _value.couponDetails
          : couponDetails // ignore: cast_nullable_to_non_nullable
              as dynamic,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $BreakDownDataModelCopyWith<$Res>? get data {
    if (_value.data == null) {
      return null;
    }

    return $BreakDownDataModelCopyWith<$Res>(_value.data!, (value) {
      return _then(_value.copyWith(data: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CalculateFareResponseModelImplCopyWith<$Res>
    implements $CalculateFareResponseModelCopyWith<$Res> {
  factory _$$CalculateFareResponseModelImplCopyWith(
          _$CalculateFareResponseModelImpl value,
          $Res Function(_$CalculateFareResponseModelImpl) then) =
      __$$CalculateFareResponseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool? success,
      String? fareToken,
      BreakDownDataModel? data,
      @JsonKey(name: 'coupon_details') dynamic couponDetails,
      @JsonKey(name: 'expires_at') dynamic expiresAt});

  @override
  $BreakDownDataModelCopyWith<$Res>? get data;
}

/// @nodoc
class __$$CalculateFareResponseModelImplCopyWithImpl<$Res>
    extends _$CalculateFareResponseModelCopyWithImpl<$Res,
        _$CalculateFareResponseModelImpl>
    implements _$$CalculateFareResponseModelImplCopyWith<$Res> {
  __$$CalculateFareResponseModelImplCopyWithImpl(
      _$CalculateFareResponseModelImpl _value,
      $Res Function(_$CalculateFareResponseModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = freezed,
    Object? fareToken = freezed,
    Object? data = freezed,
    Object? couponDetails = freezed,
    Object? expiresAt = freezed,
  }) {
    return _then(_$CalculateFareResponseModelImpl(
      success: freezed == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool?,
      fareToken: freezed == fareToken
          ? _value.fareToken
          : fareToken // ignore: cast_nullable_to_non_nullable
              as String?,
      data: freezed == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as BreakDownDataModel?,
      couponDetails: freezed == couponDetails
          ? _value.couponDetails
          : couponDetails // ignore: cast_nullable_to_non_nullable
              as dynamic,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CalculateFareResponseModelImpl implements _CalculateFareResponseModel {
  const _$CalculateFareResponseModelImpl(
      {this.success,
      this.fareToken,
      this.data,
      @JsonKey(name: 'coupon_details') this.couponDetails,
      @JsonKey(name: 'expires_at') this.expiresAt});

  factory _$CalculateFareResponseModelImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$CalculateFareResponseModelImplFromJson(json);

  @override
  final bool? success;
  @override
  final String? fareToken;
  @override
  final BreakDownDataModel? data;
  @override
  @JsonKey(name: 'coupon_details')
  final dynamic couponDetails;
  @override
  @JsonKey(name: 'expires_at')
  final dynamic expiresAt;

  @override
  String toString() {
    return 'CalculateFareResponseModel(success: $success, fareToken: $fareToken, data: $data, couponDetails: $couponDetails, expiresAt: $expiresAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CalculateFareResponseModelImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.fareToken, fareToken) ||
                other.fareToken == fareToken) &&
            (identical(other.data, data) || other.data == data) &&
            const DeepCollectionEquality()
                .equals(other.couponDetails, couponDetails) &&
            const DeepCollectionEquality().equals(other.expiresAt, expiresAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      success,
      fareToken,
      data,
      const DeepCollectionEquality().hash(couponDetails),
      const DeepCollectionEquality().hash(expiresAt));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CalculateFareResponseModelImplCopyWith<_$CalculateFareResponseModelImpl>
      get copyWith => __$$CalculateFareResponseModelImplCopyWithImpl<
          _$CalculateFareResponseModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CalculateFareResponseModelImplToJson(
      this,
    );
  }
}

abstract class _CalculateFareResponseModel
    implements CalculateFareResponseModel {
  const factory _CalculateFareResponseModel(
          {final bool? success,
          final String? fareToken,
          final BreakDownDataModel? data,
          @JsonKey(name: 'coupon_details') final dynamic couponDetails,
          @JsonKey(name: 'expires_at') final dynamic expiresAt}) =
      _$CalculateFareResponseModelImpl;

  factory _CalculateFareResponseModel.fromJson(Map<String, dynamic> json) =
      _$CalculateFareResponseModelImpl.fromJson;

  @override
  bool? get success;
  @override
  String? get fareToken;
  @override
  BreakDownDataModel? get data;
  @override
  @JsonKey(name: 'coupon_details')
  dynamic get couponDetails;
  @override
  @JsonKey(name: 'expires_at')
  dynamic get expiresAt;
  @override
  @JsonKey(ignore: true)
  _$$CalculateFareResponseModelImplCopyWith<_$CalculateFareResponseModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}

BreakDownDataModel _$BreakDownDataModelFromJson(Map<String, dynamic> json) {
  return _BreakDownDataModel.fromJson(json);
}

/// @nodoc
mixin _$BreakDownDataModel {
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'base_price')
  dynamic get basePrice => throw _privateConstructorUsedError;
  @JsonKey(name: 'traveler_count')
  dynamic get travelerCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'base_total')
  dynamic get baseTotal => throw _privateConstructorUsedError;
  dynamic get discount => throw _privateConstructorUsedError;
  @JsonKey(name: 'coupon_code')
  dynamic get couponCode => throw _privateConstructorUsedError;
  @JsonKey(name: 'amount_after_discount')
  dynamic get amountAfterDiscount => throw _privateConstructorUsedError;
  dynamic get taxes => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_tax')
  dynamic get totalTax => throw _privateConstructorUsedError;
  dynamic get gst => throw _privateConstructorUsedError;
  @JsonKey(name: 'platform_fee')
  dynamic get platformFee => throw _privateConstructorUsedError;
  @JsonKey(name: 'insurance_fee')
  dynamic get insuranceFee => throw _privateConstructorUsedError;
  @JsonKey(name: 'cancellation_fee')
  dynamic get cancellationFee => throw _privateConstructorUsedError;
  @JsonKey(name: 'final_amount')
  dynamic get finalAmount => throw _privateConstructorUsedError;
  @JsonKey(name: 'cancellation_policy_type')
  dynamic get cancellationPolicyType => throw _privateConstructorUsedError;
  @JsonKey(name: 'advance_amount')
  dynamic get advanceAmount => throw _privateConstructorUsedError;
  @JsonKey(name: 'amount_to_pay_now')
  dynamic get amountToPayNow => throw _privateConstructorUsedError;
  @JsonKey(name: 'remaining_amount')
  dynamic get remainingAmount => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BreakDownDataModelCopyWith<BreakDownDataModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BreakDownDataModelCopyWith<$Res> {
  factory $BreakDownDataModelCopyWith(
          BreakDownDataModel value, $Res Function(BreakDownDataModel) then) =
      _$BreakDownDataModelCopyWithImpl<$Res, BreakDownDataModel>;
  @useResult
  $Res call(
      {int? id,
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
      @JsonKey(name: 'remaining_amount') dynamic remainingAmount});
}

/// @nodoc
class _$BreakDownDataModelCopyWithImpl<$Res, $Val extends BreakDownDataModel>
    implements $BreakDownDataModelCopyWith<$Res> {
  _$BreakDownDataModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? basePrice = freezed,
    Object? travelerCount = freezed,
    Object? baseTotal = freezed,
    Object? discount = freezed,
    Object? couponCode = freezed,
    Object? amountAfterDiscount = freezed,
    Object? taxes = freezed,
    Object? totalTax = freezed,
    Object? gst = freezed,
    Object? platformFee = freezed,
    Object? insuranceFee = freezed,
    Object? cancellationFee = freezed,
    Object? finalAmount = freezed,
    Object? cancellationPolicyType = freezed,
    Object? advanceAmount = freezed,
    Object? amountToPayNow = freezed,
    Object? remainingAmount = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      basePrice: freezed == basePrice
          ? _value.basePrice
          : basePrice // ignore: cast_nullable_to_non_nullable
              as dynamic,
      travelerCount: freezed == travelerCount
          ? _value.travelerCount
          : travelerCount // ignore: cast_nullable_to_non_nullable
              as dynamic,
      baseTotal: freezed == baseTotal
          ? _value.baseTotal
          : baseTotal // ignore: cast_nullable_to_non_nullable
              as dynamic,
      discount: freezed == discount
          ? _value.discount
          : discount // ignore: cast_nullable_to_non_nullable
              as dynamic,
      couponCode: freezed == couponCode
          ? _value.couponCode
          : couponCode // ignore: cast_nullable_to_non_nullable
              as dynamic,
      amountAfterDiscount: freezed == amountAfterDiscount
          ? _value.amountAfterDiscount
          : amountAfterDiscount // ignore: cast_nullable_to_non_nullable
              as dynamic,
      taxes: freezed == taxes
          ? _value.taxes
          : taxes // ignore: cast_nullable_to_non_nullable
              as dynamic,
      totalTax: freezed == totalTax
          ? _value.totalTax
          : totalTax // ignore: cast_nullable_to_non_nullable
              as dynamic,
      gst: freezed == gst
          ? _value.gst
          : gst // ignore: cast_nullable_to_non_nullable
              as dynamic,
      platformFee: freezed == platformFee
          ? _value.platformFee
          : platformFee // ignore: cast_nullable_to_non_nullable
              as dynamic,
      insuranceFee: freezed == insuranceFee
          ? _value.insuranceFee
          : insuranceFee // ignore: cast_nullable_to_non_nullable
              as dynamic,
      cancellationFee: freezed == cancellationFee
          ? _value.cancellationFee
          : cancellationFee // ignore: cast_nullable_to_non_nullable
              as dynamic,
      finalAmount: freezed == finalAmount
          ? _value.finalAmount
          : finalAmount // ignore: cast_nullable_to_non_nullable
              as dynamic,
      cancellationPolicyType: freezed == cancellationPolicyType
          ? _value.cancellationPolicyType
          : cancellationPolicyType // ignore: cast_nullable_to_non_nullable
              as dynamic,
      advanceAmount: freezed == advanceAmount
          ? _value.advanceAmount
          : advanceAmount // ignore: cast_nullable_to_non_nullable
              as dynamic,
      amountToPayNow: freezed == amountToPayNow
          ? _value.amountToPayNow
          : amountToPayNow // ignore: cast_nullable_to_non_nullable
              as dynamic,
      remainingAmount: freezed == remainingAmount
          ? _value.remainingAmount
          : remainingAmount // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BreakDownDataModelImplCopyWith<$Res>
    implements $BreakDownDataModelCopyWith<$Res> {
  factory _$$BreakDownDataModelImplCopyWith(_$BreakDownDataModelImpl value,
          $Res Function(_$BreakDownDataModelImpl) then) =
      __$$BreakDownDataModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? id,
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
      @JsonKey(name: 'remaining_amount') dynamic remainingAmount});
}

/// @nodoc
class __$$BreakDownDataModelImplCopyWithImpl<$Res>
    extends _$BreakDownDataModelCopyWithImpl<$Res, _$BreakDownDataModelImpl>
    implements _$$BreakDownDataModelImplCopyWith<$Res> {
  __$$BreakDownDataModelImplCopyWithImpl(_$BreakDownDataModelImpl _value,
      $Res Function(_$BreakDownDataModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? basePrice = freezed,
    Object? travelerCount = freezed,
    Object? baseTotal = freezed,
    Object? discount = freezed,
    Object? couponCode = freezed,
    Object? amountAfterDiscount = freezed,
    Object? taxes = freezed,
    Object? totalTax = freezed,
    Object? gst = freezed,
    Object? platformFee = freezed,
    Object? insuranceFee = freezed,
    Object? cancellationFee = freezed,
    Object? finalAmount = freezed,
    Object? cancellationPolicyType = freezed,
    Object? advanceAmount = freezed,
    Object? amountToPayNow = freezed,
    Object? remainingAmount = freezed,
  }) {
    return _then(_$BreakDownDataModelImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      basePrice: freezed == basePrice
          ? _value.basePrice
          : basePrice // ignore: cast_nullable_to_non_nullable
              as dynamic,
      travelerCount: freezed == travelerCount
          ? _value.travelerCount
          : travelerCount // ignore: cast_nullable_to_non_nullable
              as dynamic,
      baseTotal: freezed == baseTotal
          ? _value.baseTotal
          : baseTotal // ignore: cast_nullable_to_non_nullable
              as dynamic,
      discount: freezed == discount
          ? _value.discount
          : discount // ignore: cast_nullable_to_non_nullable
              as dynamic,
      couponCode: freezed == couponCode
          ? _value.couponCode
          : couponCode // ignore: cast_nullable_to_non_nullable
              as dynamic,
      amountAfterDiscount: freezed == amountAfterDiscount
          ? _value.amountAfterDiscount
          : amountAfterDiscount // ignore: cast_nullable_to_non_nullable
              as dynamic,
      taxes: freezed == taxes
          ? _value.taxes
          : taxes // ignore: cast_nullable_to_non_nullable
              as dynamic,
      totalTax: freezed == totalTax
          ? _value.totalTax
          : totalTax // ignore: cast_nullable_to_non_nullable
              as dynamic,
      gst: freezed == gst
          ? _value.gst
          : gst // ignore: cast_nullable_to_non_nullable
              as dynamic,
      platformFee: freezed == platformFee
          ? _value.platformFee
          : platformFee // ignore: cast_nullable_to_non_nullable
              as dynamic,
      insuranceFee: freezed == insuranceFee
          ? _value.insuranceFee
          : insuranceFee // ignore: cast_nullable_to_non_nullable
              as dynamic,
      cancellationFee: freezed == cancellationFee
          ? _value.cancellationFee
          : cancellationFee // ignore: cast_nullable_to_non_nullable
              as dynamic,
      finalAmount: freezed == finalAmount
          ? _value.finalAmount
          : finalAmount // ignore: cast_nullable_to_non_nullable
              as dynamic,
      cancellationPolicyType: freezed == cancellationPolicyType
          ? _value.cancellationPolicyType
          : cancellationPolicyType // ignore: cast_nullable_to_non_nullable
              as dynamic,
      advanceAmount: freezed == advanceAmount
          ? _value.advanceAmount
          : advanceAmount // ignore: cast_nullable_to_non_nullable
              as dynamic,
      amountToPayNow: freezed == amountToPayNow
          ? _value.amountToPayNow
          : amountToPayNow // ignore: cast_nullable_to_non_nullable
              as dynamic,
      remainingAmount: freezed == remainingAmount
          ? _value.remainingAmount
          : remainingAmount // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BreakDownDataModelImpl implements _BreakDownDataModel {
  const _$BreakDownDataModelImpl(
      {this.id,
      @JsonKey(name: 'base_price') this.basePrice,
      @JsonKey(name: 'traveler_count') this.travelerCount,
      @JsonKey(name: 'base_total') this.baseTotal,
      this.discount,
      @JsonKey(name: 'coupon_code') this.couponCode,
      @JsonKey(name: 'amount_after_discount') this.amountAfterDiscount,
      this.taxes,
      @JsonKey(name: 'total_tax') this.totalTax,
      this.gst,
      @JsonKey(name: 'platform_fee') this.platformFee,
      @JsonKey(name: 'insurance_fee') this.insuranceFee,
      @JsonKey(name: 'cancellation_fee') this.cancellationFee,
      @JsonKey(name: 'final_amount') this.finalAmount,
      @JsonKey(name: 'cancellation_policy_type') this.cancellationPolicyType,
      @JsonKey(name: 'advance_amount') this.advanceAmount,
      @JsonKey(name: 'amount_to_pay_now') this.amountToPayNow,
      @JsonKey(name: 'remaining_amount') this.remainingAmount});

  factory _$BreakDownDataModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$BreakDownDataModelImplFromJson(json);

  @override
  final int? id;
  @override
  @JsonKey(name: 'base_price')
  final dynamic basePrice;
  @override
  @JsonKey(name: 'traveler_count')
  final dynamic travelerCount;
  @override
  @JsonKey(name: 'base_total')
  final dynamic baseTotal;
  @override
  final dynamic discount;
  @override
  @JsonKey(name: 'coupon_code')
  final dynamic couponCode;
  @override
  @JsonKey(name: 'amount_after_discount')
  final dynamic amountAfterDiscount;
  @override
  final dynamic taxes;
  @override
  @JsonKey(name: 'total_tax')
  final dynamic totalTax;
  @override
  final dynamic gst;
  @override
  @JsonKey(name: 'platform_fee')
  final dynamic platformFee;
  @override
  @JsonKey(name: 'insurance_fee')
  final dynamic insuranceFee;
  @override
  @JsonKey(name: 'cancellation_fee')
  final dynamic cancellationFee;
  @override
  @JsonKey(name: 'final_amount')
  final dynamic finalAmount;
  @override
  @JsonKey(name: 'cancellation_policy_type')
  final dynamic cancellationPolicyType;
  @override
  @JsonKey(name: 'advance_amount')
  final dynamic advanceAmount;
  @override
  @JsonKey(name: 'amount_to_pay_now')
  final dynamic amountToPayNow;
  @override
  @JsonKey(name: 'remaining_amount')
  final dynamic remainingAmount;

  @override
  String toString() {
    return 'BreakDownDataModel(id: $id, basePrice: $basePrice, travelerCount: $travelerCount, baseTotal: $baseTotal, discount: $discount, couponCode: $couponCode, amountAfterDiscount: $amountAfterDiscount, taxes: $taxes, totalTax: $totalTax, gst: $gst, platformFee: $platformFee, insuranceFee: $insuranceFee, cancellationFee: $cancellationFee, finalAmount: $finalAmount, cancellationPolicyType: $cancellationPolicyType, advanceAmount: $advanceAmount, amountToPayNow: $amountToPayNow, remainingAmount: $remainingAmount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BreakDownDataModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            const DeepCollectionEquality().equals(other.basePrice, basePrice) &&
            const DeepCollectionEquality()
                .equals(other.travelerCount, travelerCount) &&
            const DeepCollectionEquality().equals(other.baseTotal, baseTotal) &&
            const DeepCollectionEquality().equals(other.discount, discount) &&
            const DeepCollectionEquality()
                .equals(other.couponCode, couponCode) &&
            const DeepCollectionEquality()
                .equals(other.amountAfterDiscount, amountAfterDiscount) &&
            const DeepCollectionEquality().equals(other.taxes, taxes) &&
            const DeepCollectionEquality().equals(other.totalTax, totalTax) &&
            const DeepCollectionEquality().equals(other.gst, gst) &&
            const DeepCollectionEquality()
                .equals(other.platformFee, platformFee) &&
            const DeepCollectionEquality()
                .equals(other.insuranceFee, insuranceFee) &&
            const DeepCollectionEquality()
                .equals(other.cancellationFee, cancellationFee) &&
            const DeepCollectionEquality()
                .equals(other.finalAmount, finalAmount) &&
            const DeepCollectionEquality()
                .equals(other.cancellationPolicyType, cancellationPolicyType) &&
            const DeepCollectionEquality()
                .equals(other.advanceAmount, advanceAmount) &&
            const DeepCollectionEquality()
                .equals(other.amountToPayNow, amountToPayNow) &&
            const DeepCollectionEquality()
                .equals(other.remainingAmount, remainingAmount));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      const DeepCollectionEquality().hash(basePrice),
      const DeepCollectionEquality().hash(travelerCount),
      const DeepCollectionEquality().hash(baseTotal),
      const DeepCollectionEquality().hash(discount),
      const DeepCollectionEquality().hash(couponCode),
      const DeepCollectionEquality().hash(amountAfterDiscount),
      const DeepCollectionEquality().hash(taxes),
      const DeepCollectionEquality().hash(totalTax),
      const DeepCollectionEquality().hash(gst),
      const DeepCollectionEquality().hash(platformFee),
      const DeepCollectionEquality().hash(insuranceFee),
      const DeepCollectionEquality().hash(cancellationFee),
      const DeepCollectionEquality().hash(finalAmount),
      const DeepCollectionEquality().hash(cancellationPolicyType),
      const DeepCollectionEquality().hash(advanceAmount),
      const DeepCollectionEquality().hash(amountToPayNow),
      const DeepCollectionEquality().hash(remainingAmount));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BreakDownDataModelImplCopyWith<_$BreakDownDataModelImpl> get copyWith =>
      __$$BreakDownDataModelImplCopyWithImpl<_$BreakDownDataModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BreakDownDataModelImplToJson(
      this,
    );
  }
}

abstract class _BreakDownDataModel implements BreakDownDataModel {
  const factory _BreakDownDataModel(
      {final int? id,
      @JsonKey(name: 'base_price') final dynamic basePrice,
      @JsonKey(name: 'traveler_count') final dynamic travelerCount,
      @JsonKey(name: 'base_total') final dynamic baseTotal,
      final dynamic discount,
      @JsonKey(name: 'coupon_code') final dynamic couponCode,
      @JsonKey(name: 'amount_after_discount') final dynamic amountAfterDiscount,
      final dynamic taxes,
      @JsonKey(name: 'total_tax') final dynamic totalTax,
      final dynamic gst,
      @JsonKey(name: 'platform_fee') final dynamic platformFee,
      @JsonKey(name: 'insurance_fee') final dynamic insuranceFee,
      @JsonKey(name: 'cancellation_fee') final dynamic cancellationFee,
      @JsonKey(name: 'final_amount') final dynamic finalAmount,
      @JsonKey(name: 'cancellation_policy_type')
      final dynamic cancellationPolicyType,
      @JsonKey(name: 'advance_amount') final dynamic advanceAmount,
      @JsonKey(name: 'amount_to_pay_now') final dynamic amountToPayNow,
      @JsonKey(name: 'remaining_amount')
      final dynamic remainingAmount}) = _$BreakDownDataModelImpl;

  factory _BreakDownDataModel.fromJson(Map<String, dynamic> json) =
      _$BreakDownDataModelImpl.fromJson;

  @override
  int? get id;
  @override
  @JsonKey(name: 'base_price')
  dynamic get basePrice;
  @override
  @JsonKey(name: 'traveler_count')
  dynamic get travelerCount;
  @override
  @JsonKey(name: 'base_total')
  dynamic get baseTotal;
  @override
  dynamic get discount;
  @override
  @JsonKey(name: 'coupon_code')
  dynamic get couponCode;
  @override
  @JsonKey(name: 'amount_after_discount')
  dynamic get amountAfterDiscount;
  @override
  dynamic get taxes;
  @override
  @JsonKey(name: 'total_tax')
  dynamic get totalTax;
  @override
  dynamic get gst;
  @override
  @JsonKey(name: 'platform_fee')
  dynamic get platformFee;
  @override
  @JsonKey(name: 'insurance_fee')
  dynamic get insuranceFee;
  @override
  @JsonKey(name: 'cancellation_fee')
  dynamic get cancellationFee;
  @override
  @JsonKey(name: 'final_amount')
  dynamic get finalAmount;
  @override
  @JsonKey(name: 'cancellation_policy_type')
  dynamic get cancellationPolicyType;
  @override
  @JsonKey(name: 'advance_amount')
  dynamic get advanceAmount;
  @override
  @JsonKey(name: 'amount_to_pay_now')
  dynamic get amountToPayNow;
  @override
  @JsonKey(name: 'remaining_amount')
  dynamic get remainingAmount;
  @override
  @JsonKey(ignore: true)
  _$$BreakDownDataModelImplCopyWith<_$BreakDownDataModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
