import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../theme/app_tokens.dart';
import '../theme/app_typography.dart';
import '../utils/screen_constants.dart';
import 'giveaway_api.dart';

/// Official Giveaway Rules — native on purpose, so they stay reachable from
/// the app even if the campaign web page is down (Google Play requires the
/// official rules inside the app).
///
/// The text is the round's frozen rules version from the backend
/// (GET giveaway/rules → giveaway_rules_versions), so it can't change
/// mid-round and matches what every entry was made under.
class GiveawayRulesScreen extends StatefulWidget {
  const GiveawayRulesScreen({super.key, this.api, this.round});

  final GiveawayApi? api;

  /// The round whose rules to show (from the page); null → the signed-in
  /// person's own round, decided by the backend.
  final String? round;

  @override
  State<GiveawayRulesScreen> createState() => _GiveawayRulesScreenState();
}

class _GiveawayRulesScreenState extends State<GiveawayRulesScreen> {
  late Future<GiveawayRules?> _rules;

  GiveawayApi get _api => widget.api ?? GiveawayApi.instance;

  String? get _round {
    if (widget.round != null) return widget.round;
    final args = Get.arguments;
    final r = args is Map ? args['round'] : null;
    return r is String && RegExp(r'^[A-Z0-9-]{2,16}$').hasMatch(r) ? r : null;
  }

  @override
  void initState() {
    super.initState();
    _rules = _api.rules(round: _round);
  }

  void _retry() => setState(() => _rules = _api.rules(round: _round));

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<GiveawayRules?>(
      future: _rules,
      builder: (context, snap) {
        final rules = snap.data;
        final loading = snap.connectionState != ConnectionState.done;
        return Scaffold(
          backgroundColor: AppColors.bg,
          appBar: _appBar(rules),
          body: SafeArea(
            top: false,
            child: loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.forest))
                : rules == null
                    ? _errorState()
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 4.h),
                        itemCount: rules.sections.length,
                        separatorBuilder: (_, __) => SizedBox(height: 1.4.h),
                        itemBuilder: (_, i) => _sectionCard(rules.sections[i]),
                      ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _appBar(GiveawayRules? rules) {
    final subtitle = rules == null
        ? 'Aorbo Trek Giveaway'
        : [rules.label, if (rules.version.isNotEmpty) 'version ${rules.version}'].where((s) => s.isNotEmpty).join(' · ');
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      titleSpacing: 4.w,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.divider),
      ),
      title: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 1.h),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.ink),
            ),
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Giveaway Rules', style: AppType.style(FontSize.s13, w: FontWeight.w700)),
                Text(subtitle, style: AppType.style(FontSize.s9, color: AppColors.inkMid)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Couldn't load the rules",
              textAlign: TextAlign.center,
              style: AppType.style(FontSize.s12, w: FontWeight.w700),
            ),
            SizedBox(height: 0.8.h),
            Text(
              'Check your internet connection and try again.',
              textAlign: TextAlign.center,
              style: AppType.style(FontSize.s9, color: AppColors.inkMid, height: 1.5),
            ),
            SizedBox(height: 2.4.h),
            OutlinedButton(
              onPressed: _retry,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.forest,
                side: const BorderSide(color: AppColors.forest),
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.2.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
              ),
              child: Text(
                'Try again',
                style: AppType.style(FontSize.s10, w: FontWeight.w600, color: AppColors.forest),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard(GiveawayRulesSection s) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.soft(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(s.title, style: AppType.style(FontSize.s11, w: FontWeight.w700)),
          SizedBox(height: 1.h),
          ...s.paragraphs.map(
            (p) => Padding(
              padding: EdgeInsets.only(bottom: 0.8.h),
              child: Text(p, style: AppType.style(FontSize.s9, color: AppColors.ink, height: 1.55)),
            ),
          ),
        ],
      ),
    );
  }
}
