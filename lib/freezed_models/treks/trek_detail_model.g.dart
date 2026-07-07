// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trek_detail_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TrekDetailModalImpl _$$TrekDetailModalImplFromJson(
        Map<String, dynamic> json) =>
    _$TrekDetailModalImpl(
      success: json['success'] as bool?,
      data: json['data'] == null
          ? null
          : TrekDetailData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$TrekDetailModalImplToJson(
        _$TrekDetailModalImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'data': instance.data,
    };

_$TrekDetailDataImpl _$$TrekDetailDataImplFromJson(Map<String, dynamic> json) =>
    _$TrekDetailDataImpl(
      cityIds:
          (json['city_ids'] as List<dynamic>?)?.map((e) => e as int).toList(),
      inclusions: (json['inclusions'] as List<dynamic>?)
          ?.map((e) => e is Map<String, dynamic>
              ? Inclusions.fromJson(e)
              : Inclusions(id: e is int ? e : int.tryParse(e.toString()), name: null, description: null))
          .toList(),
      exclusions: (json['exclusions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      activities: (json['activities'] as List<dynamic>?)
          ?.map((e) => e is Map<String, dynamic>
              ? Activities.fromJson(e)
              : Activities(id: e is int ? e : int.tryParse(e.toString()), name: null))
          .toList(),
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
      destinationData: json['destinationData'] == null
          ? null
          : Activities.fromJson(
              json['destinationData'] as Map<String, dynamic>),
      badge: json['badge'] == null
          ? null
          : Badge.fromJson(json['badge'] as Map<String, dynamic>),
      trekStages: (json['trek_stages'] as List<dynamic>?)
          ?.map((e) => TrekStages.fromJson(e as Map<String, dynamic>))
          .toList(),
      accommodations: (json['accommodations'] as List<dynamic>?)
          ?.map((e) => Accommodations.fromJson(e as Map<String, dynamic>))
          .toList(),
      itineraryItems: (json['itinerary_items'] as List<dynamic>?)
          ?.map((e) => ItineraryItems.fromJson(e as Map<String, dynamic>))
          .toList(),
      images: (json['images'] as List<dynamic>?)
          ?.map((e) => Images.fromJson(e as Map<String, dynamic>))
          .toList(),
      averageRating: (json['average_rating'] as num?)?.toDouble(),
      totalReviews: json['total_reviews'] as int?,
      ratingTotal: (json['rating_total'] as num?)?.toDouble(),
      reviewCommentsCount: json['review_comments_count'] as int?,
      latestReviews: (json['latest_reviews'] as List<dynamic>?)
          ?.map((e) => LatestReviews.fromJson(e as Map<String, dynamic>))
          .toList(),
      categoryRatings: json['category_ratings'] == null
          ? null
          : CategoryRatings.fromJson(
              json['category_ratings'] as Map<String, dynamic>),
      batchId: json['batch_id'] as int?,
      tbrId: json['tbr_id'] as String?,
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
      capacity: json['capacity'] as int?,
      bookedSlots: json['booked_slots'] as int?,
      availableSlots: json['available_slots'] as int?,
      cancellationPolicy: json['cancellation_policy'] == null
          ? null
          : CancellationPolicy.fromJson(
              json['cancellation_policy'] as Map<String, dynamic>),
      bookingType: json['booking_type'] as String?,
    );

Map<String, dynamic> _$$TrekDetailDataImplToJson(
        _$TrekDetailDataImpl instance) =>
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
      'badge_id': instance.badgeId,
      'has_been_edited': instance.hasBeenEdited,
      'safety_security_count': instance.safetySecurityCount,
      'organizer_manner_count': instance.organizerMannerCount,
      'trek_planning_count': instance.trekPlanningCount,
      'women_safety_count': instance.womenSafetyCount,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'vendor': instance.vendor,
      'destinationData': instance.destinationData,
      'badge': instance.badge,
      'trek_stages': instance.trekStages,
      'accommodations': instance.accommodations,
      'itinerary_items': instance.itineraryItems,
      'images': instance.images,
      'average_rating': instance.averageRating,
      'total_reviews': instance.totalReviews,
      'rating_total': instance.ratingTotal,
      'review_comments_count': instance.reviewCommentsCount,
      'latest_reviews': instance.latestReviews,
      'category_ratings': instance.categoryRatings,
      'batch_id': instance.batchId,
      'tbr_id': instance.tbrId,
      'start_date': instance.startDate,
      'end_date': instance.endDate,
      'capacity': instance.capacity,
      'booked_slots': instance.bookedSlots,
      'available_slots': instance.availableSlots,
      'cancellation_policy': instance.cancellationPolicy,
      'booking_type': instance.bookingType,
    };

_$InclusionsImpl _$$InclusionsImplFromJson(Map<String, dynamic> json) =>
    _$InclusionsImpl(
      id: json['id'] as int?,
      name: json['name'] as String?,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$$InclusionsImplToJson(_$InclusionsImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
    };

_$ActivitiesImpl _$$ActivitiesImplFromJson(Map<String, dynamic> json) =>
    _$ActivitiesImpl(
      id: json['id'] as int?,
      name: json['name'] as String?,
    );

Map<String, dynamic> _$$ActivitiesImplToJson(_$ActivitiesImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };

_$VendorImpl _$$VendorImplFromJson(Map<String, dynamic> json) => _$VendorImpl(
      id: json['id'] as int?,
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$VendorImplToJson(_$VendorImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user': instance.user,
    };

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
      id: json['id'] as int?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
    );

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
    };

_$BadgeImpl _$$BadgeImplFromJson(Map<String, dynamic> json) => _$BadgeImpl(
      id: json['id'] as int?,
      name: json['name'] as String?,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      category: json['category'] as String?,
    );

Map<String, dynamic> _$$BadgeImplToJson(_$BadgeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'icon': instance.icon,
      'color': instance.color,
      'category': instance.category,
    };

_$TrekStagesImpl _$$TrekStagesImplFromJson(Map<String, dynamic> json) =>
    _$TrekStagesImpl(
      id: json['id'] as int?,
      stageName: json['stage_name'] as String?,
      destination: json['destination'] as String?,
      meansOfTransport: json['means_of_transport'] as String?,
      dateTime: json['date_time'] as String?,
      isBoardingPoint: json['is_boarding_point'] as bool?,
      batchId: json['batch_id'] as int?,
      cityId: json['city_id'] as int?,
      city: json['city'] == null
          ? null
          : City.fromJson(json['city'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$TrekStagesImplToJson(_$TrekStagesImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'stage_name': instance.stageName,
      'destination': instance.destination,
      'means_of_transport': instance.meansOfTransport,
      'date_time': instance.dateTime,
      'is_boarding_point': instance.isBoardingPoint,
      'batch_id': instance.batchId,
      'city_id': instance.cityId,
      'city': instance.city,
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

_$AccommodationsImpl _$$AccommodationsImplFromJson(Map<String, dynamic> json) =>
    _$AccommodationsImpl(
      details: json['details'] == null
          ? null
          : Details.fromJson(json['details'] as Map<String, dynamic>),
      id: json['id'] as int?,
      trekId: json['trek_id'] as int?,
      batchId: json['batch_id'] as int?,
      type: json['type'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );

Map<String, dynamic> _$$AccommodationsImplToJson(
        _$AccommodationsImpl instance) =>
    <String, dynamic>{
      'details': instance.details,
      'id': instance.id,
      'trek_id': instance.trekId,
      'batch_id': instance.batchId,
      'type': instance.type,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };

_$DetailsImpl _$$DetailsImplFromJson(Map<String, dynamic> json) =>
    _$DetailsImpl(
      night: json['night'] as int?,
      location: json['location'] as String?,
    );

Map<String, dynamic> _$$DetailsImplToJson(_$DetailsImpl instance) =>
    <String, dynamic>{
      'night': instance.night,
      'location': instance.location,
    };

_$ItineraryItemsImpl _$$ItineraryItemsImplFromJson(Map<String, dynamic> json) =>
    _$ItineraryItemsImpl(
      activities: (json['activities'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      id: json['id'] as int?,
      trekId: json['trek_id'] as int?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );

Map<String, dynamic> _$$ItineraryItemsImplToJson(
        _$ItineraryItemsImpl instance) =>
    <String, dynamic>{
      'activities': instance.activities,
      'id': instance.id,
      'trek_id': instance.trekId,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };

_$ImagesImpl _$$ImagesImplFromJson(Map<String, dynamic> json) => _$ImagesImpl(
      id: json['id'] as int?,
      url: json['url'] as String?,
      isCover: json['is_cover'] as bool?,
    );

Map<String, dynamic> _$$ImagesImplToJson(_$ImagesImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'is_cover': instance.isCover,
    };

_$CategoryRatingsImpl _$$CategoryRatingsImplFromJson(
        Map<String, dynamic> json) =>
    _$CategoryRatingsImpl(
      safetySecurity: (json['safety_security'] as num?)?.toDouble(),
      organizerManner: (json['organizer_manner'] as num?)?.toDouble(),
      trekPlanning: (json['trek_planning'] as num?)?.toDouble(),
      womenSafety: (json['women_safety'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$CategoryRatingsImplToJson(
        _$CategoryRatingsImpl instance) =>
    <String, dynamic>{
      'safety_security': instance.safetySecurity,
      'organizer_manner': instance.organizerManner,
      'trek_planning': instance.trekPlanning,
      'women_safety': instance.womenSafety,
    };

_$BatchInfoImpl _$$BatchInfoImplFromJson(Map<String, dynamic> json) =>
    _$BatchInfoImpl(
      id: json['id'] as int?,
      tbrId: json['tbrId'] as String?,
      startDate: json['startDate'] as String?,
      startTime: json['startTime'] as String?,
      endDate: json['endDate'] as String?,
      bookedSlots: json['bookedSlots'] as int?,
      availableSlots: json['availableSlots'] as int?,
      capacity: json['capacity'] as int?,
    );

Map<String, dynamic> _$$BatchInfoImplToJson(_$BatchInfoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tbrId': instance.tbrId,
      'startDate': instance.startDate,
      'startTime': instance.startTime,
      'endDate': instance.endDate,
      'bookedSlots': instance.bookedSlots,
      'availableSlots': instance.availableSlots,
      'capacity': instance.capacity,
    };

_$CancellationPolicyImpl _$$CancellationPolicyImplFromJson(
        Map<String, dynamic> json) =>
    _$CancellationPolicyImpl(
      id: json['id'] as int?,
      type: json['type'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      rules: (json['rules'] as List<dynamic>?)
          ?.map((e) => Rules.fromJson(e as Map<String, dynamic>))
          .toList(),
      descriptionPoints: (json['descriptionPoints'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$$CancellationPolicyImplToJson(
        _$CancellationPolicyImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'title': instance.title,
      'description': instance.description,
      'rules': instance.rules,
      'descriptionPoints': instance.descriptionPoints,
    };

_$RulesImpl _$$RulesImplFromJson(Map<String, dynamic> json) => _$RulesImpl(
      rule: json['rule'] as String?,
      deduction: json['deduction'],
      hours: json['hours'],
      deductionType: json['deduction_type'] as String?,
    );

Map<String, dynamic> _$$RulesImplToJson(_$RulesImpl instance) =>
    <String, dynamic>{
      'rule': instance.rule,
      'deduction': instance.deduction,
      'hours': instance.hours,
      'deduction_type': instance.deductionType,
    };

_$LatestReviewsImpl _$$LatestReviewsImplFromJson(Map<String, dynamic> json) =>
    _$LatestReviewsImpl(
      customerId: json['customer_id'] as int?,
      customerName: json['customer_name'] as String?,
      ratingValue: (json['rating_value'] as num?)?.toDouble(),
      content: json['content'] as String?,
      createdAt: json['created_at'] as String?,
    );

Map<String, dynamic> _$$LatestReviewsImplToJson(_$LatestReviewsImpl instance) =>
    <String, dynamic>{
      'customer_id': instance.customerId,
      'customer_name': instance.customerName,
      'rating_value': instance.ratingValue,
      'content': instance.content,
      'created_at': instance.createdAt,
    };
