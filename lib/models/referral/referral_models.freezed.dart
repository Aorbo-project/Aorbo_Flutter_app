// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'referral_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

ReferralInfoResponse _$ReferralInfoResponseFromJson(Map<String, dynamic> json) {
  return _ReferralInfoResponse.fromJson(json);
}

/// @nodoc
mixin _$ReferralInfoResponse {
  bool? get success => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;
  ReferralInfo? get data => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ReferralInfoResponseCopyWith<ReferralInfoResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReferralInfoResponseCopyWith<$Res> {
  factory $ReferralInfoResponseCopyWith(ReferralInfoResponse value,
          $Res Function(ReferralInfoResponse) then) =
      _$ReferralInfoResponseCopyWithImpl<$Res, ReferralInfoResponse>;
  @useResult
  $Res call({bool? success, String? message, ReferralInfo? data});

  $ReferralInfoCopyWith<$Res>? get data;
}

/// @nodoc
class _$ReferralInfoResponseCopyWithImpl<$Res,
        $Val extends ReferralInfoResponse>
    implements $ReferralInfoResponseCopyWith<$Res> {
  _$ReferralInfoResponseCopyWithImpl(this._value, this._then);

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
              as ReferralInfo?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $ReferralInfoCopyWith<$Res>? get data {
    if (_value.data == null) {
      return null;
    }

    return $ReferralInfoCopyWith<$Res>(_value.data!, (value) {
      return _then(_value.copyWith(data: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ReferralInfoResponseImplCopyWith<$Res>
    implements $ReferralInfoResponseCopyWith<$Res> {
  factory _$$ReferralInfoResponseImplCopyWith(_$ReferralInfoResponseImpl value,
          $Res Function(_$ReferralInfoResponseImpl) then) =
      __$$ReferralInfoResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool? success, String? message, ReferralInfo? data});

  @override
  $ReferralInfoCopyWith<$Res>? get data;
}

/// @nodoc
class __$$ReferralInfoResponseImplCopyWithImpl<$Res>
    extends _$ReferralInfoResponseCopyWithImpl<$Res, _$ReferralInfoResponseImpl>
    implements _$$ReferralInfoResponseImplCopyWith<$Res> {
  __$$ReferralInfoResponseImplCopyWithImpl(_$ReferralInfoResponseImpl _value,
      $Res Function(_$ReferralInfoResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = freezed,
    Object? message = freezed,
    Object? data = freezed,
  }) {
    return _then(_$ReferralInfoResponseImpl(
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
              as ReferralInfo?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReferralInfoResponseImpl implements _ReferralInfoResponse {
  const _$ReferralInfoResponseImpl({this.success, this.message, this.data});

  factory _$ReferralInfoResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReferralInfoResponseImplFromJson(json);

  @override
  final bool? success;
  @override
  final String? message;
  @override
  final ReferralInfo? data;

  @override
  String toString() {
    return 'ReferralInfoResponse(success: $success, message: $message, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReferralInfoResponseImpl &&
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
  _$$ReferralInfoResponseImplCopyWith<_$ReferralInfoResponseImpl>
      get copyWith =>
          __$$ReferralInfoResponseImplCopyWithImpl<_$ReferralInfoResponseImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReferralInfoResponseImplToJson(
      this,
    );
  }
}

abstract class _ReferralInfoResponse implements ReferralInfoResponse {
  const factory _ReferralInfoResponse(
      {final bool? success,
      final String? message,
      final ReferralInfo? data}) = _$ReferralInfoResponseImpl;

  factory _ReferralInfoResponse.fromJson(Map<String, dynamic> json) =
      _$ReferralInfoResponseImpl.fromJson;

  @override
  bool? get success;
  @override
  String? get message;
  @override
  ReferralInfo? get data;
  @override
  @JsonKey(ignore: true)
  _$$ReferralInfoResponseImplCopyWith<_$ReferralInfoResponseImpl>
      get copyWith => throw _privateConstructorUsedError;
}

ReferralInfo _$ReferralInfoFromJson(Map<String, dynamic> json) {
  return _ReferralInfo.fromJson(json);
}

/// @nodoc
mixin _$ReferralInfo {
  ReferralProgram? get program => throw _privateConstructorUsedError;

  /// The customer's own code. Backend generates it lazily on the first
  /// GET, so this should be non-null in practice — but the UI still
  /// guards for null (shows a "generating…" state).
  String? get code => throw _privateConstructorUsedError;

  /// Play Store / deep link the share sheet points at.
  String? get shareUrl => throw _privateConstructorUsedError;

  /// Ready-to-send message, fully composed by the backend from the live
  /// config (brand, code, reward amounts, link). The client never builds
  /// its own copy — so a policy/number change is one backend edit.
  String? get shareMessage => throw _privateConstructorUsedError;
  ReferralReward? get reward => throw _privateConstructorUsedError;
  ReferralStats? get stats => throw _privateConstructorUsedError;
  ReferralMilestone? get milestone => throw _privateConstructorUsedError;
  List<ReferralEntry>? get history => throw _privateConstructorUsedError;

  /// True only when this customer is still eligible to enter someone
  /// else's code (new account, no bookings, none applied, within window).
  bool? get canApplyCode => throw _privateConstructorUsedError;

  /// The code this customer used, if any.
  String? get appliedCode => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ReferralInfoCopyWith<ReferralInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReferralInfoCopyWith<$Res> {
  factory $ReferralInfoCopyWith(
          ReferralInfo value, $Res Function(ReferralInfo) then) =
      _$ReferralInfoCopyWithImpl<$Res, ReferralInfo>;
  @useResult
  $Res call(
      {ReferralProgram? program,
      String? code,
      String? shareUrl,
      String? shareMessage,
      ReferralReward? reward,
      ReferralStats? stats,
      ReferralMilestone? milestone,
      List<ReferralEntry>? history,
      bool? canApplyCode,
      String? appliedCode});

  $ReferralProgramCopyWith<$Res>? get program;
  $ReferralRewardCopyWith<$Res>? get reward;
  $ReferralStatsCopyWith<$Res>? get stats;
  $ReferralMilestoneCopyWith<$Res>? get milestone;
}

/// @nodoc
class _$ReferralInfoCopyWithImpl<$Res, $Val extends ReferralInfo>
    implements $ReferralInfoCopyWith<$Res> {
  _$ReferralInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? program = freezed,
    Object? code = freezed,
    Object? shareUrl = freezed,
    Object? shareMessage = freezed,
    Object? reward = freezed,
    Object? stats = freezed,
    Object? milestone = freezed,
    Object? history = freezed,
    Object? canApplyCode = freezed,
    Object? appliedCode = freezed,
  }) {
    return _then(_value.copyWith(
      program: freezed == program
          ? _value.program
          : program // ignore: cast_nullable_to_non_nullable
              as ReferralProgram?,
      code: freezed == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String?,
      shareUrl: freezed == shareUrl
          ? _value.shareUrl
          : shareUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      shareMessage: freezed == shareMessage
          ? _value.shareMessage
          : shareMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      reward: freezed == reward
          ? _value.reward
          : reward // ignore: cast_nullable_to_non_nullable
              as ReferralReward?,
      stats: freezed == stats
          ? _value.stats
          : stats // ignore: cast_nullable_to_non_nullable
              as ReferralStats?,
      milestone: freezed == milestone
          ? _value.milestone
          : milestone // ignore: cast_nullable_to_non_nullable
              as ReferralMilestone?,
      history: freezed == history
          ? _value.history
          : history // ignore: cast_nullable_to_non_nullable
              as List<ReferralEntry>?,
      canApplyCode: freezed == canApplyCode
          ? _value.canApplyCode
          : canApplyCode // ignore: cast_nullable_to_non_nullable
              as bool?,
      appliedCode: freezed == appliedCode
          ? _value.appliedCode
          : appliedCode // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $ReferralProgramCopyWith<$Res>? get program {
    if (_value.program == null) {
      return null;
    }

    return $ReferralProgramCopyWith<$Res>(_value.program!, (value) {
      return _then(_value.copyWith(program: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $ReferralRewardCopyWith<$Res>? get reward {
    if (_value.reward == null) {
      return null;
    }

    return $ReferralRewardCopyWith<$Res>(_value.reward!, (value) {
      return _then(_value.copyWith(reward: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $ReferralStatsCopyWith<$Res>? get stats {
    if (_value.stats == null) {
      return null;
    }

    return $ReferralStatsCopyWith<$Res>(_value.stats!, (value) {
      return _then(_value.copyWith(stats: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $ReferralMilestoneCopyWith<$Res>? get milestone {
    if (_value.milestone == null) {
      return null;
    }

    return $ReferralMilestoneCopyWith<$Res>(_value.milestone!, (value) {
      return _then(_value.copyWith(milestone: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ReferralInfoImplCopyWith<$Res>
    implements $ReferralInfoCopyWith<$Res> {
  factory _$$ReferralInfoImplCopyWith(
          _$ReferralInfoImpl value, $Res Function(_$ReferralInfoImpl) then) =
      __$$ReferralInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {ReferralProgram? program,
      String? code,
      String? shareUrl,
      String? shareMessage,
      ReferralReward? reward,
      ReferralStats? stats,
      ReferralMilestone? milestone,
      List<ReferralEntry>? history,
      bool? canApplyCode,
      String? appliedCode});

  @override
  $ReferralProgramCopyWith<$Res>? get program;
  @override
  $ReferralRewardCopyWith<$Res>? get reward;
  @override
  $ReferralStatsCopyWith<$Res>? get stats;
  @override
  $ReferralMilestoneCopyWith<$Res>? get milestone;
}

/// @nodoc
class __$$ReferralInfoImplCopyWithImpl<$Res>
    extends _$ReferralInfoCopyWithImpl<$Res, _$ReferralInfoImpl>
    implements _$$ReferralInfoImplCopyWith<$Res> {
  __$$ReferralInfoImplCopyWithImpl(
      _$ReferralInfoImpl _value, $Res Function(_$ReferralInfoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? program = freezed,
    Object? code = freezed,
    Object? shareUrl = freezed,
    Object? shareMessage = freezed,
    Object? reward = freezed,
    Object? stats = freezed,
    Object? milestone = freezed,
    Object? history = freezed,
    Object? canApplyCode = freezed,
    Object? appliedCode = freezed,
  }) {
    return _then(_$ReferralInfoImpl(
      program: freezed == program
          ? _value.program
          : program // ignore: cast_nullable_to_non_nullable
              as ReferralProgram?,
      code: freezed == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String?,
      shareUrl: freezed == shareUrl
          ? _value.shareUrl
          : shareUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      shareMessage: freezed == shareMessage
          ? _value.shareMessage
          : shareMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      reward: freezed == reward
          ? _value.reward
          : reward // ignore: cast_nullable_to_non_nullable
              as ReferralReward?,
      stats: freezed == stats
          ? _value.stats
          : stats // ignore: cast_nullable_to_non_nullable
              as ReferralStats?,
      milestone: freezed == milestone
          ? _value.milestone
          : milestone // ignore: cast_nullable_to_non_nullable
              as ReferralMilestone?,
      history: freezed == history
          ? _value._history
          : history // ignore: cast_nullable_to_non_nullable
              as List<ReferralEntry>?,
      canApplyCode: freezed == canApplyCode
          ? _value.canApplyCode
          : canApplyCode // ignore: cast_nullable_to_non_nullable
              as bool?,
      appliedCode: freezed == appliedCode
          ? _value.appliedCode
          : appliedCode // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReferralInfoImpl implements _ReferralInfo {
  const _$ReferralInfoImpl(
      {this.program,
      this.code,
      this.shareUrl,
      this.shareMessage,
      this.reward,
      this.stats,
      this.milestone,
      final List<ReferralEntry>? history,
      this.canApplyCode,
      this.appliedCode})
      : _history = history;

  factory _$ReferralInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReferralInfoImplFromJson(json);

  @override
  final ReferralProgram? program;

  /// The customer's own code. Backend generates it lazily on the first
  /// GET, so this should be non-null in practice — but the UI still
  /// guards for null (shows a "generating…" state).
  @override
  final String? code;

  /// Play Store / deep link the share sheet points at.
  @override
  final String? shareUrl;

  /// Ready-to-send message, fully composed by the backend from the live
  /// config (brand, code, reward amounts, link). The client never builds
  /// its own copy — so a policy/number change is one backend edit.
  @override
  final String? shareMessage;
  @override
  final ReferralReward? reward;
  @override
  final ReferralStats? stats;
  @override
  final ReferralMilestone? milestone;
  final List<ReferralEntry>? _history;
  @override
  List<ReferralEntry>? get history {
    final value = _history;
    if (value == null) return null;
    if (_history is EqualUnmodifiableListView) return _history;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  /// True only when this customer is still eligible to enter someone
  /// else's code (new account, no bookings, none applied, within window).
  @override
  final bool? canApplyCode;

  /// The code this customer used, if any.
  @override
  final String? appliedCode;

  @override
  String toString() {
    return 'ReferralInfo(program: $program, code: $code, shareUrl: $shareUrl, shareMessage: $shareMessage, reward: $reward, stats: $stats, milestone: $milestone, history: $history, canApplyCode: $canApplyCode, appliedCode: $appliedCode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReferralInfoImpl &&
            (identical(other.program, program) || other.program == program) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.shareUrl, shareUrl) ||
                other.shareUrl == shareUrl) &&
            (identical(other.shareMessage, shareMessage) ||
                other.shareMessage == shareMessage) &&
            (identical(other.reward, reward) || other.reward == reward) &&
            (identical(other.stats, stats) || other.stats == stats) &&
            (identical(other.milestone, milestone) ||
                other.milestone == milestone) &&
            const DeepCollectionEquality().equals(other._history, _history) &&
            (identical(other.canApplyCode, canApplyCode) ||
                other.canApplyCode == canApplyCode) &&
            (identical(other.appliedCode, appliedCode) ||
                other.appliedCode == appliedCode));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      program,
      code,
      shareUrl,
      shareMessage,
      reward,
      stats,
      milestone,
      const DeepCollectionEquality().hash(_history),
      canApplyCode,
      appliedCode);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ReferralInfoImplCopyWith<_$ReferralInfoImpl> get copyWith =>
      __$$ReferralInfoImplCopyWithImpl<_$ReferralInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReferralInfoImplToJson(
      this,
    );
  }
}

abstract class _ReferralInfo implements ReferralInfo {
  const factory _ReferralInfo(
      {final ReferralProgram? program,
      final String? code,
      final String? shareUrl,
      final String? shareMessage,
      final ReferralReward? reward,
      final ReferralStats? stats,
      final ReferralMilestone? milestone,
      final List<ReferralEntry>? history,
      final bool? canApplyCode,
      final String? appliedCode}) = _$ReferralInfoImpl;

  factory _ReferralInfo.fromJson(Map<String, dynamic> json) =
      _$ReferralInfoImpl.fromJson;

  @override
  ReferralProgram? get program;
  @override

  /// The customer's own code. Backend generates it lazily on the first
  /// GET, so this should be non-null in practice — but the UI still
  /// guards for null (shows a "generating…" state).
  String? get code;
  @override

  /// Play Store / deep link the share sheet points at.
  String? get shareUrl;
  @override

  /// Ready-to-send message, fully composed by the backend from the live
  /// config (brand, code, reward amounts, link). The client never builds
  /// its own copy — so a policy/number change is one backend edit.
  String? get shareMessage;
  @override
  ReferralReward? get reward;
  @override
  ReferralStats? get stats;
  @override
  ReferralMilestone? get milestone;
  @override
  List<ReferralEntry>? get history;
  @override

  /// True only when this customer is still eligible to enter someone
  /// else's code (new account, no bookings, none applied, within window).
  bool? get canApplyCode;
  @override

  /// The code this customer used, if any.
  String? get appliedCode;
  @override
  @JsonKey(ignore: true)
  _$$ReferralInfoImplCopyWith<_$ReferralInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ReferralProgram _$ReferralProgramFromJson(Map<String, dynamic> json) {
  return _ReferralProgram.fromJson(json);
}

/// @nodoc
mixin _$ReferralProgram {
  bool? get enabled => throw _privateConstructorUsedError;
  String? get termsUrl => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ReferralProgramCopyWith<ReferralProgram> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReferralProgramCopyWith<$Res> {
  factory $ReferralProgramCopyWith(
          ReferralProgram value, $Res Function(ReferralProgram) then) =
      _$ReferralProgramCopyWithImpl<$Res, ReferralProgram>;
  @useResult
  $Res call({bool? enabled, String? termsUrl});
}

/// @nodoc
class _$ReferralProgramCopyWithImpl<$Res, $Val extends ReferralProgram>
    implements $ReferralProgramCopyWith<$Res> {
  _$ReferralProgramCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enabled = freezed,
    Object? termsUrl = freezed,
  }) {
    return _then(_value.copyWith(
      enabled: freezed == enabled
          ? _value.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool?,
      termsUrl: freezed == termsUrl
          ? _value.termsUrl
          : termsUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ReferralProgramImplCopyWith<$Res>
    implements $ReferralProgramCopyWith<$Res> {
  factory _$$ReferralProgramImplCopyWith(_$ReferralProgramImpl value,
          $Res Function(_$ReferralProgramImpl) then) =
      __$$ReferralProgramImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool? enabled, String? termsUrl});
}

/// @nodoc
class __$$ReferralProgramImplCopyWithImpl<$Res>
    extends _$ReferralProgramCopyWithImpl<$Res, _$ReferralProgramImpl>
    implements _$$ReferralProgramImplCopyWith<$Res> {
  __$$ReferralProgramImplCopyWithImpl(
      _$ReferralProgramImpl _value, $Res Function(_$ReferralProgramImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enabled = freezed,
    Object? termsUrl = freezed,
  }) {
    return _then(_$ReferralProgramImpl(
      enabled: freezed == enabled
          ? _value.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool?,
      termsUrl: freezed == termsUrl
          ? _value.termsUrl
          : termsUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReferralProgramImpl implements _ReferralProgram {
  const _$ReferralProgramImpl({this.enabled, this.termsUrl});

  factory _$ReferralProgramImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReferralProgramImplFromJson(json);

  @override
  final bool? enabled;
  @override
  final String? termsUrl;

  @override
  String toString() {
    return 'ReferralProgram(enabled: $enabled, termsUrl: $termsUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReferralProgramImpl &&
            (identical(other.enabled, enabled) || other.enabled == enabled) &&
            (identical(other.termsUrl, termsUrl) ||
                other.termsUrl == termsUrl));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, enabled, termsUrl);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ReferralProgramImplCopyWith<_$ReferralProgramImpl> get copyWith =>
      __$$ReferralProgramImplCopyWithImpl<_$ReferralProgramImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReferralProgramImplToJson(
      this,
    );
  }
}

abstract class _ReferralProgram implements ReferralProgram {
  const factory _ReferralProgram(
      {final bool? enabled, final String? termsUrl}) = _$ReferralProgramImpl;

  factory _ReferralProgram.fromJson(Map<String, dynamic> json) =
      _$ReferralProgramImpl.fromJson;

  @override
  bool? get enabled;
  @override
  String? get termsUrl;
  @override
  @JsonKey(ignore: true)
  _$$ReferralProgramImplCopyWith<_$ReferralProgramImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ReferralReward _$ReferralRewardFromJson(Map<String, dynamic> json) {
  return _ReferralReward.fromJson(json);
}

/// @nodoc
mixin _$ReferralReward {
  String? get refereeText => throw _privateConstructorUsedError;
  String? get referrerText => throw _privateConstructorUsedError;
  num? get refereeValue => throw _privateConstructorUsedError;
  bool? get refereeIsPercent => throw _privateConstructorUsedError;
  num? get referrerValue => throw _privateConstructorUsedError;
  bool? get referrerIsPercent => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ReferralRewardCopyWith<ReferralReward> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReferralRewardCopyWith<$Res> {
  factory $ReferralRewardCopyWith(
          ReferralReward value, $Res Function(ReferralReward) then) =
      _$ReferralRewardCopyWithImpl<$Res, ReferralReward>;
  @useResult
  $Res call(
      {String? refereeText,
      String? referrerText,
      num? refereeValue,
      bool? refereeIsPercent,
      num? referrerValue,
      bool? referrerIsPercent});
}

/// @nodoc
class _$ReferralRewardCopyWithImpl<$Res, $Val extends ReferralReward>
    implements $ReferralRewardCopyWith<$Res> {
  _$ReferralRewardCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? refereeText = freezed,
    Object? referrerText = freezed,
    Object? refereeValue = freezed,
    Object? refereeIsPercent = freezed,
    Object? referrerValue = freezed,
    Object? referrerIsPercent = freezed,
  }) {
    return _then(_value.copyWith(
      refereeText: freezed == refereeText
          ? _value.refereeText
          : refereeText // ignore: cast_nullable_to_non_nullable
              as String?,
      referrerText: freezed == referrerText
          ? _value.referrerText
          : referrerText // ignore: cast_nullable_to_non_nullable
              as String?,
      refereeValue: freezed == refereeValue
          ? _value.refereeValue
          : refereeValue // ignore: cast_nullable_to_non_nullable
              as num?,
      refereeIsPercent: freezed == refereeIsPercent
          ? _value.refereeIsPercent
          : refereeIsPercent // ignore: cast_nullable_to_non_nullable
              as bool?,
      referrerValue: freezed == referrerValue
          ? _value.referrerValue
          : referrerValue // ignore: cast_nullable_to_non_nullable
              as num?,
      referrerIsPercent: freezed == referrerIsPercent
          ? _value.referrerIsPercent
          : referrerIsPercent // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ReferralRewardImplCopyWith<$Res>
    implements $ReferralRewardCopyWith<$Res> {
  factory _$$ReferralRewardImplCopyWith(_$ReferralRewardImpl value,
          $Res Function(_$ReferralRewardImpl) then) =
      __$$ReferralRewardImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? refereeText,
      String? referrerText,
      num? refereeValue,
      bool? refereeIsPercent,
      num? referrerValue,
      bool? referrerIsPercent});
}

/// @nodoc
class __$$ReferralRewardImplCopyWithImpl<$Res>
    extends _$ReferralRewardCopyWithImpl<$Res, _$ReferralRewardImpl>
    implements _$$ReferralRewardImplCopyWith<$Res> {
  __$$ReferralRewardImplCopyWithImpl(
      _$ReferralRewardImpl _value, $Res Function(_$ReferralRewardImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? refereeText = freezed,
    Object? referrerText = freezed,
    Object? refereeValue = freezed,
    Object? refereeIsPercent = freezed,
    Object? referrerValue = freezed,
    Object? referrerIsPercent = freezed,
  }) {
    return _then(_$ReferralRewardImpl(
      refereeText: freezed == refereeText
          ? _value.refereeText
          : refereeText // ignore: cast_nullable_to_non_nullable
              as String?,
      referrerText: freezed == referrerText
          ? _value.referrerText
          : referrerText // ignore: cast_nullable_to_non_nullable
              as String?,
      refereeValue: freezed == refereeValue
          ? _value.refereeValue
          : refereeValue // ignore: cast_nullable_to_non_nullable
              as num?,
      refereeIsPercent: freezed == refereeIsPercent
          ? _value.refereeIsPercent
          : refereeIsPercent // ignore: cast_nullable_to_non_nullable
              as bool?,
      referrerValue: freezed == referrerValue
          ? _value.referrerValue
          : referrerValue // ignore: cast_nullable_to_non_nullable
              as num?,
      referrerIsPercent: freezed == referrerIsPercent
          ? _value.referrerIsPercent
          : referrerIsPercent // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReferralRewardImpl implements _ReferralReward {
  const _$ReferralRewardImpl(
      {this.refereeText,
      this.referrerText,
      this.refereeValue,
      this.refereeIsPercent,
      this.referrerValue,
      this.referrerIsPercent});

  factory _$ReferralRewardImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReferralRewardImplFromJson(json);

  @override
  final String? refereeText;
  @override
  final String? referrerText;
  @override
  final num? refereeValue;
  @override
  final bool? refereeIsPercent;
  @override
  final num? referrerValue;
  @override
  final bool? referrerIsPercent;

  @override
  String toString() {
    return 'ReferralReward(refereeText: $refereeText, referrerText: $referrerText, refereeValue: $refereeValue, refereeIsPercent: $refereeIsPercent, referrerValue: $referrerValue, referrerIsPercent: $referrerIsPercent)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReferralRewardImpl &&
            (identical(other.refereeText, refereeText) ||
                other.refereeText == refereeText) &&
            (identical(other.referrerText, referrerText) ||
                other.referrerText == referrerText) &&
            (identical(other.refereeValue, refereeValue) ||
                other.refereeValue == refereeValue) &&
            (identical(other.refereeIsPercent, refereeIsPercent) ||
                other.refereeIsPercent == refereeIsPercent) &&
            (identical(other.referrerValue, referrerValue) ||
                other.referrerValue == referrerValue) &&
            (identical(other.referrerIsPercent, referrerIsPercent) ||
                other.referrerIsPercent == referrerIsPercent));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, refereeText, referrerText,
      refereeValue, refereeIsPercent, referrerValue, referrerIsPercent);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ReferralRewardImplCopyWith<_$ReferralRewardImpl> get copyWith =>
      __$$ReferralRewardImplCopyWithImpl<_$ReferralRewardImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReferralRewardImplToJson(
      this,
    );
  }
}

abstract class _ReferralReward implements ReferralReward {
  const factory _ReferralReward(
      {final String? refereeText,
      final String? referrerText,
      final num? refereeValue,
      final bool? refereeIsPercent,
      final num? referrerValue,
      final bool? referrerIsPercent}) = _$ReferralRewardImpl;

  factory _ReferralReward.fromJson(Map<String, dynamic> json) =
      _$ReferralRewardImpl.fromJson;

  @override
  String? get refereeText;
  @override
  String? get referrerText;
  @override
  num? get refereeValue;
  @override
  bool? get refereeIsPercent;
  @override
  num? get referrerValue;
  @override
  bool? get referrerIsPercent;
  @override
  @JsonKey(ignore: true)
  _$$ReferralRewardImplCopyWith<_$ReferralRewardImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ReferralStats _$ReferralStatsFromJson(Map<String, dynamic> json) {
  return _ReferralStats.fromJson(json);
}

/// @nodoc
mixin _$ReferralStats {
  /// People who applied my code (any status).
  int get totalReferred => throw _privateConstructorUsedError;

  /// Applied, friend hasn't completed a trek yet.
  int get pending => throw _privateConstructorUsedError;

  /// Friend completed → my coupon was issued.
  int get rewarded => throw _privateConstructorUsedError;

  /// Sum of my referrer-coupon face values that were issued.
  num get totalEarned => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ReferralStatsCopyWith<ReferralStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReferralStatsCopyWith<$Res> {
  factory $ReferralStatsCopyWith(
          ReferralStats value, $Res Function(ReferralStats) then) =
      _$ReferralStatsCopyWithImpl<$Res, ReferralStats>;
  @useResult
  $Res call({int totalReferred, int pending, int rewarded, num totalEarned});
}

/// @nodoc
class _$ReferralStatsCopyWithImpl<$Res, $Val extends ReferralStats>
    implements $ReferralStatsCopyWith<$Res> {
  _$ReferralStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalReferred = null,
    Object? pending = null,
    Object? rewarded = null,
    Object? totalEarned = null,
  }) {
    return _then(_value.copyWith(
      totalReferred: null == totalReferred
          ? _value.totalReferred
          : totalReferred // ignore: cast_nullable_to_non_nullable
              as int,
      pending: null == pending
          ? _value.pending
          : pending // ignore: cast_nullable_to_non_nullable
              as int,
      rewarded: null == rewarded
          ? _value.rewarded
          : rewarded // ignore: cast_nullable_to_non_nullable
              as int,
      totalEarned: null == totalEarned
          ? _value.totalEarned
          : totalEarned // ignore: cast_nullable_to_non_nullable
              as num,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ReferralStatsImplCopyWith<$Res>
    implements $ReferralStatsCopyWith<$Res> {
  factory _$$ReferralStatsImplCopyWith(
          _$ReferralStatsImpl value, $Res Function(_$ReferralStatsImpl) then) =
      __$$ReferralStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int totalReferred, int pending, int rewarded, num totalEarned});
}

/// @nodoc
class __$$ReferralStatsImplCopyWithImpl<$Res>
    extends _$ReferralStatsCopyWithImpl<$Res, _$ReferralStatsImpl>
    implements _$$ReferralStatsImplCopyWith<$Res> {
  __$$ReferralStatsImplCopyWithImpl(
      _$ReferralStatsImpl _value, $Res Function(_$ReferralStatsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalReferred = null,
    Object? pending = null,
    Object? rewarded = null,
    Object? totalEarned = null,
  }) {
    return _then(_$ReferralStatsImpl(
      totalReferred: null == totalReferred
          ? _value.totalReferred
          : totalReferred // ignore: cast_nullable_to_non_nullable
              as int,
      pending: null == pending
          ? _value.pending
          : pending // ignore: cast_nullable_to_non_nullable
              as int,
      rewarded: null == rewarded
          ? _value.rewarded
          : rewarded // ignore: cast_nullable_to_non_nullable
              as int,
      totalEarned: null == totalEarned
          ? _value.totalEarned
          : totalEarned // ignore: cast_nullable_to_non_nullable
              as num,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReferralStatsImpl implements _ReferralStats {
  const _$ReferralStatsImpl(
      {this.totalReferred = 0,
      this.pending = 0,
      this.rewarded = 0,
      this.totalEarned = 0});

  factory _$ReferralStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReferralStatsImplFromJson(json);

  /// People who applied my code (any status).
  @override
  @JsonKey()
  final int totalReferred;

  /// Applied, friend hasn't completed a trek yet.
  @override
  @JsonKey()
  final int pending;

  /// Friend completed → my coupon was issued.
  @override
  @JsonKey()
  final int rewarded;

  /// Sum of my referrer-coupon face values that were issued.
  @override
  @JsonKey()
  final num totalEarned;

  @override
  String toString() {
    return 'ReferralStats(totalReferred: $totalReferred, pending: $pending, rewarded: $rewarded, totalEarned: $totalEarned)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReferralStatsImpl &&
            (identical(other.totalReferred, totalReferred) ||
                other.totalReferred == totalReferred) &&
            (identical(other.pending, pending) || other.pending == pending) &&
            (identical(other.rewarded, rewarded) ||
                other.rewarded == rewarded) &&
            (identical(other.totalEarned, totalEarned) ||
                other.totalEarned == totalEarned));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, totalReferred, pending, rewarded, totalEarned);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ReferralStatsImplCopyWith<_$ReferralStatsImpl> get copyWith =>
      __$$ReferralStatsImplCopyWithImpl<_$ReferralStatsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReferralStatsImplToJson(
      this,
    );
  }
}

abstract class _ReferralStats implements ReferralStats {
  const factory _ReferralStats(
      {final int totalReferred,
      final int pending,
      final int rewarded,
      final num totalEarned}) = _$ReferralStatsImpl;

  factory _ReferralStats.fromJson(Map<String, dynamic> json) =
      _$ReferralStatsImpl.fromJson;

  @override

  /// People who applied my code (any status).
  int get totalReferred;
  @override

  /// Applied, friend hasn't completed a trek yet.
  int get pending;
  @override

  /// Friend completed → my coupon was issued.
  int get rewarded;
  @override

  /// Sum of my referrer-coupon face values that were issued.
  num get totalEarned;
  @override
  @JsonKey(ignore: true)
  _$$ReferralStatsImplCopyWith<_$ReferralStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ReferralMilestone _$ReferralMilestoneFromJson(Map<String, dynamic> json) {
  return _ReferralMilestone.fromJson(json);
}

/// @nodoc
mixin _$ReferralMilestone {
  bool get enabled => throw _privateConstructorUsedError;
  int get target => throw _privateConstructorUsedError;
  int get current => throw _privateConstructorUsedError;
  String? get bonusText => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ReferralMilestoneCopyWith<ReferralMilestone> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReferralMilestoneCopyWith<$Res> {
  factory $ReferralMilestoneCopyWith(
          ReferralMilestone value, $Res Function(ReferralMilestone) then) =
      _$ReferralMilestoneCopyWithImpl<$Res, ReferralMilestone>;
  @useResult
  $Res call({bool enabled, int target, int current, String? bonusText});
}

/// @nodoc
class _$ReferralMilestoneCopyWithImpl<$Res, $Val extends ReferralMilestone>
    implements $ReferralMilestoneCopyWith<$Res> {
  _$ReferralMilestoneCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enabled = null,
    Object? target = null,
    Object? current = null,
    Object? bonusText = freezed,
  }) {
    return _then(_value.copyWith(
      enabled: null == enabled
          ? _value.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool,
      target: null == target
          ? _value.target
          : target // ignore: cast_nullable_to_non_nullable
              as int,
      current: null == current
          ? _value.current
          : current // ignore: cast_nullable_to_non_nullable
              as int,
      bonusText: freezed == bonusText
          ? _value.bonusText
          : bonusText // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ReferralMilestoneImplCopyWith<$Res>
    implements $ReferralMilestoneCopyWith<$Res> {
  factory _$$ReferralMilestoneImplCopyWith(_$ReferralMilestoneImpl value,
          $Res Function(_$ReferralMilestoneImpl) then) =
      __$$ReferralMilestoneImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool enabled, int target, int current, String? bonusText});
}

/// @nodoc
class __$$ReferralMilestoneImplCopyWithImpl<$Res>
    extends _$ReferralMilestoneCopyWithImpl<$Res, _$ReferralMilestoneImpl>
    implements _$$ReferralMilestoneImplCopyWith<$Res> {
  __$$ReferralMilestoneImplCopyWithImpl(_$ReferralMilestoneImpl _value,
      $Res Function(_$ReferralMilestoneImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enabled = null,
    Object? target = null,
    Object? current = null,
    Object? bonusText = freezed,
  }) {
    return _then(_$ReferralMilestoneImpl(
      enabled: null == enabled
          ? _value.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool,
      target: null == target
          ? _value.target
          : target // ignore: cast_nullable_to_non_nullable
              as int,
      current: null == current
          ? _value.current
          : current // ignore: cast_nullable_to_non_nullable
              as int,
      bonusText: freezed == bonusText
          ? _value.bonusText
          : bonusText // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReferralMilestoneImpl implements _ReferralMilestone {
  const _$ReferralMilestoneImpl(
      {this.enabled = false,
      this.target = 0,
      this.current = 0,
      this.bonusText});

  factory _$ReferralMilestoneImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReferralMilestoneImplFromJson(json);

  @override
  @JsonKey()
  final bool enabled;
  @override
  @JsonKey()
  final int target;
  @override
  @JsonKey()
  final int current;
  @override
  final String? bonusText;

  @override
  String toString() {
    return 'ReferralMilestone(enabled: $enabled, target: $target, current: $current, bonusText: $bonusText)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReferralMilestoneImpl &&
            (identical(other.enabled, enabled) || other.enabled == enabled) &&
            (identical(other.target, target) || other.target == target) &&
            (identical(other.current, current) || other.current == current) &&
            (identical(other.bonusText, bonusText) ||
                other.bonusText == bonusText));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, enabled, target, current, bonusText);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ReferralMilestoneImplCopyWith<_$ReferralMilestoneImpl> get copyWith =>
      __$$ReferralMilestoneImplCopyWithImpl<_$ReferralMilestoneImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReferralMilestoneImplToJson(
      this,
    );
  }
}

abstract class _ReferralMilestone implements ReferralMilestone {
  const factory _ReferralMilestone(
      {final bool enabled,
      final int target,
      final int current,
      final String? bonusText}) = _$ReferralMilestoneImpl;

  factory _ReferralMilestone.fromJson(Map<String, dynamic> json) =
      _$ReferralMilestoneImpl.fromJson;

  @override
  bool get enabled;
  @override
  int get target;
  @override
  int get current;
  @override
  String? get bonusText;
  @override
  @JsonKey(ignore: true)
  _$$ReferralMilestoneImplCopyWith<_$ReferralMilestoneImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ReferralEntry _$ReferralEntryFromJson(Map<String, dynamic> json) {
  return _ReferralEntry.fromJson(json);
}

/// @nodoc
mixin _$ReferralEntry {
  int? get id => throw _privateConstructorUsedError;

  /// Masked: first name + last initial (privacy).
  String? get friendName => throw _privateConstructorUsedError;

  /// pending | rewarded | expired | rejected | reversed
  String? get status => throw _privateConstructorUsedError;
  String? get statusLabel => throw _privateConstructorUsedError;
  num? get rewardValue => throw _privateConstructorUsedError;
  bool? get rewardIsPercent => throw _privateConstructorUsedError;

  /// ISO 8601 (backend standard — utils/istDateUtils).
  String? get date => throw _privateConstructorUsedError;

  /// Optional context line, e.g. "Under review", "Friend cancelled".
  String? get note => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ReferralEntryCopyWith<ReferralEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReferralEntryCopyWith<$Res> {
  factory $ReferralEntryCopyWith(
          ReferralEntry value, $Res Function(ReferralEntry) then) =
      _$ReferralEntryCopyWithImpl<$Res, ReferralEntry>;
  @useResult
  $Res call(
      {int? id,
      String? friendName,
      String? status,
      String? statusLabel,
      num? rewardValue,
      bool? rewardIsPercent,
      String? date,
      String? note});
}

/// @nodoc
class _$ReferralEntryCopyWithImpl<$Res, $Val extends ReferralEntry>
    implements $ReferralEntryCopyWith<$Res> {
  _$ReferralEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? friendName = freezed,
    Object? status = freezed,
    Object? statusLabel = freezed,
    Object? rewardValue = freezed,
    Object? rewardIsPercent = freezed,
    Object? date = freezed,
    Object? note = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      friendName: freezed == friendName
          ? _value.friendName
          : friendName // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      statusLabel: freezed == statusLabel
          ? _value.statusLabel
          : statusLabel // ignore: cast_nullable_to_non_nullable
              as String?,
      rewardValue: freezed == rewardValue
          ? _value.rewardValue
          : rewardValue // ignore: cast_nullable_to_non_nullable
              as num?,
      rewardIsPercent: freezed == rewardIsPercent
          ? _value.rewardIsPercent
          : rewardIsPercent // ignore: cast_nullable_to_non_nullable
              as bool?,
      date: freezed == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as String?,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ReferralEntryImplCopyWith<$Res>
    implements $ReferralEntryCopyWith<$Res> {
  factory _$$ReferralEntryImplCopyWith(
          _$ReferralEntryImpl value, $Res Function(_$ReferralEntryImpl) then) =
      __$$ReferralEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? id,
      String? friendName,
      String? status,
      String? statusLabel,
      num? rewardValue,
      bool? rewardIsPercent,
      String? date,
      String? note});
}

/// @nodoc
class __$$ReferralEntryImplCopyWithImpl<$Res>
    extends _$ReferralEntryCopyWithImpl<$Res, _$ReferralEntryImpl>
    implements _$$ReferralEntryImplCopyWith<$Res> {
  __$$ReferralEntryImplCopyWithImpl(
      _$ReferralEntryImpl _value, $Res Function(_$ReferralEntryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? friendName = freezed,
    Object? status = freezed,
    Object? statusLabel = freezed,
    Object? rewardValue = freezed,
    Object? rewardIsPercent = freezed,
    Object? date = freezed,
    Object? note = freezed,
  }) {
    return _then(_$ReferralEntryImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      friendName: freezed == friendName
          ? _value.friendName
          : friendName // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      statusLabel: freezed == statusLabel
          ? _value.statusLabel
          : statusLabel // ignore: cast_nullable_to_non_nullable
              as String?,
      rewardValue: freezed == rewardValue
          ? _value.rewardValue
          : rewardValue // ignore: cast_nullable_to_non_nullable
              as num?,
      rewardIsPercent: freezed == rewardIsPercent
          ? _value.rewardIsPercent
          : rewardIsPercent // ignore: cast_nullable_to_non_nullable
              as bool?,
      date: freezed == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as String?,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReferralEntryImpl extends _ReferralEntry {
  const _$ReferralEntryImpl(
      {this.id,
      this.friendName,
      this.status,
      this.statusLabel,
      this.rewardValue,
      this.rewardIsPercent,
      this.date,
      this.note})
      : super._();

  factory _$ReferralEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReferralEntryImplFromJson(json);

  @override
  final int? id;

  /// Masked: first name + last initial (privacy).
  @override
  final String? friendName;

  /// pending | rewarded | expired | rejected | reversed
  @override
  final String? status;
  @override
  final String? statusLabel;
  @override
  final num? rewardValue;
  @override
  final bool? rewardIsPercent;

  /// ISO 8601 (backend standard — utils/istDateUtils).
  @override
  final String? date;

  /// Optional context line, e.g. "Under review", "Friend cancelled".
  @override
  final String? note;

  @override
  String toString() {
    return 'ReferralEntry(id: $id, friendName: $friendName, status: $status, statusLabel: $statusLabel, rewardValue: $rewardValue, rewardIsPercent: $rewardIsPercent, date: $date, note: $note)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReferralEntryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.friendName, friendName) ||
                other.friendName == friendName) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.statusLabel, statusLabel) ||
                other.statusLabel == statusLabel) &&
            (identical(other.rewardValue, rewardValue) ||
                other.rewardValue == rewardValue) &&
            (identical(other.rewardIsPercent, rewardIsPercent) ||
                other.rewardIsPercent == rewardIsPercent) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.note, note) || other.note == note));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, friendName, status,
      statusLabel, rewardValue, rewardIsPercent, date, note);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ReferralEntryImplCopyWith<_$ReferralEntryImpl> get copyWith =>
      __$$ReferralEntryImplCopyWithImpl<_$ReferralEntryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReferralEntryImplToJson(
      this,
    );
  }
}

abstract class _ReferralEntry extends ReferralEntry {
  const factory _ReferralEntry(
      {final int? id,
      final String? friendName,
      final String? status,
      final String? statusLabel,
      final num? rewardValue,
      final bool? rewardIsPercent,
      final String? date,
      final String? note}) = _$ReferralEntryImpl;
  const _ReferralEntry._() : super._();

  factory _ReferralEntry.fromJson(Map<String, dynamic> json) =
      _$ReferralEntryImpl.fromJson;

  @override
  int? get id;
  @override

  /// Masked: first name + last initial (privacy).
  String? get friendName;
  @override

  /// pending | rewarded | expired | rejected | reversed
  String? get status;
  @override
  String? get statusLabel;
  @override
  num? get rewardValue;
  @override
  bool? get rewardIsPercent;
  @override

  /// ISO 8601 (backend standard — utils/istDateUtils).
  String? get date;
  @override

  /// Optional context line, e.g. "Under review", "Friend cancelled".
  String? get note;
  @override
  @JsonKey(ignore: true)
  _$$ReferralEntryImplCopyWith<_$ReferralEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ReferralApplyResponse _$ReferralApplyResponseFromJson(
    Map<String, dynamic> json) {
  return _ReferralApplyResponse.fromJson(json);
}

/// @nodoc
mixin _$ReferralApplyResponse {
  bool? get success => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;
  ReferralApplyData? get data => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ReferralApplyResponseCopyWith<ReferralApplyResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReferralApplyResponseCopyWith<$Res> {
  factory $ReferralApplyResponseCopyWith(ReferralApplyResponse value,
          $Res Function(ReferralApplyResponse) then) =
      _$ReferralApplyResponseCopyWithImpl<$Res, ReferralApplyResponse>;
  @useResult
  $Res call({bool? success, String? message, ReferralApplyData? data});

  $ReferralApplyDataCopyWith<$Res>? get data;
}

/// @nodoc
class _$ReferralApplyResponseCopyWithImpl<$Res,
        $Val extends ReferralApplyResponse>
    implements $ReferralApplyResponseCopyWith<$Res> {
  _$ReferralApplyResponseCopyWithImpl(this._value, this._then);

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
              as ReferralApplyData?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $ReferralApplyDataCopyWith<$Res>? get data {
    if (_value.data == null) {
      return null;
    }

    return $ReferralApplyDataCopyWith<$Res>(_value.data!, (value) {
      return _then(_value.copyWith(data: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ReferralApplyResponseImplCopyWith<$Res>
    implements $ReferralApplyResponseCopyWith<$Res> {
  factory _$$ReferralApplyResponseImplCopyWith(
          _$ReferralApplyResponseImpl value,
          $Res Function(_$ReferralApplyResponseImpl) then) =
      __$$ReferralApplyResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool? success, String? message, ReferralApplyData? data});

  @override
  $ReferralApplyDataCopyWith<$Res>? get data;
}

/// @nodoc
class __$$ReferralApplyResponseImplCopyWithImpl<$Res>
    extends _$ReferralApplyResponseCopyWithImpl<$Res,
        _$ReferralApplyResponseImpl>
    implements _$$ReferralApplyResponseImplCopyWith<$Res> {
  __$$ReferralApplyResponseImplCopyWithImpl(_$ReferralApplyResponseImpl _value,
      $Res Function(_$ReferralApplyResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = freezed,
    Object? message = freezed,
    Object? data = freezed,
  }) {
    return _then(_$ReferralApplyResponseImpl(
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
              as ReferralApplyData?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReferralApplyResponseImpl implements _ReferralApplyResponse {
  const _$ReferralApplyResponseImpl({this.success, this.message, this.data});

  factory _$ReferralApplyResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReferralApplyResponseImplFromJson(json);

  @override
  final bool? success;
  @override
  final String? message;
  @override
  final ReferralApplyData? data;

  @override
  String toString() {
    return 'ReferralApplyResponse(success: $success, message: $message, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReferralApplyResponseImpl &&
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
  _$$ReferralApplyResponseImplCopyWith<_$ReferralApplyResponseImpl>
      get copyWith => __$$ReferralApplyResponseImplCopyWithImpl<
          _$ReferralApplyResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReferralApplyResponseImplToJson(
      this,
    );
  }
}

abstract class _ReferralApplyResponse implements ReferralApplyResponse {
  const factory _ReferralApplyResponse(
      {final bool? success,
      final String? message,
      final ReferralApplyData? data}) = _$ReferralApplyResponseImpl;

  factory _ReferralApplyResponse.fromJson(Map<String, dynamic> json) =
      _$ReferralApplyResponseImpl.fromJson;

  @override
  bool? get success;
  @override
  String? get message;
  @override
  ReferralApplyData? get data;
  @override
  @JsonKey(ignore: true)
  _$$ReferralApplyResponseImplCopyWith<_$ReferralApplyResponseImpl>
      get copyWith => throw _privateConstructorUsedError;
}

ReferralApplyData _$ReferralApplyDataFromJson(Map<String, dynamic> json) {
  return _ReferralApplyData.fromJson(json);
}

/// @nodoc
mixin _$ReferralApplyData {
  String? get refereeCouponCode => throw _privateConstructorUsedError;
  num? get refereeValue => throw _privateConstructorUsedError;
  bool? get refereeIsPercent => throw _privateConstructorUsedError;
  String? get expiresAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ReferralApplyDataCopyWith<ReferralApplyData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReferralApplyDataCopyWith<$Res> {
  factory $ReferralApplyDataCopyWith(
          ReferralApplyData value, $Res Function(ReferralApplyData) then) =
      _$ReferralApplyDataCopyWithImpl<$Res, ReferralApplyData>;
  @useResult
  $Res call(
      {String? refereeCouponCode,
      num? refereeValue,
      bool? refereeIsPercent,
      String? expiresAt});
}

/// @nodoc
class _$ReferralApplyDataCopyWithImpl<$Res, $Val extends ReferralApplyData>
    implements $ReferralApplyDataCopyWith<$Res> {
  _$ReferralApplyDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? refereeCouponCode = freezed,
    Object? refereeValue = freezed,
    Object? refereeIsPercent = freezed,
    Object? expiresAt = freezed,
  }) {
    return _then(_value.copyWith(
      refereeCouponCode: freezed == refereeCouponCode
          ? _value.refereeCouponCode
          : refereeCouponCode // ignore: cast_nullable_to_non_nullable
              as String?,
      refereeValue: freezed == refereeValue
          ? _value.refereeValue
          : refereeValue // ignore: cast_nullable_to_non_nullable
              as num?,
      refereeIsPercent: freezed == refereeIsPercent
          ? _value.refereeIsPercent
          : refereeIsPercent // ignore: cast_nullable_to_non_nullable
              as bool?,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ReferralApplyDataImplCopyWith<$Res>
    implements $ReferralApplyDataCopyWith<$Res> {
  factory _$$ReferralApplyDataImplCopyWith(_$ReferralApplyDataImpl value,
          $Res Function(_$ReferralApplyDataImpl) then) =
      __$$ReferralApplyDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? refereeCouponCode,
      num? refereeValue,
      bool? refereeIsPercent,
      String? expiresAt});
}

/// @nodoc
class __$$ReferralApplyDataImplCopyWithImpl<$Res>
    extends _$ReferralApplyDataCopyWithImpl<$Res, _$ReferralApplyDataImpl>
    implements _$$ReferralApplyDataImplCopyWith<$Res> {
  __$$ReferralApplyDataImplCopyWithImpl(_$ReferralApplyDataImpl _value,
      $Res Function(_$ReferralApplyDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? refereeCouponCode = freezed,
    Object? refereeValue = freezed,
    Object? refereeIsPercent = freezed,
    Object? expiresAt = freezed,
  }) {
    return _then(_$ReferralApplyDataImpl(
      refereeCouponCode: freezed == refereeCouponCode
          ? _value.refereeCouponCode
          : refereeCouponCode // ignore: cast_nullable_to_non_nullable
              as String?,
      refereeValue: freezed == refereeValue
          ? _value.refereeValue
          : refereeValue // ignore: cast_nullable_to_non_nullable
              as num?,
      refereeIsPercent: freezed == refereeIsPercent
          ? _value.refereeIsPercent
          : refereeIsPercent // ignore: cast_nullable_to_non_nullable
              as bool?,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReferralApplyDataImpl implements _ReferralApplyData {
  const _$ReferralApplyDataImpl(
      {this.refereeCouponCode,
      this.refereeValue,
      this.refereeIsPercent,
      this.expiresAt});

  factory _$ReferralApplyDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReferralApplyDataImplFromJson(json);

  @override
  final String? refereeCouponCode;
  @override
  final num? refereeValue;
  @override
  final bool? refereeIsPercent;
  @override
  final String? expiresAt;

  @override
  String toString() {
    return 'ReferralApplyData(refereeCouponCode: $refereeCouponCode, refereeValue: $refereeValue, refereeIsPercent: $refereeIsPercent, expiresAt: $expiresAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReferralApplyDataImpl &&
            (identical(other.refereeCouponCode, refereeCouponCode) ||
                other.refereeCouponCode == refereeCouponCode) &&
            (identical(other.refereeValue, refereeValue) ||
                other.refereeValue == refereeValue) &&
            (identical(other.refereeIsPercent, refereeIsPercent) ||
                other.refereeIsPercent == refereeIsPercent) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, refereeCouponCode, refereeValue,
      refereeIsPercent, expiresAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ReferralApplyDataImplCopyWith<_$ReferralApplyDataImpl> get copyWith =>
      __$$ReferralApplyDataImplCopyWithImpl<_$ReferralApplyDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReferralApplyDataImplToJson(
      this,
    );
  }
}

abstract class _ReferralApplyData implements ReferralApplyData {
  const factory _ReferralApplyData(
      {final String? refereeCouponCode,
      final num? refereeValue,
      final bool? refereeIsPercent,
      final String? expiresAt}) = _$ReferralApplyDataImpl;

  factory _ReferralApplyData.fromJson(Map<String, dynamic> json) =
      _$ReferralApplyDataImpl.fromJson;

  @override
  String? get refereeCouponCode;
  @override
  num? get refereeValue;
  @override
  bool? get refereeIsPercent;
  @override
  String? get expiresAt;
  @override
  @JsonKey(ignore: true)
  _$$ReferralApplyDataImplCopyWith<_$ReferralApplyDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ReferralValidateResponse _$ReferralValidateResponseFromJson(
    Map<String, dynamic> json) {
  return _ReferralValidateResponse.fromJson(json);
}

/// @nodoc
mixin _$ReferralValidateResponse {
  bool? get success => throw _privateConstructorUsedError;
  bool get valid => throw _privateConstructorUsedError;
  String? get referrerName => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ReferralValidateResponseCopyWith<ReferralValidateResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReferralValidateResponseCopyWith<$Res> {
  factory $ReferralValidateResponseCopyWith(ReferralValidateResponse value,
          $Res Function(ReferralValidateResponse) then) =
      _$ReferralValidateResponseCopyWithImpl<$Res, ReferralValidateResponse>;
  @useResult
  $Res call({bool? success, bool valid, String? referrerName, String? message});
}

/// @nodoc
class _$ReferralValidateResponseCopyWithImpl<$Res,
        $Val extends ReferralValidateResponse>
    implements $ReferralValidateResponseCopyWith<$Res> {
  _$ReferralValidateResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = freezed,
    Object? valid = null,
    Object? referrerName = freezed,
    Object? message = freezed,
  }) {
    return _then(_value.copyWith(
      success: freezed == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool?,
      valid: null == valid
          ? _value.valid
          : valid // ignore: cast_nullable_to_non_nullable
              as bool,
      referrerName: freezed == referrerName
          ? _value.referrerName
          : referrerName // ignore: cast_nullable_to_non_nullable
              as String?,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ReferralValidateResponseImplCopyWith<$Res>
    implements $ReferralValidateResponseCopyWith<$Res> {
  factory _$$ReferralValidateResponseImplCopyWith(
          _$ReferralValidateResponseImpl value,
          $Res Function(_$ReferralValidateResponseImpl) then) =
      __$$ReferralValidateResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool? success, bool valid, String? referrerName, String? message});
}

/// @nodoc
class __$$ReferralValidateResponseImplCopyWithImpl<$Res>
    extends _$ReferralValidateResponseCopyWithImpl<$Res,
        _$ReferralValidateResponseImpl>
    implements _$$ReferralValidateResponseImplCopyWith<$Res> {
  __$$ReferralValidateResponseImplCopyWithImpl(
      _$ReferralValidateResponseImpl _value,
      $Res Function(_$ReferralValidateResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = freezed,
    Object? valid = null,
    Object? referrerName = freezed,
    Object? message = freezed,
  }) {
    return _then(_$ReferralValidateResponseImpl(
      success: freezed == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool?,
      valid: null == valid
          ? _value.valid
          : valid // ignore: cast_nullable_to_non_nullable
              as bool,
      referrerName: freezed == referrerName
          ? _value.referrerName
          : referrerName // ignore: cast_nullable_to_non_nullable
              as String?,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReferralValidateResponseImpl implements _ReferralValidateResponse {
  const _$ReferralValidateResponseImpl(
      {this.success, this.valid = false, this.referrerName, this.message});

  factory _$ReferralValidateResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReferralValidateResponseImplFromJson(json);

  @override
  final bool? success;
  @override
  @JsonKey()
  final bool valid;
  @override
  final String? referrerName;
  @override
  final String? message;

  @override
  String toString() {
    return 'ReferralValidateResponse(success: $success, valid: $valid, referrerName: $referrerName, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReferralValidateResponseImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.valid, valid) || other.valid == valid) &&
            (identical(other.referrerName, referrerName) ||
                other.referrerName == referrerName) &&
            (identical(other.message, message) || other.message == message));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, success, valid, referrerName, message);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ReferralValidateResponseImplCopyWith<_$ReferralValidateResponseImpl>
      get copyWith => __$$ReferralValidateResponseImplCopyWithImpl<
          _$ReferralValidateResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReferralValidateResponseImplToJson(
      this,
    );
  }
}

abstract class _ReferralValidateResponse implements ReferralValidateResponse {
  const factory _ReferralValidateResponse(
      {final bool? success,
      final bool valid,
      final String? referrerName,
      final String? message}) = _$ReferralValidateResponseImpl;

  factory _ReferralValidateResponse.fromJson(Map<String, dynamic> json) =
      _$ReferralValidateResponseImpl.fromJson;

  @override
  bool? get success;
  @override
  bool get valid;
  @override
  String? get referrerName;
  @override
  String? get message;
  @override
  @JsonKey(ignore: true)
  _$$ReferralValidateResponseImplCopyWith<_$ReferralValidateResponseImpl>
      get copyWith => throw _privateConstructorUsedError;
}
