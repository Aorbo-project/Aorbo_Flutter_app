// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'top_treks_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TopTreksDataResponseModelImpl _$$TopTreksDataResponseModelImplFromJson(
        Map<String, dynamic> json) =>
    _$TopTreksDataResponseModelImpl(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => TopTreksData.fromJson(e as Map<String, dynamic>))
          .toList(),
      count: json['count'] as int?,
    );

Map<String, dynamic> _$$TopTreksDataResponseModelImplToJson(
        _$TopTreksDataResponseModelImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
      'count': instance.count,
    };

_$TopTreksDataImpl _$$TopTreksDataImplFromJson(Map<String, dynamic> json) =>
    _$TopTreksDataImpl(
      title: json['title'] as String?,
      description: json['description'] as String?,
      imagePath: json['imagePath'] as String?,
      gradient: (json['gradient'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      isFavorite: json['isFavorite'] as bool?,
    );

Map<String, dynamic> _$$TopTreksDataImplToJson(_$TopTreksDataImpl instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'imagePath': instance.imagePath,
      'gradient': instance.gradient,
      'isFavorite': instance.isFavorite,
    };
