// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'validate_version_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ValidateVersionResponseModelImpl _$$ValidateVersionResponseModelImplFromJson(
        Map<String, dynamic> json) =>
    _$ValidateVersionResponseModelImpl(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: json['data'] == null
          ? null
          : ValidateDataModel.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$ValidateVersionResponseModelImplToJson(
        _$ValidateVersionResponseModelImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

_$ValidateDataModelImpl _$$ValidateDataModelImplFromJson(
        Map<String, dynamic> json) =>
    _$ValidateDataModelImpl(
      currentVersion: json['current_version'] as String?,
      latestVersion: json['latest_version'] as String?,
      updateAvailable: json['update_available'] as bool?,
      releaseNotes: json['release_notes'],
      releaseDate: json['release_date'],
      platform: json['platform'] as String?,
    );

Map<String, dynamic> _$$ValidateDataModelImplToJson(
        _$ValidateDataModelImpl instance) =>
    <String, dynamic>{
      'current_version': instance.currentVersion,
      'latest_version': instance.latestVersion,
      'update_available': instance.updateAvailable,
      'release_notes': instance.releaseNotes,
      'release_date': instance.releaseDate,
      'platform': instance.platform,
    };
