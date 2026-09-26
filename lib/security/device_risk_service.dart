import 'dart:async';
import 'dart:io' show Platform;

import 'package:arobo_app/repository/network_url.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Runtime tamper detection (RASP) — DeviceSecurityChannel.kt does the checks.
///
/// Flags: root | hook | debugger | emulator | tamper | untrusted_installer.
///
/// What happens with them:
///  - sent as `X-Device-Risk` on Play-Integrity-protected requests; the
///    backend blocks hook/debugger/tamper and records the rest
///  - reported once per app run to POST /device-security/report (attacker
///    tracker), except `untrusted_installer` alone (our own test builds)
///  - [mustBlock] → main.dart shows the "device not secure" screen
///    (remote-switchable, SecurityConfig.raspBlockEnabled)
///
/// A skilled attacker can hide from in-app checks; Play Integrity on the
/// server remains the authority. This layer adds Frida/Xposed/debugger
/// detection that Play does not report, and raises the cost of an attack.
class DeviceRiskService {
  DeviceRiskService._();
  static final DeviceRiskService instance = DeviceRiskService._();

  static const MethodChannel _channel = MethodChannel('com.aorbotreks.app/device_security');
  static const String riskHeader = 'X-Device-Risk';
  static const Duration _rescanAfter = Duration(seconds: 60);

  /// Flags that mean someone is actively instrumenting / has modified the app.
  static const Set<String> blockingFlags = {'hook', 'debugger', 'tamper'};
  static const Set<String> _reportableFlags = {'root', 'hook', 'debugger', 'emulator', 'tamper'};

  List<String> _flags = const [];
  DateTime? _scannedAt;
  Future<List<String>>? _inFlight;
  bool _reported = false;

  List<String> get flags => _flags;
  bool get mustBlock => _flags.any(blockingFlags.contains);

  bool get _isSupported => !kIsWeb && Platform.isAndroid;

  /// Scan now (shared if one is already running).
  Future<List<String>> scan() {
    if (!_isSupported) return Future.value(const []);
    return _inFlight ??= _doScan().whenComplete(() => _inFlight = null);
  }

  /// Latest flags, re-scanning if the last scan is older than a minute —
  /// a hooking framework can be attached after launch.
  Future<List<String>> current() async {
    final at = _scannedAt;
    if (at == null || DateTime.now().difference(at) > _rescanAfter) {
      await scan().timeout(const Duration(seconds: 3), onTimeout: () => _flags);
    }
    return _flags;
  }

  Future<List<String>> _doScan() async {
    try {
      final res = await _channel.invokeMapMethod<String, dynamic>('riskScan', {'release': kReleaseMode});
      final raw = (res?['flags'] as List?)?.map((e) => e.toString()).toList() ?? const <String>[];
      _flags = List.unmodifiable(raw);
      _scannedAt = DateTime.now();
      _maybeReport();
    } catch (e) {
      debugPrint('DeviceRiskService.scan failed: $e');
    }
    return _flags;
  }

  void _maybeReport() {
    if (_reported) return;
    final reportable = _flags.where(_reportableFlags.contains).toList();
    if (reportable.isEmpty) return;
    _reported = true;
    () async {
      try {
        await Dio(BaseOptions(
          baseUrl: NetworkUrl.baseUrl,
          connectTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 8),
          headers: {'Content-Type': 'application/json'},
        )).post('device-security/report', data: {'event': 'rasp_detected', 'flags': reportable});
      } catch (_) {}
    }();
  }

  @visibleForTesting
  void setFlagsForTest(List<String> flags) {
    _flags = List.unmodifiable(flags);
    _scannedAt = DateTime.now();
  }
}
