// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shorts_treks_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ShortsTreksDataResponseModelImpl _$$ShortsTreksDataResponseModelImplFromJson(
        Map<String, dynamic> json) =>
    _$ShortsTreksDataResponseModelImpl(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => ShortsTreksData.fromJson(e as Map<String, dynamic>))
          .toList(),
      count: json['count'] as int?,
    );

Map<String, dynamic> _$$ShortsTreksDataResponseModelImplToJson(
        _$ShortsTreksDataResponseModelImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
      'count': instance.count,
    };

_$ShortsTreksDataImpl _$$ShortsTreksDataImplFromJson(
        Map<String, dynamic> json) =>
    _$ShortsTreksDataImpl(
      title: json['title'] as String?,
      description: json['description'] as String?,
      imagePath: json['imagePath'] as String?,
    );

Map<String, dynamic> _$$ShortsTreksDataImplToJson(
        _$ShortsTreksDataImpl instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'imagePath': instance.imagePath,
    };
