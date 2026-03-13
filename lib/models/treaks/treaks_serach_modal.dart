class TrekCardListModel {
  bool? success;
  List<TrekData>? data;
  int? count;

  TrekCardListModel({this.success, this.data, this.count});

  TrekCardListModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <TrekData>[];
      json['data'].forEach((v) {
        data!.add(new TrekData.fromJson(v));
      });
    }
    count = json['count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['count'] = this.count;
    return data;
  }
}

class TrekData {
  int? id;
  String? name;
  String? vendor;
  bool? hasDiscount;
  String? discountText;
  double? rating;
  String? price;
  String? duration;
  BatchInfo? batchInfo;
  Badge? badge;

  TrekData(
      {this.id,
      this.name,
      this.vendor,
      this.hasDiscount,
      this.discountText,
      this.rating,
      this.price,
      this.duration,
      this.batchInfo,
      this.badge});

  TrekData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    vendor = json['vendor'];
    hasDiscount = json['hasDiscount'];
    discountText = json['discountText'];
    rating = json['rating'].toDouble();
    price = json['price'];
    duration = json['duration'];
    batchInfo = json['batchInfo'] != null
        ? new BatchInfo.fromJson(json['batchInfo'])
        : null;
    badge = json['badge'] != null ? new Badge.fromJson(json['badge']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['vendor'] = this.vendor;
    data['hasDiscount'] = this.hasDiscount;
    data['discountText'] = this.discountText;
    data['rating'] = this.rating;
    data['price'] = this.price;
    data['duration'] = this.duration;
    if (this.batchInfo != null) {
      data['batchInfo'] = this.batchInfo!.toJson();
    }
    if (this.badge != null) {
      data['badge'] = this.badge!.toJson();
    }
    return data;
  }
}

class BatchInfo {
  int? id;
  String? startDate;
  int? availableSlots;

  BatchInfo({this.id, this.startDate, this.availableSlots});

  BatchInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    startDate = json['startDate'];
    availableSlots = json['availableSlots'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['startDate'] = this.startDate;
    data['availableSlots'] = this.availableSlots;
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
