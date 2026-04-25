// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'treks_model_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

CalenderDatesResponseModel _$CalenderDatesResponseModelFromJson(
    Map<String, dynamic> json) {
  return _CalenderDatesResponseModel.fromJson(json);
}

/// @nodoc
mixin _$CalenderDatesResponseModel {
  bool? get success => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;
  CalenderDataModel? get data => throw _privateConstructorUsedError;
  int? get count => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CalenderDatesResponseModelCopyWith<CalenderDatesResponseModel>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CalenderDatesResponseModelCopyWith<$Res> {
  factory $CalenderDatesResponseModelCopyWith(CalenderDatesResponseModel value,
          $Res Function(CalenderDatesResponseModel) then) =
      _$CalenderDatesResponseModelCopyWithImpl<$Res,
          CalenderDatesResponseModel>;
  @useResult
  $Res call(
      {bool? success, String? message, CalenderDataModel? data, int? count});

  $CalenderDataModelCopyWith<$Res>? get data;
}

/// @nodoc
class _$CalenderDatesResponseModelCopyWithImpl<$Res,
        $Val extends CalenderDatesResponseModel>
    implements $CalenderDatesResponseModelCopyWith<$Res> {
  _$CalenderDatesResponseModelCopyWithImpl(this._value, this._then);

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
              as CalenderDataModel?,
      count: freezed == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $CalenderDataModelCopyWith<$Res>? get data {
    if (_value.data == null) {
      return null;
    }

    return $CalenderDataModelCopyWith<$Res>(_value.data!, (value) {
      return _then(_value.copyWith(data: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CalenderDatesResponseModelImplCopyWith<$Res>
    implements $CalenderDatesResponseModelCopyWith<$Res> {
  factory _$$CalenderDatesResponseModelImplCopyWith(
          _$CalenderDatesResponseModelImpl value,
          $Res Function(_$CalenderDatesResponseModelImpl) then) =
      __$$CalenderDatesResponseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool? success, String? message, CalenderDataModel? data, int? count});

  @override
  $CalenderDataModelCopyWith<$Res>? get data;
}

/// @nodoc
class __$$CalenderDatesResponseModelImplCopyWithImpl<$Res>
    extends _$CalenderDatesResponseModelCopyWithImpl<$Res,
        _$CalenderDatesResponseModelImpl>
    implements _$$CalenderDatesResponseModelImplCopyWith<$Res> {
  __$$CalenderDatesResponseModelImplCopyWithImpl(
      _$CalenderDatesResponseModelImpl _value,
      $Res Function(_$CalenderDatesResponseModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = freezed,
    Object? message = freezed,
    Object? data = freezed,
    Object? count = freezed,
  }) {
    return _then(_$CalenderDatesResponseModelImpl(
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
              as CalenderDataModel?,
      count: freezed == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CalenderDatesResponseModelImpl implements _CalenderDatesResponseModel {
  const _$CalenderDatesResponseModelImpl(
      {this.success, this.message, this.data, this.count});

  factory _$CalenderDatesResponseModelImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$CalenderDatesResponseModelImplFromJson(json);

  @override
  final bool? success;
  @override
  final String? message;
  @override
  final CalenderDataModel? data;
  @override
  final int? count;

  @override
  String toString() {
    return 'CalenderDatesResponseModel(success: $success, message: $message, data: $data, count: $count)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CalenderDatesResponseModelImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.data, data) || other.data == data) &&
            (identical(other.count, count) || other.count == count));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, success, message, data, count);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CalenderDatesResponseModelImplCopyWith<_$CalenderDatesResponseModelImpl>
      get copyWith => __$$CalenderDatesResponseModelImplCopyWithImpl<
          _$CalenderDatesResponseModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CalenderDatesResponseModelImplToJson(
      this,
    );
  }
}

abstract class _CalenderDatesResponseModel
    implements CalenderDatesResponseModel {
  const factory _CalenderDatesResponseModel(
      {final bool? success,
      final String? message,
      final CalenderDataModel? data,
      final int? count}) = _$CalenderDatesResponseModelImpl;

  factory _CalenderDatesResponseModel.fromJson(Map<String, dynamic> json) =
      _$CalenderDatesResponseModelImpl.fromJson;

  @override
  bool? get success;
  @override
  String? get message;
  @override
  CalenderDataModel? get data;
  @override
  int? get count;
  @override
  @JsonKey(ignore: true)
  _$$CalenderDatesResponseModelImplCopyWith<_$CalenderDatesResponseModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}

CalenderDataModel _$CalenderDataModelFromJson(Map<String, dynamic> json) {
  return _CalenderDataModel.fromJson(json);
}

/// @nodoc
mixin _$CalenderDataModel {
  @JsonKey(name: 'start_date')
  String? get startDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'end_date')
  String? get endDate => throw _privateConstructorUsedError;
  List<TrekDatesModel>? get dates => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_dates_with_treks')
  int? get totalDatesWithTreks => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CalenderDataModelCopyWith<CalenderDataModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CalenderDataModelCopyWith<$Res> {
  factory $CalenderDataModelCopyWith(
          CalenderDataModel value, $Res Function(CalenderDataModel) then) =
      _$CalenderDataModelCopyWithImpl<$Res, CalenderDataModel>;
  @useResult
  $Res call(
      {@JsonKey(name: 'start_date') String? startDate,
      @JsonKey(name: 'end_date') String? endDate,
      List<TrekDatesModel>? dates,
      @JsonKey(name: 'total_dates_with_treks') int? totalDatesWithTreks});
}

/// @nodoc
class _$CalenderDataModelCopyWithImpl<$Res, $Val extends CalenderDataModel>
    implements $CalenderDataModelCopyWith<$Res> {
  _$CalenderDataModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? dates = freezed,
    Object? totalDatesWithTreks = freezed,
  }) {
    return _then(_value.copyWith(
      startDate: freezed == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as String?,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as String?,
      dates: freezed == dates
          ? _value.dates
          : dates // ignore: cast_nullable_to_non_nullable
              as List<TrekDatesModel>?,
      totalDatesWithTreks: freezed == totalDatesWithTreks
          ? _value.totalDatesWithTreks
          : totalDatesWithTreks // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CalenderDataModelImplCopyWith<$Res>
    implements $CalenderDataModelCopyWith<$Res> {
  factory _$$CalenderDataModelImplCopyWith(_$CalenderDataModelImpl value,
          $Res Function(_$CalenderDataModelImpl) then) =
      __$$CalenderDataModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'start_date') String? startDate,
      @JsonKey(name: 'end_date') String? endDate,
      List<TrekDatesModel>? dates,
      @JsonKey(name: 'total_dates_with_treks') int? totalDatesWithTreks});
}

/// @nodoc
class __$$CalenderDataModelImplCopyWithImpl<$Res>
    extends _$CalenderDataModelCopyWithImpl<$Res, _$CalenderDataModelImpl>
    implements _$$CalenderDataModelImplCopyWith<$Res> {
  __$$CalenderDataModelImplCopyWithImpl(_$CalenderDataModelImpl _value,
      $Res Function(_$CalenderDataModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? dates = freezed,
    Object? totalDatesWithTreks = freezed,
  }) {
    return _then(_$CalenderDataModelImpl(
      startDate: freezed == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as String?,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as String?,
      dates: freezed == dates
          ? _value._dates
          : dates // ignore: cast_nullable_to_non_nullable
              as List<TrekDatesModel>?,
      totalDatesWithTreks: freezed == totalDatesWithTreks
          ? _value.totalDatesWithTreks
          : totalDatesWithTreks // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CalenderDataModelImpl implements _CalenderDataModel {
  const _$CalenderDataModelImpl(
      {@JsonKey(name: 'start_date') this.startDate,
      @JsonKey(name: 'end_date') this.endDate,
      final List<TrekDatesModel>? dates,
      @JsonKey(name: 'total_dates_with_treks') this.totalDatesWithTreks})
      : _dates = dates;

  factory _$CalenderDataModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$CalenderDataModelImplFromJson(json);

  @override
  @JsonKey(name: 'start_date')
  final String? startDate;
  @override
  @JsonKey(name: 'end_date')
  final String? endDate;
  final List<TrekDatesModel>? _dates;
  @override
  List<TrekDatesModel>? get dates {
    final value = _dates;
    if (value == null) return null;
    if (_dates is EqualUnmodifiableListView) return _dates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'total_dates_with_treks')
  final int? totalDatesWithTreks;

  @override
  String toString() {
    return 'CalenderDataModel(startDate: $startDate, endDate: $endDate, dates: $dates, totalDatesWithTreks: $totalDatesWithTreks)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CalenderDataModelImpl &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            const DeepCollectionEquality().equals(other._dates, _dates) &&
            (identical(other.totalDatesWithTreks, totalDatesWithTreks) ||
                other.totalDatesWithTreks == totalDatesWithTreks));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, startDate, endDate,
      const DeepCollectionEquality().hash(_dates), totalDatesWithTreks);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CalenderDataModelImplCopyWith<_$CalenderDataModelImpl> get copyWith =>
      __$$CalenderDataModelImplCopyWithImpl<_$CalenderDataModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CalenderDataModelImplToJson(
      this,
    );
  }
}

abstract class _CalenderDataModel implements CalenderDataModel {
  const factory _CalenderDataModel(
      {@JsonKey(name: 'start_date') final String? startDate,
      @JsonKey(name: 'end_date') final String? endDate,
      final List<TrekDatesModel>? dates,
      @JsonKey(name: 'total_dates_with_treks')
      final int? totalDatesWithTreks}) = _$CalenderDataModelImpl;

  factory _CalenderDataModel.fromJson(Map<String, dynamic> json) =
      _$CalenderDataModelImpl.fromJson;

  @override
  @JsonKey(name: 'start_date')
  String? get startDate;
  @override
  @JsonKey(name: 'end_date')
  String? get endDate;
  @override
  List<TrekDatesModel>? get dates;
  @override
  @JsonKey(name: 'total_dates_with_treks')
  int? get totalDatesWithTreks;
  @override
  @JsonKey(ignore: true)
  _$$CalenderDataModelImplCopyWith<_$CalenderDataModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TrekDatesModel _$TrekDatesModelFromJson(Map<String, dynamic> json) {
  return _TrekDatesModel.fromJson(json);
}

/// @nodoc
mixin _$TrekDatesModel {
  String? get date => throw _privateConstructorUsedError;
  @JsonKey(name: 'trek_count')
  int? get trekCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'has_treks')
  bool? get available => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TrekDatesModelCopyWith<TrekDatesModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrekDatesModelCopyWith<$Res> {
  factory $TrekDatesModelCopyWith(
          TrekDatesModel value, $Res Function(TrekDatesModel) then) =
      _$TrekDatesModelCopyWithImpl<$Res, TrekDatesModel>;
  @useResult
  $Res call(
      {String? date,
      @JsonKey(name: 'trek_count') int? trekCount,
      @JsonKey(name: 'has_treks') bool? available});
}

/// @nodoc
class _$TrekDatesModelCopyWithImpl<$Res, $Val extends TrekDatesModel>
    implements $TrekDatesModelCopyWith<$Res> {
  _$TrekDatesModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = freezed,
    Object? trekCount = freezed,
    Object? available = freezed,
  }) {
    return _then(_value.copyWith(
      date: freezed == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as String?,
      trekCount: freezed == trekCount
          ? _value.trekCount
          : trekCount // ignore: cast_nullable_to_non_nullable
              as int?,
      available: freezed == available
          ? _value.available
          : available // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TrekDatesModelImplCopyWith<$Res>
    implements $TrekDatesModelCopyWith<$Res> {
  factory _$$TrekDatesModelImplCopyWith(_$TrekDatesModelImpl value,
          $Res Function(_$TrekDatesModelImpl) then) =
      __$$TrekDatesModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? date,
      @JsonKey(name: 'trek_count') int? trekCount,
      @JsonKey(name: 'has_treks') bool? available});
}

/// @nodoc
class __$$TrekDatesModelImplCopyWithImpl<$Res>
    extends _$TrekDatesModelCopyWithImpl<$Res, _$TrekDatesModelImpl>
    implements _$$TrekDatesModelImplCopyWith<$Res> {
  __$$TrekDatesModelImplCopyWithImpl(
      _$TrekDatesModelImpl _value, $Res Function(_$TrekDatesModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = freezed,
    Object? trekCount = freezed,
    Object? available = freezed,
  }) {
    return _then(_$TrekDatesModelImpl(
      date: freezed == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as String?,
      trekCount: freezed == trekCount
          ? _value.trekCount
          : trekCount // ignore: cast_nullable_to_non_nullable
              as int?,
      available: freezed == available
          ? _value.available
          : available // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TrekDatesModelImpl implements _TrekDatesModel {
  const _$TrekDatesModelImpl(
      {this.date,
      @JsonKey(name: 'trek_count') this.trekCount,
      @JsonKey(name: 'has_treks') this.available});

  factory _$TrekDatesModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TrekDatesModelImplFromJson(json);

  @override
  final String? date;
  @override
  @JsonKey(name: 'trek_count')
  final int? trekCount;
  @override
  @JsonKey(name: 'has_treks')
  final bool? available;

  @override
  String toString() {
    return 'TrekDatesModel(date: $date, trekCount: $trekCount, available: $available)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrekDatesModelImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.trekCount, trekCount) ||
                other.trekCount == trekCount) &&
            (identical(other.available, available) ||
                other.available == available));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, date, trekCount, available);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TrekDatesModelImplCopyWith<_$TrekDatesModelImpl> get copyWith =>
      __$$TrekDatesModelImplCopyWithImpl<_$TrekDatesModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TrekDatesModelImplToJson(
      this,
    );
  }
}

abstract class _TrekDatesModel implements TrekDatesModel {
  const factory _TrekDatesModel(
          {final String? date,
          @JsonKey(name: 'trek_count') final int? trekCount,
          @JsonKey(name: 'has_treks') final bool? available}) =
      _$TrekDatesModelImpl;

  factory _TrekDatesModel.fromJson(Map<String, dynamic> json) =
      _$TrekDatesModelImpl.fromJson;

  @override
  String? get date;
  @override
  @JsonKey(name: 'trek_count')
  int? get trekCount;
  @override
  @JsonKey(name: 'has_treks')
  bool? get available;
  @override
  @JsonKey(ignore: true)
  _$$TrekDatesModelImplCopyWith<_$TrekDatesModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FetchTreksResponseModel _$FetchTreksResponseModelFromJson(
    Map<String, dynamic> json) {
  return _FetchTreksResponseModel.fromJson(json);
}

/// @nodoc
mixin _$FetchTreksResponseModel {
  bool? get success => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;
  @JsonKey(name: "search_context")
  SearchContextModel? get searchContext => throw _privateConstructorUsedError;
  List<TrekData>? get data => throw _privateConstructorUsedError;
  int? get count => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $FetchTreksResponseModelCopyWith<FetchTreksResponseModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FetchTreksResponseModelCopyWith<$Res> {
  factory $FetchTreksResponseModelCopyWith(FetchTreksResponseModel value,
          $Res Function(FetchTreksResponseModel) then) =
      _$FetchTreksResponseModelCopyWithImpl<$Res, FetchTreksResponseModel>;
  @useResult
  $Res call(
      {bool? success,
      String? message,
      @JsonKey(name: "search_context") SearchContextModel? searchContext,
      List<TrekData>? data,
      int? count});

  $SearchContextModelCopyWith<$Res>? get searchContext;
}

/// @nodoc
class _$FetchTreksResponseModelCopyWithImpl<$Res,
        $Val extends FetchTreksResponseModel>
    implements $FetchTreksResponseModelCopyWith<$Res> {
  _$FetchTreksResponseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = freezed,
    Object? message = freezed,
    Object? searchContext = freezed,
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
      searchContext: freezed == searchContext
          ? _value.searchContext
          : searchContext // ignore: cast_nullable_to_non_nullable
              as SearchContextModel?,
      data: freezed == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as List<TrekData>?,
      count: freezed == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $SearchContextModelCopyWith<$Res>? get searchContext {
    if (_value.searchContext == null) {
      return null;
    }

    return $SearchContextModelCopyWith<$Res>(_value.searchContext!, (value) {
      return _then(_value.copyWith(searchContext: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$FetchTreksResponseModelImplCopyWith<$Res>
    implements $FetchTreksResponseModelCopyWith<$Res> {
  factory _$$FetchTreksResponseModelImplCopyWith(
          _$FetchTreksResponseModelImpl value,
          $Res Function(_$FetchTreksResponseModelImpl) then) =
      __$$FetchTreksResponseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool? success,
      String? message,
      @JsonKey(name: "search_context") SearchContextModel? searchContext,
      List<TrekData>? data,
      int? count});

  @override
  $SearchContextModelCopyWith<$Res>? get searchContext;
}

/// @nodoc
class __$$FetchTreksResponseModelImplCopyWithImpl<$Res>
    extends _$FetchTreksResponseModelCopyWithImpl<$Res,
        _$FetchTreksResponseModelImpl>
    implements _$$FetchTreksResponseModelImplCopyWith<$Res> {
  __$$FetchTreksResponseModelImplCopyWithImpl(
      _$FetchTreksResponseModelImpl _value,
      $Res Function(_$FetchTreksResponseModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = freezed,
    Object? message = freezed,
    Object? searchContext = freezed,
    Object? data = freezed,
    Object? count = freezed,
  }) {
    return _then(_$FetchTreksResponseModelImpl(
      success: freezed == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool?,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      searchContext: freezed == searchContext
          ? _value.searchContext
          : searchContext // ignore: cast_nullable_to_non_nullable
              as SearchContextModel?,
      data: freezed == data
          ? _value._data
          : data // ignore: cast_nullable_to_non_nullable
              as List<TrekData>?,
      count: freezed == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FetchTreksResponseModelImpl implements _FetchTreksResponseModel {
  const _$FetchTreksResponseModelImpl(
      {this.success,
      this.message,
      @JsonKey(name: "search_context") this.searchContext,
      final List<TrekData>? data,
      this.count})
      : _data = data;

  factory _$FetchTreksResponseModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$FetchTreksResponseModelImplFromJson(json);

  @override
  final bool? success;
  @override
  final String? message;
  @override
  @JsonKey(name: "search_context")
  final SearchContextModel? searchContext;
  final List<TrekData>? _data;
  @override
  List<TrekData>? get data {
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
    return 'FetchTreksResponseModel(success: $success, message: $message, searchContext: $searchContext, data: $data, count: $count)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FetchTreksResponseModelImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.searchContext, searchContext) ||
                other.searchContext == searchContext) &&
            const DeepCollectionEquality().equals(other._data, _data) &&
            (identical(other.count, count) || other.count == count));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, success, message, searchContext,
      const DeepCollectionEquality().hash(_data), count);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$FetchTreksResponseModelImplCopyWith<_$FetchTreksResponseModelImpl>
      get copyWith => __$$FetchTreksResponseModelImplCopyWithImpl<
          _$FetchTreksResponseModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FetchTreksResponseModelImplToJson(
      this,
    );
  }
}

abstract class _FetchTreksResponseModel implements FetchTreksResponseModel {
  const factory _FetchTreksResponseModel(
      {final bool? success,
      final String? message,
      @JsonKey(name: "search_context") final SearchContextModel? searchContext,
      final List<TrekData>? data,
      final int? count}) = _$FetchTreksResponseModelImpl;

  factory _FetchTreksResponseModel.fromJson(Map<String, dynamic> json) =
      _$FetchTreksResponseModelImpl.fromJson;

  @override
  bool? get success;
  @override
  String? get message;
  @override
  @JsonKey(name: "search_context")
  SearchContextModel? get searchContext;
  @override
  List<TrekData>? get data;
  @override
  int? get count;
  @override
  @JsonKey(ignore: true)
  _$$FetchTreksResponseModelImplCopyWith<_$FetchTreksResponseModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}

SearchContextModel _$SearchContextModelFromJson(Map<String, dynamic> json) {
  return _SearchContextModel.fromJson(json);
}

/// @nodoc
mixin _$SearchContextModel {
  String? get from => throw _privateConstructorUsedError;
  String? get to => throw _privateConstructorUsedError;
  @JsonKey(name: "selected_date")
  dynamic get selectedDate => throw _privateConstructorUsedError;
  @JsonKey(name: "weekend_mode")
  bool? get weekendMode => throw _privateConstructorUsedError;
  @JsonKey(name: "weekend_days")
  List<String>? get weekendDates => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SearchContextModelCopyWith<SearchContextModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SearchContextModelCopyWith<$Res> {
  factory $SearchContextModelCopyWith(
          SearchContextModel value, $Res Function(SearchContextModel) then) =
      _$SearchContextModelCopyWithImpl<$Res, SearchContextModel>;
  @useResult
  $Res call(
      {String? from,
      String? to,
      @JsonKey(name: "selected_date") dynamic selectedDate,
      @JsonKey(name: "weekend_mode") bool? weekendMode,
      @JsonKey(name: "weekend_days") List<String>? weekendDates});
}

/// @nodoc
class _$SearchContextModelCopyWithImpl<$Res, $Val extends SearchContextModel>
    implements $SearchContextModelCopyWith<$Res> {
  _$SearchContextModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? from = freezed,
    Object? to = freezed,
    Object? selectedDate = freezed,
    Object? weekendMode = freezed,
    Object? weekendDates = freezed,
  }) {
    return _then(_value.copyWith(
      from: freezed == from
          ? _value.from
          : from // ignore: cast_nullable_to_non_nullable
              as String?,
      to: freezed == to
          ? _value.to
          : to // ignore: cast_nullable_to_non_nullable
              as String?,
      selectedDate: freezed == selectedDate
          ? _value.selectedDate
          : selectedDate // ignore: cast_nullable_to_non_nullable
              as dynamic,
      weekendMode: freezed == weekendMode
          ? _value.weekendMode
          : weekendMode // ignore: cast_nullable_to_non_nullable
              as bool?,
      weekendDates: freezed == weekendDates
          ? _value.weekendDates
          : weekendDates // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SearchContextModelImplCopyWith<$Res>
    implements $SearchContextModelCopyWith<$Res> {
  factory _$$SearchContextModelImplCopyWith(_$SearchContextModelImpl value,
          $Res Function(_$SearchContextModelImpl) then) =
      __$$SearchContextModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? from,
      String? to,
      @JsonKey(name: "selected_date") dynamic selectedDate,
      @JsonKey(name: "weekend_mode") bool? weekendMode,
      @JsonKey(name: "weekend_days") List<String>? weekendDates});
}

/// @nodoc
class __$$SearchContextModelImplCopyWithImpl<$Res>
    extends _$SearchContextModelCopyWithImpl<$Res, _$SearchContextModelImpl>
    implements _$$SearchContextModelImplCopyWith<$Res> {
  __$$SearchContextModelImplCopyWithImpl(_$SearchContextModelImpl _value,
      $Res Function(_$SearchContextModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? from = freezed,
    Object? to = freezed,
    Object? selectedDate = freezed,
    Object? weekendMode = freezed,
    Object? weekendDates = freezed,
  }) {
    return _then(_$SearchContextModelImpl(
      from: freezed == from
          ? _value.from
          : from // ignore: cast_nullable_to_non_nullable
              as String?,
      to: freezed == to
          ? _value.to
          : to // ignore: cast_nullable_to_non_nullable
              as String?,
      selectedDate: freezed == selectedDate
          ? _value.selectedDate
          : selectedDate // ignore: cast_nullable_to_non_nullable
              as dynamic,
      weekendMode: freezed == weekendMode
          ? _value.weekendMode
          : weekendMode // ignore: cast_nullable_to_non_nullable
              as bool?,
      weekendDates: freezed == weekendDates
          ? _value._weekendDates
          : weekendDates // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SearchContextModelImpl implements _SearchContextModel {
  const _$SearchContextModelImpl(
      {this.from,
      this.to,
      @JsonKey(name: "selected_date") this.selectedDate,
      @JsonKey(name: "weekend_mode") this.weekendMode,
      @JsonKey(name: "weekend_days") final List<String>? weekendDates})
      : _weekendDates = weekendDates;

  factory _$SearchContextModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SearchContextModelImplFromJson(json);

  @override
  final String? from;
  @override
  final String? to;
  @override
  @JsonKey(name: "selected_date")
  final dynamic selectedDate;
  @override
  @JsonKey(name: "weekend_mode")
  final bool? weekendMode;
  final List<String>? _weekendDates;
  @override
  @JsonKey(name: "weekend_days")
  List<String>? get weekendDates {
    final value = _weekendDates;
    if (value == null) return null;
    if (_weekendDates is EqualUnmodifiableListView) return _weekendDates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'SearchContextModel(from: $from, to: $to, selectedDate: $selectedDate, weekendMode: $weekendMode, weekendDates: $weekendDates)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchContextModelImpl &&
            (identical(other.from, from) || other.from == from) &&
            (identical(other.to, to) || other.to == to) &&
            const DeepCollectionEquality()
                .equals(other.selectedDate, selectedDate) &&
            (identical(other.weekendMode, weekendMode) ||
                other.weekendMode == weekendMode) &&
            const DeepCollectionEquality()
                .equals(other._weekendDates, _weekendDates));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      from,
      to,
      const DeepCollectionEquality().hash(selectedDate),
      weekendMode,
      const DeepCollectionEquality().hash(_weekendDates));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SearchContextModelImplCopyWith<_$SearchContextModelImpl> get copyWith =>
      __$$SearchContextModelImplCopyWithImpl<_$SearchContextModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SearchContextModelImplToJson(
      this,
    );
  }
}

abstract class _SearchContextModel implements SearchContextModel {
  const factory _SearchContextModel(
          {final String? from,
          final String? to,
          @JsonKey(name: "selected_date") final dynamic selectedDate,
          @JsonKey(name: "weekend_mode") final bool? weekendMode,
          @JsonKey(name: "weekend_days") final List<String>? weekendDates}) =
      _$SearchContextModelImpl;

  factory _SearchContextModel.fromJson(Map<String, dynamic> json) =
      _$SearchContextModelImpl.fromJson;

  @override
  String? get from;
  @override
  String? get to;
  @override
  @JsonKey(name: "selected_date")
  dynamic get selectedDate;
  @override
  @JsonKey(name: "weekend_mode")
  bool? get weekendMode;
  @override
  @JsonKey(name: "weekend_days")
  List<String>? get weekendDates;
  @override
  @JsonKey(ignore: true)
  _$$SearchContextModelImplCopyWith<_$SearchContextModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TrekData _$TrekDataFromJson(Map<String, dynamic> json) {
  return _TrekData.fromJson(json);
}

/// @nodoc
mixin _$TrekData {
  int? get id => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  String? get vendor => throw _privateConstructorUsedError;
  bool? get hasDiscount => throw _privateConstructorUsedError;
  String? get discountText => throw _privateConstructorUsedError;
  double? get rating => throw _privateConstructorUsedError;
  String? get price => throw _privateConstructorUsedError;
  String? get duration => throw _privateConstructorUsedError;
  BatchInfo? get batchInfo => throw _privateConstructorUsedError;
  Badge? get badge => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TrekDataCopyWith<TrekData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrekDataCopyWith<$Res> {
  factory $TrekDataCopyWith(TrekData value, $Res Function(TrekData) then) =
      _$TrekDataCopyWithImpl<$Res, TrekData>;
  @useResult
  $Res call(
      {int? id,
      String? name,
      String? vendor,
      bool? hasDiscount,
      String? discountText,
      double? rating,
      String? price,
      String? duration,
      BatchInfo? batchInfo,
      Badge? badge,
      String? imageUrl});

  $BatchInfoCopyWith<$Res>? get batchInfo;
  $BadgeCopyWith<$Res>? get badge;
}

/// @nodoc
class _$TrekDataCopyWithImpl<$Res, $Val extends TrekData>
    implements $TrekDataCopyWith<$Res> {
  _$TrekDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? vendor = freezed,
    Object? hasDiscount = freezed,
    Object? discountText = freezed,
    Object? rating = freezed,
    Object? price = freezed,
    Object? duration = freezed,
    Object? batchInfo = freezed,
    Object? badge = freezed,
    Object? imageUrl = freezed,
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
      vendor: freezed == vendor
          ? _value.vendor
          : vendor // ignore: cast_nullable_to_non_nullable
              as String?,
      hasDiscount: freezed == hasDiscount
          ? _value.hasDiscount
          : hasDiscount // ignore: cast_nullable_to_non_nullable
              as bool?,
      discountText: freezed == discountText
          ? _value.discountText
          : discountText // ignore: cast_nullable_to_non_nullable
              as String?,
      rating: freezed == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double?,
      price: freezed == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as String?,
      duration: freezed == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as String?,
      batchInfo: freezed == batchInfo
          ? _value.batchInfo
          : batchInfo // ignore: cast_nullable_to_non_nullable
              as BatchInfo?,
      badge: freezed == badge
          ? _value.badge
          : badge // ignore: cast_nullable_to_non_nullable
              as Badge?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $BatchInfoCopyWith<$Res>? get batchInfo {
    if (_value.batchInfo == null) {
      return null;
    }

    return $BatchInfoCopyWith<$Res>(_value.batchInfo!, (value) {
      return _then(_value.copyWith(batchInfo: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $BadgeCopyWith<$Res>? get badge {
    if (_value.badge == null) {
      return null;
    }

    return $BadgeCopyWith<$Res>(_value.badge!, (value) {
      return _then(_value.copyWith(badge: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TrekDataImplCopyWith<$Res>
    implements $TrekDataCopyWith<$Res> {
  factory _$$TrekDataImplCopyWith(
          _$TrekDataImpl value, $Res Function(_$TrekDataImpl) then) =
      __$$TrekDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? id,
      String? name,
      String? vendor,
      bool? hasDiscount,
      String? discountText,
      double? rating,
      String? price,
      String? duration,
      BatchInfo? batchInfo,
      Badge? badge,
      String? imageUrl});

  @override
  $BatchInfoCopyWith<$Res>? get batchInfo;
  @override
  $BadgeCopyWith<$Res>? get badge;
}

/// @nodoc
class __$$TrekDataImplCopyWithImpl<$Res>
    extends _$TrekDataCopyWithImpl<$Res, _$TrekDataImpl>
    implements _$$TrekDataImplCopyWith<$Res> {
  __$$TrekDataImplCopyWithImpl(
      _$TrekDataImpl _value, $Res Function(_$TrekDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? vendor = freezed,
    Object? hasDiscount = freezed,
    Object? discountText = freezed,
    Object? rating = freezed,
    Object? price = freezed,
    Object? duration = freezed,
    Object? batchInfo = freezed,
    Object? badge = freezed,
    Object? imageUrl = freezed,
  }) {
    return _then(_$TrekDataImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      vendor: freezed == vendor
          ? _value.vendor
          : vendor // ignore: cast_nullable_to_non_nullable
              as String?,
      hasDiscount: freezed == hasDiscount
          ? _value.hasDiscount
          : hasDiscount // ignore: cast_nullable_to_non_nullable
              as bool?,
      discountText: freezed == discountText
          ? _value.discountText
          : discountText // ignore: cast_nullable_to_non_nullable
              as String?,
      rating: freezed == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double?,
      price: freezed == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as String?,
      duration: freezed == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as String?,
      batchInfo: freezed == batchInfo
          ? _value.batchInfo
          : batchInfo // ignore: cast_nullable_to_non_nullable
              as BatchInfo?,
      badge: freezed == badge
          ? _value.badge
          : badge // ignore: cast_nullable_to_non_nullable
              as Badge?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TrekDataImpl implements _TrekData {
  const _$TrekDataImpl(
      {this.id,
      this.name,
      this.vendor,
      this.hasDiscount,
      this.discountText,
      this.rating,
      this.price,
      this.duration,
      this.batchInfo,
      this.badge,
      this.imageUrl});

  factory _$TrekDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$TrekDataImplFromJson(json);

  @override
  final int? id;
  @override
  final String? name;
  @override
  final String? vendor;
  @override
  final bool? hasDiscount;
  @override
  final String? discountText;
  @override
  final double? rating;
  @override
  final String? price;
  @override
  final String? duration;
  @override
  final BatchInfo? batchInfo;
  @override
  final Badge? badge;
  @override
  final String? imageUrl;

  @override
  String toString() {
    return 'TrekData(id: $id, name: $name, vendor: $vendor, hasDiscount: $hasDiscount, discountText: $discountText, rating: $rating, price: $price, duration: $duration, batchInfo: $batchInfo, badge: $badge, imageUrl: $imageUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrekDataImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.vendor, vendor) || other.vendor == vendor) &&
            (identical(other.hasDiscount, hasDiscount) ||
                other.hasDiscount == hasDiscount) &&
            (identical(other.discountText, discountText) ||
                other.discountText == discountText) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.batchInfo, batchInfo) ||
                other.batchInfo == batchInfo) &&
            (identical(other.badge, badge) || other.badge == badge) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, vendor, hasDiscount,
      discountText, rating, price, duration, batchInfo, badge, imageUrl);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TrekDataImplCopyWith<_$TrekDataImpl> get copyWith =>
      __$$TrekDataImplCopyWithImpl<_$TrekDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TrekDataImplToJson(
      this,
    );
  }
}

abstract class _TrekData implements TrekData {
  const factory _TrekData(
      {final int? id,
      final String? name,
      final String? vendor,
      final bool? hasDiscount,
      final String? discountText,
      final double? rating,
      final String? price,
      final String? duration,
      final BatchInfo? batchInfo,
      final Badge? badge,
      final String? imageUrl}) = _$TrekDataImpl;

  factory _TrekData.fromJson(Map<String, dynamic> json) =
      _$TrekDataImpl.fromJson;

  @override
  int? get id;
  @override
  String? get name;
  @override
  String? get vendor;
  @override
  bool? get hasDiscount;
  @override
  String? get discountText;
  @override
  double? get rating;
  @override
  String? get price;
  @override
  String? get duration;
  @override
  BatchInfo? get batchInfo;
  @override
  Badge? get badge;
  @override
  String? get imageUrl;
  @override
  @JsonKey(ignore: true)
  _$$TrekDataImplCopyWith<_$TrekDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BatchInfo _$BatchInfoFromJson(Map<String, dynamic> json) {
  return _BatchInfo.fromJson(json);
}

/// @nodoc
mixin _$BatchInfo {
  int? get id => throw _privateConstructorUsedError;
  String? get startDate => throw _privateConstructorUsedError;
  int? get availableSlots => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BatchInfoCopyWith<BatchInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BatchInfoCopyWith<$Res> {
  factory $BatchInfoCopyWith(BatchInfo value, $Res Function(BatchInfo) then) =
      _$BatchInfoCopyWithImpl<$Res, BatchInfo>;
  @useResult
  $Res call({int? id, String? startDate, int? availableSlots});
}

/// @nodoc
class _$BatchInfoCopyWithImpl<$Res, $Val extends BatchInfo>
    implements $BatchInfoCopyWith<$Res> {
  _$BatchInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? startDate = freezed,
    Object? availableSlots = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      startDate: freezed == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as String?,
      availableSlots: freezed == availableSlots
          ? _value.availableSlots
          : availableSlots // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BatchInfoImplCopyWith<$Res>
    implements $BatchInfoCopyWith<$Res> {
  factory _$$BatchInfoImplCopyWith(
          _$BatchInfoImpl value, $Res Function(_$BatchInfoImpl) then) =
      __$$BatchInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int? id, String? startDate, int? availableSlots});
}

/// @nodoc
class __$$BatchInfoImplCopyWithImpl<$Res>
    extends _$BatchInfoCopyWithImpl<$Res, _$BatchInfoImpl>
    implements _$$BatchInfoImplCopyWith<$Res> {
  __$$BatchInfoImplCopyWithImpl(
      _$BatchInfoImpl _value, $Res Function(_$BatchInfoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? startDate = freezed,
    Object? availableSlots = freezed,
  }) {
    return _then(_$BatchInfoImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      startDate: freezed == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as String?,
      availableSlots: freezed == availableSlots
          ? _value.availableSlots
          : availableSlots // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BatchInfoImpl implements _BatchInfo {
  const _$BatchInfoImpl({this.id, this.startDate, this.availableSlots});

  factory _$BatchInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$BatchInfoImplFromJson(json);

  @override
  final int? id;
  @override
  final String? startDate;
  @override
  final int? availableSlots;

  @override
  String toString() {
    return 'BatchInfo(id: $id, startDate: $startDate, availableSlots: $availableSlots)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BatchInfoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.availableSlots, availableSlots) ||
                other.availableSlots == availableSlots));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, startDate, availableSlots);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BatchInfoImplCopyWith<_$BatchInfoImpl> get copyWith =>
      __$$BatchInfoImplCopyWithImpl<_$BatchInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BatchInfoImplToJson(
      this,
    );
  }
}

abstract class _BatchInfo implements BatchInfo {
  const factory _BatchInfo(
      {final int? id,
      final String? startDate,
      final int? availableSlots}) = _$BatchInfoImpl;

  factory _BatchInfo.fromJson(Map<String, dynamic> json) =
      _$BatchInfoImpl.fromJson;

  @override
  int? get id;
  @override
  String? get startDate;
  @override
  int? get availableSlots;
  @override
  @JsonKey(ignore: true)
  _$$BatchInfoImplCopyWith<_$BatchInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Badge _$BadgeFromJson(Map<String, dynamic> json) {
  return _Badge.fromJson(json);
}

/// @nodoc
mixin _$Badge {
  int? get id => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  String? get icon => throw _privateConstructorUsedError;
  String? get color => throw _privateConstructorUsedError;
  String? get category => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BadgeCopyWith<Badge> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BadgeCopyWith<$Res> {
  factory $BadgeCopyWith(Badge value, $Res Function(Badge) then) =
      _$BadgeCopyWithImpl<$Res, Badge>;
  @useResult
  $Res call(
      {int? id, String? name, String? icon, String? color, String? category});
}

/// @nodoc
class _$BadgeCopyWithImpl<$Res, $Val extends Badge>
    implements $BadgeCopyWith<$Res> {
  _$BadgeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? icon = freezed,
    Object? color = freezed,
    Object? category = freezed,
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
      icon: freezed == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String?,
      color: freezed == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String?,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BadgeImplCopyWith<$Res> implements $BadgeCopyWith<$Res> {
  factory _$$BadgeImplCopyWith(
          _$BadgeImpl value, $Res Function(_$BadgeImpl) then) =
      __$$BadgeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? id, String? name, String? icon, String? color, String? category});
}

/// @nodoc
class __$$BadgeImplCopyWithImpl<$Res>
    extends _$BadgeCopyWithImpl<$Res, _$BadgeImpl>
    implements _$$BadgeImplCopyWith<$Res> {
  __$$BadgeImplCopyWithImpl(
      _$BadgeImpl _value, $Res Function(_$BadgeImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? icon = freezed,
    Object? color = freezed,
    Object? category = freezed,
  }) {
    return _then(_$BadgeImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      icon: freezed == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String?,
      color: freezed == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String?,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BadgeImpl implements _Badge {
  const _$BadgeImpl({this.id, this.name, this.icon, this.color, this.category});

  factory _$BadgeImpl.fromJson(Map<String, dynamic> json) =>
      _$$BadgeImplFromJson(json);

  @override
  final int? id;
  @override
  final String? name;
  @override
  final String? icon;
  @override
  final String? color;
  @override
  final String? category;

  @override
  String toString() {
    return 'Badge(id: $id, name: $name, icon: $icon, color: $color, category: $category)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BadgeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.category, category) ||
                other.category == category));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, icon, color, category);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BadgeImplCopyWith<_$BadgeImpl> get copyWith =>
      __$$BadgeImplCopyWithImpl<_$BadgeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BadgeImplToJson(
      this,
    );
  }
}

abstract class _Badge implements Badge {
  const factory _Badge(
      {final int? id,
      final String? name,
      final String? icon,
      final String? color,
      final String? category}) = _$BadgeImpl;

  factory _Badge.fromJson(Map<String, dynamic> json) = _$BadgeImpl.fromJson;

  @override
  int? get id;
  @override
  String? get name;
  @override
  String? get icon;
  @override
  String? get color;
  @override
  String? get category;
  @override
  @JsonKey(ignore: true)
  _$$BadgeImplCopyWith<_$BadgeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TrekBatchesResponseModel _$TrekBatchesResponseModelFromJson(
    Map<String, dynamic> json) {
  return _TrekBatchesResponseModel.fromJson(json);
}

/// @nodoc
mixin _$TrekBatchesResponseModel {
  bool? get success => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;
  List<TrekBatchDataModel>? get data => throw _privateConstructorUsedError;
  int? get count => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TrekBatchesResponseModelCopyWith<TrekBatchesResponseModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrekBatchesResponseModelCopyWith<$Res> {
  factory $TrekBatchesResponseModelCopyWith(TrekBatchesResponseModel value,
          $Res Function(TrekBatchesResponseModel) then) =
      _$TrekBatchesResponseModelCopyWithImpl<$Res, TrekBatchesResponseModel>;
  @useResult
  $Res call(
      {bool? success,
      String? message,
      List<TrekBatchDataModel>? data,
      int? count});
}

/// @nodoc
class _$TrekBatchesResponseModelCopyWithImpl<$Res,
        $Val extends TrekBatchesResponseModel>
    implements $TrekBatchesResponseModelCopyWith<$Res> {
  _$TrekBatchesResponseModelCopyWithImpl(this._value, this._then);

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
              as List<TrekBatchDataModel>?,
      count: freezed == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TrekBatchesResponseModelImplCopyWith<$Res>
    implements $TrekBatchesResponseModelCopyWith<$Res> {
  factory _$$TrekBatchesResponseModelImplCopyWith(
          _$TrekBatchesResponseModelImpl value,
          $Res Function(_$TrekBatchesResponseModelImpl) then) =
      __$$TrekBatchesResponseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool? success,
      String? message,
      List<TrekBatchDataModel>? data,
      int? count});
}

/// @nodoc
class __$$TrekBatchesResponseModelImplCopyWithImpl<$Res>
    extends _$TrekBatchesResponseModelCopyWithImpl<$Res,
        _$TrekBatchesResponseModelImpl>
    implements _$$TrekBatchesResponseModelImplCopyWith<$Res> {
  __$$TrekBatchesResponseModelImplCopyWithImpl(
      _$TrekBatchesResponseModelImpl _value,
      $Res Function(_$TrekBatchesResponseModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = freezed,
    Object? message = freezed,
    Object? data = freezed,
    Object? count = freezed,
  }) {
    return _then(_$TrekBatchesResponseModelImpl(
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
              as List<TrekBatchDataModel>?,
      count: freezed == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TrekBatchesResponseModelImpl implements _TrekBatchesResponseModel {
  const _$TrekBatchesResponseModelImpl(
      {this.success,
      this.message,
      final List<TrekBatchDataModel>? data,
      this.count})
      : _data = data;

  factory _$TrekBatchesResponseModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TrekBatchesResponseModelImplFromJson(json);

  @override
  final bool? success;
  @override
  final String? message;
  final List<TrekBatchDataModel>? _data;
  @override
  List<TrekBatchDataModel>? get data {
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
    return 'TrekBatchesResponseModel(success: $success, message: $message, data: $data, count: $count)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrekBatchesResponseModelImpl &&
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
  _$$TrekBatchesResponseModelImplCopyWith<_$TrekBatchesResponseModelImpl>
      get copyWith => __$$TrekBatchesResponseModelImplCopyWithImpl<
          _$TrekBatchesResponseModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TrekBatchesResponseModelImplToJson(
      this,
    );
  }
}

abstract class _TrekBatchesResponseModel implements TrekBatchesResponseModel {
  const factory _TrekBatchesResponseModel(
      {final bool? success,
      final String? message,
      final List<TrekBatchDataModel>? data,
      final int? count}) = _$TrekBatchesResponseModelImpl;

  factory _TrekBatchesResponseModel.fromJson(Map<String, dynamic> json) =
      _$TrekBatchesResponseModelImpl.fromJson;

  @override
  bool? get success;
  @override
  String? get message;
  @override
  List<TrekBatchDataModel>? get data;
  @override
  int? get count;
  @override
  @JsonKey(ignore: true)
  _$$TrekBatchesResponseModelImplCopyWith<_$TrekBatchesResponseModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}

TrekBatchDataModel _$TrekBatchDataModelFromJson(Map<String, dynamic> json) {
  return _TrekBatchDataModel.fromJson(json);
}

/// @nodoc
mixin _$TrekBatchDataModel {
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'trek_id')
  int? get trekId => throw _privateConstructorUsedError;
  @JsonKey(name: 'start_date')
  String? get startDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'end_date')
  String? get endDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'available_slots')
  int? get availableSlots => throw _privateConstructorUsedError;
  String? get status => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TrekBatchDataModelCopyWith<TrekBatchDataModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrekBatchDataModelCopyWith<$Res> {
  factory $TrekBatchDataModelCopyWith(
          TrekBatchDataModel value, $Res Function(TrekBatchDataModel) then) =
      _$TrekBatchDataModelCopyWithImpl<$Res, TrekBatchDataModel>;
  @useResult
  $Res call(
      {int? id,
      @JsonKey(name: 'trek_id') int? trekId,
      @JsonKey(name: 'start_date') String? startDate,
      @JsonKey(name: 'end_date') String? endDate,
      @JsonKey(name: 'available_slots') int? availableSlots,
      String? status});
}

/// @nodoc
class _$TrekBatchDataModelCopyWithImpl<$Res, $Val extends TrekBatchDataModel>
    implements $TrekBatchDataModelCopyWith<$Res> {
  _$TrekBatchDataModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? trekId = freezed,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? availableSlots = freezed,
    Object? status = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      trekId: freezed == trekId
          ? _value.trekId
          : trekId // ignore: cast_nullable_to_non_nullable
              as int?,
      startDate: freezed == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as String?,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as String?,
      availableSlots: freezed == availableSlots
          ? _value.availableSlots
          : availableSlots // ignore: cast_nullable_to_non_nullable
              as int?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TrekBatchDataModelImplCopyWith<$Res>
    implements $TrekBatchDataModelCopyWith<$Res> {
  factory _$$TrekBatchDataModelImplCopyWith(_$TrekBatchDataModelImpl value,
          $Res Function(_$TrekBatchDataModelImpl) then) =
      __$$TrekBatchDataModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? id,
      @JsonKey(name: 'trek_id') int? trekId,
      @JsonKey(name: 'start_date') String? startDate,
      @JsonKey(name: 'end_date') String? endDate,
      @JsonKey(name: 'available_slots') int? availableSlots,
      String? status});
}

/// @nodoc
class __$$TrekBatchDataModelImplCopyWithImpl<$Res>
    extends _$TrekBatchDataModelCopyWithImpl<$Res, _$TrekBatchDataModelImpl>
    implements _$$TrekBatchDataModelImplCopyWith<$Res> {
  __$$TrekBatchDataModelImplCopyWithImpl(_$TrekBatchDataModelImpl _value,
      $Res Function(_$TrekBatchDataModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? trekId = freezed,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? availableSlots = freezed,
    Object? status = freezed,
  }) {
    return _then(_$TrekBatchDataModelImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      trekId: freezed == trekId
          ? _value.trekId
          : trekId // ignore: cast_nullable_to_non_nullable
              as int?,
      startDate: freezed == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as String?,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as String?,
      availableSlots: freezed == availableSlots
          ? _value.availableSlots
          : availableSlots // ignore: cast_nullable_to_non_nullable
              as int?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TrekBatchDataModelImpl implements _TrekBatchDataModel {
  const _$TrekBatchDataModelImpl(
      {this.id,
      @JsonKey(name: 'trek_id') this.trekId,
      @JsonKey(name: 'start_date') this.startDate,
      @JsonKey(name: 'end_date') this.endDate,
      @JsonKey(name: 'available_slots') this.availableSlots,
      this.status});

  factory _$TrekBatchDataModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TrekBatchDataModelImplFromJson(json);

  @override
  final int? id;
  @override
  @JsonKey(name: 'trek_id')
  final int? trekId;
  @override
  @JsonKey(name: 'start_date')
  final String? startDate;
  @override
  @JsonKey(name: 'end_date')
  final String? endDate;
  @override
  @JsonKey(name: 'available_slots')
  final int? availableSlots;
  @override
  final String? status;

  @override
  String toString() {
    return 'TrekBatchDataModel(id: $id, trekId: $trekId, startDate: $startDate, endDate: $endDate, availableSlots: $availableSlots, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrekBatchDataModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.trekId, trekId) || other.trekId == trekId) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.availableSlots, availableSlots) ||
                other.availableSlots == availableSlots) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, trekId, startDate, endDate, availableSlots, status);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TrekBatchDataModelImplCopyWith<_$TrekBatchDataModelImpl> get copyWith =>
      __$$TrekBatchDataModelImplCopyWithImpl<_$TrekBatchDataModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TrekBatchDataModelImplToJson(
      this,
    );
  }
}

abstract class _TrekBatchDataModel implements TrekBatchDataModel {
  const factory _TrekBatchDataModel(
      {final int? id,
      @JsonKey(name: 'trek_id') final int? trekId,
      @JsonKey(name: 'start_date') final String? startDate,
      @JsonKey(name: 'end_date') final String? endDate,
      @JsonKey(name: 'available_slots') final int? availableSlots,
      final String? status}) = _$TrekBatchDataModelImpl;

  factory _TrekBatchDataModel.fromJson(Map<String, dynamic> json) =
      _$TrekBatchDataModelImpl.fromJson;

  @override
  int? get id;
  @override
  @JsonKey(name: 'trek_id')
  int? get trekId;
  @override
  @JsonKey(name: 'start_date')
  String? get startDate;
  @override
  @JsonKey(name: 'end_date')
  String? get endDate;
  @override
  @JsonKey(name: 'available_slots')
  int? get availableSlots;
  @override
  String? get status;
  @override
  @JsonKey(ignore: true)
  _$$TrekBatchDataModelImplCopyWith<_$TrekBatchDataModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
