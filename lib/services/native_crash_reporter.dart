import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'crash_report_service.dart';

/// An Android-level (Java / Kotlin) crash, recorded by NativeCrashRecorder.kt
/// when it happened and sent here on the next launch (16 Oct 2026). Flutter
/// errors already reached Aorbo's crash reports; crashes below Flutter (the
/// 1.0.0+27 startup crash) reached only Firebase.
class NativeCrash implements Exception {
  NativeCrash(this.message, [this.rootCause]);
  final String message;
  final String? rootCause;

  @override
  String toString() =>
      'Android crash: $message${rootCause != null && rootCause != message ? ' (cause: $rootCause)' : ''}';
}

class NativeCrashReporter {
  NativeCrashReporter._();

  static const MethodChannel _channel = MethodChannel('com.aorbotreks.app/native_crash');

  /// The saved crash as (error, stack), or null when there is none / it is unreadable.
  @visibleForTesting
  static (NativeCrash, StackTrace)? parse(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final m = jsonDecode(raw);
      if (m is! Map || m['message'] is! String) return null;
      final cause = m['root_cause'] is String ? m['root_cause'] as String : null;
      final stack = m['stack'] is String ? m['stack'] as String : '';
      return (NativeCrash(m['message'] as String, cause), StackTrace.fromString(stack));
    } catch (_) {
      return null;
    }
  }

  /// Takes the saved crash (the file is removed either way) and reports it.
  /// Android only; never throws; fire-and-forget from start-up.
  static Future<void> sendPending({
    Future<String?> Function()? take,
    Future<void> Function(Object error, StackTrace stack)? send,
  }) async {
    if (take == null && (kIsWeb || !Platform.isAndroid)) return;
    try {
      final raw = await (take ?? () => _channel.invokeMethod<String>('takePendingCrash'))();
      final crash = parse(raw);
      if (crash == null) return;
      await (send ??
          (e, s) => CrashReportService.instance.report(e, s, fatal: true, screenName: 'android (native)'))(crash.$1, crash.$2);
    } catch (_) {
      // best effort only
    }
  }
}
