import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

import '../theme/app_tokens.dart';
import '../theme/app_typography.dart';
import '../utils/custom_snackbar.dart';
import '../utils/screen_constants.dart';
import 'giveaway_api.dart';
import 'giveaway_bridge.dart';
import 'giveaway_config.dart';
import 'giveaway_web_policy.dart';

/// Aorbo Trek Giveaway — hosts the campaign web page in a locked-down
/// in-app browser.
///
/// The page is the whole campaign UI (entry, survey, entry number, live draw,
/// invite view) so it can change without an app release. This screen owns
/// what must never depend on the page: the app bar, the native Rules link,
/// loading and error-with-retry states, and the bridge that carries the
/// page's requests to the backend (see GiveawayBridge).
///
/// Lock-down: only GiveawayConfig.webHost/giveaway loads here; other https
/// links open in the phone's browser; every other scheme is dropped; no file
/// or content access, no mixed content, no geolocation, all permission
/// requests denied, TLS errors cancel, web debugging only in debug builds.
class GiveawayScreen extends StatefulWidget {
  const GiveawayScreen({super.key, this.api});

  final GiveawayApi? api;

  @override
  State<GiveawayScreen> createState() => _GiveawayScreenState();
}

enum _Phase { loading, ready, error }

class _GiveawayScreenState extends State<GiveawayScreen> {
  static const _loadTimeout = Duration(seconds: 20);

  late final GiveawayApi _api = widget.api ?? GiveawayApi.instance;
  late final WebViewController _web = _buildController();

  _Phase _phase = _Phase.loading;
  Timer? _timeout;
  bool _submitting = false;
  bool _sharing = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _timeout?.cancel();
    super.dispose();
  }

  WebViewController _buildController() {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.bg)
      ..addJavaScriptChannel(
        GiveawayBridge.channelName,
        onMessageReceived: (m) => _onMessage(m.message),
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: _onNavigationRequest,
          onPageFinished: (_) {
            // The page normally says `ready` itself; this is the fallback
            // for a page that loaded but never did.
            Future<void>.delayed(const Duration(seconds: 4), () {
              if (mounted && _phase == _Phase.loading) _setPhase(_Phase.ready);
            });
          },
          onWebResourceError: (error) {
            if (error.isForMainFrame ?? true) _setPhase(_Phase.error);
          },
          onHttpError: (error) {
            final uri = error.request?.uri;
            final status = error.response?.statusCode ?? 0;
            if (uri != null && status >= 400 && _isPageDocument(uri)) _setPhase(_Phase.error);
          },
          onSslAuthError: (error) => error.cancel(),
        ),
      );

    final platform = controller.platform;
    if (platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(kDebugMode);
      platform
        ..setAllowFileAccess(false)
        ..setAllowContentAccess(false)
        ..setMixedContentMode(MixedContentMode.neverAllow)
        ..setGeolocationEnabled(false)
        ..setMediaPlaybackRequiresUserGesture(true)
        ..setOnPlatformPermissionRequest((request) => request.deny());
    }
    return controller;
  }

  bool _isPageDocument(Uri uri) {
    final path = uri.path;
    return GiveawayWebPolicy.isCampaignPage(uri) && !path.contains('.', path.lastIndexOf('/'));
  }

  Future<void> _load() async {
    _setPhase(_Phase.loading);
    _timeout?.cancel();
    _timeout = Timer(_loadTimeout, () {
      if (mounted && _phase == _Phase.loading) _setPhase(_Phase.error);
    });
    String? code;
    try {
      code = await _api.createWebCode();
    } catch (_) {
      code = null; // the page still opens, in its signed-out view
    }
    if (!mounted) return;
    await _web.loadRequest(GiveawayConfig.pageUri(code: code));
  }

  void _setPhase(_Phase phase) {
    if (!mounted || _phase == phase) return;
    if (phase != _Phase.loading) _timeout?.cancel();
    setState(() => _phase = phase);
  }

  FutureOr<NavigationDecision> _onNavigationRequest(NavigationRequest request) {
    final uri = Uri.tryParse(request.url);
    if (uri == null) return NavigationDecision.prevent;
    switch (GiveawayWebPolicy.decide(uri)) {
      case WebNavAction.allow:
        return NavigationDecision.navigate;
      case WebNavAction.openExternally:
        // Only a tap in the page itself leaves the app; a frame or script
        // can't push the user out.
        if (request.isMainFrame) {
          launchUrl(uri, mode: LaunchMode.externalApplication).ignore();
        }
        return NavigationDecision.prevent;
      case WebNavAction.block:
        return NavigationDecision.prevent;
    }
  }

  // ── Bridge ──────────────────────────────────────────────────────────────

  Future<void> _onMessage(String raw) async {
    // Only Aorbo's own campaign page may ask for anything.
    final current = await _web.currentUrl();
    final currentUri = current == null ? null : Uri.tryParse(current);
    if (currentUri == null || !GiveawayWebPolicy.isCampaignPage(currentUri)) return;

    final request = GiveawayBridge.parse(raw);
    if (request == null || !mounted) return;

    switch (request.type) {
      case BridgeRequestType.ready:
        _setPhase(_Phase.ready);
      case BridgeRequestType.openRules:
        Get.toNamed('/giveaway-rules', arguments: {'round': request.round});
      case BridgeRequestType.share:
        await _share(request);
      case BridgeRequestType.submitEntry:
        await _submitEntry(request);
      case BridgeRequestType.close:
        Get.back();
      case BridgeRequestType.refreshSession:
        _refreshSession();
    }
  }

  // The page's web session ended: load it again with a fresh one-time code.
  // At most once every 10 s and 5 times per visit, so a page that keeps
  // failing to sign in can never loop.
  DateTime? _lastSessionRefresh;
  int _sessionRefreshes = 0;

  void _refreshSession() {
    final now = DateTime.now();
    if (_sessionRefreshes >= 5) return;
    if (_lastSessionRefresh != null && now.difference(_lastSessionRefresh!) < const Duration(seconds: 10)) return;
    _lastSessionRefresh = now;
    _sessionRefreshes += 1;
    _load();
  }

  Future<void> _reply(Map<String, Object?> reply) async {
    if (!mounted) return;
    try {
      await _web.runJavaScript(GiveawayBridge.replyScript(reply));
    } catch (_) {
      // Page navigated away or was closed — nothing to tell.
    }
  }

  Future<void> _submitEntry(BridgeRequest request) async {
    if (request.invalid || request.entry == null) {
      await _reply({
        'replyTo': request.id,
        'type': 'entryResult',
        'ok': false,
        'error': {
          'code': 'invalid_request',
          'message': "Some answers couldn't be sent. Please check them and try again.",
        },
      });
      return;
    }
    if (_submitting) {
      await _reply({
        'replyTo': request.id,
        'type': 'entryResult',
        'ok': false,
        'error': {'code': 'busy', 'message': 'Your entry is already being sent.'},
      });
      return;
    }
    _submitting = true;
    try {
      final result = await _api.submitEntry(requestId: request.id, entry: request.entry!);
      await _reply({
        'replyTo': request.id,
        'type': 'entryResult',
        'ok': result.ok,
        if (result.ok) 'data': result.data,
        if (!result.ok) 'error': {'code': result.errorCode, 'message': result.errorMessage},
      });
    } catch (_) {
      await _reply({
        'replyTo': request.id,
        'type': 'entryResult',
        'ok': false,
        'error': {
          'code': 'network',
          'message': "Couldn't send your entry. Check your connection and try again.",
        },
      });
    } finally {
      _submitting = false;
    }
  }

  Future<void> _share(BridgeRequest request) async {
    if (_sharing) return;
    _sharing = true;
    try {
      final code = await _api.myReferralCode();
      if (code == null) throw StateError('no code');
      await Share.share(_shareMessage(code), subject: 'Aorbo Trek Giveaway');
      await _reply({'replyTo': request.id, 'type': 'shareResult', 'ok': true});
    } catch (_) {
      if (mounted) {
        CustomSnackBar.show(context, message: "Couldn't load your invite link. Please try again.");
      }
      await _reply({'replyTo': request.id, 'type': 'shareResult', 'ok': false});
    } finally {
      _sharing = false;
    }
  }

  static String _shareMessage(String code) =>
      'Join me on Aorbo Treks — sign up with my link and you could win a trek '
      'worth up to ₹10,000. Free to enter.\n'
      '${GiveawayConfig.referralLink(code)}\n\n'
      "Never trekked? You don't need a group or experience — verified trek "
      'organisers and fellow travellers make it easy.';

  // ── UI ──────────────────────────────────────────────────────────────────

  Future<void> _handleBack() async {
    if (_phase == _Phase.ready && await _web.canGoBack()) {
      await _web.goBack();
      return;
    }
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleBack();
      },
      child: Scaffold(
        backgroundColor: AppColors.bg,
        appBar: _appBar(),
        body: SafeArea(
          top: false,
          child: Stack(
            children: [
              // Kept mounted (and loading) behind the native states.
              Positioned.fill(child: WebViewWidget(controller: _web)),
              if (_phase == _Phase.loading) Positioned.fill(child: _loadingState()),
              if (_phase == _Phase.error) Positioned.fill(child: _errorState()),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _appBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      titleSpacing: 4.w,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.divider),
      ),
      title: Row(
        children: [
          GestureDetector(
            onTap: _handleBack,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 1.h),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.ink),
            ),
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Aorbo Trek Giveaway', style: AppType.style(FontSize.s13, w: FontWeight.w700)),
                Text(
                  'Win a trek worth up to ₹10,000',
                  style: AppType.style(FontSize.s9, color: AppColors.inkMid),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: () => Get.toNamed('/giveaway-rules'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.forest,
              padding: EdgeInsets.symmetric(horizontal: 2.w),
            ),
            icon: const Icon(Icons.description_outlined, size: 18),
            label: Text(
              'Rules',
              style: AppType.style(FontSize.s10, w: FontWeight.w600, color: AppColors.forest),
            ),
          ),
        ],
      ),
    );
  }

  Widget _loadingState() {
    return ColoredBox(
      color: AppColors.bg,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2.6, color: AppColors.forest),
            ),
            SizedBox(height: 2.h),
            Text(
              'Opening the giveaway…',
              style: AppType.style(FontSize.s10, color: AppColors.inkMid),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorState() {
    return ColoredBox(
      color: AppColors.bg,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(8.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(3.5.w),
                decoration: const BoxDecoration(color: AppColors.forestSoft, shape: BoxShape.circle),
                child: const Icon(Icons.cloud_off_rounded, color: AppColors.forest, size: 28),
              ),
              SizedBox(height: 2.h),
              Text(
                "Couldn't open the giveaway",
                textAlign: TextAlign.center,
                style: AppType.style(FontSize.s12, w: FontWeight.w700),
              ),
              SizedBox(height: 0.8.h),
              Text(
                'Check your internet connection and try again. The rules are always available from the Rules button above.',
                textAlign: TextAlign.center,
                style: AppType.style(FontSize.s9, color: AppColors.inkMid, height: 1.5),
              ),
              SizedBox(height: 2.4.h),
              OutlinedButton(
                onPressed: _load,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.forest,
                  side: const BorderSide(color: AppColors.forest),
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.2.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                ),
                child: Text(
                  'Try again',
                  style: AppType.style(FontSize.s10, w: FontWeight.w600, color: AppColors.forest),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
