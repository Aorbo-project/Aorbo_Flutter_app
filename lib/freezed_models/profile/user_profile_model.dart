import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile_model.freezed.dart';
part 'user_profile_model.g.dart';

class PaginationModel<T> {
  T data;
  bool isLoading;
  bool isPaginationCompleted;
  int page;
  String error;

  PaginationModel({
    required this.data,
    required this.isLoading,
    required this.isPaginationCompleted,
    required this.page,
    required this.error,
  });
}

@freezed
class UserProfileModal with _$UserProfileModal {
  const factory UserProfileModal({bool? success, UserProfileData? data}) =
      _UserProfileModal;

  factory UserProfileModal.fromJson(Map<String, dynamic> json) =>
      _$UserProfileModalFromJson(json);
}

@freezed
class UserProfileData with _$UserProfileData {
  const factory UserProfileData({Customer? customer}) = _UserProfileData;

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
    // 🔥 FIX: Added @JsonKey to safely parse IDs even if the API sends them as Strings
    @JsonKey(fromJson: _toInt) int? id,
    @JsonKey(fromJson: _toInt) int? customerId,
    String? name,
    @JsonKey(fromJson: _toInt) int? age,
    String? gender,
    String? phone,
    String? email,
    String? dateOfBirth,
    bool? isActive,
    dynamic createdAt,
    dynamic updatedAt,
  }) = _Traveler;

  factory Traveler.fromJson(Map<String, dynamic> json) =>
      _$TravelerFromJson(json);
}

// 🔽 ADD THIS HELPER FUNCTION AT THE BOTTOM OF THE FILE (Outside the classes)
int? _toInt(dynamic val) {
  if (val == null) return null;
  if (val is int) return val;
  if (val is String) return int.tryParse(val);
  if (val is double) return val.toInt();
  return null;
}

@freezed
class UserState with _$UserState {
  const factory UserState({int? id, String? name}) = _UserState;

  factory UserState.fromJson(Map<String, dynamic> json) =>
      _$UserStateFromJson(json);
}
