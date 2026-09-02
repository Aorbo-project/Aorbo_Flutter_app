import 'package:flutter_test/flutter_test.dart';
import 'package:arobo_app/models/auth/verify_otp_modal.dart';

void main() {
  group('VerifyOtpModal.Data — refresh token parsing', () {
    test('reads camelCase refreshToken', () {
      final m = VerifyOtpModal.fromJson({
        'success': true,
        'data': {'token': 'access-1', 'refreshToken': 'refresh-abc', 'expiresIn': '30m'},
      });
      expect(m.data?.token, 'access-1');
      expect(m.data?.refreshToken, 'refresh-abc');
      expect(m.data?.expiresIn, '30m');
    });

    test('falls back to snake_case refresh_token', () {
      final m = VerifyOtpModal.fromJson({
        'success': true,
        'data': {'token': 'access-1', 'refresh_token': 'refresh-xyz'},
      });
      expect(m.data?.refreshToken, 'refresh-xyz');
    });

    test('refreshToken is null when the backend does not send one', () {
      final m = VerifyOtpModal.fromJson({
        'success': true,
        'data': {'token': 'access-only', 'expiresIn': '1y'},
      });
      expect(m.data?.token, 'access-only');
      expect(m.data?.refreshToken, isNull);
    });

    test('round-trips through toJson', () {
      final m = VerifyOtpModal.fromJson({
        'data': {'token': 't', 'refreshToken': 'r'},
      });
      final j = m.toJson()['data'] as Map<String, dynamic>;
      expect(j['token'], 't');
      expect(j['refreshToken'], 'r');
    });
  });
}
