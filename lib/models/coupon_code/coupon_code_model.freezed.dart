// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'coupon_code_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

ValidateCouponCodeRequestModel _$ValidateCouponCodeRequestModelFromJson(
    Map<String, dynamic> json) {
  return _ValidateCouponCodeRequestModel.fromJson(json);
}

/// @nodoc
mixin _$ValidateCouponCodeRequestModel {
  String get code => throw _privateConstructorUsedError;
  dynamic get trekId => throw _privateConstructorUsedError;
  @JsonKey(name: 'amount')
  dynamic get bookingAmount => throw _privateConstructorUsedError;

  /// Number of travelers — required for group-discount minimum participant validation.
  @JsonKey(name: 'travelerCount')
  int? get travelerCount => throw _privateConstructorUsedError;

  /// TBR batch id — the same coupon can be assigned to multiple TBRs, and
  /// "already used" is scoped per TBR, not globally per customer.
  @JsonKey(name: 'batchId')
  int? get batchId => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ValidateCouponCodeRequestModelCopyWith<ValidateCouponCodeRequestModel>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ValidateCouponCodeRequestModelCopyWith<$Res> {
  factory $ValidateCouponCodeRequestModelCopyWith(
          ValidateCouponCodeRequestModel value,
          $Res Function(ValidateCouponCodeRequestModel) then) =
      _$ValidateCouponCodeRequestModelCopyWithImpl<$Res,
          ValidateCouponCodeRequestModel>;
  @useResult
  $Res call(
      {String code,
      dynamic trekId,
      @JsonKey(name: 'amount') dynamic bookingAmount,
      @JsonKey(name: 'travelerCount') int? travelerCount,
      @JsonKey(name: 'batchId') int? batchId});
}

/// @nodoc
class _$ValidateCouponCodeRequestModelCopyWithImpl<$Res,
        $Val extends ValidateCouponCodeRequestModel>
    implements $ValidateCouponCodeRequestModelCopyWith<$Res> {
  _$ValidateCouponCodeRequestModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? trekId = freezed,
    Object? bookingAmount = freezed,
    Object? travelerCount = freezed,
    Object? batchId = freezed,
  }) {
    return _then(_value.copyWith(
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      trekId: freezed == trekId
          ? _value.trekId
          : trekId // ignore: cast_nullable_to_non_nullable
              as dynamic,
      bookingAmount: freezed == bookingAmount
          ? _value.bookingAmount
          : bookingAmount // ignore: cast_nullable_to_non_nullable
              as dynamic,
      travelerCount: freezed == travelerCount
          ? _value.travelerCount
          : travelerCount // ignore: cast_nullable_to_non_nullable
              as int?,
      batchId: freezed == batchId
          ? _value.batchId
          : batchId // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ValidateCouponCodeRequestModelImplCopyWith<$Res>
    implements $ValidateCouponCodeRequestModelCopyWith<$Res> {
  factory _$$ValidateCouponCodeRequestModelImplCopyWith(
          _$ValidateCouponCodeRequestModelImpl value,
          $Res Function(_$ValidateCouponCodeRequestModelImpl) then) =
      __$$ValidateCouponCodeRequestModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String code,
      dynamic trekId,
      @JsonKey(name: 'amount') dynamic bookingAmount,
      @JsonKey(name: 'travelerCount') int? travelerCount,
      @JsonKey(name: 'batchId') int? batchId});
}

/// @nodoc
class __$$ValidateCouponCodeRequestModelImplCopyWithImpl<$Res>
    extends _$ValidateCouponCodeRequestModelCopyWithImpl<$Res,
        _$ValidateCouponCodeRequestModelImpl>
    implements _$$ValidateCouponCodeRequestModelImplCopyWith<$Res> {
  __$$ValidateCouponCodeRequestModelImplCopyWithImpl(
      _$ValidateCouponCodeRequestModelImpl _value,
      $Res Function(_$ValidateCouponCodeRequestModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? trekId = freezed,
    Object? bookingAmount = freezed,
    Object? travelerCount = freezed,
    Object? batchId = freezed,
  }) {
    return _then(_$ValidateCouponCodeRequestModelImpl(
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      trekId: freezed == trekId
          ? _value.trekId
          : trekId // ignore: cast_nullable_to_non_nullable
              as dynamic,
      bookingAmount: freezed == bookingAmount
          ? _value.bookingAmount
          : bookingAmount // ignore: cast_nullable_to_non_nullable
              as dynamic,
      travelerCount: freezed == travelerCount
          ? _value.travelerCount
          : travelerCount // ignore: cast_nullable_to_non_nullable
              as int?,
      batchId: freezed == batchId
          ? _value.batchId
          : batchId // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ValidateCouponCodeRequestModelImpl
    implements _ValidateCouponCodeRequestModel {
  const _$ValidateCouponCodeRequestModelImpl(
      {required this.code,
      required this.trekId,
      @JsonKey(name: 'amount') required this.bookingAmount,
      @JsonKey(name: 'travelerCount') this.travelerCount,
      @JsonKey(name: 'batchId') this.batchId});

  factory _$ValidateCouponCodeRequestModelImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$ValidateCouponCodeRequestModelImplFromJson(json);

  @override
  final String code;
  @override
  final dynamic trekId;
  @override
  @JsonKey(name: 'amount')
  final dynamic bookingAmount;

  /// Number of travelers — required for group-discount minimum participant validation.
  @override
  @JsonKey(name: 'travelerCount')
  final int? travelerCount;

  /// TBR batch id — the same coupon can be assigned to multiple TBRs, and
  /// "already used" is scoped per TBR, not globally per customer.
  @override
  @JsonKey(name: 'batchId')
  final int? batchId;

  @override
  String toString() {
    return 'ValidateCouponCodeRequestModel(code: $code, trekId: $trekId, bookingAmount: $bookingAmount, travelerCount: $travelerCount, batchId: $batchId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ValidateCouponCodeRequestModelImpl &&
            (identical(other.code, code) || other.code == code) &&
            const DeepCollectionEquality().equals(other.trekId, trekId) &&
            const DeepCollectionEquality()
                .equals(other.bookingAmount, bookingAmount) &&
            (identical(other.travelerCount, travelerCount) ||
                other.travelerCount == travelerCount) &&
            (identical(other.batchId, batchId) || other.batchId == batchId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      code,
      const DeepCollectionEquality().hash(trekId),
      const DeepCollectionEquality().hash(bookingAmount),
      travelerCount,
      batchId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ValidateCouponCodeRequestModelImplCopyWith<
          _$ValidateCouponCodeRequestModelImpl>
      get copyWith => __$$ValidateCouponCodeRequestModelImplCopyWithImpl<
          _$ValidateCouponCodeRequestModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ValidateCouponCodeRequestModelImplToJson(
      this,
    );
  }
}

abstract class _ValidateCouponCodeRequestModel
    implements ValidateCouponCodeRequestModel {
  const factory _ValidateCouponCodeRequestModel(
          {required final String code,
          required final dynamic trekId,
          @JsonKey(name: 'amount') required final dynamic bookingAmount,
          @JsonKey(name: 'travelerCount') final int? travelerCount,
          @JsonKey(name: 'batchId') final int? batchId}) =
      _$ValidateCouponCodeRequestModelImpl;

  factory _ValidateCouponCodeRequestModel.fromJson(Map<String, dynamic> json) =
      _$ValidateCouponCodeRequestModelImpl.fromJson;

  @override
  String get code;
  @override
  dynamic get trekId;
  @override
  @JsonKey(name: 'amount')
  dynamic get bookingAmount;
  @override

  /// Number of travelers — required for group-discount minimum participant validation.
  @JsonKey(name: 'travelerCount')
  int? get travelerCount;
  @override

  /// TBR batch id — the same coupon can be assigned to multiple TBRs, and
  /// "already used" is scoped per TBR, not globally per customer.
  @JsonKey(name: 'batchId')
  int? get batchId;
  @override
  @JsonKey(ignore: true)
  _$$ValidateCouponCodeRequestModelImplCopyWith<
          _$ValidateCouponCodeRequestModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}

ValidateCouponCodeResponseModel _$ValidateCouponCodeResponseModelFromJson(
    Map<String, dynamic> json) {
  return _ValidateCouponCodeResponseModel.fromJson(json);
}

/// @nodoc
mixin _$ValidateCouponCodeResponseModel {
  bool? get success => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;
  ValidateCouponCodeDataModel? get coupon => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ValidateCouponCodeResponseModelCopyWith<ValidateCouponCodeResponseModel>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ValidateCouponCodeResponseModelCopyWith<$Res> {
  factory $ValidateCouponCodeResponseModelCopyWith(
          ValidateCouponCodeResponseModel value,
          $Res Function(ValidateCouponCodeResponseModel) then) =
      _$ValidateCouponCodeResponseModelCopyWithImpl<$Res,
          ValidateCouponCodeResponseModel>;
  @useResult
  $Res call(
      {bool? success, String? message, ValidateCouponCodeDataModel? coupon});

  $ValidateCouponCodeDataModelCopyWith<$Res>? get coupon;
}

/// @nodoc
class _$ValidateCouponCodeResponseModelCopyWithImpl<$Res,
        $Val extends ValidateCouponCodeResponseModel>
    implements $ValidateCouponCodeResponseModelCopyWith<$Res> {
  _$ValidateCouponCodeResponseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = freezed,
    Object? message = freezed,
    Object? coupon = freezed,
  }) {
    return _then(_value.copyWith(
      success: freezed == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool?,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      coupon: freezed == coupon
          ? _value.coupon
          : coupon // ignore: cast_nullable_to_non_nullable
              as ValidateCouponCodeDataModel?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $ValidateCouponCodeDataModelCopyWith<$Res>? get coupon {
    if (_value.coupon == null) {
      return null;
    }

    return $ValidateCouponCodeDataModelCopyWith<$Res>(_value.coupon!, (value) {
      return _then(_value.copyWith(coupon: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ValidateCouponCodeResponseModelImplCopyWith<$Res>
    implements $ValidateCouponCodeResponseModelCopyWith<$Res> {
  factory _$$ValidateCouponCodeResponseModelImplCopyWith(
          _$ValidateCouponCodeResponseModelImpl value,
          $Res Function(_$ValidateCouponCodeResponseModelImpl) then) =
      __$$ValidateCouponCodeResponseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool? success, String? message, ValidateCouponCodeDataModel? coupon});

  @override
  $ValidateCouponCodeDataModelCopyWith<$Res>? get coupon;
}

/// @nodoc
class __$$ValidateCouponCodeResponseModelImplCopyWithImpl<$Res>
    extends _$ValidateCouponCodeResponseModelCopyWithImpl<$Res,
        _$ValidateCouponCodeResponseModelImpl>
    implements _$$ValidateCouponCodeResponseModelImplCopyWith<$Res> {
  __$$ValidateCouponCodeResponseModelImplCopyWithImpl(
      _$ValidateCouponCodeResponseModelImpl _value,
      $Res Function(_$ValidateCouponCodeResponseModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = freezed,
    Object? message = freezed,
    Object? coupon = freezed,
  }) {
    return _then(_$ValidateCouponCodeResponseModelImpl(
      success: freezed == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool?,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      coupon: freezed == coupon
          ? _value.coupon
          : coupon // ignore: cast_nullable_to_non_nullable
              as ValidateCouponCodeDataModel?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ValidateCouponCodeResponseModelImpl
    implements _ValidateCouponCodeResponseModel {
  const _$ValidateCouponCodeResponseModelImpl(
      {this.success, this.message, this.coupon});

  factory _$ValidateCouponCodeResponseModelImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$ValidateCouponCodeResponseModelImplFromJson(json);

  @override
  final bool? success;
  @override
  final String? message;
  @override
  final ValidateCouponCodeDataModel? coupon;

  @override
  String toString() {
    return 'ValidateCouponCodeResponseModel(success: $success, message: $message, coupon: $coupon)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ValidateCouponCodeResponseModelImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.coupon, coupon) || other.coupon == coupon));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, success, message, coupon);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ValidateCouponCodeResponseModelImplCopyWith<
          _$ValidateCouponCodeResponseModelImpl>
      get copyWith => __$$ValidateCouponCodeResponseModelImplCopyWithImpl<
          _$ValidateCouponCodeResponseModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ValidateCouponCodeResponseModelImplToJson(
      this,
    );
  }
}

abstract class _ValidateCouponCodeResponseModel
    implements ValidateCouponCodeResponseModel {
  const factory _ValidateCouponCodeResponseModel(
          {final bool? success,
          final String? message,
          final ValidateCouponCodeDataModel? coupon}) =
      _$ValidateCouponCodeResponseModelImpl;

  factory _ValidateCouponCodeResponseModel.fromJson(Map<String, dynamic> json) =
      _$ValidateCouponCodeResponseModelImpl.fromJson;

  @override
  bool? get success;
  @override
  String? get message;
  @override
  ValidateCouponCodeDataModel? get coupon;
  @override
  @JsonKey(ignore: true)
  _$$ValidateCouponCodeResponseModelImplCopyWith<
          _$ValidateCouponCodeResponseModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}

ValidateCouponCodeDataModel _$ValidateCouponCodeDataModelFromJson(
    Map<String, dynamic> json) {
  return _ValidateCouponCodeDataModel.fromJson(json);
}

/// @nodoc
mixin _$ValidateCouponCodeDataModel {
  bool? get valid => throw _privateConstructorUsedError;
  @JsonKey(name: 'coupon_details')
  CouponCardData? get couponDetails => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ValidateCouponCodeDataModelCopyWith<ValidateCouponCodeDataModel>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ValidateCouponCodeDataModelCopyWith<$Res> {
  factory $ValidateCouponCodeDataModelCopyWith(
          ValidateCouponCodeDataModel value,
          $Res Function(ValidateCouponCodeDataModel) then) =
      _$ValidateCouponCodeDataModelCopyWithImpl<$Res,
          ValidateCouponCodeDataModel>;
  @useResult
  $Res call(
      {bool? valid,
      @JsonKey(name: 'coupon_details') CouponCardData? couponDetails});

  $CouponCardDataCopyWith<$Res>? get couponDetails;
}

/// @nodoc
class _$ValidateCouponCodeDataModelCopyWithImpl<$Res,
        $Val extends ValidateCouponCodeDataModel>
    implements $ValidateCouponCodeDataModelCopyWith<$Res> {
  _$ValidateCouponCodeDataModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? valid = freezed,
    Object? couponDetails = freezed,
  }) {
    return _then(_value.copyWith(
      valid: freezed == valid
          ? _value.valid
          : valid // ignore: cast_nullable_to_non_nullable
              as bool?,
      couponDetails: freezed == couponDetails
          ? _value.couponDetails
          : couponDetails // ignore: cast_nullable_to_non_nullable
              as CouponCardData?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $CouponCardDataCopyWith<$Res>? get couponDetails {
    if (_value.couponDetails == null) {
      return null;
    }

    return $CouponCardDataCopyWith<$Res>(_value.couponDetails!, (value) {
      return _then(_value.copyWith(couponDetails: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ValidateCouponCodeDataModelImplCopyWith<$Res>
    implements $ValidateCouponCodeDataModelCopyWith<$Res> {
  factory _$$ValidateCouponCodeDataModelImplCopyWith(
          _$ValidateCouponCodeDataModelImpl value,
          $Res Function(_$ValidateCouponCodeDataModelImpl) then) =
      __$$ValidateCouponCodeDataModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool? valid,
      @JsonKey(name: 'coupon_details') CouponCardData? couponDetails});

  @override
  $CouponCardDataCopyWith<$Res>? get couponDetails;
}

/// @nodoc
class __$$ValidateCouponCodeDataModelImplCopyWithImpl<$Res>
    extends _$ValidateCouponCodeDataModelCopyWithImpl<$Res,
        _$ValidateCouponCodeDataModelImpl>
    implements _$$ValidateCouponCodeDataModelImplCopyWith<$Res> {
  __$$ValidateCouponCodeDataModelImplCopyWithImpl(
      _$ValidateCouponCodeDataModelImpl _value,
      $Res Function(_$ValidateCouponCodeDataModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? valid = freezed,
    Object? couponDetails = freezed,
  }) {
    return _then(_$ValidateCouponCodeDataModelImpl(
      valid: freezed == valid
          ? _value.valid
          : valid // ignore: cast_nullable_to_non_nullable
              as bool?,
      couponDetails: freezed == couponDetails
          ? _value.couponDetails
          : couponDetails // ignore: cast_nullable_to_non_nullable
              as CouponCardData?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ValidateCouponCodeDataModelImpl
    implements _ValidateCouponCodeDataModel {
  const _$ValidateCouponCodeDataModelImpl(
      {this.valid, @JsonKey(name: 'coupon_details') this.couponDetails});

  factory _$ValidateCouponCodeDataModelImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$ValidateCouponCodeDataModelImplFromJson(json);

  @override
  final bool? valid;
  @override
  @JsonKey(name: 'coupon_details')
  final CouponCardData? couponDetails;

  @override
  String toString() {
    return 'ValidateCouponCodeDataModel(valid: $valid, couponDetails: $couponDetails)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ValidateCouponCodeDataModelImpl &&
            (identical(other.valid, valid) || other.valid == valid) &&
            (identical(other.couponDetails, couponDetails) ||
                other.couponDetails == couponDetails));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, valid, couponDetails);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ValidateCouponCodeDataModelImplCopyWith<_$ValidateCouponCodeDataModelImpl>
      get copyWith => __$$ValidateCouponCodeDataModelImplCopyWithImpl<
          _$ValidateCouponCodeDataModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ValidateCouponCodeDataModelImplToJson(
      this,
    );
  }
}

abstract class _ValidateCouponCodeDataModel
    implements ValidateCouponCodeDataModel {
  const factory _ValidateCouponCodeDataModel(
      {final bool? valid,
      @JsonKey(name: 'coupon_details')
      final CouponCardData? couponDetails}) = _$ValidateCouponCodeDataModelImpl;

  factory _ValidateCouponCodeDataModel.fromJson(Map<String, dynamic> json) =
      _$ValidateCouponCodeDataModelImpl.fromJson;

  @override
  bool? get valid;
  @override
  @JsonKey(name: 'coupon_details')
  CouponCardData? get couponDetails;
  @override
  @JsonKey(ignore: true)
  _$$ValidateCouponCodeDataModelImplCopyWith<_$ValidateCouponCodeDataModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}

CouponCodeModel _$CouponCodeModelFromJson(Map<String, dynamic> json) {
  return _CouponCodeModel.fromJson(json);
}

/// @nodoc
mixin _$CouponCodeModel {
  bool? get success => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;
  List<CouponCardData>? get data => throw _privateConstructorUsedError;
  int? get count => throw _privateConstructorUsedError;
  @JsonKey(name: 'vendor_info')
  VendorInfo? get vendorInfo => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CouponCodeModelCopyWith<CouponCodeModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CouponCodeModelCopyWith<$Res> {
  factory $CouponCodeModelCopyWith(
          CouponCodeModel value, $Res Function(CouponCodeModel) then) =
      _$CouponCodeModelCopyWithImpl<$Res, CouponCodeModel>;
  @useResult
  $Res call(
      {bool? success,
      String? message,
      List<CouponCardData>? data,
      int? count,
      @JsonKey(name: 'vendor_info') VendorInfo? vendorInfo});

  $VendorInfoCopyWith<$Res>? get vendorInfo;
}

/// @nodoc
class _$CouponCodeModelCopyWithImpl<$Res, $Val extends CouponCodeModel>
    implements $CouponCodeModelCopyWith<$Res> {
  _$CouponCodeModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = freezed,
    Object? message = freezed,
    Object? data = freezed,
    Object? count = freezed,
    Object? vendorInfo = freezed,
  }) {
    return _then(_value.copyWith(
      success: freezed == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool?,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      data: freezed == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as List<CouponCardData>?,
      count: freezed == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int?,
      vendorInfo: freezed == vendorInfo
          ? _value.vendorInfo
          : vendorInfo // ignore: cast_nullable_to_non_nullable
              as VendorInfo?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $VendorInfoCopyWith<$Res>? get vendorInfo {
    if (_value.vendorInfo == null) {
      return null;
    }

    return $VendorInfoCopyWith<$Res>(_value.vendorInfo!, (value) {
      return _then(_value.copyWith(vendorInfo: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CouponCodeModelImplCopyWith<$Res>
    implements $CouponCodeModelCopyWith<$Res> {
  factory _$$CouponCodeModelImplCopyWith(_$CouponCodeModelImpl value,
          $Res Function(_$CouponCodeModelImpl) then) =
      __$$CouponCodeModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool? success,
      String? message,
      List<CouponCardData>? data,
      int? count,
      @JsonKey(name: 'vendor_info') VendorInfo? vendorInfo});

  @override
  $VendorInfoCopyWith<$Res>? get vendorInfo;
}

/// @nodoc
class __$$CouponCodeModelImplCopyWithImpl<$Res>
    extends _$CouponCodeModelCopyWithImpl<$Res, _$CouponCodeModelImpl>
    implements _$$CouponCodeModelImplCopyWith<$Res> {
  __$$CouponCodeModelImplCopyWithImpl(
      _$CouponCodeModelImpl _value, $Res Function(_$CouponCodeModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = freezed,
    Object? message = freezed,
    Object? data = freezed,
    Object? count = freezed,
    Object? vendorInfo = freezed,
  }) {
    return _then(_$CouponCodeModelImpl(
      success: freezed == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool?,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      data: freezed == data
          ? _value._data
          : data // ignore: cast_nullable_to_non_nullable
              as List<CouponCardData>?,
      count: freezed == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int?,
      vendorInfo: freezed == vendorInfo
          ? _value.vendorInfo
          : vendorInfo // ignore: cast_nullable_to_non_nullable
              as VendorInfo?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CouponCodeModelImpl implements _CouponCodeModel {
  const _$CouponCodeModelImpl(
      {this.success,
      this.message,
      final List<CouponCardData>? data,
      this.count,
      @JsonKey(name: 'vendor_info') this.vendorInfo})
      : _data = data;

  factory _$CouponCodeModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$CouponCodeModelImplFromJson(json);

  @override
  final bool? success;
  @override
  final String? message;
  final List<CouponCardData>? _data;
  @override
  List<CouponCardData>? get data {
    final value = _data;
    if (value == null) return null;
    if (_data is EqualUnmodifiableListView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final int? count;
  @override
  @JsonKey(name: 'vendor_info')
  final VendorInfo? vendorInfo;

  @override
  String toString() {
    return 'CouponCodeModel(success: $success, message: $message, data: $data, count: $count, vendorInfo: $vendorInfo)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CouponCodeModelImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.message, message) || other.message == message) &&
            const DeepCollectionEquality().equals(other._data, _data) &&
            (identical(other.count, count) || other.count == count) &&
            (identical(other.vendorInfo, vendorInfo) ||
                other.vendorInfo == vendorInfo));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, success, message,
      const DeepCollectionEquality().hash(_data), count, vendorInfo);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CouponCodeModelImplCopyWith<_$CouponCodeModelImpl> get copyWith =>
      __$$CouponCodeModelImplCopyWithImpl<_$CouponCodeModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CouponCodeModelImplToJson(
      this,
    );
  }
}

abstract class _CouponCodeModel implements CouponCodeModel {
  const factory _CouponCodeModel(
          {final bool? success,
          final String? message,
          final List<CouponCardData>? data,
          final int? count,
          @JsonKey(name: 'vendor_info') final VendorInfo? vendorInfo}) =
      _$CouponCodeModelImpl;

  factory _CouponCodeModel.fromJson(Map<String, dynamic> json) =
      _$CouponCodeModelImpl.fromJson;

  @override
  bool? get success;
  @override
  String? get message;
  @override
  List<CouponCardData>? get data;
  @override
  int? get count;
  @override
  @JsonKey(name: 'vendor_info')
  VendorInfo? get vendorInfo;
  @override
  @JsonKey(ignore: true)
  _$$CouponCodeModelImplCopyWith<_$CouponCodeModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CouponCardData _$CouponCardDataFromJson(Map<String, dynamic> json) {
  return _CouponCardData.fromJson(json);
}

/// @nodoc
mixin _$CouponCardData {
  int? get id => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'image_path')
  String? get imagePath => throw _privateConstructorUsedError;
  List<String>? get gradient => throw _privateConstructorUsedError;
  @JsonKey(name: 'text_colour')
  String? get textColour => throw _privateConstructorUsedError;
  String? get code => throw _privateConstructorUsedError;
  @JsonKey(name: 'discount_type')
  String? get discountType => throw _privateConstructorUsedError;
  @JsonKey(name: 'discount_value')
  String? get discountValue => throw _privateConstructorUsedError;
  @JsonKey(name: 'terms_and_conditions')
  List<String>? get termsAndConditions => throw _privateConstructorUsedError;

  /// Detailed marketing description (e.g. "Trekking is better with friends…")
  @JsonKey(name: 'detailed_description')
  String? get detailedDescription => throw _privateConstructorUsedError;

  /// Plain-text instructions on how to redeem the coupon
  @JsonKey(name: 'how_to_apply')
  String? get howToApply => throw _privateConstructorUsedError;

  /// Footer note shown at the bottom of the T&C modal
  @JsonKey(name: 'footer_note')
  String? get footerNote => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_expired')
  bool? get isExpired => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_active')
  bool? get isActive => throw _privateConstructorUsedError;
  @JsonKey(name: 'valid_until')
  String? get validUntil => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CouponCardDataCopyWith<CouponCardData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CouponCardDataCopyWith<$Res> {
  factory $CouponCardDataCopyWith(
          CouponCardData value, $Res Function(CouponCardData) then) =
      _$CouponCardDataCopyWithImpl<$Res, CouponCardData>;
  @useResult
  $Res call(
      {int? id,
      String? title,
      String? description,
      @JsonKey(name: 'image_path') String? imagePath,
      List<String>? gradient,
      @JsonKey(name: 'text_colour') String? textColour,
      String? code,
      @JsonKey(name: 'discount_type') String? discountType,
      @JsonKey(name: 'discount_value') String? discountValue,
      @JsonKey(name: 'terms_and_conditions') List<String>? termsAndConditions,
      @JsonKey(name: 'detailed_description') String? detailedDescription,
      @JsonKey(name: 'how_to_apply') String? howToApply,
      @JsonKey(name: 'footer_note') String? footerNote,
      @JsonKey(name: 'is_expired') bool? isExpired,
      @JsonKey(name: 'is_active') bool? isActive,
      @JsonKey(name: 'valid_until') String? validUntil});
}

/// @nodoc
class _$CouponCardDataCopyWithImpl<$Res, $Val extends CouponCardData>
    implements $CouponCardDataCopyWith<$Res> {
  _$CouponCardDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? title = freezed,
    Object? description = freezed,
    Object? imagePath = freezed,
    Object? gradient = freezed,
    Object? textColour = freezed,
    Object? code = freezed,
    Object? discountType = freezed,
    Object? discountValue = freezed,
    Object? termsAndConditions = freezed,
    Object? detailedDescription = freezed,
    Object? howToApply = freezed,
    Object? footerNote = freezed,
    Object? isExpired = freezed,
    Object? isActive = freezed,
    Object? validUntil = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      imagePath: freezed == imagePath
          ? _value.imagePath
          : imagePath // ignore: cast_nullable_to_non_nullable
              as String?,
      gradient: freezed == gradient
          ? _value.gradient
          : gradient // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      textColour: freezed == textColour
          ? _value.textColour
          : textColour // ignore: cast_nullable_to_non_nullable
              as String?,
      code: freezed == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String?,
      discountType: freezed == discountType
          ? _value.discountType
          : discountType // ignore: cast_nullable_to_non_nullable
              as String?,
      discountValue: freezed == discountValue
          ? _value.discountValue
          : discountValue // ignore: cast_nullable_to_non_nullable
              as String?,
      termsAndConditions: freezed == termsAndConditions
          ? _value.termsAndConditions
          : termsAndConditions // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      detailedDescription: freezed == detailedDescription
          ? _value.detailedDescription
          : detailedDescription // ignore: cast_nullable_to_non_nullable
              as String?,
      howToApply: freezed == howToApply
          ? _value.howToApply
          : howToApply // ignore: cast_nullable_to_non_nullable
              as String?,
      footerNote: freezed == footerNote
          ? _value.footerNote
          : footerNote // ignore: cast_nullable_to_non_nullable
              as String?,
      isExpired: freezed == isExpired
          ? _value.isExpired
          : isExpired // ignore: cast_nullable_to_non_nullable
              as bool?,
      isActive: freezed == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool?,
      validUntil: freezed == validUntil
          ? _value.validUntil
          : validUntil // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CouponCardDataImplCopyWith<$Res>
    implements $CouponCardDataCopyWith<$Res> {
  factory _$$CouponCardDataImplCopyWith(_$CouponCardDataImpl value,
          $Res Function(_$CouponCardDataImpl) then) =
      __$$CouponCardDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? id,
      String? title,
      String? description,
      @JsonKey(name: 'image_path') String? imagePath,
      List<String>? gradient,
      @JsonKey(name: 'text_colour') String? textColour,
      String? code,
      @JsonKey(name: 'discount_type') String? discountType,
      @JsonKey(name: 'discount_value') String? discountValue,
      @JsonKey(name: 'terms_and_conditions') List<String>? termsAndConditions,
      @JsonKey(name: 'detailed_description') String? detailedDescription,
      @JsonKey(name: 'how_to_apply') String? howToApply,
      @JsonKey(name: 'footer_note') String? footerNote,
      @JsonKey(name: 'is_expired') bool? isExpired,
      @JsonKey(name: 'is_active') bool? isActive,
      @JsonKey(name: 'valid_until') String? validUntil});
}

/// @nodoc
class __$$CouponCardDataImplCopyWithImpl<$Res>
    extends _$CouponCardDataCopyWithImpl<$Res, _$CouponCardDataImpl>
    implements _$$CouponCardDataImplCopyWith<$Res> {
  __$$CouponCardDataImplCopyWithImpl(
      _$CouponCardDataImpl _value, $Res Function(_$CouponCardDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? title = freezed,
    Object? description = freezed,
    Object? imagePath = freezed,
    Object? gradient = freezed,
    Object? textColour = freezed,
    Object? code = freezed,
    Object? discountType = freezed,
    Object? discountValue = freezed,
    Object? termsAndConditions = freezed,
    Object? detailedDescription = freezed,
    Object? howToApply = freezed,
    Object? footerNote = freezed,
    Object? isExpired = freezed,
    Object? isActive = freezed,
    Object? validUntil = freezed,
  }) {
    return _then(_$CouponCardDataImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      imagePath: freezed == imagePath
          ? _value.imagePath
          : imagePath // ignore: cast_nullable_to_non_nullable
              as String?,
      gradient: freezed == gradient
          ? _value._gradient
          : gradient // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      textColour: freezed == textColour
          ? _value.textColour
          : textColour // ignore: cast_nullable_to_non_nullable
              as String?,
      code: freezed == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String?,
      discountType: freezed == discountType
          ? _value.discountType
          : discountType // ignore: cast_nullable_to_non_nullable
              as String?,
      discountValue: freezed == discountValue
          ? _value.discountValue
          : discountValue // ignore: cast_nullable_to_non_nullable
              as String?,
      termsAndConditions: freezed == termsAndConditions
          ? _value._termsAndConditions
          : termsAndConditions // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      detailedDescription: freezed == detailedDescription
          ? _value.detailedDescription
          : detailedDescription // ignore: cast_nullable_to_non_nullable
              as String?,
      howToApply: freezed == howToApply
          ? _value.howToApply
          : howToApply // ignore: cast_nullable_to_non_nullable
              as String?,
      footerNote: freezed == footerNote
          ? _value.footerNote
          : footerNote // ignore: cast_nullable_to_non_nullable
              as String?,
      isExpired: freezed == isExpired
          ? _value.isExpired
          : isExpired // ignore: cast_nullable_to_non_nullable
              as bool?,
      isActive: freezed == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool?,
      validUntil: freezed == validUntil
          ? _value.validUntil
          : validUntil // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CouponCardDataImpl implements _CouponCardData {
  const _$CouponCardDataImpl(
      {this.id,
      this.title,
      this.description,
      @JsonKey(name: 'image_path') this.imagePath,
      final List<String>? gradient,
      @JsonKey(name: 'text_colour') this.textColour,
      this.code,
      @JsonKey(name: 'discount_type') this.discountType,
      @JsonKey(name: 'discount_value') this.discountValue,
      @JsonKey(name: 'terms_and_conditions')
      final List<String>? termsAndConditions,
      @JsonKey(name: 'detailed_description') this.detailedDescription,
      @JsonKey(name: 'how_to_apply') this.howToApply,
      @JsonKey(name: 'footer_note') this.footerNote,
      @JsonKey(name: 'is_expired') this.isExpired,
      @JsonKey(name: 'is_active') this.isActive,
      @JsonKey(name: 'valid_until') this.validUntil})
      : _gradient = gradient,
        _termsAndConditions = termsAndConditions;

  factory _$CouponCardDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$CouponCardDataImplFromJson(json);

  @override
  final int? id;
  @override
  final String? title;
  @override
  final String? description;
  @override
  @JsonKey(name: 'image_path')
  final String? imagePath;
  final List<String>? _gradient;
  @override
  List<String>? get gradient {
    final value = _gradient;
    if (value == null) return null;
    if (_gradient is EqualUnmodifiableListView) return _gradient;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'text_colour')
  final String? textColour;
  @override
  final String? code;
  @override
  @JsonKey(name: 'discount_type')
  final String? discountType;
  @override
  @JsonKey(name: 'discount_value')
  final String? discountValue;
  final List<String>? _termsAndConditions;
  @override
  @JsonKey(name: 'terms_and_conditions')
  List<String>? get termsAndConditions {
    final value = _termsAndConditions;
    if (value == null) return null;
    if (_termsAndConditions is EqualUnmodifiableListView)
      return _termsAndConditions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  /// Detailed marketing description (e.g. "Trekking is better with friends…")
  @override
  @JsonKey(name: 'detailed_description')
  final String? detailedDescription;

  /// Plain-text instructions on how to redeem the coupon
  @override
  @JsonKey(name: 'how_to_apply')
  final String? howToApply;

  /// Footer note shown at the bottom of the T&C modal
  @override
  @JsonKey(name: 'footer_note')
  final String? footerNote;
  @override
  @JsonKey(name: 'is_expired')
  final bool? isExpired;
  @override
  @JsonKey(name: 'is_active')
  final bool? isActive;
  @override
  @JsonKey(name: 'valid_until')
  final String? validUntil;

  @override
  String toString() {
    return 'CouponCardData(id: $id, title: $title, description: $description, imagePath: $imagePath, gradient: $gradient, textColour: $textColour, code: $code, discountType: $discountType, discountValue: $discountValue, termsAndConditions: $termsAndConditions, detailedDescription: $detailedDescription, howToApply: $howToApply, footerNote: $footerNote, isExpired: $isExpired, isActive: $isActive, validUntil: $validUntil)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CouponCardDataImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.imagePath, imagePath) ||
                other.imagePath == imagePath) &&
            const DeepCollectionEquality().equals(other._gradient, _gradient) &&
            (identical(other.textColour, textColour) ||
                other.textColour == textColour) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.discountType, discountType) ||
                other.discountType == discountType) &&
            (identical(other.discountValue, discountValue) ||
                other.discountValue == discountValue) &&
            const DeepCollectionEquality()
                .equals(other._termsAndConditions, _termsAndConditions) &&
            (identical(other.detailedDescription, detailedDescription) ||
                other.detailedDescription == detailedDescription) &&
            (identical(other.howToApply, howToApply) ||
                other.howToApply == howToApply) &&
            (identical(other.footerNote, footerNote) ||
                other.footerNote == footerNote) &&
            (identical(other.isExpired, isExpired) ||
                other.isExpired == isExpired) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.validUntil, validUntil) ||
                other.validUntil == validUntil));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      description,
      imagePath,
      const DeepCollectionEquality().hash(_gradient),
      textColour,
      code,
      discountType,
      discountValue,
      const DeepCollectionEquality().hash(_termsAndConditions),
      detailedDescription,
      howToApply,
      footerNote,
      isExpired,
      isActive,
      validUntil);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CouponCardDataImplCopyWith<_$CouponCardDataImpl> get copyWith =>
      __$$CouponCardDataImplCopyWithImpl<_$CouponCardDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CouponCardDataImplToJson(
      this,
    );
  }
}

abstract class _CouponCardData implements CouponCardData {
  const factory _CouponCardData(
      {final int? id,
      final String? title,
      final String? description,
      @JsonKey(name: 'image_path') final String? imagePath,
      final List<String>? gradient,
      @JsonKey(name: 'text_colour') final String? textColour,
      final String? code,
      @JsonKey(name: 'discount_type') final String? discountType,
      @JsonKey(name: 'discount_value') final String? discountValue,
      @JsonKey(name: 'terms_and_conditions')
      final List<String>? termsAndConditions,
      @JsonKey(name: 'detailed_description') final String? detailedDescription,
      @JsonKey(name: 'how_to_apply') final String? howToApply,
      @JsonKey(name: 'footer_note') final String? footerNote,
      @JsonKey(name: 'is_expired') final bool? isExpired,
      @JsonKey(name: 'is_active') final bool? isActive,
      @JsonKey(name: 'valid_until')
      final String? validUntil}) = _$CouponCardDataImpl;

  factory _CouponCardData.fromJson(Map<String, dynamic> json) =
      _$CouponCardDataImpl.fromJson;

  @override
  int? get id;
  @override
  String? get title;
  @override
  String? get description;
  @override
  @JsonKey(name: 'image_path')
  String? get imagePath;
  @override
  List<String>? get gradient;
  @override
  @JsonKey(name: 'text_colour')
  String? get textColour;
  @override
  String? get code;
  @override
  @JsonKey(name: 'discount_type')
  String? get discountType;
  @override
  @JsonKey(name: 'discount_value')
  String? get discountValue;
  @override
  @JsonKey(name: 'terms_and_conditions')
  List<String>? get termsAndConditions;
  @override

  /// Detailed marketing description (e.g. "Trekking is better with friends…")
  @JsonKey(name: 'detailed_description')
  String? get detailedDescription;
  @override

  /// Plain-text instructions on how to redeem the coupon
  @JsonKey(name: 'how_to_apply')
  String? get howToApply;
  @override

  /// Footer note shown at the bottom of the T&C modal
  @JsonKey(name: 'footer_note')
  String? get footerNote;
  @override
  @JsonKey(name: 'is_expired')
  bool? get isExpired;
  @override
  @JsonKey(name: 'is_active')
  bool? get isActive;
  @override
  @JsonKey(name: 'valid_until')
  String? get validUntil;
  @override
  @JsonKey(ignore: true)
  _$$CouponCardDataImplCopyWith<_$CouponCardDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Vendor _$VendorFromJson(Map<String, dynamic> json) {
  return _Vendor.fromJson(json);
}

/// @nodoc
mixin _$Vendor {
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'company_info')
  String? get companyInfo => throw _privateConstructorUsedError;
  String? get status => throw _privateConstructorUsedError;
  User? get user => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $VendorCopyWith<Vendor> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VendorCopyWith<$Res> {
  factory $VendorCopyWith(Vendor value, $Res Function(Vendor) then) =
      _$VendorCopyWithImpl<$Res, Vendor>;
  @useResult
  $Res call(
      {int? id,
      @JsonKey(name: 'company_info') String? companyInfo,
      String? status,
      User? user});

  $UserCopyWith<$Res>? get user;
}

/// @nodoc
class _$VendorCopyWithImpl<$Res, $Val extends Vendor>
    implements $VendorCopyWith<$Res> {
  _$VendorCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? companyInfo = freezed,
    Object? status = freezed,
    Object? user = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      companyInfo: freezed == companyInfo
          ? _value.companyInfo
          : companyInfo // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      user: freezed == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as User?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $UserCopyWith<$Res>? get user {
    if (_value.user == null) {
      return null;
    }

    return $UserCopyWith<$Res>(_value.user!, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$VendorImplCopyWith<$Res> implements $VendorCopyWith<$Res> {
  factory _$$VendorImplCopyWith(
          _$VendorImpl value, $Res Function(_$VendorImpl) then) =
      __$$VendorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? id,
      @JsonKey(name: 'company_info') String? companyInfo,
      String? status,
      User? user});

  @override
  $UserCopyWith<$Res>? get user;
}

/// @nodoc
class __$$VendorImplCopyWithImpl<$Res>
    extends _$VendorCopyWithImpl<$Res, _$VendorImpl>
    implements _$$VendorImplCopyWith<$Res> {
  __$$VendorImplCopyWithImpl(
      _$VendorImpl _value, $Res Function(_$VendorImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? companyInfo = freezed,
    Object? status = freezed,
    Object? user = freezed,
  }) {
    return _then(_$VendorImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      companyInfo: freezed == companyInfo
          ? _value.companyInfo
          : companyInfo // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      user: freezed == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as User?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VendorImpl implements _Vendor {
  const _$VendorImpl(
      {this.id,
      @JsonKey(name: 'company_info') this.companyInfo,
      this.status,
      this.user});

  factory _$VendorImpl.fromJson(Map<String, dynamic> json) =>
      _$$VendorImplFromJson(json);

  @override
  final int? id;
  @override
  @JsonKey(name: 'company_info')
  final String? companyInfo;
  @override
  final String? status;
  @override
  final User? user;

  @override
  String toString() {
    return 'Vendor(id: $id, companyInfo: $companyInfo, status: $status, user: $user)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VendorImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.companyInfo, companyInfo) ||
                other.companyInfo == companyInfo) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.user, user) || other.user == user));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, companyInfo, status, user);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$VendorImplCopyWith<_$VendorImpl> get copyWith =>
      __$$VendorImplCopyWithImpl<_$VendorImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VendorImplToJson(
      this,
    );
  }
}

abstract class _Vendor implements Vendor {
  const factory _Vendor(
      {final int? id,
      @JsonKey(name: 'company_info') final String? companyInfo,
      final String? status,
      final User? user}) = _$VendorImpl;

  factory _Vendor.fromJson(Map<String, dynamic> json) = _$VendorImpl.fromJson;

  @override
  int? get id;
  @override
  @JsonKey(name: 'company_info')
  String? get companyInfo;
  @override
  String? get status;
  @override
  User? get user;
  @override
  @JsonKey(ignore: true)
  _$$VendorImplCopyWith<_$VendorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

User _$UserFromJson(Map<String, dynamic> json) {
  return _User.fromJson(json);
}

/// @nodoc
mixin _$User {
  int? get id => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UserCopyWith<User> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserCopyWith<$Res> {
  factory $UserCopyWith(User value, $Res Function(User) then) =
      _$UserCopyWithImpl<$Res, User>;
  @useResult
  $Res call({int? id, String? name, String? email, String? phone});
}

/// @nodoc
class _$UserCopyWithImpl<$Res, $Val extends User>
    implements $UserCopyWith<$Res> {
  _$UserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? email = freezed,
    Object? phone = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserImplCopyWith<$Res> implements $UserCopyWith<$Res> {
  factory _$$UserImplCopyWith(
          _$UserImpl value, $Res Function(_$UserImpl) then) =
      __$$UserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int? id, String? name, String? email, String? phone});
}

/// @nodoc
class __$$UserImplCopyWithImpl<$Res>
    extends _$UserCopyWithImpl<$Res, _$UserImpl>
    implements _$$UserImplCopyWith<$Res> {
  __$$UserImplCopyWithImpl(_$UserImpl _value, $Res Function(_$UserImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? email = freezed,
    Object? phone = freezed,
  }) {
    return _then(_$UserImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserImpl implements _User {
  const _$UserImpl({this.id, this.name, this.email, this.phone});

  factory _$UserImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserImplFromJson(json);

  @override
  final int? id;
  @override
  final String? name;
  @override
  final String? email;
  @override
  final String? phone;

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, phone: $phone)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phone, phone) || other.phone == phone));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, email, phone);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      __$$UserImplCopyWithImpl<_$UserImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserImplToJson(
      this,
    );
  }
}

abstract class _User implements User {
  const factory _User(
      {final int? id,
      final String? name,
      final String? email,
      final String? phone}) = _$UserImpl;

  factory _User.fromJson(Map<String, dynamic> json) = _$UserImpl.fromJson;

  @override
  int? get id;
  @override
  String? get name;
  @override
  String? get email;
  @override
  String? get phone;
  @override
  @JsonKey(ignore: true)
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

VendorInfo _$VendorInfoFromJson(Map<String, dynamic> json) {
  return _VendorInfo.fromJson(json);
}

/// @nodoc
mixin _$VendorInfo {
  @JsonKey(name: 'vendor_id')
  String? get vendorId => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_coupons')
  int? get totalCoupons => throw _privateConstructorUsedError;
  @JsonKey(name: 'active_coupons')
  int? get activeCoupons => throw _privateConstructorUsedError;
  @JsonKey(name: 'pending_coupons')
  int? get pendingCoupons => throw _privateConstructorUsedError;
  @JsonKey(name: 'approved_coupons')
  int? get approvedCoupons => throw _privateConstructorUsedError;
  @JsonKey(name: 'rejected_coupons')
  int? get rejectedCoupons => throw _privateConstructorUsedError;
  @JsonKey(name: 'expired_coupons')
  int? get expiredCoupons => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $VendorInfoCopyWith<VendorInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VendorInfoCopyWith<$Res> {
  factory $VendorInfoCopyWith(
          VendorInfo value, $Res Function(VendorInfo) then) =
      _$VendorInfoCopyWithImpl<$Res, VendorInfo>;
  @useResult
  $Res call(
      {@JsonKey(name: 'vendor_id') String? vendorId,
      @JsonKey(name: 'total_coupons') int? totalCoupons,
      @JsonKey(name: 'active_coupons') int? activeCoupons,
      @JsonKey(name: 'pending_coupons') int? pendingCoupons,
      @JsonKey(name: 'approved_coupons') int? approvedCoupons,
      @JsonKey(name: 'rejected_coupons') int? rejectedCoupons,
      @JsonKey(name: 'expired_coupons') int? expiredCoupons});
}

/// @nodoc
class _$VendorInfoCopyWithImpl<$Res, $Val extends VendorInfo>
    implements $VendorInfoCopyWith<$Res> {
  _$VendorInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? vendorId = freezed,
    Object? totalCoupons = freezed,
    Object? activeCoupons = freezed,
    Object? pendingCoupons = freezed,
    Object? approvedCoupons = freezed,
    Object? rejectedCoupons = freezed,
    Object? expiredCoupons = freezed,
  }) {
    return _then(_value.copyWith(
      vendorId: freezed == vendorId
          ? _value.vendorId
          : vendorId // ignore: cast_nullable_to_non_nullable
              as String?,
      totalCoupons: freezed == totalCoupons
          ? _value.totalCoupons
          : totalCoupons // ignore: cast_nullable_to_non_nullable
              as int?,
      activeCoupons: freezed == activeCoupons
          ? _value.activeCoupons
          : activeCoupons // ignore: cast_nullable_to_non_nullable
              as int?,
      pendingCoupons: freezed == pendingCoupons
          ? _value.pendingCoupons
          : pendingCoupons // ignore: cast_nullable_to_non_nullable
              as int?,
      approvedCoupons: freezed == approvedCoupons
          ? _value.approvedCoupons
          : approvedCoupons // ignore: cast_nullable_to_non_nullable
              as int?,
      rejectedCoupons: freezed == rejectedCoupons
          ? _value.rejectedCoupons
          : rejectedCoupons // ignore: cast_nullable_to_non_nullable
              as int?,
      expiredCoupons: freezed == expiredCoupons
          ? _value.expiredCoupons
          : expiredCoupons // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VendorInfoImplCopyWith<$Res>
    implements $VendorInfoCopyWith<$Res> {
  factory _$$VendorInfoImplCopyWith(
          _$VendorInfoImpl value, $Res Function(_$VendorInfoImpl) then) =
      __$$VendorInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'vendor_id') String? vendorId,
      @JsonKey(name: 'total_coupons') int? totalCoupons,
      @JsonKey(name: 'active_coupons') int? activeCoupons,
      @JsonKey(name: 'pending_coupons') int? pendingCoupons,
      @JsonKey(name: 'approved_coupons') int? approvedCoupons,
      @JsonKey(name: 'rejected_coupons') int? rejectedCoupons,
      @JsonKey(name: 'expired_coupons') int? expiredCoupons});
}

/// @nodoc
class __$$VendorInfoImplCopyWithImpl<$Res>
    extends _$VendorInfoCopyWithImpl<$Res, _$VendorInfoImpl>
    implements _$$VendorInfoImplCopyWith<$Res> {
  __$$VendorInfoImplCopyWithImpl(
      _$VendorInfoImpl _value, $Res Function(_$VendorInfoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? vendorId = freezed,
    Object? totalCoupons = freezed,
    Object? activeCoupons = freezed,
    Object? pendingCoupons = freezed,
    Object? approvedCoupons = freezed,
    Object? rejectedCoupons = freezed,
    Object? expiredCoupons = freezed,
  }) {
    return _then(_$VendorInfoImpl(
      vendorId: freezed == vendorId
          ? _value.vendorId
          : vendorId // ignore: cast_nullable_to_non_nullable
              as String?,
      totalCoupons: freezed == totalCoupons
          ? _value.totalCoupons
          : totalCoupons // ignore: cast_nullable_to_non_nullable
              as int?,
      activeCoupons: freezed == activeCoupons
          ? _value.activeCoupons
          : activeCoupons // ignore: cast_nullable_to_non_nullable
              as int?,
      pendingCoupons: freezed == pendingCoupons
          ? _value.pendingCoupons
          : pendingCoupons // ignore: cast_nullable_to_non_nullable
              as int?,
      approvedCoupons: freezed == approvedCoupons
          ? _value.approvedCoupons
          : approvedCoupons // ignore: cast_nullable_to_non_nullable
              as int?,
      rejectedCoupons: freezed == rejectedCoupons
          ? _value.rejectedCoupons
          : rejectedCoupons // ignore: cast_nullable_to_non_nullable
              as int?,
      expiredCoupons: freezed == expiredCoupons
          ? _value.expiredCoupons
          : expiredCoupons // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VendorInfoImpl implements _VendorInfo {
  const _$VendorInfoImpl(
      {@JsonKey(name: 'vendor_id') this.vendorId,
      @JsonKey(name: 'total_coupons') this.totalCoupons,
      @JsonKey(name: 'active_coupons') this.activeCoupons,
      @JsonKey(name: 'pending_coupons') this.pendingCoupons,
      @JsonKey(name: 'approved_coupons') this.approvedCoupons,
      @JsonKey(name: 'rejected_coupons') this.rejectedCoupons,
      @JsonKey(name: 'expired_coupons') this.expiredCoupons});

  factory _$VendorInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$VendorInfoImplFromJson(json);

  @override
  @JsonKey(name: 'vendor_id')
  final String? vendorId;
  @override
  @JsonKey(name: 'total_coupons')
  final int? totalCoupons;
  @override
  @JsonKey(name: 'active_coupons')
  final int? activeCoupons;
  @override
  @JsonKey(name: 'pending_coupons')
  final int? pendingCoupons;
  @override
  @JsonKey(name: 'approved_coupons')
  final int? approvedCoupons;
  @override
  @JsonKey(name: 'rejected_coupons')
  final int? rejectedCoupons;
  @override
  @JsonKey(name: 'expired_coupons')
  final int? expiredCoupons;

  @override
  String toString() {
    return 'VendorInfo(vendorId: $vendorId, totalCoupons: $totalCoupons, activeCoupons: $activeCoupons, pendingCoupons: $pendingCoupons, approvedCoupons: $approvedCoupons, rejectedCoupons: $rejectedCoupons, expiredCoupons: $expiredCoupons)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VendorInfoImpl &&
            (identical(other.vendorId, vendorId) ||
                other.vendorId == vendorId) &&
            (identical(other.totalCoupons, totalCoupons) ||
                other.totalCoupons == totalCoupons) &&
            (identical(other.activeCoupons, activeCoupons) ||
                other.activeCoupons == activeCoupons) &&
            (identical(other.pendingCoupons, pendingCoupons) ||
                other.pendingCoupons == pendingCoupons) &&
            (identical(other.approvedCoupons, approvedCoupons) ||
                other.approvedCoupons == approvedCoupons) &&
            (identical(other.rejectedCoupons, rejectedCoupons) ||
                other.rejectedCoupons == rejectedCoupons) &&
            (identical(other.expiredCoupons, expiredCoupons) ||
                other.expiredCoupons == expiredCoupons));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      vendorId,
      totalCoupons,
      activeCoupons,
      pendingCoupons,
      approvedCoupons,
      rejectedCoupons,
      expiredCoupons);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$VendorInfoImplCopyWith<_$VendorInfoImpl> get copyWith =>
      __$$VendorInfoImplCopyWithImpl<_$VendorInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VendorInfoImplToJson(
      this,
    );
  }
}

abstract class _VendorInfo implements VendorInfo {
  const factory _VendorInfo(
          {@JsonKey(name: 'vendor_id') final String? vendorId,
          @JsonKey(name: 'total_coupons') final int? totalCoupons,
          @JsonKey(name: 'active_coupons') final int? activeCoupons,
          @JsonKey(name: 'pending_coupons') final int? pendingCoupons,
          @JsonKey(name: 'approved_coupons') final int? approvedCoupons,
          @JsonKey(name: 'rejected_coupons') final int? rejectedCoupons,
          @JsonKey(name: 'expired_coupons') final int? expiredCoupons}) =
      _$VendorInfoImpl;

  factory _VendorInfo.fromJson(Map<String, dynamic> json) =
      _$VendorInfoImpl.fromJson;

  @override
  @JsonKey(name: 'vendor_id')
  String? get vendorId;
  @override
  @JsonKey(name: 'total_coupons')
  int? get totalCoupons;
  @override
  @JsonKey(name: 'active_coupons')
  int? get activeCoupons;
  @override
  @JsonKey(name: 'pending_coupons')
  int? get pendingCoupons;
  @override
  @JsonKey(name: 'approved_coupons')
  int? get approvedCoupons;
  @override
  @JsonKey(name: 'rejected_coupons')
  int? get rejectedCoupons;
  @override
  @JsonKey(name: 'expired_coupons')
  int? get expiredCoupons;
  @override
  @JsonKey(ignore: true)
  _$$VendorInfoImplCopyWith<_$VendorInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
