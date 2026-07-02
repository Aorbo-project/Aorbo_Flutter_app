import '../../freezed_models/profile/user_profile_model.dart';

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
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    payment = json['payment'] != null
        ? Payment.fromJson(json['payment'])
        : null;
    paymentDetails = json['paymentDetails'] != null
        ? PaymentDetails.fromJson(json['paymentDetails'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    if (payment != null) {
      data['payment'] = payment!.toJson();
    }
    if (paymentDetails != null) {
      data['paymentDetails'] = paymentDetails!.toJson();
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
  String? bookingNumber;
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
    this.bookingNumber,
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
    bookingNumber = json['booking_number'];
    specialRequests = json['special_requests'];
    bookingSource = json['booking_source'];
    primaryContactTravelerId = json['primary_contact_traveler_id'];
    cityId = json['city_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    userId = json['user_id'];
    trek = json['trek'] != null ? Trek.fromJson(json['trek']) : null;
    vendor = json['vendor'] != null
        ? Vendor.fromJson(json['vendor'])
        : null;
    batch = json['batch'] != null ? Batch.fromJson(json['batch']) : null;
    city = json['city'] != null ? City.fromJson(json['city']) : null;
    if (json['travelers'] != null) {
      travelers = <VerifyTrekTraveler>[];
      json['travelers'].forEach((v) {
        travelers!.add(VerifyTrekTraveler.fromJson(v));
      });
    }
    if (json['payments'] != null) {
      payments = <Payments>[];
      json['payments'].forEach((v) {
        payments!.add(Payments.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['customer_id'] = customerId;
    data['trek_id'] = trekId;
    data['vendor_id'] = vendorId;
    data['batch_id'] = batchId;
    data['coupon_id'] = couponId;
    data['total_travelers'] = totalTravelers;
    data['total_amount'] = totalAmount;
    data['discount_amount'] = discountAmount;
    data['final_amount'] = finalAmount;
    data['payment_status'] = paymentStatus;
    data['status'] = status;
    data['booking_date'] = bookingDate;
    data['booking_number'] = bookingNumber;
    data['special_requests'] = specialRequests;
    data['booking_source'] = bookingSource;
    data['primary_contact_traveler_id'] = primaryContactTravelerId;
    data['city_id'] = cityId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['user_id'] = userId;
    if (trek != null) {
      data['trek'] = trek!.toJson();
    }
    if (vendor != null) {
      data['vendor'] = vendor!.toJson();
    }
    if (batch != null) {
      data['batch'] = batch!.toJson();
    }
    if (city != null) {
      data['city'] = city!.toJson();
    }
    if (travelers != null) {
      data['travelers'] = travelers!.map((v) => v.toJson()).toList();
    }
    if (payments != null) {
      data['payments'] = payments!.map((v) => v.toJson()).toList();
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
    mtrId = (json['mtr_id'] ?? json['display_trek_id'])?.toString();
    title = json['title'];
    description = json['description'];
    vendorId = json['vendor_id'];
    destinationId = json['destination_id'];
    captainId = json['captain_id'];
    duration = json['duration'];
    durationDays = json['duration_days'];
    durationNights = json['duration_nights'];
    basePrice = json['base_price']?.toString();
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
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    destinationData = json['destinationData'] != null
        ? DestinationData.fromJson(json['destinationData'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['city_ids'] = cityIds;
    data['inclusions'] = inclusions;
    data['exclusions'] = exclusions;
    data['activities'] = activities;
    data['id'] = id;
    data['mtr_id'] = mtrId;
    data['title'] = title;
    data['description'] = description;
    data['vendor_id'] = vendorId;
    data['destination_id'] = destinationId;
    data['captain_id'] = captainId;
    data['duration'] = duration;
    data['duration_days'] = durationDays;
    data['duration_nights'] = durationNights;
    data['base_price'] = basePrice;
    data['max_participants'] = maxParticipants;
    data['trekking_rules'] = trekkingRules;
    data['emergency_protocols'] = emergencyProtocols;
    data['organizer_notes'] = organizerNotes;
    data['status'] = status;
    data['discount_value'] = discountValue;
    data['discount_type'] = discountType;
    data['has_discount'] = hasDiscount;
    data['cancellation_policy_id'] = cancellationPolicyId;
    data['badge_id'] = badgeId;
    data['has_been_edited'] = hasBeenEdited;
    data['safety_security_count'] = safetySecurityCount;
    data['organizer_manner_count'] = organizerMannerCount;
    data['trek_planning_count'] = trekPlanningCount;
    data['women_safety_count'] = womenSafetyCount;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (destinationData != null) {
      data['destinationData'] = destinationData!.toJson();
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['state'] = state;
    data['isPopular'] = isPopular;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
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
        ? CompanyInfo.fromJson(json['company_info'])
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
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    if (companyInfo != null) {
      data['company_info'] = companyInfo!.toJson();
    }
    data['status'] = status;
    data['address'] = address;
    data['business_name'] = businessName;
    data['business_type'] = businessType;
    data['business_entity'] = businessEntity;
    data['business_address'] = businessAddress;
    data['gstin'] = gstin;
    data['account_holder_name'] = accountHolderName;
    data['bank_name'] = bankName;
    data['ifsc_code'] = ifscCode;
    data['account_number'] = accountNumber;
    data['pan_card_path'] = panCardPath;
    data['id_proof_path'] = idProofPath;
    data['cancelled_cheque_path'] = cancelledChequePath;
    data['gstin_certificate_path'] = gstinCertificatePath;
    data['msme_certificate_path'] = msmeCertificatePath;
    data['shop_establishment_path'] = shopEstablishmentPath;
    data['pan_card_verified'] = panCardVerified;
    data['id_proof_verified'] = idProofVerified;
    data['cancelled_cheque_verified'] = cancelledChequeVerified;
    data['gstin_certificate_verified'] = gstinCertificateVerified;
    data['msme_certificate_verified'] = msmeCertificateVerified;
    data['shop_establishment_verified'] = shopEstablishmentVerified;
    data['kyc_status'] = kycStatus;
    data['kyc_step'] = kycStep;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['company_name'] = companyName;
    data['contact_person'] = contactPerson;
    data['phone'] = phone;
    data['email'] = email;
    data['address'] = address;
    data['gst_number'] = gstNumber;
    data['pan_number'] = panNumber;
    data['bank_name'] = bankName;
    data['account_number'] = accountNumber;
    data['ifsc_code'] = ifscCode;
    data['commission_rate'] = commissionRate;
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
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['tbr_id'] = tbrId;
    data['trek_id'] = trekId;
    data['start_date'] = startDate;
    data['end_date'] = endDate;
    data['capacity'] = capacity;
    data['booked_slots'] = bookedSlots;
    data['available_slots'] = availableSlots;
    data['captain_id'] = captainId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['cityName'] = cityName;
    data['isPopular'] = isPopular;
    data['stateId'] = stateId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
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
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    traveler = json['traveler'] != null
        ? Traveler.fromJson(json['traveler'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['booking_id'] = bookingId;
    data['traveler_id'] = travelerId;
    data['is_primary'] = isPrimary;
    data['special_requirements'] = specialRequirements;
    data['accommodation_preference'] = accommodationPreference;
    data['meal_preference'] = mealPreference;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (traveler != null) {
      data['traveler'] = traveler!.toJson();
    }
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
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['booking_id'] = bookingId;
    data['amount'] = amount;
    data['payment_method'] = paymentMethod;
    data['transaction_id'] = transactionId;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['orderId'] = orderId;
    data['paymentId'] = paymentId;
    data['amount'] = amount;
    data['status'] = status;
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['isPartialPayment'] = isPartialPayment;
    data['paymentStatus'] = paymentStatus;
    data['totalAmount'] = totalAmount;
    data['paidAmount'] = paidAmount;
    data['remainingAmount'] = remainingAmount;
    data['advanceAmountPerTraveler'] = advanceAmountPerTraveler;
    data['totalAdvanceAmount'] = totalAdvanceAmount;
    data['participantCount'] = participantCount;
    return data;
  }
}
