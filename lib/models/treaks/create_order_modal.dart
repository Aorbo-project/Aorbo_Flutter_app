class CreateOrderModal {
  bool? success;
  String? message;
  Order? order;
  BookingData? bookingData;

  CreateOrderModal({this.success, this.message, this.order, this.bookingData});

  CreateOrderModal.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    order = json['order'] != null ? new Order.fromJson(json['order']) : null;
    bookingData = json['bookingData'] != null
        ? new BookingData.fromJson(json['bookingData'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    if (this.order != null) {
      data['order'] = this.order!.toJson();
    }
    if (this.bookingData != null) {
      data['bookingData'] = this.bookingData!.toJson();
    }
    return data;
  }
}

class Order {
  int? amount;
  int? amountDue;
  int? amountPaid;
  int? attempts;
  int? createdAt;
  String? currency;
  String? entity;
  String? id;
  // List<String>? notes;
  String? offerId;
  String? receipt;
  String? status;

  Order(
      {this.amount,
        this.amountDue,
        this.amountPaid,
        this.attempts,
        this.createdAt,
        this.currency,
        this.entity,
        this.id,
        // this.notes,
        this.offerId,
        this.receipt,
        this.status});

  Order.fromJson(Map<String, dynamic> json) {
    amount = json['amount'];
    amountDue = json['amount_due'];
    amountPaid = json['amount_paid'];
    attempts = json['attempts'];
    createdAt = json['created_at'];
    currency = json['currency'];
    entity = json['entity'];
    id = json['id'];
    // if (json['notes'] != null) {
    //   notes = <Null>[];
    //   json['notes'].forEach((v) {
    //     notes!.add(new Null.fromJson(v));
    //   });
    // }
    offerId = json['offer_id'];
    receipt = json['receipt'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['amount'] = this.amount;
    data['amount_due'] = this.amountDue;
    data['amount_paid'] = this.amountPaid;
    data['attempts'] = this.attempts;
    data['created_at'] = this.createdAt;
    data['currency'] = this.currency;
    data['entity'] = this.entity;
    data['id'] = this.id;
    // if (this.notes != null) {
    //   data['notes'] = this.notes!.map((v) => v.toJson()).toList();
    // }
    data['offer_id'] = this.offerId;
    data['receipt'] = this.receipt;
    data['status'] = this.status;
    return data;
  }
}

class BookingData {
  int? trekId;
  int? customerId;
  List<OrderTravelers>? travelers;
  int? totalAmount;
  int? discountAmount;
  int? finalAmount;

  BookingData(
      {this.trekId,
        this.customerId,
        this.travelers,
        this.totalAmount,
        this.discountAmount,
        this.finalAmount});

  BookingData.fromJson(Map<String, dynamic> json) {
    trekId = json['trekId'];
    customerId = json['customerId'];
    if (json['travelers'] != null) {
      travelers = <OrderTravelers>[];
      json['travelers'].forEach((v) {
        travelers!.add(new OrderTravelers.fromJson(v));
      });
    }
    totalAmount = json['totalAmount'];
    discountAmount = json['discountAmount'];
    finalAmount = json['finalAmount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['trekId'] = this.trekId;
    data['customerId'] = this.customerId;
    if (this.travelers != null) {
      data['travelers'] = this.travelers!.map((v) => v.toJson()).toList();
    }
    data['totalAmount'] = this.totalAmount;
    data['discountAmount'] = this.discountAmount;
    data['finalAmount'] = this.finalAmount;
    return data;
  }
}

class OrderTravelers {
  String? name;
  int? age;
  String? gender;
  String? phone;
  String? email;
  String? emergencyContactName;
  String? emergencyContactPhone;
  String? emergencyContactRelation;
  String? medicalConditions;
  String? dietaryRestrictions;

  OrderTravelers(
      {this.name,
        this.age,
        this.gender,
        this.phone,
        this.email,
        this.emergencyContactName,
        this.emergencyContactPhone,
        this.emergencyContactRelation,
        this.medicalConditions,
        this.dietaryRestrictions});

  OrderTravelers.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    age = json['age'];
    gender = json['gender'];
    phone = json['phone'];
    email = json['email'];
    emergencyContactName = json['emergency_contact_name'];
    emergencyContactPhone = json['emergency_contact_phone'];
    emergencyContactRelation = json['emergency_contact_relation'];
    medicalConditions = json['medical_conditions'];
    dietaryRestrictions = json['dietary_restrictions'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['age'] = this.age;
    data['gender'] = this.gender;
    data['phone'] = this.phone;
    data['email'] = this.email;
    data['emergency_contact_name'] = this.emergencyContactName;
    data['emergency_contact_phone'] = this.emergencyContactPhone;
    data['emergency_contact_relation'] = this.emergencyContactRelation;
    data['medical_conditions'] = this.medicalConditions;
    data['dietary_restrictions'] = this.dietaryRestrictions;
    return data;
  }
}
