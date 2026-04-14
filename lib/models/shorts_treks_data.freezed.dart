// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shorts_treks_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

ShortsTreksDataResponseModel _$ShortsTreksDataResponseModelFromJson(
    Map<String, dynamic> json) {
  return _ShortsTreksDataResponseModel.fromJson(json);
}

/// @nodoc
mixin _$ShortsTreksDataResponseModel {
  bool? get success => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;
  List<ShortsTreksData>? get data => throw _privateConstructorUsedError;
  int? get count => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ShortsTreksDataResponseModelCopyWith<ShortsTreksDataResponseModel>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShortsTreksDataResponseModelCopyWith<$Res> {
  factory $ShortsTreksDataResponseModelCopyWith(
          ShortsTreksDataResponseModel value,
          $Res Function(ShortsTreksDataResponseModel) then) =
      _$ShortsTreksDataResponseModelCopyWithImpl<$Res,
          ShortsTreksDataResponseModel>;
  @useResult
  $Res call(
      {bool? success,
      String? message,
      List<ShortsTreksData>? data,
      int? count});
}

/// @nodoc
class _$ShortsTreksDataResponseModelCopyWithImpl<$Res,
        $Val extends ShortsTreksDataResponseModel>
    implements $ShortsTreksDataResponseModelCopyWith<$Res> {
  _$ShortsTreksDataResponseModelCopyWithImpl(this._value, this._then);

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
    Object? count = freezed,
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
              as List<ShortsTreksData>?,
      count: freezed == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ShortsTreksDataResponseModelImplCopyWith<$Res>
    implements $ShortsTreksDataResponseModelCopyWith<$Res> {
  factory _$$ShortsTreksDataResponseModelImplCopyWith(
          _$ShortsTreksDataResponseModelImpl value,
          $Res Function(_$ShortsTreksDataResponseModelImpl) then) =
      __$$ShortsTreksDataResponseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool? success,
      String? message,
      List<ShortsTreksData>? data,
      int? count});
}

/// @nodoc
class __$$ShortsTreksDataResponseModelImplCopyWithImpl<$Res>
    extends _$ShortsTreksDataResponseModelCopyWithImpl<$Res,
        _$ShortsTreksDataResponseModelImpl>
    implements _$$ShortsTreksDataResponseModelImplCopyWith<$Res> {
  __$$ShortsTreksDataResponseModelImplCopyWithImpl(
      _$ShortsTreksDataResponseModelImpl _value,
      $Res Function(_$ShortsTreksDataResponseModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = freezed,
    Object? message = freezed,
    Object? data = freezed,
    Object? count = freezed,
  }) {
    return _then(_$ShortsTreksDataResponseModelImpl(
      success: freezed == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool?,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      data: freezed == data
          ? _value._data
          : data // ignore: cast_nullable_to_non_nullable
              as List<ShortsTreksData>?,
      count: freezed == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ShortsTreksDataResponseModelImpl
    implements _ShortsTreksDataResponseModel {
  const _$ShortsTreksDataResponseModelImpl(
      {this.success,
      this.message,
      final List<ShortsTreksData>? data,
      this.count})
      : _data = data;

  factory _$ShortsTreksDataResponseModelImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$ShortsTreksDataResponseModelImplFromJson(json);

  @override
  final bool? success;
  @override
  final String? message;
  final List<ShortsTreksData>? _data;
  @override
  List<ShortsTreksData>? get data {
    final value = _data;
    if (value == null) return null;
    if (_data is EqualUnmodifiableListView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final int? count;

  @override
  String toString() {
    return 'ShortsTreksDataResponseModel(success: $success, message: $message, data: $data, count: $count)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShortsTreksDataResponseModelImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.message, message) || other.message == message) &&
            const DeepCollectionEquality().equals(other._data, _data) &&
            (identical(other.count, count) || other.count == count));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, success, message,
      const DeepCollectionEquality().hash(_data), count);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ShortsTreksDataResponseModelImplCopyWith<
          _$ShortsTreksDataResponseModelImpl>
      get copyWith => __$$ShortsTreksDataResponseModelImplCopyWithImpl<
          _$ShortsTreksDataResponseModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ShortsTreksDataResponseModelImplToJson(
      this,
    );
  }
}

abstract class _ShortsTreksDataResponseModel
    implements ShortsTreksDataResponseModel {
  const factory _ShortsTreksDataResponseModel(
      {final bool? success,
      final String? message,
      final List<ShortsTreksData>? data,
      final int? count}) = _$ShortsTreksDataResponseModelImpl;

  factory _ShortsTreksDataResponseModel.fromJson(Map<String, dynamic> json) =
      _$ShortsTreksDataResponseModelImpl.fromJson;

  @override
  bool? get success;
  @override
  String? get message;
  @override
  List<ShortsTreksData>? get data;
  @override
  int? get count;
  @override
  @JsonKey(ignore: true)
  _$$ShortsTreksDataResponseModelImplCopyWith<
          _$ShortsTreksDataResponseModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}

ShortsTreksData _$ShortsTreksDataFromJson(Map<String, dynamic> json) {
  return _ShortsTreksData.fromJson(json);
}

/// @nodoc
mixin _$ShortsTreksData {
  String? get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get imagePath => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ShortsTreksDataCopyWith<ShortsTreksData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShortsTreksDataCopyWith<$Res> {
  factory $ShortsTreksDataCopyWith(
          ShortsTreksData value, $Res Function(ShortsTreksData) then) =
      _$ShortsTreksDataCopyWithImpl<$Res, ShortsTreksData>;
  @useResult
  $Res call({String? title, String? description, String? imagePath});
}

/// @nodoc
class _$ShortsTreksDataCopyWithImpl<$Res, $Val extends ShortsTreksData>
    implements $ShortsTreksDataCopyWith<$Res> {
  _$ShortsTreksDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = freezed,
    Object? description = freezed,
    Object? imagePath = freezed,
  }) {
    return _then(_value.copyWith(
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      imagePath: freezed == imagePath
          ? _value.imagePath
          : imagePath // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ShortsTreksDataImplCopyWith<$Res>
    implements $ShortsTreksDataCopyWith<$Res> {
  factory _$$ShortsTreksDataImplCopyWith(_$ShortsTreksDataImpl value,
          $Res Function(_$ShortsTreksDataImpl) then) =
      __$$ShortsTreksDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? title, String? description, String? imagePath});
}

/// @nodoc
class __$$ShortsTreksDataImplCopyWithImpl<$Res>
    extends _$ShortsTreksDataCopyWithImpl<$Res, _$ShortsTreksDataImpl>
    implements _$$ShortsTreksDataImplCopyWith<$Res> {
  __$$ShortsTreksDataImplCopyWithImpl(
      _$ShortsTreksDataImpl _value, $Res Function(_$ShortsTreksDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = freezed,
    Object? description = freezed,
    Object? imagePath = freezed,
  }) {
    return _then(_$ShortsTreksDataImpl(
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      imagePath: freezed == imagePath
          ? _value.imagePath
          : imagePath // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ShortsTreksDataImpl implements _ShortsTreksData {
  const _$ShortsTreksDataImpl({this.title, this.description, this.imagePath});

  factory _$ShortsTreksDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$ShortsTreksDataImplFromJson(json);

  @override
  final String? title;
  @override
  final String? description;
  @override
  final String? imagePath;

  @override
  String toString() {
    return 'ShortsTreksData(title: $title, description: $description, imagePath: $imagePath)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShortsTreksDataImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.imagePath, imagePath) ||
                other.imagePath == imagePath));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, title, description, imagePath);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ShortsTreksDataImplCopyWith<_$ShortsTreksDataImpl> get copyWith =>
      __$$ShortsTreksDataImplCopyWithImpl<_$ShortsTreksDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ShortsTreksDataImplToJson(
      this,
    );
  }
}

abstract class _ShortsTreksData implements ShortsTreksData {
  const factory _ShortsTreksData(
      {final String? title,
      final String? description,
      final String? imagePath}) = _$ShortsTreksDataImpl;

  factory _ShortsTreksData.fromJson(Map<String, dynamic> json) =
      _$ShortsTreksDataImpl.fromJson;

  @override
  String? get title;
  @override
  String? get description;
  @override
  String? get imagePath;
  @override
  @JsonKey(ignore: true)
  _$$ShortsTreksDataImplCopyWith<_$ShortsTreksDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
