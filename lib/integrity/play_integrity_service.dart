import 'dart:async';
import 'dart:io' show Platform;

import 'package:arobo_app/firebase_options.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Outcome of asking the device for an integrity token: exactly one of
/// [token] / [error] is set. [error] is a stable code (e.g.
/// PLAY_SERVICES_NOT_FOUND) that is forwarded to the backend.
class IntegrityTokenResult {
  final String? token;
  final String? error;
  const IntegrityTokenResult.token(String this.token) : error = null;
  const IntegrityTokenResult.error(String this.error) : token = null;
}

/// Google Play Integrity — standard requests, via PlayIntegrityChannel.kt.
///
/// [warmUp] once at app start (preparation takes a few seconds and must not
/// sit on the login screen's critical path); [tokenFor] per protected request.
class PlayIntegrityService {
  PlayIntegrityService._();
  static final PlayIntegrityService instance = PlayIntegrityService._();

  static const MethodChannel _channel =
      MethodChannel('com.aorbotreks.app/play_integrity');

  /// Override with --dart-define=PLAY_INTEGRITY_CLOUD_PROJECT_NUMBER=...
  /// Defaults to the Firebase project's number (messagingSenderId IS the
  /// project number), which is the Cloud project linked in Play Console.
  static const String _projectNumberOverride =
      String.fromEnvironment('PLAY_INTEGRITY_CLOUD_PROJECT_NUMBER');

  // Warm-up (background) may take a while on a cold device.
  static const Duration _prepareTimeout = Duration(seconds: 20);
  // Hard budget for [tokenFor] as a whole — prepare wait + request + retries.
  // Repository.postApiCall wraps the ENTIRE dio.post (interceptors included)
  // in a 20s timeout, so this leaves >= 12s for the actual network call.
  static const Duration tokenBudget = Duration(seconds: 8);

  /// Worth retrying: the device/Google hiccuped, nothing is wrong with it.
  static const Set<String> _transient = {
    'NETWORK_ERROR',
    'TOO_MANY_REQUESTS',
    'GOOGLE_SERVER_UNAVAILABLE',
    'CLIENT_TRANSIENT_ERROR',
    'INTERNAL_ERROR',
    'CANNOT_BIND_TO_SERVICE',
    'TIMEOUT',
  };
  static const List<Duration> _backoff = [
    Duration(milliseconds: 400),
    Duration(milliseconds: 1200),
  ];

  Future<void>? _prepared;

  bool get isSupported => !kIsWeb && Platform.isAndroid;

  String get _projectNumber => _projectNumberOverride.isNotEmpty
      ? _projectNumberOverride
      : DefaultFirebaseOptions.android.messagingSenderId;

  /// Fire-and-forget warm-up. Safe to call more than once; a failed
  /// preparation is retried by the next [tokenFor].
  void warmUp() {
    if (!isSupported) return;
    _ensurePrepared().catchError((Object e) {
      debugPrint('Play Integrity warm-up failed: $e');
    });
  }

  Future<void> _ensurePrepared() {
    final existing = _prepared;
    if (existing != null) return existing;
    final future = _channel
        .invokeMethod<bool>('prepare', {'cloudProjectNumber': _projectNumber})
        .timeout(_prepareTimeout)
        .then<void>((_) {});
    _prepared = future;
    // A failure must not be cached forever — let the next call try again.
    future.catchError((Object _) {
      if (identical(_prepared, future)) _prepared = null;
    });
    return future;
  }

  /// Mint a token bound to [requestHash]. Never throws.
  Future<IntegrityTokenResult> tokenFor(String requestHash) async {
    if (!isSupported) return const IntegrityTokenResult.error('UNSUPPORTED_PLATFORM');

    final clock = Stopwatch()..start();
    Duration remaining() => tokenBudget - clock.elapsed;

    String lastError = 'UNKNOWN';
    for (var attempt = 0; attempt <= _backoff.length; attempt++) {
      if (attempt > 0) {
        final wait = _backoff[attempt - 1];
        if (remaining() <= wait) break;
        await Future<void>.delayed(wait);
      }
      try {
        // .timeout() only stops OUR wait; the shared warm-up keeps running.
        await _ensurePrepared().timeout(remaining());
        final token = await _channel
            .invokeMethod<String>('request', {'requestHash': requestHash})
            .timeout(remaining());
        if (token != null && token.isNotEmpty) {
          return IntegrityTokenResult.token(token);
        }
        lastError = 'EMPTY_TOKEN';
      } on PlatformException catch (e) {
        lastError = e.code;
      } on TimeoutException {
        lastError = 'TIMEOUT';
      } on MissingPluginException {
        return const IntegrityTokenResult.error('CHANNEL_MISSING');
      } catch (_) {
        lastError = 'UNKNOWN';
      }
      if (!_transient.contains(lastError)) break;
    }
    return IntegrityTokenResult.error(lastError);
  }
}
