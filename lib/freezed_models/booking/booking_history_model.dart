import 'package:freezed_annotation/freezed_annotation.dart';
import '../profile/user_profile_model.dart';

part 'booking_history_model.freezed.dart';
part 'booking_history_model.g.dart';

String? _toString(dynamic value) => value?.toString();

String? _parseImageUrl(String? path) {
  if (path == null || path.isEmpty) return null;

  if (path.startsWith('http')) {
    return path;
  }

  return 'https://api.aorbotreks.co.in/$path';
}

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
    BookingHistoryData? data,
  }) = _BookingDetailsResponseModel;

  factory BookingDetailsResponseModel.fromJson(Map<String, dynamic> json) =>
      _$BookingDetailsResponseModelFromJson(json);
}

@freezed
class BookingHistoryData with _$BookingHistoryData {
  const factory BookingHistoryData({
    int? id,

    @JsonKey(name: 'customer_id')
    int? customerId,

    @JsonKey(name: 'trek_id')
    int? trekId,

    @JsonKey(name: 'vendor_id')
    int? vendorId,

    @JsonKey(name: 'VendorId')
    int? vendorIdAlt,

    @JsonKey(name: 'batch_id')
    int? batchId,

    @JsonKey(name: 'coupon_id')
    int? couponId,

    @JsonKey(name: 'total_travelers')
    int? totalTravelers,

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

    @JsonKey(name: 'payment_status')
    String? paymentStatus,

    String? status,

    @JsonKey(name: 'booking_date')
    String? bookingDate,

    @JsonKey(name: 'special_requests')
    String? specialRequests,

    @JsonKey(name: 'booking_source')
    String? bookingSource,

    @JsonKey(name: 'primary_contact_traveler_id')
    int? primaryContactTravelerId,

    String? createdAt,

    String? updatedAt,

    @JsonKey(name: 'user_id')
    int? userId,

    @JsonKey(name: 'city_id')
    int? cityId,

    @JsonKey(name: 'cancellation_policy_type')
    dynamic cancellationPolicyType,

    @JsonKey(name: 'advance_amount', fromJson: _toString)
    String? advanceAmount,

    @JsonKey(name: 'remaining_amount', fromJson: _toString)
    String? remainingAmount,

    Trek? trek,

    Batch? batch,

    List<TravelersDataModel>? travelers,

    @JsonKey(name: 'booking_number')
    String? bookingNumber,

    @JsonKey(name: 'trek_status')
    String? trekStatus,

    @JsonKey(name: 'rating_given')
    bool? ratingGiven,

    @JsonKey(name: 'rating_value')
    dynamic ratingValue,
  }) = _BookingHistoryData;

  factory BookingHistoryData.fromJson(Map<String, dynamic> json) =>
      _$BookingHistoryDataFromJson(json);
}

@freezed
class Trek with _$Trek {
  const factory Trek({
    int? id,

    String? title,

    String? duration,

    String? description,

    @JsonKey(name: 'base_price')
    String? basePrice,

    String? status,

    Vendor? vendor,

    Destination? destination,

    @JsonKey(name: 'captain_name')
    String? captainName,

    @JsonKey(name: 'captain_phone')
    String? captainPhone,

    String? difficulty,

    @JsonKey(name: 'duration_days')
    int? durationDays,

    @JsonKey(name: 'duration_nights')
    int? durationNights,

    @JsonKey(name: 'boarding_point')
    String? boardingPoint,
  }) = _Trek;

  factory Trek.fromJson(Map<String, dynamic> json) =>
      _$TrekFromJson(json);
}

@freezed
class Vendor with _$Vendor {
  const factory Vendor({
    int? id,

    @JsonKey(name: 'business_name')
    String? businessName,

    @JsonKey(
      name: 'business_logo',
      fromJson: _parseImageUrl,
    )
    String? businessLogo,

    String? city,
    String? state,
    String? address,
    String? phone,
    String? email,
  }) = _Vendor;

  factory Vendor.fromJson(Map<String, dynamic> json) =>
      _$VendorFromJson(json);
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

    @JsonKey(name: 'tbr_id')
    String? tbrId,

    @JsonKey(name: 'start_date')
    String? startDate,

    @JsonKey(name: 'end_date')
    String? endDate,

    @JsonKey(name: 'start_time')
    String? startTime,

    @JsonKey(name: 'available_slots')
    int? availableSlots,

    @JsonKey(name: 'booked_slots')
    int? bookedSlots,

    int? capacity,
  }) = _Batch;

  factory Batch.fromJson(Map<String, dynamic> json) =>
      _$BatchFromJson(json);
}

@freezed
class TravelersDataModel with _$TravelersDataModel {
  const factory TravelersDataModel({
    int? id,

    @JsonKey(name: 'booking_id')
    int? bookingId,

    @JsonKey(name: 'traveler_id')
    int? travelerId,

    @JsonKey(name: 'is_primary')
    bool? isPrimary,

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
  }) = _Pagination;

  factory Pagination.fromJson(Map<String, dynamic> json) =>
      _$PaginationFromJson(json);
}