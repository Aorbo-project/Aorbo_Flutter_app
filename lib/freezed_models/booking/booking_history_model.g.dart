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

_$BookingDetailsResponseModelImpl _$$BookingDetailsResponseModelImplFromJson(
        Map<String, dynamic> json) =>
    _$BookingDetailsResponseModelImpl(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: json['data'] == null
          ? null
          : BookingHistoryData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$BookingDetailsResponseModelImplToJson(
        _$BookingDetailsResponseModelImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

_$BookingHistoryDataImpl _$$BookingHistoryDataImplFromJson(
        Map<String, dynamic> json) =>
    _$BookingHistoryDataImpl(
      id: json['id'] as int?,
      customerId: json['customer_id'] as int?,
      trekId: json['trek_id'] as int?,
      vendorId: json['vendor_id'] as int?,
      vendorIdAlt: json['VendorId'] as int?,
      batchId: json['batch_id'] as int?,
      couponId: json['coupon_id'] as int?,
      totalTravelers: json['total_travelers'] as int?,
      totalAmount: _toString(json['total_amount']),
      platformFees: _toString(json['platform_fees']),
      gstAmount: _toString(json['gst_amount']),
      discountAmount: _toString(json['discount_amount']),
      finalAmount: _toString(json['final_amount']),
      paymentStatus: json['payment_status'] as String?,
      status: json['status'] as String?,
      bookingDate: json['booking_date'] as String?,
      specialRequests: json['special_requests'] as String?,
      bookingSource: json['booking_source'] as String?,
      primaryContactTravelerId: json['primary_contact_traveler_id'] as int?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      userId: json['user_id'] as int?,
      cityId: json['city_id'] as int?,
      sourceCityName: json['source_city_name'] as String?,
      cancellationPolicyType: json['cancellation_policy_type'],
      advanceAmount: _toString(json['advance_amount']),
      remainingAmount: _toString(json['remaining_amount']),
      financeSnapshot: json['finance_snapshot'] as String?,
      totalBasicCost: _toString(json['total_basic_cost']),
      vendorDiscount: _toString(json['vendor_discount']),
      couponDiscount: _toString(json['coupon_discount']),
      insuranceAmount: _toString(json['insurance_amount']),
      freeCancellationAmount: _toString(json['free_cancellation_amount']),
      paymentMethod: json['payment_method'] as String?,
      razorpayPaymentId: json['razorpay_payment_id'] as String?,
      razorpayOrderId: json['razorpay_order_id'] as String?,
      trek: json['trek'] == null
          ? null
          : Trek.fromJson(json['trek'] as Map<String, dynamic>),
      batch: json['batch'] == null
          ? null
          : Batch.fromJson(json['batch'] as Map<String, dynamic>),
      travelers: (json['travelers'] as List<dynamic>?)
          ?.map((e) => TravelersDataModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      bookingNumber: json['booking_number'] as String?,
      trekStatus: json['trek_status'] as String?,
      ratingGiven: json['rating_given'] as bool?,
      ratingValue: json['rating_value'],
    );

Map<String, dynamic> _$$BookingHistoryDataImplToJson(
        _$BookingHistoryDataImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'customer_id': instance.customerId,
      'trek_id': instance.trekId,
      'vendor_id': instance.vendorId,
      'VendorId': instance.vendorIdAlt,
      'batch_id': instance.batchId,
      'coupon_id': instance.couponId,
      'total_travelers': instance.totalTravelers,
      'total_amount': instance.totalAmount,
      'platform_fees': instance.platformFees,
      'gst_amount': instance.gstAmount,
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
      'city_id': instance.cityId,
      'source_city_name': instance.sourceCityName,
      'cancellation_policy_type': instance.cancellationPolicyType,
      'advance_amount': instance.advanceAmount,
      'remaining_amount': instance.remainingAmount,
      'finance_snapshot': instance.financeSnapshot,
      'total_basic_cost': instance.totalBasicCost,
      'vendor_discount': instance.vendorDiscount,
      'coupon_discount': instance.couponDiscount,
      'insurance_amount': instance.insuranceAmount,
      'free_cancellation_amount': instance.freeCancellationAmount,
      'payment_method': instance.paymentMethod,
      'razorpay_payment_id': instance.razorpayPaymentId,
      'razorpay_order_id': instance.razorpayOrderId,
      'trek': instance.trek,
      'batch': instance.batch,
      'travelers': instance.travelers,
      'booking_number': instance.bookingNumber,
      'trek_status': instance.trekStatus,
      'rating_given': instance.ratingGiven,
      'rating_value': instance.ratingValue,
    };

_$TrekImpl _$$TrekImplFromJson(Map<String, dynamic> json) => _$TrekImpl(
      id: json['id'] as int?,
      title: json['title'] as String?,
      duration: json['duration'] as String?,
      description: json['description'] as String?,
      basePrice: json['base_price'] as String?,
      status: json['status'] as String?,
      vendor: json['vendor'] == null
          ? null
          : Vendor.fromJson(json['vendor'] as Map<String, dynamic>),
      destination: json['destination'] == null
          ? null
          : Destination.fromJson(json['destination'] as Map<String, dynamic>),
      destinationId: json['destination_id'] as int?,
      cityIds:
          (json['city_ids'] as List<dynamic>?)?.map((e) => e as int).toList(),
      destinationName: json['destination_name'] as String?,
      cityNames: (json['city_names'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      captainName: json['captain_name'] as String?,
      captainPhone: json['captain_phone'] as String?,
      difficulty: json['difficulty'] as String?,
      durationDays: json['duration_days'] as int?,
      durationNights: json['duration_nights'] as int?,
      boardingPoint: json['boarding_point'] as String?,
      boardingTime: json['boarding_time'] as String?,
    );

Map<String, dynamic> _$$TrekImplToJson(_$TrekImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'duration': instance.duration,
      'description': instance.description,
      'base_price': instance.basePrice,
      'status': instance.status,
      'vendor': instance.vendor,
      'destination': instance.destination,
      'destination_id': instance.destinationId,
      'city_ids': instance.cityIds,
      'destination_name': instance.destinationName,
      'city_names': instance.cityNames,
      'captain_name': instance.captainName,
      'captain_phone': instance.captainPhone,
      'difficulty': instance.difficulty,
      'duration_days': instance.durationDays,
      'duration_nights': instance.durationNights,
      'boarding_point': instance.boardingPoint,
      'boarding_time': instance.boardingTime,
    };

_$VendorImpl _$$VendorImplFromJson(Map<String, dynamic> json) => _$VendorImpl(
      id: json['id'] as int?,
      businessName: json['business_name'] as String?,
      businessLogo: _parseImageUrl(json['business_logo'] as String?),
      city: json['city'] as String?,
      state: json['state'] as String?,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
    );

Map<String, dynamic> _$$VendorImplToJson(_$VendorImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'business_name': instance.businessName,
      'business_logo': instance.businessLogo,
      'city': instance.city,
      'state': instance.state,
      'address': instance.address,
      'phone': instance.phone,
      'email': instance.email,
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
      startTime: json['start_time'] as String?,
      availableSlots: json['available_slots'] as int?,
      bookedSlots: json['booked_slots'] as int?,
      capacity: json['capacity'] as int?,
    );

Map<String, dynamic> _$$BatchImplToJson(_$BatchImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tbr_id': instance.tbrId,
      'start_date': instance.startDate,
      'end_date': instance.endDate,
      'start_time': instance.startTime,
      'available_slots': instance.availableSlots,
      'booked_slots': instance.bookedSlots,
      'capacity': instance.capacity,
    };

_$TravelersDataModelImpl _$$TravelersDataModelImplFromJson(
        Map<String, dynamic> json) =>
    _$TravelersDataModelImpl(
      id: json['id'] as int?,
      bookingId: json['booking_id'] as int?,
      travelerId: json['traveler_id'] as int?,
      isPrimary: json['is_primary'] as bool?,
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
      'traveler': instance.traveler,
    };

_$PaginationImpl _$$PaginationImplFromJson(Map<String, dynamic> json) =>
    _$PaginationImpl(
      currentPage: json['currentPage'] as int?,
      totalPages: json['totalPages'] as int?,
      totalCount: json['totalCount'] as int?,
      limit: json['limit'] as int?,
      hasNextPage: json['hasNextPage'] as bool?,
    );

Map<String, dynamic> _$$PaginationImplToJson(_$PaginationImpl instance) =>
    <String, dynamic>{
      'currentPage': instance.currentPage,
      'totalPages': instance.totalPages,
      'totalCount': instance.totalCount,
      'limit': instance.limit,
      'hasNextPage': instance.hasNextPage,
    };
