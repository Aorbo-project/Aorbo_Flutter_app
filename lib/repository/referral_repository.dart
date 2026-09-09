import 'dart:convert';
import 'dart:developer';

import 'package:arobo_app/models/referral/referral_models.dart';
import 'package:arobo_app/repository/network_url.dart';
import 'package:arobo_app/repository/repository.dart';

/// Thin typed layer over the 3 referral endpoints. All parsing/normalisation
/// lives here so the controller only deals with models + a clean error string.
class ReferralRepository {
  final Repository _repository = Repository();

  /// GET /api/v1/customer/referral
  /// Throws a human-readable string on any non-success.
  Future<ReferralInfo> getReferralInfo() async {
    final response = await _repository.getApiCall(url: NetworkUrl.referralInfo);
    if (response == null) {
      throw 'No response from server';
    }
    final parsed = ReferralInfoResponse.fromJson(
      response is Map<String, dynamic> ? response : Map<String, dynamic>.from(response as Map),
    );
    if (parsed.success == true && parsed.data != null) {
      return parsed.data!;
    }
    throw parsed.message ?? 'Could not load your referral details';
  }

  /// POST /api/v1/customer/referral/apply { code }
  /// Returns the full response so the caller can surface the exact message
  /// (success or a specific 400/403/404/409 reason).
  Future<ReferralApplyResponse> applyCode(String code) async {
    try {
      final response = await _repository.postApiCall(
        url: NetworkUrl.referralApply,
        body: json.encode({'code': code.trim().toUpperCase()}),
      );
      if (response == null) {
        return const ReferralApplyResponse(
          success: false,
          message: 'No response from server',
        );
      }
      return ReferralApplyResponse.fromJson(
        response is Map<String, dynamic> ? response : Map<String, dynamic>.from(response as Map),
      );
    } catch (e) {
      // Repository.postApiCall throws Exception('<server message>') on 4xx.
      log('applyCode error: $e');
      return ReferralApplyResponse(
        success: false,
        message: _clean(e),
      );
    }
  }

  /// GET /api/v1/customer/referral/validate?code=
  /// Never throws — a failed validate just means "can't confirm right now".
  Future<ReferralValidateResponse> validateCode(String code, {String? phone}) async {
    try {
      final response = await _repository.getApiCall(
        url: NetworkUrl.referralValidate(code, phone: phone),
      );
      if (response == null) {
        return const ReferralValidateResponse(valid: false, message: '');
      }
      return ReferralValidateResponse.fromJson(
        response is Map<String, dynamic> ? response : Map<String, dynamic>.from(response as Map),
      );
    } catch (e) {
      log('validateCode error: $e');
      return const ReferralValidateResponse(valid: false, message: '');
    }
  }

  String _clean(Object e) {
    var s = e.toString();
    if (s.startsWith('Exception: ')) s = s.substring('Exception: '.length);
    return s.isEmpty ? 'Something went wrong' : s;
  }
}
