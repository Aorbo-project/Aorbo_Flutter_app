import 'package:freezed_annotation/freezed_annotation.dart';

part 'referral_models.freezed.dart';
part 'referral_models.g.dart';

/// Everything the Refer & Earn screen needs, in one payload.
/// Backend: GET /api/v1/customer/referral  (camelCase keys — new endpoint).
@freezed
class ReferralInfoResponse with _$ReferralInfoResponse {
  const factory ReferralInfoResponse({
    bool? success,
    String? message,
    ReferralInfo? data,
  }) = _ReferralInfoResponse;

  factory ReferralInfoResponse.fromJson(Map<String, dynamic> json) =>
      _$ReferralInfoResponseFromJson(json);
}

@freezed
class ReferralInfo with _$ReferralInfo {
  const factory ReferralInfo({
    ReferralProgram? program,

    /// The customer's own code. Backend generates it lazily on the first
    /// GET, so this should be non-null in practice — but the UI still
    /// guards for null (shows a "generating…" state).
    String? code,

    /// Play Store / deep link the share sheet points at.
    String? shareUrl,

    /// Ready-to-send message, fully composed by the backend from the live
    /// config (brand, code, reward amounts, link). The client never builds
    /// its own copy — so a policy/number change is one backend edit.
    String? shareMessage,

    ReferralReward? reward,
    ReferralStats? stats,
    ReferralMilestone? milestone,
    List<ReferralEntry>? history,

    /// True only when this customer is still eligible to enter someone
    /// else's code (new account, no bookings, none applied, within window).
    bool? canApplyCode,

    /// The code this customer used, if any.
    String? appliedCode,
  }) = _ReferralInfo;

  factory ReferralInfo.fromJson(Map<String, dynamic> json) =>
      _$ReferralInfoFromJson(json);
}

@freezed
class ReferralProgram with _$ReferralProgram {
  const factory ReferralProgram({
    bool? enabled,
    String? termsUrl,
  }) = _ReferralProgram;

  factory ReferralProgram.fromJson(Map<String, dynamic> json) =>
      _$ReferralProgramFromJson(json);
}

/// Display copy + raw numbers. Copy is authored server-side; the raw
/// values are here only so the UI can render its own emphasised numerals.
@freezed
class ReferralReward with _$ReferralReward {
  const factory ReferralReward({
    String? refereeText,
    String? referrerText,
    num? refereeValue,
    bool? refereeIsPercent,
    num? referrerValue,
    bool? referrerIsPercent,
  }) = _ReferralReward;

  factory ReferralReward.fromJson(Map<String, dynamic> json) =>
      _$ReferralRewardFromJson(json);
}

@freezed
class ReferralStats with _$ReferralStats {
  const factory ReferralStats({
    /// People who applied my code (any status).
    @Default(0) int totalReferred,

    /// Applied, friend hasn't completed a trek yet.
    @Default(0) int pending,

    /// Friend completed → my coupon was issued.
    @Default(0) int rewarded,

    /// Sum of my referrer-coupon face values that were issued.
    @Default(0) num totalEarned,
  }) = _ReferralStats;

  factory ReferralStats.fromJson(Map<String, dynamic> json) =>
      _$ReferralStatsFromJson(json);
}

@freezed
class ReferralMilestone with _$ReferralMilestone {
  const factory ReferralMilestone({
    @Default(false) bool enabled,
    @Default(0) int target,
    @Default(0) int current,
    String? bonusText,
  }) = _ReferralMilestone;

  factory ReferralMilestone.fromJson(Map<String, dynamic> json) =>
      _$ReferralMilestoneFromJson(json);
}

/// One row in the referral history list. `status` is the raw enum;
/// `statusLabel` is the human string the backend already localised.
@freezed
class ReferralEntry with _$ReferralEntry {
  const factory ReferralEntry({
    int? id,

    /// Masked: first name + last initial (privacy).
    String? friendName,

    /// pending | rewarded | expired | rejected | reversed
    String? status,
    String? statusLabel,

    num? rewardValue,
    bool? rewardIsPercent,

    /// ISO 8601 (backend standard — utils/istDateUtils).
    String? date,

    /// Optional context line, e.g. "Under review", "Friend cancelled".
    String? note,
  }) = _ReferralEntry;

  factory ReferralEntry.fromJson(Map<String, dynamic> json) =>
      _$ReferralEntryFromJson(json);

  const ReferralEntry._();

  ReferralStatus get parsedStatus {
    switch (status) {
      case 'rewarded':
        return ReferralStatus.rewarded;
      case 'expired':
        return ReferralStatus.expired;
      case 'rejected':
        return ReferralStatus.rejected;
      case 'reversed':
        return ReferralStatus.reversed;
      case 'pending':
      default:
        return ReferralStatus.pending;
    }
  }

  DateTime? get parsedDate => date == null ? null : DateTime.tryParse(date!);
}

enum ReferralStatus { pending, rewarded, expired, rejected, reversed }

/// Backend: POST /api/v1/customer/referral/apply  { code }
@freezed
class ReferralApplyResponse with _$ReferralApplyResponse {
  const factory ReferralApplyResponse({
    bool? success,
    String? message,
    ReferralApplyData? data,
  }) = _ReferralApplyResponse;

  factory ReferralApplyResponse.fromJson(Map<String, dynamic> json) =>
      _$ReferralApplyResponseFromJson(json);
}

@freezed
class ReferralApplyData with _$ReferralApplyData {
  const factory ReferralApplyData({
    String? refereeCouponCode,
    num? refereeValue,
    bool? refereeIsPercent,
    String? expiresAt,
  }) = _ReferralApplyData;

  factory ReferralApplyData.fromJson(Map<String, dynamic> json) =>
      _$ReferralApplyDataFromJson(json);
}

/// Backend: GET /api/v1/customer/referral/validate?code=
@freezed
class ReferralValidateResponse with _$ReferralValidateResponse {
  const factory ReferralValidateResponse({
    bool? success,
    @Default(false) bool valid,
    String? referrerName,
    String? message,
  }) = _ReferralValidateResponse;

  factory ReferralValidateResponse.fromJson(Map<String, dynamic> json) =>
      _$ReferralValidateResponseFromJson(json);
}
