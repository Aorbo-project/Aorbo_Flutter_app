import 'package:freezed_annotation/freezed_annotation.dart';

part 'treks_model_data.freezed.dart';
part 'treks_model_data.g.dart';


@freezed
class FetchTreksResponseModel with _$FetchTreksResponseModel {
  const factory FetchTreksResponseModel({
    bool? success,
    String? message,
    List<TrekData>? data,
    int? count
  }) = _FetchTreksResponseModel;

  factory FetchTreksResponseModel.fromJson(Map<String, dynamic> json) =>
      _$FetchTreksResponseModelFromJson(json);
}

@freezed
class TrekData with _$TrekData {
  const factory TrekData({
    int? id,
    String? name,
    String? vendor,
    bool? hasDiscount,
    String? discountText,
    double? rating,
    String? price,
    String? duration,
    BatchInfo? batchInfo,
    Badge? badge,
  }) = _TrekData;

  factory TrekData.fromJson(Map<String, dynamic> json) =>
      _$TrekDataFromJson(json);
}

@freezed
class BatchInfo with _$BatchInfo {
  const factory BatchInfo({
    int? id,
    String? startDate,
    int? availableSlots,
  }) = _BatchInfo;

  factory BatchInfo.fromJson(Map<String, dynamic> json) =>
      _$BatchInfoFromJson(json);
}

@freezed
class Badge with _$Badge {
  const factory Badge({
    int? id,
    String? name,
    String? icon,
    String? color,
    String? category,
  }) = _Badge;

  factory Badge.fromJson(Map<String, dynamic> json) =>
      _$BadgeFromJson(json);
}




@freezed
class TrekBatchesResponseModel with _$TrekBatchesResponseModel {
  const factory TrekBatchesResponseModel({
    bool? success,
    String? message,
    List<TrekBatchDataModel>? data,
    int? count
  }) = _TrekBatchesResponseModel;

  factory TrekBatchesResponseModel.fromJson(Map<String, dynamic> json) =>
      _$TrekBatchesResponseModelFromJson(json);
}

@freezed
class TrekBatchDataModel with _$TrekBatchDataModel {
  const factory TrekBatchDataModel({
    int? id,
    @JsonKey(name: 'trek_id') int? trekId,
    @JsonKey(name:'start_date') String? startDate,
    @JsonKey(name:'end_date') String? endDate,
    @JsonKey(name:'available_slots') int? availableSlots,
    String? status
  }) = _TrekBatchDataModel;

  factory TrekBatchDataModel.fromJson(Map<String, dynamic> json) =>
      _$TrekBatchDataModelFromJson(json);
}