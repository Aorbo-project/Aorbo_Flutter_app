import 'dart:convert';
import 'dart:io' show Platform;

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Device-bound session key (Android Keystore, via DeviceSecurityChannel.kt).
///
/// The public key goes to the backend once, with verify-otp. Every
/// /auth/refresh then carries `X-Device-Signature` = signature over
/// [refreshProofMessage] — so a refresh token copied off this phone is
/// useless anywhere else. Mirrors Backend services/deviceBinding.js.
class DeviceKeyService {
  DeviceKeyService._();
  static final DeviceKeyService instance = DeviceKeyService._();

  static const MethodChannel _channel = MethodChannel('com.aorbotreks.app/device_security');
  static const String signatureHeader = 'X-Device-Signature';

  bool get isSupported => !kIsWeb && Platform.isAndroid;

  /// MUST stay byte-identical to deviceBinding.refreshProofMessage.
  static List<int> refreshProofMessage(String refreshToken) {
    final tokenHash = sha256.convert(utf8.encode(refreshToken)).toString();
    return utf8.encode('aorbo-refresh-v1\n$tokenHash');
  }

  /// Base64 SPKI of the device key (created on first call), or null if the
  /// device can't provide one — login then simply isn't device-bound.
  Future<String?> publicKey() async {
    if (!isSupported) return null;
    try {
      return await _channel.invokeMethod<String>('deviceKeyPublic')
          .timeout(const Duration(seconds: 5));
    } catch (e) {
      debugPrint('DeviceKeyService.publicKey failed: $e');
      return null;
    }
  }

  /// Signature for a refresh call, or null if signing failed (the backend
  /// then rejects the refresh for a bound session → normal re-login).
  Future<String?> signRefresh(String refreshToken) async {
    if (!isSupported) return null;
    try {
      return await _channel.invokeMethod<String>('deviceKeySign', {
        'data': Uint8List.fromList(refreshProofMessage(refreshToken)),
      }).timeout(const Duration(seconds: 5));
    } catch (e) {
      debugPrint('DeviceKeyService.signRefresh failed: $e');
      return null;
    }
  }

  /// Drop the key on logout — the next login binds a fresh one.
  Future<void> reset() async {
    if (!isSupported) return;
    try {
      await _channel.invokeMethod<bool>('deviceKeyReset');
    } catch (_) {}
  }
}
