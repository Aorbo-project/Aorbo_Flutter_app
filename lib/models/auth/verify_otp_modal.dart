class VerifyOtpModal {
  bool? success;
  String? message;
  Data? data;

  VerifyOtpModal({
    this.success,
    this.message,
    this.data,
  });

  VerifyOtpModal.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  String? token;
  Customer? customer;
  String? expiresIn;

  Data({
    this.token,
    this.customer,
    this.expiresIn,
  });

  Data.fromJson(Map<String, dynamic> json) {
    token = json['token'];
    customer =
        json['customer'] != null ? Customer.fromJson(json['customer']) : null;
    expiresIn = json['expiresIn'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['token'] = token;
    if (customer != null) {
      data['customer'] = customer!.toJson();
    }
    data['expiresIn'] = expiresIn;
    return data;
  }
}

class Customer {
  int? id;
  String? phone;
  String? email;
  bool? profileCompleted;
  bool? isNewCustomer;

  Customer({
    this.id,
    this.phone,
    this.email,
    this.profileCompleted,
    this.isNewCustomer,
  });

  Customer.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    phone = json['phone'];
    email = json['email'];
    profileCompleted = json['profileCompleted'];
    isNewCustomer = json['isNewCustomer'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['phone'] = phone;
    data['email'] = email;
    data['profileCompleted'] = profileCompleted;
    data['isNewCustomer'] = isNewCustomer;
    return data;
  }
}
