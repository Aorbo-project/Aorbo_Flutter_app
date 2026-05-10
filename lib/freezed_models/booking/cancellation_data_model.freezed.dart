// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cancellation_data_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

RequestCancellationResponseModel _$RequestCancellationResponseModelFromJson(
    Map<String, dynamic> json) {
  return _RequestCancellationResponseModel.fromJson(json);
}

/// @nodoc
mixin _$RequestCancellationResponseModel {
  bool? get success => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RequestCancellationResponseModelCopyWith<RequestCancellationResponseModel>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RequestCancellationResponseModelCopyWith<$Res> {
  factory $RequestCancellationResponseModelCopyWith(
          RequestCancellationResponseModel value,
          $Res Function(RequestCancellationResponseModel) then) =
      _$RequestCancellationResponseModelCopyWithImpl<$Res,
          RequestCancellationResponseModel>;
  @useResult
  $Res call({bool? success, String? message});
}

/// @nodoc
class _$RequestCancellationResponseModelCopyWithImpl<$Res,
        $Val extends RequestCancellationResponseModel>
    implements $RequestCancellationResponseModelCopyWith<$Res> {
  _$RequestCancellationResponseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = freezed,
    Object? message = freezed,
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
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RequestCancellationResponseModelImplCopyWith<$Res>
    implements $RequestCancellationResponseModelCopyWith<$Res> {
  factory _$$RequestCancellationResponseModelImplCopyWith(
          _$RequestCancellationResponseModelImpl value,
          $Res Function(_$RequestCancellationResponseModelImpl) then) =
      __$$RequestCancellationResponseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool? success, String? message});
}

/// @nodoc
class __$$RequestCancellationResponseModelImplCopyWithImpl<$Res>
    extends _$RequestCancellationResponseModelCopyWithImpl<$Res,
        _$RequestCancellationResponseModelImpl>
    implements _$$RequestCancellationResponseModelImplCopyWith<$Res> {
  __$$RequestCancellationResponseModelImplCopyWithImpl(
      _$RequestCancellationResponseModelImpl _value,
      $Res Function(_$RequestCancellationResponseModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = freezed,
    Object? message = freezed,
  }) {
    return _then(_$RequestCancellationResponseModelImpl(
      success: freezed == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool?,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RequestCancellationResponseModelImpl
    implements _RequestCancellationResponseModel {
  const _$RequestCancellationResponseModelImpl({this.success, this.message});

  factory _$RequestCancellationResponseModelImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$RequestCancellationResponseModelImplFromJson(json);

  @override
  final bool? success;
  @override
  final String? message;

  @override
  String toString() {
    return 'RequestCancellationResponseModel(success: $success, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RequestCancellationResponseModelImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.message, message) || other.message == message));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, success, message);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RequestCancellationResponseModelImplCopyWith<
          _$RequestCancellationResponseModelImpl>
      get copyWith => __$$RequestCancellationResponseModelImplCopyWithImpl<
          _$RequestCancellationResponseModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RequestCancellationResponseModelImplToJson(
      this,
    );
  }
}

abstract class _RequestCancellationResponseModel
    implements RequestCancellationResponseModel {
  const factory _RequestCancellationResponseModel(
      {final bool? success,
      final String? message}) = _$RequestCancellationResponseModelImpl;

  factory _RequestCancellationResponseModel.fromJson(
          Map<String, dynamic> json) =
      _$RequestCancellationResponseModelImpl.fromJson;

  @override
  bool? get success;
  @override
  String? get message;
  @override
  @JsonKey(ignore: true)
  _$$RequestCancellationResponseModelImplCopyWith<
          _$RequestCancellationResponseModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}

CancellationDetailsResponseModel _$CancellationDetailsResponseModelFromJson(
    Map<String, dynamic> json) {
  return _CancellationDetailsResponseModel.fromJson(json);
}

/// @nodoc
mixin _$CancellationDetailsResponseModel {
  bool? get success => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;
  CancellationDataModel? get data => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CancellationDetailsResponseModelCopyWith<CancellationDetailsResponseModel>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CancellationDetailsResponseModelCopyWith<$Res> {
  factory $CancellationDetailsResponseModelCopyWith(
          CancellationDetailsResponseModel value,
          $Res Function(CancellationDetailsResponseModel) then) =
      _$CancellationDetailsResponseModelCopyWithImpl<$Res,
          CancellationDetailsResponseModel>;
  @useResult
  $Res call({bool? success, String? message, CancellationDataModel? data});

  $CancellationDataModelCopyWith<$Res>? get data;
}

/// @nodoc
class _$CancellationDetailsResponseModelCopyWithImpl<$Res,
        $Val extends CancellationDetailsResponseModel>
    implements $CancellationDetailsResponseModelCopyWith<$Res> {
  _$CancellationDetailsResponseModelCopyWithImpl(this._value, this._then);

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
              as CancellationDataModel?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $CancellationDataModelCopyWith<$Res>? get data {
    if (_value.data == null) {
      return null;
    }

    return $CancellationDataModelCopyWith<$Res>(_value.data!, (value) {
      return _then(_value.copyWith(data: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CancellationDetailsResponseModelImplCopyWith<$Res>
    implements $CancellationDetailsResponseModelCopyWith<$Res> {
  factory _$$CancellationDetailsResponseModelImplCopyWith(
          _$CancellationDetailsResponseModelImpl value,
          $Res Function(_$CancellationDetailsResponseModelImpl) then) =
      __$$CancellationDetailsResponseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool? success, String? message, CancellationDataModel? data});

  @override
  $CancellationDataModelCopyWith<$Res>? get data;
}

/// @nodoc
class __$$CancellationDetailsResponseModelImplCopyWithImpl<$Res>
    extends _$CancellationDetailsResponseModelCopyWithImpl<$Res,
        _$CancellationDetailsResponseModelImpl>
    implements _$$CancellationDetailsResponseModelImplCopyWith<$Res> {
  __$$CancellationDetailsResponseModelImplCopyWithImpl(
      _$CancellationDetailsResponseModelImpl _value,
      $Res Function(_$CancellationDetailsResponseModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = freezed,
    Object? message = freezed,
    Object? data = freezed,
  }) {
    return _then(_$CancellationDetailsResponseModelImpl(
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
              as CancellationDataModel?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CancellationDetailsResponseModelImpl
    implements _CancellationDetailsResponseModel {
  const _$CancellationDetailsResponseModelImpl(
      {this.success, this.message, this.data});

  factory _$CancellationDetailsResponseModelImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$CancellationDetailsResponseModelImplFromJson(json);

  @override
  final bool? success;
  @override
  final String? message;
  @override
  final CancellationDataModel? data;

  @override
  String toString() {
    return 'CancellationDetailsResponseModel(success: $success, message: $message, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CancellationDetailsResponseModelImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.data, data) || other.data == data));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, success, message, data);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CancellationDetailsResponseModelImplCopyWith<
          _$CancellationDetailsResponseModelImpl>
      get copyWith => __$$CancellationDetailsResponseModelImplCopyWithImpl<
          _$CancellationDetailsResponseModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CancellationDetailsResponseModelImplToJson(
      this,
    );
  }
}

abstract class _CancellationDetailsResponseModel
    implements CancellationDetailsResponseModel {
  const factory _CancellationDetailsResponseModel(
          {final bool? success,
          final String? message,
          final CancellationDataModel? data}) =
      _$CancellationDetailsResponseModelImpl;

  factory _CancellationDetailsResponseModel.fromJson(
          Map<String, dynamic> json) =
      _$CancellationDetailsResponseModelImpl.fromJson;

  @override
  bool? get success;
  @override
  String? get message;
  @override
  CancellationDataModel? get data;
  @override
  @JsonKey(ignore: true)
  _$$CancellationDetailsResponseModelImplCopyWith<
          _$CancellationDetailsResponseModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}

CancellationDataModel _$CancellationDataModelFromJson(
    Map<String, dynamic> json) {
  return _CancellationDataModel.fromJson(json);
}

/// @nodoc
mixin _$CancellationDataModel {
  @JsonKey(name: 'booking_id')
  int? get bookingId => throw _privateConstructorUsedError;
  @JsonKey(name: 'trek_id')
  int? get trekId => throw _privateConstructorUsedError;
  @JsonKey(name: 'batch_id')
  int? get batchId => throw _privateConstructorUsedError;
  @JsonKey(name: 'customer_id')
  int? get customerId => throw _privateConstructorUsedError;
  @JsonKey(name: 'customer_name')
  String? get customerName => throw _privateConstructorUsedError;
  @JsonKey(name: 'final_amount')
  double? get finalAmount => throw _privateConstructorUsedError;
  @JsonKey(name: 'advance_amount')
  int? get advanceAmount => throw _privateConstructorUsedError;
  @JsonKey(name: 'cancellation_policy_id')
  int? get cancellationPolicyId => throw _privateConstructorUsedError;
  @JsonKey(name: 'cancellation_policy_name')
  String? get cancellationPolicyName => throw _privateConstructorUsedError;
  @JsonKey(name: 'cancellation_policy_type')
  String? get cancellationPolicyType => throw _privateConstructorUsedError;
  @JsonKey(name: 'current_date')
  DateTime? get currentDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'boarding_date_time')
  DateTime? get boardingDateTime => throw _privateConstructorUsedError;
  @JsonKey(name: 'time_remaining_hours')
  double? get timeRemainingHours => throw _privateConstructorUsedError;
  @JsonKey(name: 'can_cancel')
  bool? get canCancel => throw _privateConstructorUsedError;
  @JsonKey(name: 'cancellation_message')
  dynamic get cancellationMessage => throw _privateConstructorUsedError;
  @JsonKey(name: 'refund_calculation')
  RefundCalculation? get refundCalculation =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'trek_details')
  TrekDetails? get trekDetails => throw _privateConstructorUsedError;
  @JsonKey(name: 'batch_details')
  BatchDetails? get batchDetails => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CancellationDataModelCopyWith<CancellationDataModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CancellationDataModelCopyWith<$Res> {
  factory $CancellationDataModelCopyWith(CancellationDataModel value,
          $Res Function(CancellationDataModel) then) =
      _$CancellationDataModelCopyWithImpl<$Res, CancellationDataModel>;
  @useResult
  $Res call(
      {@JsonKey(name: 'booking_id') int? bookingId,
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
      @JsonKey(name: 'batch_details') BatchDetails? batchDetails});

  $RefundCalculationCopyWith<$Res>? get refundCalculation;
  $TrekDetailsCopyWith<$Res>? get trekDetails;
  $BatchDetailsCopyWith<$Res>? get batchDetails;
}

/// @nodoc
class _$CancellationDataModelCopyWithImpl<$Res,
        $Val extends CancellationDataModel>
    implements $CancellationDataModelCopyWith<$Res> {
  _$CancellationDataModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bookingId = freezed,
    Object? trekId = freezed,
    Object? batchId = freezed,
    Object? customerId = freezed,
    Object? customerName = freezed,
    Object? finalAmount = freezed,
    Object? advanceAmount = freezed,
    Object? cancellationPolicyId = freezed,
    Object? cancellationPolicyName = freezed,
    Object? cancellationPolicyType = freezed,
    Object? currentDate = freezed,
    Object? boardingDateTime = freezed,
    Object? timeRemainingHours = freezed,
    Object? canCancel = freezed,
    Object? cancellationMessage = freezed,
    Object? refundCalculation = freezed,
    Object? trekDetails = freezed,
    Object? batchDetails = freezed,
  }) {
    return _then(_value.copyWith(
      bookingId: freezed == bookingId
          ? _value.bookingId
          : bookingId // ignore: cast_nullable_to_non_nullable
              as int?,
      trekId: freezed == trekId
          ? _value.trekId
          : trekId // ignore: cast_nullable_to_non_nullable
              as int?,
      batchId: freezed == batchId
          ? _value.batchId
          : batchId // ignore: cast_nullable_to_non_nullable
              as int?,
      customerId: freezed == customerId
          ? _value.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as int?,
      customerName: freezed == customerName
          ? _value.customerName
          : customerName // ignore: cast_nullable_to_non_nullable
              as String?,
      finalAmount: freezed == finalAmount
          ? _value.finalAmount
          : finalAmount // ignore: cast_nullable_to_non_nullable
              as double?,
      advanceAmount: freezed == advanceAmount
          ? _value.advanceAmount
          : advanceAmount // ignore: cast_nullable_to_non_nullable
              as int?,
      cancellationPolicyId: freezed == cancellationPolicyId
          ? _value.cancellationPolicyId
          : cancellationPolicyId // ignore: cast_nullable_to_non_nullable
              as int?,
      cancellationPolicyName: freezed == cancellationPolicyName
          ? _value.cancellationPolicyName
          : cancellationPolicyName // ignore: cast_nullable_to_non_nullable
              as String?,
      cancellationPolicyType: freezed == cancellationPolicyType
          ? _value.cancellationPolicyType
          : cancellationPolicyType // ignore: cast_nullable_to_non_nullable
              as String?,
      currentDate: freezed == currentDate
          ? _value.currentDate
          : currentDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      boardingDateTime: freezed == boardingDateTime
          ? _value.boardingDateTime
          : boardingDateTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      timeRemainingHours: freezed == timeRemainingHours
          ? _value.timeRemainingHours
          : timeRemainingHours // ignore: cast_nullable_to_non_nullable
              as double?,
      canCancel: freezed == canCancel
          ? _value.canCancel
          : canCancel // ignore: cast_nullable_to_non_nullable
              as bool?,
      cancellationMessage: freezed == cancellationMessage
          ? _value.cancellationMessage
          : cancellationMessage // ignore: cast_nullable_to_non_nullable
              as dynamic,
      refundCalculation: freezed == refundCalculation
          ? _value.refundCalculation
          : refundCalculation // ignore: cast_nullable_to_non_nullable
              as RefundCalculation?,
      trekDetails: freezed == trekDetails
          ? _value.trekDetails
          : trekDetails // ignore: cast_nullable_to_non_nullable
              as TrekDetails?,
      batchDetails: freezed == batchDetails
          ? _value.batchDetails
          : batchDetails // ignore: cast_nullable_to_non_nullable
              as BatchDetails?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $RefundCalculationCopyWith<$Res>? get refundCalculation {
    if (_value.refundCalculation == null) {
      return null;
    }

    return $RefundCalculationCopyWith<$Res>(_value.refundCalculation!, (value) {
      return _then(_value.copyWith(refundCalculation: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $TrekDetailsCopyWith<$Res>? get trekDetails {
    if (_value.trekDetails == null) {
      return null;
    }

    return $TrekDetailsCopyWith<$Res>(_value.trekDetails!, (value) {
      return _then(_value.copyWith(trekDetails: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $BatchDetailsCopyWith<$Res>? get batchDetails {
    if (_value.batchDetails == null) {
      return null;
    }

    return $BatchDetailsCopyWith<$Res>(_value.batchDetails!, (value) {
      return _then(_value.copyWith(batchDetails: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CancellationDataModelImplCopyWith<$Res>
    implements $CancellationDataModelCopyWith<$Res> {
  factory _$$CancellationDataModelImplCopyWith(
          _$CancellationDataModelImpl value,
          $Res Function(_$CancellationDataModelImpl) then) =
      __$$CancellationDataModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'booking_id') int? bookingId,
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
      @JsonKey(name: 'batch_details') BatchDetails? batchDetails});

  @override
  $RefundCalculationCopyWith<$Res>? get refundCalculation;
  @override
  $TrekDetailsCopyWith<$Res>? get trekDetails;
  @override
  $BatchDetailsCopyWith<$Res>? get batchDetails;
}

/// @nodoc
class __$$CancellationDataModelImplCopyWithImpl<$Res>
    extends _$CancellationDataModelCopyWithImpl<$Res,
        _$CancellationDataModelImpl>
    implements _$$CancellationDataModelImplCopyWith<$Res> {
  __$$CancellationDataModelImplCopyWithImpl(_$CancellationDataModelImpl _value,
      $Res Function(_$CancellationDataModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bookingId = freezed,
    Object? trekId = freezed,
    Object? batchId = freezed,
    Object? customerId = freezed,
    Object? customerName = freezed,
    Object? finalAmount = freezed,
    Object? advanceAmount = freezed,
    Object? cancellationPolicyId = freezed,
    Object? cancellationPolicyName = freezed,
    Object? cancellationPolicyType = freezed,
    Object? currentDate = freezed,
    Object? boardingDateTime = freezed,
    Object? timeRemainingHours = freezed,
    Object? canCancel = freezed,
    Object? cancellationMessage = freezed,
    Object? refundCalculation = freezed,
    Object? trekDetails = freezed,
    Object? batchDetails = freezed,
  }) {
    return _then(_$CancellationDataModelImpl(
      bookingId: freezed == bookingId
          ? _value.bookingId
          : bookingId // ignore: cast_nullable_to_non_nullable
              as int?,
      trekId: freezed == trekId
          ? _value.trekId
          : trekId // ignore: cast_nullable_to_non_nullable
              as int?,
      batchId: freezed == batchId
          ? _value.batchId
          : batchId // ignore: cast_nullable_to_non_nullable
              as int?,
      customerId: freezed == customerId
          ? _value.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as int?,
      customerName: freezed == customerName
          ? _value.customerName
          : customerName // ignore: cast_nullable_to_non_nullable
              as String?,
      finalAmount: freezed == finalAmount
          ? _value.finalAmount
          : finalAmount // ignore: cast_nullable_to_non_nullable
              as double?,
      advanceAmount: freezed == advanceAmount
          ? _value.advanceAmount
          : advanceAmount // ignore: cast_nullable_to_non_nullable
              as int?,
      cancellationPolicyId: freezed == cancellationPolicyId
          ? _value.cancellationPolicyId
          : cancellationPolicyId // ignore: cast_nullable_to_non_nullable
              as int?,
      cancellationPolicyName: freezed == cancellationPolicyName
          ? _value.cancellationPolicyName
          : cancellationPolicyName // ignore: cast_nullable_to_non_nullable
              as String?,
      cancellationPolicyType: freezed == cancellationPolicyType
          ? _value.cancellationPolicyType
          : cancellationPolicyType // ignore: cast_nullable_to_non_nullable
              as String?,
      currentDate: freezed == currentDate
          ? _value.currentDate
          : currentDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      boardingDateTime: freezed == boardingDateTime
          ? _value.boardingDateTime
          : boardingDateTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      timeRemainingHours: freezed == timeRemainingHours
          ? _value.timeRemainingHours
          : timeRemainingHours // ignore: cast_nullable_to_non_nullable
              as double?,
      canCancel: freezed == canCancel
          ? _value.canCancel
          : canCancel // ignore: cast_nullable_to_non_nullable
              as bool?,
      cancellationMessage: freezed == cancellationMessage
          ? _value.cancellationMessage
          : cancellationMessage // ignore: cast_nullable_to_non_nullable
              as dynamic,
      refundCalculation: freezed == refundCalculation
          ? _value.refundCalculation
          : refundCalculation // ignore: cast_nullable_to_non_nullable
              as RefundCalculation?,
      trekDetails: freezed == trekDetails
          ? _value.trekDetails
          : trekDetails // ignore: cast_nullable_to_non_nullable
              as TrekDetails?,
      batchDetails: freezed == batchDetails
          ? _value.batchDetails
          : batchDetails // ignore: cast_nullable_to_non_nullable
              as BatchDetails?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CancellationDataModelImpl implements _CancellationDataModel {
  const _$CancellationDataModelImpl(
      {@JsonKey(name: 'booking_id') this.bookingId,
      @JsonKey(name: 'trek_id') this.trekId,
      @JsonKey(name: 'batch_id') this.batchId,
      @JsonKey(name: 'customer_id') this.customerId,
      @JsonKey(name: 'customer_name') this.customerName,
      @JsonKey(name: 'final_amount') this.finalAmount,
      @JsonKey(name: 'advance_amount') this.advanceAmount,
      @JsonKey(name: 'cancellation_policy_id') this.cancellationPolicyId,
      @JsonKey(name: 'cancellation_policy_name') this.cancellationPolicyName,
      @JsonKey(name: 'cancellation_policy_type') this.cancellationPolicyType,
      @JsonKey(name: 'current_date') this.currentDate,
      @JsonKey(name: 'boarding_date_time') this.boardingDateTime,
      @JsonKey(name: 'time_remaining_hours') this.timeRemainingHours,
      @JsonKey(name: 'can_cancel') this.canCancel,
      @JsonKey(name: 'cancellation_message') this.cancellationMessage,
      @JsonKey(name: 'refund_calculation') this.refundCalculation,
      @JsonKey(name: 'trek_details') this.trekDetails,
      @JsonKey(name: 'batch_details') this.batchDetails});

  factory _$CancellationDataModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$CancellationDataModelImplFromJson(json);

  @override
  @JsonKey(name: 'booking_id')
  final int? bookingId;
  @override
  @JsonKey(name: 'trek_id')
  final int? trekId;
  @override
  @JsonKey(name: 'batch_id')
  final int? batchId;
  @override
  @JsonKey(name: 'customer_id')
  final int? customerId;
  @override
  @JsonKey(name: 'customer_name')
  final String? customerName;
  @override
  @JsonKey(name: 'final_amount')
  final double? finalAmount;
  @override
  @JsonKey(name: 'advance_amount')
  final int? advanceAmount;
  @override
  @JsonKey(name: 'cancellation_policy_id')
  final int? cancellationPolicyId;
  @override
  @JsonKey(name: 'cancellation_policy_name')
  final String? cancellationPolicyName;
  @override
  @JsonKey(name: 'cancellation_policy_type')
  final String? cancellationPolicyType;
  @override
  @JsonKey(name: 'current_date')
  final DateTime? currentDate;
  @override
  @JsonKey(name: 'boarding_date_time')
  final DateTime? boardingDateTime;
  @override
  @JsonKey(name: 'time_remaining_hours')
  final double? timeRemainingHours;
  @override
  @JsonKey(name: 'can_cancel')
  final bool? canCancel;
  @override
  @JsonKey(name: 'cancellation_message')
  final dynamic cancellationMessage;
  @override
  @JsonKey(name: 'refund_calculation')
  final RefundCalculation? refundCalculation;
  @override
  @JsonKey(name: 'trek_details')
  final TrekDetails? trekDetails;
  @override
  @JsonKey(name: 'batch_details')
  final BatchDetails? batchDetails;

  @override
  String toString() {
    return 'CancellationDataModel(bookingId: $bookingId, trekId: $trekId, batchId: $batchId, customerId: $customerId, customerName: $customerName, finalAmount: $finalAmount, advanceAmount: $advanceAmount, cancellationPolicyId: $cancellationPolicyId, cancellationPolicyName: $cancellationPolicyName, cancellationPolicyType: $cancellationPolicyType, currentDate: $currentDate, boardingDateTime: $boardingDateTime, timeRemainingHours: $timeRemainingHours, canCancel: $canCancel, cancellationMessage: $cancellationMessage, refundCalculation: $refundCalculation, trekDetails: $trekDetails, batchDetails: $batchDetails)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CancellationDataModelImpl &&
            (identical(other.bookingId, bookingId) ||
                other.bookingId == bookingId) &&
            (identical(other.trekId, trekId) || other.trekId == trekId) &&
            (identical(other.batchId, batchId) || other.batchId == batchId) &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.finalAmount, finalAmount) ||
                other.finalAmount == finalAmount) &&
            (identical(other.advanceAmount, advanceAmount) ||
                other.advanceAmount == advanceAmount) &&
            (identical(other.cancellationPolicyId, cancellationPolicyId) ||
                other.cancellationPolicyId == cancellationPolicyId) &&
            (identical(other.cancellationPolicyName, cancellationPolicyName) ||
                other.cancellationPolicyName == cancellationPolicyName) &&
            (identical(other.cancellationPolicyType, cancellationPolicyType) ||
                other.cancellationPolicyType == cancellationPolicyType) &&
            (identical(other.currentDate, currentDate) ||
                other.currentDate == currentDate) &&
            (identical(other.boardingDateTime, boardingDateTime) ||
                other.boardingDateTime == boardingDateTime) &&
            (identical(other.timeRemainingHours, timeRemainingHours) ||
                other.timeRemainingHours == timeRemainingHours) &&
            (identical(other.canCancel, canCancel) ||
                other.canCancel == canCancel) &&
            const DeepCollectionEquality()
                .equals(other.cancellationMessage, cancellationMessage) &&
            (identical(other.refundCalculation, refundCalculation) ||
                other.refundCalculation == refundCalculation) &&
            (identical(other.trekDetails, trekDetails) ||
                other.trekDetails == trekDetails) &&
            (identical(other.batchDetails, batchDetails) ||
                other.batchDetails == batchDetails));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      bookingId,
      trekId,
      batchId,
      customerId,
      customerName,
      finalAmount,
      advanceAmount,
      cancellationPolicyId,
      cancellationPolicyName,
      cancellationPolicyType,
      currentDate,
      boardingDateTime,
      timeRemainingHours,
      canCancel,
      const DeepCollectionEquality().hash(cancellationMessage),
      refundCalculation,
      trekDetails,
      batchDetails);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CancellationDataModelImplCopyWith<_$CancellationDataModelImpl>
      get copyWith => __$$CancellationDataModelImplCopyWithImpl<
          _$CancellationDataModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CancellationDataModelImplToJson(
      this,
    );
  }
}

abstract class _CancellationDataModel implements CancellationDataModel {
  const factory _CancellationDataModel(
      {@JsonKey(name: 'booking_id') final int? bookingId,
      @JsonKey(name: 'trek_id') final int? trekId,
      @JsonKey(name: 'batch_id') final int? batchId,
      @JsonKey(name: 'customer_id') final int? customerId,
      @JsonKey(name: 'customer_name') final String? customerName,
      @JsonKey(name: 'final_amount') final double? finalAmount,
      @JsonKey(name: 'advance_amount') final int? advanceAmount,
      @JsonKey(name: 'cancellation_policy_id') final int? cancellationPolicyId,
      @JsonKey(name: 'cancellation_policy_name')
      final String? cancellationPolicyName,
      @JsonKey(name: 'cancellation_policy_type')
      final String? cancellationPolicyType,
      @JsonKey(name: 'current_date') final DateTime? currentDate,
      @JsonKey(name: 'boarding_date_time') final DateTime? boardingDateTime,
      @JsonKey(name: 'time_remaining_hours') final double? timeRemainingHours,
      @JsonKey(name: 'can_cancel') final bool? canCancel,
      @JsonKey(name: 'cancellation_message') final dynamic cancellationMessage,
      @JsonKey(name: 'refund_calculation')
      final RefundCalculation? refundCalculation,
      @JsonKey(name: 'trek_details') final TrekDetails? trekDetails,
      @JsonKey(name: 'batch_details')
      final BatchDetails? batchDetails}) = _$CancellationDataModelImpl;

  factory _CancellationDataModel.fromJson(Map<String, dynamic> json) =
      _$CancellationDataModelImpl.fromJson;

  @override
  @JsonKey(name: 'booking_id')
  int? get bookingId;
  @override
  @JsonKey(name: 'trek_id')
  int? get trekId;
  @override
  @JsonKey(name: 'batch_id')
  int? get batchId;
  @override
  @JsonKey(name: 'customer_id')
  int? get customerId;
  @override
  @JsonKey(name: 'customer_name')
  String? get customerName;
  @override
  @JsonKey(name: 'final_amount')
  double? get finalAmount;
  @override
  @JsonKey(name: 'advance_amount')
  int? get advanceAmount;
  @override
  @JsonKey(name: 'cancellation_policy_id')
  int? get cancellationPolicyId;
  @override
  @JsonKey(name: 'cancellation_policy_name')
  String? get cancellationPolicyName;
  @override
  @JsonKey(name: 'cancellation_policy_type')
  String? get cancellationPolicyType;
  @override
  @JsonKey(name: 'current_date')
  DateTime? get currentDate;
  @override
  @JsonKey(name: 'boarding_date_time')
  DateTime? get boardingDateTime;
  @override
  @JsonKey(name: 'time_remaining_hours')
  double? get timeRemainingHours;
  @override
  @JsonKey(name: 'can_cancel')
  bool? get canCancel;
  @override
  @JsonKey(name: 'cancellation_message')
  dynamic get cancellationMessage;
  @override
  @JsonKey(name: 'refund_calculation')
  RefundCalculation? get refundCalculation;
  @override
  @JsonKey(name: 'trek_details')
  TrekDetails? get trekDetails;
  @override
  @JsonKey(name: 'batch_details')
  BatchDetails? get batchDetails;
  @override
  @JsonKey(ignore: true)
  _$$CancellationDataModelImplCopyWith<_$CancellationDataModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}

RefundCalculation _$RefundCalculationFromJson(Map<String, dynamic> json) {
  return _RefundCalculation.fromJson(json);
}

/// @nodoc
mixin _$RefundCalculation {
  double? get refund => throw _privateConstructorUsedError;
  double? get deduction => throw _privateConstructorUsedError;
  @JsonKey(name: 'policy_type')
  String? get policyType => throw _privateConstructorUsedError;
  @JsonKey(name: 'policy_name')
  String? get policyName => throw _privateConstructorUsedError;
  @JsonKey(name: 'time_remaining_hours')
  double? get timeRemainingHours => throw _privateConstructorUsedError;
  @JsonKey(name: 'within_24_hours')
  bool? get within24Hours => throw _privateConstructorUsedError;
  @JsonKey(name: 'free_cancellation')
  bool? get freeCancellation => throw _privateConstructorUsedError;
  @JsonKey(name: 'refund_items')
  List<RefundItem>? get refundItems => throw _privateConstructorUsedError;
  @JsonKey(name: 'lose_items')
  List<LoseItem>? get loseItems => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_final_amount')
  double? get totalFinalAmount => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RefundCalculationCopyWith<RefundCalculation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RefundCalculationCopyWith<$Res> {
  factory $RefundCalculationCopyWith(
          RefundCalculation value, $Res Function(RefundCalculation) then) =
      _$RefundCalculationCopyWithImpl<$Res, RefundCalculation>;
  @useResult
  $Res call(
      {double? refund,
      double? deduction,
      @JsonKey(name: 'policy_type') String? policyType,
      @JsonKey(name: 'policy_name') String? policyName,
      @JsonKey(name: 'time_remaining_hours') double? timeRemainingHours,
      @JsonKey(name: 'within_24_hours') bool? within24Hours,
      @JsonKey(name: 'free_cancellation') bool? freeCancellation,
      @JsonKey(name: 'refund_items') List<RefundItem>? refundItems,
      @JsonKey(name: 'lose_items') List<LoseItem>? loseItems,
      @JsonKey(name: 'total_final_amount') double? totalFinalAmount});
}

/// @nodoc
class _$RefundCalculationCopyWithImpl<$Res, $Val extends RefundCalculation>
    implements $RefundCalculationCopyWith<$Res> {
  _$RefundCalculationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? refund = freezed,
    Object? deduction = freezed,
    Object? policyType = freezed,
    Object? policyName = freezed,
    Object? timeRemainingHours = freezed,
    Object? within24Hours = freezed,
    Object? freeCancellation = freezed,
    Object? refundItems = freezed,
    Object? loseItems = freezed,
    Object? totalFinalAmount = freezed,
  }) {
    return _then(_value.copyWith(
      refund: freezed == refund
          ? _value.refund
          : refund // ignore: cast_nullable_to_non_nullable
              as double?,
      deduction: freezed == deduction
          ? _value.deduction
          : deduction // ignore: cast_nullable_to_non_nullable
              as double?,
      policyType: freezed == policyType
          ? _value.policyType
          : policyType // ignore: cast_nullable_to_non_nullable
              as String?,
      policyName: freezed == policyName
          ? _value.policyName
          : policyName // ignore: cast_nullable_to_non_nullable
              as String?,
      timeRemainingHours: freezed == timeRemainingHours
          ? _value.timeRemainingHours
          : timeRemainingHours // ignore: cast_nullable_to_non_nullable
              as double?,
      within24Hours: freezed == within24Hours
          ? _value.within24Hours
          : within24Hours // ignore: cast_nullable_to_non_nullable
              as bool?,
      freeCancellation: freezed == freeCancellation
          ? _value.freeCancellation
          : freeCancellation // ignore: cast_nullable_to_non_nullable
              as bool?,
      refundItems: freezed == refundItems
          ? _value.refundItems
          : refundItems // ignore: cast_nullable_to_non_nullable
              as List<RefundItem>?,
      loseItems: freezed == loseItems
          ? _value.loseItems
          : loseItems // ignore: cast_nullable_to_non_nullable
              as List<LoseItem>?,
      totalFinalAmount: freezed == totalFinalAmount
          ? _value.totalFinalAmount
          : totalFinalAmount // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RefundCalculationImplCopyWith<$Res>
    implements $RefundCalculationCopyWith<$Res> {
  factory _$$RefundCalculationImplCopyWith(_$RefundCalculationImpl value,
          $Res Function(_$RefundCalculationImpl) then) =
      __$$RefundCalculationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double? refund,
      double? deduction,
      @JsonKey(name: 'policy_type') String? policyType,
      @JsonKey(name: 'policy_name') String? policyName,
      @JsonKey(name: 'time_remaining_hours') double? timeRemainingHours,
      @JsonKey(name: 'within_24_hours') bool? within24Hours,
      @JsonKey(name: 'free_cancellation') bool? freeCancellation,
      @JsonKey(name: 'refund_items') List<RefundItem>? refundItems,
      @JsonKey(name: 'lose_items') List<LoseItem>? loseItems,
      @JsonKey(name: 'total_final_amount') double? totalFinalAmount});
}

/// @nodoc
class __$$RefundCalculationImplCopyWithImpl<$Res>
    extends _$RefundCalculationCopyWithImpl<$Res, _$RefundCalculationImpl>
    implements _$$RefundCalculationImplCopyWith<$Res> {
  __$$RefundCalculationImplCopyWithImpl(_$RefundCalculationImpl _value,
      $Res Function(_$RefundCalculationImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? refund = freezed,
    Object? deduction = freezed,
    Object? policyType = freezed,
    Object? policyName = freezed,
    Object? timeRemainingHours = freezed,
    Object? within24Hours = freezed,
    Object? freeCancellation = freezed,
    Object? refundItems = freezed,
    Object? loseItems = freezed,
    Object? totalFinalAmount = freezed,
  }) {
    return _then(_$RefundCalculationImpl(
      refund: freezed == refund
          ? _value.refund
          : refund // ignore: cast_nullable_to_non_nullable
              as double?,
      deduction: freezed == deduction
          ? _value.deduction
          : deduction // ignore: cast_nullable_to_non_nullable
              as double?,
      policyType: freezed == policyType
          ? _value.policyType
          : policyType // ignore: cast_nullable_to_non_nullable
              as String?,
      policyName: freezed == policyName
          ? _value.policyName
          : policyName // ignore: cast_nullable_to_non_nullable
              as String?,
      timeRemainingHours: freezed == timeRemainingHours
          ? _value.timeRemainingHours
          : timeRemainingHours // ignore: cast_nullable_to_non_nullable
              as double?,
      within24Hours: freezed == within24Hours
          ? _value.within24Hours
          : within24Hours // ignore: cast_nullable_to_non_nullable
              as bool?,
      freeCancellation: freezed == freeCancellation
          ? _value.freeCancellation
          : freeCancellation // ignore: cast_nullable_to_non_nullable
              as bool?,
      refundItems: freezed == refundItems
          ? _value._refundItems
          : refundItems // ignore: cast_nullable_to_non_nullable
              as List<RefundItem>?,
      loseItems: freezed == loseItems
          ? _value._loseItems
          : loseItems // ignore: cast_nullable_to_non_nullable
              as List<LoseItem>?,
      totalFinalAmount: freezed == totalFinalAmount
          ? _value.totalFinalAmount
          : totalFinalAmount // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RefundCalculationImpl implements _RefundCalculation {
  const _$RefundCalculationImpl(
      {this.refund,
      this.deduction,
      @JsonKey(name: 'policy_type') this.policyType,
      @JsonKey(name: 'policy_name') this.policyName,
      @JsonKey(name: 'time_remaining_hours') this.timeRemainingHours,
      @JsonKey(name: 'within_24_hours') this.within24Hours,
      @JsonKey(name: 'free_cancellation') this.freeCancellation,
      @JsonKey(name: 'refund_items') final List<RefundItem>? refundItems,
      @JsonKey(name: 'lose_items') final List<LoseItem>? loseItems,
      @JsonKey(name: 'total_final_amount') this.totalFinalAmount})
      : _refundItems = refundItems,
        _loseItems = loseItems;

  factory _$RefundCalculationImpl.fromJson(Map<String, dynamic> json) =>
      _$$RefundCalculationImplFromJson(json);

  @override
  final double? refund;
  @override
  final double? deduction;
  @override
  @JsonKey(name: 'policy_type')
  final String? policyType;
  @override
  @JsonKey(name: 'policy_name')
  final String? policyName;
  @override
  @JsonKey(name: 'time_remaining_hours')
  final double? timeRemainingHours;
  @override
  @JsonKey(name: 'within_24_hours')
  final bool? within24Hours;
  @override
  @JsonKey(name: 'free_cancellation')
  final bool? freeCancellation;
  final List<RefundItem>? _refundItems;
  @override
  @JsonKey(name: 'refund_items')
  List<RefundItem>? get refundItems {
    final value = _refundItems;
    if (value == null) return null;
    if (_refundItems is EqualUnmodifiableListView) return _refundItems;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<LoseItem>? _loseItems;
  @override
  @JsonKey(name: 'lose_items')
  List<LoseItem>? get loseItems {
    final value = _loseItems;
    if (value == null) return null;
    if (_loseItems is EqualUnmodifiableListView) return _loseItems;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'total_final_amount')
  final double? totalFinalAmount;

  @override
  String toString() {
    return 'RefundCalculation(refund: $refund, deduction: $deduction, policyType: $policyType, policyName: $policyName, timeRemainingHours: $timeRemainingHours, within24Hours: $within24Hours, freeCancellation: $freeCancellation, refundItems: $refundItems, loseItems: $loseItems, totalFinalAmount: $totalFinalAmount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RefundCalculationImpl &&
            (identical(other.refund, refund) || other.refund == refund) &&
            (identical(other.deduction, deduction) ||
                other.deduction == deduction) &&
            (identical(other.policyType, policyType) ||
                other.policyType == policyType) &&
            (identical(other.policyName, policyName) ||
                other.policyName == policyName) &&
            (identical(other.timeRemainingHours, timeRemainingHours) ||
                other.timeRemainingHours == timeRemainingHours) &&
            (identical(other.within24Hours, within24Hours) ||
                other.within24Hours == within24Hours) &&
            (identical(other.freeCancellation, freeCancellation) ||
                other.freeCancellation == freeCancellation) &&
            const DeepCollectionEquality()
                .equals(other._refundItems, _refundItems) &&
            const DeepCollectionEquality()
                .equals(other._loseItems, _loseItems) &&
            (identical(other.totalFinalAmount, totalFinalAmount) ||
                other.totalFinalAmount == totalFinalAmount));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      refund,
      deduction,
      policyType,
      policyName,
      timeRemainingHours,
      within24Hours,
      freeCancellation,
      const DeepCollectionEquality().hash(_refundItems),
      const DeepCollectionEquality().hash(_loseItems),
      totalFinalAmount);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RefundCalculationImplCopyWith<_$RefundCalculationImpl> get copyWith =>
      __$$RefundCalculationImplCopyWithImpl<_$RefundCalculationImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RefundCalculationImplToJson(
      this,
    );
  }
}

abstract class _RefundCalculation implements RefundCalculation {
  const factory _RefundCalculation(
      {final double? refund,
      final double? deduction,
      @JsonKey(name: 'policy_type') final String? policyType,
      @JsonKey(name: 'policy_name') final String? policyName,
      @JsonKey(name: 'time_remaining_hours') final double? timeRemainingHours,
      @JsonKey(name: 'within_24_hours') final bool? within24Hours,
      @JsonKey(name: 'free_cancellation') final bool? freeCancellation,
      @JsonKey(name: 'refund_items') final List<RefundItem>? refundItems,
      @JsonKey(name: 'lose_items') final List<LoseItem>? loseItems,
      @JsonKey(name: 'total_final_amount')
      final double? totalFinalAmount}) = _$RefundCalculationImpl;

  factory _RefundCalculation.fromJson(Map<String, dynamic> json) =
      _$RefundCalculationImpl.fromJson;

  @override
  double? get refund;
  @override
  double? get deduction;
  @override
  @JsonKey(name: 'policy_type')
  String? get policyType;
  @override
  @JsonKey(name: 'policy_name')
  String? get policyName;
  @override
  @JsonKey(name: 'time_remaining_hours')
  double? get timeRemainingHours;
  @override
  @JsonKey(name: 'within_24_hours')
  bool? get within24Hours;
  @override
  @JsonKey(name: 'free_cancellation')
  bool? get freeCancellation;
  @override
  @JsonKey(name: 'refund_items')
  List<RefundItem>? get refundItems;
  @override
  @JsonKey(name: 'lose_items')
  List<LoseItem>? get loseItems;
  @override
  @JsonKey(name: 'total_final_amount')
  double? get totalFinalAmount;
  @override
  @JsonKey(ignore: true)
  _$$RefundCalculationImplCopyWith<_$RefundCalculationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RefundItem _$RefundItemFromJson(Map<String, dynamic> json) {
  return _RefundItem.fromJson(json);
}

/// @nodoc
mixin _$RefundItem {
  String? get item => throw _privateConstructorUsedError;
  double? get amount => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RefundItemCopyWith<RefundItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RefundItemCopyWith<$Res> {
  factory $RefundItemCopyWith(
          RefundItem value, $Res Function(RefundItem) then) =
      _$RefundItemCopyWithImpl<$Res, RefundItem>;
  @useResult
  $Res call({String? item, double? amount});
}

/// @nodoc
class _$RefundItemCopyWithImpl<$Res, $Val extends RefundItem>
    implements $RefundItemCopyWith<$Res> {
  _$RefundItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? item = freezed,
    Object? amount = freezed,
  }) {
    return _then(_value.copyWith(
      item: freezed == item
          ? _value.item
          : item // ignore: cast_nullable_to_non_nullable
              as String?,
      amount: freezed == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RefundItemImplCopyWith<$Res>
    implements $RefundItemCopyWith<$Res> {
  factory _$$RefundItemImplCopyWith(
          _$RefundItemImpl value, $Res Function(_$RefundItemImpl) then) =
      __$$RefundItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? item, double? amount});
}

/// @nodoc
class __$$RefundItemImplCopyWithImpl<$Res>
    extends _$RefundItemCopyWithImpl<$Res, _$RefundItemImpl>
    implements _$$RefundItemImplCopyWith<$Res> {
  __$$RefundItemImplCopyWithImpl(
      _$RefundItemImpl _value, $Res Function(_$RefundItemImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? item = freezed,
    Object? amount = freezed,
  }) {
    return _then(_$RefundItemImpl(
      item: freezed == item
          ? _value.item
          : item // ignore: cast_nullable_to_non_nullable
              as String?,
      amount: freezed == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RefundItemImpl implements _RefundItem {
  const _$RefundItemImpl({this.item, this.amount});

  factory _$RefundItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$RefundItemImplFromJson(json);

  @override
  final String? item;
  @override
  final double? amount;

  @override
  String toString() {
    return 'RefundItem(item: $item, amount: $amount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RefundItemImpl &&
            (identical(other.item, item) || other.item == item) &&
            (identical(other.amount, amount) || other.amount == amount));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, item, amount);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RefundItemImplCopyWith<_$RefundItemImpl> get copyWith =>
      __$$RefundItemImplCopyWithImpl<_$RefundItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RefundItemImplToJson(
      this,
    );
  }
}

abstract class _RefundItem implements RefundItem {
  const factory _RefundItem({final String? item, final double? amount}) =
      _$RefundItemImpl;

  factory _RefundItem.fromJson(Map<String, dynamic> json) =
      _$RefundItemImpl.fromJson;

  @override
  String? get item;
  @override
  double? get amount;
  @override
  @JsonKey(ignore: true)
  _$$RefundItemImplCopyWith<_$RefundItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LoseItem _$LoseItemFromJson(Map<String, dynamic> json) {
  return _LoseItem.fromJson(json);
}

/// @nodoc
mixin _$LoseItem {
  String? get item => throw _privateConstructorUsedError;
  double? get amount => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $LoseItemCopyWith<LoseItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LoseItemCopyWith<$Res> {
  factory $LoseItemCopyWith(LoseItem value, $Res Function(LoseItem) then) =
      _$LoseItemCopyWithImpl<$Res, LoseItem>;
  @useResult
  $Res call({String? item, double? amount});
}

/// @nodoc
class _$LoseItemCopyWithImpl<$Res, $Val extends LoseItem>
    implements $LoseItemCopyWith<$Res> {
  _$LoseItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? item = freezed,
    Object? amount = freezed,
  }) {
    return _then(_value.copyWith(
      item: freezed == item
          ? _value.item
          : item // ignore: cast_nullable_to_non_nullable
              as String?,
      amount: freezed == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LoseItemImplCopyWith<$Res>
    implements $LoseItemCopyWith<$Res> {
  factory _$$LoseItemImplCopyWith(
          _$LoseItemImpl value, $Res Function(_$LoseItemImpl) then) =
      __$$LoseItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? item, double? amount});
}

/// @nodoc
class __$$LoseItemImplCopyWithImpl<$Res>
    extends _$LoseItemCopyWithImpl<$Res, _$LoseItemImpl>
    implements _$$LoseItemImplCopyWith<$Res> {
  __$$LoseItemImplCopyWithImpl(
      _$LoseItemImpl _value, $Res Function(_$LoseItemImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? item = freezed,
    Object? amount = freezed,
  }) {
    return _then(_$LoseItemImpl(
      item: freezed == item
          ? _value.item
          : item // ignore: cast_nullable_to_non_nullable
              as String?,
      amount: freezed == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LoseItemImpl implements _LoseItem {
  const _$LoseItemImpl({this.item, this.amount});

  factory _$LoseItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$LoseItemImplFromJson(json);

  @override
  final String? item;
  @override
  final double? amount;

  @override
  String toString() {
    return 'LoseItem(item: $item, amount: $amount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoseItemImpl &&
            (identical(other.item, item) || other.item == item) &&
            (identical(other.amount, amount) || other.amount == amount));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, item, amount);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LoseItemImplCopyWith<_$LoseItemImpl> get copyWith =>
      __$$LoseItemImplCopyWithImpl<_$LoseItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LoseItemImplToJson(
      this,
    );
  }
}

abstract class _LoseItem implements LoseItem {
  const factory _LoseItem({final String? item, final double? amount}) =
      _$LoseItemImpl;

  factory _LoseItem.fromJson(Map<String, dynamic> json) =
      _$LoseItemImpl.fromJson;

  @override
  String? get item;
  @override
  double? get amount;
  @override
  @JsonKey(ignore: true)
  _$$LoseItemImplCopyWith<_$LoseItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TrekDetails _$TrekDetailsFromJson(Map<String, dynamic> json) {
  return _TrekDetails.fromJson(json);
}

/// @nodoc
mixin _$TrekDetails {
  int? get id => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;
  @JsonKey(name: 'base_price')
  String? get basePrice => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TrekDetailsCopyWith<TrekDetails> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrekDetailsCopyWith<$Res> {
  factory $TrekDetailsCopyWith(
          TrekDetails value, $Res Function(TrekDetails) then) =
      _$TrekDetailsCopyWithImpl<$Res, TrekDetails>;
  @useResult
  $Res call(
      {int? id, String? title, @JsonKey(name: 'base_price') String? basePrice});
}

/// @nodoc
class _$TrekDetailsCopyWithImpl<$Res, $Val extends TrekDetails>
    implements $TrekDetailsCopyWith<$Res> {
  _$TrekDetailsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? title = freezed,
    Object? basePrice = freezed,
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
      basePrice: freezed == basePrice
          ? _value.basePrice
          : basePrice // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TrekDetailsImplCopyWith<$Res>
    implements $TrekDetailsCopyWith<$Res> {
  factory _$$TrekDetailsImplCopyWith(
          _$TrekDetailsImpl value, $Res Function(_$TrekDetailsImpl) then) =
      __$$TrekDetailsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? id, String? title, @JsonKey(name: 'base_price') String? basePrice});
}

/// @nodoc
class __$$TrekDetailsImplCopyWithImpl<$Res>
    extends _$TrekDetailsCopyWithImpl<$Res, _$TrekDetailsImpl>
    implements _$$TrekDetailsImplCopyWith<$Res> {
  __$$TrekDetailsImplCopyWithImpl(
      _$TrekDetailsImpl _value, $Res Function(_$TrekDetailsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? title = freezed,
    Object? basePrice = freezed,
  }) {
    return _then(_$TrekDetailsImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      basePrice: freezed == basePrice
          ? _value.basePrice
          : basePrice // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TrekDetailsImpl implements _TrekDetails {
  const _$TrekDetailsImpl(
      {this.id, this.title, @JsonKey(name: 'base_price') this.basePrice});

  factory _$TrekDetailsImpl.fromJson(Map<String, dynamic> json) =>
      _$$TrekDetailsImplFromJson(json);

  @override
  final int? id;
  @override
  final String? title;
  @override
  @JsonKey(name: 'base_price')
  final String? basePrice;

  @override
  String toString() {
    return 'TrekDetails(id: $id, title: $title, basePrice: $basePrice)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrekDetailsImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.basePrice, basePrice) ||
                other.basePrice == basePrice));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, title, basePrice);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TrekDetailsImplCopyWith<_$TrekDetailsImpl> get copyWith =>
      __$$TrekDetailsImplCopyWithImpl<_$TrekDetailsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TrekDetailsImplToJson(
      this,
    );
  }
}

abstract class _TrekDetails implements TrekDetails {
  const factory _TrekDetails(
          {final int? id,
          final String? title,
          @JsonKey(name: 'base_price') final String? basePrice}) =
      _$TrekDetailsImpl;

  factory _TrekDetails.fromJson(Map<String, dynamic> json) =
      _$TrekDetailsImpl.fromJson;

  @override
  int? get id;
  @override
  String? get title;
  @override
  @JsonKey(name: 'base_price')
  String? get basePrice;
  @override
  @JsonKey(ignore: true)
  _$$TrekDetailsImplCopyWith<_$TrekDetailsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BatchDetails _$BatchDetailsFromJson(Map<String, dynamic> json) {
  return _BatchDetails.fromJson(json);
}

/// @nodoc
mixin _$BatchDetails {
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'tbr_id')
  String? get tbrId => throw _privateConstructorUsedError;
  @JsonKey(name: 'start_date')
  String? get startDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'end_date')
  String? get endDate => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BatchDetailsCopyWith<BatchDetails> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BatchDetailsCopyWith<$Res> {
  factory $BatchDetailsCopyWith(
          BatchDetails value, $Res Function(BatchDetails) then) =
      _$BatchDetailsCopyWithImpl<$Res, BatchDetails>;
  @useResult
  $Res call(
      {int? id,
      @JsonKey(name: 'tbr_id') String? tbrId,
      @JsonKey(name: 'start_date') String? startDate,
      @JsonKey(name: 'end_date') String? endDate});
}

/// @nodoc
class _$BatchDetailsCopyWithImpl<$Res, $Val extends BatchDetails>
    implements $BatchDetailsCopyWith<$Res> {
  _$BatchDetailsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? tbrId = freezed,
    Object? startDate = freezed,
    Object? endDate = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      tbrId: freezed == tbrId
          ? _value.tbrId
          : tbrId // ignore: cast_nullable_to_non_nullable
              as String?,
      startDate: freezed == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as String?,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BatchDetailsImplCopyWith<$Res>
    implements $BatchDetailsCopyWith<$Res> {
  factory _$$BatchDetailsImplCopyWith(
          _$BatchDetailsImpl value, $Res Function(_$BatchDetailsImpl) then) =
      __$$BatchDetailsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? id,
      @JsonKey(name: 'tbr_id') String? tbrId,
      @JsonKey(name: 'start_date') String? startDate,
      @JsonKey(name: 'end_date') String? endDate});
}

/// @nodoc
class __$$BatchDetailsImplCopyWithImpl<$Res>
    extends _$BatchDetailsCopyWithImpl<$Res, _$BatchDetailsImpl>
    implements _$$BatchDetailsImplCopyWith<$Res> {
  __$$BatchDetailsImplCopyWithImpl(
      _$BatchDetailsImpl _value, $Res Function(_$BatchDetailsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? tbrId = freezed,
    Object? startDate = freezed,
    Object? endDate = freezed,
  }) {
    return _then(_$BatchDetailsImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      tbrId: freezed == tbrId
          ? _value.tbrId
          : tbrId // ignore: cast_nullable_to_non_nullable
              as String?,
      startDate: freezed == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as String?,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BatchDetailsImpl implements _BatchDetails {
  const _$BatchDetailsImpl(
      {this.id,
      @JsonKey(name: 'tbr_id') this.tbrId,
      @JsonKey(name: 'start_date') this.startDate,
      @JsonKey(name: 'end_date') this.endDate});

  factory _$BatchDetailsImpl.fromJson(Map<String, dynamic> json) =>
      _$$BatchDetailsImplFromJson(json);

  @override
  final int? id;
  @override
  @JsonKey(name: 'tbr_id')
  final String? tbrId;
  @override
  @JsonKey(name: 'start_date')
  final String? startDate;
  @override
  @JsonKey(name: 'end_date')
  final String? endDate;

  @override
  String toString() {
    return 'BatchDetails(id: $id, tbrId: $tbrId, startDate: $startDate, endDate: $endDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BatchDetailsImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tbrId, tbrId) || other.tbrId == tbrId) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, tbrId, startDate, endDate);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BatchDetailsImplCopyWith<_$BatchDetailsImpl> get copyWith =>
      __$$BatchDetailsImplCopyWithImpl<_$BatchDetailsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BatchDetailsImplToJson(
      this,
    );
  }
}

abstract class _BatchDetails implements BatchDetails {
  const factory _BatchDetails(
      {final int? id,
      @JsonKey(name: 'tbr_id') final String? tbrId,
      @JsonKey(name: 'start_date') final String? startDate,
      @JsonKey(name: 'end_date') final String? endDate}) = _$BatchDetailsImpl;

  factory _BatchDetails.fromJson(Map<String, dynamic> json) =
      _$BatchDetailsImpl.fromJson;

  @override
  int? get id;
  @override
  @JsonKey(name: 'tbr_id')
  String? get tbrId;
  @override
  @JsonKey(name: 'start_date')
  String? get startDate;
  @override
  @JsonKey(name: 'end_date')
  String? get endDate;
  @override
  @JsonKey(ignore: true)
  _$$BatchDetailsImplCopyWith<_$BatchDetailsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
