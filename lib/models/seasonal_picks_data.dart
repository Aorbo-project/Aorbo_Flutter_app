import 'package:freezed_annotation/freezed_annotation.dart';

part 'seasonal_picks_data.freezed.dart';
part 'seasonal_picks_data.g.dart';

/// Response model for GET /api/v1/discovery/seasonal-picks — the dedicated
/// seasonal_forecast_picks backend (distinct from the legacy, unrelated
/// SeasonalForecastDataResponseModel / discovery/seasonal-forecast).
@freezed
class SeasonalPicksDataResponseModel with _$SeasonalPicksDataResponseModel {
  const factory SeasonalPicksDataResponseModel({
    bool? success,
    String? message,
    SeasonalPicksData? data,
  }) = _SeasonalPicksDataResponseModel;

  factory SeasonalPicksDataResponseModel.fromJson(Map<String, dynamic> json) =>
      _$SeasonalPicksDataResponseModelFromJson(json);
}

@freezed
class SeasonalPicksData with _$SeasonalPicksData {
  const factory SeasonalPicksData({
    String? season,
    String? label,

    @JsonKey(name: 'dateRange')
    String? dateRange,

    String? blurb,

    @JsonKey(name: 'topPicks')
    List<SeasonalPickItem>? topPicks,

    @JsonKey(name: 'avoidPicks')
    List<SeasonalPickItem>? avoidPicks,
  }) = _SeasonalPicksData;

  factory SeasonalPicksData.fromJson(Map<String, dynamic> json) =>
      _$SeasonalPicksDataFromJson(json);
}

@freezed
class SeasonalPickItem with _$SeasonalPickItem {
  const factory SeasonalPickItem({
    int? id,

    @JsonKey(name: 'trekName')
    String? trekName,

    String? reason,

    @JsonKey(name: 'imagePath')
    String? imagePath,

    @JsonKey(name: 'isAvoid')
    bool? isAvoid,

    @JsonKey(name: 'trekId')
    int? trekId,

    @JsonKey(name: 'detailUrl')
    String? detailUrl,
  }) = _SeasonalPickItem;

  factory SeasonalPickItem.fromJson(Map<String, dynamic> json) =>
      _$SeasonalPickItemFromJson(json);
}
