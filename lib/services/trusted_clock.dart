import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:ntp/ntp.dart';

/// "Now" for the date pickers, corrected by an NTP lookup when one works.
///
/// Scan D3: the Home / Search date pickers awaited `NTP.now()` with no
/// timeout. On networks that drop UDP/123 replies (office/hotel/campus Wi-Fi,
/// some VPNs, flaky mobile data) that future never completed: tapping "Date"
/// did nothing at all, and every attempt leaked a datagram socket.
///
/// - One lookup per app start, shared by every screen ([sync]); it always
///   finishes within [timeout] + 1 s and never throws.
/// - [now] never waits: device time, corrected by the NTP offset once known.
/// - A failed lookup is not retried for [retryAfter].
class TrustedClock {
  TrustedClock({
    Future<Duration> Function(Duration timeout)? fetchOffset,
    this.timeout = const Duration(seconds: 2),
    this.retryAfter = const Duration(minutes: 5),
  }) : _fetchOffset = fetchOffset ?? _ntpOffset;

  /// Replaceable in tests.
  static TrustedClock instance = TrustedClock();

  final Duration timeout;
  final Duration retryAfter;
  final Future<Duration> Function(Duration timeout) _fetchOffset;

  Duration? _offset;
  Future<DateTime>? _inFlight;
  DateTime? _lastFailure;

  /// The NTP offset is known.
  bool get isSynced => _offset != null;

  /// Device time, corrected by the NTP offset when known. Never waits.
  DateTime now() {
    final offset = _offset;
    return offset == null ? DateTime.now() : DateTime.now().add(offset);
  }

  /// Runs the (single, shared) lookup if it hasn't succeeded yet and returns
  /// the best "now". Completes within [timeout] + 1 s; device time on failure.
  Future<DateTime> sync() {
    if (_offset != null) return Future.value(now());
    final failedAt = _lastFailure;
    if (failedAt != null && DateTime.now().difference(failedAt) < retryAfter) {
      return Future.value(now());
    }
    return _inFlight ??= _run();
  }

  Future<DateTime> _run() async {
    try {
      // The outer bound also covers the DNS lookup, which the ntp package's
      // own timeout does not.
      _offset = await _fetchOffset(timeout)
          .timeout(timeout + const Duration(seconds: 1));
    } catch (e) {
      _lastFailure = DateTime.now();
      if (kDebugMode) debugPrint('TrustedClock: NTP unavailable ($e)');
    } finally {
      _inFlight = null;
    }
    return now();
  }

  // With a timeout the ntp package closes its socket when no reply comes.
  static Future<Duration> _ntpOffset(Duration timeout) async =>
      Duration(milliseconds: await NTP.getNtpOffset(timeout: timeout));
}
