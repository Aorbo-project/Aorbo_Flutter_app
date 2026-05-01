import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';

part 'trek_detail_model.freezed.dart';
part 'trek_detail_model.g.dart';

@freezed
class TrekDetailModal with _$TrekDetailModal {
  const factory TrekDetailModal({
    bool? success,
    TrekDetailData? data,
  }) = _TrekDetailModal;

  factory TrekDetailModal.fromJson(Map<String, dynamic> json) =>
      _$TrekDetailModalFromJson(json);
}

@freezed
class TrekDetailData with _$TrekDetailData {
  const factory TrekDetailData({
    @JsonKey(name: 'city_ids') List<int>? cityIds,
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
    @JsonKey(name: 'cancellation_policy') CancellationPolicy? cancellationPolicy,
    @JsonKey(name: 'booking_type') String? bookingType,
  }) = _TrekDetailData;

  factory TrekDetailData.fromJson(Map<String, dynamic> json) =>
      _$TrekDetailDataFromJson(json);
}

extension TrekDetailDataExtension on TrekDetailData {
  /// Returns the departure datetime from the first boarding point stage.
  /// If no boarding stage is found, returns null.
  DateTime? get departureDateTimeFromStages {
    // Find the first stage where isBoardingPoint == true
    for (final stage in trekStages ?? []) {
      if (stage.isBoardingPoint == true && stage.dateTime != null) {
        return _parseCustomDateTime(stage.dateTime!);
      }
    }
    return null;
  }

  DateTime? _parseCustomDateTime(String dateTimeStr) {
    // Try to parse "yyyy-MM-dd hh:mm a" format (e.g., 2026-05-09 12:00 PM)
    try {
      return DateFormat('yyyy-MM-dd hh:mm a').parse(dateTimeStr);
    } catch (_) {}
    // Fallback to default parse
    try {
      return DateTime.parse(dateTimeStr);
    } catch (_) {}
    return null;
  }
}

@freezed
class Inclusions with _$Inclusions {
  const factory Inclusions({
    int? id,
    String? name,
    String? description,
  }) = _Inclusions;

  factory Inclusions.fromJson(Map<String, dynamic> json) =>
      _$InclusionsFromJson(json);
}

@freezed
class Activities with _$Activities {
  const factory Activities({
    int? id,
    String? name,
  }) = _Activities;

  factory Activities.fromJson(Map<String, dynamic> json) =>
      _$ActivitiesFromJson(json);
}

@freezed
class Vendor with _$Vendor {
  const factory Vendor({
    int? id,
    User? user,
  }) = _Vendor;

  factory Vendor.fromJson(Map<String, dynamic> json) =>
      _$VendorFromJson(json);
}

@freezed
class User with _$User {
  const factory User({
    int? id,
    String? name,
    String? email,
    String? phone,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

@freezed
class Badge with _$Badge {
  const factory Badge({
    int? id,
    String? name,
    String? icon,
    String? color,
    String? category,
  }) = _Badge;

  factory Badge.fromJson(Map<String, dynamic> json) => _$BadgeFromJson(json);
}

@freezed
class TrekStages with _$TrekStages {
  const factory TrekStages({
    int? id,
    @JsonKey(name: 'stage_name') String? stageName,
    String? destination,
    @JsonKey(name: 'means_of_transport') String? meansOfTransport,
    @JsonKey(name: 'date_time') String? dateTime,
    @JsonKey(name: 'is_boarding_point') bool? isBoardingPoint,
    @JsonKey(name: 'batch_id') int? batchId,
    @JsonKey(name: 'city_id') int? cityId,
    City? city,
  }) = _TrekStages;

  factory TrekStages.fromJson(Map<String, dynamic> json) =>
      _$TrekStagesFromJson(json);
}

@freezed
class City with _$City {
  const factory City({
    int? id,
    @JsonKey(name: 'cityName') String? cityName,
  }) = _City;

  factory City.fromJson(Map<String, dynamic> json) => _$CityFromJson(json);
}

@freezed
class Accommodations with _$Accommodations {
  const factory Accommodations({
    Details? details,
    int? id,
    @JsonKey(name: 'trek_id') int? trekId,
    @JsonKey(name: 'batch_id') int? batchId,
    String? type,
    @JsonKey(name: 'createdAt') String? createdAt,
    @JsonKey(name: 'updatedAt') String? updatedAt,
  }) = _Accommodations;

  factory Accommodations.fromJson(Map<String, dynamic> json) =>
      _$AccommodationsFromJson(json);
}

@freezed
class Details with _$Details {
  const factory Details({
    int? night,
    String? location,
  }) = _Details;

  factory Details.fromJson(Map<String, dynamic> json) =>
      _$DetailsFromJson(json);
}

@freezed
class ItineraryItems with _$ItineraryItems {
  const factory ItineraryItems({
    List<String>? activities,
    int? id,
    @JsonKey(name: 'trek_id') int? trekId,
    @JsonKey(name: 'createdAt') String? createdAt,
    @JsonKey(name: 'updatedAt') String? updatedAt,
  }) = _ItineraryItems;

  factory ItineraryItems.fromJson(Map<String, dynamic> json) =>
      _$ItineraryItemsFromJson(json);
}

@freezed
class Images with _$Images {
  const factory Images({
    int? id,
    String? url,
    @JsonKey(name: 'is_cover') bool? isCover,
  }) = _Images;

  factory Images.fromJson(Map<String, dynamic> json) =>
      _$ImagesFromJson(json);
}

@freezed
class CategoryRatings with _$CategoryRatings {
  const factory CategoryRatings({
    @JsonKey(name: 'safety_security') double? safetySecurity,
    @JsonKey(name: 'organizer_manner') double? organizerManner,
    @JsonKey(name: 'trek_planning') double? trekPlanning,
    @JsonKey(name: 'women_safety') double? womenSafety,
  }) = _CategoryRatings;

  factory CategoryRatings.fromJson(Map<String, dynamic> json) =>
      _$CategoryRatingsFromJson(json);
}

@freezed
class BatchInfo with _$BatchInfo {
  const factory BatchInfo({
    int? id,
    String? tbrId,
   String? startDate,
    String? endDate,
    int? bookedSlots,
   int? availableSlots,
    int? capacity,
  }) = _BatchInfo;

  factory BatchInfo.fromJson(Map<String, dynamic> json) =>
      _$BatchInfoFromJson(json);
}

@freezed
class CancellationPolicy with _$CancellationPolicy {
  const factory CancellationPolicy({
    int? id,
    String? type,
    String? title,
    String? description,
    List<Rules>? rules,
    @JsonKey(name: 'descriptionPoints') List<String>? descriptionPoints,
  }) = _CancellationPolicy;

  factory CancellationPolicy.fromJson(Map<String, dynamic> json) =>
      _$CancellationPolicyFromJson(json);
}

@freezed
class Rules with _$Rules {
  const factory Rules({
    String? rule,
    dynamic deduction,
    dynamic hours,
    @JsonKey(name: 'deduction_type') String? deductionType,
  }) = _Rules;

  factory Rules.fromJson(Map<String, dynamic> json) => _$RulesFromJson(json);
}

@freezed
class LatestReviews with _$LatestReviews {
  const factory LatestReviews({
    @JsonKey(name: 'customer_id') int? customerId,
    @JsonKey(name: 'customer_name') String? customerName,
    @JsonKey(name: 'rating_value') double? ratingValue,
    String? content,
    @JsonKey(name: 'created_at') String? createdAt,
  }) = _LatestReviews;

  factory LatestReviews.fromJson(Map<String, dynamic> json) =>
      _$LatestReviewsFromJson(json);
}