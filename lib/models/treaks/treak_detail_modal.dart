// class TrekDetailModal {
//   bool? success;
//   TrekDetailData? data;
//
//   TrekDetailModal({this.success, this.data});
//
//   TrekDetailModal.fromJson(Map<String, dynamic> json) {
//     success = json['success'];
//     data =
//         json['data'] != null ? new TrekDetailData.fromJson(json['data']) : null;
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['success'] = this.success;
//     if (this.data != null) {
//       data['data'] = this.data!.toJson();
//     }
//     return data;
//   }
// }
//
// class TrekDetailData {
//   List<int>? cityIds;
//   List<String>? inclusions;
//   List<String>? exclusions;
//   List<String>? activities;
//   int? id;
//   String? mtrId;
//   String? title;
//   String? description;
//   int? vendorId;
//   int? destinationId;
//   int? captainId;
//   String? duration;
//   int? durationDays;
//   int? durationNights;
//   String? basePrice;
//   int? maxParticipants;
//   String? trekkingRules;
//   String? emergencyProtocols;
//   String? organizerNotes;
//   String? status;
//   String? discountValue;
//   String? discountType;
//   bool? hasDiscount;
//   int? cancellationPolicyId;
//   int? hasBeenEdited;
//   int? badgeId;
//   String? createdAt;
//   String? updatedAt;
//   String? vendor;
//   Badge? badge;
//   List<TrekStages>? trekStages;
//   List<Accommodations>? accommodations;
//   List<ItineraryItems>? itineraryItems;
//   List<Images>? images;
//   double? rating;
//   int? ratingCount;
//   CategoryRatings? categoryRatings;
//   List<CancellationPolicies>? cancellationPolicies;
//   String? destination;
//   List<int>? cities;
//   Batch? batch;
//   List<Reviews>? reviews;
//   int? reviewCount;
//
//   TrekDetailData(
//       {this.cityIds,
//       this.inclusions,
//       this.exclusions,
//       this.activities,
//       this.id,
//       this.mtrId,
//       this.title,
//       this.description,
//       this.vendorId,
//       this.destinationId,
//       this.captainId,
//       this.duration,
//       this.durationDays,
//       this.durationNights,
//       this.basePrice,
//       this.maxParticipants,
//       this.trekkingRules,
//       this.emergencyProtocols,
//       this.organizerNotes,
//       this.status,
//       this.discountValue,
//       this.discountType,
//       this.hasDiscount,
//       this.cancellationPolicyId,
//         this.hasBeenEdited,
//       this.badgeId,
//       this.createdAt,
//       this.updatedAt,
//       this.vendor,
//       this.badge,
//       this.trekStages,
//       this.accommodations,
//       this.itineraryItems,
//       this.images,
//       this.rating,
//       this.ratingCount,
//       this.categoryRatings,
//       this.cancellationPolicies,
//       this.destination,
//       this.cities,
//       this.batch,
//       this.reviews,
//       this.reviewCount});
//
//   TrekDetailData.fromJson(Map<String, dynamic> json) {
//     cityIds = json['city_ids'].cast<int>();
//     inclusions = json['inclusions'].cast<String>();
//     exclusions = json['exclusions'].cast<String>();
//     activities = json['activities'].cast<String>();
//     id = json['id'];
//     mtrId = json['mtr_id'];
//     title = json['title'];
//     description = json['description'];
//     vendorId = json['vendor_id'];
//     destinationId = json['destination_id'];
//     captainId = json['captain_id'];
//     duration = json['duration'];
//     durationDays = json['duration_days'];
//     durationNights = json['duration_nights'];
//     basePrice = json['base_price'];
//     maxParticipants = json['max_participants'];
//     trekkingRules = json['trekking_rules'];
//     emergencyProtocols = json['emergency_protocols'];
//     organizerNotes = json['organizer_notes'];
//     status = json['status'];
//     discountValue = json['discount_value'];
//     discountType = json['discount_type'];
//     hasDiscount = json['has_discount'];
//     cancellationPolicyId = json['cancellation_policy_id'];
//     hasBeenEdited = json['has_been_edited'];
//     badgeId = json['badge_id'];
//     createdAt = json['createdAt'];
//     updatedAt = json['updatedAt'];
//     vendor = json['vendor'];
//     badge = json['badge'] != null ? new Badge.fromJson(json['badge']) : null;
//     if (json['trek_stages'] != null) {
//       trekStages = <TrekStages>[];
//       json['trek_stages'].forEach((v) {
//         trekStages!.add(new TrekStages.fromJson(v));
//       });
//     }
//     if (json['accommodations'] != null) {
//       accommodations = <Accommodations>[];
//       json['accommodations'].forEach((v) {
//         accommodations!.add(new Accommodations.fromJson(v));
//       });
//     }
//     if (json['itinerary_items'] != null) {
//       itineraryItems = <ItineraryItems>[];
//       json['itinerary_items'].forEach((v) {
//         itineraryItems!.add(new ItineraryItems.fromJson(v));
//       });
//     }
//     if (json['images'] != null) {
//       images = <Images>[];
//       json['images'].forEach((v) {
//         images!.add(new Images.fromJson(v));
//       });
//     }
//     rating = json['rating'].toDouble();
//     ratingCount = json['ratingCount'];
//     categoryRatings = json['categoryRatings'] != null
//         ? new CategoryRatings.fromJson(json['categoryRatings'])
//         : null;
//     if (json['cancellation_policies'] != null) {
//       cancellationPolicies = <CancellationPolicies>[];
//       json['cancellation_policies'].forEach((v) {
//         cancellationPolicies!.add(new CancellationPolicies.fromJson(v));
//       });
//     }
//     destination = json['destination'];
//     cities = json['cities'].cast<int>();
//     batch = json['batch'] != null ? new Batch.fromJson(json['batch']) : null;
//     if (json['reviews'] != null) {
//       reviews = <Reviews>[];
//       json['reviews'].forEach((v) {
//         reviews!.add(new Reviews.fromJson(v));
//       });
//     }
//     reviewCount = json['reviewCount'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['city_ids'] = this.cityIds;
//     data['inclusions'] = this.inclusions;
//     data['exclusions'] = this.exclusions;
//     data['activities'] = this.activities;
//     data['id'] = this.id;
//     data['mtr_id'] = this.mtrId;
//     data['title'] = this.title;
//     data['description'] = this.description;
//     data['vendor_id'] = this.vendorId;
//     data['destination_id'] = this.destinationId;
//     data['captain_id'] = this.captainId;
//     data['duration'] = this.duration;
//     data['duration_days'] = this.durationDays;
//     data['duration_nights'] = this.durationNights;
//     data['base_price'] = this.basePrice;
//     data['max_participants'] = this.maxParticipants;
//     data['trekking_rules'] = this.trekkingRules;
//     data['emergency_protocols'] = this.emergencyProtocols;
//     data['organizer_notes'] = this.organizerNotes;
//     data['status'] = this.status;
//     data['discount_value'] = this.discountValue;
//     data['discount_type'] = this.discountType;
//     data['has_discount'] = this.hasDiscount;
//     data['cancellation_policy_id'] = this.cancellationPolicyId;
//     data['has_been_edited'] = this.hasBeenEdited;
//     data['badge_id'] = this.badgeId;
//     data['createdAt'] = this.createdAt;
//     data['updatedAt'] = this.updatedAt;
//     data['vendor'] = this.vendor;
//     if (this.badge != null) {
//       data['badge'] = this.badge!.toJson();
//     }
//     if (this.trekStages != null) {
//       data['trek_stages'] = this.trekStages!.map((v) => v.toJson()).toList();
//     }
//     if (this.accommodations != null) {
//       data['accommodations'] =
//           this.accommodations!.map((v) => v.toJson()).toList();
//     }
//     if (this.itineraryItems != null) {
//       data['itinerary_items'] =
//           this.itineraryItems!.map((v) => v.toJson()).toList();
//     }
//     if (this.images != null) {
//       data['images'] = this.images!.map((v) => v.toJson()).toList();
//     }
//     data['rating'] = this.rating;
//     data['ratingCount'] = this.ratingCount;
//     if (this.categoryRatings != null) {
//       data['categoryRatings'] = this.categoryRatings!.toJson();
//     }
//     if (this.cancellationPolicies != null) {
//       data['cancellation_policies'] =
//           this.cancellationPolicies!.map((v) => v.toJson()).toList();
//     }
//     data['destination'] = this.destination;
//     data['cities'] = this.cities;
//     if (this.batch != null) {
//       data['batch'] = this.batch!.toJson();
//     }
//     if (this.reviews != null) {
//       data['reviews'] = this.reviews!.map((v) => v.toJson()).toList();
//     }
//     data['reviewCount'] = this.reviewCount;
//     return data;
//   }
// }
//
// class Badge {
//   String? name;
//   String? color;
//
//   Badge({this.name, this.color});
//
//   Badge.fromJson(Map<String, dynamic> json) {
//     name = json['name'];
//     color = json['color'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['name'] = this.name;
//     data['color'] = this.color;
//     return data;
//   }
// }
//
// class TrekStages {
//   int? id;
//   String? stageName;
//   String? destination;
//   String? meansOfTransport;
//   String? dateTime;
//   bool? isBoardingPoint;
//   int? batchId;
//   City? city;
//
//   TrekStages(
//       {this.id,
//       this.stageName,
//       this.destination,
//       this.meansOfTransport,
//       this.dateTime,
//       this.isBoardingPoint,
//         this.batchId,
//       this.city});
//
//   TrekStages.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     stageName = json['stage_name'];
//     destination = json['destination'];
//     meansOfTransport = json['means_of_transport'];
//     dateTime = json['date_time'];
//     isBoardingPoint = json['is_boarding_point'];
//     batchId = json['batch_id'];
//     city = json['city'] != null ? new City.fromJson(json['city']) : null;
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['stage_name'] = this.stageName;
//     data['destination'] = this.destination;
//     data['means_of_transport'] = this.meansOfTransport;
//     data['date_time'] = this.dateTime;
//     data['is_boarding_point'] = this.isBoardingPoint;
//     data['batch_id'] = this.batchId;
//     if (this.city != null) {
//       data['city'] = this.city!.toJson();
//     }
//     return data;
//   }
// }
//
// class City {
//   int? id;
//   String? name;
//
//   City({this.id, this.name});
//
//   City.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     name = json['name'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['name'] = this.name;
//     return data;
//   }
// }
//
// class Accommodations {
//   int? id;
//   String? type;
//   Details? details;
//   int? batchId;
//
//   Accommodations({this.id, this.type, this.details, this.batchId});
//
//   Accommodations.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     type = json['type'];
//     details =
//         json['details'] != null ? new Details.fromJson(json['details']) : null;
//     batchId = json['batch_id'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['type'] = this.type;
//     if (this.details != null) {
//       data['details'] = this.details!.toJson();
//     }
//     data['batch_id'] = this.batchId;
//     return data;
//   }
// }
//
// class Details {
//   int? night;
//   String? location;
//
//   Details({this.night, this.location});
//
//   Details.fromJson(Map<String, dynamic> json) {
//     night = json['night'];
//     location = json['location'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['night'] = this.night;
//     data['location'] = this.location;
//     return data;
//   }
// }
//
// class ItineraryItems {
//   int? id;
//   List<String>? activities;
//
//   ItineraryItems({this.id, this.activities});
//
//   ItineraryItems.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     activities = json['activities'].cast<String>();
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['activities'] = this.activities;
//     return data;
//   }
// }

class Images {
  int? id;
  String? url;
  bool? isCover;

  Images({this.id, this.url, this.isCover});

  Images.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    url = json['url'];
    isCover = json['is_cover'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['url'] = this.url;
    data['is_cover'] = this.isCover;
    return data;
  }
}

//
// class CategoryRatings {
//   double? safetyAndSecurity;
//   double? organizerManner;
//   double? trekPlanning;
//   double? womenSafety;
//
//   CategoryRatings(
//       {this.safetyAndSecurity,
//       this.organizerManner,
//       this.trekPlanning,
//       this.womenSafety});
//
//   CategoryRatings.fromJson(Map<String, dynamic> json) {
//     safetyAndSecurity = json['Safety and Security'].toDouble();
//     organizerManner = json['Organizer Manner'].toDouble();
//     trekPlanning = json['Trek Planning'].toDouble();
//     womenSafety = json['Women Safety'].toDouble();
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['Safety and Security'] = this.safetyAndSecurity;
//     data['Organizer Manner'] = this.organizerManner;
//     data['Trek Planning'] = this.trekPlanning;
//     data['Women Safety'] = this.womenSafety;
//     return data;
//   }
// }
//
// class CancellationPolicies {
//   List<Rules>? rules;
//   List<String>? descriptionPoints;
//   int? id;
//   String? title;
//   String? description;
//
//   CancellationPolicies(
//       {this.rules,
//       this.descriptionPoints,
//       this.id,
//       this.title,
//       this.description});
//
//   CancellationPolicies.fromJson(Map<String, dynamic> json) {
//     if (json['rules'] != null) {
//       rules = <Rules>[];
//       json['rules'].forEach((v) {
//         rules!.add(new Rules.fromJson(v));
//       });
//     }
//     descriptionPoints = json['descriptionPoints'].cast<String>();
//     id = json['id'];
//     title = json['title'];
//     description = json['description'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     if (this.rules != null) {
//       data['rules'] = this.rules!.map((v) => v.toJson()).toList();
//     }
//     data['descriptionPoints'] = this.descriptionPoints;
//     data['id'] = this.id;
//     data['title'] = this.title;
//     data['description'] = this.description;
//     return data;
//   }
// }
//
// class Rules {
//   String? rule;
//   int? deduction;
//   String? deductionType;
//
//   Rules({this.rule, this.deduction, this.deductionType});
//
//   Rules.fromJson(Map<String, dynamic> json) {
//     rule = json['rule'];
//     deduction = json['deduction'];
//     deductionType = json['deduction_type'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['rule'] = this.rule;
//     data['deduction'] = this.deduction;
//     data['deduction_type'] = this.deductionType;
//     return data;
//   }
// }
//
// class Batch {
//   int? id;
//   String? startDate;
//   String? endDate;
//   int? capacity;
//   int? availableSlots;
//
//   Batch(
//       {this.id,
//       this.startDate,
//       this.endDate,
//       this.capacity,
//       this.availableSlots});
//
//   Batch.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     startDate = json['start_date'];
//     endDate = json['end_date'];
//     capacity = json['capacity'];
//     availableSlots = json['available_slots'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['start_date'] = this.startDate;
//     data['end_date'] = this.endDate;
//     data['capacity'] = this.capacity;
//     data['available_slots'] = this.availableSlots;
//     return data;
//   }
// }
//
// class Reviews {
//   int? id;
//   int? trekId;
//   int? customerId;
//   int? bookingId;
//   String? title;
//   String? content;
//   bool? isVerified;
//   bool? isApproved;
//   int? isHelpful;
//   String? status;
//   String? createdAt;
//   String? updatedAt;
//   City? customer;
//
//   Reviews(
//       {this.id,
//       this.trekId,
//       this.customerId,
//       this.bookingId,
//       this.title,
//       this.content,
//       this.isVerified,
//       this.isApproved,
//       this.isHelpful,
//       this.status,
//       this.createdAt,
//       this.updatedAt,
//       this.customer});
//
//   Reviews.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     trekId = json['trek_id'];
//     customerId = json['customer_id'];
//     bookingId = json['booking_id'];
//     title = json['title'];
//     content = json['content'];
//     isVerified = json['is_verified'];
//     isApproved = json['is_approved'];
//     isHelpful = json['is_helpful'];
//     status = json['status'];
//     createdAt = json['createdAt'];
//     updatedAt = json['updatedAt'];
//     customer =
//         json['customer'] != null ? new City.fromJson(json['customer']) : null;
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['trek_id'] = this.trekId;
//     data['customer_id'] = this.customerId;
//     data['booking_id'] = this.bookingId;
//     data['title'] = this.title;
//     data['content'] = this.content;
//     data['is_verified'] = this.isVerified;
//     data['is_approved'] = this.isApproved;
//     data['is_helpful'] = this.isHelpful;
//     data['status'] = this.status;
//     data['createdAt'] = this.createdAt;
//     data['updatedAt'] = this.updatedAt;
//     if (this.customer != null) {
//       data['customer'] = this.customer!.toJson();
//     }
//     return data;
//   }
// }

class TrekDetailModal {
  bool? success;
  TrekDetailData? data;

  TrekDetailModal({this.success, this.data});

  TrekDetailModal.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data =
        json['data'] != null ? new TrekDetailData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class TrekDetailData {
  List<int>? cityIds;
  List<Inclusions>? inclusions;
  List<String>? exclusions;
  List<Activities>? activities;
  int? id;
  String? mtrId;
  String? title;
  String? description;
  int? vendorId;
  int? destinationId;
  int? captainId;
  String? duration;
  int? durationDays;
  int? durationNights;
  String? basePrice;
  int? maxParticipants;
  String? trekkingRules;
  String? emergencyProtocols;
  String? organizerNotes;
  String? status;
  String? discountValue;
  String? discountType;
  bool? hasDiscount;
  int? badgeId;
  int? hasBeenEdited;
  int? safetySecurityCount;
  int? organizerMannerCount;
  int? trekPlanningCount;
  int? womenSafetyCount;
  String? createdAt;
  String? updatedAt;
  Vendor? vendor;
  Activities? destinationData;
  Badge? badge;
  List<TrekStages>? trekStages;
  List<Accommodations>? accommodations;
  List<ItineraryItems>? itineraryItems;
  List<Images>? images;
  double? averageRating;
  int? totalReviews;
  double? ratingTotal;
  int? reviewCommentsCount;
  List<LatestReviews>? latestReviews;
  CategoryRatings? categoryRatings;
  BatchInfo? batchInfo;
  CancellationPolicy? cancellationPolicy;

  TrekDetailData(
      {this.cityIds,
      this.inclusions,
      this.exclusions,
      this.activities,
      this.id,
      this.mtrId,
      this.title,
      this.description,
      this.vendorId,
      this.destinationId,
      this.captainId,
      this.duration,
      this.durationDays,
      this.durationNights,
      this.basePrice,
      this.maxParticipants,
      this.trekkingRules,
      this.emergencyProtocols,
      this.organizerNotes,
      this.status,
      this.discountValue,
      this.discountType,
      this.hasDiscount,
      this.badgeId,
      this.hasBeenEdited,
      this.safetySecurityCount,
      this.organizerMannerCount,
      this.trekPlanningCount,
      this.womenSafetyCount,
      this.createdAt,
      this.updatedAt,
      this.vendor,
      this.destinationData,
      this.badge,
      this.trekStages,
      this.accommodations,
      this.itineraryItems,
      this.images,
      this.averageRating,
      this.totalReviews,
      this.ratingTotal,
      this.reviewCommentsCount,
      this.latestReviews,
      this.categoryRatings,
      this.batchInfo,
      this.cancellationPolicy});

  TrekDetailData.fromJson(Map<String, dynamic> json) {
    cityIds = json['city_ids'].cast<int>();
    if (json['inclusions'] != null) {
      inclusions = <Inclusions>[];
      json['inclusions'].forEach((v) {
        inclusions!.add(new Inclusions.fromJson(v));
      });
    }
    exclusions = json['exclusions'].cast<String>();
    if (json['activities'] != null) {
      activities = <Activities>[];
      json['activities'].forEach((v) {
        activities!.add(new Activities.fromJson(v));
      });
    }
    id = json['id'];
    mtrId = json['mtr_id'];
    title = json['title'];
    description = json['description'];
    vendorId = json['vendor_id'];
    destinationId = json['destination_id'];
    captainId = json['captain_id'];
    duration = json['duration'];
    durationDays = json['duration_days'];
    durationNights = json['duration_nights'];
    basePrice = json['base_price'];
    maxParticipants = json['max_participants'];
    trekkingRules = json['trekking_rules'];
    emergencyProtocols = json['emergency_protocols'];
    organizerNotes = json['organizer_notes'];
    status = json['status'];
    discountValue = json['discount_value'];
    discountType = json['discount_type'];
    hasDiscount = json['has_discount'];
    badgeId = json['badge_id'];
    hasBeenEdited = json['has_been_edited'];
    safetySecurityCount = json['safety_security_count'];
    organizerMannerCount = json['organizer_manner_count'];
    trekPlanningCount = json['trek_planning_count'];
    womenSafetyCount = json['women_safety_count'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    vendor =
        json['vendor'] != null ? new Vendor.fromJson(json['vendor']) : null;
    destinationData = json['destinationData'] != null
        ? new Activities.fromJson(json['destinationData'])
        : null;
    badge = json['badge'] != null ? new Badge.fromJson(json['badge']) : null;
    if (json['trek_stages'] != null) {
      trekStages = <TrekStages>[];
      json['trek_stages'].forEach((v) {
        trekStages!.add(new TrekStages.fromJson(v));
      });
    }
    if (json['accommodations'] != null) {
      accommodations = <Accommodations>[];
      json['accommodations'].forEach((v) {
        accommodations!.add(new Accommodations.fromJson(v));
      });
    }
    if (json['itinerary_items'] != null) {
      itineraryItems = <ItineraryItems>[];
      json['itinerary_items'].forEach((v) {
        itineraryItems!.add(new ItineraryItems.fromJson(v));
      });
    }
    if (json['images'] != null) {
      images = <Images>[];
      json['images'].forEach((v) {
        images!.add(new Images.fromJson(v));
      });
    }
    averageRating = double.tryParse(json['average_rating'].toString());
    totalReviews = json['total_reviews'];
    ratingTotal = double.tryParse(json['rating_total'].toString());
    reviewCommentsCount = json['review_comments_count'];
    if (json['latest_reviews'] != null) {
      latestReviews = <LatestReviews>[];
      json['latest_reviews'].forEach((v) {
        latestReviews!.add(new LatestReviews.fromJson(v));
      });
    }
    categoryRatings = json['category_ratings'] != null
        ? new CategoryRatings.fromJson(json['category_ratings'])
        : null;
    batchInfo = json['batch_info'] != null
        ? new BatchInfo.fromJson(json['batch_info'])
        : null;
    cancellationPolicy = json['cancellation_policy'] != null
        ? new CancellationPolicy.fromJson(json['cancellation_policy'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['city_ids'] = this.cityIds;
    if (this.inclusions != null) {
      data['inclusions'] = this.inclusions!.map((v) => v.toJson()).toList();
    }
    data['exclusions'] = this.exclusions;
    if (this.activities != null) {
      data['activities'] = this.activities!.map((v) => v.toJson()).toList();
    }
    data['id'] = this.id;
    data['mtr_id'] = this.mtrId;
    data['title'] = this.title;
    data['description'] = this.description;
    data['vendor_id'] = this.vendorId;
    data['destination_id'] = this.destinationId;
    data['captain_id'] = this.captainId;
    data['duration'] = this.duration;
    data['duration_days'] = this.durationDays;
    data['duration_nights'] = this.durationNights;
    data['base_price'] = this.basePrice;
    data['max_participants'] = this.maxParticipants;
    data['trekking_rules'] = this.trekkingRules;
    data['emergency_protocols'] = this.emergencyProtocols;
    data['organizer_notes'] = this.organizerNotes;
    data['status'] = this.status;
    data['discount_value'] = this.discountValue;
    data['discount_type'] = this.discountType;
    data['has_discount'] = this.hasDiscount;
    data['badge_id'] = this.badgeId;
    data['has_been_edited'] = this.hasBeenEdited;
    data['safety_security_count'] = this.safetySecurityCount;
    data['organizer_manner_count'] = this.organizerMannerCount;
    data['trek_planning_count'] = this.trekPlanningCount;
    data['women_safety_count'] = this.womenSafetyCount;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    if (this.vendor != null) {
      data['vendor'] = this.vendor!.toJson();
    }
    if (this.destinationData != null) {
      data['destinationData'] = this.destinationData!.toJson();
    }
    if (this.badge != null) {
      data['badge'] = this.badge!.toJson();
    }
    if (this.trekStages != null) {
      data['trek_stages'] = this.trekStages!.map((v) => v.toJson()).toList();
    }
    if (this.accommodations != null) {
      data['accommodations'] =
          this.accommodations!.map((v) => v.toJson()).toList();
    }
    if (this.itineraryItems != null) {
      data['itinerary_items'] =
          this.itineraryItems!.map((v) => v.toJson()).toList();
    }
    if (this.images != null) {
      data['images'] = this.images!.map((v) => v.toJson()).toList();
    }
    data['average_rating'] = this.averageRating;
    data['total_reviews'] = this.totalReviews;
    data['rating_total'] = this.ratingTotal;
    data['review_comments_count'] = this.reviewCommentsCount;
    if (this.latestReviews != null) {
      data['latest_reviews'] =
          this.latestReviews!.map((v) => v.toJson()).toList();
    }
    if (this.categoryRatings != null) {
      data['category_ratings'] = this.categoryRatings!.toJson();
    }
    if (this.batchInfo != null) {
      data['batch_info'] = this.batchInfo!.toJson();
    }
    if (this.cancellationPolicy != null) {
      data['cancellation_policy'] = this.cancellationPolicy!.toJson();
    }
    return data;
  }
}

class Inclusions {
  int? id;
  String? name;
  String? description;

  Inclusions({this.id, this.name, this.description});

  Inclusions.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['description'] = this.description;
    return data;
  }
}

class Activities {
  int? id;
  String? name;

  Activities({this.id, this.name});

  Activities.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    return data;
  }
}

class Vendor {
  int? id;
  User? user;

  Vendor({this.id, this.user});

  Vendor.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    return data;
  }
}

class User {
  int? id;
  String? name;
  String? email;
  String? phone;

  User({this.id, this.name, this.email, this.phone});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    data['phone'] = this.phone;
    return data;
  }
}

class Badge {
  int? id;
  String? name;
  String? icon;
  String? color;
  String? category;

  Badge({this.id, this.name, this.icon, this.color, this.category});

  Badge.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    icon = json['icon'];
    color = json['color'];
    category = json['category'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['icon'] = this.icon;
    data['color'] = this.color;
    data['category'] = this.category;
    return data;
  }
}

class TrekStages {
  int? id;
  String? stageName;
  String? destination;
  String? meansOfTransport;
  String? dateTime;
  bool? isBoardingPoint;
  int? batchId;
  int? cityId;
  City? city;

  TrekStages(
      {this.id,
      this.stageName,
      this.destination,
      this.meansOfTransport,
      this.dateTime,
      this.isBoardingPoint,
      this.batchId,
      this.cityId,
      this.city});

  TrekStages.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    stageName = json['stage_name'];
    destination = json['destination'];
    meansOfTransport = json['means_of_transport'];
    dateTime = json['date_time'];
    isBoardingPoint = json['is_boarding_point'];
    batchId = json['batch_id'];
    cityId = json['city_id'];
    city = json['city'] != null ? new City.fromJson(json['city']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['stage_name'] = this.stageName;
    data['destination'] = this.destination;
    data['means_of_transport'] = this.meansOfTransport;
    data['date_time'] = this.dateTime;
    data['is_boarding_point'] = this.isBoardingPoint;
    data['batch_id'] = this.batchId;
    data['city_id'] = this.cityId;
    if (this.city != null) {
      data['city'] = this.city!.toJson();
    }
    return data;
  }
}

class City {
  int? id;
  String? cityName;

  City({this.id, this.cityName});

  City.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    cityName = json['cityName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['cityName'] = this.cityName;
    return data;
  }
}

class Accommodations {
  Details? details;
  int? id;
  int? trekId;
  int? batchId;
  String? type;
  String? createdAt;
  String? updatedAt;

  Accommodations(
      {this.details,
      this.id,
      this.trekId,
      this.batchId,
      this.type,
      this.createdAt,
      this.updatedAt});

  Accommodations.fromJson(Map<String, dynamic> json) {
    details =
        json['details'] != null ? new Details.fromJson(json['details']) : null;
    id = json['id'];
    trekId = json['trek_id'];
    batchId = json['batch_id'];
    type = json['type'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.details != null) {
      data['details'] = this.details!.toJson();
    }
    data['id'] = this.id;
    data['trek_id'] = this.trekId;
    data['batch_id'] = this.batchId;
    data['type'] = this.type;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}

class Details {
  int? night;
  String? location;

  Details({this.night, this.location});

  Details.fromJson(Map<String, dynamic> json) {
    night = json['night'];
    location = json['location'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['night'] = this.night;
    data['location'] = this.location;
    return data;
  }
}

class ItineraryItems {
  List<String>? activities;
  int? id;
  int? trekId;
  String? createdAt;
  String? updatedAt;

  ItineraryItems(
      {this.activities, this.id, this.trekId, this.createdAt, this.updatedAt});

  ItineraryItems.fromJson(Map<String, dynamic> json) {
    activities = json['activities'].cast<String>();
    id = json['id'];
    trekId = json['trek_id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['activities'] = this.activities;
    data['id'] = this.id;
    data['trek_id'] = this.trekId;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}

class CategoryRatings {
  double? safetySecurity;
  double? organizerManner;
  double? trekPlanning;
  double? womenSafety;

  CategoryRatings(
      {this.safetySecurity,
      this.organizerManner,
      this.trekPlanning,
      this.womenSafety});

  CategoryRatings.fromJson(Map<String, dynamic> json) {
    safetySecurity = double.tryParse(json['safety_security'].toString());
    organizerManner = double.tryParse(json['organizer_manner'].toString());
    trekPlanning = double.tryParse(json['trek_planning'].toString());
    womenSafety = double.tryParse(json['women_safety'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['safety_security'] = this.safetySecurity;
    data['organizer_manner'] = this.organizerManner;
    data['trek_planning'] = this.trekPlanning;
    data['women_safety'] = this.womenSafety;
    return data;
  }
}

class BatchInfo {
  int? id;
  String? tbrId;
  String? startDate;
  String? endDate;
  int? bookedSlots;
  int? availableSlots;
  int? capacity;

  BatchInfo(
      {this.id,
      this.tbrId,
      this.startDate,
      this.endDate,
      this.bookedSlots,
      this.availableSlots,
      this.capacity});

  BatchInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    tbrId = json['tbr_id'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    bookedSlots = json['booked_slots'];
    availableSlots = json['available_slots'];
    capacity = json['capacity'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['tbr_id'] = this.tbrId;
    data['start_date'] = this.startDate;
    data['end_date'] = this.endDate;
    data['booked_slots'] = this.bookedSlots;
    data['available_slots'] = this.availableSlots;
    data['capacity'] = this.capacity;
    return data;
  }
}

class CancellationPolicy {
  int? id;
  String? title;
  String? description;
  List<Rules>? rules;
  List<String>? descriptionPoints;

  CancellationPolicy(
      {this.id,
      this.title,
      this.description,
      this.rules,
      this.descriptionPoints});

  CancellationPolicy.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    if (json['rules'] != null) {
      rules = <Rules>[];
      json['rules'].forEach((v) {
        rules!.add(new Rules.fromJson(v));
      });
    }
    descriptionPoints = json['descriptionPoints'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['description'] = this.description;
    if (this.rules != null) {
      data['rules'] = this.rules!.map((v) => v.toJson()).toList();
    }
    data['descriptionPoints'] = this.descriptionPoints;
    return data;
  }
}

class Rules {
  String? rule;
  int? deduction;
  String? deductionType;

  Rules({this.rule, this.deduction, this.deductionType});

  Rules.fromJson(Map<String, dynamic> json) {
    rule = json['rule'];
    deduction = json['deduction'];
    deductionType = json['deduction_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['rule'] = this.rule;
    data['deduction'] = this.deduction;
    data['deduction_type'] = this.deductionType;
    return data;
  }
}

class LatestReviews {
  int? customerId;
  String? customerName;
  double? ratingValue;
  String? content;
  String? createdAt;

  LatestReviews(
      {this.customerId,
      this.customerName,
      this.ratingValue,
      this.content,
      this.createdAt});

  LatestReviews.fromJson(Map<String, dynamic> json) {
    customerId = json['customer_id'];
    customerName = json['customer_name'];
    ratingValue = double.tryParse(json['rating_value'].toString());
    content = json['content'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['customer_id'] = this.customerId;
    data['customer_name'] = this.customerName;
    data['rating_value'] = this.ratingValue;
    data['content'] = this.content;
    data['created_at'] = this.createdAt;
    return data;
  }
}
