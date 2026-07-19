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
      id: json['id'] as int?,
      title: json['title'] as String?,
      kicker: json['kicker'] as String?,
      description: json['description'] as String?,
      imagePath: json['imagePath'] as String?,
      badgeType: json['badgeType'] as String?,
      meta: json['meta'] as String?,
      isFavorite: json['isFavorite'] as bool?,
      trekId: json['trekId'] as int?,
      detailUrl: json['detailUrl'] as String?,
    );

Map<String, dynamic> _$$TopTreksDataImplToJson(_$TopTreksDataImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'kicker': instance.kicker,
      'description': instance.description,
      'imagePath': instance.imagePath,
      'badgeType': instance.badgeType,
      'meta': instance.meta,
      'isFavorite': instance.isFavorite,
      'trekId': instance.trekId,
      'detailUrl': instance.detailUrl,
    };
