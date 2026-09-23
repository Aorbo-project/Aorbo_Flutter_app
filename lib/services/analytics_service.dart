import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:arobo_app/repository/network_url.dart';
import 'package:arobo_app/repository/repository.dart';

/// Fire-and-forget behaviour tracking for the vendor Performance Insights
/// conversion funnel (trek views -> booking started -> booking paid).
///
/// Nothing here ever throws, blocks a screen, or shows UI. Events are buffered
/// and flushed in the background. Anonymous is fine — the backend fills
/// customer_id when a token is present.
class AnalyticsService {
  AnalyticsService._();
  static final AnalyticsService instance = AnalyticsService._();

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: NetworkUrl.baseUrl, // .../api/v1/
      connectTimeout: const Duration(seconds: 8),
      sendTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 8),
      headers: {'Accept': '*/*', 'Content-Type': 'application/json'},
    ),
  );

  late final String _sessionId = _makeSessionId();
  final List<Map<String, dynamic>> _buffer = [];
  Timer? _flushTimer;
  bool _sending = false;

  static const int _flushAt = 8;
  static const Duration _flushEvery = Duration(seconds: 12);

  String _makeSessionId() {
    final r = Random();
    final rand = List.generate(8, (_) => r.nextInt(16).toRadixString(16)).join();
    return '${DateTime.now().microsecondsSinceEpoch.toRadixString(16)}$rand';
  }

  void _enqueue(String type, {int? trekId, int? batchId, String? source, Map<String, dynamic>? meta}) {
    try {
      _buffer.add({
        'type': type,
        if (trekId != null && trekId > 0) 'trek_id': trekId,
        if (batchId != null && batchId > 0) 'batch_id': batchId,
        if (source != null) 'source': source,
        'session_id': _sessionId,
        if (meta != null) 'meta': meta,
      });
      if (_buffer.length >= _flushAt) {
        flush();
      } else {
        _flushTimer ??= Timer(_flushEvery, flush);
      }
    } catch (_) {/* never throw */}
  }

  // ---- public event helpers ----

  void logTrekView(int? trekId, {String? source}) =>
      _enqueue('trek_view', trekId: trekId, source: source);

  void logTrekDetailView(int? trekId, {String? source}) =>
      _enqueue('trek_detail_view', trekId: trekId, source: source);

  void logBookingStarted(int? trekId, {int? batchId, String? source}) =>
      _enqueue('booking_started', trekId: trekId, batchId: batchId, source: source);

  void logBookingPaid(int? trekId, {int? batchId}) =>
      _enqueue('booking_paid', trekId: trekId, batchId: batchId);

  /// Send whatever is buffered. Safe to call any time (app pause, etc.).
  Future<void> flush() async {
    _flushTimer?.cancel();
    _flushTimer = null;
    if (_sending || _buffer.isEmpty) return;
    _sending = true;
    final batch = List<Map<String, dynamic>>.from(_buffer);
    _buffer.clear();
    try {
      final token = Repository.token;
      await _dio.post(
        'analytics/events',
        data: {'events': batch},
        options: Options(
          headers: token.isNotEmpty ? {'Authorization': 'Bearer $token'} : null,
        ),
      );
    } catch (e) {
      // Drop on failure — analytics is best-effort, never retried aggressively.
      if (kDebugMode) debugPrint('AnalyticsService flush failed: $e');
    } finally {
      _sending = false;
    }
  }

  /// Test-only: cancels any pending flush timer and clears buffered events.
  ///
  /// Root cause of the long-standing "A Timer is still pending" failure in
  /// test/responsive/screens_responsive_test.dart's TrekDetailsScreen case
  /// (misdiagnosed for weeks as an unrelated flake, 2026-09-23): this is a
  /// process-wide singleton, so its _flushTimer (created by any screen whose
  /// initState logs a view event — see logTrekDetailView) outlives any single
  /// widget test's pumpWidget/dispose cycle, exactly as intended for a real
  /// running app. flutter_test's !timersPending invariant has no way to know
  /// that's deliberate, so it fails whichever test happens to be the one that
  /// creates the timer. Call this from a test harness's tearDown/setUp —
  /// screen_responsive_harness.dart's teardownScreenTestEnv already resets
  /// other shared singletons (Repository's dio interceptors, Get.reset()) the
  /// same way.
  @visibleForTesting
  void resetForTest() {
    _flushTimer?.cancel();
    _flushTimer = null;
    _buffer.clear();
    _sending = false;
  }
}
