// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'know_more_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

WhatsNewDataResponseModel _$WhatsNewDataResponseModelFromJson(
    Map<String, dynamic> json) {
  return _WhatsNewDataResponseModel.fromJson(json);
}

/// @nodoc
mixin _$WhatsNewDataResponseModel {
  bool? get success => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;
  List<KnowMoreData>? get data => throw _privateConstructorUsedError;
  int? get count => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $WhatsNewDataResponseModelCopyWith<WhatsNewDataResponseModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WhatsNewDataResponseModelCopyWith<$Res> {
  factory $WhatsNewDataResponseModelCopyWith(WhatsNewDataResponseModel value,
          $Res Function(WhatsNewDataResponseModel) then) =
      _$WhatsNewDataResponseModelCopyWithImpl<$Res, WhatsNewDataResponseModel>;
  @useResult
  $Res call(
      {bool? success, String? message, List<KnowMoreData>? data, int? count});
}

/// @nodoc
class _$WhatsNewDataResponseModelCopyWithImpl<$Res,
        $Val extends WhatsNewDataResponseModel>
    implements $WhatsNewDataResponseModelCopyWith<$Res> {
  _$WhatsNewDataResponseModelCopyWithImpl(this._value, this._then);

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
              as List<KnowMoreData>?,
      count: freezed == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WhatsNewDataResponseModelImplCopyWith<$Res>
    implements $WhatsNewDataResponseModelCopyWith<$Res> {
  factory _$$WhatsNewDataResponseModelImplCopyWith(
          _$WhatsNewDataResponseModelImpl value,
          $Res Function(_$WhatsNewDataResponseModelImpl) then) =
      __$$WhatsNewDataResponseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool? success, String? message, List<KnowMoreData>? data, int? count});
}

/// @nodoc
class __$$WhatsNewDataResponseModelImplCopyWithImpl<$Res>
    extends _$WhatsNewDataResponseModelCopyWithImpl<$Res,
        _$WhatsNewDataResponseModelImpl>
    implements _$$WhatsNewDataResponseModelImplCopyWith<$Res> {
  __$$WhatsNewDataResponseModelImplCopyWithImpl(
      _$WhatsNewDataResponseModelImpl _value,
      $Res Function(_$WhatsNewDataResponseModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = freezed,
    Object? message = freezed,
    Object? data = freezed,
    Object? count = freezed,
  }) {
    return _then(_$WhatsNewDataResponseModelImpl(
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
              as List<KnowMoreData>?,
      count: freezed == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WhatsNewDataResponseModelImpl implements _WhatsNewDataResponseModel {
  const _$WhatsNewDataResponseModelImpl(
      {this.success, this.message, final List<KnowMoreData>? data, this.count})
      : _data = data;

  factory _$WhatsNewDataResponseModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$WhatsNewDataResponseModelImplFromJson(json);

  @override
  final bool? success;
  @override
  final String? message;
  final List<KnowMoreData>? _data;
  @override
  List<KnowMoreData>? get data {
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
    return 'WhatsNewDataResponseModel(success: $success, message: $message, data: $data, count: $count)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WhatsNewDataResponseModelImpl &&
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
  _$$WhatsNewDataResponseModelImplCopyWith<_$WhatsNewDataResponseModelImpl>
      get copyWith => __$$WhatsNewDataResponseModelImplCopyWithImpl<
          _$WhatsNewDataResponseModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WhatsNewDataResponseModelImplToJson(
      this,
    );
  }
}

abstract class _WhatsNewDataResponseModel implements WhatsNewDataResponseModel {
  const factory _WhatsNewDataResponseModel(
      {final bool? success,
      final String? message,
      final List<KnowMoreData>? data,
      final int? count}) = _$WhatsNewDataResponseModelImpl;

  factory _WhatsNewDataResponseModel.fromJson(Map<String, dynamic> json) =
      _$WhatsNewDataResponseModelImpl.fromJson;

  @override
  bool? get success;
  @override
  String? get message;
  @override
  List<KnowMoreData>? get data;
  @override
  int? get count;
  @override
  @JsonKey(ignore: true)
  _$$WhatsNewDataResponseModelImplCopyWith<_$WhatsNewDataResponseModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}

KnowMoreData _$KnowMoreDataFromJson(Map<String, dynamic> json) {
  return _KnowMoreData.fromJson(json);
}

/// @nodoc
mixin _$KnowMoreData {
  String? get title => throw _privateConstructorUsedError;
  String? get subtitle => throw _privateConstructorUsedError;
  String? get imagePath => throw _privateConstructorUsedError;
  bool? get hasKnowMore => throw _privateConstructorUsedError;
  List<String>? get customGradient => throw _privateConstructorUsedError;
  String? get textColor => throw _privateConstructorUsedError;
  String? get detailedTitle => throw _privateConstructorUsedError;
  String? get detailedDescription => throw _privateConstructorUsedError;
  List<BulletPointModel>? get bulletPoints =>
      throw _privateConstructorUsedError;
  String? get callToAction => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $KnowMoreDataCopyWith<KnowMoreData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $KnowMoreDataCopyWith<$Res> {
  factory $KnowMoreDataCopyWith(
          KnowMoreData value, $Res Function(KnowMoreData) then) =
      _$KnowMoreDataCopyWithImpl<$Res, KnowMoreData>;
  @useResult
  $Res call(
      {String? title,
      String? subtitle,
      String? imagePath,
      bool? hasKnowMore,
      List<String>? customGradient,
      String? textColor,
      String? detailedTitle,
      String? detailedDescription,
      List<BulletPointModel>? bulletPoints,
      String? callToAction});
}

/// @nodoc
class _$KnowMoreDataCopyWithImpl<$Res, $Val extends KnowMoreData>
    implements $KnowMoreDataCopyWith<$Res> {
  _$KnowMoreDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = freezed,
    Object? subtitle = freezed,
    Object? imagePath = freezed,
    Object? hasKnowMore = freezed,
    Object? customGradient = freezed,
    Object? textColor = freezed,
    Object? detailedTitle = freezed,
    Object? detailedDescription = freezed,
    Object? bulletPoints = freezed,
    Object? callToAction = freezed,
  }) {
    return _then(_value.copyWith(
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      subtitle: freezed == subtitle
          ? _value.subtitle
          : subtitle // ignore: cast_nullable_to_non_nullable
              as String?,
      imagePath: freezed == imagePath
          ? _value.imagePath
          : imagePath // ignore: cast_nullable_to_non_nullable
              as String?,
      hasKnowMore: freezed == hasKnowMore
          ? _value.hasKnowMore
          : hasKnowMore // ignore: cast_nullable_to_non_nullable
              as bool?,
      customGradient: freezed == customGradient
          ? _value.customGradient
          : customGradient // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      textColor: freezed == textColor
          ? _value.textColor
          : textColor // ignore: cast_nullable_to_non_nullable
              as String?,
      detailedTitle: freezed == detailedTitle
          ? _value.detailedTitle
          : detailedTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      detailedDescription: freezed == detailedDescription
          ? _value.detailedDescription
          : detailedDescription // ignore: cast_nullable_to_non_nullable
              as String?,
      bulletPoints: freezed == bulletPoints
          ? _value.bulletPoints
          : bulletPoints // ignore: cast_nullable_to_non_nullable
              as List<BulletPointModel>?,
      callToAction: freezed == callToAction
          ? _value.callToAction
          : callToAction // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$KnowMoreDataImplCopyWith<$Res>
    implements $KnowMoreDataCopyWith<$Res> {
  factory _$$KnowMoreDataImplCopyWith(
          _$KnowMoreDataImpl value, $Res Function(_$KnowMoreDataImpl) then) =
      __$$KnowMoreDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? title,
      String? subtitle,
      String? imagePath,
      bool? hasKnowMore,
      List<String>? customGradient,
      String? textColor,
      String? detailedTitle,
      String? detailedDescription,
      List<BulletPointModel>? bulletPoints,
      String? callToAction});
}

/// @nodoc
class __$$KnowMoreDataImplCopyWithImpl<$Res>
    extends _$KnowMoreDataCopyWithImpl<$Res, _$KnowMoreDataImpl>
    implements _$$KnowMoreDataImplCopyWith<$Res> {
  __$$KnowMoreDataImplCopyWithImpl(
      _$KnowMoreDataImpl _value, $Res Function(_$KnowMoreDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = freezed,
    Object? subtitle = freezed,
    Object? imagePath = freezed,
    Object? hasKnowMore = freezed,
    Object? customGradient = freezed,
    Object? textColor = freezed,
    Object? detailedTitle = freezed,
    Object? detailedDescription = freezed,
    Object? bulletPoints = freezed,
    Object? callToAction = freezed,
  }) {
    return _then(_$KnowMoreDataImpl(
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      subtitle: freezed == subtitle
          ? _value.subtitle
          : subtitle // ignore: cast_nullable_to_non_nullable
              as String?,
      imagePath: freezed == imagePath
          ? _value.imagePath
          : imagePath // ignore: cast_nullable_to_non_nullable
              as String?,
      hasKnowMore: freezed == hasKnowMore
          ? _value.hasKnowMore
          : hasKnowMore // ignore: cast_nullable_to_non_nullable
              as bool?,
      customGradient: freezed == customGradient
          ? _value._customGradient
          : customGradient // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      textColor: freezed == textColor
          ? _value.textColor
          : textColor // ignore: cast_nullable_to_non_nullable
              as String?,
      detailedTitle: freezed == detailedTitle
          ? _value.detailedTitle
          : detailedTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      detailedDescription: freezed == detailedDescription
          ? _value.detailedDescription
          : detailedDescription // ignore: cast_nullable_to_non_nullable
              as String?,
      bulletPoints: freezed == bulletPoints
          ? _value._bulletPoints
          : bulletPoints // ignore: cast_nullable_to_non_nullable
              as List<BulletPointModel>?,
      callToAction: freezed == callToAction
          ? _value.callToAction
          : callToAction // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$KnowMoreDataImpl implements _KnowMoreData {
  const _$KnowMoreDataImpl(
      {this.title,
      this.subtitle,
      this.imagePath,
      this.hasKnowMore,
      final List<String>? customGradient,
      this.textColor,
      this.detailedTitle,
      this.detailedDescription,
      final List<BulletPointModel>? bulletPoints,
      this.callToAction})
      : _customGradient = customGradient,
        _bulletPoints = bulletPoints;

  factory _$KnowMoreDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$KnowMoreDataImplFromJson(json);

  @override
  final String? title;
  @override
  final String? subtitle;
  @override
  final String? imagePath;
  @override
  final bool? hasKnowMore;
  final List<String>? _customGradient;
  @override
  List<String>? get customGradient {
    final value = _customGradient;
    if (value == null) return null;
    if (_customGradient is EqualUnmodifiableListView) return _customGradient;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? textColor;
  @override
  final String? detailedTitle;
  @override
  final String? detailedDescription;
  final List<BulletPointModel>? _bulletPoints;
  @override
  List<BulletPointModel>? get bulletPoints {
    final value = _bulletPoints;
    if (value == null) return null;
    if (_bulletPoints is EqualUnmodifiableListView) return _bulletPoints;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? callToAction;

  @override
  String toString() {
    return 'KnowMoreData(title: $title, subtitle: $subtitle, imagePath: $imagePath, hasKnowMore: $hasKnowMore, customGradient: $customGradient, textColor: $textColor, detailedTitle: $detailedTitle, detailedDescription: $detailedDescription, bulletPoints: $bulletPoints, callToAction: $callToAction)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$KnowMoreDataImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.subtitle, subtitle) ||
                other.subtitle == subtitle) &&
            (identical(other.imagePath, imagePath) ||
                other.imagePath == imagePath) &&
            (identical(other.hasKnowMore, hasKnowMore) ||
                other.hasKnowMore == hasKnowMore) &&
            const DeepCollectionEquality()
                .equals(other._customGradient, _customGradient) &&
            (identical(other.textColor, textColor) ||
                other.textColor == textColor) &&
            (identical(other.detailedTitle, detailedTitle) ||
                other.detailedTitle == detailedTitle) &&
            (identical(other.detailedDescription, detailedDescription) ||
                other.detailedDescription == detailedDescription) &&
            const DeepCollectionEquality()
                .equals(other._bulletPoints, _bulletPoints) &&
            (identical(other.callToAction, callToAction) ||
                other.callToAction == callToAction));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      title,
      subtitle,
      imagePath,
      hasKnowMore,
      const DeepCollectionEquality().hash(_customGradient),
      textColor,
      detailedTitle,
      detailedDescription,
      const DeepCollectionEquality().hash(_bulletPoints),
      callToAction);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$KnowMoreDataImplCopyWith<_$KnowMoreDataImpl> get copyWith =>
      __$$KnowMoreDataImplCopyWithImpl<_$KnowMoreDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$KnowMoreDataImplToJson(
      this,
    );
  }
}

abstract class _KnowMoreData implements KnowMoreData {
  const factory _KnowMoreData(
      {final String? title,
      final String? subtitle,
      final String? imagePath,
      final bool? hasKnowMore,
      final List<String>? customGradient,
      final String? textColor,
      final String? detailedTitle,
      final String? detailedDescription,
      final List<BulletPointModel>? bulletPoints,
      final String? callToAction}) = _$KnowMoreDataImpl;

  factory _KnowMoreData.fromJson(Map<String, dynamic> json) =
      _$KnowMoreDataImpl.fromJson;

  @override
  String? get title;
  @override
  String? get subtitle;
  @override
  String? get imagePath;
  @override
  bool? get hasKnowMore;
  @override
  List<String>? get customGradient;
  @override
  String? get textColor;
  @override
  String? get detailedTitle;
  @override
  String? get detailedDescription;
  @override
  List<BulletPointModel>? get bulletPoints;
  @override
  String? get callToAction;
  @override
  @JsonKey(ignore: true)
  _$$KnowMoreDataImplCopyWith<_$KnowMoreDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BulletPointModel _$BulletPointModelFromJson(Map<String, dynamic> json) {
  return _BulletPointModel.fromJson(json);
}

/// @nodoc
mixin _$BulletPointModel {
  String? get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BulletPointModelCopyWith<BulletPointModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BulletPointModelCopyWith<$Res> {
  factory $BulletPointModelCopyWith(
          BulletPointModel value, $Res Function(BulletPointModel) then) =
      _$BulletPointModelCopyWithImpl<$Res, BulletPointModel>;
  @useResult
  $Res call({String? title, String? description});
}

/// @nodoc
class _$BulletPointModelCopyWithImpl<$Res, $Val extends BulletPointModel>
    implements $BulletPointModelCopyWith<$Res> {
  _$BulletPointModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = freezed,
    Object? description = freezed,
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
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BulletPointModelImplCopyWith<$Res>
    implements $BulletPointModelCopyWith<$Res> {
  factory _$$BulletPointModelImplCopyWith(_$BulletPointModelImpl value,
          $Res Function(_$BulletPointModelImpl) then) =
      __$$BulletPointModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? title, String? description});
}

/// @nodoc
class __$$BulletPointModelImplCopyWithImpl<$Res>
    extends _$BulletPointModelCopyWithImpl<$Res, _$BulletPointModelImpl>
    implements _$$BulletPointModelImplCopyWith<$Res> {
  __$$BulletPointModelImplCopyWithImpl(_$BulletPointModelImpl _value,
      $Res Function(_$BulletPointModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = freezed,
    Object? description = freezed,
  }) {
    return _then(_$BulletPointModelImpl(
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BulletPointModelImpl implements _BulletPointModel {
  const _$BulletPointModelImpl({this.title, this.description});

  factory _$BulletPointModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$BulletPointModelImplFromJson(json);

  @override
  final String? title;
  @override
  final String? description;

  @override
  String toString() {
    return 'BulletPointModel(title: $title, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BulletPointModelImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, title, description);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BulletPointModelImplCopyWith<_$BulletPointModelImpl> get copyWith =>
      __$$BulletPointModelImplCopyWithImpl<_$BulletPointModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BulletPointModelImplToJson(
      this,
    );
  }
}

abstract class _BulletPointModel implements BulletPointModel {
  const factory _BulletPointModel(
      {final String? title,
      final String? description}) = _$BulletPointModelImpl;

  factory _BulletPointModel.fromJson(Map<String, dynamic> json) =
      _$BulletPointModelImpl.fromJson;

  @override
  String? get title;
  @override
  String? get description;
  @override
  @JsonKey(ignore: true)
  _$$BulletPointModelImplCopyWith<_$BulletPointModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
