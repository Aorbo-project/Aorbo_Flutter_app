// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'top_treks_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

TopTreksDataResponseModel _$TopTreksDataResponseModelFromJson(
    Map<String, dynamic> json) {
  return _TopTreksDataResponseModel.fromJson(json);
}

/// @nodoc
mixin _$TopTreksDataResponseModel {
  bool? get success => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;
  List<TopTreksData>? get data => throw _privateConstructorUsedError;
  int? get count => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TopTreksDataResponseModelCopyWith<TopTreksDataResponseModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TopTreksDataResponseModelCopyWith<$Res> {
  factory $TopTreksDataResponseModelCopyWith(TopTreksDataResponseModel value,
          $Res Function(TopTreksDataResponseModel) then) =
      _$TopTreksDataResponseModelCopyWithImpl<$Res, TopTreksDataResponseModel>;
  @useResult
  $Res call(
      {bool? success, String? message, List<TopTreksData>? data, int? count});
}

/// @nodoc
class _$TopTreksDataResponseModelCopyWithImpl<$Res,
        $Val extends TopTreksDataResponseModel>
    implements $TopTreksDataResponseModelCopyWith<$Res> {
  _$TopTreksDataResponseModelCopyWithImpl(this._value, this._then);

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
              as List<TopTreksData>?,
      count: freezed == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TopTreksDataResponseModelImplCopyWith<$Res>
    implements $TopTreksDataResponseModelCopyWith<$Res> {
  factory _$$TopTreksDataResponseModelImplCopyWith(
          _$TopTreksDataResponseModelImpl value,
          $Res Function(_$TopTreksDataResponseModelImpl) then) =
      __$$TopTreksDataResponseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool? success, String? message, List<TopTreksData>? data, int? count});
}

/// @nodoc
class __$$TopTreksDataResponseModelImplCopyWithImpl<$Res>
    extends _$TopTreksDataResponseModelCopyWithImpl<$Res,
        _$TopTreksDataResponseModelImpl>
    implements _$$TopTreksDataResponseModelImplCopyWith<$Res> {
  __$$TopTreksDataResponseModelImplCopyWithImpl(
      _$TopTreksDataResponseModelImpl _value,
      $Res Function(_$TopTreksDataResponseModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = freezed,
    Object? message = freezed,
    Object? data = freezed,
    Object? count = freezed,
  }) {
    return _then(_$TopTreksDataResponseModelImpl(
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
              as List<TopTreksData>?,
      count: freezed == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TopTreksDataResponseModelImpl implements _TopTreksDataResponseModel {
  const _$TopTreksDataResponseModelImpl(
      {this.success, this.message, final List<TopTreksData>? data, this.count})
      : _data = data;

  factory _$TopTreksDataResponseModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TopTreksDataResponseModelImplFromJson(json);

  @override
  final bool? success;
  @override
  final String? message;
  final List<TopTreksData>? _data;
  @override
  List<TopTreksData>? get data {
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
    return 'TopTreksDataResponseModel(success: $success, message: $message, data: $data, count: $count)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TopTreksDataResponseModelImpl &&
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
  _$$TopTreksDataResponseModelImplCopyWith<_$TopTreksDataResponseModelImpl>
      get copyWith => __$$TopTreksDataResponseModelImplCopyWithImpl<
          _$TopTreksDataResponseModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TopTreksDataResponseModelImplToJson(
      this,
    );
  }
}

abstract class _TopTreksDataResponseModel implements TopTreksDataResponseModel {
  const factory _TopTreksDataResponseModel(
      {final bool? success,
      final String? message,
      final List<TopTreksData>? data,
      final int? count}) = _$TopTreksDataResponseModelImpl;

  factory _TopTreksDataResponseModel.fromJson(Map<String, dynamic> json) =
      _$TopTreksDataResponseModelImpl.fromJson;

  @override
  bool? get success;
  @override
  String? get message;
  @override
  List<TopTreksData>? get data;
  @override
  int? get count;
  @override
  @JsonKey(ignore: true)
  _$$TopTreksDataResponseModelImplCopyWith<_$TopTreksDataResponseModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}

TopTreksData _$TopTreksDataFromJson(Map<String, dynamic> json) {
  return _TopTreksData.fromJson(json);
}

/// @nodoc
mixin _$TopTreksData {
  String? get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get imagePath => throw _privateConstructorUsedError;
  List<String>? get gradient => throw _privateConstructorUsedError;
  bool? get isFavorite => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TopTreksDataCopyWith<TopTreksData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TopTreksDataCopyWith<$Res> {
  factory $TopTreksDataCopyWith(
          TopTreksData value, $Res Function(TopTreksData) then) =
      _$TopTreksDataCopyWithImpl<$Res, TopTreksData>;
  @useResult
  $Res call(
      {String? title,
      String? description,
      String? imagePath,
      List<String>? gradient,
      bool? isFavorite});
}

/// @nodoc
class _$TopTreksDataCopyWithImpl<$Res, $Val extends TopTreksData>
    implements $TopTreksDataCopyWith<$Res> {
  _$TopTreksDataCopyWithImpl(this._value, this._then);

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
    Object? gradient = freezed,
    Object? isFavorite = freezed,
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
      gradient: freezed == gradient
          ? _value.gradient
          : gradient // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      isFavorite: freezed == isFavorite
          ? _value.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TopTreksDataImplCopyWith<$Res>
    implements $TopTreksDataCopyWith<$Res> {
  factory _$$TopTreksDataImplCopyWith(
          _$TopTreksDataImpl value, $Res Function(_$TopTreksDataImpl) then) =
      __$$TopTreksDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? title,
      String? description,
      String? imagePath,
      List<String>? gradient,
      bool? isFavorite});
}

/// @nodoc
class __$$TopTreksDataImplCopyWithImpl<$Res>
    extends _$TopTreksDataCopyWithImpl<$Res, _$TopTreksDataImpl>
    implements _$$TopTreksDataImplCopyWith<$Res> {
  __$$TopTreksDataImplCopyWithImpl(
      _$TopTreksDataImpl _value, $Res Function(_$TopTreksDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = freezed,
    Object? description = freezed,
    Object? imagePath = freezed,
    Object? gradient = freezed,
    Object? isFavorite = freezed,
  }) {
    return _then(_$TopTreksDataImpl(
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
      gradient: freezed == gradient
          ? _value._gradient
          : gradient // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      isFavorite: freezed == isFavorite
          ? _value.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TopTreksDataImpl implements _TopTreksData {
  const _$TopTreksDataImpl(
      {this.title,
      this.description,
      this.imagePath,
      final List<String>? gradient,
      this.isFavorite})
      : _gradient = gradient;

  factory _$TopTreksDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$TopTreksDataImplFromJson(json);

  @override
  final String? title;
  @override
  final String? description;
  @override
  final String? imagePath;
  final List<String>? _gradient;
  @override
  List<String>? get gradient {
    final value = _gradient;
    if (value == null) return null;
    if (_gradient is EqualUnmodifiableListView) return _gradient;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final bool? isFavorite;

  @override
  String toString() {
    return 'TopTreksData(title: $title, description: $description, imagePath: $imagePath, gradient: $gradient, isFavorite: $isFavorite)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TopTreksDataImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.imagePath, imagePath) ||
                other.imagePath == imagePath) &&
            const DeepCollectionEquality().equals(other._gradient, _gradient) &&
            (identical(other.isFavorite, isFavorite) ||
                other.isFavorite == isFavorite));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, title, description, imagePath,
      const DeepCollectionEquality().hash(_gradient), isFavorite);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TopTreksDataImplCopyWith<_$TopTreksDataImpl> get copyWith =>
      __$$TopTreksDataImplCopyWithImpl<_$TopTreksDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TopTreksDataImplToJson(
      this,
    );
  }
}

abstract class _TopTreksData implements TopTreksData {
  const factory _TopTreksData(
      {final String? title,
      final String? description,
      final String? imagePath,
      final List<String>? gradient,
      final bool? isFavorite}) = _$TopTreksDataImpl;

  factory _TopTreksData.fromJson(Map<String, dynamic> json) =
      _$TopTreksDataImpl.fromJson;

  @override
  String? get title;
  @override
  String? get description;
  @override
  String? get imagePath;
  @override
  List<String>? get gradient;
  @override
  bool? get isFavorite;
  @override
  @JsonKey(ignore: true)
  _$$TopTreksDataImplCopyWith<_$TopTreksDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
