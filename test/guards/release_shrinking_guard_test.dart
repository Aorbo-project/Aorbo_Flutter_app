// Release-build guard (16 Oct 2026). 1.0.0+27 crashed on every phone before the
// first frame: AGP 9 switched R8 to strict full-mode keep rules, WorkManager's
// Room database lost its constructor ("Failed to create an instance of
// androidx.work.impl.WorkDatabase"). Debug builds don't shrink, so no test or
// debug run saw it. These settings must stay.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('R8 keeps the keep-rule meaning library rules were written for', () {
    final props = File('android/gradle.properties').readAsStringSync();
    expect(
      RegExp(r'^android\.r8\.strictFullModeForKeepRules=false\s*$', multiLine: true).hasMatch(props),
      isTrue,
      reason: 'Removing this brings back the +27 startup crash (WorkDatabase).',
    );
  });

  test('classes created by reflection keep their constructors', () {
    final rules = File('android/app/proguard-rules.pro').readAsStringSync();
    for (final rule in [
      '-keep class * extends androidx.room.RoomDatabase { <init>(); }',
      '-keep class * extends androidx.work.ListenableWorker { <init>(android.content.Context, androidx.work.WorkerParameters); }',
      '-keep class * implements androidx.startup.Initializer { <init>(); }',
    ]) {
      expect(rules.contains(rule), isTrue, reason: 'missing: $rule');
    }
  });

  test('the release build really uses those rules', () {
    final gradle = File('android/app/build.gradle').readAsStringSync();
    expect(gradle, contains("proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'"));
  });
}
