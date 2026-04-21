// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_profile_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

UserProfileModal _$UserProfileModalFromJson(Map<String, dynamic> json) {
  return _UserProfileModal.fromJson(json);
}

/// @nodoc
mixin _$UserProfileModal {
  bool? get success => throw _privateConstructorUsedError;
  UserProfileData? get data => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UserProfileModalCopyWith<UserProfileModal> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserProfileModalCopyWith<$Res> {
  factory $UserProfileModalCopyWith(
          UserProfileModal value, $Res Function(UserProfileModal) then) =
      _$UserProfileModalCopyWithImpl<$Res, UserProfileModal>;
  @useResult
  $Res call({bool? success, UserProfileData? data});

  $UserProfileDataCopyWith<$Res>? get data;
}

/// @nodoc
class _$UserProfileModalCopyWithImpl<$Res, $Val extends UserProfileModal>
    implements $UserProfileModalCopyWith<$Res> {
  _$UserProfileModalCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = freezed,
    Object? data = freezed,
  }) {
    return _then(_value.copyWith(
      success: freezed == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool?,
      data: freezed == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as UserProfileData?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $UserProfileDataCopyWith<$Res>? get data {
    if (_value.data == null) {
      return null;
    }

    return $UserProfileDataCopyWith<$Res>(_value.data!, (value) {
      return _then(_value.copyWith(data: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$UserProfileModalImplCopyWith<$Res>
    implements $UserProfileModalCopyWith<$Res> {
  factory _$$UserProfileModalImplCopyWith(_$UserProfileModalImpl value,
          $Res Function(_$UserProfileModalImpl) then) =
      __$$UserProfileModalImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool? success, UserProfileData? data});

  @override
  $UserProfileDataCopyWith<$Res>? get data;
}

/// @nodoc
class __$$UserProfileModalImplCopyWithImpl<$Res>
    extends _$UserProfileModalCopyWithImpl<$Res, _$UserProfileModalImpl>
    implements _$$UserProfileModalImplCopyWith<$Res> {
  __$$UserProfileModalImplCopyWithImpl(_$UserProfileModalImpl _value,
      $Res Function(_$UserProfileModalImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = freezed,
    Object? data = freezed,
  }) {
    return _then(_$UserProfileModalImpl(
      success: freezed == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool?,
      data: freezed == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as UserProfileData?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserProfileModalImpl implements _UserProfileModal {
  const _$UserProfileModalImpl({this.success, this.data});

  factory _$UserProfileModalImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserProfileModalImplFromJson(json);

  @override
  final bool? success;
  @override
  final UserProfileData? data;

  @override
  String toString() {
    return 'UserProfileModal(success: $success, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserProfileModalImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.data, data) || other.data == data));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, success, data);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserProfileModalImplCopyWith<_$UserProfileModalImpl> get copyWith =>
      __$$UserProfileModalImplCopyWithImpl<_$UserProfileModalImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserProfileModalImplToJson(
      this,
    );
  }
}

abstract class _UserProfileModal implements UserProfileModal {
  const factory _UserProfileModal(
      {final bool? success,
      final UserProfileData? data}) = _$UserProfileModalImpl;

  factory _UserProfileModal.fromJson(Map<String, dynamic> json) =
      _$UserProfileModalImpl.fromJson;

  @override
  bool? get success;
  @override
  UserProfileData? get data;
  @override
  @JsonKey(ignore: true)
  _$$UserProfileModalImplCopyWith<_$UserProfileModalImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserProfileData _$UserProfileDataFromJson(Map<String, dynamic> json) {
  return _UserProfileData.fromJson(json);
}

/// @nodoc
mixin _$UserProfileData {
  Customer? get customer => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UserProfileDataCopyWith<UserProfileData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserProfileDataCopyWith<$Res> {
  factory $UserProfileDataCopyWith(
          UserProfileData value, $Res Function(UserProfileData) then) =
      _$UserProfileDataCopyWithImpl<$Res, UserProfileData>;
  @useResult
  $Res call({Customer? customer});

  $CustomerCopyWith<$Res>? get customer;
}

/// @nodoc
class _$UserProfileDataCopyWithImpl<$Res, $Val extends UserProfileData>
    implements $UserProfileDataCopyWith<$Res> {
  _$UserProfileDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? customer = freezed,
  }) {
    return _then(_value.copyWith(
      customer: freezed == customer
          ? _value.customer
          : customer // ignore: cast_nullable_to_non_nullable
              as Customer?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $CustomerCopyWith<$Res>? get customer {
    if (_value.customer == null) {
      return null;
    }

    return $CustomerCopyWith<$Res>(_value.customer!, (value) {
      return _then(_value.copyWith(customer: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$UserProfileDataImplCopyWith<$Res>
    implements $UserProfileDataCopyWith<$Res> {
  factory _$$UserProfileDataImplCopyWith(_$UserProfileDataImpl value,
          $Res Function(_$UserProfileDataImpl) then) =
      __$$UserProfileDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Customer? customer});

  @override
  $CustomerCopyWith<$Res>? get customer;
}

/// @nodoc
class __$$UserProfileDataImplCopyWithImpl<$Res>
    extends _$UserProfileDataCopyWithImpl<$Res, _$UserProfileDataImpl>
    implements _$$UserProfileDataImplCopyWith<$Res> {
  __$$UserProfileDataImplCopyWithImpl(
      _$UserProfileDataImpl _value, $Res Function(_$UserProfileDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? customer = freezed,
  }) {
    return _then(_$UserProfileDataImpl(
      customer: freezed == customer
          ? _value.customer
          : customer // ignore: cast_nullable_to_non_nullable
              as Customer?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserProfileDataImpl implements _UserProfileData {
  const _$UserProfileDataImpl({this.customer});

  factory _$UserProfileDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserProfileDataImplFromJson(json);

  @override
  final Customer? customer;

  @override
  String toString() {
    return 'UserProfileData(customer: $customer)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserProfileDataImpl &&
            (identical(other.customer, customer) ||
                other.customer == customer));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, customer);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserProfileDataImplCopyWith<_$UserProfileDataImpl> get copyWith =>
      __$$UserProfileDataImplCopyWithImpl<_$UserProfileDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserProfileDataImplToJson(
      this,
    );
  }
}

abstract class _UserProfileData implements UserProfileData {
  const factory _UserProfileData({final Customer? customer}) =
      _$UserProfileDataImpl;

  factory _UserProfileData.fromJson(Map<String, dynamic> json) =
      _$UserProfileDataImpl.fromJson;

  @override
  Customer? get customer;
  @override
  @JsonKey(ignore: true)
  _$$UserProfileDataImplCopyWith<_$UserProfileDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Customer _$CustomerFromJson(Map<String, dynamic> json) {
  return _Customer.fromJson(json);
}

/// @nodoc
mixin _$Customer {
  int? get id => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  String? get dateOfBirth => throw _privateConstructorUsedError;
  String? get emergencyContact => throw _privateConstructorUsedError;
  bool? get profileCompleted => throw _privateConstructorUsedError;
  UserState? get city => throw _privateConstructorUsedError;
  UserState? get state => throw _privateConstructorUsedError;
  List<Traveler>? get travelers => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CustomerCopyWith<Customer> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CustomerCopyWith<$Res> {
  factory $CustomerCopyWith(Customer value, $Res Function(Customer) then) =
      _$CustomerCopyWithImpl<$Res, Customer>;
  @useResult
  $Res call(
      {int? id,
      String? phone,
      String? name,
      String? email,
      String? dateOfBirth,
      String? emergencyContact,
      bool? profileCompleted,
      UserState? city,
      UserState? state,
      List<Traveler>? travelers});

  $UserStateCopyWith<$Res>? get city;
  $UserStateCopyWith<$Res>? get state;
}

/// @nodoc
class _$CustomerCopyWithImpl<$Res, $Val extends Customer>
    implements $CustomerCopyWith<$Res> {
  _$CustomerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? phone = freezed,
    Object? name = freezed,
    Object? email = freezed,
    Object? dateOfBirth = freezed,
    Object? emergencyContact = freezed,
    Object? profileCompleted = freezed,
    Object? city = freezed,
    Object? state = freezed,
    Object? travelers = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      dateOfBirth: freezed == dateOfBirth
          ? _value.dateOfBirth
          : dateOfBirth // ignore: cast_nullable_to_non_nullable
              as String?,
      emergencyContact: freezed == emergencyContact
          ? _value.emergencyContact
          : emergencyContact // ignore: cast_nullable_to_non_nullable
              as String?,
      profileCompleted: freezed == profileCompleted
          ? _value.profileCompleted
          : profileCompleted // ignore: cast_nullable_to_non_nullable
              as bool?,
      city: freezed == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as UserState?,
      state: freezed == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as UserState?,
      travelers: freezed == travelers
          ? _value.travelers
          : travelers // ignore: cast_nullable_to_non_nullable
              as List<Traveler>?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $UserStateCopyWith<$Res>? get city {
    if (_value.city == null) {
      return null;
    }

    return $UserStateCopyWith<$Res>(_value.city!, (value) {
      return _then(_value.copyWith(city: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $UserStateCopyWith<$Res>? get state {
    if (_value.state == null) {
      return null;
    }

    return $UserStateCopyWith<$Res>(_value.state!, (value) {
      return _then(_value.copyWith(state: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CustomerImplCopyWith<$Res>
    implements $CustomerCopyWith<$Res> {
  factory _$$CustomerImplCopyWith(
          _$CustomerImpl value, $Res Function(_$CustomerImpl) then) =
      __$$CustomerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? id,
      String? phone,
      String? name,
      String? email,
      String? dateOfBirth,
      String? emergencyContact,
      bool? profileCompleted,
      UserState? city,
      UserState? state,
      List<Traveler>? travelers});

  @override
  $UserStateCopyWith<$Res>? get city;
  @override
  $UserStateCopyWith<$Res>? get state;
}

/// @nodoc
class __$$CustomerImplCopyWithImpl<$Res>
    extends _$CustomerCopyWithImpl<$Res, _$CustomerImpl>
    implements _$$CustomerImplCopyWith<$Res> {
  __$$CustomerImplCopyWithImpl(
      _$CustomerImpl _value, $Res Function(_$CustomerImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? phone = freezed,
    Object? name = freezed,
    Object? email = freezed,
    Object? dateOfBirth = freezed,
    Object? emergencyContact = freezed,
    Object? profileCompleted = freezed,
    Object? city = freezed,
    Object? state = freezed,
    Object? travelers = freezed,
  }) {
    return _then(_$CustomerImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      dateOfBirth: freezed == dateOfBirth
          ? _value.dateOfBirth
          : dateOfBirth // ignore: cast_nullable_to_non_nullable
              as String?,
      emergencyContact: freezed == emergencyContact
          ? _value.emergencyContact
          : emergencyContact // ignore: cast_nullable_to_non_nullable
              as String?,
      profileCompleted: freezed == profileCompleted
          ? _value.profileCompleted
          : profileCompleted // ignore: cast_nullable_to_non_nullable
              as bool?,
      city: freezed == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as UserState?,
      state: freezed == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as UserState?,
      travelers: freezed == travelers
          ? _value._travelers
          : travelers // ignore: cast_nullable_to_non_nullable
              as List<Traveler>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CustomerImpl implements _Customer {
  const _$CustomerImpl(
      {this.id,
      this.phone,
      this.name,
      this.email,
      this.dateOfBirth,
      this.emergencyContact,
      this.profileCompleted,
      this.city,
      this.state,
      final List<Traveler>? travelers})
      : _travelers = travelers;

  factory _$CustomerImpl.fromJson(Map<String, dynamic> json) =>
      _$$CustomerImplFromJson(json);

  @override
  final int? id;
  @override
  final String? phone;
  @override
  final String? name;
  @override
  final String? email;
  @override
  final String? dateOfBirth;
  @override
  final String? emergencyContact;
  @override
  final bool? profileCompleted;
  @override
  final UserState? city;
  @override
  final UserState? state;
  final List<Traveler>? _travelers;
  @override
  List<Traveler>? get travelers {
    final value = _travelers;
    if (value == null) return null;
    if (_travelers is EqualUnmodifiableListView) return _travelers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'Customer(id: $id, phone: $phone, name: $name, email: $email, dateOfBirth: $dateOfBirth, emergencyContact: $emergencyContact, profileCompleted: $profileCompleted, city: $city, state: $state, travelers: $travelers)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomerImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.dateOfBirth, dateOfBirth) ||
                other.dateOfBirth == dateOfBirth) &&
            (identical(other.emergencyContact, emergencyContact) ||
                other.emergencyContact == emergencyContact) &&
            (identical(other.profileCompleted, profileCompleted) ||
                other.profileCompleted == profileCompleted) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.state, state) || other.state == state) &&
            const DeepCollectionEquality()
                .equals(other._travelers, _travelers));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      phone,
      name,
      email,
      dateOfBirth,
      emergencyContact,
      profileCompleted,
      city,
      state,
      const DeepCollectionEquality().hash(_travelers));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomerImplCopyWith<_$CustomerImpl> get copyWith =>
      __$$CustomerImplCopyWithImpl<_$CustomerImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CustomerImplToJson(
      this,
    );
  }
}

abstract class _Customer implements Customer {
  const factory _Customer(
      {final int? id,
      final String? phone,
      final String? name,
      final String? email,
      final String? dateOfBirth,
      final String? emergencyContact,
      final bool? profileCompleted,
      final UserState? city,
      final UserState? state,
      final List<Traveler>? travelers}) = _$CustomerImpl;

  factory _Customer.fromJson(Map<String, dynamic> json) =
      _$CustomerImpl.fromJson;

  @override
  int? get id;
  @override
  String? get phone;
  @override
  String? get name;
  @override
  String? get email;
  @override
  String? get dateOfBirth;
  @override
  String? get emergencyContact;
  @override
  bool? get profileCompleted;
  @override
  UserState? get city;
  @override
  UserState? get state;
  @override
  List<Traveler>? get travelers;
  @override
  @JsonKey(ignore: true)
  _$$CustomerImplCopyWith<_$CustomerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Traveler _$TravelerFromJson(Map<String, dynamic> json) {
  return _Traveler.fromJson(json);
}

/// @nodoc
mixin _$Traveler {
  int? get id => throw _privateConstructorUsedError;
  int? get customerId => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  int? get age => throw _privateConstructorUsedError;
  String? get gender => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  String? get dateOfBirth => throw _privateConstructorUsedError;
  bool? get isActive => throw _privateConstructorUsedError;
  dynamic get createdAt => throw _privateConstructorUsedError;
  dynamic get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TravelerCopyWith<Traveler> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TravelerCopyWith<$Res> {
  factory $TravelerCopyWith(Traveler value, $Res Function(Traveler) then) =
      _$TravelerCopyWithImpl<$Res, Traveler>;
  @useResult
  $Res call(
      {int? id,
      int? customerId,
      String? name,
      int? age,
      String? gender,
      String? phone,
      String? email,
      String? dateOfBirth,
      bool? isActive,
      dynamic createdAt,
      dynamic updatedAt});
}

/// @nodoc
class _$TravelerCopyWithImpl<$Res, $Val extends Traveler>
    implements $TravelerCopyWith<$Res> {
  _$TravelerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? customerId = freezed,
    Object? name = freezed,
    Object? age = freezed,
    Object? gender = freezed,
    Object? phone = freezed,
    Object? email = freezed,
    Object? dateOfBirth = freezed,
    Object? isActive = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      customerId: freezed == customerId
          ? _value.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as int?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      age: freezed == age
          ? _value.age
          : age // ignore: cast_nullable_to_non_nullable
              as int?,
      gender: freezed == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      dateOfBirth: freezed == dateOfBirth
          ? _value.dateOfBirth
          : dateOfBirth // ignore: cast_nullable_to_non_nullable
              as String?,
      isActive: freezed == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as dynamic,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TravelerImplCopyWith<$Res>
    implements $TravelerCopyWith<$Res> {
  factory _$$TravelerImplCopyWith(
          _$TravelerImpl value, $Res Function(_$TravelerImpl) then) =
      __$$TravelerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? id,
      int? customerId,
      String? name,
      int? age,
      String? gender,
      String? phone,
      String? email,
      String? dateOfBirth,
      bool? isActive,
      dynamic createdAt,
      dynamic updatedAt});
}

/// @nodoc
class __$$TravelerImplCopyWithImpl<$Res>
    extends _$TravelerCopyWithImpl<$Res, _$TravelerImpl>
    implements _$$TravelerImplCopyWith<$Res> {
  __$$TravelerImplCopyWithImpl(
      _$TravelerImpl _value, $Res Function(_$TravelerImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? customerId = freezed,
    Object? name = freezed,
    Object? age = freezed,
    Object? gender = freezed,
    Object? phone = freezed,
    Object? email = freezed,
    Object? dateOfBirth = freezed,
    Object? isActive = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$TravelerImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      customerId: freezed == customerId
          ? _value.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as int?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      age: freezed == age
          ? _value.age
          : age // ignore: cast_nullable_to_non_nullable
              as int?,
      gender: freezed == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      dateOfBirth: freezed == dateOfBirth
          ? _value.dateOfBirth
          : dateOfBirth // ignore: cast_nullable_to_non_nullable
              as String?,
      isActive: freezed == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as dynamic,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TravelerImpl implements _Traveler {
  const _$TravelerImpl(
      {this.id,
      this.customerId,
      this.name,
      this.age,
      this.gender,
      this.phone,
      this.email,
      this.dateOfBirth,
      this.isActive,
      this.createdAt,
      this.updatedAt});

  factory _$TravelerImpl.fromJson(Map<String, dynamic> json) =>
      _$$TravelerImplFromJson(json);

  @override
  final int? id;
  @override
  final int? customerId;
  @override
  final String? name;
  @override
  final int? age;
  @override
  final String? gender;
  @override
  final String? phone;
  @override
  final String? email;
  @override
  final String? dateOfBirth;
  @override
  final bool? isActive;
  @override
  final dynamic createdAt;
  @override
  final dynamic updatedAt;

  @override
  String toString() {
    return 'Traveler(id: $id, customerId: $customerId, name: $name, age: $age, gender: $gender, phone: $phone, email: $email, dateOfBirth: $dateOfBirth, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TravelerImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.age, age) || other.age == age) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.dateOfBirth, dateOfBirth) ||
                other.dateOfBirth == dateOfBirth) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            const DeepCollectionEquality().equals(other.createdAt, createdAt) &&
            const DeepCollectionEquality().equals(other.updatedAt, updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      customerId,
      name,
      age,
      gender,
      phone,
      email,
      dateOfBirth,
      isActive,
      const DeepCollectionEquality().hash(createdAt),
      const DeepCollectionEquality().hash(updatedAt));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TravelerImplCopyWith<_$TravelerImpl> get copyWith =>
      __$$TravelerImplCopyWithImpl<_$TravelerImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TravelerImplToJson(
      this,
    );
  }
}

abstract class _Traveler implements Traveler {
  const factory _Traveler(
      {final int? id,
      final int? customerId,
      final String? name,
      final int? age,
      final String? gender,
      final String? phone,
      final String? email,
      final String? dateOfBirth,
      final bool? isActive,
      final dynamic createdAt,
      final dynamic updatedAt}) = _$TravelerImpl;

  factory _Traveler.fromJson(Map<String, dynamic> json) =
      _$TravelerImpl.fromJson;

  @override
  int? get id;
  @override
  int? get customerId;
  @override
  String? get name;
  @override
  int? get age;
  @override
  String? get gender;
  @override
  String? get phone;
  @override
  String? get email;
  @override
  String? get dateOfBirth;
  @override
  bool? get isActive;
  @override
  dynamic get createdAt;
  @override
  dynamic get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$TravelerImplCopyWith<_$TravelerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserState _$UserStateFromJson(Map<String, dynamic> json) {
  return _UserState.fromJson(json);
}

/// @nodoc
mixin _$UserState {
  int? get id => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UserStateCopyWith<UserState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserStateCopyWith<$Res> {
  factory $UserStateCopyWith(UserState value, $Res Function(UserState) then) =
      _$UserStateCopyWithImpl<$Res, UserState>;
  @useResult
  $Res call({int? id, String? name});
}

/// @nodoc
class _$UserStateCopyWithImpl<$Res, $Val extends UserState>
    implements $UserStateCopyWith<$Res> {
  _$UserStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserStateImplCopyWith<$Res>
    implements $UserStateCopyWith<$Res> {
  factory _$$UserStateImplCopyWith(
          _$UserStateImpl value, $Res Function(_$UserStateImpl) then) =
      __$$UserStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int? id, String? name});
}

/// @nodoc
class __$$UserStateImplCopyWithImpl<$Res>
    extends _$UserStateCopyWithImpl<$Res, _$UserStateImpl>
    implements _$$UserStateImplCopyWith<$Res> {
  __$$UserStateImplCopyWithImpl(
      _$UserStateImpl _value, $Res Function(_$UserStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
  }) {
    return _then(_$UserStateImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserStateImpl implements _UserState {
  const _$UserStateImpl({this.id, this.name});

  factory _$UserStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserStateImplFromJson(json);

  @override
  final int? id;
  @override
  final String? name;

  @override
  String toString() {
    return 'UserState(id: $id, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserStateImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, name);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserStateImplCopyWith<_$UserStateImpl> get copyWith =>
      __$$UserStateImplCopyWithImpl<_$UserStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserStateImplToJson(
      this,
    );
  }
}

abstract class _UserState implements UserState {
  const factory _UserState({final int? id, final String? name}) =
      _$UserStateImpl;

  factory _UserState.fromJson(Map<String, dynamic> json) =
      _$UserStateImpl.fromJson;

  @override
  int? get id;
  @override
  String? get name;
  @override
  @JsonKey(ignore: true)
  _$$UserStateImplCopyWith<_$UserStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
