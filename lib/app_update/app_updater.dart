import 'package:flutter/foundation.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app_update_policy.dart';

/// How an "Update now" tap ended.
enum AppUpdateOutcome {
  /// Google Play's in-app update flow ran (on success the app restarts).
  inAppUpdate,

  /// The person closed Play's update screen — stay where we are.
  declined,

  /// The store page was opened.
  openedStore,

  /// Nothing could be opened.
  failed,
}

/// Starts an app update. Behind an interface so widget tests never reach
/// the Play / url_launcher plugins.
abstract class AppUpdater {
  /// Never throws.
  Future<AppUpdateOutcome> update({String? storeUrl});
}

/// Android: Google Play In-App Updates, IMMEDIATE flow, when Play offers it.
/// Anything else — no update visible to Play yet, not installed from Play,
/// Play unavailable, an error, or not Android — opens the store page
/// ([storeUrl] if it is a plain https link, else the default listing).
class PlayAppUpdater implements AppUpdater {
  PlayAppUpdater({
    Future<AppUpdateInfo> Function()? checkForUpdate,
    Future<AppUpdateResult> Function()? performImmediateUpdate,
    Future<bool> Function(Uri uri)? openUrl,
    bool? useInAppUpdate,
  }) : _checkForUpdate = checkForUpdate ?? InAppUpdate.checkForUpdate,
       _performImmediateUpdate =
           performImmediateUpdate ?? InAppUpdate.performImmediateUpdate,
       _openUrl = openUrl ?? _launchExternal,
       _useInAppUpdate =
           useInAppUpdate ??
           (!kIsWeb && defaultTargetPlatform == TargetPlatform.android);

  final Future<AppUpdateInfo> Function() _checkForUpdate;
  final Future<AppUpdateResult> Function() _performImmediateUpdate;
  final Future<bool> Function(Uri uri) _openUrl;
  final bool _useInAppUpdate;

  static Future<bool> _launchExternal(Uri uri) =>
      launchUrl(uri, mode: LaunchMode.externalApplication);

  @override
  Future<AppUpdateOutcome> update({String? storeUrl}) async {
    if (_useInAppUpdate) {
      try {
        final info = await _checkForUpdate();
        final available =
            info.updateAvailability == UpdateAvailability.updateAvailable ||
            // An immediate update the person left half-way: resume it.
            info.updateAvailability ==
                UpdateAvailability.developerTriggeredUpdateInProgress;
        if (available && info.immediateUpdateAllowed) {
          final result = await _performImmediateUpdate();
          switch (result) {
            case AppUpdateResult.success:
              return AppUpdateOutcome.inAppUpdate;
            case AppUpdateResult.userDeniedUpdate:
              return AppUpdateOutcome.declined;
            case AppUpdateResult.inAppUpdateFailed:
              break; // fall back to the store page
          }
        }
      } catch (e) {
        // Not installed from Play, Play missing/outdated, no activity, ...
        debugPrint('In-app update unavailable, opening the store: $e');
      }
    }
    return _openStore(storeUrl);
  }

  Future<AppUpdateOutcome> _openStore(String? storeUrl) async {
    final url = safeStoreUrl(storeUrl) ?? defaultStoreUrl();
    try {
      final opened = await _openUrl(Uri.parse(url));
      return opened ? AppUpdateOutcome.openedStore : AppUpdateOutcome.failed;
    } catch (e) {
      debugPrint('Could not open the store: $e');
      return AppUpdateOutcome.failed;
    }
  }
}
