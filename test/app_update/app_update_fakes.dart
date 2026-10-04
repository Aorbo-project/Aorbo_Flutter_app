// Shared fakes for the app_update tests (not a test file itself).

import 'dart:async';

import 'package:arobo_app/app_update/app_updater.dart';

/// Records "Update now" taps instead of reaching the Play / url_launcher
/// plugins. [gate], when set, holds the update open until completed.
class FakeUpdater implements AppUpdater {
  FakeUpdater([this.outcome = AppUpdateOutcome.openedStore]);

  AppUpdateOutcome outcome;
  Completer<void>? gate;
  final List<String?> calls = [];

  @override
  Future<AppUpdateOutcome> update({String? storeUrl}) async {
    calls.add(storeUrl);
    if (gate != null) await gate!.future;
    return outcome;
  }
}
