// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserProfileModalImpl _$$UserProfileModalImplFromJson(
        Map<String, dynamic> json) =>
    _$UserProfileModalImpl(
      success: json['success'] as bool?,
      data: json['data'] == null
          ? null
          : UserProfileData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$UserProfileModalImplToJson(
        _$UserProfileModalImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'data': instance.data,
    };

_$UserProfileDataImpl _$$UserProfileDataImplFromJson(
        Map<String, dynamic> json) =>
    _$UserProfileDataImpl(
      customer: json['customer'] == null
          ? null
          : Customer.fromJson(json['customer'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$UserProfileDataImplToJson(
        _$UserProfileDataImpl instance) =>
    <String, dynamic>{
      'customer': instance.customer,
    };

_$CustomerImpl _$$CustomerImplFromJson(Map<String, dynamic> json) =>
    _$CustomerImpl(
      id: json['id'] as int?,
      phone: json['phone'] as String?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      emergencyContact: json['emergencyContact'] as String?,
      profileCompleted: json['profileCompleted'] as bool?,
      city: json['city'] == null
          ? null
          : UserState.fromJson(json['city'] as Map<String, dynamic>),
      state: json['state'] == null
          ? null
          : UserState.fromJson(json['state'] as Map<String, dynamic>),
      travelers: (json['travelers'] as List<dynamic>?)
          ?.map((e) => Traveler.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$CustomerImplToJson(_$CustomerImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'phone': instance.phone,
      'name': instance.name,
      'email': instance.email,
      'dateOfBirth': instance.dateOfBirth,
      'emergencyContact': instance.emergencyContact,
      'profileCompleted': instance.profileCompleted,
      'city': instance.city,
      'state': instance.state,
      'travelers': instance.travelers,
    };

_$TravelerImpl _$$TravelerImplFromJson(Map<String, dynamic> json) =>
    _$TravelerImpl(
      id: json['id'] as int?,
      customerId: json['customerId'] as int?,
      name: json['name'] as String?,
      age: json['age'] as int?,
      gender: json['gender'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      isActive: json['isActive'] as bool?,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );

Map<String, dynamic> _$$TravelerImplToJson(_$TravelerImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'customerId': instance.customerId,
      'name': instance.name,
      'age': instance.age,
      'gender': instance.gender,
      'phone': instance.phone,
      'email': instance.email,
      'dateOfBirth': instance.dateOfBirth,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };

_$UserStateImpl _$$UserStateImplFromJson(Map<String, dynamic> json) =>
    _$UserStateImpl(
      id: json['id'] as int?,
      name: json['name'] as String?,
    );

Map<String, dynamic> _$$UserStateImplToJson(_$UserStateImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };
