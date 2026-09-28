import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../repository/network_url.dart';
import '../repository/repository.dart';
import '../theme/app_tokens.dart';
import '../theme/app_typography.dart';
import '../utils/common_logics.dart';
import '../utils/custom_snackbar.dart';
import '../utils/screen_constants.dart';

/// Delete Account — customer self-service account deletion.
///
/// Procedure (owner decision 2026-09-28):
///  * A request schedules deletion 30 days out and signs the customer out;
///    signing in again within those 30 days cancels it automatically.
///  * Blocked while the customer has an upcoming trek, a refund in progress
///    or an open complaint.
///  * Profile, travellers, emergency contacts, coupons/rewards, device and
///    login history are erased; booking/payment/GST records are kept as the
///    law requires.
///  * The number is kept only as a one-way code, so Aorbo offers and referral
///    rewards are not available again on it for 12 months.
///
/// Backend: GET/POST/DELETE customer/account/deletion
/// (services/accountDeletionService.js).
class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  // label → reason code accepted by the backend
  static const _reasons = <String, String>{
    "I don't trek often": 'dont_trek_often',
    'I use another app': 'use_another_app',
    'Privacy concerns': 'privacy',
    'Too many notifications': 'too_many_notifications',
    'Had a bad experience': 'bad_experience',
    'Something else': 'other',
  };

  final Repository _repository = Repository();
  String? _reason;
  bool _understood = false;
  bool _loading = true;
  bool _submitting = false;
  String? _loadError;
  List<String> _blockers = const [];

  bool get _canSubmit => _reason != null && _understood && _blockers.isEmpty && !_submitting;

  String get _deletionDate {
    final d = DateTime.now().add(const Duration(days: 30));
    const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day} ${m[d.month - 1]} ${d.year}';
  }

  /// "28 Oct 2026" from an ISO timestamp (local time).
  static String _formatDate(String? iso) {
    final d = DateTime.tryParse(iso ?? '')?.toLocal();
    if (d == null) return '';
    const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day} ${m[d.month - 1]} ${d.year}';
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final res = await _repository.getApiCall(url: NetworkUrl.accountDeletionPath);
      final data = res is Map ? res['data'] : null;
      final blockers = (data is Map && data['blockers'] is List)
          ? (data['blockers'] as List)
              .map((b) => b is Map ? (b['message']?.toString() ?? '') : '')
              .where((m) => m.isNotEmpty)
              .toList()
          : <String>[];
      if (!mounted) return;
      setState(() {
        _blockers = blockers;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = "Couldn't load your account details. Please try again.";
      });
    }
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      final res = await _repository.postApiCall(
        url: NetworkUrl.accountDeletionPath,
        body: {'reason': _reasons[_reason]},
      );
      if (res is Map && res['success'] == true) {
        final data = res['data'];
        final scheduled = data is Map ? data['scheduledFor']?.toString() : null;
        _showScheduled(_formatDate(scheduled));
        return;
      }
      throw Exception('Request failed');
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      final msg = e.toString().replaceFirst('Exception: ', '');
      CustomSnackBar.show(
        context,
        message: msg.isNotEmpty && msg != 'Request failed'
            ? msg
            : "Couldn't delete your account. Please try again.",
      );
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: _appBar(),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.danger))
            : _loadError != null
                ? _errorState()
                : _content(),
      ),
    );
  }

  Widget _content() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 4.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _timelineCard(),
          SizedBox(height: 2.h),
          _listCard(
            title: 'What will be deleted',
            icon: Icons.delete_outline_rounded,
            iconColor: AppColors.danger,
            items: const [
              'Your profile — name, e-mail and state',
              'Saved travellers and emergency contacts',
              'Your referral code, unused coupons and rewards',
              'Login history, devices and notification settings',
            ],
          ),
          SizedBox(height: 1.6.h),
          _listCard(
            title: 'What we keep',
            icon: Icons.inventory_2_outlined,
            iconColor: AppColors.inkMid,
            items: const [
              'Booking, payment and GST invoice records, for as long as tax and other laws require',
              'Your mobile number, name and e-mail for 180 days, as the law requires — then deleted',
              'A one-way code of your number for 12 months, to stop misuse of offers — Aorbo offers and referral rewards will not be available on this number during that time',
            ],
          ),
          SizedBox(height: 1.6.h),
          _blockers.isEmpty ? _blockerNote() : _blockedCard(),
          SizedBox(height: 2.4.h),
          Text('Why are you leaving?', style: AppType.style(FontSize.s11, w: FontWeight.w700)),
          SizedBox(height: 1.2.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: _reasons.keys.map(_reasonChip).toList(),
          ),
          SizedBox(height: 2.4.h),
          _understandRow(),
          SizedBox(height: 2.4.h),
          _deleteButton(),
          SizedBox(height: 1.4.h),
          Center(
            child: TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'Keep my account',
                style: AppType.style(FontSize.s10, w: FontWeight.w600, color: AppColors.ink),
              ),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _appBar() {
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
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.ink),
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Delete Account', style: AppType.style(FontSize.s13, w: FontWeight.w700)),
                Text(
                  'Permanently remove your Aorbo account',
                  style: AppType.style(FontSize.s9, color: AppColors.inkMid),
                ),
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
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _loadError!,
              textAlign: TextAlign.center,
              style: AppType.style(FontSize.s10, color: AppColors.inkMid),
            ),
            SizedBox(height: 2.h),
            OutlinedButton(
              onPressed: _load,
              child: Text('Try again', style: AppType.style(FontSize.s10, w: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _timelineCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.dangerSoft,
        borderRadius: BorderRadius.circular(4.w),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const Icon(Icons.schedule_rounded, color: AppColors.danger, size: 20),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Deleted after 30 days',
                  style: AppType.style(FontSize.s11, w: FontWeight.w700, color: AppColors.danger),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'If you continue, your account will be deleted on $_deletionDate. '
                  'Changed your mind? Just log in again before that date and the request is cancelled.',
                  style: AppType.style(FontSize.s9, color: AppColors.ink, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _listCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<String> items,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(4.w),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: iconColor),
              SizedBox(width: 2.w),
              Text(title, style: AppType.style(FontSize.s11, w: FontWeight.w700)),
            ],
          ),
          SizedBox(height: 1.2.h),
          ...items.map(
            (t) => Padding(
              padding: EdgeInsets.only(bottom: 0.9.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 0.8.h),
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(color: iconColor, shape: BoxShape.circle),
                    ),
                  ),
                  SizedBox(width: 2.5.w),
                  Expanded(
                    child: Text(t, style: AppType.style(FontSize.s9, color: AppColors.inkMid, height: 1.5)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _blockerNote() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.4.h),
      decoration: BoxDecoration(
        color: AppColors.warningSoft,
        borderRadius: BorderRadius.circular(3.w),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.amber),
          SizedBox(width: 2.5.w),
          Expanded(
            child: Text(
              'You can delete your account only when you have no upcoming or ongoing trek (wait until it is completed, or cancel it), no refund in progress and no open complaint.',
              style: AppType.style(FontSize.s9, color: AppColors.ink, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _blockedCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.dangerSoft,
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.block_rounded, size: 18, color: AppColors.danger),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  "You can't delete your account yet",
                  style: AppType.style(FontSize.s10, w: FontWeight.w700, color: AppColors.danger),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          ..._blockers.map(
            (m) => Padding(
              padding: EdgeInsets.only(bottom: 0.6.h),
              child: Text('• $m', style: AppType.style(FontSize.s9, color: AppColors.ink, height: 1.5)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _reasonChip(String r) {
    final selected = _reason == r;
    return GestureDetector(
      onTap: () => setState(() => _reason = r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.ink : AppColors.surface,
          borderRadius: BorderRadius.circular(6.w),
          border: Border.all(color: selected ? AppColors.ink : AppColors.border),
        ),
        child: Text(
          r,
          style: AppType.style(
            FontSize.s9,
            w: FontWeight.w600,
            color: selected ? Colors.white : AppColors.ink,
          ),
        ),
      ),
    );
  }

  Widget _understandRow() {
    return GestureDetector(
      onTap: () => setState(() => _understood = !_understood),
      behavior: HitTestBehavior.opaque,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 20,
            height: 20,
            margin: EdgeInsets.only(top: 0.2.h),
            decoration: BoxDecoration(
              color: _understood ? AppColors.danger : Colors.white,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: _understood ? AppColors.danger : AppColors.inkLight, width: 1.5),
            ),
            child: _understood ? const Icon(Icons.check_rounded, size: 15, color: Colors.white) : null,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              'I understand that after 30 days my account and data will be permanently deleted and cannot be recovered.',
              style: AppType.style(FontSize.s9, color: AppColors.ink, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _deleteButton() {
    return SizedBox(
      width: double.infinity,
      height: 6.h,
      child: ElevatedButton(
        onPressed: _canSubmit ? _confirm : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.danger,
          disabledBackgroundColor: AppColors.danger.withValues(alpha: 0.35),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3.w)),
        ),
        child: _submitting
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
              )
            : Text(
                'Delete my account',
                style: AppType.style(FontSize.s11, w: FontWeight.w700, color: Colors.white),
              ),
      ),
    );
  }

  void _confirm() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.fromLTRB(5.w, 2.5.h, 5.w, 3.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(6.w)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 4,
              decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
            ),
            SizedBox(height: 2.5.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: const BoxDecoration(color: AppColors.dangerSoft, shape: BoxShape.circle),
              child: const Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 28),
            ),
            SizedBox(height: 1.6.h),
            Text('Delete your account?', style: AppType.style(FontSize.s13, w: FontWeight.w700)),
            SizedBox(height: 0.8.h),
            Text(
              'Your account will be deleted on $_deletionDate and you will be logged out now. '
              'Logging in again before then cancels it.',
              textAlign: TextAlign.center,
              style: AppType.style(FontSize.s9, color: AppColors.inkMid, height: 1.5),
            ),
            SizedBox(height: 2.5.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size.fromHeight(5.5.h),
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3.w)),
                    ),
                    child: Text('Cancel', style: AppType.style(FontSize.s10, w: FontWeight.w600)),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      _submit();
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size.fromHeight(5.5.h),
                      backgroundColor: AppColors.danger,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3.w)),
                    ),
                    child: Text(
                      'Yes, delete',
                      style: AppType.style(FontSize.s10, w: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showScheduled(String date) {
    Get.dialog(
      PopScope(
        canPop: false,
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.w)),
          child: Padding(
            padding: EdgeInsets.all(5.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 44),
                SizedBox(height: 1.4.h),
                Text('Deletion scheduled', style: AppType.style(FontSize.s13, w: FontWeight.w700)),
                SizedBox(height: 0.8.h),
                Text(
                  'Your account will be deleted on ${date.isEmpty ? _deletionDate : date}. '
                  "We've logged you out. Logging in again before that date cancels the request.",
                  textAlign: TextAlign.center,
                  style: AppType.style(FontSize.s9, color: AppColors.inkMid, height: 1.5),
                ),
                SizedBox(height: 2.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    // The server has already ended every session; clear this
                    // device and return to the sign-in screen.
                    onPressed: () => CommonLogics.logOut(),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size.fromHeight(5.5.h),
                      backgroundColor: AppColors.ink,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3.w)),
                    ),
                    child: Text('OK', style: AppType.style(FontSize.s10, w: FontWeight.w700, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}
