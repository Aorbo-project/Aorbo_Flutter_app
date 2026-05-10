import 'package:arobo_app/freezed_models/treks/trek_detail_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'treks_model_data.freezed.dart';
part 'treks_model_data.g.dart';


@freezed
class CalenderDatesResponseModel with _$CalenderDatesResponseModel {
  const factory CalenderDatesResponseModel({
    bool? success,
    String? message,
    CalenderDataModel? data,
    int? count
  }) = _CalenderDatesResponseModel;

  factory CalenderDatesResponseModel.fromJson(Map<String, dynamic> json) =>
      _$CalenderDatesResponseModelFromJson(json);
}


@freezed
class CalenderDataModel with _$CalenderDataModel {
  const factory CalenderDataModel({
    @JsonKey(name: 'start_date') String? startDate,
    @JsonKey(name: 'end_date') String? endDate,
    List<TrekDatesModel>? dates,
    @JsonKey(name: 'total_dates_with_treks') int? totalDatesWithTreks,
  }) = _CalenderDataModel;

  factory CalenderDataModel.fromJson(Map<String, dynamic> json) =>
      _$CalenderDataModelFromJson(json);
}

@freezed
class TrekDatesModel with _$TrekDatesModel {
  const factory TrekDatesModel({
    String? date,
    @JsonKey(name: 'trek_count') int? trekCount,
    @JsonKey(name: 'has_treks') bool? available
  }) = _TrekDatesModel;

  factory TrekDatesModel.fromJson(Map<String, dynamic> json) =>
      _$TrekDatesModelFromJson(json);
}


@freezed
class FetchTreksResponseModel with _$FetchTreksResponseModel {
  const factory FetchTreksResponseModel({
    bool? success,
    String? message,
    @JsonKey(name:"search_context") SearchContextModel? searchContext,
    List<TrekData>? data,
    int? count
  }) = _FetchTreksResponseModel;

  factory FetchTreksResponseModel.fromJson(Map<String, dynamic> json) =>
      _$FetchTreksResponseModelFromJson(json);
}

@freezed
class SearchContextModel with _$SearchContextModel {
  const factory SearchContextModel({
    String? from,
    String? to,
    @JsonKey(name:"selected_date") dynamic selectedDate,
    @JsonKey(name:"weekend_mode") bool? weekendMode,
    @JsonKey(name:"weekend_dates") List<String>? weekendDates
  }) = _SearchContextModel;

  factory SearchContextModel.fromJson(Map<String, dynamic> json) =>
      _$SearchContextModelFromJson(json);
}

@freezed
class TrekData with _$TrekData {
  const factory TrekData({
    int? id,
    String? name,
    String? vendor,
    String? vendorLogo,
    String? businessName,
    bool? hasDiscount,
    String? discountText,
    double? rating,
    String? price,
    String? duration,
    BatchInfo? batchInfo,
    Badge? badge,
    String? imageUrl,
    CancellationPolicy? cancellationPolicy
  }) = _TrekData;

  factory TrekData.fromJson(Map<String, dynamic> json) =>
      _$TrekDataFromJson(json);
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