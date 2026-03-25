class BookingHistoryModel {
  bool? success;
  List<BookingHistoryData>? data;
  Pagination? pagination;
  int? count;

  BookingHistoryModel({this.success, this.data, this.pagination, this.count});

  BookingHistoryModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <BookingHistoryData>[];
      json['data'].forEach((v) {
        data!.add(new BookingHistoryData.fromJson(v));
      });
    }
    pagination = json['pagination'] != null
        ? new Pagination.fromJson(json['pagination'])
        : null;
    count = json['count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    if (this.pagination != null) {
      data['pagination'] = this.pagination!.toJson();
    }
    data['count'] = this.count;
    return data;
  }
}

class BookingHistoryData {
  int? id;
  int? customerId;
  int? trekId;
  int? vendorId;
  int? batchId;
  int? couponId;
  int? totalTravelers;
  String? totalAmount;
  String? discountAmount;
  String? finalAmount;
  String? paymentStatus;
  String? status;
  String? bookingDate;
  String? specialRequests;
  String? bookingSource;
  int? primaryContactTravelerId;
  String? createdAt;
  String? updatedAt;
  int? userId;
  Trek? trek;
  Batch? batch;
  City? city;
  List<Travelers>? travelers;
  String? trekStatus;
  bool? ratingGiven;
  double? ratingValue;
  String? trekStageDateTime;
  String? trekStageName;

  BookingHistoryData({
    this.id,
    this.customerId,
    this.trekId,
    this.vendorId,
    this.batchId,
    this.couponId,
    this.totalTravelers,
    this.totalAmount,
    this.discountAmount,
    this.finalAmount,
    this.paymentStatus,
    this.status,
    this.bookingDate,
    this.specialRequests,
    this.bookingSource,
    this.primaryContactTravelerId,
    this.createdAt,
    this.updatedAt,
    this.userId,
    this.trek,
    this.batch,
    this.city,
    this.travelers,
    this.trekStatus,
    this.ratingGiven,
    this.ratingValue,
    this.trekStageDateTime,
    this.trekStageName,
  });

  BookingHistoryData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    customerId = json['customer_id'];
    trekId = json['trek_id'];
    vendorId = json['vendor_id'];
    batchId = json['batch_id'];
    couponId = json['coupon_id'];
    totalTravelers = json['total_travelers'];
    totalAmount = json['total_amount'];
    discountAmount = json['discount_amount'];
    finalAmount = json['final_amount'];
    paymentStatus = json['payment_status'];
    status = json['status'];
    bookingDate = json['booking_date'];
    specialRequests = json['special_requests'];
    bookingSource = json['booking_source'];
    primaryContactTravelerId = json['primary_contact_traveler_id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    userId = json['user_id'];
    trek = json['trek'] != null ? new Trek.fromJson(json['trek']) : null;
    batch = json['batch'] != null ? new Batch.fromJson(json['batch']) : null;
    city = json['city'] != null ? new City.fromJson(json['city']) : null;
    if (json['travelers'] != null) {
      travelers = <Travelers>[];
      json['travelers'].forEach((v) {
        travelers!.add(new Travelers.fromJson(v));
      });
    }
    trekStatus = json['trek_status'];
    ratingGiven = json['rating_given'];
    ratingValue = double.tryParse(json['rating_value'].toString());
    trekStageDateTime = json['trek_stage_date_time'];
    trekStageName = json['trek_stage_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['customer_id'] = this.customerId;
    data['trek_id'] = this.trekId;
    data['vendor_id'] = this.vendorId;
    data['batch_id'] = this.batchId;
    data['coupon_id'] = this.couponId;
    data['total_travelers'] = this.totalTravelers;
    data['total_amount'] = this.totalAmount;
    data['discount_amount'] = this.discountAmount;
    data['final_amount'] = this.finalAmount;
    data['payment_status'] = this.paymentStatus;
    data['status'] = this.status;
    data['booking_date'] = this.bookingDate;
    data['special_requests'] = this.specialRequests;
    data['booking_source'] = this.bookingSource;
    data['primary_contact_traveler_id'] = this.primaryContactTravelerId;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['user_id'] = this.userId;
    if (this.trek != null) {
      data['trek'] = this.trek!.toJson();
    }
    if (this.batch != null) {
      data['batch'] = this.batch!.toJson();
    }
    if (this.city != null) {
      data['city'] = this.city!.toJson();
    }
    if (this.travelers != null) {
      data['travelers'] = this.travelers!.map((v) => v.toJson()).toList();
    }
    data['trek_status'] = this.trekStatus;
    data['rating_given'] = this.ratingGiven;
    data['rating_value'] = this.ratingValue;
    data['trek_stage_date_time'] = this.trekStageDateTime;
    data['trek_stage_name'] = this.trekStageName;
    return data;
  }
}

class Trek {
  List<int>? cityIds;
  List<String>? inclusions;
  List<String>? exclusions;
  List<int>? activities;
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
  int? cancellationPolicyId;
  int? badgeId;
  int? hasBeenEdited;
  int? safetySecurityCount;
  int? organizerMannerCount;
  int? trekPlanningCount;
  int? womenSafetyCount;
  String? createdAt;
  String? updatedAt;
  Vendor? vendor;
  int? rating;
  int? ratingCount;
  Destination? destination;
  String? captainName;
  String? captainPhone;

  Trek({
    this.cityIds,
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
    this.cancellationPolicyId,
    this.badgeId,
    this.hasBeenEdited,
    this.safetySecurityCount,
    this.organizerMannerCount,
    this.trekPlanningCount,
    this.womenSafetyCount,
    this.createdAt,
    this.updatedAt,
    this.vendor,
    this.rating,
    this.ratingCount,
    this.destination,
    this.captainName,
    this.captainPhone,
  });

  Trek.fromJson(Map<String, dynamic> json) {
    cityIds = json['city_ids'].cast<int>();
    inclusions = json['inclusions'].cast<String>();
    exclusions = json['exclusions'].cast<String>();
    activities = json['activities'].cast<int>();
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
    cancellationPolicyId = json['cancellation_policy_id'];
    badgeId = json['badge_id'];
    hasBeenEdited = json['has_been_edited'];
    safetySecurityCount = json['safety_security_count'];
    organizerMannerCount = json['organizer_manner_count'];
    trekPlanningCount = json['trek_planning_count'];
    womenSafetyCount = json['women_safety_count'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    vendor = json['vendor'] != null
        ? new Vendor.fromJson(json['vendor'])
        : null;
    rating = json['rating'];
    ratingCount = json['ratingCount'];
    destination = json['destination'] != null
        ? new Destination.fromJson(json['destination'])
        : null;
    captainName = json['captain_name'];
    captainPhone = json['captain_phone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['city_ids'] = this.cityIds;
    data['inclusions'] = this.inclusions;
    data['exclusions'] = this.exclusions;
    data['activities'] = this.activities;
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
    data['cancellation_policy_id'] = this.cancellationPolicyId;
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
    data['rating'] = this.rating;
    data['ratingCount'] = this.ratingCount;
    if (this.destination != null) {
      data['destination'] = this.destination!.toJson();
    }
    data['captain_name'] = this.captainName;
    data['captain_phone'] = this.captainPhone;
    return data;
  }
}

class Vendor {
  int? id;
  CompanyInfo? companyInfo;

  Vendor({this.id, this.companyInfo});

  Vendor.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    companyInfo = json['company_info'] != null
        ? new CompanyInfo.fromJson(json['company_info'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    if (this.companyInfo != null) {
      data['company_info'] = this.companyInfo!.toJson();
    }
    return data;
  }
}

class CompanyInfo {
  String? companyName;
  String? contactPerson;
  String? phone;
  String? email;
  String? address;
  String? gstNumber;
  String? panNumber;
  String? bankName;
  String? accountNumber;
  String? ifscCode;
  int? commissionRate;

  CompanyInfo({
    this.companyName,
    this.contactPerson,
    this.phone,
    this.email,
    this.address,
    this.gstNumber,
    this.panNumber,
    this.bankName,
    this.accountNumber,
    this.ifscCode,
    this.commissionRate,
  });

  CompanyInfo.fromJson(Map<String, dynamic> json) {
    companyName = json['company_name'];
    contactPerson = json['contact_person'];
    phone = json['phone'];
    email = json['email'];
    address = json['address'];
    gstNumber = json['gst_number'];
    panNumber = json['pan_number'];
    bankName = json['bank_name'];
    accountNumber = json['account_number'];
    ifscCode = json['ifsc_code'];
    commissionRate = json['commission_rate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['company_name'] = this.companyName;
    data['contact_person'] = this.contactPerson;
    data['phone'] = this.phone;
    data['email'] = this.email;
    data['address'] = this.address;
    data['gst_number'] = this.gstNumber;
    data['pan_number'] = this.panNumber;
    data['bank_name'] = this.bankName;
    data['account_number'] = this.accountNumber;
    data['ifsc_code'] = this.ifscCode;
    data['commission_rate'] = this.commissionRate;
    return data;
  }
}

class Destination {
  int? id;
  String? name;

  Destination({this.id, this.name});

  Destination.fromJson(Map<String, dynamic> json) {
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

class Batch {
  int? id;
  String? tbrId;
  String? startDate;
  String? endDate;
  int? capacity;
  int? bookedSlots;
  int? availableSlots;

  Batch({
    this.id,
    this.tbrId,
    this.startDate,
    this.endDate,
    this.capacity,
    this.bookedSlots,
    this.availableSlots,
  });

  Batch.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    tbrId = json['tbr_id'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    capacity = json['capacity'];
    bookedSlots = json['booked_slots'];
    availableSlots = json['available_slots'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['tbr_id'] = this.tbrId;
    data['start_date'] = this.startDate;
    data['end_date'] = this.endDate;
    data['capacity'] = this.capacity;
    data['booked_slots'] = this.bookedSlots;
    data['available_slots'] = this.availableSlots;
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

class Travelers {
  int? id;
  int? bookingId;
  int? travelerId;
  bool? isPrimary;
  String? specialRequirements;
  String? accommodationPreference;
  String? mealPreference;
  String? status;
  String? createdAt;
  String? updatedAt;
  Traveler? traveler;

  Travelers({
    this.id,
    this.bookingId,
    this.travelerId,
    this.isPrimary,
    this.specialRequirements,
    this.accommodationPreference,
    this.mealPreference,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.traveler,
  });

  Travelers.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    bookingId = json['booking_id'];
    travelerId = json['traveler_id'];
    isPrimary = json['is_primary'];
    specialRequirements = json['special_requirements'];
    accommodationPreference = json['accommodation_preference'];
    mealPreference = json['meal_preference'];
    status = json['status'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    traveler = json['traveler'] != null
        ? new Traveler.fromJson(json['traveler'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['booking_id'] = this.bookingId;
    data['traveler_id'] = this.travelerId;
    data['is_primary'] = this.isPrimary;
    data['special_requirements'] = this.specialRequirements;
    data['accommodation_preference'] = this.accommodationPreference;
    data['meal_preference'] = this.mealPreference;
    data['status'] = this.status;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    if (this.traveler != null) {
      data['traveler'] = this.traveler!.toJson();
    }
    return data;
  }
}

class Traveler {
  int? id;
  int? customerId;
  String? name;
  int? age;
  String? gender;
  bool? isActive;
  String? createdAt;
  String? updatedAt;

  Traveler({
    this.id,
    this.customerId,
    this.name,
    this.age,
    this.gender,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  Traveler.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    customerId = json['customer_id'];
    name = json['name'];
    age = json['age'];
    gender = json['gender'];
    isActive = json['is_active'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['customer_id'] = this.customerId;
    data['name'] = this.name;
    data['age'] = this.age;
    data['gender'] = this.gender;
    data['is_active'] = this.isActive;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}

class Pagination {
  int? currentPage;
  int? totalPages;
  int? totalCount;
  int? limit;
  bool? hasNextPage;
  bool? hasPrevPage;
  int? nextPage;
  int? prevPage;

  Pagination({
    this.currentPage,
    this.totalPages,
    this.totalCount,
    this.limit,
    this.hasNextPage,
    this.hasPrevPage,
    this.nextPage,
    this.prevPage,
  });

  Pagination.fromJson(Map<String, dynamic> json) {
    currentPage = json['currentPage'];
    totalPages = json['totalPages'];
    totalCount = json['totalCount'];
    limit = json['limit'];
    hasNextPage = json['hasNextPage'];
    hasPrevPage = json['hasPrevPage'];
    nextPage = json['nextPage'];
    prevPage = json['prevPage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['currentPage'] = this.currentPage;
    data['totalPages'] = this.totalPages;
    data['totalCount'] = this.totalCount;
    data['limit'] = this.limit;
    data['hasNextPage'] = this.hasNextPage;
    data['hasPrevPage'] = this.hasPrevPage;
    data['nextPage'] = this.nextPage;
    data['prevPage'] = this.prevPage;
    return data;
  }
}
