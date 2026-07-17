import 'package:freezed_annotation/freezed_annotation.dart';

part 'know_more_data.freezed.dart';
part 'know_more_data.g.dart';

@freezed
class WhatsNewDataResponseModel with _$WhatsNewDataResponseModel {
  const factory WhatsNewDataResponseModel({
    bool? success,
    String? message,
    List<KnowMoreData>? data,
    int? count
  }) = _WhatsNewDataResponseModel;

  factory WhatsNewDataResponseModel.fromJson(Map<String, dynamic> json) => _$WhatsNewDataResponseModelFromJson(json);
}

@freezed
class KnowMoreData with _$KnowMoreData {
  const factory KnowMoreData({
    String? title,

    String? subtitle,

    @JsonKey(name: 'imagePath')
    String? imagePath,

    @JsonKey(name: 'hasKnowMore')
    bool? hasKnowMore,

    List<String>? gradient,

    String? textColour,

    @JsonKey(name: 'detailedTitle')
    String? detailedTitle,

    @JsonKey(name: 'detailedDescription')
    String? detailedDescription,

    List<BulletPointModel>? bulletPoints,

    @JsonKey(name: 'callToAction')
    String? callToAction,
  }) = _KnowMoreData;

  factory KnowMoreData.fromJson(Map<String, dynamic> json) =>
      _$KnowMoreDataFromJson(json);
}

@freezed
class BulletPointModel with _$BulletPointModel {
  const factory BulletPointModel({
    String? icon,

    String? text,
  }) = _BulletPointModel;

  factory BulletPointModel.fromJson(Map<String, dynamic> json) =>
      _$BulletPointModelFromJson(json);
}

