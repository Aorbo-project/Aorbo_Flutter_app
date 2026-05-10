// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'validate_version_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

ValidateVersionResponseModel _$ValidateVersionResponseModelFromJson(
    Map<String, dynamic> json) {
  return _ValidateVersionResponseModel.fromJson(json);
}

/// @nodoc
mixin _$ValidateVersionResponseModel {
  bool? get success => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;
  ValidateDataModel? get data => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ValidateVersionResponseModelCopyWith<ValidateVersionResponseModel>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ValidateVersionResponseModelCopyWith<$Res> {
  factory $ValidateVersionResponseModelCopyWith(
          ValidateVersionResponseModel value,
          $Res Function(ValidateVersionResponseModel) then) =
      _$ValidateVersionResponseModelCopyWithImpl<$Res,
          ValidateVersionResponseModel>;
  @useResult
  $Res call({bool? success, String? message, ValidateDataModel? data});

  $ValidateDataModelCopyWith<$Res>? get data;
}

/// @nodoc
class _$ValidateVersionResponseModelCopyWithImpl<$Res,
        $Val extends ValidateVersionResponseModel>
    implements $ValidateVersionResponseModelCopyWith<$Res> {
  _$ValidateVersionResponseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = freezed,
    Object? message = freezed,
    Object? data = freezed,
  }) {
    return _then(_value.copyWith(
      success: freezed == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool?,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      data: freezed == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as ValidateDataModel?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $ValidateDataModelCopyWith<$Res>? get data {
    if (_value.data == null) {
      return null;
    }

    return $ValidateDataModelCopyWith<$Res>(_value.data!, (value) {
      return _then(_value.copyWith(data: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ValidateVersionResponseModelImplCopyWith<$Res>
    implements $ValidateVersionResponseModelCopyWith<$Res> {
  factory _$$ValidateVersionResponseModelImplCopyWith(
          _$ValidateVersionResponseModelImpl value,
          $Res Function(_$ValidateVersionResponseModelImpl) then) =
      __$$ValidateVersionResponseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool? success, String? message, ValidateDataModel? data});

  @override
  $ValidateDataModelCopyWith<$Res>? get data;
}

/// @nodoc
class __$$ValidateVersionResponseModelImplCopyWithImpl<$Res>
    extends _$ValidateVersionResponseModelCopyWithImpl<$Res,
        _$ValidateVersionResponseModelImpl>
    implements _$$ValidateVersionResponseModelImplCopyWith<$Res> {
  __$$ValidateVersionResponseModelImplCopyWithImpl(
      _$ValidateVersionResponseModelImpl _value,
      $Res Function(_$ValidateVersionResponseModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = freezed,
    Object? message = freezed,
    Object? data = freezed,
  }) {
    return _then(_$ValidateVersionResponseModelImpl(
      success: freezed == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool?,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      data: freezed == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as ValidateDataModel?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ValidateVersionResponseModelImpl
    implements _ValidateVersionResponseModel {
  const _$ValidateVersionResponseModelImpl(
      {this.success, this.message, this.data});

  factory _$ValidateVersionResponseModelImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$ValidateVersionResponseModelImplFromJson(json);

  @override
  final bool? success;
  @override
  final String? message;
  @override
  final ValidateDataModel? data;

  @override
  String toString() {
    return 'ValidateVersionResponseModel(success: $success, message: $message, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ValidateVersionResponseModelImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.data, data) || other.data == data));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, success, message, data);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ValidateVersionResponseModelImplCopyWith<
          _$ValidateVersionResponseModelImpl>
      get copyWith => __$$ValidateVersionResponseModelImplCopyWithImpl<
          _$ValidateVersionResponseModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ValidateVersionResponseModelImplToJson(
      this,
    );
  }
}

abstract class _ValidateVersionResponseModel
    implements ValidateVersionResponseModel {
  const factory _ValidateVersionResponseModel(
      {final bool? success,
      final String? message,
      final ValidateDataModel? data}) = _$ValidateVersionResponseModelImpl;

  factory _ValidateVersionResponseModel.fromJson(Map<String, dynamic> json) =
      _$ValidateVersionResponseModelImpl.fromJson;

  @override
  bool? get success;
  @override
  String? get message;
  @override
  ValidateDataModel? get data;
  @override
  @JsonKey(ignore: true)
  _$$ValidateVersionResponseModelImplCopyWith<
          _$ValidateVersionResponseModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}

ValidateDataModel _$ValidateDataModelFromJson(Map<String, dynamic> json) {
  return _ValidateDataModel.fromJson(json);
}

/// @nodoc
mixin _$ValidateDataModel {
  @JsonKey(name: "current_version")
  String? get currentVersion => throw _privateConstructorUsedError;
  @JsonKey(name: "latest_version")
  String? get latestVersion => throw _privateConstructorUsedError;
  @JsonKey(name: "update_available")
  bool? get updateAvailable => throw _privateConstructorUsedError;
  @JsonKey(name: "release_notes")
  dynamic get releaseNotes => throw _privateConstructorUsedError;
  @JsonKey(name: "release_date")
  dynamic get releaseDate => throw _privateConstructorUsedError;
  String? get platform => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ValidateDataModelCopyWith<ValidateDataModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ValidateDataModelCopyWith<$Res> {
  factory $ValidateDataModelCopyWith(
          ValidateDataModel value, $Res Function(ValidateDataModel) then) =
      _$ValidateDataModelCopyWithImpl<$Res, ValidateDataModel>;
  @useResult
  $Res call(
      {@JsonKey(name: "current_version") String? currentVersion,
      @JsonKey(name: "latest_version") String? latestVersion,
      @JsonKey(name: "update_available") bool? updateAvailable,
      @JsonKey(name: "release_notes") dynamic releaseNotes,
      @JsonKey(name: "release_date") dynamic releaseDate,
      String? platform});
}

/// @nodoc
class _$ValidateDataModelCopyWithImpl<$Res, $Val extends ValidateDataModel>
    implements $ValidateDataModelCopyWith<$Res> {
  _$ValidateDataModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentVersion = freezed,
    Object? latestVersion = freezed,
    Object? updateAvailable = freezed,
    Object? releaseNotes = freezed,
    Object? releaseDate = freezed,
    Object? platform = freezed,
  }) {
    return _then(_value.copyWith(
      currentVersion: freezed == currentVersion
          ? _value.currentVersion
          : currentVersion // ignore: cast_nullable_to_non_nullable
              as String?,
      latestVersion: freezed == latestVersion
          ? _value.latestVersion
          : latestVersion // ignore: cast_nullable_to_non_nullable
              as String?,
      updateAvailable: freezed == updateAvailable
          ? _value.updateAvailable
          : updateAvailable // ignore: cast_nullable_to_non_nullable
              as bool?,
      releaseNotes: freezed == releaseNotes
          ? _value.releaseNotes
          : releaseNotes // ignore: cast_nullable_to_non_nullable
              as dynamic,
      releaseDate: freezed == releaseDate
          ? _value.releaseDate
          : releaseDate // ignore: cast_nullable_to_non_nullable
              as dynamic,
      platform: freezed == platform
          ? _value.platform
          : platform // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ValidateDataModelImplCopyWith<$Res>
    implements $ValidateDataModelCopyWith<$Res> {
  factory _$$ValidateDataModelImplCopyWith(_$ValidateDataModelImpl value,
          $Res Function(_$ValidateDataModelImpl) then) =
      __$$ValidateDataModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: "current_version") String? currentVersion,
      @JsonKey(name: "latest_version") String? latestVersion,
      @JsonKey(name: "update_available") bool? updateAvailable,
      @JsonKey(name: "release_notes") dynamic releaseNotes,
      @JsonKey(name: "release_date") dynamic releaseDate,
      String? platform});
}

/// @nodoc
class __$$ValidateDataModelImplCopyWithImpl<$Res>
    extends _$ValidateDataModelCopyWithImpl<$Res, _$ValidateDataModelImpl>
    implements _$$ValidateDataModelImplCopyWith<$Res> {
  __$$ValidateDataModelImplCopyWithImpl(_$ValidateDataModelImpl _value,
      $Res Function(_$ValidateDataModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentVersion = freezed,
    Object? latestVersion = freezed,
    Object? updateAvailable = freezed,
    Object? releaseNotes = freezed,
    Object? releaseDate = freezed,
    Object? platform = freezed,
  }) {
    return _then(_$ValidateDataModelImpl(
      currentVersion: freezed == currentVersion
          ? _value.currentVersion
          : currentVersion // ignore: cast_nullable_to_non_nullable
              as String?,
      latestVersion: freezed == latestVersion
          ? _value.latestVersion
          : latestVersion // ignore: cast_nullable_to_non_nullable
              as String?,
      updateAvailable: freezed == updateAvailable
          ? _value.updateAvailable
          : updateAvailable // ignore: cast_nullable_to_non_nullable
              as bool?,
      releaseNotes: freezed == releaseNotes
          ? _value.releaseNotes
          : releaseNotes // ignore: cast_nullable_to_non_nullable
              as dynamic,
      releaseDate: freezed == releaseDate
          ? _value.releaseDate
          : releaseDate // ignore: cast_nullable_to_non_nullable
              as dynamic,
      platform: freezed == platform
          ? _value.platform
          : platform // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ValidateDataModelImpl implements _ValidateDataModel {
  const _$ValidateDataModelImpl(
      {@JsonKey(name: "current_version") this.currentVersion,
      @JsonKey(name: "latest_version") this.latestVersion,
      @JsonKey(name: "update_available") this.updateAvailable,
      @JsonKey(name: "release_notes") this.releaseNotes,
      @JsonKey(name: "release_date") this.releaseDate,
      this.platform});

  factory _$ValidateDataModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ValidateDataModelImplFromJson(json);

  @override
  @JsonKey(name: "current_version")
  final String? currentVersion;
  @override
  @JsonKey(name: "latest_version")
  final String? latestVersion;
  @override
  @JsonKey(name: "update_available")
  final bool? updateAvailable;
  @override
  @JsonKey(name: "release_notes")
  final dynamic releaseNotes;
  @override
  @JsonKey(name: "release_date")
  final dynamic releaseDate;
  @override
  final String? platform;

  @override
  String toString() {
    return 'ValidateDataModel(currentVersion: $currentVersion, latestVersion: $latestVersion, updateAvailable: $updateAvailable, releaseNotes: $releaseNotes, releaseDate: $releaseDate, platform: $platform)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ValidateDataModelImpl &&
            (identical(other.currentVersion, currentVersion) ||
                other.currentVersion == currentVersion) &&
            (identical(other.latestVersion, latestVersion) ||
                other.latestVersion == latestVersion) &&
            (identical(other.updateAvailable, updateAvailable) ||
                other.updateAvailable == updateAvailable) &&
            const DeepCollectionEquality()
                .equals(other.releaseNotes, releaseNotes) &&
            const DeepCollectionEquality()
                .equals(other.releaseDate, releaseDate) &&
            (identical(other.platform, platform) ||
                other.platform == platform));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      currentVersion,
      latestVersion,
      updateAvailable,
      const DeepCollectionEquality().hash(releaseNotes),
      const DeepCollectionEquality().hash(releaseDate),
      platform);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ValidateDataModelImplCopyWith<_$ValidateDataModelImpl> get copyWith =>
      __$$ValidateDataModelImplCopyWithImpl<_$ValidateDataModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ValidateDataModelImplToJson(
      this,
    );
  }
}

abstract class _ValidateDataModel implements ValidateDataModel {
  const factory _ValidateDataModel(
      {@JsonKey(name: "current_version") final String? currentVersion,
      @JsonKey(name: "latest_version") final String? latestVersion,
      @JsonKey(name: "update_available") final bool? updateAvailable,
      @JsonKey(name: "release_notes") final dynamic releaseNotes,
      @JsonKey(name: "release_date") final dynamic releaseDate,
      final String? platform}) = _$ValidateDataModelImpl;

  factory _ValidateDataModel.fromJson(Map<String, dynamic> json) =
      _$ValidateDataModelImpl.fromJson;

  @override
  @JsonKey(name: "current_version")
  String? get currentVersion;
  @override
  @JsonKey(name: "latest_version")
  String? get latestVersion;
  @override
  @JsonKey(name: "update_available")
  bool? get updateAvailable;
  @override
  @JsonKey(name: "release_notes")
  dynamic get releaseNotes;
  @override
  @JsonKey(name: "release_date")
  dynamic get releaseDate;
  @override
  String? get platform;
  @override
  @JsonKey(ignore: true)
  _$$ValidateDataModelImplCopyWith<_$ValidateDataModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
