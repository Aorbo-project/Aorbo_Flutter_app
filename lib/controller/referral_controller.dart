import 'package:arobo_app/models/referral/referral_models.dart';
import 'package:arobo_app/repository/api_result.dart';
import 'package:arobo_app/repository/referral_repository.dart';
import 'package:get/get.dart';

/// Single source of truth for the Refer & Earn screen.
///
/// - `infoState` drives the whole screen (loading / error / data).
/// - `applyState` is a separate transient state for the "enter a code" flow
///   so applying a code never blanks the screen.
/// - Nothing about rewards, milestones, brand or share copy is hardcoded —
///   it all comes from `infoState.data` (the backend's live config).
class ReferralController extends GetxController {
  final ReferralRepository _repo = ReferralRepository();

  final Rx<ApiResult<ReferralInfo>> infoState =
      const ApiResult<ReferralInfo>.init().obs;

  /// null = idle. loading = request in flight. success/error = last result
  /// (message shown once, then cleared by the screen).
  final Rxn<ApiResult<ReferralApplyResponse>> applyState =
      Rxn<ApiResult<ReferralApplyResponse>>();

  /// Live inline feedback for the code field while the user types.
  final Rxn<ReferralValidateResponse> validateResult =
      Rxn<ReferralValidateResponse>();
  final RxBool validating = false.obs;

  ReferralInfo? get info => infoState.value.maybeWhen(
        success: (data) => data,
        orElse: () => null,
      );

  bool get isLoading => infoState.value.maybeWhen(
        loading: (_) => true,
        init: () => true,
        orElse: () => false,
      );
  bool get hasError =>
      infoState.value.maybeWhen(error: (_) => true, orElse: () => false);
  String? get errorMessage =>
      infoState.value.maybeWhen(error: (e) => e, orElse: () => null);

  bool get programEnabled => info?.program?.enabled ?? true;
  bool get canApplyCode => info?.canApplyCode ?? false;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load({bool silent = false}) async {
    if (!silent) infoState.value = const ApiResult.loading('');
    try {
      final data = await _repo.getReferralInfo();
      infoState.value = ApiResult.success(data);
    } catch (e) {
      // Keep any previously-loaded data on a silent refresh failure.
      if (silent && info != null) return;
      infoState.value = ApiResult.error(_clean(e));
    }
  }

  Future<void> reload() => load(silent: info != null);

  // ── Apply a referrer's code ────────────────────────────────────────────────

  Future<void> validateCode(String code) async {
    final trimmed = code.trim();
    if (trimmed.length < 4) {
      validateResult.value = null;
      return;
    }
    validating.value = true;
    try {
      validateResult.value = await _repo.validateCode(trimmed);
    } finally {
      validating.value = false;
    }
  }

  void clearValidation() => validateResult.value = null;

  /// Returns true on success. The screen reads `applyState` for the message
  /// and refreshes the info payload so the applied code / coupon show up.
  Future<bool> applyCode(String code) async {
    applyState.value = const ApiResult.loading('');
    final res = await _repo.applyCode(code);
    if (res.success == true) {
      applyState.value = ApiResult.success(res);
      await load(silent: true);
      return true;
    }
    applyState.value = ApiResult.error(res.message ?? 'Could not apply this code');
    return false;
  }

  void clearApplyState() => applyState.value = null;

  String _clean(Object e) {
    var s = e.toString();
    if (s.startsWith('Exception: ')) s = s.substring('Exception: '.length);
    return s.isEmpty ? 'Something went wrong' : s;
  }
}
