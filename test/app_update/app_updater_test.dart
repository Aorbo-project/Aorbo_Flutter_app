import 'package:arobo_app/app_update/app_update_policy.dart';
import 'package:arobo_app/app_update/app_updater.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_update/in_app_update.dart';

AppUpdateInfo _info(
  UpdateAvailability availability, {
  bool immediateAllowed = true,
}) => AppUpdateInfo(
  updateAvailability: availability,
  immediateUpdateAllowed: immediateAllowed,
  immediateAllowedPreconditions: null,
  flexibleUpdateAllowed: false,
  flexibleAllowedPreconditions: null,
  availableVersionCode: 26,
  installStatus: InstallStatus.unknown,
  packageName: 'com.aorbotreks.app',
  clientVersionStalenessDays: null,
  updatePriority: 0,
);

/// Records what the updater did instead of calling the plugins.
class _Play {
  _Play({
    this.check,
    this.result = AppUpdateResult.success,
    this.openResult = true,
  });

  final Future<AppUpdateInfo> Function()? check;
  final AppUpdateResult result;
  final bool openResult;
  int checks = 0;
  int immediateUpdates = 0;
  final List<Uri> opened = [];

  PlayAppUpdater updater({bool android = true}) => PlayAppUpdater(
    useInAppUpdate: android,
    checkForUpdate: () {
      checks++;
      return check!();
    },
    performImmediateUpdate: () async {
      immediateUpdates++;
      return result;
    },
    openUrl: (uri) async {
      opened.add(uri);
      return openResult;
    },
  );
}

void main() {
  const serverStoreUrl =
      'https://play.google.com/store/apps/details?id=com.aorbotreks.app&ref=426';

  test('Play has the update: runs the IMMEDIATE flow, no store page', () async {
    final play = _Play(
      check: () async => _info(UpdateAvailability.updateAvailable),
    );
    expect(
      await play.updater().update(storeUrl: serverStoreUrl),
      AppUpdateOutcome.inAppUpdate,
    );
    expect(play.immediateUpdates, 1);
    expect(play.opened, isEmpty);
  });

  test('an immediate update left half-way is resumed', () async {
    final play = _Play(
      check: () async =>
          _info(UpdateAvailability.developerTriggeredUpdateInProgress),
    );
    expect(await play.updater().update(), AppUpdateOutcome.inAppUpdate);
    expect(play.immediateUpdates, 1);
  });

  test(
    'the person closes Play\'s update screen: stay, no store page',
    () async {
      final play = _Play(
        check: () async => _info(UpdateAvailability.updateAvailable),
        result: AppUpdateResult.userDeniedUpdate,
      );
      expect(await play.updater().update(), AppUpdateOutcome.declined);
      expect(play.opened, isEmpty);
    },
  );

  test('in-app update failed: opens the server store_url', () async {
    final play = _Play(
      check: () async => _info(UpdateAvailability.updateAvailable),
      result: AppUpdateResult.inAppUpdateFailed,
    );
    expect(
      await play.updater().update(storeUrl: serverStoreUrl),
      AppUpdateOutcome.openedStore,
    );
    expect(play.opened.single.toString(), serverStoreUrl);
  });

  test('Play sees no update (or immediate not allowed): store page', () async {
    for (final info in [
      _info(UpdateAvailability.updateNotAvailable),
      _info(UpdateAvailability.unknown),
      _info(UpdateAvailability.updateAvailable, immediateAllowed: false),
    ]) {
      final play = _Play(check: () async => info);
      expect(await play.updater().update(), AppUpdateOutcome.openedStore);
      expect(play.immediateUpdates, 0);
      expect(
        play.opened.single.toString(),
        kPlayStoreUrl,
        reason: 'default listing',
      );
    }
  });

  test('not installed from Play / plugin error: store page', () async {
    final play = _Play(
      check: () async => throw PlatformException(
        code: 'TASK_FAILURE',
        message: 'Install Error(-10)',
      ),
    );
    expect(
      await play.updater().update(storeUrl: serverStoreUrl),
      AppUpdateOutcome.openedStore,
    );
    expect(play.opened.single.toString(), serverStoreUrl);
  });

  test(
    'a non-https store link is never opened; the default listing is',
    () async {
      final play = _Play(
        check: () async => _info(UpdateAvailability.updateNotAvailable),
      );
      await play.updater().update(storeUrl: 'intent://evil#Intent;end');
      expect(play.opened.single.toString(), kPlayStoreUrl);
    },
  );

  test('off Android: straight to the store, Play is never asked', () async {
    final play = _Play(
      check: () async => throw StateError('must not be called'),
    );
    expect(
      await play.updater(android: false).update(storeUrl: serverStoreUrl),
      AppUpdateOutcome.openedStore,
    );
    expect(play.checks, 0);
  });

  test('nothing could be opened: failed', () async {
    final play = _Play(
      check: () async => _info(UpdateAvailability.updateNotAvailable),
      openResult: false,
    );
    expect(await play.updater().update(), AppUpdateOutcome.failed);

    final throwing = PlayAppUpdater(
      useInAppUpdate: false,
      openUrl: (_) async => throw PlatformException(code: 'ACTIVITY_NOT_FOUND'),
    );
    expect(await throwing.update(), AppUpdateOutcome.failed);
  });
}
