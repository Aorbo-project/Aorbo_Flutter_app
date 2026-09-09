// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'referral_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReferralInfoResponseImpl _$$ReferralInfoResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$ReferralInfoResponseImpl(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: json['data'] == null
          ? null
          : ReferralInfo.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$ReferralInfoResponseImplToJson(
        _$ReferralInfoResponseImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

_$ReferralInfoImpl _$$ReferralInfoImplFromJson(Map<String, dynamic> json) =>
    _$ReferralInfoImpl(
      program: json['program'] == null
          ? null
          : ReferralProgram.fromJson(json['program'] as Map<String, dynamic>),
      code: json['code'] as String?,
      shareUrl: json['shareUrl'] as String?,
      shareMessage: json['shareMessage'] as String?,
      reward: json['reward'] == null
          ? null
          : ReferralReward.fromJson(json['reward'] as Map<String, dynamic>),
      stats: json['stats'] == null
          ? null
          : ReferralStats.fromJson(json['stats'] as Map<String, dynamic>),
      milestone: json['milestone'] == null
          ? null
          : ReferralMilestone.fromJson(
              json['milestone'] as Map<String, dynamic>),
      history: (json['history'] as List<dynamic>?)
          ?.map((e) => ReferralEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      canApplyCode: json['canApplyCode'] as bool?,
      appliedCode: json['appliedCode'] as String?,
    );

Map<String, dynamic> _$$ReferralInfoImplToJson(_$ReferralInfoImpl instance) =>
    <String, dynamic>{
      'program': instance.program,
      'code': instance.code,
      'shareUrl': instance.shareUrl,
      'shareMessage': instance.shareMessage,
      'reward': instance.reward,
      'stats': instance.stats,
      'milestone': instance.milestone,
      'history': instance.history,
      'canApplyCode': instance.canApplyCode,
      'appliedCode': instance.appliedCode,
    };

_$ReferralProgramImpl _$$ReferralProgramImplFromJson(
        Map<String, dynamic> json) =>
    _$ReferralProgramImpl(
      enabled: json['enabled'] as bool?,
      termsUrl: json['termsUrl'] as String?,
    );

Map<String, dynamic> _$$ReferralProgramImplToJson(
        _$ReferralProgramImpl instance) =>
    <String, dynamic>{
      'enabled': instance.enabled,
      'termsUrl': instance.termsUrl,
    };

_$ReferralRewardImpl _$$ReferralRewardImplFromJson(Map<String, dynamic> json) =>
    _$ReferralRewardImpl(
      refereeText: json['refereeText'] as String?,
      referrerText: json['referrerText'] as String?,
      refereeValue: json['refereeValue'] as num?,
      refereeIsPercent: json['refereeIsPercent'] as bool?,
      referrerValue: json['referrerValue'] as num?,
      referrerIsPercent: json['referrerIsPercent'] as bool?,
    );

Map<String, dynamic> _$$ReferralRewardImplToJson(
        _$ReferralRewardImpl instance) =>
    <String, dynamic>{
      'refereeText': instance.refereeText,
      'referrerText': instance.referrerText,
      'refereeValue': instance.refereeValue,
      'refereeIsPercent': instance.refereeIsPercent,
      'referrerValue': instance.referrerValue,
      'referrerIsPercent': instance.referrerIsPercent,
    };

_$ReferralStatsImpl _$$ReferralStatsImplFromJson(Map<String, dynamic> json) =>
    _$ReferralStatsImpl(
      totalReferred: json['totalReferred'] as int? ?? 0,
      pending: json['pending'] as int? ?? 0,
      rewarded: json['rewarded'] as int? ?? 0,
      totalEarned: json['totalEarned'] as num? ?? 0,
    );

Map<String, dynamic> _$$ReferralStatsImplToJson(_$ReferralStatsImpl instance) =>
    <String, dynamic>{
      'totalReferred': instance.totalReferred,
      'pending': instance.pending,
      'rewarded': instance.rewarded,
      'totalEarned': instance.totalEarned,
    };

_$ReferralMilestoneImpl _$$ReferralMilestoneImplFromJson(
        Map<String, dynamic> json) =>
    _$ReferralMilestoneImpl(
      enabled: json['enabled'] as bool? ?? false,
      target: json['target'] as int? ?? 0,
      current: json['current'] as int? ?? 0,
      bonusText: json['bonusText'] as String?,
    );

Map<String, dynamic> _$$ReferralMilestoneImplToJson(
        _$ReferralMilestoneImpl instance) =>
    <String, dynamic>{
      'enabled': instance.enabled,
      'target': instance.target,
      'current': instance.current,
      'bonusText': instance.bonusText,
    };

_$ReferralEntryImpl _$$ReferralEntryImplFromJson(Map<String, dynamic> json) =>
    _$ReferralEntryImpl(
      id: json['id'] as int?,
      friendName: json['friendName'] as String?,
      status: json['status'] as String?,
      statusLabel: json['statusLabel'] as String?,
      rewardValue: json['rewardValue'] as num?,
      rewardIsPercent: json['rewardIsPercent'] as bool?,
      date: json['date'] as String?,
      note: json['note'] as String?,
    );

Map<String, dynamic> _$$ReferralEntryImplToJson(_$ReferralEntryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'friendName': instance.friendName,
      'status': instance.status,
      'statusLabel': instance.statusLabel,
      'rewardValue': instance.rewardValue,
      'rewardIsPercent': instance.rewardIsPercent,
      'date': instance.date,
      'note': instance.note,
    };

_$ReferralApplyResponseImpl _$$ReferralApplyResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$ReferralApplyResponseImpl(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: json['data'] == null
          ? null
          : ReferralApplyData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$ReferralApplyResponseImplToJson(
        _$ReferralApplyResponseImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

_$ReferralApplyDataImpl _$$ReferralApplyDataImplFromJson(
        Map<String, dynamic> json) =>
    _$ReferralApplyDataImpl(
      refereeCouponCode: json['refereeCouponCode'] as String?,
      refereeValue: json['refereeValue'] as num?,
      refereeIsPercent: json['refereeIsPercent'] as bool?,
      expiresAt: json['expiresAt'] as String?,
    );

Map<String, dynamic> _$$ReferralApplyDataImplToJson(
        _$ReferralApplyDataImpl instance) =>
    <String, dynamic>{
      'refereeCouponCode': instance.refereeCouponCode,
      'refereeValue': instance.refereeValue,
      'refereeIsPercent': instance.refereeIsPercent,
      'expiresAt': instance.expiresAt,
    };

_$ReferralValidateResponseImpl _$$ReferralValidateResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$ReferralValidateResponseImpl(
      success: json['success'] as bool?,
      valid: json['valid'] as bool? ?? false,
      referrerName: json['referrerName'] as String?,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$$ReferralValidateResponseImplToJson(
        _$ReferralValidateResponseImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'valid': instance.valid,
      'referrerName': instance.referrerName,
      'message': instance.message,
    };
