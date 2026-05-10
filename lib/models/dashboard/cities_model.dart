class GetCities {
  bool? success;
  List<Data>? data;

  GetCities({this.success, this.data});

  GetCities.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? id;
  String? cityName;
  bool? isPopular;

  Data({this.id, this.cityName, this.isPopular});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    cityName = json['cityName'];
    isPopular = json['isPopular'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['cityName'] = this.cityName;
    data['isPopular'] = this.isPopular;
    return data;
  }
}
