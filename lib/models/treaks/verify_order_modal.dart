class VerifyOrderModal {
  bool? success;
  String? message;
  Data? data;
  Payment? payment;
  PaymentDetails? paymentDetails;

  VerifyOrderModal({
    this.success,
    this.message,
    this.data,
    this.payment,
    this.paymentDetails,
  });

  VerifyOrderModal.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    payment = json['payment'] != null
        ? new Payment.fromJson(json['payment'])
        : null;
    paymentDetails = json['paymentDetails'] != null
        ? new PaymentDetails.fromJson(json['paymentDetails'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    if (this.payment != null) {
      data['payment'] = this.payment!.toJson();
    }
    if (this.paymentDetails != null) {
      data['paymentDetails'] = this.paymentDetails!.toJson();
    }
    return data;
  }
}

class Data {
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
  int? cityId;
  String? createdAt;
  String? updatedAt;
  int? userId;
  Trek? trek;
  Vendor? vendor;
  Batch? batch;
  City? city;
  List<VerifyTrekTraveler>? travelers;
  List<Payments>? payments;

  Data({
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
    this.cityId,
    this.createdAt,
    this.updatedAt,
    this.userId,
    this.trek,
    this.vendor,
    this.batch,
    this.city,
    this.travelers,
    this.payments,
  });

  Data.fromJson(Map<String, dynamic> json) {
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
    cityId = json['city_id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    userId = json['user_id'];
    trek = json['trek'] != null ? new Trek.fromJson(json['trek']) : null;
    vendor = json['vendor'] != null
        ? new Vendor.fromJson(json['vendor'])
        : null;
    batch = json['batch'] != null ? new Batch.fromJson(json['batch']) : null;
    city = json['city'] != null ? new City.fromJson(json['city']) : null;
    if (json['travelers'] != null) {
      travelers = <VerifyTrekTraveler>[];
      json['travelers'].forEach((v) {
        travelers!.add(new VerifyTrekTraveler.fromJson(v));
      });
    }
    if (json['payments'] != null) {
      payments = <Payments>[];
      json['payments'].forEach((v) {
        payments!.add(new Payments.fromJson(v));
      });
    }
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
    data['city_id'] = this.cityId;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['user_id'] = this.userId;
    if (this.trek != null) {
      data['trek'] = this.trek!.toJson();
    }
    if (this.vendor != null) {
      data['vendor'] = this.vendor!.toJson();
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
    if (this.payments != null) {
      data['payments'] = this.payments!.map((v) => v.toJson()).toList();
    }
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
  DestinationData? destinationData;

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
    this.destinationData,
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
    destinationData = json['destinationData'] != null
        ? new DestinationData.fromJson(json['destinationData'])
        : null;
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
    if (this.destinationData != null) {
      data['destinationData'] = this.destinationData!.toJson();
    }
    return data;
  }
}

class DestinationData {
  int? id;
  String? name;
  String? state;
  bool? isPopular;
  String? status;
  String? createdAt;
  String? updatedAt;

  DestinationData({
    this.id,
    this.name,
    this.state,
    this.isPopular,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  DestinationData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    state = json['state'];
    isPopular = json['isPopular'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['state'] = this.state;
    data['isPopular'] = this.isPopular;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class Vendor {
  int? id;
  int? userId;
  CompanyInfo? companyInfo;
  String? status;
  String? address;
  String? businessName;
  String? businessType;
  String? businessEntity;
  String? businessAddress;
  String? gstin;
  String? accountHolderName;
  String? bankName;
  String? ifscCode;
  String? accountNumber;
  String? panCardPath;
  String? idProofPath;
  String? cancelledChequePath;
  String? gstinCertificatePath;
  String? msmeCertificatePath;
  String? shopEstablishmentPath;
  bool? panCardVerified;
  bool? idProofVerified;
  bool? cancelledChequeVerified;
  bool? gstinCertificateVerified;
  bool? msmeCertificateVerified;
  bool? shopEstablishmentVerified;
  String? kycStatus;
  int? kycStep;
  String? createdAt;
  String? updatedAt;

  Vendor({
    this.id,
    this.userId,
    this.companyInfo,
    this.status,
    this.address,
    this.businessName,
    this.businessType,
    this.businessEntity,
    this.businessAddress,
    this.gstin,
    this.accountHolderName,
    this.bankName,
    this.ifscCode,
    this.accountNumber,
    this.panCardPath,
    this.idProofPath,
    this.cancelledChequePath,
    this.gstinCertificatePath,
    this.msmeCertificatePath,
    this.shopEstablishmentPath,
    this.panCardVerified,
    this.idProofVerified,
    this.cancelledChequeVerified,
    this.gstinCertificateVerified,
    this.msmeCertificateVerified,
    this.shopEstablishmentVerified,
    this.kycStatus,
    this.kycStep,
    this.createdAt,
    this.updatedAt,
  });

  Vendor.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    companyInfo = json['company_info'] != null
        ? new CompanyInfo.fromJson(json['company_info'])
        : null;
    status = json['status'];
    address = json['address'];
    businessName = json['business_name'];
    businessType = json['business_type'];
    businessEntity = json['business_entity'];
    businessAddress = json['business_address'];
    gstin = json['gstin'];
    accountHolderName = json['account_holder_name'];
    bankName = json['bank_name'];
    ifscCode = json['ifsc_code'];
    accountNumber = json['account_number'];
    panCardPath = json['pan_card_path'];
    idProofPath = json['id_proof_path'];
    cancelledChequePath = json['cancelled_cheque_path'];
    gstinCertificatePath = json['gstin_certificate_path'];
    msmeCertificatePath = json['msme_certificate_path'];
    shopEstablishmentPath = json['shop_establishment_path'];
    panCardVerified = json['pan_card_verified'];
    idProofVerified = json['id_proof_verified'];
    cancelledChequeVerified = json['cancelled_cheque_verified'];
    gstinCertificateVerified = json['gstin_certificate_verified'];
    msmeCertificateVerified = json['msme_certificate_verified'];
    shopEstablishmentVerified = json['shop_establishment_verified'];
    kycStatus = json['kyc_status'];
    kycStep = json['kyc_step'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    if (this.companyInfo != null) {
      data['company_info'] = this.companyInfo!.toJson();
    }
    data['status'] = this.status;
    data['address'] = this.address;
    data['business_name'] = this.businessName;
    data['business_type'] = this.businessType;
    data['business_entity'] = this.businessEntity;
    data['business_address'] = this.businessAddress;
    data['gstin'] = this.gstin;
    data['account_holder_name'] = this.accountHolderName;
    data['bank_name'] = this.bankName;
    data['ifsc_code'] = this.ifscCode;
    data['account_number'] = this.accountNumber;
    data['pan_card_path'] = this.panCardPath;
    data['id_proof_path'] = this.idProofPath;
    data['cancelled_cheque_path'] = this.cancelledChequePath;
    data['gstin_certificate_path'] = this.gstinCertificatePath;
    data['msme_certificate_path'] = this.msmeCertificatePath;
    data['shop_establishment_path'] = this.shopEstablishmentPath;
    data['pan_card_verified'] = this.panCardVerified;
    data['id_proof_verified'] = this.idProofVerified;
    data['cancelled_cheque_verified'] = this.cancelledChequeVerified;
    data['gstin_certificate_verified'] = this.gstinCertificateVerified;
    data['msme_certificate_verified'] = this.msmeCertificateVerified;
    data['shop_establishment_verified'] = this.shopEstablishmentVerified;
    data['kyc_status'] = this.kycStatus;
    data['kyc_step'] = this.kycStep;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
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

class Batch {
  int? id;
  String? tbrId;
  int? trekId;
  String? startDate;
  String? endDate;
  int? capacity;
  int? bookedSlots;
  int? availableSlots;
  int? captainId;
  String? createdAt;
  String? updatedAt;

  Batch({
    this.id,
    this.tbrId,
    this.trekId,
    this.startDate,
    this.endDate,
    this.capacity,
    this.bookedSlots,
    this.availableSlots,
    this.captainId,
    this.createdAt,
    this.updatedAt,
  });

  Batch.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    tbrId = json['tbr_id'];
    trekId = json['trek_id'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    capacity = json['capacity'];
    bookedSlots = json['booked_slots'];
    availableSlots = json['available_slots'];
    captainId = json['captain_id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['tbr_id'] = this.tbrId;
    data['trek_id'] = this.trekId;
    data['start_date'] = this.startDate;
    data['end_date'] = this.endDate;
    data['capacity'] = this.capacity;
    data['booked_slots'] = this.bookedSlots;
    data['available_slots'] = this.availableSlots;
    data['captain_id'] = this.captainId;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}

class City {
  int? id;
  String? cityName;
  bool? isPopular;
  int? stateId;
  String? createdAt;
  String? updatedAt;

  City({
    this.id,
    this.cityName,
    this.isPopular,
    this.stateId,
    this.createdAt,
    this.updatedAt,
  });

  City.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    cityName = json['cityName'];
    isPopular = json['isPopular'];
    stateId = json['stateId'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['cityName'] = this.cityName;
    data['isPopular'] = this.isPopular;
    data['stateId'] = this.stateId;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class VerifyTrekTraveler {
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

  VerifyTrekTraveler({
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

  VerifyTrekTraveler.fromJson(Map<String, dynamic> json) {
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

class Payments {
  int? id;
  int? bookingId;
  String? amount;
  String? paymentMethod;
  String? transactionId;
  String? status;
  String? createdAt;
  String? updatedAt;

  Payments({
    this.id,
    this.bookingId,
    this.amount,
    this.paymentMethod,
    this.transactionId,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  Payments.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    bookingId = json['booking_id'];
    amount = json['amount'];
    paymentMethod = json['payment_method'];
    transactionId = json['transaction_id'];
    status = json['status'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['booking_id'] = this.bookingId;
    data['amount'] = this.amount;
    data['payment_method'] = this.paymentMethod;
    data['transaction_id'] = this.transactionId;
    data['status'] = this.status;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}

class Payment {
  String? orderId;
  String? paymentId;
  double? amount;
  String? status;

  Payment({this.orderId, this.paymentId, this.amount, this.status});

  Payment.fromJson(Map<String, dynamic> json) {
    orderId = json['orderId'];
    paymentId = json['paymentId'];
    amount = double.tryParse(json['amount']?.toString() ?? '0.00');
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['orderId'] = this.orderId;
    data['paymentId'] = this.paymentId;
    data['amount'] = this.amount;
    data['status'] = this.status;
    return data;
  }
}

class PaymentDetails {
  bool? isPartialPayment;
  String? paymentStatus;
  double? totalAmount;
  double? paidAmount;
  double? remainingAmount;
  double? advanceAmountPerTraveler;
  double? totalAdvanceAmount;
  int? participantCount;

  PaymentDetails({
    this.isPartialPayment,
    this.paymentStatus,
    this.totalAmount,
    this.paidAmount,
    this.remainingAmount,
    this.advanceAmountPerTraveler,
    this.totalAdvanceAmount,
    this.participantCount,
  });

  PaymentDetails.fromJson(Map<String, dynamic> json) {
    isPartialPayment = json['isPartialPayment'];
    paymentStatus = json['paymentStatus'];
    totalAmount = double.tryParse(json['totalAmount']?.toString() ?? '0.00');
    paidAmount = double.tryParse(json['paidAmount']?.toString() ?? '0.00');
    remainingAmount = double.tryParse(
      json['remainingAmount']?.toString() ?? '0.00',
    );
    advanceAmountPerTraveler = double.tryParse(
      json['advanceAmountPerTraveler']?.toString() ?? '0.00',
    );
    totalAdvanceAmount = double.tryParse(
      json['totalAdvanceAmount']?.toString() ?? '0.00',
    );
    participantCount = json['participantCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['isPartialPayment'] = this.isPartialPayment;
    data['paymentStatus'] = this.paymentStatus;
    data['totalAmount'] = this.totalAmount;
    data['paidAmount'] = this.paidAmount;
    data['remainingAmount'] = this.remainingAmount;
    data['advanceAmountPerTraveler'] = this.advanceAmountPerTraveler;
    data['totalAdvanceAmount'] = this.totalAdvanceAmount;
    data['participantCount'] = this.participantCount;
    return data;
  }
}
