import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../theme/app_tokens.dart';
import '../theme/app_typography.dart';
import '../utils/screen_constants.dart';

/// Official Giveaway Rules — native on purpose, so they stay reachable from
/// the app even if the campaign web page is down (Google Play requires the
/// official rules inside the app).
///
/// DESIGN PHASE: the text below is a draft built from the campaign plan
/// (v4, 29 Sep 2026) with the plan's recommended option for each open
/// decision. The backend phase replaces it with the round's frozen rules
/// version from the backend (rules_versions), so the text can't change
/// mid-round and every entry records which version it was made under.
class GiveawayRulesScreen extends StatelessWidget {
  const GiveawayRulesScreen({super.key});

  static const String _versionLabel = 'Round 1 · Draft for review';

  static const List<_RulesSection> _sections = [
    _RulesSection('1. The giveaway', [
      'The Aorbo Trek Giveaway ("the giveaway") is run by Aorbo Treks ("Aorbo"). '
          'Each round has one winner, chosen at random by computer.',
      'No purchase necessary. You never need to book, pay for or buy anything to enter or to get extra entries.',
    ]),
    _RulesSection('2. Who can enter', [
      '• You are 18 or older and live in India.',
      '• You are new to Aorbo: your mobile number has never been registered on Aorbo before, including accounts deleted in the last 12 months.',
      '• You signed up during the round\'s sign-up window. One account per person.',
      '• Not eligible: Aorbo employees and their immediate families, staff of trek organisers listed on Aorbo, and residents of Tamil Nadu.',
    ]),
    _RulesSection('3. How to enter', [
      'Sign up in the Aorbo app with your mobile number and OTP, open the giveaway, answer the 5 questions and tick "I agree to the Giveaway Rules". '
          'You get one entry number.',
      'You get one extra entry for each friend who signs up with your referral code and whose referral is verified before entries close. '
          'A referral is verified when your friend is new to Aorbo, applied your code at sign-up, is 18 or older and has completed the giveaway questions.',
    ]),
    _RulesSection('4. Round 1 dates (India time)', [
      '• Sign-ups count from: 1 January 2027',
      '• Entries close: 25 March 2027, 11:59:59 PM',
      '• Draw: 31 March 2027, 7:00 PM, shown live in the app and on aorbotreks.co.in',
      'Times are taken from Aorbo\'s server clock, not your phone\'s.',
    ]),
    _RulesSection('5. The draw', [
      'Between entries closing and the draw, Aorbo checks every entry. Entries that break these rules are removed, and the reason is recorded.',
      'The winner is picked at random from all valid entries. Your chances depend on how many valid entries there are.',
      'The result stays published for at least one year.',
    ]),
    _RulesSection('6. The prize', [
      'One trek of the winner\'s choice listed on Aorbo, for one person, with a listed price (including taxes) of up to ₹10,000, '
          'starting within 10 days of the winner being confirmed. If no trek fits that window, it is extended to 30 days.',
      'Not included: travel to and from the base camp, stays before or after the trek, gear rental, add-ons and personal expenses.',
      'The prize can\'t be exchanged for cash, transferred or upgraded by paying the difference. '
          'If the winner cancels the trek, there is no refund or replacement.',
      'If the trek organiser cancels the trek (for example for weather or too few bookings), Aorbo books another eligible trek for the winner.',
    ]),
    _RulesSection('7. Winner verification', [
      'Aorbo contacts the winner through the app and by phone. Within 2 days the winner must show a government photo ID proving they are 18 or older, and confirm they accept the prize.',
      'If the winner doesn\'t reply or can\'t be verified within 2 days, Aorbo draws another winner. The second draw is recorded and published the same way.',
    ]),
    _RulesSection('8. The trek', [
      'The trek is run by its trek organiser under the organiser\'s own terms. The winner must meet the trek\'s age, fitness and medical requirements. '
          'If the organiser turns the winner down, the winner can choose another eligible trek.',
      'Aorbo\'s responsibility is to provide the booking for the chosen trek.',
    ]),
    _RulesSection('9. Tax', [
      'The prize may count as income for the winner. The winner is responsible for any tax on it in their own tax return.',
    ]),
    _RulesSection('10. Fair play', [
      'Aorbo may remove entries and referrals that involve fake or multiple accounts, borrowed numbers, modified apps or devices, or automated sign-ups.',
      'Aorbo may pause or cancel the giveaway only for fraud, a technical failure or events outside its control, and will say so in the app. '
          'Aorbo will never use this to deny a valid winner after the draw.',
    ]),
    _RulesSection('11. Your information', [
      'Your answers are used for research about trekking and are only ever published as totals ("based on X Aorbo survey participants"). They never affect who wins.',
      'The winning entry number is always published. The winner\'s first initial and city are shown only if they tick the optional publicity box.',
      'See the Aorbo Privacy Policy for how your personal data is handled.',
    ]),
    _RulesSection('12. Questions and complaints', [
      'Write to care@aorbotreks.com. These rules are governed by Indian law.',
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
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
                  Text(_versionLabel, style: AppType.style(FontSize.s9, color: AppColors.inkMid)),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView.separated(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 4.h),
          itemCount: _sections.length,
          separatorBuilder: (_, __) => SizedBox(height: 1.4.h),
          itemBuilder: (_, i) => _sectionCard(_sections[i]),
        ),
      ),
    );
  }

  Widget _sectionCard(_RulesSection s) {
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

class _RulesSection {
  const _RulesSection(this.title, this.paragraphs);
  final String title;
  final List<String> paragraphs;
}
