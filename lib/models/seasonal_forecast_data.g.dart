// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seasonal_forecast_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SeasonalForecastDataResponseModelImpl
    _$$SeasonalForecastDataResponseModelImplFromJson(
            Map<String, dynamic> json) =>
        _$SeasonalForecastDataResponseModelImpl(
          success: json['success'] as bool?,
          message: json['message'] as String?,
          data: (json['data'] as List<dynamic>?)
              ?.map((e) =>
                  SeasonalForecastData.fromJson(e as Map<String, dynamic>))
              .toList(),
          count: json['count'] as int?,
        );

Map<String, dynamic> _$$SeasonalForecastDataResponseModelImplToJson(
        _$SeasonalForecastDataResponseModelImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
      'count': instance.count,
    };

_$SeasonalForecastDataImpl _$$SeasonalForecastDataImplFromJson(
        Map<String, dynamic> json) =>
    _$SeasonalForecastDataImpl(
      title: json['title'] as String?,
      description: json['description'] as String?,
      imagePath: json['imagePath'] as String?,
      color: json['color'] as String?,
    );

Map<String, dynamic> _$$SeasonalForecastDataImplToJson(
        _$SeasonalForecastDataImpl instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'imagePath': instance.imagePath,
      'color': instance.color,
    };
