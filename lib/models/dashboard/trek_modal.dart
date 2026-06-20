class TrekModal {
  bool? success;
  List<Data>? data;
  Pagination? pagination;

  TrekModal({this.success, this.data, this.pagination});

  TrekModal.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
    pagination = json['pagination'] != null
        ? Pagination.fromJson(json['pagination'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    if (pagination != null) {
      data['pagination'] = pagination!.toJson();
    }
    return data;
  }
}

class Data {
  int? id;
  String? name;
  String? state;
  bool? isPopular;
  String? status;
  String? createdAt;
  String? updatedAt;

  Data(
      {this.id,
        this.name,
        this.state,
        this.isPopular,
        this.status,
        this.createdAt,
        this.updatedAt});

  Data.fromJson(Map<String, dynamic> json) {
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

class Pagination {
  int? total;
  int? limit;
  int? offset;
  bool? hasMore;

  Pagination({this.total, this.limit, this.offset, this.hasMore});

  Pagination.fromJson(Map<String, dynamic> json) {
    total = json['total'];
    limit = json['limit'];
    offset = json['offset'];
    hasMore = json['hasMore'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total'] = total;
    data['limit'] = limit;
    data['offset'] = offset;
    data['hasMore'] = hasMore;
    return data;
  }
}
