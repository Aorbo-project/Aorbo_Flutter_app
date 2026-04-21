import 'package:freezed_annotation/freezed_annotation.dart';


part 'user_profile_model.freezed.dart';
part 'user_profile_model.g.dart';

@freezed
class UserProfileModal with _$UserProfileModal {
  const factory UserProfileModal({
    bool? success,
    UserProfileData? data,
  }) = _UserProfileModal;

  factory UserProfileModal.fromJson(Map<String, dynamic> json) =>
      _$UserProfileModalFromJson(json);
}

@freezed
class UserProfileData with _$UserProfileData {
  const factory UserProfileData({
    Customer? customer,
  }) = _UserProfileData;

  factory UserProfileData.fromJson(Map<String, dynamic> json) =>
      _$UserProfileDataFromJson(json);
}

@freezed
class Customer with _$Customer {
  const factory Customer({
    int? id,
    String? phone,
    String? name,
    String? email,
    String? dateOfBirth,
    String? emergencyContact,
    bool? profileCompleted,
    UserState? city,
    UserState? state,
    List<Traveler>? travelers,
  }) = _Customer;

  factory Customer.fromJson(Map<String, dynamic> json) =>
      _$CustomerFromJson(json);
}

@freezed
class Traveler with _$Traveler {
  const factory Traveler({
    int? id,
    int? customerId,
    String? name,
    int? age,
    String? gender,
    String? phone,
    String? email,
    String? dateOfBirth,
    bool? isActive,
    dynamic createdAt,
    dynamic updatedAt
  }) = _Traveler;

  factory Traveler.fromJson(Map<String, dynamic> json) =>
      _$TravelerFromJson(json);
}

@freezed
class UserState with _$UserState {
  const factory UserState({
    int? id,
    String? name,
  }) = _UserState;

  factory UserState.fromJson(Map<String, dynamic> json) =>
      _$UserStateFromJson(json);
}

