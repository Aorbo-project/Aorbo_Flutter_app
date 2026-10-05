import 'package:arobo_app/main.dart' show sp;
import 'package:arobo_app/repository/network_url.dart';
import 'package:arobo_app/repository/repository.dart';
import 'package:arobo_app/services/app_feedback.dart';
import 'package:arobo_app/utils/ist_date_utils.dart';
import 'package:arobo_app/utils/shared_preferences.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'app_update_policy.dart';
import 'app_version_info.dart';
import 'update_required_screen.dart';

/// GET version/check for this build. Null when offline or on any error — the
/// caller fails open (the server enforces the minimum anyway).
Future<AppUpdatePolicy?> fetchAppUpdatePolicy() async {
  final repo = Repository();
  // Offline: skip quietly instead of getApiCall's "check your connection"
  // toast — a resume re-check must never nag.
  if (!await repo.isInternetAvailable()) return null;
  final info = AppVersionInfo.current ?? await AppVersionInfo.load();
  final version = (info == null || info.version.isEmpty)
      ? '1.0.0'
      : info.version;
  final body = await repo.getApiCall(
    url: NetworkUrl.validateVersion(
      version,
      info?.platform ?? AppVersionInfo.currentPlatformName(),
      build: info?.build,
    ),
  );
  return AppUpdatePolicy.fromResponse(body);
}

enum UpdateBannerKind {
  /// The minimum goes up on a known date: "Please update by …".
  announced,

  /// A newer build exists; optional.
  available,
}

/// What the dashboard's update banner should say.
@immutable
class UpdateBannerInfo {
  const UpdateBannerInfo({required this.kind, required this.policy});

  final UpdateBannerKind kind;
  final AppUpdatePolicy policy;

  /// The enforcement date in IST, e.g. "20 Oct 2026"; null when unknown.
  String? get deadlineLabel {
    final from = policy.requiredFrom;
    return from == null ? null : ISTDateUtils.formatDate(from);
  }
}

/// The app's side of the force-update policy.
///
///  - [check] asks the server (cold start from the splash screen, then on
///    every return to the app, at most once per [resumeThrottle]). It fails
///    open: no answer means carry on.
///  - update_required, or a 426 / 403 APP_UPDATE_REQUIRED from any request
///    ([forceBlock], called by the network layer), replaces everything with
///    [UpdateRequiredScreen]. That happens once, and the app then stays
///    blocked until it is restarted — any later navigation is undone (see
///    [onRouteChanged]).
///  - update_announced / update_available drive the dashboard banner
///    ([currentBanner]).
///
/// A plain singleton, not a GetxService: logout runs Get.deleteAll(force:
/// true), and the block must outlive it. Tests swap [instance].
class AppUpdateGate with WidgetsBindingObserver {
  @visibleForTesting
  AppUpdateGate({
    Future<AppUpdatePolicy?> Function()? fetchPolicy,
    DateTime Function()? clock,
    void Function(AppUpdateBlock block)? present,
    this.resumeThrottle = const Duration(minutes: 30),
  }) : _fetchPolicy = fetchPolicy ?? fetchAppUpdatePolicy,
       _clock = clock ?? DateTime.now,
       _present = present ?? _presentWithGet;

  static AppUpdateGate instance = AppUpdateGate();

  final Future<AppUpdatePolicy?> Function() _fetchPolicy;
  final DateTime Function() _clock;
  final void Function(AppUpdateBlock block) _present;
  final Duration resumeThrottle;

  /// The last answer from version/check (kept when a later check fails).
  final Rxn<AppUpdatePolicy> policy = Rxn<AppUpdatePolicy>();

  final RxBool _blocked = false.obs;
  AppUpdateBlock? _block;
  DateTime? _lastCheckAt;
  Future<AppUpdatePolicy?>? _inFlight;
  bool _observing = false;
  bool _reassertScheduled = false;

  // Banner dismissals: "announced" hides for the rest of today (IST) in
  // memory, so it is back tomorrow and on the next cold start; "available"
  // is remembered per latest_build in prefs.
  final RxInt _bannerTick = 0.obs;
  String? _noticeHiddenDay;
  String? _dismissedAvailableKey;

  bool get isBlocked => _blocked.value;

  /// What the block screen shows; null until blocked.
  AppUpdateBlock? get block => _block;

  /// Asks the server about this build. Concurrent calls share one request.
  /// Returns the policy, or null when there was no usable answer.
  Future<AppUpdatePolicy?> check() {
    _startObserving();
    return _inFlight ??= _runCheck().whenComplete(() => _inFlight = null);
  }

  Future<AppUpdatePolicy?> _runCheck() async {
    _lastCheckAt = _clock();
    AppUpdatePolicy? result;
    try {
      result = await _fetchPolicy();
    } catch (e) {
      debugPrint('version/check failed, continuing: $e');
    }
    if (result == null) return null;
    policy.value = result;
    if (result.updateRequired) {
      forceBlock(message: result.updateMessage, storeUrl: result.storeUrl);
    }
    return result;
  }

  /// Re-checks on a return to the app, unless blocked or checked within the
  /// last [resumeThrottle].
  @visibleForTesting
  Future<void> recheckIfStale() async {
    if (isBlocked) return;
    final last = _lastCheckAt;
    if (last != null && _clock().difference(last) < resumeThrottle) return;
    await check();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) recheckIfStale();
  }

  void _startObserving() {
    if (_observing) return;
    _observing = true;
    WidgetsBinding.instance.addObserver(this);
  }

  /// Shows [UpdateRequiredScreen] in place of everything. Only the first
  /// call does anything; the app stays blocked until restarted.
  void forceBlock({String? message, String? storeUrl}) {
    if (_blocked.value) return;
    _blocked.value = true;
    final m = message?.trim();
    _block = AppUpdateBlock(
      message: (m == null || m.isEmpty) ? policy.value?.updateMessage : m,
      storeUrl: safeStoreUrl(storeUrl) ?? policy.value?.storeUrl,
    );
    // Requests still in flight fail now; their error toasts would only sit
    // on top of the update screen.
    AppFeedback.dismissAll();
    AppFeedback.muted = true;
    _presentSafely();
  }

  /// Hooked to GetMaterialApp.routingCallback: once blocked, any navigation
  /// away from the update screen (a notification tap, a stray offAll, ...)
  /// is put back.
  void onRouteChanged(String? route) {
    if (!_blocked.value ||
        route == UpdateRequiredScreen.routeName ||
        _reassertScheduled) {
      return;
    }
    _reassertScheduled = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _reassertScheduled = false;
      if (_blocked.value &&
          Get.currentRoute != UpdateRequiredScreen.routeName) {
        _presentSafely();
      }
    });
    SchedulerBinding.instance.scheduleFrame();
  }

  void _presentSafely() {
    void run() {
      try {
        _present(_block ?? const AppUpdateBlock());
      } catch (e) {
        debugPrint('Could not open the update screen: $e');
      }
    }

    // Never navigate in the middle of a build.
    final phase = SchedulerBinding.instance.schedulerPhase;
    if (phase == SchedulerPhase.idle ||
        phase == SchedulerPhase.postFrameCallbacks) {
      run();
    } else {
      SchedulerBinding.instance.addPostFrameCallback((_) => run());
    }
  }

  static void _presentWithGet(AppUpdateBlock block) {
    Get.offAll(
      () => UpdateRequiredScreen(
        message: block.message,
        storeUrl: block.storeUrl,
      ),
      routeName: UpdateRequiredScreen.routeName,
      transition: Transition.fadeIn,
    );
  }

  // ── Dashboard banner ────────────────────────────────────────────────────

  /// The banner to show now, or null. Reactive inside an Obx.
  UpdateBannerInfo? currentBanner() {
    _bannerTick.value; // rebuild on dismiss
    if (_blocked.value) return null;
    final p = policy.value;
    if (p == null || p.updateRequired) return null;
    if (p.updateAnnounced) {
      if (_noticeHiddenDay == _istDay(_clock())) return null;
      return UpdateBannerInfo(kind: UpdateBannerKind.announced, policy: p);
    }
    if (p.updateAvailable) {
      final key = p.dismissKey ?? '';
      if (key == (_dismissedAvailableKey ?? _readDismissedKey())) return null;
      return UpdateBannerInfo(kind: UpdateBannerKind.available, policy: p);
    }
    return null;
  }

  /// Hides the current banner: "announced" for the rest of today, "available"
  /// until a newer build is published.
  Future<void> dismissBanner() async {
    final banner = currentBanner();
    if (banner == null) return;
    if (banner.kind == UpdateBannerKind.announced) {
      _noticeHiddenDay = _istDay(_clock());
    } else {
      final key = banner.policy.dismissKey ?? '';
      _dismissedAvailableKey = key;
      if (key.isNotEmpty) {
        try {
          await sp?.putString(SpUtil.dismissedUpdateBuild, key);
        } catch (_) {}
      }
    }
    _bannerTick.value++;
  }

  String? _readDismissedKey() {
    try {
      final v = sp?.getString(SpUtil.dismissedUpdateBuild);
      return v is String ? v : null;
    } catch (_) {
      return null;
    }
  }

  static String _istDay(DateTime now) =>
      ISTDateUtils.formatCustom(now, 'yyyy-MM-dd');

  /// Stops watching the app lifecycle (tests).
  @visibleForTesting
  void dispose() {
    if (_observing) WidgetsBinding.instance.removeObserver(this);
    _observing = false;
  }
}
