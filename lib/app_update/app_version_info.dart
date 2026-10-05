import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// This build's version, as the backend's force-update gate reads it.
///
/// Enforcement is by build number (Android versionCode = pubspec `+N`):
/// versionName stayed `1.0.0` for every early build, so names alone can't
/// tell builds apart. Loaded once at start-up (main.dart `_bootstrap`, before
/// the API client is built); until then [current] is null and no version
/// headers are sent.
@immutable
class AppVersionInfo {
  const AppVersionInfo({
    required this.version,
    required this.build,
    required this.platform,
  });

  /// From raw PackageInfo values. Both are cleaned so they are always safe
  /// to put in an HTTP header: the name keeps `[0-9A-Za-z.+-]`, the build
  /// keeps digits only.
  factory AppVersionInfo.from({
    required String version,
    required String buildNumber,
    String? platform,
  }) {
    return AppVersionInfo(
      version: version.replaceAll(RegExp(r'[^0-9A-Za-z.+\-]'), ''),
      build: buildNumber.replaceAll(RegExp(r'[^0-9]'), ''),
      platform: platform ?? currentPlatformName(),
    );
  }

  static const String versionHeader = 'X-App-Version';
  static const String buildHeader = 'X-App-Build';
  static const String platformHeader = 'X-App-Platform';

  /// versionName, e.g. `1.1.0`. May be empty.
  final String version;

  /// versionCode, digits only, e.g. `24`. Empty when unknown.
  final String build;

  /// `android` or `ios`.
  final String platform;

  int? get buildNumber => int.tryParse(build);

  /// The three version headers (empty values left out).
  Map<String, String> get headers => {
    if (version.isNotEmpty) versionHeader: version,
    if (build.isNotEmpty) buildHeader: build,
    platformHeader: platform,
  };

  static AppVersionInfo? _current;

  /// This build's info, or null before [load] has finished (or if it failed).
  static AppVersionInfo? get current => _current;

  /// Headers for one-off clients; empty before [load].
  static Map<String, String> get currentHeaders =>
      _current?.headers ?? const {};

  @visibleForTesting
  static set current(AppVersionInfo? value) => _current = value;

  /// Reads PackageInfo once. Never throws: on failure [current] stays null.
  static Future<AppVersionInfo?> load({
    Future<PackageInfo> Function()? source,
  }) async {
    if (_current != null) return _current;
    try {
      final info = await (source ?? PackageInfo.fromPlatform)();
      _current = AppVersionInfo.from(
        version: info.version,
        buildNumber: info.buildNumber,
      );
    } catch (e) {
      debugPrint('AppVersionInfo.load failed: $e');
    }
    return _current;
  }

  /// `ios` on iOS, `android` everywhere else (the app ships on Android only).
  static String currentPlatformName() =>
      defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android';

  @override
  String toString() => 'AppVersionInfo($version+$build, $platform)';
}

/// Adds `X-App-Version`, `X-App-Build` and `X-App-Platform` to every request.
/// UX hints only — the server never trusts them for security. Sends nothing
/// while the version isn't known yet, and never fails a request.
class AppVersionHeadersInterceptor extends Interceptor {
  AppVersionHeadersInterceptor({AppVersionInfo? Function()? info})
    : _info = info ?? (() => AppVersionInfo.current);

  final AppVersionInfo? Function() _info;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    try {
      final info = _info();
      if (info != null) options.headers.addAll(info.headers);
    } catch (_) {
      // A version hint must never stop a request.
    }
    handler.next(options);
  }
}
