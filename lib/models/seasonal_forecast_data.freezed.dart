// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'seasonal_forecast_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

SeasonalForecastDataResponseModel _$SeasonalForecastDataResponseModelFromJson(
    Map<String, dynamic> json) {
  return _SeasonalForecastDataResponseModel.fromJson(json);
}

/// @nodoc
mixin _$SeasonalForecastDataResponseModel {
  bool? get success => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;
  List<SeasonalForecastData>? get data => throw _privateConstructorUsedError;
  int? get count => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SeasonalForecastDataResponseModelCopyWith<SeasonalForecastDataResponseModel>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SeasonalForecastDataResponseModelCopyWith<$Res> {
  factory $SeasonalForecastDataResponseModelCopyWith(
          SeasonalForecastDataResponseModel value,
          $Res Function(SeasonalForecastDataResponseModel) then) =
      _$SeasonalForecastDataResponseModelCopyWithImpl<$Res,
          SeasonalForecastDataResponseModel>;
  @useResult
  $Res call(
      {bool? success,
      String? message,
      List<SeasonalForecastData>? data,
      int? count});
}

/// @nodoc
class _$SeasonalForecastDataResponseModelCopyWithImpl<$Res,
        $Val extends SeasonalForecastDataResponseModel>
    implements $SeasonalForecastDataResponseModelCopyWith<$Res> {
  _$SeasonalForecastDataResponseModelCopyWithImpl(this._value, this._then);

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
              as List<SeasonalForecastData>?,
      count: freezed == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SeasonalForecastDataResponseModelImplCopyWith<$Res>
    implements $SeasonalForecastDataResponseModelCopyWith<$Res> {
  factory _$$SeasonalForecastDataResponseModelImplCopyWith(
          _$SeasonalForecastDataResponseModelImpl value,
          $Res Function(_$SeasonalForecastDataResponseModelImpl) then) =
      __$$SeasonalForecastDataResponseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool? success,
      String? message,
      List<SeasonalForecastData>? data,
      int? count});
}

/// @nodoc
class __$$SeasonalForecastDataResponseModelImplCopyWithImpl<$Res>
    extends _$SeasonalForecastDataResponseModelCopyWithImpl<$Res,
        _$SeasonalForecastDataResponseModelImpl>
    implements _$$SeasonalForecastDataResponseModelImplCopyWith<$Res> {
  __$$SeasonalForecastDataResponseModelImplCopyWithImpl(
      _$SeasonalForecastDataResponseModelImpl _value,
      $Res Function(_$SeasonalForecastDataResponseModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = freezed,
    Object? message = freezed,
    Object? data = freezed,
    Object? count = freezed,
  }) {
    return _then(_$SeasonalForecastDataResponseModelImpl(
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
              as List<SeasonalForecastData>?,
      count: freezed == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SeasonalForecastDataResponseModelImpl
    implements _SeasonalForecastDataResponseModel {
  const _$SeasonalForecastDataResponseModelImpl(
      {this.success,
      this.message,
      final List<SeasonalForecastData>? data,
      this.count})
      : _data = data;

  factory _$SeasonalForecastDataResponseModelImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$SeasonalForecastDataResponseModelImplFromJson(json);

  @override
  final bool? success;
  @override
  final String? message;
  final List<SeasonalForecastData>? _data;
  @override
  List<SeasonalForecastData>? get data {
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
    return 'SeasonalForecastDataResponseModel(success: $success, message: $message, data: $data, count: $count)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SeasonalForecastDataResponseModelImpl &&
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
  _$$SeasonalForecastDataResponseModelImplCopyWith<
          _$SeasonalForecastDataResponseModelImpl>
      get copyWith => __$$SeasonalForecastDataResponseModelImplCopyWithImpl<
          _$SeasonalForecastDataResponseModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SeasonalForecastDataResponseModelImplToJson(
      this,
    );
  }
}

abstract class _SeasonalForecastDataResponseModel
    implements SeasonalForecastDataResponseModel {
  const factory _SeasonalForecastDataResponseModel(
      {final bool? success,
      final String? message,
      final List<SeasonalForecastData>? data,
      final int? count}) = _$SeasonalForecastDataResponseModelImpl;

  factory _SeasonalForecastDataResponseModel.fromJson(
          Map<String, dynamic> json) =
      _$SeasonalForecastDataResponseModelImpl.fromJson;

  @override
  bool? get success;
  @override
  String? get message;
  @override
  List<SeasonalForecastData>? get data;
  @override
  int? get count;
  @override
  @JsonKey(ignore: true)
  _$$SeasonalForecastDataResponseModelImplCopyWith<
          _$SeasonalForecastDataResponseModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}

SeasonalForecastData _$SeasonalForecastDataFromJson(Map<String, dynamic> json) {
  return _SeasonalForecastData.fromJson(json);
}

/// @nodoc
mixin _$SeasonalForecastData {
  String? get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'imagePath')
  String? get imagePath => throw _privateConstructorUsedError;
  String? get color => throw _privateConstructorUsedError;
  List<dynamic>? get gradient => throw _privateConstructorUsedError;
  String? get textColour => throw _privateConstructorUsedError;
  StylingModel? get styling => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SeasonalForecastDataCopyWith<SeasonalForecastData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SeasonalForecastDataCopyWith<$Res> {
  factory $SeasonalForecastDataCopyWith(SeasonalForecastData value,
          $Res Function(SeasonalForecastData) then) =
      _$SeasonalForecastDataCopyWithImpl<$Res, SeasonalForecastData>;
  @useResult
  $Res call(
      {String? title,
      String? description,
      @JsonKey(name: 'imagePath') String? imagePath,
      String? color,
      List<dynamic>? gradient,
      String? textColour,
      StylingModel? styling});

  $StylingModelCopyWith<$Res>? get styling;
}

/// @nodoc
class _$SeasonalForecastDataCopyWithImpl<$Res,
        $Val extends SeasonalForecastData>
    implements $SeasonalForecastDataCopyWith<$Res> {
  _$SeasonalForecastDataCopyWithImpl(this._value, this._then);

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
    Object? color = freezed,
    Object? gradient = freezed,
    Object? textColour = freezed,
    Object? styling = freezed,
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
      color: freezed == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String?,
      gradient: freezed == gradient
          ? _value.gradient
          : gradient // ignore: cast_nullable_to_non_nullable
              as List<dynamic>?,
      textColour: freezed == textColour
          ? _value.textColour
          : textColour // ignore: cast_nullable_to_non_nullable
              as String?,
      styling: freezed == styling
          ? _value.styling
          : styling // ignore: cast_nullable_to_non_nullable
              as StylingModel?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $StylingModelCopyWith<$Res>? get styling {
    if (_value.styling == null) {
      return null;
    }

    return $StylingModelCopyWith<$Res>(_value.styling!, (value) {
      return _then(_value.copyWith(styling: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SeasonalForecastDataImplCopyWith<$Res>
    implements $SeasonalForecastDataCopyWith<$Res> {
  factory _$$SeasonalForecastDataImplCopyWith(_$SeasonalForecastDataImpl value,
          $Res Function(_$SeasonalForecastDataImpl) then) =
      __$$SeasonalForecastDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? title,
      String? description,
      @JsonKey(name: 'imagePath') String? imagePath,
      String? color,
      List<dynamic>? gradient,
      String? textColour,
      StylingModel? styling});

  @override
  $StylingModelCopyWith<$Res>? get styling;
}

/// @nodoc
class __$$SeasonalForecastDataImplCopyWithImpl<$Res>
    extends _$SeasonalForecastDataCopyWithImpl<$Res, _$SeasonalForecastDataImpl>
    implements _$$SeasonalForecastDataImplCopyWith<$Res> {
  __$$SeasonalForecastDataImplCopyWithImpl(_$SeasonalForecastDataImpl _value,
      $Res Function(_$SeasonalForecastDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = freezed,
    Object? description = freezed,
    Object? imagePath = freezed,
    Object? color = freezed,
    Object? gradient = freezed,
    Object? textColour = freezed,
    Object? styling = freezed,
  }) {
    return _then(_$SeasonalForecastDataImpl(
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
      color: freezed == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String?,
      gradient: freezed == gradient
          ? _value._gradient
          : gradient // ignore: cast_nullable_to_non_nullable
              as List<dynamic>?,
      textColour: freezed == textColour
          ? _value.textColour
          : textColour // ignore: cast_nullable_to_non_nullable
              as String?,
      styling: freezed == styling
          ? _value.styling
          : styling // ignore: cast_nullable_to_non_nullable
              as StylingModel?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SeasonalForecastDataImpl implements _SeasonalForecastData {
  const _$SeasonalForecastDataImpl(
      {this.title,
      this.description,
      @JsonKey(name: 'imagePath') this.imagePath,
      this.color,
      final List<dynamic>? gradient,
      this.textColour,
      this.styling})
      : _gradient = gradient;

  factory _$SeasonalForecastDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$SeasonalForecastDataImplFromJson(json);

  @override
  final String? title;
  @override
  final String? description;
  @override
  @JsonKey(name: 'imagePath')
  final String? imagePath;
  @override
  final String? color;
  final List<dynamic>? _gradient;
  @override
  List<dynamic>? get gradient {
    final value = _gradient;
    if (value == null) return null;
    if (_gradient is EqualUnmodifiableListView) return _gradient;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? textColour;
  @override
  final StylingModel? styling;

  @override
  String toString() {
    return 'SeasonalForecastData(title: $title, description: $description, imagePath: $imagePath, color: $color, gradient: $gradient, textColour: $textColour, styling: $styling)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SeasonalForecastDataImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.imagePath, imagePath) ||
                other.imagePath == imagePath) &&
            (identical(other.color, color) || other.color == color) &&
            const DeepCollectionEquality().equals(other._gradient, _gradient) &&
            (identical(other.textColour, textColour) ||
                other.textColour == textColour) &&
            (identical(other.styling, styling) || other.styling == styling));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      title,
      description,
      imagePath,
      color,
      const DeepCollectionEquality().hash(_gradient),
      textColour,
      styling);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SeasonalForecastDataImplCopyWith<_$SeasonalForecastDataImpl>
      get copyWith =>
          __$$SeasonalForecastDataImplCopyWithImpl<_$SeasonalForecastDataImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SeasonalForecastDataImplToJson(
      this,
    );
  }
}

abstract class _SeasonalForecastData implements SeasonalForecastData {
  const factory _SeasonalForecastData(
      {final String? title,
      final String? description,
      @JsonKey(name: 'imagePath') final String? imagePath,
      final String? color,
      final List<dynamic>? gradient,
      final String? textColour,
      final StylingModel? styling}) = _$SeasonalForecastDataImpl;

  factory _SeasonalForecastData.fromJson(Map<String, dynamic> json) =
      _$SeasonalForecastDataImpl.fromJson;

  @override
  String? get title;
  @override
  String? get description;
  @override
  @JsonKey(name: 'imagePath')
  String? get imagePath;
  @override
  String? get color;
  @override
  List<dynamic>? get gradient;
  @override
  String? get textColour;
  @override
  StylingModel? get styling;
  @override
  @JsonKey(ignore: true)
  _$$SeasonalForecastDataImplCopyWith<_$SeasonalForecastDataImpl>
      get copyWith => throw _privateConstructorUsedError;
}

StylingModel _$StylingModelFromJson(Map<String, dynamic> json) {
  return _StylingModel.fromJson(json);
}

/// @nodoc
mixin _$StylingModel {
  dynamic get card => throw _privateConstructorUsedError;
  dynamic get header => throw _privateConstructorUsedError;
  TitleStylingModel? get title => throw _privateConstructorUsedError;
  dynamic get icon => throw _privateConstructorUsedError;
  BodyStylingModel? get body => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $StylingModelCopyWith<StylingModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StylingModelCopyWith<$Res> {
  factory $StylingModelCopyWith(
          StylingModel value, $Res Function(StylingModel) then) =
      _$StylingModelCopyWithImpl<$Res, StylingModel>;
  @useResult
  $Res call(
      {dynamic card,
      dynamic header,
      TitleStylingModel? title,
      dynamic icon,
      BodyStylingModel? body});

  $TitleStylingModelCopyWith<$Res>? get title;
  $BodyStylingModelCopyWith<$Res>? get body;
}

/// @nodoc
class _$StylingModelCopyWithImpl<$Res, $Val extends StylingModel>
    implements $StylingModelCopyWith<$Res> {
  _$StylingModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? card = freezed,
    Object? header = freezed,
    Object? title = freezed,
    Object? icon = freezed,
    Object? body = freezed,
  }) {
    return _then(_value.copyWith(
      card: freezed == card
          ? _value.card
          : card // ignore: cast_nullable_to_non_nullable
              as dynamic,
      header: freezed == header
          ? _value.header
          : header // ignore: cast_nullable_to_non_nullable
              as dynamic,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as TitleStylingModel?,
      icon: freezed == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as dynamic,
      body: freezed == body
          ? _value.body
          : body // ignore: cast_nullable_to_non_nullable
              as BodyStylingModel?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $TitleStylingModelCopyWith<$Res>? get title {
    if (_value.title == null) {
      return null;
    }

    return $TitleStylingModelCopyWith<$Res>(_value.title!, (value) {
      return _then(_value.copyWith(title: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $BodyStylingModelCopyWith<$Res>? get body {
    if (_value.body == null) {
      return null;
    }

    return $BodyStylingModelCopyWith<$Res>(_value.body!, (value) {
      return _then(_value.copyWith(body: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$StylingModelImplCopyWith<$Res>
    implements $StylingModelCopyWith<$Res> {
  factory _$$StylingModelImplCopyWith(
          _$StylingModelImpl value, $Res Function(_$StylingModelImpl) then) =
      __$$StylingModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {dynamic card,
      dynamic header,
      TitleStylingModel? title,
      dynamic icon,
      BodyStylingModel? body});

  @override
  $TitleStylingModelCopyWith<$Res>? get title;
  @override
  $BodyStylingModelCopyWith<$Res>? get body;
}

/// @nodoc
class __$$StylingModelImplCopyWithImpl<$Res>
    extends _$StylingModelCopyWithImpl<$Res, _$StylingModelImpl>
    implements _$$StylingModelImplCopyWith<$Res> {
  __$$StylingModelImplCopyWithImpl(
      _$StylingModelImpl _value, $Res Function(_$StylingModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? card = freezed,
    Object? header = freezed,
    Object? title = freezed,
    Object? icon = freezed,
    Object? body = freezed,
  }) {
    return _then(_$StylingModelImpl(
      card: freezed == card
          ? _value.card
          : card // ignore: cast_nullable_to_non_nullable
              as dynamic,
      header: freezed == header
          ? _value.header
          : header // ignore: cast_nullable_to_non_nullable
              as dynamic,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as TitleStylingModel?,
      icon: freezed == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as dynamic,
      body: freezed == body
          ? _value.body
          : body // ignore: cast_nullable_to_non_nullable
              as BodyStylingModel?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StylingModelImpl implements _StylingModel {
  const _$StylingModelImpl(
      {this.card, this.header, this.title, this.icon, this.body});

  factory _$StylingModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$StylingModelImplFromJson(json);

  @override
  final dynamic card;
  @override
  final dynamic header;
  @override
  final TitleStylingModel? title;
  @override
  final dynamic icon;
  @override
  final BodyStylingModel? body;

  @override
  String toString() {
    return 'StylingModel(card: $card, header: $header, title: $title, icon: $icon, body: $body)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StylingModelImpl &&
            const DeepCollectionEquality().equals(other.card, card) &&
            const DeepCollectionEquality().equals(other.header, header) &&
            (identical(other.title, title) || other.title == title) &&
            const DeepCollectionEquality().equals(other.icon, icon) &&
            (identical(other.body, body) || other.body == body));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(card),
      const DeepCollectionEquality().hash(header),
      title,
      const DeepCollectionEquality().hash(icon),
      body);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$StylingModelImplCopyWith<_$StylingModelImpl> get copyWith =>
      __$$StylingModelImplCopyWithImpl<_$StylingModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StylingModelImplToJson(
      this,
    );
  }
}

abstract class _StylingModel implements StylingModel {
  const factory _StylingModel(
      {final dynamic card,
      final dynamic header,
      final TitleStylingModel? title,
      final dynamic icon,
      final BodyStylingModel? body}) = _$StylingModelImpl;

  factory _StylingModel.fromJson(Map<String, dynamic> json) =
      _$StylingModelImpl.fromJson;

  @override
  dynamic get card;
  @override
  dynamic get header;
  @override
  TitleStylingModel? get title;
  @override
  dynamic get icon;
  @override
  BodyStylingModel? get body;
  @override
  @JsonKey(ignore: true)
  _$$StylingModelImplCopyWith<_$StylingModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TitleStylingModel _$TitleStylingModelFromJson(Map<String, dynamic> json) {
  return _TitleStylingModel.fromJson(json);
}

/// @nodoc
mixin _$TitleStylingModel {
  List<dynamic>? get gradient => throw _privateConstructorUsedError;
  String? get textColour => throw _privateConstructorUsedError;
  String? get icon => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TitleStylingModelCopyWith<TitleStylingModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TitleStylingModelCopyWith<$Res> {
  factory $TitleStylingModelCopyWith(
          TitleStylingModel value, $Res Function(TitleStylingModel) then) =
      _$TitleStylingModelCopyWithImpl<$Res, TitleStylingModel>;
  @useResult
  $Res call({List<dynamic>? gradient, String? textColour, String? icon});
}

/// @nodoc
class _$TitleStylingModelCopyWithImpl<$Res, $Val extends TitleStylingModel>
    implements $TitleStylingModelCopyWith<$Res> {
  _$TitleStylingModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? gradient = freezed,
    Object? textColour = freezed,
    Object? icon = freezed,
  }) {
    return _then(_value.copyWith(
      gradient: freezed == gradient
          ? _value.gradient
          : gradient // ignore: cast_nullable_to_non_nullable
              as List<dynamic>?,
      textColour: freezed == textColour
          ? _value.textColour
          : textColour // ignore: cast_nullable_to_non_nullable
              as String?,
      icon: freezed == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TitleStylingModelImplCopyWith<$Res>
    implements $TitleStylingModelCopyWith<$Res> {
  factory _$$TitleStylingModelImplCopyWith(_$TitleStylingModelImpl value,
          $Res Function(_$TitleStylingModelImpl) then) =
      __$$TitleStylingModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<dynamic>? gradient, String? textColour, String? icon});
}

/// @nodoc
class __$$TitleStylingModelImplCopyWithImpl<$Res>
    extends _$TitleStylingModelCopyWithImpl<$Res, _$TitleStylingModelImpl>
    implements _$$TitleStylingModelImplCopyWith<$Res> {
  __$$TitleStylingModelImplCopyWithImpl(_$TitleStylingModelImpl _value,
      $Res Function(_$TitleStylingModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? gradient = freezed,
    Object? textColour = freezed,
    Object? icon = freezed,
  }) {
    return _then(_$TitleStylingModelImpl(
      gradient: freezed == gradient
          ? _value._gradient
          : gradient // ignore: cast_nullable_to_non_nullable
              as List<dynamic>?,
      textColour: freezed == textColour
          ? _value.textColour
          : textColour // ignore: cast_nullable_to_non_nullable
              as String?,
      icon: freezed == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TitleStylingModelImpl implements _TitleStylingModel {
  const _$TitleStylingModelImpl(
      {final List<dynamic>? gradient, this.textColour, this.icon})
      : _gradient = gradient;

  factory _$TitleStylingModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TitleStylingModelImplFromJson(json);

  final List<dynamic>? _gradient;
  @override
  List<dynamic>? get gradient {
    final value = _gradient;
    if (value == null) return null;
    if (_gradient is EqualUnmodifiableListView) return _gradient;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? textColour;
  @override
  final String? icon;

  @override
  String toString() {
    return 'TitleStylingModel(gradient: $gradient, textColour: $textColour, icon: $icon)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TitleStylingModelImpl &&
            const DeepCollectionEquality().equals(other._gradient, _gradient) &&
            (identical(other.textColour, textColour) ||
                other.textColour == textColour) &&
            (identical(other.icon, icon) || other.icon == icon));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(_gradient), textColour, icon);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TitleStylingModelImplCopyWith<_$TitleStylingModelImpl> get copyWith =>
      __$$TitleStylingModelImplCopyWithImpl<_$TitleStylingModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TitleStylingModelImplToJson(
      this,
    );
  }
}

abstract class _TitleStylingModel implements TitleStylingModel {
  const factory _TitleStylingModel(
      {final List<dynamic>? gradient,
      final String? textColour,
      final String? icon}) = _$TitleStylingModelImpl;

  factory _TitleStylingModel.fromJson(Map<String, dynamic> json) =
      _$TitleStylingModelImpl.fromJson;

  @override
  List<dynamic>? get gradient;
  @override
  String? get textColour;
  @override
  String? get icon;
  @override
  @JsonKey(ignore: true)
  _$$TitleStylingModelImplCopyWith<_$TitleStylingModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BodyStylingModel _$BodyStylingModelFromJson(Map<String, dynamic> json) {
  return _BodyStylingModel.fromJson(json);
}

/// @nodoc
mixin _$BodyStylingModel {
  dynamic get padding => throw _privateConstructorUsedError;
  GradientStylingModel? get gradient => throw _privateConstructorUsedError;
  dynamic get borderRadiusBottom => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BodyStylingModelCopyWith<BodyStylingModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BodyStylingModelCopyWith<$Res> {
  factory $BodyStylingModelCopyWith(
          BodyStylingModel value, $Res Function(BodyStylingModel) then) =
      _$BodyStylingModelCopyWithImpl<$Res, BodyStylingModel>;
  @useResult
  $Res call(
      {dynamic padding,
      GradientStylingModel? gradient,
      dynamic borderRadiusBottom});

  $GradientStylingModelCopyWith<$Res>? get gradient;
}

/// @nodoc
class _$BodyStylingModelCopyWithImpl<$Res, $Val extends BodyStylingModel>
    implements $BodyStylingModelCopyWith<$Res> {
  _$BodyStylingModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? padding = freezed,
    Object? gradient = freezed,
    Object? borderRadiusBottom = freezed,
  }) {
    return _then(_value.copyWith(
      padding: freezed == padding
          ? _value.padding
          : padding // ignore: cast_nullable_to_non_nullable
              as dynamic,
      gradient: freezed == gradient
          ? _value.gradient
          : gradient // ignore: cast_nullable_to_non_nullable
              as GradientStylingModel?,
      borderRadiusBottom: freezed == borderRadiusBottom
          ? _value.borderRadiusBottom
          : borderRadiusBottom // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $GradientStylingModelCopyWith<$Res>? get gradient {
    if (_value.gradient == null) {
      return null;
    }

    return $GradientStylingModelCopyWith<$Res>(_value.gradient!, (value) {
      return _then(_value.copyWith(gradient: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$BodyStylingModelImplCopyWith<$Res>
    implements $BodyStylingModelCopyWith<$Res> {
  factory _$$BodyStylingModelImplCopyWith(_$BodyStylingModelImpl value,
          $Res Function(_$BodyStylingModelImpl) then) =
      __$$BodyStylingModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {dynamic padding,
      GradientStylingModel? gradient,
      dynamic borderRadiusBottom});

  @override
  $GradientStylingModelCopyWith<$Res>? get gradient;
}

/// @nodoc
class __$$BodyStylingModelImplCopyWithImpl<$Res>
    extends _$BodyStylingModelCopyWithImpl<$Res, _$BodyStylingModelImpl>
    implements _$$BodyStylingModelImplCopyWith<$Res> {
  __$$BodyStylingModelImplCopyWithImpl(_$BodyStylingModelImpl _value,
      $Res Function(_$BodyStylingModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? padding = freezed,
    Object? gradient = freezed,
    Object? borderRadiusBottom = freezed,
  }) {
    return _then(_$BodyStylingModelImpl(
      padding: freezed == padding
          ? _value.padding
          : padding // ignore: cast_nullable_to_non_nullable
              as dynamic,
      gradient: freezed == gradient
          ? _value.gradient
          : gradient // ignore: cast_nullable_to_non_nullable
              as GradientStylingModel?,
      borderRadiusBottom: freezed == borderRadiusBottom
          ? _value.borderRadiusBottom
          : borderRadiusBottom // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BodyStylingModelImpl implements _BodyStylingModel {
  const _$BodyStylingModelImpl(
      {this.padding, this.gradient, this.borderRadiusBottom});

  factory _$BodyStylingModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$BodyStylingModelImplFromJson(json);

  @override
  final dynamic padding;
  @override
  final GradientStylingModel? gradient;
  @override
  final dynamic borderRadiusBottom;

  @override
  String toString() {
    return 'BodyStylingModel(padding: $padding, gradient: $gradient, borderRadiusBottom: $borderRadiusBottom)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BodyStylingModelImpl &&
            const DeepCollectionEquality().equals(other.padding, padding) &&
            (identical(other.gradient, gradient) ||
                other.gradient == gradient) &&
            const DeepCollectionEquality()
                .equals(other.borderRadiusBottom, borderRadiusBottom));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(padding),
      gradient,
      const DeepCollectionEquality().hash(borderRadiusBottom));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BodyStylingModelImplCopyWith<_$BodyStylingModelImpl> get copyWith =>
      __$$BodyStylingModelImplCopyWithImpl<_$BodyStylingModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BodyStylingModelImplToJson(
      this,
    );
  }
}

abstract class _BodyStylingModel implements BodyStylingModel {
  const factory _BodyStylingModel(
      {final dynamic padding,
      final GradientStylingModel? gradient,
      final dynamic borderRadiusBottom}) = _$BodyStylingModelImpl;

  factory _BodyStylingModel.fromJson(Map<String, dynamic> json) =
      _$BodyStylingModelImpl.fromJson;

  @override
  dynamic get padding;
  @override
  GradientStylingModel? get gradient;
  @override
  dynamic get borderRadiusBottom;
  @override
  @JsonKey(ignore: true)
  _$$BodyStylingModelImplCopyWith<_$BodyStylingModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GradientStylingModel _$GradientStylingModelFromJson(Map<String, dynamic> json) {
  return _GradientStylingModel.fromJson(json);
}

/// @nodoc
mixin _$GradientStylingModel {
  List<String>? get colors => throw _privateConstructorUsedError;
  String? get direction => throw _privateConstructorUsedError;
  List<double>? get start => throw _privateConstructorUsedError;
  List<double>? get end => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GradientStylingModelCopyWith<GradientStylingModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GradientStylingModelCopyWith<$Res> {
  factory $GradientStylingModelCopyWith(GradientStylingModel value,
          $Res Function(GradientStylingModel) then) =
      _$GradientStylingModelCopyWithImpl<$Res, GradientStylingModel>;
  @useResult
  $Res call(
      {List<String>? colors,
      String? direction,
      List<double>? start,
      List<double>? end});
}

/// @nodoc
class _$GradientStylingModelCopyWithImpl<$Res,
        $Val extends GradientStylingModel>
    implements $GradientStylingModelCopyWith<$Res> {
  _$GradientStylingModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? colors = freezed,
    Object? direction = freezed,
    Object? start = freezed,
    Object? end = freezed,
  }) {
    return _then(_value.copyWith(
      colors: freezed == colors
          ? _value.colors
          : colors // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      direction: freezed == direction
          ? _value.direction
          : direction // ignore: cast_nullable_to_non_nullable
              as String?,
      start: freezed == start
          ? _value.start
          : start // ignore: cast_nullable_to_non_nullable
              as List<double>?,
      end: freezed == end
          ? _value.end
          : end // ignore: cast_nullable_to_non_nullable
              as List<double>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GradientStylingModelImplCopyWith<$Res>
    implements $GradientStylingModelCopyWith<$Res> {
  factory _$$GradientStylingModelImplCopyWith(_$GradientStylingModelImpl value,
          $Res Function(_$GradientStylingModelImpl) then) =
      __$$GradientStylingModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<String>? colors,
      String? direction,
      List<double>? start,
      List<double>? end});
}

/// @nodoc
class __$$GradientStylingModelImplCopyWithImpl<$Res>
    extends _$GradientStylingModelCopyWithImpl<$Res, _$GradientStylingModelImpl>
    implements _$$GradientStylingModelImplCopyWith<$Res> {
  __$$GradientStylingModelImplCopyWithImpl(_$GradientStylingModelImpl _value,
      $Res Function(_$GradientStylingModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? colors = freezed,
    Object? direction = freezed,
    Object? start = freezed,
    Object? end = freezed,
  }) {
    return _then(_$GradientStylingModelImpl(
      colors: freezed == colors
          ? _value._colors
          : colors // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      direction: freezed == direction
          ? _value.direction
          : direction // ignore: cast_nullable_to_non_nullable
              as String?,
      start: freezed == start
          ? _value._start
          : start // ignore: cast_nullable_to_non_nullable
              as List<double>?,
      end: freezed == end
          ? _value._end
          : end // ignore: cast_nullable_to_non_nullable
              as List<double>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GradientStylingModelImpl implements _GradientStylingModel {
  const _$GradientStylingModelImpl(
      {final List<String>? colors,
      this.direction,
      final List<double>? start,
      final List<double>? end})
      : _colors = colors,
        _start = start,
        _end = end;

  factory _$GradientStylingModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$GradientStylingModelImplFromJson(json);

  final List<String>? _colors;
  @override
  List<String>? get colors {
    final value = _colors;
    if (value == null) return null;
    if (_colors is EqualUnmodifiableListView) return _colors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? direction;
  final List<double>? _start;
  @override
  List<double>? get start {
    final value = _start;
    if (value == null) return null;
    if (_start is EqualUnmodifiableListView) return _start;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<double>? _end;
  @override
  List<double>? get end {
    final value = _end;
    if (value == null) return null;
    if (_end is EqualUnmodifiableListView) return _end;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'GradientStylingModel(colors: $colors, direction: $direction, start: $start, end: $end)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GradientStylingModelImpl &&
            const DeepCollectionEquality().equals(other._colors, _colors) &&
            (identical(other.direction, direction) ||
                other.direction == direction) &&
            const DeepCollectionEquality().equals(other._start, _start) &&
            const DeepCollectionEquality().equals(other._end, _end));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_colors),
      direction,
      const DeepCollectionEquality().hash(_start),
      const DeepCollectionEquality().hash(_end));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GradientStylingModelImplCopyWith<_$GradientStylingModelImpl>
      get copyWith =>
          __$$GradientStylingModelImplCopyWithImpl<_$GradientStylingModelImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GradientStylingModelImplToJson(
      this,
    );
  }
}

abstract class _GradientStylingModel implements GradientStylingModel {
  const factory _GradientStylingModel(
      {final List<String>? colors,
      final String? direction,
      final List<double>? start,
      final List<double>? end}) = _$GradientStylingModelImpl;

  factory _GradientStylingModel.fromJson(Map<String, dynamic> json) =
      _$GradientStylingModelImpl.fromJson;

  @override
  List<String>? get colors;
  @override
  String? get direction;
  @override
  List<double>? get start;
  @override
  List<double>? get end;
  @override
  @JsonKey(ignore: true)
  _$$GradientStylingModelImplCopyWith<_$GradientStylingModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
