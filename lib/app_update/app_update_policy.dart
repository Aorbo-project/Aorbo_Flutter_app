import 'dart:convert';

import 'package:flutter/foundation.dart';

/// Play Store listing — used when the server sends no (or an unusable)
/// store_url. applicationId is com.aorbotreks.app.
const String kPlayStoreUrl =
    'https://play.google.com/store/apps/details?id=com.aorbotreks.app';
const String kAppStoreUrl = 'https://apps.apple.com/us/app/aorbo/id6747623495';

/// The store page for this platform.
String defaultStoreUrl() =>
    defaultTargetPlatform == TargetPlatform.iOS ? kAppStoreUrl : kPlayStoreUrl;

/// [raw] when it is a plain https URL, otherwise null — a store link from the
/// network is only ever opened as a web/store page, never as another scheme.
String? safeStoreUrl(Object? raw) {
  if (raw is! String) return null;
  final uri = Uri.tryParse(raw.trim());
  if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) return null;
  return uri.toString();
}

/// `code` the server sends with a "this build is too old" refusal.
const String kAppUpdateRequiredCode = 'APP_UPDATE_REQUIRED';

/// True when a response means "this build must be updated before it can be
/// used": HTTP 426 (the version gate), or 403 with code APP_UPDATE_REQUIRED
/// (the Play Integrity floor). [body] is the decoded JSON (a Map) or the raw
/// string.
bool isAppUpdateRequired(int? status, dynamic body) {
  if (status == 426) return true;
  if (status != 403) return false;
  return _asMap(body)?['code'] == kAppUpdateRequiredCode;
}

/// What a blocking response asks the app to show.
@immutable
class AppUpdateBlock {
  const AppUpdateBlock({this.message, this.storeUrl});

  /// From a 426 / 403 APP_UPDATE_REQUIRED body. Never throws.
  factory AppUpdateBlock.fromBody(dynamic body) {
    final map = _asMap(body);
    return AppUpdateBlock(
      message: _string(map?['message']),
      storeUrl: safeStoreUrl(map?['store_url']),
    );
  }

  final String? message;
  final String? storeUrl;
}

/// GET version/check `data`, parsed tolerantly: a missing or wrongly typed
/// field becomes null / false, and parsing never throws.
@immutable
class AppUpdatePolicy {
  const AppUpdatePolicy({
    this.currentVersion,
    this.currentBuild,
    this.latestVersion,
    this.latestBuild,
    this.minSupportedVersion,
    this.minSupportedBuild,
    this.updateAvailable = false,
    this.updateAnnounced = false,
    this.updateRequired = false,
    this.requiredFrom,
    this.updateMessage,
    this.releaseNotes,
    this.storeUrl,
  });

  /// From the `data` object.
  factory AppUpdatePolicy.fromJson(Map<dynamic, dynamic> json) {
    return AppUpdatePolicy(
      currentVersion: _string(json['current_version']),
      currentBuild: _int(json['current_build']),
      latestVersion: _string(json['latest_version']),
      latestBuild: _int(json['latest_build']),
      minSupportedVersion: _string(json['min_supported_version']),
      minSupportedBuild: _int(json['min_supported_build']),
      updateAvailable: json['update_available'] == true,
      updateAnnounced: json['update_announced'] == true,
      updateRequired: json['update_required'] == true,
      requiredFrom: _date(json['required_from']),
      updateMessage: _string(json['update_message']),
      releaseNotes: _string(json['release_notes']),
      storeUrl: safeStoreUrl(json['store_url']),
    );
  }

  /// From the whole response (`{ success, data: {...} }`), or null when it
  /// isn't a usable answer — the caller then fails open.
  static AppUpdatePolicy? fromResponse(dynamic body) {
    final map = _asMap(body);
    if (map == null || map['success'] == false) return null;
    final data = map['data'];
    if (data is! Map) return null;
    return AppUpdatePolicy.fromJson(data);
  }

  final String? currentVersion;
  final int? currentBuild;
  final String? latestVersion;
  final int? latestBuild;
  final String? minSupportedVersion;
  final int? minSupportedBuild;

  /// A newer build exists (optional tier).
  final bool updateAvailable;

  /// Below the minimum, but [requiredFrom] is still in the future.
  final bool updateAnnounced;

  /// Below the minimum and enforced now — hard block.
  final bool updateRequired;

  /// When the minimum starts being enforced (UTC), if announced.
  final DateTime? requiredFrom;
  final String? updateMessage;
  final String? releaseNotes;

  /// https store link, or null (use [defaultStoreUrl]).
  final String? storeUrl;

  /// What an "update available" dismissal is remembered against: the latest
  /// build, else the latest version name; null when neither is known.
  String? get dismissKey {
    if (latestBuild != null) return 'b$latestBuild';
    if (latestVersion != null) return 'v$latestVersion';
    return null;
  }
}

Map<dynamic, dynamic>? _asMap(dynamic body) {
  if (body is Map) return body;
  if (body is String && body.isNotEmpty) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map) return decoded;
    } catch (_) {}
  }
  return null;
}

String? _string(dynamic v) {
  if (v is! String) return null;
  final s = v.trim();
  return s.isEmpty ? null : s;
}

int? _int(dynamic v) {
  if (v is int) return v;
  if (v is double && v.isFinite && v == v.truncateToDouble()) return v.toInt();
  if (v is String) return int.tryParse(v.trim());
  return null;
}

/// A UTC instant. A timestamp without a zone is read as UTC (the backend's
/// standard), never as the phone's local time.
DateTime? _date(dynamic v) {
  if (v is! String) return null;
  final s = v.trim();
  final parsed = DateTime.tryParse(s);
  if (parsed == null) return null;
  if (RegExp(r'(Z|[+-]\d{2}:?\d{2})$').hasMatch(s)) return parsed.toUtc();
  return DateTime.utc(
    parsed.year,
    parsed.month,
    parsed.day,
    parsed.hour,
    parsed.minute,
    parsed.second,
    parsed.millisecond,
  );
}
