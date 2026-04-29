// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_history_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BookingHistoryModelImpl _$$BookingHistoryModelImplFromJson(
        Map<String, dynamic> json) =>
    _$BookingHistoryModelImpl(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => BookingHistoryData.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: json['pagination'] == null
          ? null
          : Pagination.fromJson(json['pagination'] as Map<String, dynamic>),
      count: json['count'] as int?,
    );

Map<String, dynamic> _$$BookingHistoryModelImplToJson(
        _$BookingHistoryModelImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
      'pagination': instance.pagination,
      'count': instance.count,
    };

_$BookingHistoryDataImpl _$$BookingHistoryDataImplFromJson(
        Map<String, dynamic> json) =>
    _$BookingHistoryDataImpl(
      id: json['id'] as int?,
      customerId: json['customer_id'] as int?,
      trekId: json['trek_id'] as int?,
      vendorId: json['vendor_id'] as int?,
      batchId: json['batch_id'] as int?,
      couponId: json['coupon_id'] as int?,
      totalTravelers: json['total_travelers'] as int?,
      totalAmount: json['total_amount'] as String?,
      discountAmount: json['discount_amount'] as String?,
      finalAmount: json['final_amount'] as String?,
      paymentStatus: json['payment_status'] as String?,
      status: json['status'] as String?,
      bookingDate: json['booking_date'] as String?,
      specialRequests: json['special_requests'] as String?,
      bookingSource: json['booking_source'] as String?,
      primaryContactTravelerId: json['primary_contact_traveler_id'] as int?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      userId: json['user_id'] as int?,
      trek: json['trek'] == null
          ? null
          : Trek.fromJson(json['trek'] as Map<String, dynamic>),
      batch: json['batch'] == null
          ? null
          : Batch.fromJson(json['batch'] as Map<String, dynamic>),
      city: json['city'] == null
          ? null
          : City.fromJson(json['city'] as Map<String, dynamic>),
      travelers: (json['travelers'] as List<dynamic>?)
          ?.map((e) => TravelersDataModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      trekStatus: json['trek_status'] as String?,
      ratingGiven: json['rating_given'] as bool?,
      ratingValue: (json['rating_value'] as num?)?.toDouble(),
      trekStageDateTime: json['trek_stage_date_time'] as String?,
      trekStageName: json['trek_stage_name'] as String?,
    );

Map<String, dynamic> _$$BookingHistoryDataImplToJson(
        _$BookingHistoryDataImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'customer_id': instance.customerId,
      'trek_id': instance.trekId,
      'vendor_id': instance.vendorId,
      'batch_id': instance.batchId,
      'coupon_id': instance.couponId,
      'total_travelers': instance.totalTravelers,
      'total_amount': instance.totalAmount,
      'discount_amount': instance.discountAmount,
      'final_amount': instance.finalAmount,
      'payment_status': instance.paymentStatus,
      'status': instance.status,
      'booking_date': instance.bookingDate,
      'special_requests': instance.specialRequests,
      'booking_source': instance.bookingSource,
      'primary_contact_traveler_id': instance.primaryContactTravelerId,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'user_id': instance.userId,
      'trek': instance.trek,
      'batch': instance.batch,
      'city': instance.city,
      'travelers': instance.travelers,
      'trek_status': instance.trekStatus,
      'rating_given': instance.ratingGiven,
      'rating_value': instance.ratingValue,
      'trek_stage_date_time': instance.trekStageDateTime,
      'trek_stage_name': instance.trekStageName,
    };

_$TrekImpl _$$TrekImplFromJson(Map<String, dynamic> json) => _$TrekImpl(
      cityIds:
          (json['city_ids'] as List<dynamic>?)?.map((e) => e as int).toList(),
      inclusions: (json['inclusions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      exclusions: (json['exclusions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      activities:
          (json['activities'] as List<dynamic>?)?.map((e) => e as int).toList(),
      id: json['id'] as int?,
      mtrId: json['mtr_id'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      vendorId: json['vendor_id'] as int?,
      destinationId: json['destination_id'] as int?,
      captainId: json['captain_id'] as int?,
      duration: json['duration'] as String?,
      durationDays: json['duration_days'] as int?,
      durationNights: json['duration_nights'] as int?,
      basePrice: json['base_price'] as String?,
      maxParticipants: json['max_participants'] as int?,
      trekkingRules: json['trekking_rules'] as String?,
      emergencyProtocols: json['emergency_protocols'] as String?,
      organizerNotes: json['organizer_notes'] as String?,
      status: json['status'] as String?,
      discountValue: json['discount_value'] as String?,
      discountType: json['discount_type'] as String?,
      hasDiscount: json['has_discount'] as bool?,
      cancellationPolicyId: json['cancellation_policy_id'] as int?,
      badgeId: json['badge_id'] as int?,
      hasBeenEdited: json['has_been_edited'] as int?,
      safetySecurityCount: json['safety_security_count'] as int?,
      organizerMannerCount: json['organizer_manner_count'] as int?,
      trekPlanningCount: json['trek_planning_count'] as int?,
      womenSafetyCount: json['women_safety_count'] as int?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      vendor: json['vendor'] == null
          ? null
          : Vendor.fromJson(json['vendor'] as Map<String, dynamic>),
      rating: json['rating'] as int?,
      ratingCount: json['ratingCount'] as int?,
      destination: json['destination'] == null
          ? null
          : Destination.fromJson(json['destination'] as Map<String, dynamic>),
      captainName: json['captain_name'] as String?,
      captainPhone: json['captain_phone'] as String?,
    );

Map<String, dynamic> _$$TrekImplToJson(_$TrekImpl instance) =>
    <String, dynamic>{
      'city_ids': instance.cityIds,
      'inclusions': instance.inclusions,
      'exclusions': instance.exclusions,
      'activities': instance.activities,
      'id': instance.id,
      'mtr_id': instance.mtrId,
      'title': instance.title,
      'description': instance.description,
      'vendor_id': instance.vendorId,
      'destination_id': instance.destinationId,
      'captain_id': instance.captainId,
      'duration': instance.duration,
      'duration_days': instance.durationDays,
      'duration_nights': instance.durationNights,
      'base_price': instance.basePrice,
      'max_participants': instance.maxParticipants,
      'trekking_rules': instance.trekkingRules,
      'emergency_protocols': instance.emergencyProtocols,
      'organizer_notes': instance.organizerNotes,
      'status': instance.status,
      'discount_value': instance.discountValue,
      'discount_type': instance.discountType,
      'has_discount': instance.hasDiscount,
      'cancellation_policy_id': instance.cancellationPolicyId,
      'badge_id': instance.badgeId,
      'has_been_edited': instance.hasBeenEdited,
      'safety_security_count': instance.safetySecurityCount,
      'organizer_manner_count': instance.organizerMannerCount,
      'trek_planning_count': instance.trekPlanningCount,
      'women_safety_count': instance.womenSafetyCount,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'vendor': instance.vendor,
      'rating': instance.rating,
      'ratingCount': instance.ratingCount,
      'destination': instance.destination,
      'captain_name': instance.captainName,
      'captain_phone': instance.captainPhone,
    };

_$VendorImpl _$$VendorImplFromJson(Map<String, dynamic> json) => _$VendorImpl(
      id: json['id'] as int?,
      companyInfo: json['company_info'] == null
          ? null
          : CompanyInfo.fromJson(json['company_info'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$VendorImplToJson(_$VendorImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'company_info': instance.companyInfo,
    };

_$CompanyInfoImpl _$$CompanyInfoImplFromJson(Map<String, dynamic> json) =>
    _$CompanyInfoImpl(
      companyName: json['company_name'] as String?,
      contactPerson: json['contact_person'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      address: json['address'] as String?,
      gstNumber: json['gst_number'] as String?,
      panNumber: json['pan_number'] as String?,
      bankName: json['bank_name'] as String?,
      accountNumber: json['account_number'] as String?,
      ifscCode: json['ifsc_code'] as String?,
      commissionRate: json['commission_rate'] as int?,
    );

Map<String, dynamic> _$$CompanyInfoImplToJson(_$CompanyInfoImpl instance) =>
    <String, dynamic>{
      'company_name': instance.companyName,
      'contact_person': instance.contactPerson,
      'phone': instance.phone,
      'email': instance.email,
      'address': instance.address,
      'gst_number': instance.gstNumber,
      'pan_number': instance.panNumber,
      'bank_name': instance.bankName,
      'account_number': instance.accountNumber,
      'ifsc_code': instance.ifscCode,
      'commission_rate': instance.commissionRate,
    };

_$DestinationImpl _$$DestinationImplFromJson(Map<String, dynamic> json) =>
    _$DestinationImpl(
      id: json['id'] as int?,
      name: json['name'] as String?,
    );

Map<String, dynamic> _$$DestinationImplToJson(_$DestinationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };

_$BatchImpl _$$BatchImplFromJson(Map<String, dynamic> json) => _$BatchImpl(
      id: json['id'] as int?,
      tbrId: json['tbr_id'] as String?,
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
      capacity: json['capacity'] as int?,
      bookedSlots: json['booked_slots'] as int?,
      availableSlots: json['available_slots'] as int?,
    );

Map<String, dynamic> _$$BatchImplToJson(_$BatchImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tbr_id': instance.tbrId,
      'start_date': instance.startDate,
      'end_date': instance.endDate,
      'capacity': instance.capacity,
      'booked_slots': instance.bookedSlots,
      'available_slots': instance.availableSlots,
    };

_$CityImpl _$$CityImplFromJson(Map<String, dynamic> json) => _$CityImpl(
      id: json['id'] as int?,
      cityName: json['cityName'] as String?,
    );

Map<String, dynamic> _$$CityImplToJson(_$CityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'cityName': instance.cityName,
    };

_$TravelersDataModelImpl _$$TravelersDataModelImplFromJson(
        Map<String, dynamic> json) =>
    _$TravelersDataModelImpl(
      id: json['id'] as int?,
      bookingId: json['booking_id'] as int?,
      travelerId: json['traveler_id'] as int?,
      isPrimary: json['is_primary'] as bool?,
      specialRequirements: json['special_requirements'] as String?,
      accommodationPreference: json['accommodation_preference'] as String?,
      mealPreference: json['meal_preference'] as String?,
      status: json['status'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      traveler: json['traveler'] == null
          ? null
          : Traveler.fromJson(json['traveler'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$TravelersDataModelImplToJson(
        _$TravelersDataModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'booking_id': instance.bookingId,
      'traveler_id': instance.travelerId,
      'is_primary': instance.isPrimary,
      'special_requirements': instance.specialRequirements,
      'accommodation_preference': instance.accommodationPreference,
      'meal_preference': instance.mealPreference,
      'status': instance.status,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'traveler': instance.traveler,
    };

_$PaginationImpl _$$PaginationImplFromJson(Map<String, dynamic> json) =>
    _$PaginationImpl(
      currentPage: json['currentPage'] as int?,
      totalPages: json['totalPages'] as int?,
      totalCount: json['totalCount'] as int?,
      limit: json['limit'] as int?,
      hasNextPage: json['hasNextPage'] as bool?,
      hasPrevPage: json['hasPrevPage'] as bool?,
      nextPage: json['nextPage'] as int?,
      prevPage: json['prevPage'] as int?,
    );

Map<String, dynamic> _$$PaginationImplToJson(_$PaginationImpl instance) =>
    <String, dynamic>{
      'currentPage': instance.currentPage,
      'totalPages': instance.totalPages,
      'totalCount': instance.totalCount,
      'limit': instance.limit,
      'hasNextPage': instance.hasNextPage,
      'hasPrevPage': instance.hasPrevPage,
      'nextPage': instance.nextPage,
      'prevPage': instance.prevPage,
    };
