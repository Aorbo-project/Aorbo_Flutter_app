import 'package:freezed_annotation/freezed_annotation.dart';
import '../profile/user_profile_model.dart';
import '../treks/trek_detail_model.dart';

part 'booking_history_model.freezed.dart';
part 'booking_history_model.g.dart';

@freezed
class BookingHistoryModel with _$BookingHistoryModel {
  const factory BookingHistoryModel({
    bool? success,
    String? message,
    List<BookingHistoryData>? data,
    Pagination? pagination,
    int? count,
  }) = _BookingHistoryModel;

  factory BookingHistoryModel.fromJson(Map<String, dynamic> json) =>
      _$BookingHistoryModelFromJson(json);
}

@freezed
class BookingDetailsResponseModel with _$BookingDetailsResponseModel {
  const factory BookingDetailsResponseModel({
    bool? success,
    String? message,
    BookingHistoryData? data
  }) = _BookingDetailsResponseModel;

  factory BookingDetailsResponseModel.fromJson(Map<String, dynamic> json) =>
      _$BookingDetailsResponseModelFromJson(json);
}

String? _toString(dynamic value) => value?.toString();

@freezed
class BookingHistoryData with _$BookingHistoryData {
  const factory BookingHistoryData({
    int? id,
    @JsonKey(name: 'customer_id') int? customerId,
    @JsonKey(name: 'trek_id') int? trekId,
    @JsonKey(name: 'vendor_id') int? vendorId,
    @JsonKey(name: 'VendorId') int? vendorIdAlt, // API extra key
    @JsonKey(name: 'batch_id') int? batchId,
    @JsonKey(name: 'coupon_id') int? couponId,
    @JsonKey(name: 'total_travelers') int? totalTravelers,

    // ✅ SAFE STRING CONVERSION
    @JsonKey(name: 'total_amount', fromJson: _toString)
    String? totalAmount,

    @JsonKey(name: 'platform_fees', fromJson: _toString)
    String? platformFees,

    @JsonKey(name: 'gst_amount', fromJson: _toString)
    String? gstAmount,

    @JsonKey(name: 'discount_amount', fromJson: _toString)
    String? discountAmount,

    @JsonKey(name: 'final_amount', fromJson: _toString)
    String? finalAmount,

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
    @JsonKey(name: 'rating_value') dynamic ratingValue,
    @JsonKey(name: 'trek_stage_date_time') String? trekStageDateTime,
    @JsonKey(name: 'trek_stage_name') String? trekStageName,
  }) = _BookingHistoryData;

  factory BookingHistoryData.fromJson(Map<String, dynamic> json) =>
      _$BookingHistoryDataFromJson(json);
}

@freezed
class Trek with _$Trek {
  const factory Trek({
    @JsonKey(name: 'city_ids') List<int>? cityIds,
    List<dynamic>? inclusions,
    List<dynamic>? exclusions,
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
    String? difficulty,
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
    Badge? badge,
    @JsonKey(name: 'trek_stages') List<TrekStages>? trekStages,
    dynamic rating,
    int? ratingCount,
    Destination? destination,
    @JsonKey(name: 'captain_name') String? captainName,
    @JsonKey(name: 'captain_phone') String? captainPhone,
  }) = _Trek;

  factory Trek.fromJson(Map<String, dynamic> json) => _$TrekFromJson(json);
}

@freezed
class Vendor with _$Vendor {
  const factory Vendor({
    int? id,
    @JsonKey(name: 'business_name') String? businessName,
    @JsonKey(name: 'business_logo') String? businessLogo
  }) = _Vendor;

  factory Vendor.fromJson(Map<String, dynamic> json) =>
      _$VendorFromJson(json);
}

@freezed
class CompanyInfo with _$CompanyInfo {
  const factory CompanyInfo({
    @JsonKey(name: 'company_name') String? companyName,
    @JsonKey(name: 'contact_person') String? contactPerson,
    String? phone,
    String? email,
    String? address,
    @JsonKey(name: 'gst_number') String? gstNumber,
    @JsonKey(name: 'pan_number') String? panNumber,
    @JsonKey(name: 'bank_name') String? bankName,
    @JsonKey(name: 'account_number') String? accountNumber,
    @JsonKey(name: 'ifsc_code') String? ifscCode,
    @JsonKey(name: 'commission_rate') int? commissionRate,
  }) = _CompanyInfo;

  factory CompanyInfo.fromJson(Map<String, dynamic> json) =>
      _$CompanyInfoFromJson(json);
}

@freezed
class Destination with _$Destination {
  const factory Destination({
    int? id,
    String? name,
  }) = _Destination;

  factory Destination.fromJson(Map<String, dynamic> json) =>
      _$DestinationFromJson(json);
}

@freezed
class Batch with _$Batch {
  const factory Batch({
    int? id,
    @JsonKey(name: 'tbr_id') String? tbrId,
    @JsonKey(name: 'start_date') String? startDate,
    @JsonKey(name: 'end_date') String? endDate,
    int? capacity,
    @JsonKey(name: 'booked_slots') int? bookedSlots,
    @JsonKey(name: 'available_slots') int? availableSlots,
  }) = _Batch;

  factory Batch.fromJson(Map<String, dynamic> json) =>
      _$BatchFromJson(json);
}

@freezed
class City with _$City {
  const factory City({
    int? id,
    String? cityName,
  }) = _City;

  factory City.fromJson(Map<String, dynamic> json) =>
      _$CityFromJson(json);
}

@freezed
class TravelersDataModel with _$TravelersDataModel {
  const factory TravelersDataModel({
    int? id,
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
    Traveler? traveler,
  }) = _TravelersDataModel;

  factory TravelersDataModel.fromJson(Map<String, dynamic> json) =>
      _$TravelersDataModelFromJson(json);
}

@freezed
class Pagination with _$Pagination {
  const factory Pagination({
    int? currentPage,
    int? totalPages,
    int? totalCount,
    int? limit,
    bool? hasNextPage,
    bool? hasPrevPage,
    int? nextPage,
    int? prevPage,
  }) = _Pagination;

  factory Pagination.fromJson(Map<String, dynamic> json) =>
      _$PaginationFromJson(json);
}