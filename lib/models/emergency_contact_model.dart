class EmergencyContactResponse {
  bool? success;
  List<EmergencyContact>? data;

  EmergencyContactResponse({this.success, this.data});

  EmergencyContactResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <EmergencyContact>[];
      json['data'].forEach((v) {
        data!.add(EmergencyContact.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class EmergencyContact {
  int? id;
  int? customerId;
  String? name;
  String? phone;
  String? relationship;
  int? priority;
  bool? isActive;
  String? createdAt;
  String? updatedAt;

  EmergencyContact({
    this.id,
    this.customerId,
    this.name,
    this.phone,
    this.relationship,
    this.priority,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  EmergencyContact.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    customerId = json['customer_id'];
    name = json['name'];
    phone = json['phone'];
    relationship = json['relationship'];
    priority = json['priority'];
    isActive = json['is_active'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (id != null) data['id'] = id;
    if (customerId != null) data['customer_id'] = customerId;
    data['name'] = name;
    data['phone'] = phone;
    if (relationship != null) data['relationship'] = relationship;
    if (priority != null) data['priority'] = priority;
    if (isActive != null) data['is_active'] = isActive;
    if (createdAt != null) data['created_at'] = createdAt;
    if (updatedAt != null) data['updated_at'] = updatedAt;
    return data;
  }
}

class EmergencyContactCreateResponse {
  bool? success;
  String? message;
  EmergencyContact? data;

  EmergencyContactCreateResponse({this.success, this.message, this.data});

  EmergencyContactCreateResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? EmergencyContact.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (message != null) data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class EmergencyContactDeleteResponse {
  bool? success;
  String? message;

  EmergencyContactDeleteResponse({this.success, this.message});

  EmergencyContactDeleteResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (message != null) data['message'] = message;
    return data;
  }
}
