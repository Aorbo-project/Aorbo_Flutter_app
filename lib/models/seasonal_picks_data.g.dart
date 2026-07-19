// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seasonal_picks_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SeasonalPicksDataResponseModelImpl
    _$$SeasonalPicksDataResponseModelImplFromJson(Map<String, dynamic> json) =>
        _$SeasonalPicksDataResponseModelImpl(
          success: json['success'] as bool?,
          message: json['message'] as String?,
          data: json['data'] == null
              ? null
              : SeasonalPicksData.fromJson(
                  json['data'] as Map<String, dynamic>),
        );

Map<String, dynamic> _$$SeasonalPicksDataResponseModelImplToJson(
        _$SeasonalPicksDataResponseModelImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

_$SeasonalPicksDataImpl _$$SeasonalPicksDataImplFromJson(
        Map<String, dynamic> json) =>
    _$SeasonalPicksDataImpl(
      season: json['season'] as String?,
      label: json['label'] as String?,
      dateRange: json['dateRange'] as String?,
      blurb: json['blurb'] as String?,
      topPicks: (json['topPicks'] as List<dynamic>?)
          ?.map((e) => SeasonalPickItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      avoidPicks: (json['avoidPicks'] as List<dynamic>?)
          ?.map((e) => SeasonalPickItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$SeasonalPicksDataImplToJson(
        _$SeasonalPicksDataImpl instance) =>
    <String, dynamic>{
      'season': instance.season,
      'label': instance.label,
      'dateRange': instance.dateRange,
      'blurb': instance.blurb,
      'topPicks': instance.topPicks,
      'avoidPicks': instance.avoidPicks,
    };

_$SeasonalPickItemImpl _$$SeasonalPickItemImplFromJson(
        Map<String, dynamic> json) =>
    _$SeasonalPickItemImpl(
      id: json['id'] as int?,
      trekName: json['trekName'] as String?,
      reason: json['reason'] as String?,
      imagePath: json['imagePath'] as String?,
      imageType: json['imageType'] as String?,
      isAvoid: json['isAvoid'] as bool?,
      trekId: json['trekId'] as int?,
      detailUrl: json['detailUrl'] as String?,
    );

Map<String, dynamic> _$$SeasonalPickItemImplToJson(
        _$SeasonalPickItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'trekName': instance.trekName,
      'reason': instance.reason,
      'imagePath': instance.imagePath,
      'imageType': instance.imageType,
      'isAvoid': instance.isAvoid,
      'trekId': instance.trekId,
      'detailUrl': instance.detailUrl,
    };
