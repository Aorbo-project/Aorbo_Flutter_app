// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'treks_model_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CalenderDatesResponseModelImpl _$$CalenderDatesResponseModelImplFromJson(
        Map<String, dynamic> json) =>
    _$CalenderDatesResponseModelImpl(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: json['data'] == null
          ? null
          : CalenderDataModel.fromJson(json['data'] as Map<String, dynamic>),
      count: json['count'] as int?,
    );

Map<String, dynamic> _$$CalenderDatesResponseModelImplToJson(
        _$CalenderDatesResponseModelImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
      'count': instance.count,
    };

_$CalenderDataModelImpl _$$CalenderDataModelImplFromJson(
        Map<String, dynamic> json) =>
    _$CalenderDataModelImpl(
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
      dates: (json['dates'] as List<dynamic>?)
          ?.map((e) => TrekDatesModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalDatesWithTreks: json['total_dates_with_treks'] as int?,
    );

Map<String, dynamic> _$$CalenderDataModelImplToJson(
        _$CalenderDataModelImpl instance) =>
    <String, dynamic>{
      'start_date': instance.startDate,
      'end_date': instance.endDate,
      'dates': instance.dates,
      'total_dates_with_treks': instance.totalDatesWithTreks,
    };

_$TrekDatesModelImpl _$$TrekDatesModelImplFromJson(Map<String, dynamic> json) =>
    _$TrekDatesModelImpl(
      date: json['date'] as String?,
      trekCount: json['trek_count'] as int?,
      available: json['has_treks'] as bool?,
    );

Map<String, dynamic> _$$TrekDatesModelImplToJson(
        _$TrekDatesModelImpl instance) =>
    <String, dynamic>{
      'date': instance.date,
      'trek_count': instance.trekCount,
      'has_treks': instance.available,
    };

_$FetchTreksResponseModelImpl _$$FetchTreksResponseModelImplFromJson(
        Map<String, dynamic> json) =>
    _$FetchTreksResponseModelImpl(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      searchContext: json['search_context'] == null
          ? null
          : SearchContextModel.fromJson(
              json['search_context'] as Map<String, dynamic>),
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
      'search_context': instance.searchContext,
      'data': instance.data,
      'count': instance.count,
    };

_$SearchContextModelImpl _$$SearchContextModelImplFromJson(
        Map<String, dynamic> json) =>
    _$SearchContextModelImpl(
      from: json['from'] as String?,
      to: json['to'] as String?,
      selectedDate: json['selected_date'],
      weekendMode: json['weekend_mode'] as bool?,
      weekendDates: (json['weekend_dates'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$$SearchContextModelImplToJson(
        _$SearchContextModelImpl instance) =>
    <String, dynamic>{
      'from': instance.from,
      'to': instance.to,
      'selected_date': instance.selectedDate,
      'weekend_mode': instance.weekendMode,
      'weekend_dates': instance.weekendDates,
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
      imageUrl: json['imageUrl'] as String?,
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
      'imageUrl': instance.imageUrl,
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
