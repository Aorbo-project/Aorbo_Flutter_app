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
      gradient: json['gradient'] as List<dynamic>?,
      textColour: json['textColour'] as String?,
      styling: json['styling'] == null
          ? null
          : StylingModel.fromJson(json['styling'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$SeasonalForecastDataImplToJson(
        _$SeasonalForecastDataImpl instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'imagePath': instance.imagePath,
      'color': instance.color,
      'gradient': instance.gradient,
      'textColour': instance.textColour,
      'styling': instance.styling,
    };

_$StylingModelImpl _$$StylingModelImplFromJson(Map<String, dynamic> json) =>
    _$StylingModelImpl(
      card: json['card'],
      header: json['header'],
      title: json['title'] == null
          ? null
          : TitleStylingModel.fromJson(json['title'] as Map<String, dynamic>),
      icon: json['icon'],
      body: json['body'] == null
          ? null
          : BodyStylingModel.fromJson(json['body'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$StylingModelImplToJson(_$StylingModelImpl instance) =>
    <String, dynamic>{
      'card': instance.card,
      'header': instance.header,
      'title': instance.title,
      'icon': instance.icon,
      'body': instance.body,
    };

_$TitleStylingModelImpl _$$TitleStylingModelImplFromJson(
        Map<String, dynamic> json) =>
    _$TitleStylingModelImpl(
      gradient: json['gradient'] as List<dynamic>?,
      textColour: json['textColour'] as String?,
      icon: json['icon'] as String?,
    );

Map<String, dynamic> _$$TitleStylingModelImplToJson(
        _$TitleStylingModelImpl instance) =>
    <String, dynamic>{
      'gradient': instance.gradient,
      'textColour': instance.textColour,
      'icon': instance.icon,
    };

_$BodyStylingModelImpl _$$BodyStylingModelImplFromJson(
        Map<String, dynamic> json) =>
    _$BodyStylingModelImpl(
      padding: json['padding'],
      gradient: json['gradient'] == null
          ? null
          : GradientStylingModel.fromJson(
              json['gradient'] as Map<String, dynamic>),
      borderRadiusBottom: json['borderRadiusBottom'],
    );

Map<String, dynamic> _$$BodyStylingModelImplToJson(
        _$BodyStylingModelImpl instance) =>
    <String, dynamic>{
      'padding': instance.padding,
      'gradient': instance.gradient,
      'borderRadiusBottom': instance.borderRadiusBottom,
    };

_$GradientStylingModelImpl _$$GradientStylingModelImplFromJson(
        Map<String, dynamic> json) =>
    _$GradientStylingModelImpl(
      colors:
          (json['colors'] as List<dynamic>?)?.map((e) => e as String).toList(),
      direction: json['direction'] as String?,
      start: (json['start'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
      end: (json['end'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
    );

Map<String, dynamic> _$$GradientStylingModelImplToJson(
        _$GradientStylingModelImpl instance) =>
    <String, dynamic>{
      'colors': instance.colors,
      'direction': instance.direction,
      'start': instance.start,
      'end': instance.end,
    };
