// Scan E4: Android backup must not carry the sign-in session (access +
// refresh tokens, user id, "logged in" flag) to Google Drive or to a new
// phone. Backup stays on for everything else. A restored phone then starts
// signed out instead of replaying the old session, whose device-bound
// refresh fails and is recorded as a DEVICE_BINDING_VIOLATION.
//
// The session lives in Flutter's legacy SharedPreferences file
// (FlutterSharedPreferences.xml): SpUtil and Preferences both use
// SharedPreferences.getInstance(). (Aapt2 compiles both rule files; checked
// by hand with build-tools 35.0.0.)

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _res = 'android/app/src/main/res/xml';
const _sessionFile = 'FlutterSharedPreferences.xml';

String _read(String path) => File(path).readAsStringSync();

/// `<exclude domain="sharedpref" path="FlutterSharedPreferences.xml" />`
/// inside [xml] (ignoring comments).
bool _excludesSession(String xml) {
  final noComments = xml.replaceAll(RegExp(r'<!--[\s\S]*?-->'), '');
  return RegExp(
    r'<exclude\s+domain="sharedpref"\s+path="' + RegExp.escape(_sessionFile) + r'"\s*/>',
  ).hasMatch(noComments);
}

String _section(String xml, String tag) {
  final m = RegExp('<$tag>([\\s\\S]*?)</$tag>').firstMatch(xml);
  expect(m, isNotNull, reason: 'missing <$tag>');
  return m!.group(1)!;
}

void main() {
  final manifest = _read('android/app/src/main/AndroidManifest.xml');
  final application = RegExp(r'<application[\s\S]*?>').firstMatch(manifest)!.group(0)!;

  test('the manifest points backup at the rule files (Android 6-11 and 12+)', () {
    expect(application, contains('android:fullBackupContent="@xml/backup_rules"'));
    expect(application, contains('android:dataExtractionRules="@xml/data_extraction_rules"'));
    expect(application, isNot(contains('android:allowBackup="false"')),
        reason: 'owner choice: keep backup, exclude only the session');
  });

  test('Android 6-11 Auto Backup excludes the session file', () {
    final xml = _read('$_res/backup_rules.xml');
    expect(xml, contains('<full-backup-content>'));
    expect(_excludesSession(xml), isTrue);
  });

  test('Android 12+ excludes it from BOTH cloud backup and device-to-device transfer', () {
    final xml = _read('$_res/data_extraction_rules.xml');
    expect(_excludesSession(_section(xml, 'cloud-backup')), isTrue);
    expect(_excludesSession(_section(xml, 'device-transfer')), isTrue);
  });

  test('XML comments are well formed (no "--" inside a comment)', () {
    for (final f in ['backup_rules.xml', 'data_extraction_rules.xml']) {
      for (final c in RegExp(r'<!--([\s\S]*?)-->').allMatches(_read('$_res/$f'))) {
        expect(c.group(1)!.contains('--'), isFalse, reason: f);
      }
    }
  });
}
