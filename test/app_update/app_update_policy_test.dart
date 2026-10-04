import 'dart:convert';

import 'package:arobo_app/app_update/app_update_policy.dart';
import 'package:arobo_app/repository/network_url.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _contractData() => {
  'current_version': '1.1.0',
  'current_build': 24,
  'latest_version': '1.2.0',
  'latest_build': 26,
  'min_supported_version': '1.1.0',
  'min_supported_build': 25,
  'update_available': true,
  'update_announced': true,
  'update_required': false,
  'required_from': '2026-10-20T00:00:00.000Z',
  'update_message':
      'We fixed a security issue. Please update to keep using Aorbo.',
  'release_notes': 'Faster search',
  'release_date': '2026-10-05T10:00:00.000Z',
  'platform': 'android',
  'store_url':
      'https://play.google.com/store/apps/details?id=com.aorbotreks.app',
};

void main() {
  group('AppUpdatePolicy — version/check response', () {
    test('reads every field of the contract', () {
      final p = AppUpdatePolicy.fromResponse({
        'success': true,
        'data': _contractData(),
      })!;
      expect(p.currentVersion, '1.1.0');
      expect(p.currentBuild, 24);
      expect(p.latestVersion, '1.2.0');
      expect(p.latestBuild, 26);
      expect(p.minSupportedVersion, '1.1.0');
      expect(p.minSupportedBuild, 25);
      expect(p.updateAvailable, isTrue);
      expect(p.updateAnnounced, isTrue);
      expect(p.updateRequired, isFalse);
      expect(p.requiredFrom, DateTime.utc(2026, 10, 20));
      expect(p.updateMessage, startsWith('We fixed a security issue'));
      expect(p.releaseNotes, 'Faster search');
      expect(p.storeUrl, kPlayStoreUrl);
      expect(p.dismissKey, 'b26');
    });

    test('old servers (no new fields) parse to "nothing to do"', () {
      final p = AppUpdatePolicy.fromResponse({
        'success': true,
        'data': {
          'current_version': '1.0.0',
          'latest_version': '1.0.0',
          'update_available': false,
          'update_required': false,
          'release_notes': null,
          'platform': 'android',
        },
      })!;
      expect(p.updateAvailable, isFalse);
      expect(p.updateAnnounced, isFalse);
      expect(p.updateRequired, isFalse);
      expect(p.latestBuild, isNull);
      expect(p.requiredFrom, isNull);
      expect(p.storeUrl, isNull);
      expect(p.dismissKey, 'v1.0.0');
    });

    test('wrong types become null / false and never throw', () {
      final p = AppUpdatePolicy.fromJson({
        'current_version': 110,
        'current_build': '24',
        'latest_build': 26.0,
        'min_supported_build': 'twenty-five',
        'update_available': 'true',
        'update_announced': 1,
        'update_required': 'yes',
        'required_from': 1760918400,
        'update_message': 42,
        'release_notes': ['line one', 'line two'],
        'store_url': {'android': 'x'},
      });
      expect(p.currentVersion, isNull);
      expect(p.currentBuild, 24);
      expect(p.latestBuild, 26);
      expect(p.minSupportedBuild, isNull);
      expect(p.updateAvailable, isFalse);
      expect(p.updateAnnounced, isFalse);
      expect(
        p.updateRequired,
        isFalse,
        reason: 'only a real JSON true may block',
      );
      expect(p.requiredFrom, isNull);
      expect(p.updateMessage, isNull);
      expect(p.releaseNotes, isNull);
      expect(p.storeUrl, isNull);
    });

    test('blank strings and bad dates are null; a zone-less date is UTC', () {
      final p = AppUpdatePolicy.fromJson({
        'update_message': '   ',
        'release_notes': '',
        'required_from': 'not a date',
      });
      expect(p.updateMessage, isNull);
      expect(p.releaseNotes, isNull);
      expect(p.requiredFrom, isNull);
      expect(
        AppUpdatePolicy.fromJson({
          'required_from': '2026-10-20 00:00:00',
        }).requiredFrom,
        DateTime.utc(2026, 10, 20),
      );
      expect(
        AppUpdatePolicy.fromJson({
          'required_from': '2026-10-20T05:30:00+05:30',
        }).requiredFrom,
        DateTime.utc(2026, 10, 20),
      );
    });

    test('only an https store link is kept', () {
      for (final bad in [
        'intent://details?id=x#Intent;end',
        'market://details?id=com.aorbotreks.app',
        'http://play.google.com/store/apps/details?id=com.aorbotreks.app',
        'javascript:alert(1)',
        'https://',
        '',
      ]) {
        expect(
          AppUpdatePolicy.fromJson({'store_url': bad}).storeUrl,
          isNull,
          reason: bad,
        );
      }
    });

    test('unusable responses give null (fail open)', () {
      for (final body in <Object?>[
        null,
        'garbage',
        42,
        [],
        {'success': false, 'message': 'boom', 'data': _contractData()},
        {'success': true},
        {'success': true, 'data': 'x'},
      ]) {
        expect(AppUpdatePolicy.fromResponse(body), isNull, reason: '$body');
      }
    });

    test('a JSON string body is decoded', () {
      final body = jsonEncode({
        'success': true,
        'data': {'update_required': true},
      });
      expect(AppUpdatePolicy.fromResponse(body)!.updateRequired, isTrue);
    });
  });

  group('isAppUpdateRequired — the server refusing this build', () {
    test('426 always means update', () {
      expect(isAppUpdateRequired(426, null), isTrue);
      expect(isAppUpdateRequired(426, 'Upgrade Required'), isTrue);
      expect(
        isAppUpdateRequired(426, {
          'success': false,
          'code': 'APP_UPDATE_REQUIRED',
        }),
        isTrue,
      );
    });

    test('403 only with code APP_UPDATE_REQUIRED (Play Integrity floor)', () {
      expect(
        isAppUpdateRequired(403, {
          'success': false,
          'code': 'APP_UPDATE_REQUIRED',
        }),
        isTrue,
      );
      expect(
        isAppUpdateRequired(403, '{"code":"APP_UPDATE_REQUIRED"}'),
        isTrue,
      );
      expect(isAppUpdateRequired(403, {'code': 'ACCOUNT_INACTIVE'}), isFalse);
      expect(isAppUpdateRequired(403, {'code': 'INTEGRITY_FAILED'}), isFalse);
      expect(isAppUpdateRequired(403, null), isFalse);
      expect(isAppUpdateRequired(403, 'Forbidden'), isFalse);
    });

    test('nothing else counts', () {
      expect(isAppUpdateRequired(null, null), isFalse);
      expect(
        isAppUpdateRequired(200, {'code': 'APP_UPDATE_REQUIRED'}),
        isFalse,
      );
      expect(
        isAppUpdateRequired(401, {'code': 'APP_UPDATE_REQUIRED'}),
        isFalse,
      );
      expect(
        isAppUpdateRequired(400, {'code': 'APP_UPDATE_REQUIRED'}),
        isFalse,
      );
      expect(isAppUpdateRequired(500, null), isFalse);
    });

    test('the block reads message + store_url, and drops a non-https link', () {
      final b = AppUpdateBlock.fromBody({
        'success': false,
        'code': 'APP_UPDATE_REQUIRED',
        'message': 'A plain message to show the user',
        'store_url': kPlayStoreUrl,
      });
      expect(b.message, 'A plain message to show the user');
      expect(b.storeUrl, kPlayStoreUrl);

      final integrity = AppUpdateBlock.fromBody({
        'code': 'APP_UPDATE_REQUIRED',
        'store_url': 'market://x',
      });
      expect(integrity.message, isNull);
      expect(integrity.storeUrl, isNull);
      expect(AppUpdateBlock.fromBody('<html>426</html>').message, isNull);
    });
  });

  group('version/check URL', () {
    test('sends the build next to current_version and platform', () {
      expect(
        NetworkUrl.validateVersion('1.1.0', 'android', build: '24'),
        'version/check?current_version=1.1.0&build=24&platform=android',
      );
    });

    test('without a build it stays the old request', () {
      expect(
        NetworkUrl.validateVersion('1.0.0', 'android'),
        'version/check?current_version=1.0.0&platform=android',
      );
      expect(
        NetworkUrl.validateVersion('1.0.0', 'android', build: ''),
        'version/check?current_version=1.0.0&platform=android',
      );
    });
  });
}
