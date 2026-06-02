// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'booking_history_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

BookingHistoryModel _$BookingHistoryModelFromJson(Map<String, dynamic> json) {
  return _BookingHistoryModel.fromJson(json);
}

/// @nodoc
mixin _$BookingHistoryModel {
  bool? get success => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;
  List<BookingHistoryData>? get data => throw _privateConstructorUsedError;
  Pagination? get pagination => throw _privateConstructorUsedError;
  int? get count => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BookingHistoryModelCopyWith<BookingHistoryModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BookingHistoryModelCopyWith<$Res> {
  factory $BookingHistoryModelCopyWith(
          BookingHistoryModel value, $Res Function(BookingHistoryModel) then) =
      _$BookingHistoryModelCopyWithImpl<$Res, BookingHistoryModel>;
  @useResult
  $Res call(
      {bool? success,
      String? message,
      List<BookingHistoryData>? data,
      Pagination? pagination,
      int? count});

  $PaginationCopyWith<$Res>? get pagination;
}

/// @nodoc
class _$BookingHistoryModelCopyWithImpl<$Res, $Val extends BookingHistoryModel>
    implements $BookingHistoryModelCopyWith<$Res> {
  _$BookingHistoryModelCopyWithImpl(this._value, this._then);

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
    Object? pagination = freezed,
    Object? count = freezed,
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
              as List<BookingHistoryData>?,
      pagination: freezed == pagination
          ? _value.pagination
          : pagination // ignore: cast_nullable_to_non_nullable
              as Pagination?,
      count: freezed == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $PaginationCopyWith<$Res>? get pagination {
    if (_value.pagination == null) {
      return null;
    }

    return $PaginationCopyWith<$Res>(_value.pagination!, (value) {
      return _then(_value.copyWith(pagination: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$BookingHistoryModelImplCopyWith<$Res>
    implements $BookingHistoryModelCopyWith<$Res> {
  factory _$$BookingHistoryModelImplCopyWith(_$BookingHistoryModelImpl value,
          $Res Function(_$BookingHistoryModelImpl) then) =
      __$$BookingHistoryModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool? success,
      String? message,
      List<BookingHistoryData>? data,
      Pagination? pagination,
      int? count});

  @override
  $PaginationCopyWith<$Res>? get pagination;
}

/// @nodoc
class __$$BookingHistoryModelImplCopyWithImpl<$Res>
    extends _$BookingHistoryModelCopyWithImpl<$Res, _$BookingHistoryModelImpl>
    implements _$$BookingHistoryModelImplCopyWith<$Res> {
  __$$BookingHistoryModelImplCopyWithImpl(_$BookingHistoryModelImpl _value,
      $Res Function(_$BookingHistoryModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = freezed,
    Object? message = freezed,
    Object? data = freezed,
    Object? pagination = freezed,
    Object? count = freezed,
  }) {
    return _then(_$BookingHistoryModelImpl(
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
              as List<BookingHistoryData>?,
      pagination: freezed == pagination
          ? _value.pagination
          : pagination // ignore: cast_nullable_to_non_nullable
              as Pagination?,
      count: freezed == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BookingHistoryModelImpl implements _BookingHistoryModel {
  const _$BookingHistoryModelImpl(
      {this.success,
      this.message,
      final List<BookingHistoryData>? data,
      this.pagination,
      this.count})
      : _data = data;

  factory _$BookingHistoryModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$BookingHistoryModelImplFromJson(json);

  @override
  final bool? success;
  @override
  final String? message;
  final List<BookingHistoryData>? _data;
  @override
  List<BookingHistoryData>? get data {
    final value = _data;
    if (value == null) return null;
    if (_data is EqualUnmodifiableListView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final Pagination? pagination;
  @override
  final int? count;

  @override
  String toString() {
    return 'BookingHistoryModel(success: $success, message: $message, data: $data, pagination: $pagination, count: $count)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BookingHistoryModelImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.message, message) || other.message == message) &&
            const DeepCollectionEquality().equals(other._data, _data) &&
            (identical(other.pagination, pagination) ||
                other.pagination == pagination) &&
            (identical(other.count, count) || other.count == count));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, success, message,
      const DeepCollectionEquality().hash(_data), pagination, count);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BookingHistoryModelImplCopyWith<_$BookingHistoryModelImpl> get copyWith =>
      __$$BookingHistoryModelImplCopyWithImpl<_$BookingHistoryModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BookingHistoryModelImplToJson(
      this,
    );
  }
}

abstract class _BookingHistoryModel implements BookingHistoryModel {
  const factory _BookingHistoryModel(
      {final bool? success,
      final String? message,
      final List<BookingHistoryData>? data,
      final Pagination? pagination,
      final int? count}) = _$BookingHistoryModelImpl;

  factory _BookingHistoryModel.fromJson(Map<String, dynamic> json) =
      _$BookingHistoryModelImpl.fromJson;

  @override
  bool? get success;
  @override
  String? get message;
  @override
  List<BookingHistoryData>? get data;
  @override
  Pagination? get pagination;
  @override
  int? get count;
  @override
  @JsonKey(ignore: true)
  _$$BookingHistoryModelImplCopyWith<_$BookingHistoryModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BookingDetailsResponseModel _$BookingDetailsResponseModelFromJson(
    Map<String, dynamic> json) {
  return _BookingDetailsResponseModel.fromJson(json);
}

/// @nodoc
mixin _$BookingDetailsResponseModel {
  bool? get success => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;
  BookingHistoryData? get data => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BookingDetailsResponseModelCopyWith<BookingDetailsResponseModel>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BookingDetailsResponseModelCopyWith<$Res> {
  factory $BookingDetailsResponseModelCopyWith(
          BookingDetailsResponseModel value,
          $Res Function(BookingDetailsResponseModel) then) =
      _$BookingDetailsResponseModelCopyWithImpl<$Res,
          BookingDetailsResponseModel>;
  @useResult
  $Res call({bool? success, String? message, BookingHistoryData? data});

  $BookingHistoryDataCopyWith<$Res>? get data;
}

/// @nodoc
class _$BookingDetailsResponseModelCopyWithImpl<$Res,
        $Val extends BookingDetailsResponseModel>
    implements $BookingDetailsResponseModelCopyWith<$Res> {
  _$BookingDetailsResponseModelCopyWithImpl(this._value, this._then);

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
              as BookingHistoryData?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $BookingHistoryDataCopyWith<$Res>? get data {
    if (_value.data == null) {
      return null;
    }

    return $BookingHistoryDataCopyWith<$Res>(_value.data!, (value) {
      return _then(_value.copyWith(data: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$BookingDetailsResponseModelImplCopyWith<$Res>
    implements $BookingDetailsResponseModelCopyWith<$Res> {
  factory _$$BookingDetailsResponseModelImplCopyWith(
          _$BookingDetailsResponseModelImpl value,
          $Res Function(_$BookingDetailsResponseModelImpl) then) =
      __$$BookingDetailsResponseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool? success, String? message, BookingHistoryData? data});

  @override
  $BookingHistoryDataCopyWith<$Res>? get data;
}

/// @nodoc
class __$$BookingDetailsResponseModelImplCopyWithImpl<$Res>
    extends _$BookingDetailsResponseModelCopyWithImpl<$Res,
        _$BookingDetailsResponseModelImpl>
    implements _$$BookingDetailsResponseModelImplCopyWith<$Res> {
  __$$BookingDetailsResponseModelImplCopyWithImpl(
      _$BookingDetailsResponseModelImpl _value,
      $Res Function(_$BookingDetailsResponseModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = freezed,
    Object? message = freezed,
    Object? data = freezed,
  }) {
    return _then(_$BookingDetailsResponseModelImpl(
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
              as BookingHistoryData?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BookingDetailsResponseModelImpl
    implements _BookingDetailsResponseModel {
  const _$BookingDetailsResponseModelImpl(
      {this.success, this.message, this.data});

  factory _$BookingDetailsResponseModelImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$BookingDetailsResponseModelImplFromJson(json);

  @override
  final bool? success;
  @override
  final String? message;
  @override
  final BookingHistoryData? data;

  @override
  String toString() {
    return 'BookingDetailsResponseModel(success: $success, message: $message, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BookingDetailsResponseModelImpl &&
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
  _$$BookingDetailsResponseModelImplCopyWith<_$BookingDetailsResponseModelImpl>
      get copyWith => __$$BookingDetailsResponseModelImplCopyWithImpl<
          _$BookingDetailsResponseModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BookingDetailsResponseModelImplToJson(
      this,
    );
  }
}

abstract class _BookingDetailsResponseModel
    implements BookingDetailsResponseModel {
  const factory _BookingDetailsResponseModel(
      {final bool? success,
      final String? message,
      final BookingHistoryData? data}) = _$BookingDetailsResponseModelImpl;

  factory _BookingDetailsResponseModel.fromJson(Map<String, dynamic> json) =
      _$BookingDetailsResponseModelImpl.fromJson;

  @override
  bool? get success;
  @override
  String? get message;
  @override
  BookingHistoryData? get data;
  @override
  @JsonKey(ignore: true)
  _$$BookingDetailsResponseModelImplCopyWith<_$BookingDetailsResponseModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}

BookingHistoryData _$BookingHistoryDataFromJson(Map<String, dynamic> json) {
  return _BookingHistoryData.fromJson(json);
}

/// @nodoc
mixin _$BookingHistoryData {
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'customer_id')
  int? get customerId => throw _privateConstructorUsedError;
  @JsonKey(name: 'trek_id')
  int? get trekId => throw _privateConstructorUsedError;
  @JsonKey(name: 'vendor_id')
  int? get vendorId => throw _privateConstructorUsedError;
  @JsonKey(name: 'VendorId')
  int? get vendorIdAlt => throw _privateConstructorUsedError;
  @JsonKey(name: 'batch_id')
  int? get batchId => throw _privateConstructorUsedError;
  @JsonKey(name: 'coupon_id')
  int? get couponId => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_travelers')
  int? get totalTravelers => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_amount', fromJson: _toString)
  String? get totalAmount => throw _privateConstructorUsedError;
  @JsonKey(name: 'platform_fees', fromJson: _toString)
  String? get platformFees => throw _privateConstructorUsedError;
  @JsonKey(name: 'gst_amount', fromJson: _toString)
  String? get gstAmount => throw _privateConstructorUsedError;
  @JsonKey(name: 'discount_amount', fromJson: _toString)
  String? get discountAmount => throw _privateConstructorUsedError;
  @JsonKey(name: 'final_amount', fromJson: _toString)
  String? get finalAmount => throw _privateConstructorUsedError;
  @JsonKey(name: 'payment_status')
  String? get paymentStatus => throw _privateConstructorUsedError;
  String? get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'booking_date')
  String? get bookingDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'special_requests')
  String? get specialRequests => throw _privateConstructorUsedError;
  @JsonKey(name: 'booking_source')
  String? get bookingSource => throw _privateConstructorUsedError;
  @JsonKey(name: 'primary_contact_traveler_id')
  int? get primaryContactTravelerId => throw _privateConstructorUsedError;
  String? get createdAt => throw _privateConstructorUsedError;
  String? get updatedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  int? get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'city_id')
  int? get cityId => throw _privateConstructorUsedError;
  @JsonKey(name: 'cancellation_policy_type')
  dynamic get cancellationPolicyType => throw _privateConstructorUsedError;
  @JsonKey(name: 'advance_amount', fromJson: _toString)
  String? get advanceAmount => throw _privateConstructorUsedError;
  @JsonKey(name: 'remaining_amount', fromJson: _toString)
  String? get remainingAmount => throw _privateConstructorUsedError;
  Trek? get trek => throw _privateConstructorUsedError;
  Batch? get batch => throw _privateConstructorUsedError;
  List<TravelersDataModel>? get travelers => throw _privateConstructorUsedError;
  @JsonKey(name: 'booking_number')
  String? get bookingNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'trek_status')
  String? get trekStatus => throw _privateConstructorUsedError;
  @JsonKey(name: 'rating_given')
  bool? get ratingGiven => throw _privateConstructorUsedError;
  @JsonKey(name: 'rating_value')
  dynamic get ratingValue => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BookingHistoryDataCopyWith<BookingHistoryData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BookingHistoryDataCopyWith<$Res> {
  factory $BookingHistoryDataCopyWith(
          BookingHistoryData value, $Res Function(BookingHistoryData) then) =
      _$BookingHistoryDataCopyWithImpl<$Res, BookingHistoryData>;
  @useResult
  $Res call(
      {int? id,
      @JsonKey(name: 'customer_id') int? customerId,
      @JsonKey(name: 'trek_id') int? trekId,
      @JsonKey(name: 'vendor_id') int? vendorId,
      @JsonKey(name: 'VendorId') int? vendorIdAlt,
      @JsonKey(name: 'batch_id') int? batchId,
      @JsonKey(name: 'coupon_id') int? couponId,
      @JsonKey(name: 'total_travelers') int? totalTravelers,
      @JsonKey(name: 'total_amount', fromJson: _toString) String? totalAmount,
      @JsonKey(name: 'platform_fees', fromJson: _toString) String? platformFees,
      @JsonKey(name: 'gst_amount', fromJson: _toString) String? gstAmount,
      @JsonKey(name: 'discount_amount', fromJson: _toString)
      String? discountAmount,
      @JsonKey(name: 'final_amount', fromJson: _toString) String? finalAmount,
      @JsonKey(name: 'payment_status') String? paymentStatus,
      String? status,
      @JsonKey(name: 'booking_date') String? bookingDate,
      @JsonKey(name: 'special_requests') String? specialRequests,
      @JsonKey(name: 'booking_source') String? bookingSource,
      @JsonKey(name: 'primary_contact_traveler_id')
      int? primaryContactTravelerId,
      String? createdAt,
      String? updatedAt,
      @JsonKey(name: 'user_id') int? userId,
      @JsonKey(name: 'city_id') int? cityId,
      @JsonKey(name: 'cancellation_policy_type') dynamic cancellationPolicyType,
      @JsonKey(name: 'advance_amount', fromJson: _toString)
      String? advanceAmount,
      @JsonKey(name: 'remaining_amount', fromJson: _toString)
      String? remainingAmount,
      Trek? trek,
      Batch? batch,
      List<TravelersDataModel>? travelers,
      @JsonKey(name: 'booking_number') String? bookingNumber,
      @JsonKey(name: 'trek_status') String? trekStatus,
      @JsonKey(name: 'rating_given') bool? ratingGiven,
      @JsonKey(name: 'rating_value') dynamic ratingValue});

  $TrekCopyWith<$Res>? get trek;
  $BatchCopyWith<$Res>? get batch;
}

/// @nodoc
class _$BookingHistoryDataCopyWithImpl<$Res, $Val extends BookingHistoryData>
    implements $BookingHistoryDataCopyWith<$Res> {
  _$BookingHistoryDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? customerId = freezed,
    Object? trekId = freezed,
    Object? vendorId = freezed,
    Object? vendorIdAlt = freezed,
    Object? batchId = freezed,
    Object? couponId = freezed,
    Object? totalTravelers = freezed,
    Object? totalAmount = freezed,
    Object? platformFees = freezed,
    Object? gstAmount = freezed,
    Object? discountAmount = freezed,
    Object? finalAmount = freezed,
    Object? paymentStatus = freezed,
    Object? status = freezed,
    Object? bookingDate = freezed,
    Object? specialRequests = freezed,
    Object? bookingSource = freezed,
    Object? primaryContactTravelerId = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? userId = freezed,
    Object? cityId = freezed,
    Object? cancellationPolicyType = freezed,
    Object? advanceAmount = freezed,
    Object? remainingAmount = freezed,
    Object? trek = freezed,
    Object? batch = freezed,
    Object? travelers = freezed,
    Object? bookingNumber = freezed,
    Object? trekStatus = freezed,
    Object? ratingGiven = freezed,
    Object? ratingValue = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      customerId: freezed == customerId
          ? _value.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as int?,
      trekId: freezed == trekId
          ? _value.trekId
          : trekId // ignore: cast_nullable_to_non_nullable
              as int?,
      vendorId: freezed == vendorId
          ? _value.vendorId
          : vendorId // ignore: cast_nullable_to_non_nullable
              as int?,
      vendorIdAlt: freezed == vendorIdAlt
          ? _value.vendorIdAlt
          : vendorIdAlt // ignore: cast_nullable_to_non_nullable
              as int?,
      batchId: freezed == batchId
          ? _value.batchId
          : batchId // ignore: cast_nullable_to_non_nullable
              as int?,
      couponId: freezed == couponId
          ? _value.couponId
          : couponId // ignore: cast_nullable_to_non_nullable
              as int?,
      totalTravelers: freezed == totalTravelers
          ? _value.totalTravelers
          : totalTravelers // ignore: cast_nullable_to_non_nullable
              as int?,
      totalAmount: freezed == totalAmount
          ? _value.totalAmount
          : totalAmount // ignore: cast_nullable_to_non_nullable
              as String?,
      platformFees: freezed == platformFees
          ? _value.platformFees
          : platformFees // ignore: cast_nullable_to_non_nullable
              as String?,
      gstAmount: freezed == gstAmount
          ? _value.gstAmount
          : gstAmount // ignore: cast_nullable_to_non_nullable
              as String?,
      discountAmount: freezed == discountAmount
          ? _value.discountAmount
          : discountAmount // ignore: cast_nullable_to_non_nullable
              as String?,
      finalAmount: freezed == finalAmount
          ? _value.finalAmount
          : finalAmount // ignore: cast_nullable_to_non_nullable
              as String?,
      paymentStatus: freezed == paymentStatus
          ? _value.paymentStatus
          : paymentStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      bookingDate: freezed == bookingDate
          ? _value.bookingDate
          : bookingDate // ignore: cast_nullable_to_non_nullable
              as String?,
      specialRequests: freezed == specialRequests
          ? _value.specialRequests
          : specialRequests // ignore: cast_nullable_to_non_nullable
              as String?,
      bookingSource: freezed == bookingSource
          ? _value.bookingSource
          : bookingSource // ignore: cast_nullable_to_non_nullable
              as String?,
      primaryContactTravelerId: freezed == primaryContactTravelerId
          ? _value.primaryContactTravelerId
          : primaryContactTravelerId // ignore: cast_nullable_to_non_nullable
              as int?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int?,
      cityId: freezed == cityId
          ? _value.cityId
          : cityId // ignore: cast_nullable_to_non_nullable
              as int?,
      cancellationPolicyType: freezed == cancellationPolicyType
          ? _value.cancellationPolicyType
          : cancellationPolicyType // ignore: cast_nullable_to_non_nullable
              as dynamic,
      advanceAmount: freezed == advanceAmount
          ? _value.advanceAmount
          : advanceAmount // ignore: cast_nullable_to_non_nullable
              as String?,
      remainingAmount: freezed == remainingAmount
          ? _value.remainingAmount
          : remainingAmount // ignore: cast_nullable_to_non_nullable
              as String?,
      trek: freezed == trek
          ? _value.trek
          : trek // ignore: cast_nullable_to_non_nullable
              as Trek?,
      batch: freezed == batch
          ? _value.batch
          : batch // ignore: cast_nullable_to_non_nullable
              as Batch?,
      travelers: freezed == travelers
          ? _value.travelers
          : travelers // ignore: cast_nullable_to_non_nullable
              as List<TravelersDataModel>?,
      bookingNumber: freezed == bookingNumber
          ? _value.bookingNumber
          : bookingNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      trekStatus: freezed == trekStatus
          ? _value.trekStatus
          : trekStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      ratingGiven: freezed == ratingGiven
          ? _value.ratingGiven
          : ratingGiven // ignore: cast_nullable_to_non_nullable
              as bool?,
      ratingValue: freezed == ratingValue
          ? _value.ratingValue
          : ratingValue // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $TrekCopyWith<$Res>? get trek {
    if (_value.trek == null) {
      return null;
    }

    return $TrekCopyWith<$Res>(_value.trek!, (value) {
      return _then(_value.copyWith(trek: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $BatchCopyWith<$Res>? get batch {
    if (_value.batch == null) {
      return null;
    }

    return $BatchCopyWith<$Res>(_value.batch!, (value) {
      return _then(_value.copyWith(batch: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$BookingHistoryDataImplCopyWith<$Res>
    implements $BookingHistoryDataCopyWith<$Res> {
  factory _$$BookingHistoryDataImplCopyWith(_$BookingHistoryDataImpl value,
          $Res Function(_$BookingHistoryDataImpl) then) =
      __$$BookingHistoryDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? id,
      @JsonKey(name: 'customer_id') int? customerId,
      @JsonKey(name: 'trek_id') int? trekId,
      @JsonKey(name: 'vendor_id') int? vendorId,
      @JsonKey(name: 'VendorId') int? vendorIdAlt,
      @JsonKey(name: 'batch_id') int? batchId,
      @JsonKey(name: 'coupon_id') int? couponId,
      @JsonKey(name: 'total_travelers') int? totalTravelers,
      @JsonKey(name: 'total_amount', fromJson: _toString) String? totalAmount,
      @JsonKey(name: 'platform_fees', fromJson: _toString) String? platformFees,
      @JsonKey(name: 'gst_amount', fromJson: _toString) String? gstAmount,
      @JsonKey(name: 'discount_amount', fromJson: _toString)
      String? discountAmount,
      @JsonKey(name: 'final_amount', fromJson: _toString) String? finalAmount,
      @JsonKey(name: 'payment_status') String? paymentStatus,
      String? status,
      @JsonKey(name: 'booking_date') String? bookingDate,
      @JsonKey(name: 'special_requests') String? specialRequests,
      @JsonKey(name: 'booking_source') String? bookingSource,
      @JsonKey(name: 'primary_contact_traveler_id')
      int? primaryContactTravelerId,
      String? createdAt,
      String? updatedAt,
      @JsonKey(name: 'user_id') int? userId,
      @JsonKey(name: 'city_id') int? cityId,
      @JsonKey(name: 'cancellation_policy_type') dynamic cancellationPolicyType,
      @JsonKey(name: 'advance_amount', fromJson: _toString)
      String? advanceAmount,
      @JsonKey(name: 'remaining_amount', fromJson: _toString)
      String? remainingAmount,
      Trek? trek,
      Batch? batch,
      List<TravelersDataModel>? travelers,
      @JsonKey(name: 'booking_number') String? bookingNumber,
      @JsonKey(name: 'trek_status') String? trekStatus,
      @JsonKey(name: 'rating_given') bool? ratingGiven,
      @JsonKey(name: 'rating_value') dynamic ratingValue});

  @override
  $TrekCopyWith<$Res>? get trek;
  @override
  $BatchCopyWith<$Res>? get batch;
}

/// @nodoc
class __$$BookingHistoryDataImplCopyWithImpl<$Res>
    extends _$BookingHistoryDataCopyWithImpl<$Res, _$BookingHistoryDataImpl>
    implements _$$BookingHistoryDataImplCopyWith<$Res> {
  __$$BookingHistoryDataImplCopyWithImpl(_$BookingHistoryDataImpl _value,
      $Res Function(_$BookingHistoryDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? customerId = freezed,
    Object? trekId = freezed,
    Object? vendorId = freezed,
    Object? vendorIdAlt = freezed,
    Object? batchId = freezed,
    Object? couponId = freezed,
    Object? totalTravelers = freezed,
    Object? totalAmount = freezed,
    Object? platformFees = freezed,
    Object? gstAmount = freezed,
    Object? discountAmount = freezed,
    Object? finalAmount = freezed,
    Object? paymentStatus = freezed,
    Object? status = freezed,
    Object? bookingDate = freezed,
    Object? specialRequests = freezed,
    Object? bookingSource = freezed,
    Object? primaryContactTravelerId = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? userId = freezed,
    Object? cityId = freezed,
    Object? cancellationPolicyType = freezed,
    Object? advanceAmount = freezed,
    Object? remainingAmount = freezed,
    Object? trek = freezed,
    Object? batch = freezed,
    Object? travelers = freezed,
    Object? bookingNumber = freezed,
    Object? trekStatus = freezed,
    Object? ratingGiven = freezed,
    Object? ratingValue = freezed,
  }) {
    return _then(_$BookingHistoryDataImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      customerId: freezed == customerId
          ? _value.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as int?,
      trekId: freezed == trekId
          ? _value.trekId
          : trekId // ignore: cast_nullable_to_non_nullable
              as int?,
      vendorId: freezed == vendorId
          ? _value.vendorId
          : vendorId // ignore: cast_nullable_to_non_nullable
              as int?,
      vendorIdAlt: freezed == vendorIdAlt
          ? _value.vendorIdAlt
          : vendorIdAlt // ignore: cast_nullable_to_non_nullable
              as int?,
      batchId: freezed == batchId
          ? _value.batchId
          : batchId // ignore: cast_nullable_to_non_nullable
              as int?,
      couponId: freezed == couponId
          ? _value.couponId
          : couponId // ignore: cast_nullable_to_non_nullable
              as int?,
      totalTravelers: freezed == totalTravelers
          ? _value.totalTravelers
          : totalTravelers // ignore: cast_nullable_to_non_nullable
              as int?,
      totalAmount: freezed == totalAmount
          ? _value.totalAmount
          : totalAmount // ignore: cast_nullable_to_non_nullable
              as String?,
      platformFees: freezed == platformFees
          ? _value.platformFees
          : platformFees // ignore: cast_nullable_to_non_nullable
              as String?,
      gstAmount: freezed == gstAmount
          ? _value.gstAmount
          : gstAmount // ignore: cast_nullable_to_non_nullable
              as String?,
      discountAmount: freezed == discountAmount
          ? _value.discountAmount
          : discountAmount // ignore: cast_nullable_to_non_nullable
              as String?,
      finalAmount: freezed == finalAmount
          ? _value.finalAmount
          : finalAmount // ignore: cast_nullable_to_non_nullable
              as String?,
      paymentStatus: freezed == paymentStatus
          ? _value.paymentStatus
          : paymentStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      bookingDate: freezed == bookingDate
          ? _value.bookingDate
          : bookingDate // ignore: cast_nullable_to_non_nullable
              as String?,
      specialRequests: freezed == specialRequests
          ? _value.specialRequests
          : specialRequests // ignore: cast_nullable_to_non_nullable
              as String?,
      bookingSource: freezed == bookingSource
          ? _value.bookingSource
          : bookingSource // ignore: cast_nullable_to_non_nullable
              as String?,
      primaryContactTravelerId: freezed == primaryContactTravelerId
          ? _value.primaryContactTravelerId
          : primaryContactTravelerId // ignore: cast_nullable_to_non_nullable
              as int?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int?,
      cityId: freezed == cityId
          ? _value.cityId
          : cityId // ignore: cast_nullable_to_non_nullable
              as int?,
      cancellationPolicyType: freezed == cancellationPolicyType
          ? _value.cancellationPolicyType
          : cancellationPolicyType // ignore: cast_nullable_to_non_nullable
              as dynamic,
      advanceAmount: freezed == advanceAmount
          ? _value.advanceAmount
          : advanceAmount // ignore: cast_nullable_to_non_nullable
              as String?,
      remainingAmount: freezed == remainingAmount
          ? _value.remainingAmount
          : remainingAmount // ignore: cast_nullable_to_non_nullable
              as String?,
      trek: freezed == trek
          ? _value.trek
          : trek // ignore: cast_nullable_to_non_nullable
              as Trek?,
      batch: freezed == batch
          ? _value.batch
          : batch // ignore: cast_nullable_to_non_nullable
              as Batch?,
      travelers: freezed == travelers
          ? _value._travelers
          : travelers // ignore: cast_nullable_to_non_nullable
              as List<TravelersDataModel>?,
      bookingNumber: freezed == bookingNumber
          ? _value.bookingNumber
          : bookingNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      trekStatus: freezed == trekStatus
          ? _value.trekStatus
          : trekStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      ratingGiven: freezed == ratingGiven
          ? _value.ratingGiven
          : ratingGiven // ignore: cast_nullable_to_non_nullable
              as bool?,
      ratingValue: freezed == ratingValue
          ? _value.ratingValue
          : ratingValue // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BookingHistoryDataImpl implements _BookingHistoryData {
  const _$BookingHistoryDataImpl(
      {this.id,
      @JsonKey(name: 'customer_id') this.customerId,
      @JsonKey(name: 'trek_id') this.trekId,
      @JsonKey(name: 'vendor_id') this.vendorId,
      @JsonKey(name: 'VendorId') this.vendorIdAlt,
      @JsonKey(name: 'batch_id') this.batchId,
      @JsonKey(name: 'coupon_id') this.couponId,
      @JsonKey(name: 'total_travelers') this.totalTravelers,
      @JsonKey(name: 'total_amount', fromJson: _toString) this.totalAmount,
      @JsonKey(name: 'platform_fees', fromJson: _toString) this.platformFees,
      @JsonKey(name: 'gst_amount', fromJson: _toString) this.gstAmount,
      @JsonKey(name: 'discount_amount', fromJson: _toString)
      this.discountAmount,
      @JsonKey(name: 'final_amount', fromJson: _toString) this.finalAmount,
      @JsonKey(name: 'payment_status') this.paymentStatus,
      this.status,
      @JsonKey(name: 'booking_date') this.bookingDate,
      @JsonKey(name: 'special_requests') this.specialRequests,
      @JsonKey(name: 'booking_source') this.bookingSource,
      @JsonKey(name: 'primary_contact_traveler_id')
      this.primaryContactTravelerId,
      this.createdAt,
      this.updatedAt,
      @JsonKey(name: 'user_id') this.userId,
      @JsonKey(name: 'city_id') this.cityId,
      @JsonKey(name: 'cancellation_policy_type') this.cancellationPolicyType,
      @JsonKey(name: 'advance_amount', fromJson: _toString) this.advanceAmount,
      @JsonKey(name: 'remaining_amount', fromJson: _toString)
      this.remainingAmount,
      this.trek,
      this.batch,
      final List<TravelersDataModel>? travelers,
      @JsonKey(name: 'booking_number') this.bookingNumber,
      @JsonKey(name: 'trek_status') this.trekStatus,
      @JsonKey(name: 'rating_given') this.ratingGiven,
      @JsonKey(name: 'rating_value') this.ratingValue})
      : _travelers = travelers;

  factory _$BookingHistoryDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$BookingHistoryDataImplFromJson(json);

  @override
  final int? id;
  @override
  @JsonKey(name: 'customer_id')
  final int? customerId;
  @override
  @JsonKey(name: 'trek_id')
  final int? trekId;
  @override
  @JsonKey(name: 'vendor_id')
  final int? vendorId;
  @override
  @JsonKey(name: 'VendorId')
  final int? vendorIdAlt;
  @override
  @JsonKey(name: 'batch_id')
  final int? batchId;
  @override
  @JsonKey(name: 'coupon_id')
  final int? couponId;
  @override
  @JsonKey(name: 'total_travelers')
  final int? totalTravelers;
  @override
  @JsonKey(name: 'total_amount', fromJson: _toString)
  final String? totalAmount;
  @override
  @JsonKey(name: 'platform_fees', fromJson: _toString)
  final String? platformFees;
  @override
  @JsonKey(name: 'gst_amount', fromJson: _toString)
  final String? gstAmount;
  @override
  @JsonKey(name: 'discount_amount', fromJson: _toString)
  final String? discountAmount;
  @override
  @JsonKey(name: 'final_amount', fromJson: _toString)
  final String? finalAmount;
  @override
  @JsonKey(name: 'payment_status')
  final String? paymentStatus;
  @override
  final String? status;
  @override
  @JsonKey(name: 'booking_date')
  final String? bookingDate;
  @override
  @JsonKey(name: 'special_requests')
  final String? specialRequests;
  @override
  @JsonKey(name: 'booking_source')
  final String? bookingSource;
  @override
  @JsonKey(name: 'primary_contact_traveler_id')
  final int? primaryContactTravelerId;
  @override
  final String? createdAt;
  @override
  final String? updatedAt;
  @override
  @JsonKey(name: 'user_id')
  final int? userId;
  @override
  @JsonKey(name: 'city_id')
  final int? cityId;
  @override
  @JsonKey(name: 'cancellation_policy_type')
  final dynamic cancellationPolicyType;
  @override
  @JsonKey(name: 'advance_amount', fromJson: _toString)
  final String? advanceAmount;
  @override
  @JsonKey(name: 'remaining_amount', fromJson: _toString)
  final String? remainingAmount;
  @override
  final Trek? trek;
  @override
  final Batch? batch;
  final List<TravelersDataModel>? _travelers;
  @override
  List<TravelersDataModel>? get travelers {
    final value = _travelers;
    if (value == null) return null;
    if (_travelers is EqualUnmodifiableListView) return _travelers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'booking_number')
  final String? bookingNumber;
  @override
  @JsonKey(name: 'trek_status')
  final String? trekStatus;
  @override
  @JsonKey(name: 'rating_given')
  final bool? ratingGiven;
  @override
  @JsonKey(name: 'rating_value')
  final dynamic ratingValue;

  @override
  String toString() {
    return 'BookingHistoryData(id: $id, customerId: $customerId, trekId: $trekId, vendorId: $vendorId, vendorIdAlt: $vendorIdAlt, batchId: $batchId, couponId: $couponId, totalTravelers: $totalTravelers, totalAmount: $totalAmount, platformFees: $platformFees, gstAmount: $gstAmount, discountAmount: $discountAmount, finalAmount: $finalAmount, paymentStatus: $paymentStatus, status: $status, bookingDate: $bookingDate, specialRequests: $specialRequests, bookingSource: $bookingSource, primaryContactTravelerId: $primaryContactTravelerId, createdAt: $createdAt, updatedAt: $updatedAt, userId: $userId, cityId: $cityId, cancellationPolicyType: $cancellationPolicyType, advanceAmount: $advanceAmount, remainingAmount: $remainingAmount, trek: $trek, batch: $batch, travelers: $travelers, bookingNumber: $bookingNumber, trekStatus: $trekStatus, ratingGiven: $ratingGiven, ratingValue: $ratingValue)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BookingHistoryDataImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.trekId, trekId) || other.trekId == trekId) &&
            (identical(other.vendorId, vendorId) ||
                other.vendorId == vendorId) &&
            (identical(other.vendorIdAlt, vendorIdAlt) ||
                other.vendorIdAlt == vendorIdAlt) &&
            (identical(other.batchId, batchId) || other.batchId == batchId) &&
            (identical(other.couponId, couponId) ||
                other.couponId == couponId) &&
            (identical(other.totalTravelers, totalTravelers) ||
                other.totalTravelers == totalTravelers) &&
            (identical(other.totalAmount, totalAmount) ||
                other.totalAmount == totalAmount) &&
            (identical(other.platformFees, platformFees) ||
                other.platformFees == platformFees) &&
            (identical(other.gstAmount, gstAmount) ||
                other.gstAmount == gstAmount) &&
            (identical(other.discountAmount, discountAmount) ||
                other.discountAmount == discountAmount) &&
            (identical(other.finalAmount, finalAmount) ||
                other.finalAmount == finalAmount) &&
            (identical(other.paymentStatus, paymentStatus) ||
                other.paymentStatus == paymentStatus) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.bookingDate, bookingDate) ||
                other.bookingDate == bookingDate) &&
            (identical(other.specialRequests, specialRequests) ||
                other.specialRequests == specialRequests) &&
            (identical(other.bookingSource, bookingSource) ||
                other.bookingSource == bookingSource) &&
            (identical(
                    other.primaryContactTravelerId, primaryContactTravelerId) ||
                other.primaryContactTravelerId == primaryContactTravelerId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.cityId, cityId) || other.cityId == cityId) &&
            const DeepCollectionEquality()
                .equals(other.cancellationPolicyType, cancellationPolicyType) &&
            (identical(other.advanceAmount, advanceAmount) ||
                other.advanceAmount == advanceAmount) &&
            (identical(other.remainingAmount, remainingAmount) ||
                other.remainingAmount == remainingAmount) &&
            (identical(other.trek, trek) || other.trek == trek) &&
            (identical(other.batch, batch) || other.batch == batch) &&
            const DeepCollectionEquality()
                .equals(other._travelers, _travelers) &&
            (identical(other.bookingNumber, bookingNumber) ||
                other.bookingNumber == bookingNumber) &&
            (identical(other.trekStatus, trekStatus) ||
                other.trekStatus == trekStatus) &&
            (identical(other.ratingGiven, ratingGiven) ||
                other.ratingGiven == ratingGiven) &&
            const DeepCollectionEquality()
                .equals(other.ratingValue, ratingValue));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        customerId,
        trekId,
        vendorId,
        vendorIdAlt,
        batchId,
        couponId,
        totalTravelers,
        totalAmount,
        platformFees,
        gstAmount,
        discountAmount,
        finalAmount,
        paymentStatus,
        status,
        bookingDate,
        specialRequests,
        bookingSource,
        primaryContactTravelerId,
        createdAt,
        updatedAt,
        userId,
        cityId,
        const DeepCollectionEquality().hash(cancellationPolicyType),
        advanceAmount,
        remainingAmount,
        trek,
        batch,
        const DeepCollectionEquality().hash(_travelers),
        bookingNumber,
        trekStatus,
        ratingGiven,
        const DeepCollectionEquality().hash(ratingValue)
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BookingHistoryDataImplCopyWith<_$BookingHistoryDataImpl> get copyWith =>
      __$$BookingHistoryDataImplCopyWithImpl<_$BookingHistoryDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BookingHistoryDataImplToJson(
      this,
    );
  }
}

abstract class _BookingHistoryData implements BookingHistoryData {
  const factory _BookingHistoryData(
      {final int? id,
      @JsonKey(name: 'customer_id') final int? customerId,
      @JsonKey(name: 'trek_id') final int? trekId,
      @JsonKey(name: 'vendor_id') final int? vendorId,
      @JsonKey(name: 'VendorId') final int? vendorIdAlt,
      @JsonKey(name: 'batch_id') final int? batchId,
      @JsonKey(name: 'coupon_id') final int? couponId,
      @JsonKey(name: 'total_travelers') final int? totalTravelers,
      @JsonKey(name: 'total_amount', fromJson: _toString)
      final String? totalAmount,
      @JsonKey(name: 'platform_fees', fromJson: _toString)
      final String? platformFees,
      @JsonKey(name: 'gst_amount', fromJson: _toString) final String? gstAmount,
      @JsonKey(name: 'discount_amount', fromJson: _toString)
      final String? discountAmount,
      @JsonKey(name: 'final_amount', fromJson: _toString)
      final String? finalAmount,
      @JsonKey(name: 'payment_status') final String? paymentStatus,
      final String? status,
      @JsonKey(name: 'booking_date') final String? bookingDate,
      @JsonKey(name: 'special_requests') final String? specialRequests,
      @JsonKey(name: 'booking_source') final String? bookingSource,
      @JsonKey(name: 'primary_contact_traveler_id')
      final int? primaryContactTravelerId,
      final String? createdAt,
      final String? updatedAt,
      @JsonKey(name: 'user_id') final int? userId,
      @JsonKey(name: 'city_id') final int? cityId,
      @JsonKey(name: 'cancellation_policy_type')
      final dynamic cancellationPolicyType,
      @JsonKey(name: 'advance_amount', fromJson: _toString)
      final String? advanceAmount,
      @JsonKey(name: 'remaining_amount', fromJson: _toString)
      final String? remainingAmount,
      final Trek? trek,
      final Batch? batch,
      final List<TravelersDataModel>? travelers,
      @JsonKey(name: 'booking_number') final String? bookingNumber,
      @JsonKey(name: 'trek_status') final String? trekStatus,
      @JsonKey(name: 'rating_given') final bool? ratingGiven,
      @JsonKey(name: 'rating_value')
      final dynamic ratingValue}) = _$BookingHistoryDataImpl;

  factory _BookingHistoryData.fromJson(Map<String, dynamic> json) =
      _$BookingHistoryDataImpl.fromJson;

  @override
  int? get id;
  @override
  @JsonKey(name: 'customer_id')
  int? get customerId;
  @override
  @JsonKey(name: 'trek_id')
  int? get trekId;
  @override
  @JsonKey(name: 'vendor_id')
  int? get vendorId;
  @override
  @JsonKey(name: 'VendorId')
  int? get vendorIdAlt;
  @override
  @JsonKey(name: 'batch_id')
  int? get batchId;
  @override
  @JsonKey(name: 'coupon_id')
  int? get couponId;
  @override
  @JsonKey(name: 'total_travelers')
  int? get totalTravelers;
  @override
  @JsonKey(name: 'total_amount', fromJson: _toString)
  String? get totalAmount;
  @override
  @JsonKey(name: 'platform_fees', fromJson: _toString)
  String? get platformFees;
  @override
  @JsonKey(name: 'gst_amount', fromJson: _toString)
  String? get gstAmount;
  @override
  @JsonKey(name: 'discount_amount', fromJson: _toString)
  String? get discountAmount;
  @override
  @JsonKey(name: 'final_amount', fromJson: _toString)
  String? get finalAmount;
  @override
  @JsonKey(name: 'payment_status')
  String? get paymentStatus;
  @override
  String? get status;
  @override
  @JsonKey(name: 'booking_date')
  String? get bookingDate;
  @override
  @JsonKey(name: 'special_requests')
  String? get specialRequests;
  @override
  @JsonKey(name: 'booking_source')
  String? get bookingSource;
  @override
  @JsonKey(name: 'primary_contact_traveler_id')
  int? get primaryContactTravelerId;
  @override
  String? get createdAt;
  @override
  String? get updatedAt;
  @override
  @JsonKey(name: 'user_id')
  int? get userId;
  @override
  @JsonKey(name: 'city_id')
  int? get cityId;
  @override
  @JsonKey(name: 'cancellation_policy_type')
  dynamic get cancellationPolicyType;
  @override
  @JsonKey(name: 'advance_amount', fromJson: _toString)
  String? get advanceAmount;
  @override
  @JsonKey(name: 'remaining_amount', fromJson: _toString)
  String? get remainingAmount;
  @override
  Trek? get trek;
  @override
  Batch? get batch;
  @override
  List<TravelersDataModel>? get travelers;
  @override
  @JsonKey(name: 'booking_number')
  String? get bookingNumber;
  @override
  @JsonKey(name: 'trek_status')
  String? get trekStatus;
  @override
  @JsonKey(name: 'rating_given')
  bool? get ratingGiven;
  @override
  @JsonKey(name: 'rating_value')
  dynamic get ratingValue;
  @override
  @JsonKey(ignore: true)
  _$$BookingHistoryDataImplCopyWith<_$BookingHistoryDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Trek _$TrekFromJson(Map<String, dynamic> json) {
  return _Trek.fromJson(json);
}

/// @nodoc
mixin _$Trek {
  int? get id => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;
  String? get duration => throw _privateConstructorUsedError;
  @JsonKey(name: 'base_price')
  String? get basePrice => throw _privateConstructorUsedError;
  String? get status => throw _privateConstructorUsedError;
  Vendor? get vendor => throw _privateConstructorUsedError;
  Destination? get destination => throw _privateConstructorUsedError;
  @JsonKey(name: 'captain_name')
  String? get captainName => throw _privateConstructorUsedError;
  @JsonKey(name: 'captain_phone')
  String? get captainPhone => throw _privateConstructorUsedError;
  String? get difficulty => throw _privateConstructorUsedError;
  @JsonKey(name: 'duration_days')
  int? get durationDays => throw _privateConstructorUsedError;
  @JsonKey(name: 'duration_nights')
  int? get durationNights => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TrekCopyWith<Trek> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrekCopyWith<$Res> {
  factory $TrekCopyWith(Trek value, $Res Function(Trek) then) =
      _$TrekCopyWithImpl<$Res, Trek>;
  @useResult
  $Res call(
      {int? id,
      String? title,
      String? duration,
      @JsonKey(name: 'base_price') String? basePrice,
      String? status,
      Vendor? vendor,
      Destination? destination,
      @JsonKey(name: 'captain_name') String? captainName,
      @JsonKey(name: 'captain_phone') String? captainPhone,
      String? difficulty,
      @JsonKey(name: 'duration_days') int? durationDays,
      @JsonKey(name: 'duration_nights') int? durationNights});

  $VendorCopyWith<$Res>? get vendor;
  $DestinationCopyWith<$Res>? get destination;
}

/// @nodoc
class _$TrekCopyWithImpl<$Res, $Val extends Trek>
    implements $TrekCopyWith<$Res> {
  _$TrekCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? title = freezed,
    Object? duration = freezed,
    Object? basePrice = freezed,
    Object? status = freezed,
    Object? vendor = freezed,
    Object? destination = freezed,
    Object? captainName = freezed,
    Object? captainPhone = freezed,
    Object? difficulty = freezed,
    Object? durationDays = freezed,
    Object? durationNights = freezed,
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
      duration: freezed == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as String?,
      basePrice: freezed == basePrice
          ? _value.basePrice
          : basePrice // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      vendor: freezed == vendor
          ? _value.vendor
          : vendor // ignore: cast_nullable_to_non_nullable
              as Vendor?,
      destination: freezed == destination
          ? _value.destination
          : destination // ignore: cast_nullable_to_non_nullable
              as Destination?,
      captainName: freezed == captainName
          ? _value.captainName
          : captainName // ignore: cast_nullable_to_non_nullable
              as String?,
      captainPhone: freezed == captainPhone
          ? _value.captainPhone
          : captainPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      difficulty: freezed == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as String?,
      durationDays: freezed == durationDays
          ? _value.durationDays
          : durationDays // ignore: cast_nullable_to_non_nullable
              as int?,
      durationNights: freezed == durationNights
          ? _value.durationNights
          : durationNights // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $VendorCopyWith<$Res>? get vendor {
    if (_value.vendor == null) {
      return null;
    }

    return $VendorCopyWith<$Res>(_value.vendor!, (value) {
      return _then(_value.copyWith(vendor: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $DestinationCopyWith<$Res>? get destination {
    if (_value.destination == null) {
      return null;
    }

    return $DestinationCopyWith<$Res>(_value.destination!, (value) {
      return _then(_value.copyWith(destination: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TrekImplCopyWith<$Res> implements $TrekCopyWith<$Res> {
  factory _$$TrekImplCopyWith(
          _$TrekImpl value, $Res Function(_$TrekImpl) then) =
      __$$TrekImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? id,
      String? title,
      String? duration,
      @JsonKey(name: 'base_price') String? basePrice,
      String? status,
      Vendor? vendor,
      Destination? destination,
      @JsonKey(name: 'captain_name') String? captainName,
      @JsonKey(name: 'captain_phone') String? captainPhone,
      String? difficulty,
      @JsonKey(name: 'duration_days') int? durationDays,
      @JsonKey(name: 'duration_nights') int? durationNights});

  @override
  $VendorCopyWith<$Res>? get vendor;
  @override
  $DestinationCopyWith<$Res>? get destination;
}

/// @nodoc
class __$$TrekImplCopyWithImpl<$Res>
    extends _$TrekCopyWithImpl<$Res, _$TrekImpl>
    implements _$$TrekImplCopyWith<$Res> {
  __$$TrekImplCopyWithImpl(_$TrekImpl _value, $Res Function(_$TrekImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? title = freezed,
    Object? duration = freezed,
    Object? basePrice = freezed,
    Object? status = freezed,
    Object? vendor = freezed,
    Object? destination = freezed,
    Object? captainName = freezed,
    Object? captainPhone = freezed,
    Object? difficulty = freezed,
    Object? durationDays = freezed,
    Object? durationNights = freezed,
  }) {
    return _then(_$TrekImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      duration: freezed == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as String?,
      basePrice: freezed == basePrice
          ? _value.basePrice
          : basePrice // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      vendor: freezed == vendor
          ? _value.vendor
          : vendor // ignore: cast_nullable_to_non_nullable
              as Vendor?,
      destination: freezed == destination
          ? _value.destination
          : destination // ignore: cast_nullable_to_non_nullable
              as Destination?,
      captainName: freezed == captainName
          ? _value.captainName
          : captainName // ignore: cast_nullable_to_non_nullable
              as String?,
      captainPhone: freezed == captainPhone
          ? _value.captainPhone
          : captainPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      difficulty: freezed == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as String?,
      durationDays: freezed == durationDays
          ? _value.durationDays
          : durationDays // ignore: cast_nullable_to_non_nullable
              as int?,
      durationNights: freezed == durationNights
          ? _value.durationNights
          : durationNights // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TrekImpl implements _Trek {
  const _$TrekImpl(
      {this.id,
      this.title,
      this.duration,
      @JsonKey(name: 'base_price') this.basePrice,
      this.status,
      this.vendor,
      this.destination,
      @JsonKey(name: 'captain_name') this.captainName,
      @JsonKey(name: 'captain_phone') this.captainPhone,
      this.difficulty,
      @JsonKey(name: 'duration_days') this.durationDays,
      @JsonKey(name: 'duration_nights') this.durationNights});

  factory _$TrekImpl.fromJson(Map<String, dynamic> json) =>
      _$$TrekImplFromJson(json);

  @override
  final int? id;
  @override
  final String? title;
  @override
  final String? duration;
  @override
  @JsonKey(name: 'base_price')
  final String? basePrice;
  @override
  final String? status;
  @override
  final Vendor? vendor;
  @override
  final Destination? destination;
  @override
  @JsonKey(name: 'captain_name')
  final String? captainName;
  @override
  @JsonKey(name: 'captain_phone')
  final String? captainPhone;
  @override
  final String? difficulty;
  @override
  @JsonKey(name: 'duration_days')
  final int? durationDays;
  @override
  @JsonKey(name: 'duration_nights')
  final int? durationNights;

  @override
  String toString() {
    return 'Trek(id: $id, title: $title, duration: $duration, basePrice: $basePrice, status: $status, vendor: $vendor, destination: $destination, captainName: $captainName, captainPhone: $captainPhone, difficulty: $difficulty, durationDays: $durationDays, durationNights: $durationNights)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrekImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.basePrice, basePrice) ||
                other.basePrice == basePrice) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.vendor, vendor) || other.vendor == vendor) &&
            (identical(other.destination, destination) ||
                other.destination == destination) &&
            (identical(other.captainName, captainName) ||
                other.captainName == captainName) &&
            (identical(other.captainPhone, captainPhone) ||
                other.captainPhone == captainPhone) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            (identical(other.durationDays, durationDays) ||
                other.durationDays == durationDays) &&
            (identical(other.durationNights, durationNights) ||
                other.durationNights == durationNights));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      duration,
      basePrice,
      status,
      vendor,
      destination,
      captainName,
      captainPhone,
      difficulty,
      durationDays,
      durationNights);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TrekImplCopyWith<_$TrekImpl> get copyWith =>
      __$$TrekImplCopyWithImpl<_$TrekImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TrekImplToJson(
      this,
    );
  }
}

abstract class _Trek implements Trek {
  const factory _Trek(
          {final int? id,
          final String? title,
          final String? duration,
          @JsonKey(name: 'base_price') final String? basePrice,
          final String? status,
          final Vendor? vendor,
          final Destination? destination,
          @JsonKey(name: 'captain_name') final String? captainName,
          @JsonKey(name: 'captain_phone') final String? captainPhone,
          final String? difficulty,
          @JsonKey(name: 'duration_days') final int? durationDays,
          @JsonKey(name: 'duration_nights') final int? durationNights}) =
      _$TrekImpl;

  factory _Trek.fromJson(Map<String, dynamic> json) = _$TrekImpl.fromJson;

  @override
  int? get id;
  @override
  String? get title;
  @override
  String? get duration;
  @override
  @JsonKey(name: 'base_price')
  String? get basePrice;
  @override
  String? get status;
  @override
  Vendor? get vendor;
  @override
  Destination? get destination;
  @override
  @JsonKey(name: 'captain_name')
  String? get captainName;
  @override
  @JsonKey(name: 'captain_phone')
  String? get captainPhone;
  @override
  String? get difficulty;
  @override
  @JsonKey(name: 'duration_days')
  int? get durationDays;
  @override
  @JsonKey(name: 'duration_nights')
  int? get durationNights;
  @override
  @JsonKey(ignore: true)
  _$$TrekImplCopyWith<_$TrekImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Vendor _$VendorFromJson(Map<String, dynamic> json) {
  return _Vendor.fromJson(json);
}

/// @nodoc
mixin _$Vendor {
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'business_name')
  String? get businessName => throw _privateConstructorUsedError;
  @JsonKey(name: 'business_logo', fromJson: _parseImageUrl)
  String? get businessLogo => throw _privateConstructorUsedError;
  String? get city => throw _privateConstructorUsedError;
  String? get state => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;

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
      @JsonKey(name: 'business_name') String? businessName,
      @JsonKey(name: 'business_logo', fromJson: _parseImageUrl)
      String? businessLogo,
      String? city,
      String? state,
      String? address});
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
    Object? businessName = freezed,
    Object? businessLogo = freezed,
    Object? city = freezed,
    Object? state = freezed,
    Object? address = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      businessName: freezed == businessName
          ? _value.businessName
          : businessName // ignore: cast_nullable_to_non_nullable
              as String?,
      businessLogo: freezed == businessLogo
          ? _value.businessLogo
          : businessLogo // ignore: cast_nullable_to_non_nullable
              as String?,
      city: freezed == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String?,
      state: freezed == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as String?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
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
      @JsonKey(name: 'business_name') String? businessName,
      @JsonKey(name: 'business_logo', fromJson: _parseImageUrl)
      String? businessLogo,
      String? city,
      String? state,
      String? address});
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
    Object? businessName = freezed,
    Object? businessLogo = freezed,
    Object? city = freezed,
    Object? state = freezed,
    Object? address = freezed,
  }) {
    return _then(_$VendorImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      businessName: freezed == businessName
          ? _value.businessName
          : businessName // ignore: cast_nullable_to_non_nullable
              as String?,
      businessLogo: freezed == businessLogo
          ? _value.businessLogo
          : businessLogo // ignore: cast_nullable_to_non_nullable
              as String?,
      city: freezed == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String?,
      state: freezed == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as String?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VendorImpl implements _Vendor {
  const _$VendorImpl(
      {this.id,
      @JsonKey(name: 'business_name') this.businessName,
      @JsonKey(name: 'business_logo', fromJson: _parseImageUrl)
      this.businessLogo,
      this.city,
      this.state,
      this.address});

  factory _$VendorImpl.fromJson(Map<String, dynamic> json) =>
      _$$VendorImplFromJson(json);

  @override
  final int? id;
  @override
  @JsonKey(name: 'business_name')
  final String? businessName;
  @override
  @JsonKey(name: 'business_logo', fromJson: _parseImageUrl)
  final String? businessLogo;
  @override
  final String? city;
  @override
  final String? state;
  @override
  final String? address;

  @override
  String toString() {
    return 'Vendor(id: $id, businessName: $businessName, businessLogo: $businessLogo, city: $city, state: $state, address: $address)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VendorImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.businessName, businessName) ||
                other.businessName == businessName) &&
            (identical(other.businessLogo, businessLogo) ||
                other.businessLogo == businessLogo) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.address, address) || other.address == address));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, businessName, businessLogo, city, state, address);

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
      @JsonKey(name: 'business_name') final String? businessName,
      @JsonKey(name: 'business_logo', fromJson: _parseImageUrl)
      final String? businessLogo,
      final String? city,
      final String? state,
      final String? address}) = _$VendorImpl;

  factory _Vendor.fromJson(Map<String, dynamic> json) = _$VendorImpl.fromJson;

  @override
  int? get id;
  @override
  @JsonKey(name: 'business_name')
  String? get businessName;
  @override
  @JsonKey(name: 'business_logo', fromJson: _parseImageUrl)
  String? get businessLogo;
  @override
  String? get city;
  @override
  String? get state;
  @override
  String? get address;
  @override
  @JsonKey(ignore: true)
  _$$VendorImplCopyWith<_$VendorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Destination _$DestinationFromJson(Map<String, dynamic> json) {
  return _Destination.fromJson(json);
}

/// @nodoc
mixin _$Destination {
  int? get id => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DestinationCopyWith<Destination> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DestinationCopyWith<$Res> {
  factory $DestinationCopyWith(
          Destination value, $Res Function(Destination) then) =
      _$DestinationCopyWithImpl<$Res, Destination>;
  @useResult
  $Res call({int? id, String? name});
}

/// @nodoc
class _$DestinationCopyWithImpl<$Res, $Val extends Destination>
    implements $DestinationCopyWith<$Res> {
  _$DestinationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
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
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DestinationImplCopyWith<$Res>
    implements $DestinationCopyWith<$Res> {
  factory _$$DestinationImplCopyWith(
          _$DestinationImpl value, $Res Function(_$DestinationImpl) then) =
      __$$DestinationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int? id, String? name});
}

/// @nodoc
class __$$DestinationImplCopyWithImpl<$Res>
    extends _$DestinationCopyWithImpl<$Res, _$DestinationImpl>
    implements _$$DestinationImplCopyWith<$Res> {
  __$$DestinationImplCopyWithImpl(
      _$DestinationImpl _value, $Res Function(_$DestinationImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
  }) {
    return _then(_$DestinationImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DestinationImpl implements _Destination {
  const _$DestinationImpl({this.id, this.name});

  factory _$DestinationImpl.fromJson(Map<String, dynamic> json) =>
      _$$DestinationImplFromJson(json);

  @override
  final int? id;
  @override
  final String? name;

  @override
  String toString() {
    return 'Destination(id: $id, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DestinationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, name);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DestinationImplCopyWith<_$DestinationImpl> get copyWith =>
      __$$DestinationImplCopyWithImpl<_$DestinationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DestinationImplToJson(
      this,
    );
  }
}

abstract class _Destination implements Destination {
  const factory _Destination({final int? id, final String? name}) =
      _$DestinationImpl;

  factory _Destination.fromJson(Map<String, dynamic> json) =
      _$DestinationImpl.fromJson;

  @override
  int? get id;
  @override
  String? get name;
  @override
  @JsonKey(ignore: true)
  _$$DestinationImplCopyWith<_$DestinationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Batch _$BatchFromJson(Map<String, dynamic> json) {
  return _Batch.fromJson(json);
}

/// @nodoc
mixin _$Batch {
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'tbr_id')
  String? get tbrId => throw _privateConstructorUsedError;
  @JsonKey(name: 'start_date')
  String? get startDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'end_date')
  String? get endDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'start_time')
  String? get startTime => throw _privateConstructorUsedError;
  @JsonKey(name: 'available_slots')
  int? get availableSlots => throw _privateConstructorUsedError;
  @JsonKey(name: 'booked_slots')
  int? get bookedSlots => throw _privateConstructorUsedError;
  int? get capacity => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BatchCopyWith<Batch> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BatchCopyWith<$Res> {
  factory $BatchCopyWith(Batch value, $Res Function(Batch) then) =
      _$BatchCopyWithImpl<$Res, Batch>;
  @useResult
  $Res call(
      {int? id,
      @JsonKey(name: 'tbr_id') String? tbrId,
      @JsonKey(name: 'start_date') String? startDate,
      @JsonKey(name: 'end_date') String? endDate,
      @JsonKey(name: 'start_time') String? startTime,
      @JsonKey(name: 'available_slots') int? availableSlots,
      @JsonKey(name: 'booked_slots') int? bookedSlots,
      int? capacity});
}

/// @nodoc
class _$BatchCopyWithImpl<$Res, $Val extends Batch>
    implements $BatchCopyWith<$Res> {
  _$BatchCopyWithImpl(this._value, this._then);

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
    Object? startTime = freezed,
    Object? availableSlots = freezed,
    Object? bookedSlots = freezed,
    Object? capacity = freezed,
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
      startTime: freezed == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as String?,
      availableSlots: freezed == availableSlots
          ? _value.availableSlots
          : availableSlots // ignore: cast_nullable_to_non_nullable
              as int?,
      bookedSlots: freezed == bookedSlots
          ? _value.bookedSlots
          : bookedSlots // ignore: cast_nullable_to_non_nullable
              as int?,
      capacity: freezed == capacity
          ? _value.capacity
          : capacity // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BatchImplCopyWith<$Res> implements $BatchCopyWith<$Res> {
  factory _$$BatchImplCopyWith(
          _$BatchImpl value, $Res Function(_$BatchImpl) then) =
      __$$BatchImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? id,
      @JsonKey(name: 'tbr_id') String? tbrId,
      @JsonKey(name: 'start_date') String? startDate,
      @JsonKey(name: 'end_date') String? endDate,
      @JsonKey(name: 'start_time') String? startTime,
      @JsonKey(name: 'available_slots') int? availableSlots,
      @JsonKey(name: 'booked_slots') int? bookedSlots,
      int? capacity});
}

/// @nodoc
class __$$BatchImplCopyWithImpl<$Res>
    extends _$BatchCopyWithImpl<$Res, _$BatchImpl>
    implements _$$BatchImplCopyWith<$Res> {
  __$$BatchImplCopyWithImpl(
      _$BatchImpl _value, $Res Function(_$BatchImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? tbrId = freezed,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? startTime = freezed,
    Object? availableSlots = freezed,
    Object? bookedSlots = freezed,
    Object? capacity = freezed,
  }) {
    return _then(_$BatchImpl(
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
      startTime: freezed == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as String?,
      availableSlots: freezed == availableSlots
          ? _value.availableSlots
          : availableSlots // ignore: cast_nullable_to_non_nullable
              as int?,
      bookedSlots: freezed == bookedSlots
          ? _value.bookedSlots
          : bookedSlots // ignore: cast_nullable_to_non_nullable
              as int?,
      capacity: freezed == capacity
          ? _value.capacity
          : capacity // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BatchImpl implements _Batch {
  const _$BatchImpl(
      {this.id,
      @JsonKey(name: 'tbr_id') this.tbrId,
      @JsonKey(name: 'start_date') this.startDate,
      @JsonKey(name: 'end_date') this.endDate,
      @JsonKey(name: 'start_time') this.startTime,
      @JsonKey(name: 'available_slots') this.availableSlots,
      @JsonKey(name: 'booked_slots') this.bookedSlots,
      this.capacity});

  factory _$BatchImpl.fromJson(Map<String, dynamic> json) =>
      _$$BatchImplFromJson(json);

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
  @JsonKey(name: 'start_time')
  final String? startTime;
  @override
  @JsonKey(name: 'available_slots')
  final int? availableSlots;
  @override
  @JsonKey(name: 'booked_slots')
  final int? bookedSlots;
  @override
  final int? capacity;

  @override
  String toString() {
    return 'Batch(id: $id, tbrId: $tbrId, startDate: $startDate, endDate: $endDate, startTime: $startTime, availableSlots: $availableSlots, bookedSlots: $bookedSlots, capacity: $capacity)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BatchImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tbrId, tbrId) || other.tbrId == tbrId) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.availableSlots, availableSlots) ||
                other.availableSlots == availableSlots) &&
            (identical(other.bookedSlots, bookedSlots) ||
                other.bookedSlots == bookedSlots) &&
            (identical(other.capacity, capacity) ||
                other.capacity == capacity));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, tbrId, startDate, endDate,
      startTime, availableSlots, bookedSlots, capacity);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BatchImplCopyWith<_$BatchImpl> get copyWith =>
      __$$BatchImplCopyWithImpl<_$BatchImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BatchImplToJson(
      this,
    );
  }
}

abstract class _Batch implements Batch {
  const factory _Batch(
      {final int? id,
      @JsonKey(name: 'tbr_id') final String? tbrId,
      @JsonKey(name: 'start_date') final String? startDate,
      @JsonKey(name: 'end_date') final String? endDate,
      @JsonKey(name: 'start_time') final String? startTime,
      @JsonKey(name: 'available_slots') final int? availableSlots,
      @JsonKey(name: 'booked_slots') final int? bookedSlots,
      final int? capacity}) = _$BatchImpl;

  factory _Batch.fromJson(Map<String, dynamic> json) = _$BatchImpl.fromJson;

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
  @JsonKey(name: 'start_time')
  String? get startTime;
  @override
  @JsonKey(name: 'available_slots')
  int? get availableSlots;
  @override
  @JsonKey(name: 'booked_slots')
  int? get bookedSlots;
  @override
  int? get capacity;
  @override
  @JsonKey(ignore: true)
  _$$BatchImplCopyWith<_$BatchImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TravelersDataModel _$TravelersDataModelFromJson(Map<String, dynamic> json) {
  return _TravelersDataModel.fromJson(json);
}

/// @nodoc
mixin _$TravelersDataModel {
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'booking_id')
  int? get bookingId => throw _privateConstructorUsedError;
  @JsonKey(name: 'traveler_id')
  int? get travelerId => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_primary')
  bool? get isPrimary => throw _privateConstructorUsedError;
  Traveler? get traveler => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TravelersDataModelCopyWith<TravelersDataModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TravelersDataModelCopyWith<$Res> {
  factory $TravelersDataModelCopyWith(
          TravelersDataModel value, $Res Function(TravelersDataModel) then) =
      _$TravelersDataModelCopyWithImpl<$Res, TravelersDataModel>;
  @useResult
  $Res call(
      {int? id,
      @JsonKey(name: 'booking_id') int? bookingId,
      @JsonKey(name: 'traveler_id') int? travelerId,
      @JsonKey(name: 'is_primary') bool? isPrimary,
      Traveler? traveler});

  $TravelerCopyWith<$Res>? get traveler;
}

/// @nodoc
class _$TravelersDataModelCopyWithImpl<$Res, $Val extends TravelersDataModel>
    implements $TravelersDataModelCopyWith<$Res> {
  _$TravelersDataModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? bookingId = freezed,
    Object? travelerId = freezed,
    Object? isPrimary = freezed,
    Object? traveler = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      bookingId: freezed == bookingId
          ? _value.bookingId
          : bookingId // ignore: cast_nullable_to_non_nullable
              as int?,
      travelerId: freezed == travelerId
          ? _value.travelerId
          : travelerId // ignore: cast_nullable_to_non_nullable
              as int?,
      isPrimary: freezed == isPrimary
          ? _value.isPrimary
          : isPrimary // ignore: cast_nullable_to_non_nullable
              as bool?,
      traveler: freezed == traveler
          ? _value.traveler
          : traveler // ignore: cast_nullable_to_non_nullable
              as Traveler?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $TravelerCopyWith<$Res>? get traveler {
    if (_value.traveler == null) {
      return null;
    }

    return $TravelerCopyWith<$Res>(_value.traveler!, (value) {
      return _then(_value.copyWith(traveler: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TravelersDataModelImplCopyWith<$Res>
    implements $TravelersDataModelCopyWith<$Res> {
  factory _$$TravelersDataModelImplCopyWith(_$TravelersDataModelImpl value,
          $Res Function(_$TravelersDataModelImpl) then) =
      __$$TravelersDataModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? id,
      @JsonKey(name: 'booking_id') int? bookingId,
      @JsonKey(name: 'traveler_id') int? travelerId,
      @JsonKey(name: 'is_primary') bool? isPrimary,
      Traveler? traveler});

  @override
  $TravelerCopyWith<$Res>? get traveler;
}

/// @nodoc
class __$$TravelersDataModelImplCopyWithImpl<$Res>
    extends _$TravelersDataModelCopyWithImpl<$Res, _$TravelersDataModelImpl>
    implements _$$TravelersDataModelImplCopyWith<$Res> {
  __$$TravelersDataModelImplCopyWithImpl(_$TravelersDataModelImpl _value,
      $Res Function(_$TravelersDataModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? bookingId = freezed,
    Object? travelerId = freezed,
    Object? isPrimary = freezed,
    Object? traveler = freezed,
  }) {
    return _then(_$TravelersDataModelImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      bookingId: freezed == bookingId
          ? _value.bookingId
          : bookingId // ignore: cast_nullable_to_non_nullable
              as int?,
      travelerId: freezed == travelerId
          ? _value.travelerId
          : travelerId // ignore: cast_nullable_to_non_nullable
              as int?,
      isPrimary: freezed == isPrimary
          ? _value.isPrimary
          : isPrimary // ignore: cast_nullable_to_non_nullable
              as bool?,
      traveler: freezed == traveler
          ? _value.traveler
          : traveler // ignore: cast_nullable_to_non_nullable
              as Traveler?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TravelersDataModelImpl implements _TravelersDataModel {
  const _$TravelersDataModelImpl(
      {this.id,
      @JsonKey(name: 'booking_id') this.bookingId,
      @JsonKey(name: 'traveler_id') this.travelerId,
      @JsonKey(name: 'is_primary') this.isPrimary,
      this.traveler});

  factory _$TravelersDataModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TravelersDataModelImplFromJson(json);

  @override
  final int? id;
  @override
  @JsonKey(name: 'booking_id')
  final int? bookingId;
  @override
  @JsonKey(name: 'traveler_id')
  final int? travelerId;
  @override
  @JsonKey(name: 'is_primary')
  final bool? isPrimary;
  @override
  final Traveler? traveler;

  @override
  String toString() {
    return 'TravelersDataModel(id: $id, bookingId: $bookingId, travelerId: $travelerId, isPrimary: $isPrimary, traveler: $traveler)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TravelersDataModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.bookingId, bookingId) ||
                other.bookingId == bookingId) &&
            (identical(other.travelerId, travelerId) ||
                other.travelerId == travelerId) &&
            (identical(other.isPrimary, isPrimary) ||
                other.isPrimary == isPrimary) &&
            (identical(other.traveler, traveler) ||
                other.traveler == traveler));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, bookingId, travelerId, isPrimary, traveler);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TravelersDataModelImplCopyWith<_$TravelersDataModelImpl> get copyWith =>
      __$$TravelersDataModelImplCopyWithImpl<_$TravelersDataModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TravelersDataModelImplToJson(
      this,
    );
  }
}

abstract class _TravelersDataModel implements TravelersDataModel {
  const factory _TravelersDataModel(
      {final int? id,
      @JsonKey(name: 'booking_id') final int? bookingId,
      @JsonKey(name: 'traveler_id') final int? travelerId,
      @JsonKey(name: 'is_primary') final bool? isPrimary,
      final Traveler? traveler}) = _$TravelersDataModelImpl;

  factory _TravelersDataModel.fromJson(Map<String, dynamic> json) =
      _$TravelersDataModelImpl.fromJson;

  @override
  int? get id;
  @override
  @JsonKey(name: 'booking_id')
  int? get bookingId;
  @override
  @JsonKey(name: 'traveler_id')
  int? get travelerId;
  @override
  @JsonKey(name: 'is_primary')
  bool? get isPrimary;
  @override
  Traveler? get traveler;
  @override
  @JsonKey(ignore: true)
  _$$TravelersDataModelImplCopyWith<_$TravelersDataModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Pagination _$PaginationFromJson(Map<String, dynamic> json) {
  return _Pagination.fromJson(json);
}

/// @nodoc
mixin _$Pagination {
  int? get currentPage => throw _privateConstructorUsedError;
  int? get totalPages => throw _privateConstructorUsedError;
  int? get totalCount => throw _privateConstructorUsedError;
  int? get limit => throw _privateConstructorUsedError;
  bool? get hasNextPage => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PaginationCopyWith<Pagination> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaginationCopyWith<$Res> {
  factory $PaginationCopyWith(
          Pagination value, $Res Function(Pagination) then) =
      _$PaginationCopyWithImpl<$Res, Pagination>;
  @useResult
  $Res call(
      {int? currentPage,
      int? totalPages,
      int? totalCount,
      int? limit,
      bool? hasNextPage});
}

/// @nodoc
class _$PaginationCopyWithImpl<$Res, $Val extends Pagination>
    implements $PaginationCopyWith<$Res> {
  _$PaginationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentPage = freezed,
    Object? totalPages = freezed,
    Object? totalCount = freezed,
    Object? limit = freezed,
    Object? hasNextPage = freezed,
  }) {
    return _then(_value.copyWith(
      currentPage: freezed == currentPage
          ? _value.currentPage
          : currentPage // ignore: cast_nullable_to_non_nullable
              as int?,
      totalPages: freezed == totalPages
          ? _value.totalPages
          : totalPages // ignore: cast_nullable_to_non_nullable
              as int?,
      totalCount: freezed == totalCount
          ? _value.totalCount
          : totalCount // ignore: cast_nullable_to_non_nullable
              as int?,
      limit: freezed == limit
          ? _value.limit
          : limit // ignore: cast_nullable_to_non_nullable
              as int?,
      hasNextPage: freezed == hasNextPage
          ? _value.hasNextPage
          : hasNextPage // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PaginationImplCopyWith<$Res>
    implements $PaginationCopyWith<$Res> {
  factory _$$PaginationImplCopyWith(
          _$PaginationImpl value, $Res Function(_$PaginationImpl) then) =
      __$$PaginationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? currentPage,
      int? totalPages,
      int? totalCount,
      int? limit,
      bool? hasNextPage});
}

/// @nodoc
class __$$PaginationImplCopyWithImpl<$Res>
    extends _$PaginationCopyWithImpl<$Res, _$PaginationImpl>
    implements _$$PaginationImplCopyWith<$Res> {
  __$$PaginationImplCopyWithImpl(
      _$PaginationImpl _value, $Res Function(_$PaginationImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentPage = freezed,
    Object? totalPages = freezed,
    Object? totalCount = freezed,
    Object? limit = freezed,
    Object? hasNextPage = freezed,
  }) {
    return _then(_$PaginationImpl(
      currentPage: freezed == currentPage
          ? _value.currentPage
          : currentPage // ignore: cast_nullable_to_non_nullable
              as int?,
      totalPages: freezed == totalPages
          ? _value.totalPages
          : totalPages // ignore: cast_nullable_to_non_nullable
              as int?,
      totalCount: freezed == totalCount
          ? _value.totalCount
          : totalCount // ignore: cast_nullable_to_non_nullable
              as int?,
      limit: freezed == limit
          ? _value.limit
          : limit // ignore: cast_nullable_to_non_nullable
              as int?,
      hasNextPage: freezed == hasNextPage
          ? _value.hasNextPage
          : hasNextPage // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PaginationImpl implements _Pagination {
  const _$PaginationImpl(
      {this.currentPage,
      this.totalPages,
      this.totalCount,
      this.limit,
      this.hasNextPage});

  factory _$PaginationImpl.fromJson(Map<String, dynamic> json) =>
      _$$PaginationImplFromJson(json);

  @override
  final int? currentPage;
  @override
  final int? totalPages;
  @override
  final int? totalCount;
  @override
  final int? limit;
  @override
  final bool? hasNextPage;

  @override
  String toString() {
    return 'Pagination(currentPage: $currentPage, totalPages: $totalPages, totalCount: $totalCount, limit: $limit, hasNextPage: $hasNextPage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaginationImpl &&
            (identical(other.currentPage, currentPage) ||
                other.currentPage == currentPage) &&
            (identical(other.totalPages, totalPages) ||
                other.totalPages == totalPages) &&
            (identical(other.totalCount, totalCount) ||
                other.totalCount == totalCount) &&
            (identical(other.limit, limit) || other.limit == limit) &&
            (identical(other.hasNextPage, hasNextPage) ||
                other.hasNextPage == hasNextPage));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, currentPage, totalPages, totalCount, limit, hasNextPage);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PaginationImplCopyWith<_$PaginationImpl> get copyWith =>
      __$$PaginationImplCopyWithImpl<_$PaginationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PaginationImplToJson(
      this,
    );
  }
}

abstract class _Pagination implements Pagination {
  const factory _Pagination(
      {final int? currentPage,
      final int? totalPages,
      final int? totalCount,
      final int? limit,
      final bool? hasNextPage}) = _$PaginationImpl;

  factory _Pagination.fromJson(Map<String, dynamic> json) =
      _$PaginationImpl.fromJson;

  @override
  int? get currentPage;
  @override
  int? get totalPages;
  @override
  int? get totalCount;
  @override
  int? get limit;
  @override
  bool? get hasNextPage;
  @override
  @JsonKey(ignore: true)
  _$$PaginationImplCopyWith<_$PaginationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
