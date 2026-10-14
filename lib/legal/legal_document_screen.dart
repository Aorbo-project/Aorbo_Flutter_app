import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

import '../theme/app_tokens.dart';
import '../theme/app_typography.dart';
import '../utils/screen_constants.dart';
import 'legal_web_policy.dart';

/// A legal document (Terms, Privacy Policy, User Agreement, Refund Policy)
/// read inside the app.
///
/// It shows the website's CURRENT page — the one source of truth, so the app
/// can never show an outdated copy — under the app's own header, with the
/// site's menu, footer and cookie banner hidden (kLegalHideSiteChromeScript).
/// Locked down like the giveaway view: only Aorbo's site loads here, other
/// links open outside the app, no file / content / location access, TLS
/// errors cancel, web debugging only in debug builds.
class LegalDocumentScreen extends StatefulWidget {
  const LegalDocumentScreen({super.key, required this.url, required this.title});

  final String url;
  final String title;

  @override
  State<LegalDocumentScreen> createState() => _LegalDocumentScreenState();
}

enum _Phase { loading, ready, error }

class _LegalDocumentScreenState extends State<LegalDocumentScreen> {
  static const _loadTimeout = Duration(seconds: 20);

  late final Uri _home = Uri.parse(widget.url);
  late final WebViewController _web = _buildController();

  _Phase _phase = _Phase.loading;
  Timer? _timeout;

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
      ..setJavaScriptMode(JavaScriptMode.unrestricted) // the site is a React app
      ..setBackgroundColor(AppColors.bg)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: _onNavigationRequest,
          onProgress: (_) => _hideSiteChrome(),
          onPageFinished: (_) async {
            await _hideSiteChrome();
            // A moment for the page's text to render before it is shown.
            Future<void>.delayed(const Duration(milliseconds: 300), () {
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

  /// The page itself, not one of its scripts / images / fonts.
  bool _isPageDocument(Uri uri) {
    final path = uri.path;
    return uri.host == _home.host && !path.contains('.', path.lastIndexOf('/'));
  }

  Future<void> _hideSiteChrome() async {
    try {
      await _web.runJavaScript(kLegalHideSiteChromeScript);
    } catch (_) {
      // Too early in the load (no document yet) — the next tick runs it.
    }
  }

  Future<void> _load() async {
    _setPhase(_Phase.loading);
    _timeout?.cancel();
    _timeout = Timer(_loadTimeout, () {
      if (mounted && _phase == _Phase.loading) _setPhase(_Phase.error);
    });
    await _web.loadRequest(_home);
  }

  void _setPhase(_Phase phase) {
    if (!mounted || _phase == phase) return;
    if (phase != _Phase.loading) _timeout?.cancel();
    setState(() => _phase = phase);
  }

  FutureOr<NavigationDecision> _onNavigationRequest(NavigationRequest request) {
    final uri = Uri.tryParse(request.url);
    if (uri == null) return NavigationDecision.prevent;
    switch (decideLegalNavigation(uri, home: _home)) {
      case LegalNavAction.allow:
        return NavigationDecision.navigate;
      case LegalNavAction.openExternally:
        // Only a tap in the page itself leaves the app; a frame or script
        // can't push the user out.
        if (request.isMainFrame) {
          launchUrl(uri, mode: LaunchMode.externalApplication).ignore();
        }
        return NavigationDecision.prevent;
      case LegalNavAction.block:
        return NavigationDecision.prevent;
    }
  }

  Future<void> _openInBrowser() async {
    try {
      await launchUrl(_home, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

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
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              widget.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppType.style(FontSize.s13, w: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _loadingState() {
    return const ColoredBox(
      color: AppColors.bg,
      child: Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(strokeWidth: 2.6, color: AppColors.forest),
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
                "Couldn't open ${widget.title}",
                textAlign: TextAlign.center,
                style: AppType.style(FontSize.s12, w: FontWeight.w700),
              ),
              SizedBox(height: 0.8.h),
              Text(
                'Check your internet connection and try again.',
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
              TextButton(
                onPressed: _openInBrowser,
                child: Text(
                  'Open in browser',
                  style: AppType.style(FontSize.s9, w: FontWeight.w600, color: AppColors.inkMid),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
