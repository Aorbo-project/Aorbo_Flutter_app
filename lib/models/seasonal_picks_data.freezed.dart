// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'seasonal_picks_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

SeasonalPicksDataResponseModel _$SeasonalPicksDataResponseModelFromJson(
    Map<String, dynamic> json) {
  return _SeasonalPicksDataResponseModel.fromJson(json);
}

/// @nodoc
mixin _$SeasonalPicksDataResponseModel {
  bool? get success => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;
  SeasonalPicksData? get data => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SeasonalPicksDataResponseModelCopyWith<SeasonalPicksDataResponseModel>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SeasonalPicksDataResponseModelCopyWith<$Res> {
  factory $SeasonalPicksDataResponseModelCopyWith(
          SeasonalPicksDataResponseModel value,
          $Res Function(SeasonalPicksDataResponseModel) then) =
      _$SeasonalPicksDataResponseModelCopyWithImpl<$Res,
          SeasonalPicksDataResponseModel>;
  @useResult
  $Res call({bool? success, String? message, SeasonalPicksData? data});

  $SeasonalPicksDataCopyWith<$Res>? get data;
}

/// @nodoc
class _$SeasonalPicksDataResponseModelCopyWithImpl<$Res,
        $Val extends SeasonalPicksDataResponseModel>
    implements $SeasonalPicksDataResponseModelCopyWith<$Res> {
  _$SeasonalPicksDataResponseModelCopyWithImpl(this._value, this._then);

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
              as SeasonalPicksData?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $SeasonalPicksDataCopyWith<$Res>? get data {
    if (_value.data == null) {
      return null;
    }

    return $SeasonalPicksDataCopyWith<$Res>(_value.data!, (value) {
      return _then(_value.copyWith(data: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SeasonalPicksDataResponseModelImplCopyWith<$Res>
    implements $SeasonalPicksDataResponseModelCopyWith<$Res> {
  factory _$$SeasonalPicksDataResponseModelImplCopyWith(
          _$SeasonalPicksDataResponseModelImpl value,
          $Res Function(_$SeasonalPicksDataResponseModelImpl) then) =
      __$$SeasonalPicksDataResponseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool? success, String? message, SeasonalPicksData? data});

  @override
  $SeasonalPicksDataCopyWith<$Res>? get data;
}

/// @nodoc
class __$$SeasonalPicksDataResponseModelImplCopyWithImpl<$Res>
    extends _$SeasonalPicksDataResponseModelCopyWithImpl<$Res,
        _$SeasonalPicksDataResponseModelImpl>
    implements _$$SeasonalPicksDataResponseModelImplCopyWith<$Res> {
  __$$SeasonalPicksDataResponseModelImplCopyWithImpl(
      _$SeasonalPicksDataResponseModelImpl _value,
      $Res Function(_$SeasonalPicksDataResponseModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = freezed,
    Object? message = freezed,
    Object? data = freezed,
  }) {
    return _then(_$SeasonalPicksDataResponseModelImpl(
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
              as SeasonalPicksData?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SeasonalPicksDataResponseModelImpl
    implements _SeasonalPicksDataResponseModel {
  const _$SeasonalPicksDataResponseModelImpl(
      {this.success, this.message, this.data});

  factory _$SeasonalPicksDataResponseModelImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$SeasonalPicksDataResponseModelImplFromJson(json);

  @override
  final bool? success;
  @override
  final String? message;
  @override
  final SeasonalPicksData? data;

  @override
  String toString() {
    return 'SeasonalPicksDataResponseModel(success: $success, message: $message, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SeasonalPicksDataResponseModelImpl &&
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
  _$$SeasonalPicksDataResponseModelImplCopyWith<
          _$SeasonalPicksDataResponseModelImpl>
      get copyWith => __$$SeasonalPicksDataResponseModelImplCopyWithImpl<
          _$SeasonalPicksDataResponseModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SeasonalPicksDataResponseModelImplToJson(
      this,
    );
  }
}

abstract class _SeasonalPicksDataResponseModel
    implements SeasonalPicksDataResponseModel {
  const factory _SeasonalPicksDataResponseModel(
      {final bool? success,
      final String? message,
      final SeasonalPicksData? data}) = _$SeasonalPicksDataResponseModelImpl;

  factory _SeasonalPicksDataResponseModel.fromJson(Map<String, dynamic> json) =
      _$SeasonalPicksDataResponseModelImpl.fromJson;

  @override
  bool? get success;
  @override
  String? get message;
  @override
  SeasonalPicksData? get data;
  @override
  @JsonKey(ignore: true)
  _$$SeasonalPicksDataResponseModelImplCopyWith<
          _$SeasonalPicksDataResponseModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}

SeasonalPicksData _$SeasonalPicksDataFromJson(Map<String, dynamic> json) {
  return _SeasonalPicksData.fromJson(json);
}

/// @nodoc
mixin _$SeasonalPicksData {
  String? get season => throw _privateConstructorUsedError;
  String? get label => throw _privateConstructorUsedError;
  @JsonKey(name: 'dateRange')
  String? get dateRange => throw _privateConstructorUsedError;
  String? get blurb => throw _privateConstructorUsedError;
  @JsonKey(name: 'topPicks')
  List<SeasonalPickItem>? get topPicks => throw _privateConstructorUsedError;
  @JsonKey(name: 'avoidPicks')
  List<SeasonalPickItem>? get avoidPicks => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SeasonalPicksDataCopyWith<SeasonalPicksData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SeasonalPicksDataCopyWith<$Res> {
  factory $SeasonalPicksDataCopyWith(
          SeasonalPicksData value, $Res Function(SeasonalPicksData) then) =
      _$SeasonalPicksDataCopyWithImpl<$Res, SeasonalPicksData>;
  @useResult
  $Res call(
      {String? season,
      String? label,
      @JsonKey(name: 'dateRange') String? dateRange,
      String? blurb,
      @JsonKey(name: 'topPicks') List<SeasonalPickItem>? topPicks,
      @JsonKey(name: 'avoidPicks') List<SeasonalPickItem>? avoidPicks});
}

/// @nodoc
class _$SeasonalPicksDataCopyWithImpl<$Res, $Val extends SeasonalPicksData>
    implements $SeasonalPicksDataCopyWith<$Res> {
  _$SeasonalPicksDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? season = freezed,
    Object? label = freezed,
    Object? dateRange = freezed,
    Object? blurb = freezed,
    Object? topPicks = freezed,
    Object? avoidPicks = freezed,
  }) {
    return _then(_value.copyWith(
      season: freezed == season
          ? _value.season
          : season // ignore: cast_nullable_to_non_nullable
              as String?,
      label: freezed == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String?,
      dateRange: freezed == dateRange
          ? _value.dateRange
          : dateRange // ignore: cast_nullable_to_non_nullable
              as String?,
      blurb: freezed == blurb
          ? _value.blurb
          : blurb // ignore: cast_nullable_to_non_nullable
              as String?,
      topPicks: freezed == topPicks
          ? _value.topPicks
          : topPicks // ignore: cast_nullable_to_non_nullable
              as List<SeasonalPickItem>?,
      avoidPicks: freezed == avoidPicks
          ? _value.avoidPicks
          : avoidPicks // ignore: cast_nullable_to_non_nullable
              as List<SeasonalPickItem>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SeasonalPicksDataImplCopyWith<$Res>
    implements $SeasonalPicksDataCopyWith<$Res> {
  factory _$$SeasonalPicksDataImplCopyWith(_$SeasonalPicksDataImpl value,
          $Res Function(_$SeasonalPicksDataImpl) then) =
      __$$SeasonalPicksDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? season,
      String? label,
      @JsonKey(name: 'dateRange') String? dateRange,
      String? blurb,
      @JsonKey(name: 'topPicks') List<SeasonalPickItem>? topPicks,
      @JsonKey(name: 'avoidPicks') List<SeasonalPickItem>? avoidPicks});
}

/// @nodoc
class __$$SeasonalPicksDataImplCopyWithImpl<$Res>
    extends _$SeasonalPicksDataCopyWithImpl<$Res, _$SeasonalPicksDataImpl>
    implements _$$SeasonalPicksDataImplCopyWith<$Res> {
  __$$SeasonalPicksDataImplCopyWithImpl(_$SeasonalPicksDataImpl _value,
      $Res Function(_$SeasonalPicksDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? season = freezed,
    Object? label = freezed,
    Object? dateRange = freezed,
    Object? blurb = freezed,
    Object? topPicks = freezed,
    Object? avoidPicks = freezed,
  }) {
    return _then(_$SeasonalPicksDataImpl(
      season: freezed == season
          ? _value.season
          : season // ignore: cast_nullable_to_non_nullable
              as String?,
      label: freezed == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String?,
      dateRange: freezed == dateRange
          ? _value.dateRange
          : dateRange // ignore: cast_nullable_to_non_nullable
              as String?,
      blurb: freezed == blurb
          ? _value.blurb
          : blurb // ignore: cast_nullable_to_non_nullable
              as String?,
      topPicks: freezed == topPicks
          ? _value._topPicks
          : topPicks // ignore: cast_nullable_to_non_nullable
              as List<SeasonalPickItem>?,
      avoidPicks: freezed == avoidPicks
          ? _value._avoidPicks
          : avoidPicks // ignore: cast_nullable_to_non_nullable
              as List<SeasonalPickItem>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SeasonalPicksDataImpl implements _SeasonalPicksData {
  const _$SeasonalPicksDataImpl(
      {this.season,
      this.label,
      @JsonKey(name: 'dateRange') this.dateRange,
      this.blurb,
      @JsonKey(name: 'topPicks') final List<SeasonalPickItem>? topPicks,
      @JsonKey(name: 'avoidPicks') final List<SeasonalPickItem>? avoidPicks})
      : _topPicks = topPicks,
        _avoidPicks = avoidPicks;

  factory _$SeasonalPicksDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$SeasonalPicksDataImplFromJson(json);

  @override
  final String? season;
  @override
  final String? label;
  @override
  @JsonKey(name: 'dateRange')
  final String? dateRange;
  @override
  final String? blurb;
  final List<SeasonalPickItem>? _topPicks;
  @override
  @JsonKey(name: 'topPicks')
  List<SeasonalPickItem>? get topPicks {
    final value = _topPicks;
    if (value == null) return null;
    if (_topPicks is EqualUnmodifiableListView) return _topPicks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<SeasonalPickItem>? _avoidPicks;
  @override
  @JsonKey(name: 'avoidPicks')
  List<SeasonalPickItem>? get avoidPicks {
    final value = _avoidPicks;
    if (value == null) return null;
    if (_avoidPicks is EqualUnmodifiableListView) return _avoidPicks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'SeasonalPicksData(season: $season, label: $label, dateRange: $dateRange, blurb: $blurb, topPicks: $topPicks, avoidPicks: $avoidPicks)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SeasonalPicksDataImpl &&
            (identical(other.season, season) || other.season == season) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.dateRange, dateRange) ||
                other.dateRange == dateRange) &&
            (identical(other.blurb, blurb) || other.blurb == blurb) &&
            const DeepCollectionEquality().equals(other._topPicks, _topPicks) &&
            const DeepCollectionEquality()
                .equals(other._avoidPicks, _avoidPicks));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      season,
      label,
      dateRange,
      blurb,
      const DeepCollectionEquality().hash(_topPicks),
      const DeepCollectionEquality().hash(_avoidPicks));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SeasonalPicksDataImplCopyWith<_$SeasonalPicksDataImpl> get copyWith =>
      __$$SeasonalPicksDataImplCopyWithImpl<_$SeasonalPicksDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SeasonalPicksDataImplToJson(
      this,
    );
  }
}

abstract class _SeasonalPicksData implements SeasonalPicksData {
  const factory _SeasonalPicksData(
      {final String? season,
      final String? label,
      @JsonKey(name: 'dateRange') final String? dateRange,
      final String? blurb,
      @JsonKey(name: 'topPicks') final List<SeasonalPickItem>? topPicks,
      @JsonKey(name: 'avoidPicks')
      final List<SeasonalPickItem>? avoidPicks}) = _$SeasonalPicksDataImpl;

  factory _SeasonalPicksData.fromJson(Map<String, dynamic> json) =
      _$SeasonalPicksDataImpl.fromJson;

  @override
  String? get season;
  @override
  String? get label;
  @override
  @JsonKey(name: 'dateRange')
  String? get dateRange;
  @override
  String? get blurb;
  @override
  @JsonKey(name: 'topPicks')
  List<SeasonalPickItem>? get topPicks;
  @override
  @JsonKey(name: 'avoidPicks')
  List<SeasonalPickItem>? get avoidPicks;
  @override
  @JsonKey(ignore: true)
  _$$SeasonalPicksDataImplCopyWith<_$SeasonalPicksDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SeasonalPickItem _$SeasonalPickItemFromJson(Map<String, dynamic> json) {
  return _SeasonalPickItem.fromJson(json);
}

/// @nodoc
mixin _$SeasonalPickItem {
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'trekName')
  String? get trekName => throw _privateConstructorUsedError;
  String? get reason => throw _privateConstructorUsedError;
  @JsonKey(name: 'imagePath')
  String? get imagePath => throw _privateConstructorUsedError;
  @JsonKey(name: 'imageType')
  String? get imageType => throw _privateConstructorUsedError;
  @JsonKey(name: 'isAvoid')
  bool? get isAvoid => throw _privateConstructorUsedError;
  @JsonKey(name: 'trekId')
  int? get trekId => throw _privateConstructorUsedError;
  @JsonKey(name: 'detailUrl')
  String? get detailUrl => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SeasonalPickItemCopyWith<SeasonalPickItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SeasonalPickItemCopyWith<$Res> {
  factory $SeasonalPickItemCopyWith(
          SeasonalPickItem value, $Res Function(SeasonalPickItem) then) =
      _$SeasonalPickItemCopyWithImpl<$Res, SeasonalPickItem>;
  @useResult
  $Res call(
      {int? id,
      @JsonKey(name: 'trekName') String? trekName,
      String? reason,
      @JsonKey(name: 'imagePath') String? imagePath,
      @JsonKey(name: 'imageType') String? imageType,
      @JsonKey(name: 'isAvoid') bool? isAvoid,
      @JsonKey(name: 'trekId') int? trekId,
      @JsonKey(name: 'detailUrl') String? detailUrl});
}

/// @nodoc
class _$SeasonalPickItemCopyWithImpl<$Res, $Val extends SeasonalPickItem>
    implements $SeasonalPickItemCopyWith<$Res> {
  _$SeasonalPickItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? trekName = freezed,
    Object? reason = freezed,
    Object? imagePath = freezed,
    Object? imageType = freezed,
    Object? isAvoid = freezed,
    Object? trekId = freezed,
    Object? detailUrl = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      trekName: freezed == trekName
          ? _value.trekName
          : trekName // ignore: cast_nullable_to_non_nullable
              as String?,
      reason: freezed == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String?,
      imagePath: freezed == imagePath
          ? _value.imagePath
          : imagePath // ignore: cast_nullable_to_non_nullable
              as String?,
      imageType: freezed == imageType
          ? _value.imageType
          : imageType // ignore: cast_nullable_to_non_nullable
              as String?,
      isAvoid: freezed == isAvoid
          ? _value.isAvoid
          : isAvoid // ignore: cast_nullable_to_non_nullable
              as bool?,
      trekId: freezed == trekId
          ? _value.trekId
          : trekId // ignore: cast_nullable_to_non_nullable
              as int?,
      detailUrl: freezed == detailUrl
          ? _value.detailUrl
          : detailUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SeasonalPickItemImplCopyWith<$Res>
    implements $SeasonalPickItemCopyWith<$Res> {
  factory _$$SeasonalPickItemImplCopyWith(_$SeasonalPickItemImpl value,
          $Res Function(_$SeasonalPickItemImpl) then) =
      __$$SeasonalPickItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? id,
      @JsonKey(name: 'trekName') String? trekName,
      String? reason,
      @JsonKey(name: 'imagePath') String? imagePath,
      @JsonKey(name: 'imageType') String? imageType,
      @JsonKey(name: 'isAvoid') bool? isAvoid,
      @JsonKey(name: 'trekId') int? trekId,
      @JsonKey(name: 'detailUrl') String? detailUrl});
}

/// @nodoc
class __$$SeasonalPickItemImplCopyWithImpl<$Res>
    extends _$SeasonalPickItemCopyWithImpl<$Res, _$SeasonalPickItemImpl>
    implements _$$SeasonalPickItemImplCopyWith<$Res> {
  __$$SeasonalPickItemImplCopyWithImpl(_$SeasonalPickItemImpl _value,
      $Res Function(_$SeasonalPickItemImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? trekName = freezed,
    Object? reason = freezed,
    Object? imagePath = freezed,
    Object? imageType = freezed,
    Object? isAvoid = freezed,
    Object? trekId = freezed,
    Object? detailUrl = freezed,
  }) {
    return _then(_$SeasonalPickItemImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      trekName: freezed == trekName
          ? _value.trekName
          : trekName // ignore: cast_nullable_to_non_nullable
              as String?,
      reason: freezed == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String?,
      imagePath: freezed == imagePath
          ? _value.imagePath
          : imagePath // ignore: cast_nullable_to_non_nullable
              as String?,
      imageType: freezed == imageType
          ? _value.imageType
          : imageType // ignore: cast_nullable_to_non_nullable
              as String?,
      isAvoid: freezed == isAvoid
          ? _value.isAvoid
          : isAvoid // ignore: cast_nullable_to_non_nullable
              as bool?,
      trekId: freezed == trekId
          ? _value.trekId
          : trekId // ignore: cast_nullable_to_non_nullable
              as int?,
      detailUrl: freezed == detailUrl
          ? _value.detailUrl
          : detailUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SeasonalPickItemImpl implements _SeasonalPickItem {
  const _$SeasonalPickItemImpl(
      {this.id,
      @JsonKey(name: 'trekName') this.trekName,
      this.reason,
      @JsonKey(name: 'imagePath') this.imagePath,
      @JsonKey(name: 'imageType') this.imageType,
      @JsonKey(name: 'isAvoid') this.isAvoid,
      @JsonKey(name: 'trekId') this.trekId,
      @JsonKey(name: 'detailUrl') this.detailUrl});

  factory _$SeasonalPickItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$SeasonalPickItemImplFromJson(json);

  @override
  final int? id;
  @override
  @JsonKey(name: 'trekName')
  final String? trekName;
  @override
  final String? reason;
  @override
  @JsonKey(name: 'imagePath')
  final String? imagePath;
  @override
  @JsonKey(name: 'imageType')
  final String? imageType;
  @override
  @JsonKey(name: 'isAvoid')
  final bool? isAvoid;
  @override
  @JsonKey(name: 'trekId')
  final int? trekId;
  @override
  @JsonKey(name: 'detailUrl')
  final String? detailUrl;

  @override
  String toString() {
    return 'SeasonalPickItem(id: $id, trekName: $trekName, reason: $reason, imagePath: $imagePath, imageType: $imageType, isAvoid: $isAvoid, trekId: $trekId, detailUrl: $detailUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SeasonalPickItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.trekName, trekName) ||
                other.trekName == trekName) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.imagePath, imagePath) ||
                other.imagePath == imagePath) &&
            (identical(other.imageType, imageType) ||
                other.imageType == imageType) &&
            (identical(other.isAvoid, isAvoid) || other.isAvoid == isAvoid) &&
            (identical(other.trekId, trekId) || other.trekId == trekId) &&
            (identical(other.detailUrl, detailUrl) ||
                other.detailUrl == detailUrl));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, trekName, reason, imagePath,
      imageType, isAvoid, trekId, detailUrl);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SeasonalPickItemImplCopyWith<_$SeasonalPickItemImpl> get copyWith =>
      __$$SeasonalPickItemImplCopyWithImpl<_$SeasonalPickItemImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SeasonalPickItemImplToJson(
      this,
    );
  }
}

abstract class _SeasonalPickItem implements SeasonalPickItem {
  const factory _SeasonalPickItem(
          {final int? id,
          @JsonKey(name: 'trekName') final String? trekName,
          final String? reason,
          @JsonKey(name: 'imagePath') final String? imagePath,
          @JsonKey(name: 'imageType') final String? imageType,
          @JsonKey(name: 'isAvoid') final bool? isAvoid,
          @JsonKey(name: 'trekId') final int? trekId,
          @JsonKey(name: 'detailUrl') final String? detailUrl}) =
      _$SeasonalPickItemImpl;

  factory _SeasonalPickItem.fromJson(Map<String, dynamic> json) =
      _$SeasonalPickItemImpl.fromJson;

  @override
  int? get id;
  @override
  @JsonKey(name: 'trekName')
  String? get trekName;
  @override
  String? get reason;
  @override
  @JsonKey(name: 'imagePath')
  String? get imagePath;
  @override
  @JsonKey(name: 'imageType')
  String? get imageType;
  @override
  @JsonKey(name: 'isAvoid')
  bool? get isAvoid;
  @override
  @JsonKey(name: 'trekId')
  int? get trekId;
  @override
  @JsonKey(name: 'detailUrl')
  String? get detailUrl;
  @override
  @JsonKey(ignore: true)
  _$$SeasonalPickItemImplCopyWith<_$SeasonalPickItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
