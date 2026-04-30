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
  int? get vendorIdAlt => throw _privateConstructorUsedError; // API extra key
  @JsonKey(name: 'batch_id')
  int? get batchId => throw _privateConstructorUsedError;
  @JsonKey(name: 'coupon_id')
  int? get couponId => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_travelers')
  int? get totalTravelers =>
      throw _privateConstructorUsedError; // ✅ SAFE STRING CONVERSION
  @JsonKey(name: 'total_amount', fromJson: _toString)
  String? get totalAmount => throw _privateConstructorUsedError;
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
  Trek? get trek => throw _privateConstructorUsedError;
  Batch? get batch => throw _privateConstructorUsedError;
  List<TravelersDataModel>? get travelers => throw _privateConstructorUsedError;
  @JsonKey(name: 'trek_status')
  String? get trekStatus => throw _privateConstructorUsedError;
  @JsonKey(name: 'rating_given')
  bool? get ratingGiven => throw _privateConstructorUsedError;
  @JsonKey(name: 'rating_value')
  double? get ratingValue => throw _privateConstructorUsedError;
  @JsonKey(name: 'trek_stage_date_time')
  String? get trekStageDateTime => throw _privateConstructorUsedError;
  @JsonKey(name: 'trek_stage_name')
  String? get trekStageName => throw _privateConstructorUsedError;

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
      Trek? trek,
      Batch? batch,
      List<TravelersDataModel>? travelers,
      @JsonKey(name: 'trek_status') String? trekStatus,
      @JsonKey(name: 'rating_given') bool? ratingGiven,
      @JsonKey(name: 'rating_value') double? ratingValue,
      @JsonKey(name: 'trek_stage_date_time') String? trekStageDateTime,
      @JsonKey(name: 'trek_stage_name') String? trekStageName});

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
    Object? trek = freezed,
    Object? batch = freezed,
    Object? travelers = freezed,
    Object? trekStatus = freezed,
    Object? ratingGiven = freezed,
    Object? ratingValue = freezed,
    Object? trekStageDateTime = freezed,
    Object? trekStageName = freezed,
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
              as double?,
      trekStageDateTime: freezed == trekStageDateTime
          ? _value.trekStageDateTime
          : trekStageDateTime // ignore: cast_nullable_to_non_nullable
              as String?,
      trekStageName: freezed == trekStageName
          ? _value.trekStageName
          : trekStageName // ignore: cast_nullable_to_non_nullable
              as String?,
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
      Trek? trek,
      Batch? batch,
      List<TravelersDataModel>? travelers,
      @JsonKey(name: 'trek_status') String? trekStatus,
      @JsonKey(name: 'rating_given') bool? ratingGiven,
      @JsonKey(name: 'rating_value') double? ratingValue,
      @JsonKey(name: 'trek_stage_date_time') String? trekStageDateTime,
      @JsonKey(name: 'trek_stage_name') String? trekStageName});

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
    Object? trek = freezed,
    Object? batch = freezed,
    Object? travelers = freezed,
    Object? trekStatus = freezed,
    Object? ratingGiven = freezed,
    Object? ratingValue = freezed,
    Object? trekStageDateTime = freezed,
    Object? trekStageName = freezed,
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
              as double?,
      trekStageDateTime: freezed == trekStageDateTime
          ? _value.trekStageDateTime
          : trekStageDateTime // ignore: cast_nullable_to_non_nullable
              as String?,
      trekStageName: freezed == trekStageName
          ? _value.trekStageName
          : trekStageName // ignore: cast_nullable_to_non_nullable
              as String?,
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
      this.trek,
      this.batch,
      final List<TravelersDataModel>? travelers,
      @JsonKey(name: 'trek_status') this.trekStatus,
      @JsonKey(name: 'rating_given') this.ratingGiven,
      @JsonKey(name: 'rating_value') this.ratingValue,
      @JsonKey(name: 'trek_stage_date_time') this.trekStageDateTime,
      @JsonKey(name: 'trek_stage_name') this.trekStageName})
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
// API extra key
  @override
  @JsonKey(name: 'batch_id')
  final int? batchId;
  @override
  @JsonKey(name: 'coupon_id')
  final int? couponId;
  @override
  @JsonKey(name: 'total_travelers')
  final int? totalTravelers;
// ✅ SAFE STRING CONVERSION
  @override
  @JsonKey(name: 'total_amount', fromJson: _toString)
  final String? totalAmount;
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
  @JsonKey(name: 'trek_status')
  final String? trekStatus;
  @override
  @JsonKey(name: 'rating_given')
  final bool? ratingGiven;
  @override
  @JsonKey(name: 'rating_value')
  final double? ratingValue;
  @override
  @JsonKey(name: 'trek_stage_date_time')
  final String? trekStageDateTime;
  @override
  @JsonKey(name: 'trek_stage_name')
  final String? trekStageName;

  @override
  String toString() {
    return 'BookingHistoryData(id: $id, customerId: $customerId, trekId: $trekId, vendorId: $vendorId, vendorIdAlt: $vendorIdAlt, batchId: $batchId, couponId: $couponId, totalTravelers: $totalTravelers, totalAmount: $totalAmount, discountAmount: $discountAmount, finalAmount: $finalAmount, paymentStatus: $paymentStatus, status: $status, bookingDate: $bookingDate, specialRequests: $specialRequests, bookingSource: $bookingSource, primaryContactTravelerId: $primaryContactTravelerId, createdAt: $createdAt, updatedAt: $updatedAt, userId: $userId, cityId: $cityId, trek: $trek, batch: $batch, travelers: $travelers, trekStatus: $trekStatus, ratingGiven: $ratingGiven, ratingValue: $ratingValue, trekStageDateTime: $trekStageDateTime, trekStageName: $trekStageName)';
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
            (identical(other.trek, trek) || other.trek == trek) &&
            (identical(other.batch, batch) || other.batch == batch) &&
            const DeepCollectionEquality()
                .equals(other._travelers, _travelers) &&
            (identical(other.trekStatus, trekStatus) ||
                other.trekStatus == trekStatus) &&
            (identical(other.ratingGiven, ratingGiven) ||
                other.ratingGiven == ratingGiven) &&
            (identical(other.ratingValue, ratingValue) ||
                other.ratingValue == ratingValue) &&
            (identical(other.trekStageDateTime, trekStageDateTime) ||
                other.trekStageDateTime == trekStageDateTime) &&
            (identical(other.trekStageName, trekStageName) ||
                other.trekStageName == trekStageName));
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
        trek,
        batch,
        const DeepCollectionEquality().hash(_travelers),
        trekStatus,
        ratingGiven,
        ratingValue,
        trekStageDateTime,
        trekStageName
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
      final Trek? trek,
      final Batch? batch,
      final List<TravelersDataModel>? travelers,
      @JsonKey(name: 'trek_status') final String? trekStatus,
      @JsonKey(name: 'rating_given') final bool? ratingGiven,
      @JsonKey(name: 'rating_value') final double? ratingValue,
      @JsonKey(name: 'trek_stage_date_time') final String? trekStageDateTime,
      @JsonKey(name: 'trek_stage_name')
      final String? trekStageName}) = _$BookingHistoryDataImpl;

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
  @override // API extra key
  @JsonKey(name: 'batch_id')
  int? get batchId;
  @override
  @JsonKey(name: 'coupon_id')
  int? get couponId;
  @override
  @JsonKey(name: 'total_travelers')
  int? get totalTravelers;
  @override // ✅ SAFE STRING CONVERSION
  @JsonKey(name: 'total_amount', fromJson: _toString)
  String? get totalAmount;
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
  Trek? get trek;
  @override
  Batch? get batch;
  @override
  List<TravelersDataModel>? get travelers;
  @override
  @JsonKey(name: 'trek_status')
  String? get trekStatus;
  @override
  @JsonKey(name: 'rating_given')
  bool? get ratingGiven;
  @override
  @JsonKey(name: 'rating_value')
  double? get ratingValue;
  @override
  @JsonKey(name: 'trek_stage_date_time')
  String? get trekStageDateTime;
  @override
  @JsonKey(name: 'trek_stage_name')
  String? get trekStageName;
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
  @JsonKey(name: 'city_ids')
  List<int>? get cityIds => throw _privateConstructorUsedError;
  List<String>? get inclusions => throw _privateConstructorUsedError;
  List<String>? get exclusions => throw _privateConstructorUsedError;
  List<int>? get activities => throw _privateConstructorUsedError;
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'mtr_id')
  String? get mtrId => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'VendorId')
  int? get vendorId => throw _privateConstructorUsedError;
  @JsonKey(name: 'destination_id')
  int? get destinationId => throw _privateConstructorUsedError;
  @JsonKey(name: 'captain_id')
  int? get captainId => throw _privateConstructorUsedError;
  String? get duration => throw _privateConstructorUsedError;
  @JsonKey(name: 'duration_days')
  int? get durationDays => throw _privateConstructorUsedError;
  @JsonKey(name: 'duration_nights')
  int? get durationNights => throw _privateConstructorUsedError;
  @JsonKey(name: 'base_price')
  String? get basePrice => throw _privateConstructorUsedError;
  @JsonKey(name: 'max_participants')
  int? get maxParticipants => throw _privateConstructorUsedError;
  @JsonKey(name: 'trekking_rules')
  String? get trekkingRules => throw _privateConstructorUsedError;
  @JsonKey(name: 'emergency_protocols')
  String? get emergencyProtocols => throw _privateConstructorUsedError;
  @JsonKey(name: 'organizer_notes')
  String? get organizerNotes => throw _privateConstructorUsedError;
  String? get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'discount_value')
  String? get discountValue => throw _privateConstructorUsedError;
  @JsonKey(name: 'discount_type')
  String? get discountType => throw _privateConstructorUsedError;
  @JsonKey(name: 'has_discount')
  bool? get hasDiscount => throw _privateConstructorUsedError;
  @JsonKey(name: 'cancellation_policy_id')
  int? get cancellationPolicyId => throw _privateConstructorUsedError;
  @JsonKey(name: 'badge_id')
  int? get badgeId => throw _privateConstructorUsedError;
  @JsonKey(name: 'has_been_edited')
  int? get hasBeenEdited => throw _privateConstructorUsedError;
  @JsonKey(name: 'safety_security_count')
  int? get safetySecurityCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'organizer_manner_count')
  int? get organizerMannerCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'trek_planning_count')
  int? get trekPlanningCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'women_safety_count')
  int? get womenSafetyCount => throw _privateConstructorUsedError;
  String? get createdAt => throw _privateConstructorUsedError;
  String? get updatedAt => throw _privateConstructorUsedError;
  Vendor? get vendor => throw _privateConstructorUsedError;
  int? get rating => throw _privateConstructorUsedError;
  int? get ratingCount => throw _privateConstructorUsedError;
  Destination? get destination => throw _privateConstructorUsedError;
  @JsonKey(name: 'captain_name')
  String? get captainName => throw _privateConstructorUsedError;
  @JsonKey(name: 'captain_phone')
  String? get captainPhone => throw _privateConstructorUsedError;

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
      {@JsonKey(name: 'city_ids') List<int>? cityIds,
      List<String>? inclusions,
      List<String>? exclusions,
      List<int>? activities,
      int? id,
      @JsonKey(name: 'mtr_id') String? mtrId,
      String? title,
      String? description,
      @JsonKey(name: 'VendorId') int? vendorId,
      @JsonKey(name: 'destination_id') int? destinationId,
      @JsonKey(name: 'captain_id') int? captainId,
      String? duration,
      @JsonKey(name: 'duration_days') int? durationDays,
      @JsonKey(name: 'duration_nights') int? durationNights,
      @JsonKey(name: 'base_price') String? basePrice,
      @JsonKey(name: 'max_participants') int? maxParticipants,
      @JsonKey(name: 'trekking_rules') String? trekkingRules,
      @JsonKey(name: 'emergency_protocols') String? emergencyProtocols,
      @JsonKey(name: 'organizer_notes') String? organizerNotes,
      String? status,
      @JsonKey(name: 'discount_value') String? discountValue,
      @JsonKey(name: 'discount_type') String? discountType,
      @JsonKey(name: 'has_discount') bool? hasDiscount,
      @JsonKey(name: 'cancellation_policy_id') int? cancellationPolicyId,
      @JsonKey(name: 'badge_id') int? badgeId,
      @JsonKey(name: 'has_been_edited') int? hasBeenEdited,
      @JsonKey(name: 'safety_security_count') int? safetySecurityCount,
      @JsonKey(name: 'organizer_manner_count') int? organizerMannerCount,
      @JsonKey(name: 'trek_planning_count') int? trekPlanningCount,
      @JsonKey(name: 'women_safety_count') int? womenSafetyCount,
      String? createdAt,
      String? updatedAt,
      Vendor? vendor,
      int? rating,
      int? ratingCount,
      Destination? destination,
      @JsonKey(name: 'captain_name') String? captainName,
      @JsonKey(name: 'captain_phone') String? captainPhone});

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
    Object? cityIds = freezed,
    Object? inclusions = freezed,
    Object? exclusions = freezed,
    Object? activities = freezed,
    Object? id = freezed,
    Object? mtrId = freezed,
    Object? title = freezed,
    Object? description = freezed,
    Object? vendorId = freezed,
    Object? destinationId = freezed,
    Object? captainId = freezed,
    Object? duration = freezed,
    Object? durationDays = freezed,
    Object? durationNights = freezed,
    Object? basePrice = freezed,
    Object? maxParticipants = freezed,
    Object? trekkingRules = freezed,
    Object? emergencyProtocols = freezed,
    Object? organizerNotes = freezed,
    Object? status = freezed,
    Object? discountValue = freezed,
    Object? discountType = freezed,
    Object? hasDiscount = freezed,
    Object? cancellationPolicyId = freezed,
    Object? badgeId = freezed,
    Object? hasBeenEdited = freezed,
    Object? safetySecurityCount = freezed,
    Object? organizerMannerCount = freezed,
    Object? trekPlanningCount = freezed,
    Object? womenSafetyCount = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? vendor = freezed,
    Object? rating = freezed,
    Object? ratingCount = freezed,
    Object? destination = freezed,
    Object? captainName = freezed,
    Object? captainPhone = freezed,
  }) {
    return _then(_value.copyWith(
      cityIds: freezed == cityIds
          ? _value.cityIds
          : cityIds // ignore: cast_nullable_to_non_nullable
              as List<int>?,
      inclusions: freezed == inclusions
          ? _value.inclusions
          : inclusions // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      exclusions: freezed == exclusions
          ? _value.exclusions
          : exclusions // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      activities: freezed == activities
          ? _value.activities
          : activities // ignore: cast_nullable_to_non_nullable
              as List<int>?,
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      mtrId: freezed == mtrId
          ? _value.mtrId
          : mtrId // ignore: cast_nullable_to_non_nullable
              as String?,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      vendorId: freezed == vendorId
          ? _value.vendorId
          : vendorId // ignore: cast_nullable_to_non_nullable
              as int?,
      destinationId: freezed == destinationId
          ? _value.destinationId
          : destinationId // ignore: cast_nullable_to_non_nullable
              as int?,
      captainId: freezed == captainId
          ? _value.captainId
          : captainId // ignore: cast_nullable_to_non_nullable
              as int?,
      duration: freezed == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as String?,
      durationDays: freezed == durationDays
          ? _value.durationDays
          : durationDays // ignore: cast_nullable_to_non_nullable
              as int?,
      durationNights: freezed == durationNights
          ? _value.durationNights
          : durationNights // ignore: cast_nullable_to_non_nullable
              as int?,
      basePrice: freezed == basePrice
          ? _value.basePrice
          : basePrice // ignore: cast_nullable_to_non_nullable
              as String?,
      maxParticipants: freezed == maxParticipants
          ? _value.maxParticipants
          : maxParticipants // ignore: cast_nullable_to_non_nullable
              as int?,
      trekkingRules: freezed == trekkingRules
          ? _value.trekkingRules
          : trekkingRules // ignore: cast_nullable_to_non_nullable
              as String?,
      emergencyProtocols: freezed == emergencyProtocols
          ? _value.emergencyProtocols
          : emergencyProtocols // ignore: cast_nullable_to_non_nullable
              as String?,
      organizerNotes: freezed == organizerNotes
          ? _value.organizerNotes
          : organizerNotes // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      discountValue: freezed == discountValue
          ? _value.discountValue
          : discountValue // ignore: cast_nullable_to_non_nullable
              as String?,
      discountType: freezed == discountType
          ? _value.discountType
          : discountType // ignore: cast_nullable_to_non_nullable
              as String?,
      hasDiscount: freezed == hasDiscount
          ? _value.hasDiscount
          : hasDiscount // ignore: cast_nullable_to_non_nullable
              as bool?,
      cancellationPolicyId: freezed == cancellationPolicyId
          ? _value.cancellationPolicyId
          : cancellationPolicyId // ignore: cast_nullable_to_non_nullable
              as int?,
      badgeId: freezed == badgeId
          ? _value.badgeId
          : badgeId // ignore: cast_nullable_to_non_nullable
              as int?,
      hasBeenEdited: freezed == hasBeenEdited
          ? _value.hasBeenEdited
          : hasBeenEdited // ignore: cast_nullable_to_non_nullable
              as int?,
      safetySecurityCount: freezed == safetySecurityCount
          ? _value.safetySecurityCount
          : safetySecurityCount // ignore: cast_nullable_to_non_nullable
              as int?,
      organizerMannerCount: freezed == organizerMannerCount
          ? _value.organizerMannerCount
          : organizerMannerCount // ignore: cast_nullable_to_non_nullable
              as int?,
      trekPlanningCount: freezed == trekPlanningCount
          ? _value.trekPlanningCount
          : trekPlanningCount // ignore: cast_nullable_to_non_nullable
              as int?,
      womenSafetyCount: freezed == womenSafetyCount
          ? _value.womenSafetyCount
          : womenSafetyCount // ignore: cast_nullable_to_non_nullable
              as int?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      vendor: freezed == vendor
          ? _value.vendor
          : vendor // ignore: cast_nullable_to_non_nullable
              as Vendor?,
      rating: freezed == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as int?,
      ratingCount: freezed == ratingCount
          ? _value.ratingCount
          : ratingCount // ignore: cast_nullable_to_non_nullable
              as int?,
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
      {@JsonKey(name: 'city_ids') List<int>? cityIds,
      List<String>? inclusions,
      List<String>? exclusions,
      List<int>? activities,
      int? id,
      @JsonKey(name: 'mtr_id') String? mtrId,
      String? title,
      String? description,
      @JsonKey(name: 'VendorId') int? vendorId,
      @JsonKey(name: 'destination_id') int? destinationId,
      @JsonKey(name: 'captain_id') int? captainId,
      String? duration,
      @JsonKey(name: 'duration_days') int? durationDays,
      @JsonKey(name: 'duration_nights') int? durationNights,
      @JsonKey(name: 'base_price') String? basePrice,
      @JsonKey(name: 'max_participants') int? maxParticipants,
      @JsonKey(name: 'trekking_rules') String? trekkingRules,
      @JsonKey(name: 'emergency_protocols') String? emergencyProtocols,
      @JsonKey(name: 'organizer_notes') String? organizerNotes,
      String? status,
      @JsonKey(name: 'discount_value') String? discountValue,
      @JsonKey(name: 'discount_type') String? discountType,
      @JsonKey(name: 'has_discount') bool? hasDiscount,
      @JsonKey(name: 'cancellation_policy_id') int? cancellationPolicyId,
      @JsonKey(name: 'badge_id') int? badgeId,
      @JsonKey(name: 'has_been_edited') int? hasBeenEdited,
      @JsonKey(name: 'safety_security_count') int? safetySecurityCount,
      @JsonKey(name: 'organizer_manner_count') int? organizerMannerCount,
      @JsonKey(name: 'trek_planning_count') int? trekPlanningCount,
      @JsonKey(name: 'women_safety_count') int? womenSafetyCount,
      String? createdAt,
      String? updatedAt,
      Vendor? vendor,
      int? rating,
      int? ratingCount,
      Destination? destination,
      @JsonKey(name: 'captain_name') String? captainName,
      @JsonKey(name: 'captain_phone') String? captainPhone});

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
    Object? cityIds = freezed,
    Object? inclusions = freezed,
    Object? exclusions = freezed,
    Object? activities = freezed,
    Object? id = freezed,
    Object? mtrId = freezed,
    Object? title = freezed,
    Object? description = freezed,
    Object? vendorId = freezed,
    Object? destinationId = freezed,
    Object? captainId = freezed,
    Object? duration = freezed,
    Object? durationDays = freezed,
    Object? durationNights = freezed,
    Object? basePrice = freezed,
    Object? maxParticipants = freezed,
    Object? trekkingRules = freezed,
    Object? emergencyProtocols = freezed,
    Object? organizerNotes = freezed,
    Object? status = freezed,
    Object? discountValue = freezed,
    Object? discountType = freezed,
    Object? hasDiscount = freezed,
    Object? cancellationPolicyId = freezed,
    Object? badgeId = freezed,
    Object? hasBeenEdited = freezed,
    Object? safetySecurityCount = freezed,
    Object? organizerMannerCount = freezed,
    Object? trekPlanningCount = freezed,
    Object? womenSafetyCount = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? vendor = freezed,
    Object? rating = freezed,
    Object? ratingCount = freezed,
    Object? destination = freezed,
    Object? captainName = freezed,
    Object? captainPhone = freezed,
  }) {
    return _then(_$TrekImpl(
      cityIds: freezed == cityIds
          ? _value._cityIds
          : cityIds // ignore: cast_nullable_to_non_nullable
              as List<int>?,
      inclusions: freezed == inclusions
          ? _value._inclusions
          : inclusions // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      exclusions: freezed == exclusions
          ? _value._exclusions
          : exclusions // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      activities: freezed == activities
          ? _value._activities
          : activities // ignore: cast_nullable_to_non_nullable
              as List<int>?,
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      mtrId: freezed == mtrId
          ? _value.mtrId
          : mtrId // ignore: cast_nullable_to_non_nullable
              as String?,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      vendorId: freezed == vendorId
          ? _value.vendorId
          : vendorId // ignore: cast_nullable_to_non_nullable
              as int?,
      destinationId: freezed == destinationId
          ? _value.destinationId
          : destinationId // ignore: cast_nullable_to_non_nullable
              as int?,
      captainId: freezed == captainId
          ? _value.captainId
          : captainId // ignore: cast_nullable_to_non_nullable
              as int?,
      duration: freezed == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as String?,
      durationDays: freezed == durationDays
          ? _value.durationDays
          : durationDays // ignore: cast_nullable_to_non_nullable
              as int?,
      durationNights: freezed == durationNights
          ? _value.durationNights
          : durationNights // ignore: cast_nullable_to_non_nullable
              as int?,
      basePrice: freezed == basePrice
          ? _value.basePrice
          : basePrice // ignore: cast_nullable_to_non_nullable
              as String?,
      maxParticipants: freezed == maxParticipants
          ? _value.maxParticipants
          : maxParticipants // ignore: cast_nullable_to_non_nullable
              as int?,
      trekkingRules: freezed == trekkingRules
          ? _value.trekkingRules
          : trekkingRules // ignore: cast_nullable_to_non_nullable
              as String?,
      emergencyProtocols: freezed == emergencyProtocols
          ? _value.emergencyProtocols
          : emergencyProtocols // ignore: cast_nullable_to_non_nullable
              as String?,
      organizerNotes: freezed == organizerNotes
          ? _value.organizerNotes
          : organizerNotes // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      discountValue: freezed == discountValue
          ? _value.discountValue
          : discountValue // ignore: cast_nullable_to_non_nullable
              as String?,
      discountType: freezed == discountType
          ? _value.discountType
          : discountType // ignore: cast_nullable_to_non_nullable
              as String?,
      hasDiscount: freezed == hasDiscount
          ? _value.hasDiscount
          : hasDiscount // ignore: cast_nullable_to_non_nullable
              as bool?,
      cancellationPolicyId: freezed == cancellationPolicyId
          ? _value.cancellationPolicyId
          : cancellationPolicyId // ignore: cast_nullable_to_non_nullable
              as int?,
      badgeId: freezed == badgeId
          ? _value.badgeId
          : badgeId // ignore: cast_nullable_to_non_nullable
              as int?,
      hasBeenEdited: freezed == hasBeenEdited
          ? _value.hasBeenEdited
          : hasBeenEdited // ignore: cast_nullable_to_non_nullable
              as int?,
      safetySecurityCount: freezed == safetySecurityCount
          ? _value.safetySecurityCount
          : safetySecurityCount // ignore: cast_nullable_to_non_nullable
              as int?,
      organizerMannerCount: freezed == organizerMannerCount
          ? _value.organizerMannerCount
          : organizerMannerCount // ignore: cast_nullable_to_non_nullable
              as int?,
      trekPlanningCount: freezed == trekPlanningCount
          ? _value.trekPlanningCount
          : trekPlanningCount // ignore: cast_nullable_to_non_nullable
              as int?,
      womenSafetyCount: freezed == womenSafetyCount
          ? _value.womenSafetyCount
          : womenSafetyCount // ignore: cast_nullable_to_non_nullable
              as int?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      vendor: freezed == vendor
          ? _value.vendor
          : vendor // ignore: cast_nullable_to_non_nullable
              as Vendor?,
      rating: freezed == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as int?,
      ratingCount: freezed == ratingCount
          ? _value.ratingCount
          : ratingCount // ignore: cast_nullable_to_non_nullable
              as int?,
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
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TrekImpl implements _Trek {
  const _$TrekImpl(
      {@JsonKey(name: 'city_ids') final List<int>? cityIds,
      final List<String>? inclusions,
      final List<String>? exclusions,
      final List<int>? activities,
      this.id,
      @JsonKey(name: 'mtr_id') this.mtrId,
      this.title,
      this.description,
      @JsonKey(name: 'VendorId') this.vendorId,
      @JsonKey(name: 'destination_id') this.destinationId,
      @JsonKey(name: 'captain_id') this.captainId,
      this.duration,
      @JsonKey(name: 'duration_days') this.durationDays,
      @JsonKey(name: 'duration_nights') this.durationNights,
      @JsonKey(name: 'base_price') this.basePrice,
      @JsonKey(name: 'max_participants') this.maxParticipants,
      @JsonKey(name: 'trekking_rules') this.trekkingRules,
      @JsonKey(name: 'emergency_protocols') this.emergencyProtocols,
      @JsonKey(name: 'organizer_notes') this.organizerNotes,
      this.status,
      @JsonKey(name: 'discount_value') this.discountValue,
      @JsonKey(name: 'discount_type') this.discountType,
      @JsonKey(name: 'has_discount') this.hasDiscount,
      @JsonKey(name: 'cancellation_policy_id') this.cancellationPolicyId,
      @JsonKey(name: 'badge_id') this.badgeId,
      @JsonKey(name: 'has_been_edited') this.hasBeenEdited,
      @JsonKey(name: 'safety_security_count') this.safetySecurityCount,
      @JsonKey(name: 'organizer_manner_count') this.organizerMannerCount,
      @JsonKey(name: 'trek_planning_count') this.trekPlanningCount,
      @JsonKey(name: 'women_safety_count') this.womenSafetyCount,
      this.createdAt,
      this.updatedAt,
      this.vendor,
      this.rating,
      this.ratingCount,
      this.destination,
      @JsonKey(name: 'captain_name') this.captainName,
      @JsonKey(name: 'captain_phone') this.captainPhone})
      : _cityIds = cityIds,
        _inclusions = inclusions,
        _exclusions = exclusions,
        _activities = activities;

  factory _$TrekImpl.fromJson(Map<String, dynamic> json) =>
      _$$TrekImplFromJson(json);

  final List<int>? _cityIds;
  @override
  @JsonKey(name: 'city_ids')
  List<int>? get cityIds {
    final value = _cityIds;
    if (value == null) return null;
    if (_cityIds is EqualUnmodifiableListView) return _cityIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _inclusions;
  @override
  List<String>? get inclusions {
    final value = _inclusions;
    if (value == null) return null;
    if (_inclusions is EqualUnmodifiableListView) return _inclusions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _exclusions;
  @override
  List<String>? get exclusions {
    final value = _exclusions;
    if (value == null) return null;
    if (_exclusions is EqualUnmodifiableListView) return _exclusions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<int>? _activities;
  @override
  List<int>? get activities {
    final value = _activities;
    if (value == null) return null;
    if (_activities is EqualUnmodifiableListView) return _activities;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final int? id;
  @override
  @JsonKey(name: 'mtr_id')
  final String? mtrId;
  @override
  final String? title;
  @override
  final String? description;
  @override
  @JsonKey(name: 'VendorId')
  final int? vendorId;
  @override
  @JsonKey(name: 'destination_id')
  final int? destinationId;
  @override
  @JsonKey(name: 'captain_id')
  final int? captainId;
  @override
  final String? duration;
  @override
  @JsonKey(name: 'duration_days')
  final int? durationDays;
  @override
  @JsonKey(name: 'duration_nights')
  final int? durationNights;
  @override
  @JsonKey(name: 'base_price')
  final String? basePrice;
  @override
  @JsonKey(name: 'max_participants')
  final int? maxParticipants;
  @override
  @JsonKey(name: 'trekking_rules')
  final String? trekkingRules;
  @override
  @JsonKey(name: 'emergency_protocols')
  final String? emergencyProtocols;
  @override
  @JsonKey(name: 'organizer_notes')
  final String? organizerNotes;
  @override
  final String? status;
  @override
  @JsonKey(name: 'discount_value')
  final String? discountValue;
  @override
  @JsonKey(name: 'discount_type')
  final String? discountType;
  @override
  @JsonKey(name: 'has_discount')
  final bool? hasDiscount;
  @override
  @JsonKey(name: 'cancellation_policy_id')
  final int? cancellationPolicyId;
  @override
  @JsonKey(name: 'badge_id')
  final int? badgeId;
  @override
  @JsonKey(name: 'has_been_edited')
  final int? hasBeenEdited;
  @override
  @JsonKey(name: 'safety_security_count')
  final int? safetySecurityCount;
  @override
  @JsonKey(name: 'organizer_manner_count')
  final int? organizerMannerCount;
  @override
  @JsonKey(name: 'trek_planning_count')
  final int? trekPlanningCount;
  @override
  @JsonKey(name: 'women_safety_count')
  final int? womenSafetyCount;
  @override
  final String? createdAt;
  @override
  final String? updatedAt;
  @override
  final Vendor? vendor;
  @override
  final int? rating;
  @override
  final int? ratingCount;
  @override
  final Destination? destination;
  @override
  @JsonKey(name: 'captain_name')
  final String? captainName;
  @override
  @JsonKey(name: 'captain_phone')
  final String? captainPhone;

  @override
  String toString() {
    return 'Trek(cityIds: $cityIds, inclusions: $inclusions, exclusions: $exclusions, activities: $activities, id: $id, mtrId: $mtrId, title: $title, description: $description, vendorId: $vendorId, destinationId: $destinationId, captainId: $captainId, duration: $duration, durationDays: $durationDays, durationNights: $durationNights, basePrice: $basePrice, maxParticipants: $maxParticipants, trekkingRules: $trekkingRules, emergencyProtocols: $emergencyProtocols, organizerNotes: $organizerNotes, status: $status, discountValue: $discountValue, discountType: $discountType, hasDiscount: $hasDiscount, cancellationPolicyId: $cancellationPolicyId, badgeId: $badgeId, hasBeenEdited: $hasBeenEdited, safetySecurityCount: $safetySecurityCount, organizerMannerCount: $organizerMannerCount, trekPlanningCount: $trekPlanningCount, womenSafetyCount: $womenSafetyCount, createdAt: $createdAt, updatedAt: $updatedAt, vendor: $vendor, rating: $rating, ratingCount: $ratingCount, destination: $destination, captainName: $captainName, captainPhone: $captainPhone)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrekImpl &&
            const DeepCollectionEquality().equals(other._cityIds, _cityIds) &&
            const DeepCollectionEquality()
                .equals(other._inclusions, _inclusions) &&
            const DeepCollectionEquality()
                .equals(other._exclusions, _exclusions) &&
            const DeepCollectionEquality()
                .equals(other._activities, _activities) &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.mtrId, mtrId) || other.mtrId == mtrId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.vendorId, vendorId) ||
                other.vendorId == vendorId) &&
            (identical(other.destinationId, destinationId) ||
                other.destinationId == destinationId) &&
            (identical(other.captainId, captainId) ||
                other.captainId == captainId) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.durationDays, durationDays) ||
                other.durationDays == durationDays) &&
            (identical(other.durationNights, durationNights) ||
                other.durationNights == durationNights) &&
            (identical(other.basePrice, basePrice) ||
                other.basePrice == basePrice) &&
            (identical(other.maxParticipants, maxParticipants) ||
                other.maxParticipants == maxParticipants) &&
            (identical(other.trekkingRules, trekkingRules) ||
                other.trekkingRules == trekkingRules) &&
            (identical(other.emergencyProtocols, emergencyProtocols) ||
                other.emergencyProtocols == emergencyProtocols) &&
            (identical(other.organizerNotes, organizerNotes) ||
                other.organizerNotes == organizerNotes) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.discountValue, discountValue) ||
                other.discountValue == discountValue) &&
            (identical(other.discountType, discountType) ||
                other.discountType == discountType) &&
            (identical(other.hasDiscount, hasDiscount) ||
                other.hasDiscount == hasDiscount) &&
            (identical(other.cancellationPolicyId, cancellationPolicyId) ||
                other.cancellationPolicyId == cancellationPolicyId) &&
            (identical(other.badgeId, badgeId) || other.badgeId == badgeId) &&
            (identical(other.hasBeenEdited, hasBeenEdited) ||
                other.hasBeenEdited == hasBeenEdited) &&
            (identical(other.safetySecurityCount, safetySecurityCount) ||
                other.safetySecurityCount == safetySecurityCount) &&
            (identical(other.organizerMannerCount, organizerMannerCount) ||
                other.organizerMannerCount == organizerMannerCount) &&
            (identical(other.trekPlanningCount, trekPlanningCount) ||
                other.trekPlanningCount == trekPlanningCount) &&
            (identical(other.womenSafetyCount, womenSafetyCount) ||
                other.womenSafetyCount == womenSafetyCount) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.vendor, vendor) || other.vendor == vendor) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.ratingCount, ratingCount) ||
                other.ratingCount == ratingCount) &&
            (identical(other.destination, destination) ||
                other.destination == destination) &&
            (identical(other.captainName, captainName) ||
                other.captainName == captainName) &&
            (identical(other.captainPhone, captainPhone) ||
                other.captainPhone == captainPhone));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        const DeepCollectionEquality().hash(_cityIds),
        const DeepCollectionEquality().hash(_inclusions),
        const DeepCollectionEquality().hash(_exclusions),
        const DeepCollectionEquality().hash(_activities),
        id,
        mtrId,
        title,
        description,
        vendorId,
        destinationId,
        captainId,
        duration,
        durationDays,
        durationNights,
        basePrice,
        maxParticipants,
        trekkingRules,
        emergencyProtocols,
        organizerNotes,
        status,
        discountValue,
        discountType,
        hasDiscount,
        cancellationPolicyId,
        badgeId,
        hasBeenEdited,
        safetySecurityCount,
        organizerMannerCount,
        trekPlanningCount,
        womenSafetyCount,
        createdAt,
        updatedAt,
        vendor,
        rating,
        ratingCount,
        destination,
        captainName,
        captainPhone
      ]);

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
      {@JsonKey(name: 'city_ids') final List<int>? cityIds,
      final List<String>? inclusions,
      final List<String>? exclusions,
      final List<int>? activities,
      final int? id,
      @JsonKey(name: 'mtr_id') final String? mtrId,
      final String? title,
      final String? description,
      @JsonKey(name: 'VendorId') final int? vendorId,
      @JsonKey(name: 'destination_id') final int? destinationId,
      @JsonKey(name: 'captain_id') final int? captainId,
      final String? duration,
      @JsonKey(name: 'duration_days') final int? durationDays,
      @JsonKey(name: 'duration_nights') final int? durationNights,
      @JsonKey(name: 'base_price') final String? basePrice,
      @JsonKey(name: 'max_participants') final int? maxParticipants,
      @JsonKey(name: 'trekking_rules') final String? trekkingRules,
      @JsonKey(name: 'emergency_protocols') final String? emergencyProtocols,
      @JsonKey(name: 'organizer_notes') final String? organizerNotes,
      final String? status,
      @JsonKey(name: 'discount_value') final String? discountValue,
      @JsonKey(name: 'discount_type') final String? discountType,
      @JsonKey(name: 'has_discount') final bool? hasDiscount,
      @JsonKey(name: 'cancellation_policy_id') final int? cancellationPolicyId,
      @JsonKey(name: 'badge_id') final int? badgeId,
      @JsonKey(name: 'has_been_edited') final int? hasBeenEdited,
      @JsonKey(name: 'safety_security_count') final int? safetySecurityCount,
      @JsonKey(name: 'organizer_manner_count') final int? organizerMannerCount,
      @JsonKey(name: 'trek_planning_count') final int? trekPlanningCount,
      @JsonKey(name: 'women_safety_count') final int? womenSafetyCount,
      final String? createdAt,
      final String? updatedAt,
      final Vendor? vendor,
      final int? rating,
      final int? ratingCount,
      final Destination? destination,
      @JsonKey(name: 'captain_name') final String? captainName,
      @JsonKey(name: 'captain_phone') final String? captainPhone}) = _$TrekImpl;

  factory _Trek.fromJson(Map<String, dynamic> json) = _$TrekImpl.fromJson;

  @override
  @JsonKey(name: 'city_ids')
  List<int>? get cityIds;
  @override
  List<String>? get inclusions;
  @override
  List<String>? get exclusions;
  @override
  List<int>? get activities;
  @override
  int? get id;
  @override
  @JsonKey(name: 'mtr_id')
  String? get mtrId;
  @override
  String? get title;
  @override
  String? get description;
  @override
  @JsonKey(name: 'VendorId')
  int? get vendorId;
  @override
  @JsonKey(name: 'destination_id')
  int? get destinationId;
  @override
  @JsonKey(name: 'captain_id')
  int? get captainId;
  @override
  String? get duration;
  @override
  @JsonKey(name: 'duration_days')
  int? get durationDays;
  @override
  @JsonKey(name: 'duration_nights')
  int? get durationNights;
  @override
  @JsonKey(name: 'base_price')
  String? get basePrice;
  @override
  @JsonKey(name: 'max_participants')
  int? get maxParticipants;
  @override
  @JsonKey(name: 'trekking_rules')
  String? get trekkingRules;
  @override
  @JsonKey(name: 'emergency_protocols')
  String? get emergencyProtocols;
  @override
  @JsonKey(name: 'organizer_notes')
  String? get organizerNotes;
  @override
  String? get status;
  @override
  @JsonKey(name: 'discount_value')
  String? get discountValue;
  @override
  @JsonKey(name: 'discount_type')
  String? get discountType;
  @override
  @JsonKey(name: 'has_discount')
  bool? get hasDiscount;
  @override
  @JsonKey(name: 'cancellation_policy_id')
  int? get cancellationPolicyId;
  @override
  @JsonKey(name: 'badge_id')
  int? get badgeId;
  @override
  @JsonKey(name: 'has_been_edited')
  int? get hasBeenEdited;
  @override
  @JsonKey(name: 'safety_security_count')
  int? get safetySecurityCount;
  @override
  @JsonKey(name: 'organizer_manner_count')
  int? get organizerMannerCount;
  @override
  @JsonKey(name: 'trek_planning_count')
  int? get trekPlanningCount;
  @override
  @JsonKey(name: 'women_safety_count')
  int? get womenSafetyCount;
  @override
  String? get createdAt;
  @override
  String? get updatedAt;
  @override
  Vendor? get vendor;
  @override
  int? get rating;
  @override
  int? get ratingCount;
  @override
  Destination? get destination;
  @override
  @JsonKey(name: 'captain_name')
  String? get captainName;
  @override
  @JsonKey(name: 'captain_phone')
  String? get captainPhone;
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
  @JsonKey(name: 'business_logo')
  String? get businessLogo => throw _privateConstructorUsedError;

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
      @JsonKey(name: 'business_logo') String? businessLogo});
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
      @JsonKey(name: 'business_logo') String? businessLogo});
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
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VendorImpl implements _Vendor {
  const _$VendorImpl(
      {this.id,
      @JsonKey(name: 'business_name') this.businessName,
      @JsonKey(name: 'business_logo') this.businessLogo});

  factory _$VendorImpl.fromJson(Map<String, dynamic> json) =>
      _$$VendorImplFromJson(json);

  @override
  final int? id;
  @override
  @JsonKey(name: 'business_name')
  final String? businessName;
  @override
  @JsonKey(name: 'business_logo')
  final String? businessLogo;

  @override
  String toString() {
    return 'Vendor(id: $id, businessName: $businessName, businessLogo: $businessLogo)';
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
                other.businessLogo == businessLogo));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, businessName, businessLogo);

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
          @JsonKey(name: 'business_logo') final String? businessLogo}) =
      _$VendorImpl;

  factory _Vendor.fromJson(Map<String, dynamic> json) = _$VendorImpl.fromJson;

  @override
  int? get id;
  @override
  @JsonKey(name: 'business_name')
  String? get businessName;
  @override
  @JsonKey(name: 'business_logo')
  String? get businessLogo;
  @override
  @JsonKey(ignore: true)
  _$$VendorImplCopyWith<_$VendorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CompanyInfo _$CompanyInfoFromJson(Map<String, dynamic> json) {
  return _CompanyInfo.fromJson(json);
}

/// @nodoc
mixin _$CompanyInfo {
  @JsonKey(name: 'company_name')
  String? get companyName => throw _privateConstructorUsedError;
  @JsonKey(name: 'contact_person')
  String? get contactPerson => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;
  @JsonKey(name: 'gst_number')
  String? get gstNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'pan_number')
  String? get panNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'bank_name')
  String? get bankName => throw _privateConstructorUsedError;
  @JsonKey(name: 'account_number')
  String? get accountNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'ifsc_code')
  String? get ifscCode => throw _privateConstructorUsedError;
  @JsonKey(name: 'commission_rate')
  int? get commissionRate => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CompanyInfoCopyWith<CompanyInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CompanyInfoCopyWith<$Res> {
  factory $CompanyInfoCopyWith(
          CompanyInfo value, $Res Function(CompanyInfo) then) =
      _$CompanyInfoCopyWithImpl<$Res, CompanyInfo>;
  @useResult
  $Res call(
      {@JsonKey(name: 'company_name') String? companyName,
      @JsonKey(name: 'contact_person') String? contactPerson,
      String? phone,
      String? email,
      String? address,
      @JsonKey(name: 'gst_number') String? gstNumber,
      @JsonKey(name: 'pan_number') String? panNumber,
      @JsonKey(name: 'bank_name') String? bankName,
      @JsonKey(name: 'account_number') String? accountNumber,
      @JsonKey(name: 'ifsc_code') String? ifscCode,
      @JsonKey(name: 'commission_rate') int? commissionRate});
}

/// @nodoc
class _$CompanyInfoCopyWithImpl<$Res, $Val extends CompanyInfo>
    implements $CompanyInfoCopyWith<$Res> {
  _$CompanyInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? companyName = freezed,
    Object? contactPerson = freezed,
    Object? phone = freezed,
    Object? email = freezed,
    Object? address = freezed,
    Object? gstNumber = freezed,
    Object? panNumber = freezed,
    Object? bankName = freezed,
    Object? accountNumber = freezed,
    Object? ifscCode = freezed,
    Object? commissionRate = freezed,
  }) {
    return _then(_value.copyWith(
      companyName: freezed == companyName
          ? _value.companyName
          : companyName // ignore: cast_nullable_to_non_nullable
              as String?,
      contactPerson: freezed == contactPerson
          ? _value.contactPerson
          : contactPerson // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      gstNumber: freezed == gstNumber
          ? _value.gstNumber
          : gstNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      panNumber: freezed == panNumber
          ? _value.panNumber
          : panNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      bankName: freezed == bankName
          ? _value.bankName
          : bankName // ignore: cast_nullable_to_non_nullable
              as String?,
      accountNumber: freezed == accountNumber
          ? _value.accountNumber
          : accountNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      ifscCode: freezed == ifscCode
          ? _value.ifscCode
          : ifscCode // ignore: cast_nullable_to_non_nullable
              as String?,
      commissionRate: freezed == commissionRate
          ? _value.commissionRate
          : commissionRate // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CompanyInfoImplCopyWith<$Res>
    implements $CompanyInfoCopyWith<$Res> {
  factory _$$CompanyInfoImplCopyWith(
          _$CompanyInfoImpl value, $Res Function(_$CompanyInfoImpl) then) =
      __$$CompanyInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'company_name') String? companyName,
      @JsonKey(name: 'contact_person') String? contactPerson,
      String? phone,
      String? email,
      String? address,
      @JsonKey(name: 'gst_number') String? gstNumber,
      @JsonKey(name: 'pan_number') String? panNumber,
      @JsonKey(name: 'bank_name') String? bankName,
      @JsonKey(name: 'account_number') String? accountNumber,
      @JsonKey(name: 'ifsc_code') String? ifscCode,
      @JsonKey(name: 'commission_rate') int? commissionRate});
}

/// @nodoc
class __$$CompanyInfoImplCopyWithImpl<$Res>
    extends _$CompanyInfoCopyWithImpl<$Res, _$CompanyInfoImpl>
    implements _$$CompanyInfoImplCopyWith<$Res> {
  __$$CompanyInfoImplCopyWithImpl(
      _$CompanyInfoImpl _value, $Res Function(_$CompanyInfoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? companyName = freezed,
    Object? contactPerson = freezed,
    Object? phone = freezed,
    Object? email = freezed,
    Object? address = freezed,
    Object? gstNumber = freezed,
    Object? panNumber = freezed,
    Object? bankName = freezed,
    Object? accountNumber = freezed,
    Object? ifscCode = freezed,
    Object? commissionRate = freezed,
  }) {
    return _then(_$CompanyInfoImpl(
      companyName: freezed == companyName
          ? _value.companyName
          : companyName // ignore: cast_nullable_to_non_nullable
              as String?,
      contactPerson: freezed == contactPerson
          ? _value.contactPerson
          : contactPerson // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      gstNumber: freezed == gstNumber
          ? _value.gstNumber
          : gstNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      panNumber: freezed == panNumber
          ? _value.panNumber
          : panNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      bankName: freezed == bankName
          ? _value.bankName
          : bankName // ignore: cast_nullable_to_non_nullable
              as String?,
      accountNumber: freezed == accountNumber
          ? _value.accountNumber
          : accountNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      ifscCode: freezed == ifscCode
          ? _value.ifscCode
          : ifscCode // ignore: cast_nullable_to_non_nullable
              as String?,
      commissionRate: freezed == commissionRate
          ? _value.commissionRate
          : commissionRate // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CompanyInfoImpl implements _CompanyInfo {
  const _$CompanyInfoImpl(
      {@JsonKey(name: 'company_name') this.companyName,
      @JsonKey(name: 'contact_person') this.contactPerson,
      this.phone,
      this.email,
      this.address,
      @JsonKey(name: 'gst_number') this.gstNumber,
      @JsonKey(name: 'pan_number') this.panNumber,
      @JsonKey(name: 'bank_name') this.bankName,
      @JsonKey(name: 'account_number') this.accountNumber,
      @JsonKey(name: 'ifsc_code') this.ifscCode,
      @JsonKey(name: 'commission_rate') this.commissionRate});

  factory _$CompanyInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$CompanyInfoImplFromJson(json);

  @override
  @JsonKey(name: 'company_name')
  final String? companyName;
  @override
  @JsonKey(name: 'contact_person')
  final String? contactPerson;
  @override
  final String? phone;
  @override
  final String? email;
  @override
  final String? address;
  @override
  @JsonKey(name: 'gst_number')
  final String? gstNumber;
  @override
  @JsonKey(name: 'pan_number')
  final String? panNumber;
  @override
  @JsonKey(name: 'bank_name')
  final String? bankName;
  @override
  @JsonKey(name: 'account_number')
  final String? accountNumber;
  @override
  @JsonKey(name: 'ifsc_code')
  final String? ifscCode;
  @override
  @JsonKey(name: 'commission_rate')
  final int? commissionRate;

  @override
  String toString() {
    return 'CompanyInfo(companyName: $companyName, contactPerson: $contactPerson, phone: $phone, email: $email, address: $address, gstNumber: $gstNumber, panNumber: $panNumber, bankName: $bankName, accountNumber: $accountNumber, ifscCode: $ifscCode, commissionRate: $commissionRate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CompanyInfoImpl &&
            (identical(other.companyName, companyName) ||
                other.companyName == companyName) &&
            (identical(other.contactPerson, contactPerson) ||
                other.contactPerson == contactPerson) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.gstNumber, gstNumber) ||
                other.gstNumber == gstNumber) &&
            (identical(other.panNumber, panNumber) ||
                other.panNumber == panNumber) &&
            (identical(other.bankName, bankName) ||
                other.bankName == bankName) &&
            (identical(other.accountNumber, accountNumber) ||
                other.accountNumber == accountNumber) &&
            (identical(other.ifscCode, ifscCode) ||
                other.ifscCode == ifscCode) &&
            (identical(other.commissionRate, commissionRate) ||
                other.commissionRate == commissionRate));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      companyName,
      contactPerson,
      phone,
      email,
      address,
      gstNumber,
      panNumber,
      bankName,
      accountNumber,
      ifscCode,
      commissionRate);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CompanyInfoImplCopyWith<_$CompanyInfoImpl> get copyWith =>
      __$$CompanyInfoImplCopyWithImpl<_$CompanyInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CompanyInfoImplToJson(
      this,
    );
  }
}

abstract class _CompanyInfo implements CompanyInfo {
  const factory _CompanyInfo(
          {@JsonKey(name: 'company_name') final String? companyName,
          @JsonKey(name: 'contact_person') final String? contactPerson,
          final String? phone,
          final String? email,
          final String? address,
          @JsonKey(name: 'gst_number') final String? gstNumber,
          @JsonKey(name: 'pan_number') final String? panNumber,
          @JsonKey(name: 'bank_name') final String? bankName,
          @JsonKey(name: 'account_number') final String? accountNumber,
          @JsonKey(name: 'ifsc_code') final String? ifscCode,
          @JsonKey(name: 'commission_rate') final int? commissionRate}) =
      _$CompanyInfoImpl;

  factory _CompanyInfo.fromJson(Map<String, dynamic> json) =
      _$CompanyInfoImpl.fromJson;

  @override
  @JsonKey(name: 'company_name')
  String? get companyName;
  @override
  @JsonKey(name: 'contact_person')
  String? get contactPerson;
  @override
  String? get phone;
  @override
  String? get email;
  @override
  String? get address;
  @override
  @JsonKey(name: 'gst_number')
  String? get gstNumber;
  @override
  @JsonKey(name: 'pan_number')
  String? get panNumber;
  @override
  @JsonKey(name: 'bank_name')
  String? get bankName;
  @override
  @JsonKey(name: 'account_number')
  String? get accountNumber;
  @override
  @JsonKey(name: 'ifsc_code')
  String? get ifscCode;
  @override
  @JsonKey(name: 'commission_rate')
  int? get commissionRate;
  @override
  @JsonKey(ignore: true)
  _$$CompanyInfoImplCopyWith<_$CompanyInfoImpl> get copyWith =>
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
  int? get capacity => throw _privateConstructorUsedError;
  @JsonKey(name: 'booked_slots')
  int? get bookedSlots => throw _privateConstructorUsedError;
  @JsonKey(name: 'available_slots')
  int? get availableSlots => throw _privateConstructorUsedError;

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
      int? capacity,
      @JsonKey(name: 'booked_slots') int? bookedSlots,
      @JsonKey(name: 'available_slots') int? availableSlots});
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
    Object? capacity = freezed,
    Object? bookedSlots = freezed,
    Object? availableSlots = freezed,
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
      capacity: freezed == capacity
          ? _value.capacity
          : capacity // ignore: cast_nullable_to_non_nullable
              as int?,
      bookedSlots: freezed == bookedSlots
          ? _value.bookedSlots
          : bookedSlots // ignore: cast_nullable_to_non_nullable
              as int?,
      availableSlots: freezed == availableSlots
          ? _value.availableSlots
          : availableSlots // ignore: cast_nullable_to_non_nullable
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
      int? capacity,
      @JsonKey(name: 'booked_slots') int? bookedSlots,
      @JsonKey(name: 'available_slots') int? availableSlots});
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
    Object? capacity = freezed,
    Object? bookedSlots = freezed,
    Object? availableSlots = freezed,
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
      capacity: freezed == capacity
          ? _value.capacity
          : capacity // ignore: cast_nullable_to_non_nullable
              as int?,
      bookedSlots: freezed == bookedSlots
          ? _value.bookedSlots
          : bookedSlots // ignore: cast_nullable_to_non_nullable
              as int?,
      availableSlots: freezed == availableSlots
          ? _value.availableSlots
          : availableSlots // ignore: cast_nullable_to_non_nullable
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
      this.capacity,
      @JsonKey(name: 'booked_slots') this.bookedSlots,
      @JsonKey(name: 'available_slots') this.availableSlots});

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
  final int? capacity;
  @override
  @JsonKey(name: 'booked_slots')
  final int? bookedSlots;
  @override
  @JsonKey(name: 'available_slots')
  final int? availableSlots;

  @override
  String toString() {
    return 'Batch(id: $id, tbrId: $tbrId, startDate: $startDate, endDate: $endDate, capacity: $capacity, bookedSlots: $bookedSlots, availableSlots: $availableSlots)';
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
            (identical(other.capacity, capacity) ||
                other.capacity == capacity) &&
            (identical(other.bookedSlots, bookedSlots) ||
                other.bookedSlots == bookedSlots) &&
            (identical(other.availableSlots, availableSlots) ||
                other.availableSlots == availableSlots));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, tbrId, startDate, endDate,
      capacity, bookedSlots, availableSlots);

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
          final int? capacity,
          @JsonKey(name: 'booked_slots') final int? bookedSlots,
          @JsonKey(name: 'available_slots') final int? availableSlots}) =
      _$BatchImpl;

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
  int? get capacity;
  @override
  @JsonKey(name: 'booked_slots')
  int? get bookedSlots;
  @override
  @JsonKey(name: 'available_slots')
  int? get availableSlots;
  @override
  @JsonKey(ignore: true)
  _$$BatchImplCopyWith<_$BatchImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

City _$CityFromJson(Map<String, dynamic> json) {
  return _City.fromJson(json);
}

/// @nodoc
mixin _$City {
  int? get id => throw _privateConstructorUsedError;
  String? get cityName => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CityCopyWith<City> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CityCopyWith<$Res> {
  factory $CityCopyWith(City value, $Res Function(City) then) =
      _$CityCopyWithImpl<$Res, City>;
  @useResult
  $Res call({int? id, String? cityName});
}

/// @nodoc
class _$CityCopyWithImpl<$Res, $Val extends City>
    implements $CityCopyWith<$Res> {
  _$CityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? cityName = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      cityName: freezed == cityName
          ? _value.cityName
          : cityName // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CityImplCopyWith<$Res> implements $CityCopyWith<$Res> {
  factory _$$CityImplCopyWith(
          _$CityImpl value, $Res Function(_$CityImpl) then) =
      __$$CityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int? id, String? cityName});
}

/// @nodoc
class __$$CityImplCopyWithImpl<$Res>
    extends _$CityCopyWithImpl<$Res, _$CityImpl>
    implements _$$CityImplCopyWith<$Res> {
  __$$CityImplCopyWithImpl(_$CityImpl _value, $Res Function(_$CityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? cityName = freezed,
  }) {
    return _then(_$CityImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      cityName: freezed == cityName
          ? _value.cityName
          : cityName // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CityImpl implements _City {
  const _$CityImpl({this.id, this.cityName});

  factory _$CityImpl.fromJson(Map<String, dynamic> json) =>
      _$$CityImplFromJson(json);

  @override
  final int? id;
  @override
  final String? cityName;

  @override
  String toString() {
    return 'City(id: $id, cityName: $cityName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.cityName, cityName) ||
                other.cityName == cityName));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, cityName);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CityImplCopyWith<_$CityImpl> get copyWith =>
      __$$CityImplCopyWithImpl<_$CityImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CityImplToJson(
      this,
    );
  }
}

abstract class _City implements City {
  const factory _City({final int? id, final String? cityName}) = _$CityImpl;

  factory _City.fromJson(Map<String, dynamic> json) = _$CityImpl.fromJson;

  @override
  int? get id;
  @override
  String? get cityName;
  @override
  @JsonKey(ignore: true)
  _$$CityImplCopyWith<_$CityImpl> get copyWith =>
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
  @JsonKey(name: 'special_requirements')
  String? get specialRequirements => throw _privateConstructorUsedError;
  @JsonKey(name: 'accommodation_preference')
  String? get accommodationPreference => throw _privateConstructorUsedError;
  @JsonKey(name: 'meal_preference')
  String? get mealPreference => throw _privateConstructorUsedError;
  String? get status => throw _privateConstructorUsedError;
  String? get createdAt => throw _privateConstructorUsedError;
  String? get updatedAt => throw _privateConstructorUsedError;
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
      @JsonKey(name: 'special_requirements') String? specialRequirements,
      @JsonKey(name: 'accommodation_preference')
      String? accommodationPreference,
      @JsonKey(name: 'meal_preference') String? mealPreference,
      String? status,
      String? createdAt,
      String? updatedAt,
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
    Object? specialRequirements = freezed,
    Object? accommodationPreference = freezed,
    Object? mealPreference = freezed,
    Object? status = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
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
      specialRequirements: freezed == specialRequirements
          ? _value.specialRequirements
          : specialRequirements // ignore: cast_nullable_to_non_nullable
              as String?,
      accommodationPreference: freezed == accommodationPreference
          ? _value.accommodationPreference
          : accommodationPreference // ignore: cast_nullable_to_non_nullable
              as String?,
      mealPreference: freezed == mealPreference
          ? _value.mealPreference
          : mealPreference // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
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
      @JsonKey(name: 'special_requirements') String? specialRequirements,
      @JsonKey(name: 'accommodation_preference')
      String? accommodationPreference,
      @JsonKey(name: 'meal_preference') String? mealPreference,
      String? status,
      String? createdAt,
      String? updatedAt,
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
    Object? specialRequirements = freezed,
    Object? accommodationPreference = freezed,
    Object? mealPreference = freezed,
    Object? status = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
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
      specialRequirements: freezed == specialRequirements
          ? _value.specialRequirements
          : specialRequirements // ignore: cast_nullable_to_non_nullable
              as String?,
      accommodationPreference: freezed == accommodationPreference
          ? _value.accommodationPreference
          : accommodationPreference // ignore: cast_nullable_to_non_nullable
              as String?,
      mealPreference: freezed == mealPreference
          ? _value.mealPreference
          : mealPreference // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
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
      @JsonKey(name: 'special_requirements') this.specialRequirements,
      @JsonKey(name: 'accommodation_preference') this.accommodationPreference,
      @JsonKey(name: 'meal_preference') this.mealPreference,
      this.status,
      this.createdAt,
      this.updatedAt,
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
  @JsonKey(name: 'special_requirements')
  final String? specialRequirements;
  @override
  @JsonKey(name: 'accommodation_preference')
  final String? accommodationPreference;
  @override
  @JsonKey(name: 'meal_preference')
  final String? mealPreference;
  @override
  final String? status;
  @override
  final String? createdAt;
  @override
  final String? updatedAt;
  @override
  final Traveler? traveler;

  @override
  String toString() {
    return 'TravelersDataModel(id: $id, bookingId: $bookingId, travelerId: $travelerId, isPrimary: $isPrimary, specialRequirements: $specialRequirements, accommodationPreference: $accommodationPreference, mealPreference: $mealPreference, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, traveler: $traveler)';
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
            (identical(other.specialRequirements, specialRequirements) ||
                other.specialRequirements == specialRequirements) &&
            (identical(
                    other.accommodationPreference, accommodationPreference) ||
                other.accommodationPreference == accommodationPreference) &&
            (identical(other.mealPreference, mealPreference) ||
                other.mealPreference == mealPreference) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.traveler, traveler) ||
                other.traveler == traveler));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      bookingId,
      travelerId,
      isPrimary,
      specialRequirements,
      accommodationPreference,
      mealPreference,
      status,
      createdAt,
      updatedAt,
      traveler);

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
      @JsonKey(name: 'special_requirements') final String? specialRequirements,
      @JsonKey(name: 'accommodation_preference')
      final String? accommodationPreference,
      @JsonKey(name: 'meal_preference') final String? mealPreference,
      final String? status,
      final String? createdAt,
      final String? updatedAt,
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
  @JsonKey(name: 'special_requirements')
  String? get specialRequirements;
  @override
  @JsonKey(name: 'accommodation_preference')
  String? get accommodationPreference;
  @override
  @JsonKey(name: 'meal_preference')
  String? get mealPreference;
  @override
  String? get status;
  @override
  String? get createdAt;
  @override
  String? get updatedAt;
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
  bool? get hasPrevPage => throw _privateConstructorUsedError;
  int? get nextPage => throw _privateConstructorUsedError;
  int? get prevPage => throw _privateConstructorUsedError;

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
      bool? hasNextPage,
      bool? hasPrevPage,
      int? nextPage,
      int? prevPage});
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
    Object? hasPrevPage = freezed,
    Object? nextPage = freezed,
    Object? prevPage = freezed,
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
      hasPrevPage: freezed == hasPrevPage
          ? _value.hasPrevPage
          : hasPrevPage // ignore: cast_nullable_to_non_nullable
              as bool?,
      nextPage: freezed == nextPage
          ? _value.nextPage
          : nextPage // ignore: cast_nullable_to_non_nullable
              as int?,
      prevPage: freezed == prevPage
          ? _value.prevPage
          : prevPage // ignore: cast_nullable_to_non_nullable
              as int?,
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
      bool? hasNextPage,
      bool? hasPrevPage,
      int? nextPage,
      int? prevPage});
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
    Object? hasPrevPage = freezed,
    Object? nextPage = freezed,
    Object? prevPage = freezed,
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
      hasPrevPage: freezed == hasPrevPage
          ? _value.hasPrevPage
          : hasPrevPage // ignore: cast_nullable_to_non_nullable
              as bool?,
      nextPage: freezed == nextPage
          ? _value.nextPage
          : nextPage // ignore: cast_nullable_to_non_nullable
              as int?,
      prevPage: freezed == prevPage
          ? _value.prevPage
          : prevPage // ignore: cast_nullable_to_non_nullable
              as int?,
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
      this.hasNextPage,
      this.hasPrevPage,
      this.nextPage,
      this.prevPage});

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
  final bool? hasPrevPage;
  @override
  final int? nextPage;
  @override
  final int? prevPage;

  @override
  String toString() {
    return 'Pagination(currentPage: $currentPage, totalPages: $totalPages, totalCount: $totalCount, limit: $limit, hasNextPage: $hasNextPage, hasPrevPage: $hasPrevPage, nextPage: $nextPage, prevPage: $prevPage)';
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
                other.hasNextPage == hasNextPage) &&
            (identical(other.hasPrevPage, hasPrevPage) ||
                other.hasPrevPage == hasPrevPage) &&
            (identical(other.nextPage, nextPage) ||
                other.nextPage == nextPage) &&
            (identical(other.prevPage, prevPage) ||
                other.prevPage == prevPage));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, currentPage, totalPages,
      totalCount, limit, hasNextPage, hasPrevPage, nextPage, prevPage);

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
      final bool? hasNextPage,
      final bool? hasPrevPage,
      final int? nextPage,
      final int? prevPage}) = _$PaginationImpl;

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
  bool? get hasPrevPage;
  @override
  int? get nextPage;
  @override
  int? get prevPage;
  @override
  @JsonKey(ignore: true)
  _$$PaginationImplCopyWith<_$PaginationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
