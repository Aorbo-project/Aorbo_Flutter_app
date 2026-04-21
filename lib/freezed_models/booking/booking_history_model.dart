import 'package:freezed_annotation/freezed_annotation.dart';
import '../profile/user_profile_model.dart';

part 'booking_history_model.freezed.dart';
part 'booking_history_model.g.dart';

@freezed
class BookingHistoryModel with _$BookingHistoryModel {
  const factory BookingHistoryModel({
    bool? success,
    List<BookingHistoryData>? data,
    Pagination? pagination,
    int? count,
  }) = _BookingHistoryModel;

  factory BookingHistoryModel.fromJson(Map<String, dynamic> json) =>
      _$BookingHistoryModelFromJson(json);
}

@freezed
class BookingHistoryData with _$BookingHistoryData {
  const factory BookingHistoryData({
    int? id,
    @JsonKey(name: 'customer_id') int? customerId,
    @JsonKey(name: 'trek_id') int? trekId,
    @JsonKey(name: 'vendor_id') int? vendorId,
    @JsonKey(name: 'batch_id') int? batchId,
    @JsonKey(name: 'coupon_id') int? couponId,
    @JsonKey(name: 'total_travelers') int? totalTravelers,
    @JsonKey(name: 'total_amount') String? totalAmount,
    @JsonKey(name: 'discount_amount') String? discountAmount,
    @JsonKey(name: 'final_amount') String? finalAmount,
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
    Trek? trek,
    Batch? batch,
    City? city,
    List<TravelersDataModel>? travelers,
    @JsonKey(name: 'trek_status') String? trekStatus,
    @JsonKey(name: 'rating_given') bool? ratingGiven,
    @JsonKey(name: 'rating_value') double? ratingValue,
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
    List<String>? inclusions,
    List<String>? exclusions,
    List<int>? activities,
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
    @JsonKey(name: 'captain_phone') String? captainPhone,
  }) = _Trek;

  factory Trek.fromJson(Map<String, dynamic> json) => _$TrekFromJson(json);
}

@freezed
class Vendor with _$Vendor {
  const factory Vendor({
    int? id,
    @JsonKey(name: 'company_info') CompanyInfo? companyInfo,
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