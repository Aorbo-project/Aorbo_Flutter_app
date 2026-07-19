import 'package:freezed_annotation/freezed_annotation.dart';

part 'top_treks_data.freezed.dart';
part 'top_treks_data.g.dart';

@freezed
class TopTreksDataResponseModel with _$TopTreksDataResponseModel {
  const factory TopTreksDataResponseModel({
    bool? success,
    String? message,
    List<TopTreksData>? data,
    int? count
  }) = _TopTreksDataResponseModel;

  factory TopTreksDataResponseModel.fromJson(Map<String, dynamic> json) => _$TopTreksDataResponseModelFromJson(json);
}

@freezed
class TopTreksData with _$TopTreksData {
  const factory TopTreksData({
    int? id,

    String? title,

    String? kicker,

    String? description,

    @JsonKey(name: 'imagePath')
    String? imagePath,

    @JsonKey(name: 'badgeType')
    String? badgeType,

    String? meta,

    @JsonKey(name: 'isFavorite')
    bool? isFavorite,

    @JsonKey(name: 'trekId')
    int? trekId,

    @JsonKey(name: 'detailUrl')
    String? detailUrl,
  }) = _TopTreksData;

  factory TopTreksData.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$TopTreksDataFromJson(json);
}
