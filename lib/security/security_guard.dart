import 'package:arobo_app/repository/repository.dart';
import 'package:arobo_app/security/device_risk_service.dart';
import 'package:arobo_app/security/security_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// Runs the security layers after start-up and whenever the app returns to
/// the foreground:
///  - refreshes the remote kill switches and rebuilds the HTTP clients if the
///    pinning switch changed
///  - re-scans for tampering; if a hooking framework, debugger or modified
///    build is found (release builds only, remote-switchable) the app shows
///    [SecurityBlockedScreen] instead of continuing.
class SecurityGuard with WidgetsBindingObserver {
  SecurityGuard._();
  static final SecurityGuard instance = SecurityGuard._();

  bool _started = false;
  bool _blocked = false;

  void start() {
    if (_started) return;
    _started = true;
    WidgetsBinding.instance.addObserver(this);
    _check(refreshConfig: true);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _check(refreshConfig: true);
  }

  Future<void> _check({required bool refreshConfig}) async {
    if (refreshConfig && await SecurityConfig.refresh()) {
      Repository().resetHttpClients();
    }
    await DeviceRiskService.instance.scan();
    if (_blocked || !kReleaseMode || !SecurityConfig.raspBlockEnabled) return;
    if (DeviceRiskService.instance.mustBlock) {
      _blocked = true;
      Get.offAll(() => const SecurityBlockedScreen());
    }
  }
}

class SecurityBlockedScreen extends StatelessWidget {
  const SecurityBlockedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.gpp_bad_outlined, size: 72, color: Color(0xFFD32F2F)),
                const SizedBox(height: 24),
                const Text(
                  'This device is not secure',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.black),
                ),
                const SizedBox(height: 12),
                const Text(
                  'To protect your account and payments, Aorbo can\'t run while '
                  'debugging or app-modification tools are active on this phone. '
                  'Please remove them, reinstall Aorbo from the Google Play Store, and try again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, height: 1.45, color: Color(0xFF555555)),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => SystemNavigator.pop(),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Close app'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
