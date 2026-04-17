// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'treks_model_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FetchTreksResponseModelImpl _$$FetchTreksResponseModelImplFromJson(
        Map<String, dynamic> json) =>
    _$FetchTreksResponseModelImpl(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => TrekData.fromJson(e as Map<String, dynamic>))
          .toList(),
      count: json['count'] as int?,
    );

Map<String, dynamic> _$$FetchTreksResponseModelImplToJson(
        _$FetchTreksResponseModelImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
      'count': instance.count,
    };

_$TrekDataImpl _$$TrekDataImplFromJson(Map<String, dynamic> json) =>
    _$TrekDataImpl(
      id: json['id'] as int?,
      name: json['name'] as String?,
      vendor: json['vendor'] as String?,
      hasDiscount: json['hasDiscount'] as bool?,
      discountText: json['discountText'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      price: json['price'] as String?,
      duration: json['duration'] as String?,
      batchInfo: json['batchInfo'] == null
          ? null
          : BatchInfo.fromJson(json['batchInfo'] as Map<String, dynamic>),
      badge: json['badge'] == null
          ? null
          : Badge.fromJson(json['badge'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$TrekDataImplToJson(_$TrekDataImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'vendor': instance.vendor,
      'hasDiscount': instance.hasDiscount,
      'discountText': instance.discountText,
      'rating': instance.rating,
      'price': instance.price,
      'duration': instance.duration,
      'batchInfo': instance.batchInfo,
      'badge': instance.badge,
    };

_$BatchInfoImpl _$$BatchInfoImplFromJson(Map<String, dynamic> json) =>
    _$BatchInfoImpl(
      id: json['id'] as int?,
      startDate: json['startDate'] as String?,
      availableSlots: json['availableSlots'] as int?,
    );

Map<String, dynamic> _$$BatchInfoImplToJson(_$BatchInfoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'startDate': instance.startDate,
      'availableSlots': instance.availableSlots,
    };

_$BadgeImpl _$$BadgeImplFromJson(Map<String, dynamic> json) => _$BadgeImpl(
      id: json['id'] as int?,
      name: json['name'] as String?,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      category: json['category'] as String?,
    );

Map<String, dynamic> _$$BadgeImplToJson(_$BadgeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'icon': instance.icon,
      'color': instance.color,
      'category': instance.category,
    };

_$TrekBatchesResponseModelImpl _$$TrekBatchesResponseModelImplFromJson(
        Map<String, dynamic> json) =>
    _$TrekBatchesResponseModelImpl(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => TrekBatchDataModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      count: json['count'] as int?,
    );

Map<String, dynamic> _$$TrekBatchesResponseModelImplToJson(
        _$TrekBatchesResponseModelImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
      'count': instance.count,
    };

_$TrekBatchDataModelImpl _$$TrekBatchDataModelImplFromJson(
        Map<String, dynamic> json) =>
    _$TrekBatchDataModelImpl(
      id: json['id'] as int?,
      trekId: json['trek_id'] as int?,
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
      availableSlots: json['available_slots'] as int?,
      status: json['status'] as String?,
    );

Map<String, dynamic> _$$TrekBatchDataModelImplToJson(
        _$TrekBatchDataModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'trek_id': instance.trekId,
      'start_date': instance.startDate,
      'end_date': instance.endDate,
      'available_slots': instance.availableSlots,
      'status': instance.status,
    };
