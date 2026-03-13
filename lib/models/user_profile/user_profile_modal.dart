class UserProfileModal {
  bool? success;
  UserProfileData? data;

  UserProfileModal({this.success, this.data});

  UserProfileModal.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? new UserProfileData.fromJson(json['data']) : null;
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

class UserProfileData {
  Customer? customer;

  UserProfileData({this.customer});

  UserProfileData.fromJson(Map<String, dynamic> json) {
    customer = json['customer'] != null
        ? new Customer.fromJson(json['customer'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.customer != null) {
      data['customer'] = this.customer!.toJson();
    }
    return data;
  }
}

class Customer {
  int? id;
  String? phone;
  String? name;
  String? email;
  String? dateOfBirth;
  String? emergencyContact;
  bool? profileCompleted;
  UserState? city;
  UserState? state;
  List<Travelers>? travelers;

  Customer(
      {this.id,
        this.phone,
        this.name,
        this.email,
        this.dateOfBirth,
        this.emergencyContact,
        this.profileCompleted,
        this.city,
        this.state,
        this.travelers});

  Customer.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    phone = json['phone'];
    name = json['name'];
    email = json['email'];
    dateOfBirth = json['dateOfBirth'];
    emergencyContact = json['emergencyContact'];
    profileCompleted = json['profileCompleted'];
    city = json['city'];
    state = json['state'] != null ? new UserState.fromJson(json['state']) : null;
    if (json['travelers'] != null) {
      travelers = <Travelers>[];
      json['travelers'].forEach((v) {
        travelers!.add(new Travelers.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['phone'] = this.phone;
    data['name'] = this.name;
    data['email'] = this.email;
    data['dateOfBirth'] = this.dateOfBirth;
    data['emergencyContact'] = this.emergencyContact;
    data['profileCompleted'] = this.profileCompleted;
    data['city'] = this.city;
    if (this.state != null) {
      data['state'] = this.state!.toJson();
    }
    if (this.travelers != null) {
      data['travelers'] = this.travelers!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class UserState {
  int? id;
  String? name;

  UserState({this.id, this.name});

  UserState.fromJson(Map<String, dynamic> json) {
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

class Travelers {
  int? id;
  int? customerId;
  String? name;
  int? age;
  String? gender;
  bool? isActive;
  String? createdAt;
  String? updatedAt;

  Travelers(
      {this.id,
        this.customerId,
        this.name,
        this.age,
        this.gender,
        this.isActive,
        this.createdAt,
        this.updatedAt});

  Travelers.fromJson(Map<String, dynamic> json) {
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
