// Play Console recommendations fixed 20 Nov 2026 (release 36 report): keep them fixed.
//  - edge-to-edge: no deprecated bar-colour setters in our code or themes; edge-to-edge switched on;
//  - large screens: never an unconditional portrait lock;
//  - bitmap memory: Image.network always decodes at a set size (CustomNetworkImage handles the rest).
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Iterable<File> dartFiles(String dir) => Directory(dir)
    .listSync(recursive: true)
    .whereType<File>()
    .where((f) => f.path.endsWith('.dart') && !f.path.contains('.g.dart') && !f.path.contains('.freezed.dart'));

void main() {
  test('no deprecated status / navigation bar colours (Android 15)', () {
    final bad = RegExp(r'statusBarColor|systemNavigationBarColor|systemNavigationBarDividerColor|SystemUiOverlayStyle\.(dark|light)\b');
    for (final f in dartFiles('lib')) {
      final hits = f.readAsLinesSync().where((l) => !l.trimLeft().startsWith('//') && bad.hasMatch(l));
      expect(hits, isEmpty, reason: '${f.path} sets a system bar colour');
    }
    for (final f in Directory('android/app/src/main/res').listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.xml'))) {
      expect(f.readAsStringSync(), isNot(matches(RegExp(r'android:(statusBarColor|navigationBarColor|navigationBarDividerColor)'))),
          reason: '${f.path} sets a deprecated bar colour');
    }
  });

  test('edge-to-edge on; the start-up orientation lock depends on the screen size', () {
    final main = File('lib/main.dart').readAsStringSync();
    expect(main, contains('SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge)'));
    expect(main, isNot(contains('setPreferredOrientations([DeviceOrientation.portraitUp])')));
    expect(main, contains('orientationsFor('));
  });

  test('every Image.network decodes at a set size', () {
    for (final f in dartFiles('lib')) {
      final src = f.readAsStringSync();
      for (final m in RegExp(r'Image\.network\(([\s\S]*?)\)\s*[,;:]').allMatches(src)) {
        expect(m.group(1), anyOf(contains('cacheWidth'), contains('cacheHeight')), reason: '${f.path}: Image.network without cacheWidth');
      }
    }
  });
}
