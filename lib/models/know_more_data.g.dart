// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'know_more_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WhatsNewDataResponseModelImpl _$$WhatsNewDataResponseModelImplFromJson(
        Map<String, dynamic> json) =>
    _$WhatsNewDataResponseModelImpl(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => KnowMoreData.fromJson(e as Map<String, dynamic>))
          .toList(),
      count: json['count'] as int?,
    );

Map<String, dynamic> _$$WhatsNewDataResponseModelImplToJson(
        _$WhatsNewDataResponseModelImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
      'count': instance.count,
    };

_$KnowMoreDataImpl _$$KnowMoreDataImplFromJson(Map<String, dynamic> json) =>
    _$KnowMoreDataImpl(
      title: json['title'] as String?,
      subtitle: json['subtitle'] as String?,
      imagePath: json['imagePath'] as String?,
      hasKnowMore: json['hasKnowMore'] as bool?,
      customGradient: (json['customGradient'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      textColor: json['textColor'] as String?,
      detailedTitle: json['detailedTitle'] as String?,
      detailedDescription: json['detailedDescription'] as String?,
      bulletPoints: (json['bulletPoints'] as List<dynamic>?)
          ?.map((e) => BulletPointModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      callToAction: json['callToAction'] as String?,
    );

Map<String, dynamic> _$$KnowMoreDataImplToJson(_$KnowMoreDataImpl instance) =>
    <String, dynamic>{
      'title': instance.title,
      'subtitle': instance.subtitle,
      'imagePath': instance.imagePath,
      'hasKnowMore': instance.hasKnowMore,
      'customGradient': instance.customGradient,
      'textColor': instance.textColor,
      'detailedTitle': instance.detailedTitle,
      'detailedDescription': instance.detailedDescription,
      'bulletPoints': instance.bulletPoints,
      'callToAction': instance.callToAction,
    };

_$BulletPointModelImpl _$$BulletPointModelImplFromJson(
        Map<String, dynamic> json) =>
    _$BulletPointModelImpl(
      title: json['title'] as String?,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$$BulletPointModelImplToJson(
        _$BulletPointModelImpl instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
    };
