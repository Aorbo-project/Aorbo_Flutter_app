// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trek_detail_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

TrekDetailModal _$TrekDetailModalFromJson(Map<String, dynamic> json) {
  return _TrekDetailModal.fromJson(json);
}

/// @nodoc
mixin _$TrekDetailModal {
  bool? get success => throw _privateConstructorUsedError;
  TrekDetailData? get data => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TrekDetailModalCopyWith<TrekDetailModal> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrekDetailModalCopyWith<$Res> {
  factory $TrekDetailModalCopyWith(
          TrekDetailModal value, $Res Function(TrekDetailModal) then) =
      _$TrekDetailModalCopyWithImpl<$Res, TrekDetailModal>;
  @useResult
  $Res call({bool? success, TrekDetailData? data});

  $TrekDetailDataCopyWith<$Res>? get data;
}

/// @nodoc
class _$TrekDetailModalCopyWithImpl<$Res, $Val extends TrekDetailModal>
    implements $TrekDetailModalCopyWith<$Res> {
  _$TrekDetailModalCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = freezed,
    Object? data = freezed,
  }) {
    return _then(_value.copyWith(
      success: freezed == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool?,
      data: freezed == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as TrekDetailData?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $TrekDetailDataCopyWith<$Res>? get data {
    if (_value.data == null) {
      return null;
    }

    return $TrekDetailDataCopyWith<$Res>(_value.data!, (value) {
      return _then(_value.copyWith(data: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TrekDetailModalImplCopyWith<$Res>
    implements $TrekDetailModalCopyWith<$Res> {
  factory _$$TrekDetailModalImplCopyWith(_$TrekDetailModalImpl value,
          $Res Function(_$TrekDetailModalImpl) then) =
      __$$TrekDetailModalImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool? success, TrekDetailData? data});

  @override
  $TrekDetailDataCopyWith<$Res>? get data;
}

/// @nodoc
class __$$TrekDetailModalImplCopyWithImpl<$Res>
    extends _$TrekDetailModalCopyWithImpl<$Res, _$TrekDetailModalImpl>
    implements _$$TrekDetailModalImplCopyWith<$Res> {
  __$$TrekDetailModalImplCopyWithImpl(
      _$TrekDetailModalImpl _value, $Res Function(_$TrekDetailModalImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = freezed,
    Object? data = freezed,
  }) {
    return _then(_$TrekDetailModalImpl(
      success: freezed == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool?,
      data: freezed == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as TrekDetailData?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TrekDetailModalImpl implements _TrekDetailModal {
  const _$TrekDetailModalImpl({this.success, this.data});

  factory _$TrekDetailModalImpl.fromJson(Map<String, dynamic> json) =>
      _$$TrekDetailModalImplFromJson(json);

  @override
  final bool? success;
  @override
  final TrekDetailData? data;

  @override
  String toString() {
    return 'TrekDetailModal(success: $success, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrekDetailModalImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.data, data) || other.data == data));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, success, data);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TrekDetailModalImplCopyWith<_$TrekDetailModalImpl> get copyWith =>
      __$$TrekDetailModalImplCopyWithImpl<_$TrekDetailModalImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TrekDetailModalImplToJson(
      this,
    );
  }
}

abstract class _TrekDetailModal implements TrekDetailModal {
  const factory _TrekDetailModal(
      {final bool? success,
      final TrekDetailData? data}) = _$TrekDetailModalImpl;

  factory _TrekDetailModal.fromJson(Map<String, dynamic> json) =
      _$TrekDetailModalImpl.fromJson;

  @override
  bool? get success;
  @override
  TrekDetailData? get data;
  @override
  @JsonKey(ignore: true)
  _$$TrekDetailModalImplCopyWith<_$TrekDetailModalImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TrekDetailData _$TrekDetailDataFromJson(Map<String, dynamic> json) {
  return _TrekDetailData.fromJson(json);
}

/// @nodoc
mixin _$TrekDetailData {
  @JsonKey(name: 'city_ids')
  List<int>? get cityIds => throw _privateConstructorUsedError;
  List<Inclusions>? get inclusions => throw _privateConstructorUsedError;
  List<String>? get exclusions => throw _privateConstructorUsedError;
  List<Activities>? get activities => throw _privateConstructorUsedError;
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'mtr_id')
  String? get mtrId => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'vendor_id')
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
  @JsonKey(name: 'createdAt')
  String? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updatedAt')
  String? get updatedAt => throw _privateConstructorUsedError;
  Vendor? get vendor => throw _privateConstructorUsedError;
  @JsonKey(name: 'destinationData')
  Activities? get destinationData => throw _privateConstructorUsedError;
  Badge? get badge => throw _privateConstructorUsedError;
  @JsonKey(name: 'trek_stages')
  List<TrekStages>? get trekStages => throw _privateConstructorUsedError;
  List<Accommodations>? get accommodations =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'itinerary_items')
  List<ItineraryItems>? get itineraryItems =>
      throw _privateConstructorUsedError;
  List<Images>? get images => throw _privateConstructorUsedError;
  @JsonKey(name: 'average_rating')
  double? get averageRating => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_reviews')
  int? get totalReviews => throw _privateConstructorUsedError;
  @JsonKey(name: 'rating_total')
  double? get ratingTotal => throw _privateConstructorUsedError;
  @JsonKey(name: 'review_comments_count')
  int? get reviewCommentsCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'latest_reviews')
  List<LatestReviews>? get latestReviews => throw _privateConstructorUsedError;
  @JsonKey(name: 'category_ratings')
  CategoryRatings? get categoryRatings => throw _privateConstructorUsedError;
  @JsonKey(name: 'batch_id')
  int? get batchId => throw _privateConstructorUsedError;
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
  @JsonKey(name: 'cancellation_policy')
  CancellationPolicy? get cancellationPolicy =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'booking_type')
  String? get bookingType => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TrekDetailDataCopyWith<TrekDetailData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrekDetailDataCopyWith<$Res> {
  factory $TrekDetailDataCopyWith(
          TrekDetailData value, $Res Function(TrekDetailData) then) =
      _$TrekDetailDataCopyWithImpl<$Res, TrekDetailData>;
  @useResult
  $Res call(
      {@JsonKey(name: 'city_ids') List<int>? cityIds,
      List<Inclusions>? inclusions,
      List<String>? exclusions,
      List<Activities>? activities,
      int? id,
      @JsonKey(name: 'mtr_id') String? mtrId,
      String? title,
      String? description,
      @JsonKey(name: 'vendor_id') int? vendorId,
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
      @JsonKey(name: 'badge_id') int? badgeId,
      @JsonKey(name: 'has_been_edited') int? hasBeenEdited,
      @JsonKey(name: 'safety_security_count') int? safetySecurityCount,
      @JsonKey(name: 'organizer_manner_count') int? organizerMannerCount,
      @JsonKey(name: 'trek_planning_count') int? trekPlanningCount,
      @JsonKey(name: 'women_safety_count') int? womenSafetyCount,
      @JsonKey(name: 'createdAt') String? createdAt,
      @JsonKey(name: 'updatedAt') String? updatedAt,
      Vendor? vendor,
      @JsonKey(name: 'destinationData') Activities? destinationData,
      Badge? badge,
      @JsonKey(name: 'trek_stages') List<TrekStages>? trekStages,
      List<Accommodations>? accommodations,
      @JsonKey(name: 'itinerary_items') List<ItineraryItems>? itineraryItems,
      List<Images>? images,
      @JsonKey(name: 'average_rating') double? averageRating,
      @JsonKey(name: 'total_reviews') int? totalReviews,
      @JsonKey(name: 'rating_total') double? ratingTotal,
      @JsonKey(name: 'review_comments_count') int? reviewCommentsCount,
      @JsonKey(name: 'latest_reviews') List<LatestReviews>? latestReviews,
      @JsonKey(name: 'category_ratings') CategoryRatings? categoryRatings,
      @JsonKey(name: 'batch_id') int? batchId,
      @JsonKey(name: 'tbr_id') String? tbrId,
      @JsonKey(name: 'start_date') String? startDate,
      @JsonKey(name: 'end_date') String? endDate,
      int? capacity,
      @JsonKey(name: 'booked_slots') int? bookedSlots,
      @JsonKey(name: 'available_slots') int? availableSlots,
      @JsonKey(name: 'cancellation_policy')
      CancellationPolicy? cancellationPolicy,
      @JsonKey(name: 'booking_type') String? bookingType});

  $VendorCopyWith<$Res>? get vendor;
  $ActivitiesCopyWith<$Res>? get destinationData;
  $BadgeCopyWith<$Res>? get badge;
  $CategoryRatingsCopyWith<$Res>? get categoryRatings;
  $CancellationPolicyCopyWith<$Res>? get cancellationPolicy;
}

/// @nodoc
class _$TrekDetailDataCopyWithImpl<$Res, $Val extends TrekDetailData>
    implements $TrekDetailDataCopyWith<$Res> {
  _$TrekDetailDataCopyWithImpl(this._value, this._then);

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
    Object? badgeId = freezed,
    Object? hasBeenEdited = freezed,
    Object? safetySecurityCount = freezed,
    Object? organizerMannerCount = freezed,
    Object? trekPlanningCount = freezed,
    Object? womenSafetyCount = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? vendor = freezed,
    Object? destinationData = freezed,
    Object? badge = freezed,
    Object? trekStages = freezed,
    Object? accommodations = freezed,
    Object? itineraryItems = freezed,
    Object? images = freezed,
    Object? averageRating = freezed,
    Object? totalReviews = freezed,
    Object? ratingTotal = freezed,
    Object? reviewCommentsCount = freezed,
    Object? latestReviews = freezed,
    Object? categoryRatings = freezed,
    Object? batchId = freezed,
    Object? tbrId = freezed,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? capacity = freezed,
    Object? bookedSlots = freezed,
    Object? availableSlots = freezed,
    Object? cancellationPolicy = freezed,
    Object? bookingType = freezed,
  }) {
    return _then(_value.copyWith(
      cityIds: freezed == cityIds
          ? _value.cityIds
          : cityIds // ignore: cast_nullable_to_non_nullable
              as List<int>?,
      inclusions: freezed == inclusions
          ? _value.inclusions
          : inclusions // ignore: cast_nullable_to_non_nullable
              as List<Inclusions>?,
      exclusions: freezed == exclusions
          ? _value.exclusions
          : exclusions // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      activities: freezed == activities
          ? _value.activities
          : activities // ignore: cast_nullable_to_non_nullable
              as List<Activities>?,
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
      destinationData: freezed == destinationData
          ? _value.destinationData
          : destinationData // ignore: cast_nullable_to_non_nullable
              as Activities?,
      badge: freezed == badge
          ? _value.badge
          : badge // ignore: cast_nullable_to_non_nullable
              as Badge?,
      trekStages: freezed == trekStages
          ? _value.trekStages
          : trekStages // ignore: cast_nullable_to_non_nullable
              as List<TrekStages>?,
      accommodations: freezed == accommodations
          ? _value.accommodations
          : accommodations // ignore: cast_nullable_to_non_nullable
              as List<Accommodations>?,
      itineraryItems: freezed == itineraryItems
          ? _value.itineraryItems
          : itineraryItems // ignore: cast_nullable_to_non_nullable
              as List<ItineraryItems>?,
      images: freezed == images
          ? _value.images
          : images // ignore: cast_nullable_to_non_nullable
              as List<Images>?,
      averageRating: freezed == averageRating
          ? _value.averageRating
          : averageRating // ignore: cast_nullable_to_non_nullable
              as double?,
      totalReviews: freezed == totalReviews
          ? _value.totalReviews
          : totalReviews // ignore: cast_nullable_to_non_nullable
              as int?,
      ratingTotal: freezed == ratingTotal
          ? _value.ratingTotal
          : ratingTotal // ignore: cast_nullable_to_non_nullable
              as double?,
      reviewCommentsCount: freezed == reviewCommentsCount
          ? _value.reviewCommentsCount
          : reviewCommentsCount // ignore: cast_nullable_to_non_nullable
              as int?,
      latestReviews: freezed == latestReviews
          ? _value.latestReviews
          : latestReviews // ignore: cast_nullable_to_non_nullable
              as List<LatestReviews>?,
      categoryRatings: freezed == categoryRatings
          ? _value.categoryRatings
          : categoryRatings // ignore: cast_nullable_to_non_nullable
              as CategoryRatings?,
      batchId: freezed == batchId
          ? _value.batchId
          : batchId // ignore: cast_nullable_to_non_nullable
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
      cancellationPolicy: freezed == cancellationPolicy
          ? _value.cancellationPolicy
          : cancellationPolicy // ignore: cast_nullable_to_non_nullable
              as CancellationPolicy?,
      bookingType: freezed == bookingType
          ? _value.bookingType
          : bookingType // ignore: cast_nullable_to_non_nullable
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
  $ActivitiesCopyWith<$Res>? get destinationData {
    if (_value.destinationData == null) {
      return null;
    }

    return $ActivitiesCopyWith<$Res>(_value.destinationData!, (value) {
      return _then(_value.copyWith(destinationData: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $BadgeCopyWith<$Res>? get badge {
    if (_value.badge == null) {
      return null;
    }

    return $BadgeCopyWith<$Res>(_value.badge!, (value) {
      return _then(_value.copyWith(badge: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $CategoryRatingsCopyWith<$Res>? get categoryRatings {
    if (_value.categoryRatings == null) {
      return null;
    }

    return $CategoryRatingsCopyWith<$Res>(_value.categoryRatings!, (value) {
      return _then(_value.copyWith(categoryRatings: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $CancellationPolicyCopyWith<$Res>? get cancellationPolicy {
    if (_value.cancellationPolicy == null) {
      return null;
    }

    return $CancellationPolicyCopyWith<$Res>(_value.cancellationPolicy!,
        (value) {
      return _then(_value.copyWith(cancellationPolicy: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TrekDetailDataImplCopyWith<$Res>
    implements $TrekDetailDataCopyWith<$Res> {
  factory _$$TrekDetailDataImplCopyWith(_$TrekDetailDataImpl value,
          $Res Function(_$TrekDetailDataImpl) then) =
      __$$TrekDetailDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'city_ids') List<int>? cityIds,
      List<Inclusions>? inclusions,
      List<String>? exclusions,
      List<Activities>? activities,
      int? id,
      @JsonKey(name: 'mtr_id') String? mtrId,
      String? title,
      String? description,
      @JsonKey(name: 'vendor_id') int? vendorId,
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
      @JsonKey(name: 'badge_id') int? badgeId,
      @JsonKey(name: 'has_been_edited') int? hasBeenEdited,
      @JsonKey(name: 'safety_security_count') int? safetySecurityCount,
      @JsonKey(name: 'organizer_manner_count') int? organizerMannerCount,
      @JsonKey(name: 'trek_planning_count') int? trekPlanningCount,
      @JsonKey(name: 'women_safety_count') int? womenSafetyCount,
      @JsonKey(name: 'createdAt') String? createdAt,
      @JsonKey(name: 'updatedAt') String? updatedAt,
      Vendor? vendor,
      @JsonKey(name: 'destinationData') Activities? destinationData,
      Badge? badge,
      @JsonKey(name: 'trek_stages') List<TrekStages>? trekStages,
      List<Accommodations>? accommodations,
      @JsonKey(name: 'itinerary_items') List<ItineraryItems>? itineraryItems,
      List<Images>? images,
      @JsonKey(name: 'average_rating') double? averageRating,
      @JsonKey(name: 'total_reviews') int? totalReviews,
      @JsonKey(name: 'rating_total') double? ratingTotal,
      @JsonKey(name: 'review_comments_count') int? reviewCommentsCount,
      @JsonKey(name: 'latest_reviews') List<LatestReviews>? latestReviews,
      @JsonKey(name: 'category_ratings') CategoryRatings? categoryRatings,
      @JsonKey(name: 'batch_id') int? batchId,
      @JsonKey(name: 'tbr_id') String? tbrId,
      @JsonKey(name: 'start_date') String? startDate,
      @JsonKey(name: 'end_date') String? endDate,
      int? capacity,
      @JsonKey(name: 'booked_slots') int? bookedSlots,
      @JsonKey(name: 'available_slots') int? availableSlots,
      @JsonKey(name: 'cancellation_policy')
      CancellationPolicy? cancellationPolicy,
      @JsonKey(name: 'booking_type') String? bookingType});

  @override
  $VendorCopyWith<$Res>? get vendor;
  @override
  $ActivitiesCopyWith<$Res>? get destinationData;
  @override
  $BadgeCopyWith<$Res>? get badge;
  @override
  $CategoryRatingsCopyWith<$Res>? get categoryRatings;
  @override
  $CancellationPolicyCopyWith<$Res>? get cancellationPolicy;
}

/// @nodoc
class __$$TrekDetailDataImplCopyWithImpl<$Res>
    extends _$TrekDetailDataCopyWithImpl<$Res, _$TrekDetailDataImpl>
    implements _$$TrekDetailDataImplCopyWith<$Res> {
  __$$TrekDetailDataImplCopyWithImpl(
      _$TrekDetailDataImpl _value, $Res Function(_$TrekDetailDataImpl) _then)
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
    Object? badgeId = freezed,
    Object? hasBeenEdited = freezed,
    Object? safetySecurityCount = freezed,
    Object? organizerMannerCount = freezed,
    Object? trekPlanningCount = freezed,
    Object? womenSafetyCount = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? vendor = freezed,
    Object? destinationData = freezed,
    Object? badge = freezed,
    Object? trekStages = freezed,
    Object? accommodations = freezed,
    Object? itineraryItems = freezed,
    Object? images = freezed,
    Object? averageRating = freezed,
    Object? totalReviews = freezed,
    Object? ratingTotal = freezed,
    Object? reviewCommentsCount = freezed,
    Object? latestReviews = freezed,
    Object? categoryRatings = freezed,
    Object? batchId = freezed,
    Object? tbrId = freezed,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? capacity = freezed,
    Object? bookedSlots = freezed,
    Object? availableSlots = freezed,
    Object? cancellationPolicy = freezed,
    Object? bookingType = freezed,
  }) {
    return _then(_$TrekDetailDataImpl(
      cityIds: freezed == cityIds
          ? _value._cityIds
          : cityIds // ignore: cast_nullable_to_non_nullable
              as List<int>?,
      inclusions: freezed == inclusions
          ? _value._inclusions
          : inclusions // ignore: cast_nullable_to_non_nullable
              as List<Inclusions>?,
      exclusions: freezed == exclusions
          ? _value._exclusions
          : exclusions // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      activities: freezed == activities
          ? _value._activities
          : activities // ignore: cast_nullable_to_non_nullable
              as List<Activities>?,
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
      destinationData: freezed == destinationData
          ? _value.destinationData
          : destinationData // ignore: cast_nullable_to_non_nullable
              as Activities?,
      badge: freezed == badge
          ? _value.badge
          : badge // ignore: cast_nullable_to_non_nullable
              as Badge?,
      trekStages: freezed == trekStages
          ? _value._trekStages
          : trekStages // ignore: cast_nullable_to_non_nullable
              as List<TrekStages>?,
      accommodations: freezed == accommodations
          ? _value._accommodations
          : accommodations // ignore: cast_nullable_to_non_nullable
              as List<Accommodations>?,
      itineraryItems: freezed == itineraryItems
          ? _value._itineraryItems
          : itineraryItems // ignore: cast_nullable_to_non_nullable
              as List<ItineraryItems>?,
      images: freezed == images
          ? _value._images
          : images // ignore: cast_nullable_to_non_nullable
              as List<Images>?,
      averageRating: freezed == averageRating
          ? _value.averageRating
          : averageRating // ignore: cast_nullable_to_non_nullable
              as double?,
      totalReviews: freezed == totalReviews
          ? _value.totalReviews
          : totalReviews // ignore: cast_nullable_to_non_nullable
              as int?,
      ratingTotal: freezed == ratingTotal
          ? _value.ratingTotal
          : ratingTotal // ignore: cast_nullable_to_non_nullable
              as double?,
      reviewCommentsCount: freezed == reviewCommentsCount
          ? _value.reviewCommentsCount
          : reviewCommentsCount // ignore: cast_nullable_to_non_nullable
              as int?,
      latestReviews: freezed == latestReviews
          ? _value._latestReviews
          : latestReviews // ignore: cast_nullable_to_non_nullable
              as List<LatestReviews>?,
      categoryRatings: freezed == categoryRatings
          ? _value.categoryRatings
          : categoryRatings // ignore: cast_nullable_to_non_nullable
              as CategoryRatings?,
      batchId: freezed == batchId
          ? _value.batchId
          : batchId // ignore: cast_nullable_to_non_nullable
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
      cancellationPolicy: freezed == cancellationPolicy
          ? _value.cancellationPolicy
          : cancellationPolicy // ignore: cast_nullable_to_non_nullable
              as CancellationPolicy?,
      bookingType: freezed == bookingType
          ? _value.bookingType
          : bookingType // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TrekDetailDataImpl implements _TrekDetailData {
  const _$TrekDetailDataImpl(
      {@JsonKey(name: 'city_ids') final List<int>? cityIds,
      final List<Inclusions>? inclusions,
      final List<String>? exclusions,
      final List<Activities>? activities,
      this.id,
      @JsonKey(name: 'mtr_id') this.mtrId,
      this.title,
      this.description,
      @JsonKey(name: 'vendor_id') this.vendorId,
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
      @JsonKey(name: 'badge_id') this.badgeId,
      @JsonKey(name: 'has_been_edited') this.hasBeenEdited,
      @JsonKey(name: 'safety_security_count') this.safetySecurityCount,
      @JsonKey(name: 'organizer_manner_count') this.organizerMannerCount,
      @JsonKey(name: 'trek_planning_count') this.trekPlanningCount,
      @JsonKey(name: 'women_safety_count') this.womenSafetyCount,
      @JsonKey(name: 'createdAt') this.createdAt,
      @JsonKey(name: 'updatedAt') this.updatedAt,
      this.vendor,
      @JsonKey(name: 'destinationData') this.destinationData,
      this.badge,
      @JsonKey(name: 'trek_stages') final List<TrekStages>? trekStages,
      final List<Accommodations>? accommodations,
      @JsonKey(name: 'itinerary_items')
      final List<ItineraryItems>? itineraryItems,
      final List<Images>? images,
      @JsonKey(name: 'average_rating') this.averageRating,
      @JsonKey(name: 'total_reviews') this.totalReviews,
      @JsonKey(name: 'rating_total') this.ratingTotal,
      @JsonKey(name: 'review_comments_count') this.reviewCommentsCount,
      @JsonKey(name: 'latest_reviews') final List<LatestReviews>? latestReviews,
      @JsonKey(name: 'category_ratings') this.categoryRatings,
      @JsonKey(name: 'batch_id') this.batchId,
      @JsonKey(name: 'tbr_id') this.tbrId,
      @JsonKey(name: 'start_date') this.startDate,
      @JsonKey(name: 'end_date') this.endDate,
      this.capacity,
      @JsonKey(name: 'booked_slots') this.bookedSlots,
      @JsonKey(name: 'available_slots') this.availableSlots,
      @JsonKey(name: 'cancellation_policy') this.cancellationPolicy,
      @JsonKey(name: 'booking_type') this.bookingType})
      : _cityIds = cityIds,
        _inclusions = inclusions,
        _exclusions = exclusions,
        _activities = activities,
        _trekStages = trekStages,
        _accommodations = accommodations,
        _itineraryItems = itineraryItems,
        _images = images,
        _latestReviews = latestReviews;

  factory _$TrekDetailDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$TrekDetailDataImplFromJson(json);

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

  final List<Inclusions>? _inclusions;
  @override
  List<Inclusions>? get inclusions {
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

  final List<Activities>? _activities;
  @override
  List<Activities>? get activities {
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
  @JsonKey(name: 'vendor_id')
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
  @JsonKey(name: 'createdAt')
  final String? createdAt;
  @override
  @JsonKey(name: 'updatedAt')
  final String? updatedAt;
  @override
  final Vendor? vendor;
  @override
  @JsonKey(name: 'destinationData')
  final Activities? destinationData;
  @override
  final Badge? badge;
  final List<TrekStages>? _trekStages;
  @override
  @JsonKey(name: 'trek_stages')
  List<TrekStages>? get trekStages {
    final value = _trekStages;
    if (value == null) return null;
    if (_trekStages is EqualUnmodifiableListView) return _trekStages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<Accommodations>? _accommodations;
  @override
  List<Accommodations>? get accommodations {
    final value = _accommodations;
    if (value == null) return null;
    if (_accommodations is EqualUnmodifiableListView) return _accommodations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<ItineraryItems>? _itineraryItems;
  @override
  @JsonKey(name: 'itinerary_items')
  List<ItineraryItems>? get itineraryItems {
    final value = _itineraryItems;
    if (value == null) return null;
    if (_itineraryItems is EqualUnmodifiableListView) return _itineraryItems;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<Images>? _images;
  @override
  List<Images>? get images {
    final value = _images;
    if (value == null) return null;
    if (_images is EqualUnmodifiableListView) return _images;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'average_rating')
  final double? averageRating;
  @override
  @JsonKey(name: 'total_reviews')
  final int? totalReviews;
  @override
  @JsonKey(name: 'rating_total')
  final double? ratingTotal;
  @override
  @JsonKey(name: 'review_comments_count')
  final int? reviewCommentsCount;
  final List<LatestReviews>? _latestReviews;
  @override
  @JsonKey(name: 'latest_reviews')
  List<LatestReviews>? get latestReviews {
    final value = _latestReviews;
    if (value == null) return null;
    if (_latestReviews is EqualUnmodifiableListView) return _latestReviews;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'category_ratings')
  final CategoryRatings? categoryRatings;
  @override
  @JsonKey(name: 'batch_id')
  final int? batchId;
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
  @JsonKey(name: 'cancellation_policy')
  final CancellationPolicy? cancellationPolicy;
  @override
  @JsonKey(name: 'booking_type')
  final String? bookingType;

  @override
  String toString() {
    return 'TrekDetailData(cityIds: $cityIds, inclusions: $inclusions, exclusions: $exclusions, activities: $activities, id: $id, mtrId: $mtrId, title: $title, description: $description, vendorId: $vendorId, destinationId: $destinationId, captainId: $captainId, duration: $duration, durationDays: $durationDays, durationNights: $durationNights, basePrice: $basePrice, maxParticipants: $maxParticipants, trekkingRules: $trekkingRules, emergencyProtocols: $emergencyProtocols, organizerNotes: $organizerNotes, status: $status, discountValue: $discountValue, discountType: $discountType, hasDiscount: $hasDiscount, badgeId: $badgeId, hasBeenEdited: $hasBeenEdited, safetySecurityCount: $safetySecurityCount, organizerMannerCount: $organizerMannerCount, trekPlanningCount: $trekPlanningCount, womenSafetyCount: $womenSafetyCount, createdAt: $createdAt, updatedAt: $updatedAt, vendor: $vendor, destinationData: $destinationData, badge: $badge, trekStages: $trekStages, accommodations: $accommodations, itineraryItems: $itineraryItems, images: $images, averageRating: $averageRating, totalReviews: $totalReviews, ratingTotal: $ratingTotal, reviewCommentsCount: $reviewCommentsCount, latestReviews: $latestReviews, categoryRatings: $categoryRatings, batchId: $batchId, tbrId: $tbrId, startDate: $startDate, endDate: $endDate, capacity: $capacity, bookedSlots: $bookedSlots, availableSlots: $availableSlots, cancellationPolicy: $cancellationPolicy, bookingType: $bookingType)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrekDetailDataImpl &&
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
            (identical(other.destinationData, destinationData) ||
                other.destinationData == destinationData) &&
            (identical(other.badge, badge) || other.badge == badge) &&
            const DeepCollectionEquality()
                .equals(other._trekStages, _trekStages) &&
            const DeepCollectionEquality()
                .equals(other._accommodations, _accommodations) &&
            const DeepCollectionEquality()
                .equals(other._itineraryItems, _itineraryItems) &&
            const DeepCollectionEquality().equals(other._images, _images) &&
            (identical(other.averageRating, averageRating) ||
                other.averageRating == averageRating) &&
            (identical(other.totalReviews, totalReviews) ||
                other.totalReviews == totalReviews) &&
            (identical(other.ratingTotal, ratingTotal) ||
                other.ratingTotal == ratingTotal) &&
            (identical(other.reviewCommentsCount, reviewCommentsCount) ||
                other.reviewCommentsCount == reviewCommentsCount) &&
            const DeepCollectionEquality()
                .equals(other._latestReviews, _latestReviews) &&
            (identical(other.categoryRatings, categoryRatings) ||
                other.categoryRatings == categoryRatings) &&
            (identical(other.batchId, batchId) || other.batchId == batchId) &&
            (identical(other.tbrId, tbrId) || other.tbrId == tbrId) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.capacity, capacity) ||
                other.capacity == capacity) &&
            (identical(other.bookedSlots, bookedSlots) ||
                other.bookedSlots == bookedSlots) &&
            (identical(other.availableSlots, availableSlots) ||
                other.availableSlots == availableSlots) &&
            (identical(other.cancellationPolicy, cancellationPolicy) ||
                other.cancellationPolicy == cancellationPolicy) &&
            (identical(other.bookingType, bookingType) ||
                other.bookingType == bookingType));
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
        badgeId,
        hasBeenEdited,
        safetySecurityCount,
        organizerMannerCount,
        trekPlanningCount,
        womenSafetyCount,
        createdAt,
        updatedAt,
        vendor,
        destinationData,
        badge,
        const DeepCollectionEquality().hash(_trekStages),
        const DeepCollectionEquality().hash(_accommodations),
        const DeepCollectionEquality().hash(_itineraryItems),
        const DeepCollectionEquality().hash(_images),
        averageRating,
        totalReviews,
        ratingTotal,
        reviewCommentsCount,
        const DeepCollectionEquality().hash(_latestReviews),
        categoryRatings,
        batchId,
        tbrId,
        startDate,
        endDate,
        capacity,
        bookedSlots,
        availableSlots,
        cancellationPolicy,
        bookingType
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TrekDetailDataImplCopyWith<_$TrekDetailDataImpl> get copyWith =>
      __$$TrekDetailDataImplCopyWithImpl<_$TrekDetailDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TrekDetailDataImplToJson(
      this,
    );
  }
}

abstract class _TrekDetailData implements TrekDetailData {
  const factory _TrekDetailData(
      {@JsonKey(name: 'city_ids') final List<int>? cityIds,
      final List<Inclusions>? inclusions,
      final List<String>? exclusions,
      final List<Activities>? activities,
      final int? id,
      @JsonKey(name: 'mtr_id') final String? mtrId,
      final String? title,
      final String? description,
      @JsonKey(name: 'vendor_id') final int? vendorId,
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
      @JsonKey(name: 'badge_id') final int? badgeId,
      @JsonKey(name: 'has_been_edited') final int? hasBeenEdited,
      @JsonKey(name: 'safety_security_count') final int? safetySecurityCount,
      @JsonKey(name: 'organizer_manner_count') final int? organizerMannerCount,
      @JsonKey(name: 'trek_planning_count') final int? trekPlanningCount,
      @JsonKey(name: 'women_safety_count') final int? womenSafetyCount,
      @JsonKey(name: 'createdAt') final String? createdAt,
      @JsonKey(name: 'updatedAt') final String? updatedAt,
      final Vendor? vendor,
      @JsonKey(name: 'destinationData') final Activities? destinationData,
      final Badge? badge,
      @JsonKey(name: 'trek_stages') final List<TrekStages>? trekStages,
      final List<Accommodations>? accommodations,
      @JsonKey(name: 'itinerary_items')
      final List<ItineraryItems>? itineraryItems,
      final List<Images>? images,
      @JsonKey(name: 'average_rating') final double? averageRating,
      @JsonKey(name: 'total_reviews') final int? totalReviews,
      @JsonKey(name: 'rating_total') final double? ratingTotal,
      @JsonKey(name: 'review_comments_count') final int? reviewCommentsCount,
      @JsonKey(name: 'latest_reviews') final List<LatestReviews>? latestReviews,
      @JsonKey(name: 'category_ratings') final CategoryRatings? categoryRatings,
      @JsonKey(name: 'batch_id') final int? batchId,
      @JsonKey(name: 'tbr_id') final String? tbrId,
      @JsonKey(name: 'start_date') final String? startDate,
      @JsonKey(name: 'end_date') final String? endDate,
      final int? capacity,
      @JsonKey(name: 'booked_slots') final int? bookedSlots,
      @JsonKey(name: 'available_slots') final int? availableSlots,
      @JsonKey(name: 'cancellation_policy')
      final CancellationPolicy? cancellationPolicy,
      @JsonKey(name: 'booking_type')
      final String? bookingType}) = _$TrekDetailDataImpl;

  factory _TrekDetailData.fromJson(Map<String, dynamic> json) =
      _$TrekDetailDataImpl.fromJson;

  @override
  @JsonKey(name: 'city_ids')
  List<int>? get cityIds;
  @override
  List<Inclusions>? get inclusions;
  @override
  List<String>? get exclusions;
  @override
  List<Activities>? get activities;
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
  @JsonKey(name: 'vendor_id')
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
  @JsonKey(name: 'createdAt')
  String? get createdAt;
  @override
  @JsonKey(name: 'updatedAt')
  String? get updatedAt;
  @override
  Vendor? get vendor;
  @override
  @JsonKey(name: 'destinationData')
  Activities? get destinationData;
  @override
  Badge? get badge;
  @override
  @JsonKey(name: 'trek_stages')
  List<TrekStages>? get trekStages;
  @override
  List<Accommodations>? get accommodations;
  @override
  @JsonKey(name: 'itinerary_items')
  List<ItineraryItems>? get itineraryItems;
  @override
  List<Images>? get images;
  @override
  @JsonKey(name: 'average_rating')
  double? get averageRating;
  @override
  @JsonKey(name: 'total_reviews')
  int? get totalReviews;
  @override
  @JsonKey(name: 'rating_total')
  double? get ratingTotal;
  @override
  @JsonKey(name: 'review_comments_count')
  int? get reviewCommentsCount;
  @override
  @JsonKey(name: 'latest_reviews')
  List<LatestReviews>? get latestReviews;
  @override
  @JsonKey(name: 'category_ratings')
  CategoryRatings? get categoryRatings;
  @override
  @JsonKey(name: 'batch_id')
  int? get batchId;
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
  @JsonKey(name: 'cancellation_policy')
  CancellationPolicy? get cancellationPolicy;
  @override
  @JsonKey(name: 'booking_type')
  String? get bookingType;
  @override
  @JsonKey(ignore: true)
  _$$TrekDetailDataImplCopyWith<_$TrekDetailDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Inclusions _$InclusionsFromJson(Map<String, dynamic> json) {
  return _Inclusions.fromJson(json);
}

/// @nodoc
mixin _$Inclusions {
  int? get id => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $InclusionsCopyWith<Inclusions> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InclusionsCopyWith<$Res> {
  factory $InclusionsCopyWith(
          Inclusions value, $Res Function(Inclusions) then) =
      _$InclusionsCopyWithImpl<$Res, Inclusions>;
  @useResult
  $Res call({int? id, String? name, String? description});
}

/// @nodoc
class _$InclusionsCopyWithImpl<$Res, $Val extends Inclusions>
    implements $InclusionsCopyWith<$Res> {
  _$InclusionsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? description = freezed,
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
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$InclusionsImplCopyWith<$Res>
    implements $InclusionsCopyWith<$Res> {
  factory _$$InclusionsImplCopyWith(
          _$InclusionsImpl value, $Res Function(_$InclusionsImpl) then) =
      __$$InclusionsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int? id, String? name, String? description});
}

/// @nodoc
class __$$InclusionsImplCopyWithImpl<$Res>
    extends _$InclusionsCopyWithImpl<$Res, _$InclusionsImpl>
    implements _$$InclusionsImplCopyWith<$Res> {
  __$$InclusionsImplCopyWithImpl(
      _$InclusionsImpl _value, $Res Function(_$InclusionsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? description = freezed,
  }) {
    return _then(_$InclusionsImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$InclusionsImpl implements _Inclusions {
  const _$InclusionsImpl({this.id, this.name, this.description});

  factory _$InclusionsImpl.fromJson(Map<String, dynamic> json) =>
      _$$InclusionsImplFromJson(json);

  @override
  final int? id;
  @override
  final String? name;
  @override
  final String? description;

  @override
  String toString() {
    return 'Inclusions(id: $id, name: $name, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InclusionsImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, description);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$InclusionsImplCopyWith<_$InclusionsImpl> get copyWith =>
      __$$InclusionsImplCopyWithImpl<_$InclusionsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$InclusionsImplToJson(
      this,
    );
  }
}

abstract class _Inclusions implements Inclusions {
  const factory _Inclusions(
      {final int? id,
      final String? name,
      final String? description}) = _$InclusionsImpl;

  factory _Inclusions.fromJson(Map<String, dynamic> json) =
      _$InclusionsImpl.fromJson;

  @override
  int? get id;
  @override
  String? get name;
  @override
  String? get description;
  @override
  @JsonKey(ignore: true)
  _$$InclusionsImplCopyWith<_$InclusionsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Activities _$ActivitiesFromJson(Map<String, dynamic> json) {
  return _Activities.fromJson(json);
}

/// @nodoc
mixin _$Activities {
  int? get id => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ActivitiesCopyWith<Activities> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ActivitiesCopyWith<$Res> {
  factory $ActivitiesCopyWith(
          Activities value, $Res Function(Activities) then) =
      _$ActivitiesCopyWithImpl<$Res, Activities>;
  @useResult
  $Res call({int? id, String? name});
}

/// @nodoc
class _$ActivitiesCopyWithImpl<$Res, $Val extends Activities>
    implements $ActivitiesCopyWith<$Res> {
  _$ActivitiesCopyWithImpl(this._value, this._then);

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
abstract class _$$ActivitiesImplCopyWith<$Res>
    implements $ActivitiesCopyWith<$Res> {
  factory _$$ActivitiesImplCopyWith(
          _$ActivitiesImpl value, $Res Function(_$ActivitiesImpl) then) =
      __$$ActivitiesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int? id, String? name});
}

/// @nodoc
class __$$ActivitiesImplCopyWithImpl<$Res>
    extends _$ActivitiesCopyWithImpl<$Res, _$ActivitiesImpl>
    implements _$$ActivitiesImplCopyWith<$Res> {
  __$$ActivitiesImplCopyWithImpl(
      _$ActivitiesImpl _value, $Res Function(_$ActivitiesImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
  }) {
    return _then(_$ActivitiesImpl(
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
class _$ActivitiesImpl implements _Activities {
  const _$ActivitiesImpl({this.id, this.name});

  factory _$ActivitiesImpl.fromJson(Map<String, dynamic> json) =>
      _$$ActivitiesImplFromJson(json);

  @override
  final int? id;
  @override
  final String? name;

  @override
  String toString() {
    return 'Activities(id: $id, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ActivitiesImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, name);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ActivitiesImplCopyWith<_$ActivitiesImpl> get copyWith =>
      __$$ActivitiesImplCopyWithImpl<_$ActivitiesImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ActivitiesImplToJson(
      this,
    );
  }
}

abstract class _Activities implements Activities {
  const factory _Activities({final int? id, final String? name}) =
      _$ActivitiesImpl;

  factory _Activities.fromJson(Map<String, dynamic> json) =
      _$ActivitiesImpl.fromJson;

  @override
  int? get id;
  @override
  String? get name;
  @override
  @JsonKey(ignore: true)
  _$$ActivitiesImplCopyWith<_$ActivitiesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Vendor _$VendorFromJson(Map<String, dynamic> json) {
  return _Vendor.fromJson(json);
}

/// @nodoc
mixin _$Vendor {
  int? get id => throw _privateConstructorUsedError;
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
  $Res call({int? id, User? user});

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
    Object? user = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
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
  $Res call({int? id, User? user});

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
    Object? user = freezed,
  }) {
    return _then(_$VendorImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
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
  const _$VendorImpl({this.id, this.user});

  factory _$VendorImpl.fromJson(Map<String, dynamic> json) =>
      _$$VendorImplFromJson(json);

  @override
  final int? id;
  @override
  final User? user;

  @override
  String toString() {
    return 'Vendor(id: $id, user: $user)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VendorImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.user, user) || other.user == user));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, user);

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
  const factory _Vendor({final int? id, final User? user}) = _$VendorImpl;

  factory _Vendor.fromJson(Map<String, dynamic> json) = _$VendorImpl.fromJson;

  @override
  int? get id;
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

Badge _$BadgeFromJson(Map<String, dynamic> json) {
  return _Badge.fromJson(json);
}

/// @nodoc
mixin _$Badge {
  int? get id => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  String? get icon => throw _privateConstructorUsedError;
  String? get color => throw _privateConstructorUsedError;
  String? get category => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BadgeCopyWith<Badge> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BadgeCopyWith<$Res> {
  factory $BadgeCopyWith(Badge value, $Res Function(Badge) then) =
      _$BadgeCopyWithImpl<$Res, Badge>;
  @useResult
  $Res call(
      {int? id, String? name, String? icon, String? color, String? category});
}

/// @nodoc
class _$BadgeCopyWithImpl<$Res, $Val extends Badge>
    implements $BadgeCopyWith<$Res> {
  _$BadgeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? icon = freezed,
    Object? color = freezed,
    Object? category = freezed,
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
      icon: freezed == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String?,
      color: freezed == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String?,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BadgeImplCopyWith<$Res> implements $BadgeCopyWith<$Res> {
  factory _$$BadgeImplCopyWith(
          _$BadgeImpl value, $Res Function(_$BadgeImpl) then) =
      __$$BadgeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? id, String? name, String? icon, String? color, String? category});
}

/// @nodoc
class __$$BadgeImplCopyWithImpl<$Res>
    extends _$BadgeCopyWithImpl<$Res, _$BadgeImpl>
    implements _$$BadgeImplCopyWith<$Res> {
  __$$BadgeImplCopyWithImpl(
      _$BadgeImpl _value, $Res Function(_$BadgeImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? icon = freezed,
    Object? color = freezed,
    Object? category = freezed,
  }) {
    return _then(_$BadgeImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      icon: freezed == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String?,
      color: freezed == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String?,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BadgeImpl implements _Badge {
  const _$BadgeImpl({this.id, this.name, this.icon, this.color, this.category});

  factory _$BadgeImpl.fromJson(Map<String, dynamic> json) =>
      _$$BadgeImplFromJson(json);

  @override
  final int? id;
  @override
  final String? name;
  @override
  final String? icon;
  @override
  final String? color;
  @override
  final String? category;

  @override
  String toString() {
    return 'Badge(id: $id, name: $name, icon: $icon, color: $color, category: $category)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BadgeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.category, category) ||
                other.category == category));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, icon, color, category);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BadgeImplCopyWith<_$BadgeImpl> get copyWith =>
      __$$BadgeImplCopyWithImpl<_$BadgeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BadgeImplToJson(
      this,
    );
  }
}

abstract class _Badge implements Badge {
  const factory _Badge(
      {final int? id,
      final String? name,
      final String? icon,
      final String? color,
      final String? category}) = _$BadgeImpl;

  factory _Badge.fromJson(Map<String, dynamic> json) = _$BadgeImpl.fromJson;

  @override
  int? get id;
  @override
  String? get name;
  @override
  String? get icon;
  @override
  String? get color;
  @override
  String? get category;
  @override
  @JsonKey(ignore: true)
  _$$BadgeImplCopyWith<_$BadgeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TrekStages _$TrekStagesFromJson(Map<String, dynamic> json) {
  return _TrekStages.fromJson(json);
}

/// @nodoc
mixin _$TrekStages {
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'stage_name')
  String? get stageName => throw _privateConstructorUsedError;
  String? get destination => throw _privateConstructorUsedError;
  @JsonKey(name: 'means_of_transport')
  String? get meansOfTransport => throw _privateConstructorUsedError;
  @JsonKey(name: 'date_time')
  String? get dateTime => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_boarding_point')
  bool? get isBoardingPoint => throw _privateConstructorUsedError;
  @JsonKey(name: 'batch_id')
  int? get batchId => throw _privateConstructorUsedError;
  @JsonKey(name: 'city_id')
  int? get cityId => throw _privateConstructorUsedError;
  City? get city => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TrekStagesCopyWith<TrekStages> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrekStagesCopyWith<$Res> {
  factory $TrekStagesCopyWith(
          TrekStages value, $Res Function(TrekStages) then) =
      _$TrekStagesCopyWithImpl<$Res, TrekStages>;
  @useResult
  $Res call(
      {int? id,
      @JsonKey(name: 'stage_name') String? stageName,
      String? destination,
      @JsonKey(name: 'means_of_transport') String? meansOfTransport,
      @JsonKey(name: 'date_time') String? dateTime,
      @JsonKey(name: 'is_boarding_point') bool? isBoardingPoint,
      @JsonKey(name: 'batch_id') int? batchId,
      @JsonKey(name: 'city_id') int? cityId,
      City? city});

  $CityCopyWith<$Res>? get city;
}

/// @nodoc
class _$TrekStagesCopyWithImpl<$Res, $Val extends TrekStages>
    implements $TrekStagesCopyWith<$Res> {
  _$TrekStagesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? stageName = freezed,
    Object? destination = freezed,
    Object? meansOfTransport = freezed,
    Object? dateTime = freezed,
    Object? isBoardingPoint = freezed,
    Object? batchId = freezed,
    Object? cityId = freezed,
    Object? city = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      stageName: freezed == stageName
          ? _value.stageName
          : stageName // ignore: cast_nullable_to_non_nullable
              as String?,
      destination: freezed == destination
          ? _value.destination
          : destination // ignore: cast_nullable_to_non_nullable
              as String?,
      meansOfTransport: freezed == meansOfTransport
          ? _value.meansOfTransport
          : meansOfTransport // ignore: cast_nullable_to_non_nullable
              as String?,
      dateTime: freezed == dateTime
          ? _value.dateTime
          : dateTime // ignore: cast_nullable_to_non_nullable
              as String?,
      isBoardingPoint: freezed == isBoardingPoint
          ? _value.isBoardingPoint
          : isBoardingPoint // ignore: cast_nullable_to_non_nullable
              as bool?,
      batchId: freezed == batchId
          ? _value.batchId
          : batchId // ignore: cast_nullable_to_non_nullable
              as int?,
      cityId: freezed == cityId
          ? _value.cityId
          : cityId // ignore: cast_nullable_to_non_nullable
              as int?,
      city: freezed == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as City?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $CityCopyWith<$Res>? get city {
    if (_value.city == null) {
      return null;
    }

    return $CityCopyWith<$Res>(_value.city!, (value) {
      return _then(_value.copyWith(city: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TrekStagesImplCopyWith<$Res>
    implements $TrekStagesCopyWith<$Res> {
  factory _$$TrekStagesImplCopyWith(
          _$TrekStagesImpl value, $Res Function(_$TrekStagesImpl) then) =
      __$$TrekStagesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? id,
      @JsonKey(name: 'stage_name') String? stageName,
      String? destination,
      @JsonKey(name: 'means_of_transport') String? meansOfTransport,
      @JsonKey(name: 'date_time') String? dateTime,
      @JsonKey(name: 'is_boarding_point') bool? isBoardingPoint,
      @JsonKey(name: 'batch_id') int? batchId,
      @JsonKey(name: 'city_id') int? cityId,
      City? city});

  @override
  $CityCopyWith<$Res>? get city;
}

/// @nodoc
class __$$TrekStagesImplCopyWithImpl<$Res>
    extends _$TrekStagesCopyWithImpl<$Res, _$TrekStagesImpl>
    implements _$$TrekStagesImplCopyWith<$Res> {
  __$$TrekStagesImplCopyWithImpl(
      _$TrekStagesImpl _value, $Res Function(_$TrekStagesImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? stageName = freezed,
    Object? destination = freezed,
    Object? meansOfTransport = freezed,
    Object? dateTime = freezed,
    Object? isBoardingPoint = freezed,
    Object? batchId = freezed,
    Object? cityId = freezed,
    Object? city = freezed,
  }) {
    return _then(_$TrekStagesImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      stageName: freezed == stageName
          ? _value.stageName
          : stageName // ignore: cast_nullable_to_non_nullable
              as String?,
      destination: freezed == destination
          ? _value.destination
          : destination // ignore: cast_nullable_to_non_nullable
              as String?,
      meansOfTransport: freezed == meansOfTransport
          ? _value.meansOfTransport
          : meansOfTransport // ignore: cast_nullable_to_non_nullable
              as String?,
      dateTime: freezed == dateTime
          ? _value.dateTime
          : dateTime // ignore: cast_nullable_to_non_nullable
              as String?,
      isBoardingPoint: freezed == isBoardingPoint
          ? _value.isBoardingPoint
          : isBoardingPoint // ignore: cast_nullable_to_non_nullable
              as bool?,
      batchId: freezed == batchId
          ? _value.batchId
          : batchId // ignore: cast_nullable_to_non_nullable
              as int?,
      cityId: freezed == cityId
          ? _value.cityId
          : cityId // ignore: cast_nullable_to_non_nullable
              as int?,
      city: freezed == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as City?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TrekStagesImpl implements _TrekStages {
  const _$TrekStagesImpl(
      {this.id,
      @JsonKey(name: 'stage_name') this.stageName,
      this.destination,
      @JsonKey(name: 'means_of_transport') this.meansOfTransport,
      @JsonKey(name: 'date_time') this.dateTime,
      @JsonKey(name: 'is_boarding_point') this.isBoardingPoint,
      @JsonKey(name: 'batch_id') this.batchId,
      @JsonKey(name: 'city_id') this.cityId,
      this.city});

  factory _$TrekStagesImpl.fromJson(Map<String, dynamic> json) =>
      _$$TrekStagesImplFromJson(json);

  @override
  final int? id;
  @override
  @JsonKey(name: 'stage_name')
  final String? stageName;
  @override
  final String? destination;
  @override
  @JsonKey(name: 'means_of_transport')
  final String? meansOfTransport;
  @override
  @JsonKey(name: 'date_time')
  final String? dateTime;
  @override
  @JsonKey(name: 'is_boarding_point')
  final bool? isBoardingPoint;
  @override
  @JsonKey(name: 'batch_id')
  final int? batchId;
  @override
  @JsonKey(name: 'city_id')
  final int? cityId;
  @override
  final City? city;

  @override
  String toString() {
    return 'TrekStages(id: $id, stageName: $stageName, destination: $destination, meansOfTransport: $meansOfTransport, dateTime: $dateTime, isBoardingPoint: $isBoardingPoint, batchId: $batchId, cityId: $cityId, city: $city)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrekStagesImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.stageName, stageName) ||
                other.stageName == stageName) &&
            (identical(other.destination, destination) ||
                other.destination == destination) &&
            (identical(other.meansOfTransport, meansOfTransport) ||
                other.meansOfTransport == meansOfTransport) &&
            (identical(other.dateTime, dateTime) ||
                other.dateTime == dateTime) &&
            (identical(other.isBoardingPoint, isBoardingPoint) ||
                other.isBoardingPoint == isBoardingPoint) &&
            (identical(other.batchId, batchId) || other.batchId == batchId) &&
            (identical(other.cityId, cityId) || other.cityId == cityId) &&
            (identical(other.city, city) || other.city == city));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, stageName, destination,
      meansOfTransport, dateTime, isBoardingPoint, batchId, cityId, city);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TrekStagesImplCopyWith<_$TrekStagesImpl> get copyWith =>
      __$$TrekStagesImplCopyWithImpl<_$TrekStagesImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TrekStagesImplToJson(
      this,
    );
  }
}

abstract class _TrekStages implements TrekStages {
  const factory _TrekStages(
      {final int? id,
      @JsonKey(name: 'stage_name') final String? stageName,
      final String? destination,
      @JsonKey(name: 'means_of_transport') final String? meansOfTransport,
      @JsonKey(name: 'date_time') final String? dateTime,
      @JsonKey(name: 'is_boarding_point') final bool? isBoardingPoint,
      @JsonKey(name: 'batch_id') final int? batchId,
      @JsonKey(name: 'city_id') final int? cityId,
      final City? city}) = _$TrekStagesImpl;

  factory _TrekStages.fromJson(Map<String, dynamic> json) =
      _$TrekStagesImpl.fromJson;

  @override
  int? get id;
  @override
  @JsonKey(name: 'stage_name')
  String? get stageName;
  @override
  String? get destination;
  @override
  @JsonKey(name: 'means_of_transport')
  String? get meansOfTransport;
  @override
  @JsonKey(name: 'date_time')
  String? get dateTime;
  @override
  @JsonKey(name: 'is_boarding_point')
  bool? get isBoardingPoint;
  @override
  @JsonKey(name: 'batch_id')
  int? get batchId;
  @override
  @JsonKey(name: 'city_id')
  int? get cityId;
  @override
  City? get city;
  @override
  @JsonKey(ignore: true)
  _$$TrekStagesImplCopyWith<_$TrekStagesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

City _$CityFromJson(Map<String, dynamic> json) {
  return _City.fromJson(json);
}

/// @nodoc
mixin _$City {
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'cityName')
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
  $Res call({int? id, @JsonKey(name: 'cityName') String? cityName});
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
  $Res call({int? id, @JsonKey(name: 'cityName') String? cityName});
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
  const _$CityImpl({this.id, @JsonKey(name: 'cityName') this.cityName});

  factory _$CityImpl.fromJson(Map<String, dynamic> json) =>
      _$$CityImplFromJson(json);

  @override
  final int? id;
  @override
  @JsonKey(name: 'cityName')
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
  const factory _City(
      {final int? id,
      @JsonKey(name: 'cityName') final String? cityName}) = _$CityImpl;

  factory _City.fromJson(Map<String, dynamic> json) = _$CityImpl.fromJson;

  @override
  int? get id;
  @override
  @JsonKey(name: 'cityName')
  String? get cityName;
  @override
  @JsonKey(ignore: true)
  _$$CityImplCopyWith<_$CityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Accommodations _$AccommodationsFromJson(Map<String, dynamic> json) {
  return _Accommodations.fromJson(json);
}

/// @nodoc
mixin _$Accommodations {
  Details? get details => throw _privateConstructorUsedError;
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'trek_id')
  int? get trekId => throw _privateConstructorUsedError;
  @JsonKey(name: 'batch_id')
  int? get batchId => throw _privateConstructorUsedError;
  String? get type => throw _privateConstructorUsedError;
  @JsonKey(name: 'createdAt')
  String? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updatedAt')
  String? get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AccommodationsCopyWith<Accommodations> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AccommodationsCopyWith<$Res> {
  factory $AccommodationsCopyWith(
          Accommodations value, $Res Function(Accommodations) then) =
      _$AccommodationsCopyWithImpl<$Res, Accommodations>;
  @useResult
  $Res call(
      {Details? details,
      int? id,
      @JsonKey(name: 'trek_id') int? trekId,
      @JsonKey(name: 'batch_id') int? batchId,
      String? type,
      @JsonKey(name: 'createdAt') String? createdAt,
      @JsonKey(name: 'updatedAt') String? updatedAt});

  $DetailsCopyWith<$Res>? get details;
}

/// @nodoc
class _$AccommodationsCopyWithImpl<$Res, $Val extends Accommodations>
    implements $AccommodationsCopyWith<$Res> {
  _$AccommodationsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? details = freezed,
    Object? id = freezed,
    Object? trekId = freezed,
    Object? batchId = freezed,
    Object? type = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      details: freezed == details
          ? _value.details
          : details // ignore: cast_nullable_to_non_nullable
              as Details?,
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      trekId: freezed == trekId
          ? _value.trekId
          : trekId // ignore: cast_nullable_to_non_nullable
              as int?,
      batchId: freezed == batchId
          ? _value.batchId
          : batchId // ignore: cast_nullable_to_non_nullable
              as int?,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $DetailsCopyWith<$Res>? get details {
    if (_value.details == null) {
      return null;
    }

    return $DetailsCopyWith<$Res>(_value.details!, (value) {
      return _then(_value.copyWith(details: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AccommodationsImplCopyWith<$Res>
    implements $AccommodationsCopyWith<$Res> {
  factory _$$AccommodationsImplCopyWith(_$AccommodationsImpl value,
          $Res Function(_$AccommodationsImpl) then) =
      __$$AccommodationsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Details? details,
      int? id,
      @JsonKey(name: 'trek_id') int? trekId,
      @JsonKey(name: 'batch_id') int? batchId,
      String? type,
      @JsonKey(name: 'createdAt') String? createdAt,
      @JsonKey(name: 'updatedAt') String? updatedAt});

  @override
  $DetailsCopyWith<$Res>? get details;
}

/// @nodoc
class __$$AccommodationsImplCopyWithImpl<$Res>
    extends _$AccommodationsCopyWithImpl<$Res, _$AccommodationsImpl>
    implements _$$AccommodationsImplCopyWith<$Res> {
  __$$AccommodationsImplCopyWithImpl(
      _$AccommodationsImpl _value, $Res Function(_$AccommodationsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? details = freezed,
    Object? id = freezed,
    Object? trekId = freezed,
    Object? batchId = freezed,
    Object? type = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$AccommodationsImpl(
      details: freezed == details
          ? _value.details
          : details // ignore: cast_nullable_to_non_nullable
              as Details?,
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      trekId: freezed == trekId
          ? _value.trekId
          : trekId // ignore: cast_nullable_to_non_nullable
              as int?,
      batchId: freezed == batchId
          ? _value.batchId
          : batchId // ignore: cast_nullable_to_non_nullable
              as int?,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AccommodationsImpl implements _Accommodations {
  const _$AccommodationsImpl(
      {this.details,
      this.id,
      @JsonKey(name: 'trek_id') this.trekId,
      @JsonKey(name: 'batch_id') this.batchId,
      this.type,
      @JsonKey(name: 'createdAt') this.createdAt,
      @JsonKey(name: 'updatedAt') this.updatedAt});

  factory _$AccommodationsImpl.fromJson(Map<String, dynamic> json) =>
      _$$AccommodationsImplFromJson(json);

  @override
  final Details? details;
  @override
  final int? id;
  @override
  @JsonKey(name: 'trek_id')
  final int? trekId;
  @override
  @JsonKey(name: 'batch_id')
  final int? batchId;
  @override
  final String? type;
  @override
  @JsonKey(name: 'createdAt')
  final String? createdAt;
  @override
  @JsonKey(name: 'updatedAt')
  final String? updatedAt;

  @override
  String toString() {
    return 'Accommodations(details: $details, id: $id, trekId: $trekId, batchId: $batchId, type: $type, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AccommodationsImpl &&
            (identical(other.details, details) || other.details == details) &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.trekId, trekId) || other.trekId == trekId) &&
            (identical(other.batchId, batchId) || other.batchId == batchId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, details, id, trekId, batchId, type, createdAt, updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AccommodationsImplCopyWith<_$AccommodationsImpl> get copyWith =>
      __$$AccommodationsImplCopyWithImpl<_$AccommodationsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AccommodationsImplToJson(
      this,
    );
  }
}

abstract class _Accommodations implements Accommodations {
  const factory _Accommodations(
          {final Details? details,
          final int? id,
          @JsonKey(name: 'trek_id') final int? trekId,
          @JsonKey(name: 'batch_id') final int? batchId,
          final String? type,
          @JsonKey(name: 'createdAt') final String? createdAt,
          @JsonKey(name: 'updatedAt') final String? updatedAt}) =
      _$AccommodationsImpl;

  factory _Accommodations.fromJson(Map<String, dynamic> json) =
      _$AccommodationsImpl.fromJson;

  @override
  Details? get details;
  @override
  int? get id;
  @override
  @JsonKey(name: 'trek_id')
  int? get trekId;
  @override
  @JsonKey(name: 'batch_id')
  int? get batchId;
  @override
  String? get type;
  @override
  @JsonKey(name: 'createdAt')
  String? get createdAt;
  @override
  @JsonKey(name: 'updatedAt')
  String? get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$AccommodationsImplCopyWith<_$AccommodationsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Details _$DetailsFromJson(Map<String, dynamic> json) {
  return _Details.fromJson(json);
}

/// @nodoc
mixin _$Details {
  int? get night => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DetailsCopyWith<Details> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DetailsCopyWith<$Res> {
  factory $DetailsCopyWith(Details value, $Res Function(Details) then) =
      _$DetailsCopyWithImpl<$Res, Details>;
  @useResult
  $Res call({int? night, String? location});
}

/// @nodoc
class _$DetailsCopyWithImpl<$Res, $Val extends Details>
    implements $DetailsCopyWith<$Res> {
  _$DetailsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? night = freezed,
    Object? location = freezed,
  }) {
    return _then(_value.copyWith(
      night: freezed == night
          ? _value.night
          : night // ignore: cast_nullable_to_non_nullable
              as int?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DetailsImplCopyWith<$Res> implements $DetailsCopyWith<$Res> {
  factory _$$DetailsImplCopyWith(
          _$DetailsImpl value, $Res Function(_$DetailsImpl) then) =
      __$$DetailsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int? night, String? location});
}

/// @nodoc
class __$$DetailsImplCopyWithImpl<$Res>
    extends _$DetailsCopyWithImpl<$Res, _$DetailsImpl>
    implements _$$DetailsImplCopyWith<$Res> {
  __$$DetailsImplCopyWithImpl(
      _$DetailsImpl _value, $Res Function(_$DetailsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? night = freezed,
    Object? location = freezed,
  }) {
    return _then(_$DetailsImpl(
      night: freezed == night
          ? _value.night
          : night // ignore: cast_nullable_to_non_nullable
              as int?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DetailsImpl implements _Details {
  const _$DetailsImpl({this.night, this.location});

  factory _$DetailsImpl.fromJson(Map<String, dynamic> json) =>
      _$$DetailsImplFromJson(json);

  @override
  final int? night;
  @override
  final String? location;

  @override
  String toString() {
    return 'Details(night: $night, location: $location)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DetailsImpl &&
            (identical(other.night, night) || other.night == night) &&
            (identical(other.location, location) ||
                other.location == location));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, night, location);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DetailsImplCopyWith<_$DetailsImpl> get copyWith =>
      __$$DetailsImplCopyWithImpl<_$DetailsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DetailsImplToJson(
      this,
    );
  }
}

abstract class _Details implements Details {
  const factory _Details({final int? night, final String? location}) =
      _$DetailsImpl;

  factory _Details.fromJson(Map<String, dynamic> json) = _$DetailsImpl.fromJson;

  @override
  int? get night;
  @override
  String? get location;
  @override
  @JsonKey(ignore: true)
  _$$DetailsImplCopyWith<_$DetailsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ItineraryItems _$ItineraryItemsFromJson(Map<String, dynamic> json) {
  return _ItineraryItems.fromJson(json);
}

/// @nodoc
mixin _$ItineraryItems {
  List<String>? get activities => throw _privateConstructorUsedError;
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'trek_id')
  int? get trekId => throw _privateConstructorUsedError;
  @JsonKey(name: 'createdAt')
  String? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updatedAt')
  String? get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ItineraryItemsCopyWith<ItineraryItems> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ItineraryItemsCopyWith<$Res> {
  factory $ItineraryItemsCopyWith(
          ItineraryItems value, $Res Function(ItineraryItems) then) =
      _$ItineraryItemsCopyWithImpl<$Res, ItineraryItems>;
  @useResult
  $Res call(
      {List<String>? activities,
      int? id,
      @JsonKey(name: 'trek_id') int? trekId,
      @JsonKey(name: 'createdAt') String? createdAt,
      @JsonKey(name: 'updatedAt') String? updatedAt});
}

/// @nodoc
class _$ItineraryItemsCopyWithImpl<$Res, $Val extends ItineraryItems>
    implements $ItineraryItemsCopyWith<$Res> {
  _$ItineraryItemsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? activities = freezed,
    Object? id = freezed,
    Object? trekId = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      activities: freezed == activities
          ? _value.activities
          : activities // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      trekId: freezed == trekId
          ? _value.trekId
          : trekId // ignore: cast_nullable_to_non_nullable
              as int?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ItineraryItemsImplCopyWith<$Res>
    implements $ItineraryItemsCopyWith<$Res> {
  factory _$$ItineraryItemsImplCopyWith(_$ItineraryItemsImpl value,
          $Res Function(_$ItineraryItemsImpl) then) =
      __$$ItineraryItemsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<String>? activities,
      int? id,
      @JsonKey(name: 'trek_id') int? trekId,
      @JsonKey(name: 'createdAt') String? createdAt,
      @JsonKey(name: 'updatedAt') String? updatedAt});
}

/// @nodoc
class __$$ItineraryItemsImplCopyWithImpl<$Res>
    extends _$ItineraryItemsCopyWithImpl<$Res, _$ItineraryItemsImpl>
    implements _$$ItineraryItemsImplCopyWith<$Res> {
  __$$ItineraryItemsImplCopyWithImpl(
      _$ItineraryItemsImpl _value, $Res Function(_$ItineraryItemsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? activities = freezed,
    Object? id = freezed,
    Object? trekId = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$ItineraryItemsImpl(
      activities: freezed == activities
          ? _value._activities
          : activities // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      trekId: freezed == trekId
          ? _value.trekId
          : trekId // ignore: cast_nullable_to_non_nullable
              as int?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ItineraryItemsImpl implements _ItineraryItems {
  const _$ItineraryItemsImpl(
      {final List<String>? activities,
      this.id,
      @JsonKey(name: 'trek_id') this.trekId,
      @JsonKey(name: 'createdAt') this.createdAt,
      @JsonKey(name: 'updatedAt') this.updatedAt})
      : _activities = activities;

  factory _$ItineraryItemsImpl.fromJson(Map<String, dynamic> json) =>
      _$$ItineraryItemsImplFromJson(json);

  final List<String>? _activities;
  @override
  List<String>? get activities {
    final value = _activities;
    if (value == null) return null;
    if (_activities is EqualUnmodifiableListView) return _activities;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final int? id;
  @override
  @JsonKey(name: 'trek_id')
  final int? trekId;
  @override
  @JsonKey(name: 'createdAt')
  final String? createdAt;
  @override
  @JsonKey(name: 'updatedAt')
  final String? updatedAt;

  @override
  String toString() {
    return 'ItineraryItems(activities: $activities, id: $id, trekId: $trekId, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ItineraryItemsImpl &&
            const DeepCollectionEquality()
                .equals(other._activities, _activities) &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.trekId, trekId) || other.trekId == trekId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_activities),
      id,
      trekId,
      createdAt,
      updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ItineraryItemsImplCopyWith<_$ItineraryItemsImpl> get copyWith =>
      __$$ItineraryItemsImplCopyWithImpl<_$ItineraryItemsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ItineraryItemsImplToJson(
      this,
    );
  }
}

abstract class _ItineraryItems implements ItineraryItems {
  const factory _ItineraryItems(
          {final List<String>? activities,
          final int? id,
          @JsonKey(name: 'trek_id') final int? trekId,
          @JsonKey(name: 'createdAt') final String? createdAt,
          @JsonKey(name: 'updatedAt') final String? updatedAt}) =
      _$ItineraryItemsImpl;

  factory _ItineraryItems.fromJson(Map<String, dynamic> json) =
      _$ItineraryItemsImpl.fromJson;

  @override
  List<String>? get activities;
  @override
  int? get id;
  @override
  @JsonKey(name: 'trek_id')
  int? get trekId;
  @override
  @JsonKey(name: 'createdAt')
  String? get createdAt;
  @override
  @JsonKey(name: 'updatedAt')
  String? get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$ItineraryItemsImplCopyWith<_$ItineraryItemsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Images _$ImagesFromJson(Map<String, dynamic> json) {
  return _Images.fromJson(json);
}

/// @nodoc
mixin _$Images {
  int? get id => throw _privateConstructorUsedError;
  String? get url => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_cover')
  bool? get isCover => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ImagesCopyWith<Images> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ImagesCopyWith<$Res> {
  factory $ImagesCopyWith(Images value, $Res Function(Images) then) =
      _$ImagesCopyWithImpl<$Res, Images>;
  @useResult
  $Res call({int? id, String? url, @JsonKey(name: 'is_cover') bool? isCover});
}

/// @nodoc
class _$ImagesCopyWithImpl<$Res, $Val extends Images>
    implements $ImagesCopyWith<$Res> {
  _$ImagesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? url = freezed,
    Object? isCover = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      url: freezed == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String?,
      isCover: freezed == isCover
          ? _value.isCover
          : isCover // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ImagesImplCopyWith<$Res> implements $ImagesCopyWith<$Res> {
  factory _$$ImagesImplCopyWith(
          _$ImagesImpl value, $Res Function(_$ImagesImpl) then) =
      __$$ImagesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int? id, String? url, @JsonKey(name: 'is_cover') bool? isCover});
}

/// @nodoc
class __$$ImagesImplCopyWithImpl<$Res>
    extends _$ImagesCopyWithImpl<$Res, _$ImagesImpl>
    implements _$$ImagesImplCopyWith<$Res> {
  __$$ImagesImplCopyWithImpl(
      _$ImagesImpl _value, $Res Function(_$ImagesImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? url = freezed,
    Object? isCover = freezed,
  }) {
    return _then(_$ImagesImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      url: freezed == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String?,
      isCover: freezed == isCover
          ? _value.isCover
          : isCover // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ImagesImpl implements _Images {
  const _$ImagesImpl(
      {this.id, this.url, @JsonKey(name: 'is_cover') this.isCover});

  factory _$ImagesImpl.fromJson(Map<String, dynamic> json) =>
      _$$ImagesImplFromJson(json);

  @override
  final int? id;
  @override
  final String? url;
  @override
  @JsonKey(name: 'is_cover')
  final bool? isCover;

  @override
  String toString() {
    return 'Images(id: $id, url: $url, isCover: $isCover)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ImagesImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.isCover, isCover) || other.isCover == isCover));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, url, isCover);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ImagesImplCopyWith<_$ImagesImpl> get copyWith =>
      __$$ImagesImplCopyWithImpl<_$ImagesImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ImagesImplToJson(
      this,
    );
  }
}

abstract class _Images implements Images {
  const factory _Images(
      {final int? id,
      final String? url,
      @JsonKey(name: 'is_cover') final bool? isCover}) = _$ImagesImpl;

  factory _Images.fromJson(Map<String, dynamic> json) = _$ImagesImpl.fromJson;

  @override
  int? get id;
  @override
  String? get url;
  @override
  @JsonKey(name: 'is_cover')
  bool? get isCover;
  @override
  @JsonKey(ignore: true)
  _$$ImagesImplCopyWith<_$ImagesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CategoryRatings _$CategoryRatingsFromJson(Map<String, dynamic> json) {
  return _CategoryRatings.fromJson(json);
}

/// @nodoc
mixin _$CategoryRatings {
  @JsonKey(name: 'safety_security')
  double? get safetySecurity => throw _privateConstructorUsedError;
  @JsonKey(name: 'organizer_manner')
  double? get organizerManner => throw _privateConstructorUsedError;
  @JsonKey(name: 'trek_planning')
  double? get trekPlanning => throw _privateConstructorUsedError;
  @JsonKey(name: 'women_safety')
  double? get womenSafety => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CategoryRatingsCopyWith<CategoryRatings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CategoryRatingsCopyWith<$Res> {
  factory $CategoryRatingsCopyWith(
          CategoryRatings value, $Res Function(CategoryRatings) then) =
      _$CategoryRatingsCopyWithImpl<$Res, CategoryRatings>;
  @useResult
  $Res call(
      {@JsonKey(name: 'safety_security') double? safetySecurity,
      @JsonKey(name: 'organizer_manner') double? organizerManner,
      @JsonKey(name: 'trek_planning') double? trekPlanning,
      @JsonKey(name: 'women_safety') double? womenSafety});
}

/// @nodoc
class _$CategoryRatingsCopyWithImpl<$Res, $Val extends CategoryRatings>
    implements $CategoryRatingsCopyWith<$Res> {
  _$CategoryRatingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? safetySecurity = freezed,
    Object? organizerManner = freezed,
    Object? trekPlanning = freezed,
    Object? womenSafety = freezed,
  }) {
    return _then(_value.copyWith(
      safetySecurity: freezed == safetySecurity
          ? _value.safetySecurity
          : safetySecurity // ignore: cast_nullable_to_non_nullable
              as double?,
      organizerManner: freezed == organizerManner
          ? _value.organizerManner
          : organizerManner // ignore: cast_nullable_to_non_nullable
              as double?,
      trekPlanning: freezed == trekPlanning
          ? _value.trekPlanning
          : trekPlanning // ignore: cast_nullable_to_non_nullable
              as double?,
      womenSafety: freezed == womenSafety
          ? _value.womenSafety
          : womenSafety // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CategoryRatingsImplCopyWith<$Res>
    implements $CategoryRatingsCopyWith<$Res> {
  factory _$$CategoryRatingsImplCopyWith(_$CategoryRatingsImpl value,
          $Res Function(_$CategoryRatingsImpl) then) =
      __$$CategoryRatingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'safety_security') double? safetySecurity,
      @JsonKey(name: 'organizer_manner') double? organizerManner,
      @JsonKey(name: 'trek_planning') double? trekPlanning,
      @JsonKey(name: 'women_safety') double? womenSafety});
}

/// @nodoc
class __$$CategoryRatingsImplCopyWithImpl<$Res>
    extends _$CategoryRatingsCopyWithImpl<$Res, _$CategoryRatingsImpl>
    implements _$$CategoryRatingsImplCopyWith<$Res> {
  __$$CategoryRatingsImplCopyWithImpl(
      _$CategoryRatingsImpl _value, $Res Function(_$CategoryRatingsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? safetySecurity = freezed,
    Object? organizerManner = freezed,
    Object? trekPlanning = freezed,
    Object? womenSafety = freezed,
  }) {
    return _then(_$CategoryRatingsImpl(
      safetySecurity: freezed == safetySecurity
          ? _value.safetySecurity
          : safetySecurity // ignore: cast_nullable_to_non_nullable
              as double?,
      organizerManner: freezed == organizerManner
          ? _value.organizerManner
          : organizerManner // ignore: cast_nullable_to_non_nullable
              as double?,
      trekPlanning: freezed == trekPlanning
          ? _value.trekPlanning
          : trekPlanning // ignore: cast_nullable_to_non_nullable
              as double?,
      womenSafety: freezed == womenSafety
          ? _value.womenSafety
          : womenSafety // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CategoryRatingsImpl implements _CategoryRatings {
  const _$CategoryRatingsImpl(
      {@JsonKey(name: 'safety_security') this.safetySecurity,
      @JsonKey(name: 'organizer_manner') this.organizerManner,
      @JsonKey(name: 'trek_planning') this.trekPlanning,
      @JsonKey(name: 'women_safety') this.womenSafety});

  factory _$CategoryRatingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$CategoryRatingsImplFromJson(json);

  @override
  @JsonKey(name: 'safety_security')
  final double? safetySecurity;
  @override
  @JsonKey(name: 'organizer_manner')
  final double? organizerManner;
  @override
  @JsonKey(name: 'trek_planning')
  final double? trekPlanning;
  @override
  @JsonKey(name: 'women_safety')
  final double? womenSafety;

  @override
  String toString() {
    return 'CategoryRatings(safetySecurity: $safetySecurity, organizerManner: $organizerManner, trekPlanning: $trekPlanning, womenSafety: $womenSafety)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CategoryRatingsImpl &&
            (identical(other.safetySecurity, safetySecurity) ||
                other.safetySecurity == safetySecurity) &&
            (identical(other.organizerManner, organizerManner) ||
                other.organizerManner == organizerManner) &&
            (identical(other.trekPlanning, trekPlanning) ||
                other.trekPlanning == trekPlanning) &&
            (identical(other.womenSafety, womenSafety) ||
                other.womenSafety == womenSafety));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, safetySecurity, organizerManner, trekPlanning, womenSafety);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CategoryRatingsImplCopyWith<_$CategoryRatingsImpl> get copyWith =>
      __$$CategoryRatingsImplCopyWithImpl<_$CategoryRatingsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CategoryRatingsImplToJson(
      this,
    );
  }
}

abstract class _CategoryRatings implements CategoryRatings {
  const factory _CategoryRatings(
          {@JsonKey(name: 'safety_security') final double? safetySecurity,
          @JsonKey(name: 'organizer_manner') final double? organizerManner,
          @JsonKey(name: 'trek_planning') final double? trekPlanning,
          @JsonKey(name: 'women_safety') final double? womenSafety}) =
      _$CategoryRatingsImpl;

  factory _CategoryRatings.fromJson(Map<String, dynamic> json) =
      _$CategoryRatingsImpl.fromJson;

  @override
  @JsonKey(name: 'safety_security')
  double? get safetySecurity;
  @override
  @JsonKey(name: 'organizer_manner')
  double? get organizerManner;
  @override
  @JsonKey(name: 'trek_planning')
  double? get trekPlanning;
  @override
  @JsonKey(name: 'women_safety')
  double? get womenSafety;
  @override
  @JsonKey(ignore: true)
  _$$CategoryRatingsImplCopyWith<_$CategoryRatingsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BatchInfo _$BatchInfoFromJson(Map<String, dynamic> json) {
  return _BatchInfo.fromJson(json);
}

/// @nodoc
mixin _$BatchInfo {
  int? get id => throw _privateConstructorUsedError;
  String? get tbrId => throw _privateConstructorUsedError;
  String? get startDate => throw _privateConstructorUsedError;
  String? get startTime => throw _privateConstructorUsedError;
  String? get endDate => throw _privateConstructorUsedError;
  int? get bookedSlots => throw _privateConstructorUsedError;
  int? get availableSlots => throw _privateConstructorUsedError;
  int? get capacity => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BatchInfoCopyWith<BatchInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BatchInfoCopyWith<$Res> {
  factory $BatchInfoCopyWith(BatchInfo value, $Res Function(BatchInfo) then) =
      _$BatchInfoCopyWithImpl<$Res, BatchInfo>;
  @useResult
  $Res call(
      {int? id,
      String? tbrId,
      String? startDate,
      String? startTime,
      String? endDate,
      int? bookedSlots,
      int? availableSlots,
      int? capacity});
}

/// @nodoc
class _$BatchInfoCopyWithImpl<$Res, $Val extends BatchInfo>
    implements $BatchInfoCopyWith<$Res> {
  _$BatchInfoCopyWithImpl(this._value, this._then);

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
    Object? startTime = freezed,
    Object? endDate = freezed,
    Object? bookedSlots = freezed,
    Object? availableSlots = freezed,
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
      startTime: freezed == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as String?,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as String?,
      bookedSlots: freezed == bookedSlots
          ? _value.bookedSlots
          : bookedSlots // ignore: cast_nullable_to_non_nullable
              as int?,
      availableSlots: freezed == availableSlots
          ? _value.availableSlots
          : availableSlots // ignore: cast_nullable_to_non_nullable
              as int?,
      capacity: freezed == capacity
          ? _value.capacity
          : capacity // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BatchInfoImplCopyWith<$Res>
    implements $BatchInfoCopyWith<$Res> {
  factory _$$BatchInfoImplCopyWith(
          _$BatchInfoImpl value, $Res Function(_$BatchInfoImpl) then) =
      __$$BatchInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? id,
      String? tbrId,
      String? startDate,
      String? startTime,
      String? endDate,
      int? bookedSlots,
      int? availableSlots,
      int? capacity});
}

/// @nodoc
class __$$BatchInfoImplCopyWithImpl<$Res>
    extends _$BatchInfoCopyWithImpl<$Res, _$BatchInfoImpl>
    implements _$$BatchInfoImplCopyWith<$Res> {
  __$$BatchInfoImplCopyWithImpl(
      _$BatchInfoImpl _value, $Res Function(_$BatchInfoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? tbrId = freezed,
    Object? startDate = freezed,
    Object? startTime = freezed,
    Object? endDate = freezed,
    Object? bookedSlots = freezed,
    Object? availableSlots = freezed,
    Object? capacity = freezed,
  }) {
    return _then(_$BatchInfoImpl(
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
      startTime: freezed == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as String?,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as String?,
      bookedSlots: freezed == bookedSlots
          ? _value.bookedSlots
          : bookedSlots // ignore: cast_nullable_to_non_nullable
              as int?,
      availableSlots: freezed == availableSlots
          ? _value.availableSlots
          : availableSlots // ignore: cast_nullable_to_non_nullable
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
class _$BatchInfoImpl implements _BatchInfo {
  const _$BatchInfoImpl(
      {this.id,
      this.tbrId,
      this.startDate,
      this.startTime,
      this.endDate,
      this.bookedSlots,
      this.availableSlots,
      this.capacity});

  factory _$BatchInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$BatchInfoImplFromJson(json);

  @override
  final int? id;
  @override
  final String? tbrId;
  @override
  final String? startDate;
  @override
  final String? startTime;
  @override
  final String? endDate;
  @override
  final int? bookedSlots;
  @override
  final int? availableSlots;
  @override
  final int? capacity;

  @override
  String toString() {
    return 'BatchInfo(id: $id, tbrId: $tbrId, startDate: $startDate, startTime: $startTime, endDate: $endDate, bookedSlots: $bookedSlots, availableSlots: $availableSlots, capacity: $capacity)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BatchInfoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tbrId, tbrId) || other.tbrId == tbrId) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.bookedSlots, bookedSlots) ||
                other.bookedSlots == bookedSlots) &&
            (identical(other.availableSlots, availableSlots) ||
                other.availableSlots == availableSlots) &&
            (identical(other.capacity, capacity) ||
                other.capacity == capacity));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, tbrId, startDate, startTime,
      endDate, bookedSlots, availableSlots, capacity);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BatchInfoImplCopyWith<_$BatchInfoImpl> get copyWith =>
      __$$BatchInfoImplCopyWithImpl<_$BatchInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BatchInfoImplToJson(
      this,
    );
  }
}

abstract class _BatchInfo implements BatchInfo {
  const factory _BatchInfo(
      {final int? id,
      final String? tbrId,
      final String? startDate,
      final String? startTime,
      final String? endDate,
      final int? bookedSlots,
      final int? availableSlots,
      final int? capacity}) = _$BatchInfoImpl;

  factory _BatchInfo.fromJson(Map<String, dynamic> json) =
      _$BatchInfoImpl.fromJson;

  @override
  int? get id;
  @override
  String? get tbrId;
  @override
  String? get startDate;
  @override
  String? get startTime;
  @override
  String? get endDate;
  @override
  int? get bookedSlots;
  @override
  int? get availableSlots;
  @override
  int? get capacity;
  @override
  @JsonKey(ignore: true)
  _$$BatchInfoImplCopyWith<_$BatchInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CancellationPolicy _$CancellationPolicyFromJson(Map<String, dynamic> json) {
  return _CancellationPolicy.fromJson(json);
}

/// @nodoc
mixin _$CancellationPolicy {
  int? get id => throw _privateConstructorUsedError;
  String? get type => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  List<Rules>? get rules => throw _privateConstructorUsedError;
  @JsonKey(name: 'descriptionPoints')
  List<String>? get descriptionPoints => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CancellationPolicyCopyWith<CancellationPolicy> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CancellationPolicyCopyWith<$Res> {
  factory $CancellationPolicyCopyWith(
          CancellationPolicy value, $Res Function(CancellationPolicy) then) =
      _$CancellationPolicyCopyWithImpl<$Res, CancellationPolicy>;
  @useResult
  $Res call(
      {int? id,
      String? type,
      String? title,
      String? description,
      List<Rules>? rules,
      @JsonKey(name: 'descriptionPoints') List<String>? descriptionPoints});
}

/// @nodoc
class _$CancellationPolicyCopyWithImpl<$Res, $Val extends CancellationPolicy>
    implements $CancellationPolicyCopyWith<$Res> {
  _$CancellationPolicyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? type = freezed,
    Object? title = freezed,
    Object? description = freezed,
    Object? rules = freezed,
    Object? descriptionPoints = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String?,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      rules: freezed == rules
          ? _value.rules
          : rules // ignore: cast_nullable_to_non_nullable
              as List<Rules>?,
      descriptionPoints: freezed == descriptionPoints
          ? _value.descriptionPoints
          : descriptionPoints // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CancellationPolicyImplCopyWith<$Res>
    implements $CancellationPolicyCopyWith<$Res> {
  factory _$$CancellationPolicyImplCopyWith(_$CancellationPolicyImpl value,
          $Res Function(_$CancellationPolicyImpl) then) =
      __$$CancellationPolicyImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? id,
      String? type,
      String? title,
      String? description,
      List<Rules>? rules,
      @JsonKey(name: 'descriptionPoints') List<String>? descriptionPoints});
}

/// @nodoc
class __$$CancellationPolicyImplCopyWithImpl<$Res>
    extends _$CancellationPolicyCopyWithImpl<$Res, _$CancellationPolicyImpl>
    implements _$$CancellationPolicyImplCopyWith<$Res> {
  __$$CancellationPolicyImplCopyWithImpl(_$CancellationPolicyImpl _value,
      $Res Function(_$CancellationPolicyImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? type = freezed,
    Object? title = freezed,
    Object? description = freezed,
    Object? rules = freezed,
    Object? descriptionPoints = freezed,
  }) {
    return _then(_$CancellationPolicyImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String?,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      rules: freezed == rules
          ? _value._rules
          : rules // ignore: cast_nullable_to_non_nullable
              as List<Rules>?,
      descriptionPoints: freezed == descriptionPoints
          ? _value._descriptionPoints
          : descriptionPoints // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CancellationPolicyImpl implements _CancellationPolicy {
  const _$CancellationPolicyImpl(
      {this.id,
      this.type,
      this.title,
      this.description,
      final List<Rules>? rules,
      @JsonKey(name: 'descriptionPoints')
      final List<String>? descriptionPoints})
      : _rules = rules,
        _descriptionPoints = descriptionPoints;

  factory _$CancellationPolicyImpl.fromJson(Map<String, dynamic> json) =>
      _$$CancellationPolicyImplFromJson(json);

  @override
  final int? id;
  @override
  final String? type;
  @override
  final String? title;
  @override
  final String? description;
  final List<Rules>? _rules;
  @override
  List<Rules>? get rules {
    final value = _rules;
    if (value == null) return null;
    if (_rules is EqualUnmodifiableListView) return _rules;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _descriptionPoints;
  @override
  @JsonKey(name: 'descriptionPoints')
  List<String>? get descriptionPoints {
    final value = _descriptionPoints;
    if (value == null) return null;
    if (_descriptionPoints is EqualUnmodifiableListView)
      return _descriptionPoints;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'CancellationPolicy(id: $id, type: $type, title: $title, description: $description, rules: $rules, descriptionPoints: $descriptionPoints)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CancellationPolicyImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(other._rules, _rules) &&
            const DeepCollectionEquality()
                .equals(other._descriptionPoints, _descriptionPoints));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      type,
      title,
      description,
      const DeepCollectionEquality().hash(_rules),
      const DeepCollectionEquality().hash(_descriptionPoints));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CancellationPolicyImplCopyWith<_$CancellationPolicyImpl> get copyWith =>
      __$$CancellationPolicyImplCopyWithImpl<_$CancellationPolicyImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CancellationPolicyImplToJson(
      this,
    );
  }
}

abstract class _CancellationPolicy implements CancellationPolicy {
  const factory _CancellationPolicy(
      {final int? id,
      final String? type,
      final String? title,
      final String? description,
      final List<Rules>? rules,
      @JsonKey(name: 'descriptionPoints')
      final List<String>? descriptionPoints}) = _$CancellationPolicyImpl;

  factory _CancellationPolicy.fromJson(Map<String, dynamic> json) =
      _$CancellationPolicyImpl.fromJson;

  @override
  int? get id;
  @override
  String? get type;
  @override
  String? get title;
  @override
  String? get description;
  @override
  List<Rules>? get rules;
  @override
  @JsonKey(name: 'descriptionPoints')
  List<String>? get descriptionPoints;
  @override
  @JsonKey(ignore: true)
  _$$CancellationPolicyImplCopyWith<_$CancellationPolicyImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Rules _$RulesFromJson(Map<String, dynamic> json) {
  return _Rules.fromJson(json);
}

/// @nodoc
mixin _$Rules {
  String? get rule => throw _privateConstructorUsedError;
  dynamic get deduction => throw _privateConstructorUsedError;
  dynamic get hours => throw _privateConstructorUsedError;
  @JsonKey(name: 'deduction_type')
  String? get deductionType => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RulesCopyWith<Rules> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RulesCopyWith<$Res> {
  factory $RulesCopyWith(Rules value, $Res Function(Rules) then) =
      _$RulesCopyWithImpl<$Res, Rules>;
  @useResult
  $Res call(
      {String? rule,
      dynamic deduction,
      dynamic hours,
      @JsonKey(name: 'deduction_type') String? deductionType});
}

/// @nodoc
class _$RulesCopyWithImpl<$Res, $Val extends Rules>
    implements $RulesCopyWith<$Res> {
  _$RulesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rule = freezed,
    Object? deduction = freezed,
    Object? hours = freezed,
    Object? deductionType = freezed,
  }) {
    return _then(_value.copyWith(
      rule: freezed == rule
          ? _value.rule
          : rule // ignore: cast_nullable_to_non_nullable
              as String?,
      deduction: freezed == deduction
          ? _value.deduction
          : deduction // ignore: cast_nullable_to_non_nullable
              as dynamic,
      hours: freezed == hours
          ? _value.hours
          : hours // ignore: cast_nullable_to_non_nullable
              as dynamic,
      deductionType: freezed == deductionType
          ? _value.deductionType
          : deductionType // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RulesImplCopyWith<$Res> implements $RulesCopyWith<$Res> {
  factory _$$RulesImplCopyWith(
          _$RulesImpl value, $Res Function(_$RulesImpl) then) =
      __$$RulesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? rule,
      dynamic deduction,
      dynamic hours,
      @JsonKey(name: 'deduction_type') String? deductionType});
}

/// @nodoc
class __$$RulesImplCopyWithImpl<$Res>
    extends _$RulesCopyWithImpl<$Res, _$RulesImpl>
    implements _$$RulesImplCopyWith<$Res> {
  __$$RulesImplCopyWithImpl(
      _$RulesImpl _value, $Res Function(_$RulesImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rule = freezed,
    Object? deduction = freezed,
    Object? hours = freezed,
    Object? deductionType = freezed,
  }) {
    return _then(_$RulesImpl(
      rule: freezed == rule
          ? _value.rule
          : rule // ignore: cast_nullable_to_non_nullable
              as String?,
      deduction: freezed == deduction
          ? _value.deduction
          : deduction // ignore: cast_nullable_to_non_nullable
              as dynamic,
      hours: freezed == hours
          ? _value.hours
          : hours // ignore: cast_nullable_to_non_nullable
              as dynamic,
      deductionType: freezed == deductionType
          ? _value.deductionType
          : deductionType // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RulesImpl implements _Rules {
  const _$RulesImpl(
      {this.rule,
      this.deduction,
      this.hours,
      @JsonKey(name: 'deduction_type') this.deductionType});

  factory _$RulesImpl.fromJson(Map<String, dynamic> json) =>
      _$$RulesImplFromJson(json);

  @override
  final String? rule;
  @override
  final dynamic deduction;
  @override
  final dynamic hours;
  @override
  @JsonKey(name: 'deduction_type')
  final String? deductionType;

  @override
  String toString() {
    return 'Rules(rule: $rule, deduction: $deduction, hours: $hours, deductionType: $deductionType)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RulesImpl &&
            (identical(other.rule, rule) || other.rule == rule) &&
            const DeepCollectionEquality().equals(other.deduction, deduction) &&
            const DeepCollectionEquality().equals(other.hours, hours) &&
            (identical(other.deductionType, deductionType) ||
                other.deductionType == deductionType));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      rule,
      const DeepCollectionEquality().hash(deduction),
      const DeepCollectionEquality().hash(hours),
      deductionType);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RulesImplCopyWith<_$RulesImpl> get copyWith =>
      __$$RulesImplCopyWithImpl<_$RulesImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RulesImplToJson(
      this,
    );
  }
}

abstract class _Rules implements Rules {
  const factory _Rules(
          {final String? rule,
          final dynamic deduction,
          final dynamic hours,
          @JsonKey(name: 'deduction_type') final String? deductionType}) =
      _$RulesImpl;

  factory _Rules.fromJson(Map<String, dynamic> json) = _$RulesImpl.fromJson;

  @override
  String? get rule;
  @override
  dynamic get deduction;
  @override
  dynamic get hours;
  @override
  @JsonKey(name: 'deduction_type')
  String? get deductionType;
  @override
  @JsonKey(ignore: true)
  _$$RulesImplCopyWith<_$RulesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LatestReviews _$LatestReviewsFromJson(Map<String, dynamic> json) {
  return _LatestReviews.fromJson(json);
}

/// @nodoc
mixin _$LatestReviews {
  @JsonKey(name: 'customer_id')
  int? get customerId => throw _privateConstructorUsedError;
  @JsonKey(name: 'customer_name')
  String? get customerName => throw _privateConstructorUsedError;
  @JsonKey(name: 'rating_value')
  double? get ratingValue => throw _privateConstructorUsedError;
  String? get content => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String? get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $LatestReviewsCopyWith<LatestReviews> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LatestReviewsCopyWith<$Res> {
  factory $LatestReviewsCopyWith(
          LatestReviews value, $Res Function(LatestReviews) then) =
      _$LatestReviewsCopyWithImpl<$Res, LatestReviews>;
  @useResult
  $Res call(
      {@JsonKey(name: 'customer_id') int? customerId,
      @JsonKey(name: 'customer_name') String? customerName,
      @JsonKey(name: 'rating_value') double? ratingValue,
      String? content,
      @JsonKey(name: 'created_at') String? createdAt});
}

/// @nodoc
class _$LatestReviewsCopyWithImpl<$Res, $Val extends LatestReviews>
    implements $LatestReviewsCopyWith<$Res> {
  _$LatestReviewsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? customerId = freezed,
    Object? customerName = freezed,
    Object? ratingValue = freezed,
    Object? content = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      customerId: freezed == customerId
          ? _value.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as int?,
      customerName: freezed == customerName
          ? _value.customerName
          : customerName // ignore: cast_nullable_to_non_nullable
              as String?,
      ratingValue: freezed == ratingValue
          ? _value.ratingValue
          : ratingValue // ignore: cast_nullable_to_non_nullable
              as double?,
      content: freezed == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LatestReviewsImplCopyWith<$Res>
    implements $LatestReviewsCopyWith<$Res> {
  factory _$$LatestReviewsImplCopyWith(
          _$LatestReviewsImpl value, $Res Function(_$LatestReviewsImpl) then) =
      __$$LatestReviewsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'customer_id') int? customerId,
      @JsonKey(name: 'customer_name') String? customerName,
      @JsonKey(name: 'rating_value') double? ratingValue,
      String? content,
      @JsonKey(name: 'created_at') String? createdAt});
}

/// @nodoc
class __$$LatestReviewsImplCopyWithImpl<$Res>
    extends _$LatestReviewsCopyWithImpl<$Res, _$LatestReviewsImpl>
    implements _$$LatestReviewsImplCopyWith<$Res> {
  __$$LatestReviewsImplCopyWithImpl(
      _$LatestReviewsImpl _value, $Res Function(_$LatestReviewsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? customerId = freezed,
    Object? customerName = freezed,
    Object? ratingValue = freezed,
    Object? content = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_$LatestReviewsImpl(
      customerId: freezed == customerId
          ? _value.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as int?,
      customerName: freezed == customerName
          ? _value.customerName
          : customerName // ignore: cast_nullable_to_non_nullable
              as String?,
      ratingValue: freezed == ratingValue
          ? _value.ratingValue
          : ratingValue // ignore: cast_nullable_to_non_nullable
              as double?,
      content: freezed == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LatestReviewsImpl implements _LatestReviews {
  const _$LatestReviewsImpl(
      {@JsonKey(name: 'customer_id') this.customerId,
      @JsonKey(name: 'customer_name') this.customerName,
      @JsonKey(name: 'rating_value') this.ratingValue,
      this.content,
      @JsonKey(name: 'created_at') this.createdAt});

  factory _$LatestReviewsImpl.fromJson(Map<String, dynamic> json) =>
      _$$LatestReviewsImplFromJson(json);

  @override
  @JsonKey(name: 'customer_id')
  final int? customerId;
  @override
  @JsonKey(name: 'customer_name')
  final String? customerName;
  @override
  @JsonKey(name: 'rating_value')
  final double? ratingValue;
  @override
  final String? content;
  @override
  @JsonKey(name: 'created_at')
  final String? createdAt;

  @override
  String toString() {
    return 'LatestReviews(customerId: $customerId, customerName: $customerName, ratingValue: $ratingValue, content: $content, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LatestReviewsImpl &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.ratingValue, ratingValue) ||
                other.ratingValue == ratingValue) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, customerId, customerName, ratingValue, content, createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LatestReviewsImplCopyWith<_$LatestReviewsImpl> get copyWith =>
      __$$LatestReviewsImplCopyWithImpl<_$LatestReviewsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LatestReviewsImplToJson(
      this,
    );
  }
}

abstract class _LatestReviews implements LatestReviews {
  const factory _LatestReviews(
          {@JsonKey(name: 'customer_id') final int? customerId,
          @JsonKey(name: 'customer_name') final String? customerName,
          @JsonKey(name: 'rating_value') final double? ratingValue,
          final String? content,
          @JsonKey(name: 'created_at') final String? createdAt}) =
      _$LatestReviewsImpl;

  factory _LatestReviews.fromJson(Map<String, dynamic> json) =
      _$LatestReviewsImpl.fromJson;

  @override
  @JsonKey(name: 'customer_id')
  int? get customerId;
  @override
  @JsonKey(name: 'customer_name')
  String? get customerName;
  @override
  @JsonKey(name: 'rating_value')
  double? get ratingValue;
  @override
  String? get content;
  @override
  @JsonKey(name: 'created_at')
  String? get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$LatestReviewsImplCopyWith<_$LatestReviewsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
