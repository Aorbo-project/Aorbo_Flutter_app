import 'package:arobo_app/theme/app_typography.dart';
import 'package:arobo_app/utils/common_colors.dart';
import 'package:arobo_app/utils/screen_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import 'legal_documents.dart';
import 'legal_service.dart';

/// Dashboard entry: if the signed-in customer hasn't agreed to the current
/// Terms / Privacy Policy, show the "We've updated…" sheet — at most once per
/// app run, never when logged out. Every failure is silent. Completes when
/// the sheet closes (or straight away when there's nothing to show).
Future<void> maybeShowLegalUpdatePrompt({
  Duration settle = const Duration(milliseconds: 800),
}) async {
  try {
    final service = LegalService.instance;
    // Check now, but let the dashboard finish revealing before a sheet rises.
    final results = await Future.wait<Object?>([
      service.statusForPrompt(),
      Future<void>.delayed(settle),
    ]);
    final status = results.first as LegalStatus?;
    if (status == null || !service.isLoggedIn) return;
    await Get.bottomSheet<void>(
      LegalUpdateSheet(initialDocuments: documentsForPrompt(status, service.documents)),
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  } catch (_) {
    // Never let a legal nudge break the dashboard.
  }
}

/// Non-dismissible: the only way out is "I agree" (or signing out elsewhere).
class LegalUpdateSheet extends StatefulWidget {
  const LegalUpdateSheet({super.key, required this.initialDocuments});

  final List<LegalDocument> initialDocuments;

  @override
  State<LegalUpdateSheet> createState() => _LegalUpdateSheetState();
}

class _LegalUpdateSheetState extends State<LegalUpdateSheet> {
  late List<LegalDocument> _docs = widget.initialDocuments;
  bool _saving = false;
  String? _error;
  String? _notice;

  Future<void> _agree() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    final service = LegalService.instance;
    final result = await service.acceptCurrent(LegalAcceptSource.updatePrompt);
    if (!mounted) return;
    switch (result.outcome) {
      case LegalAcceptOutcome.accepted:
        Navigator.of(context).pop();
      case LegalAcceptOutcome.outdated:
        // A document changed while the sheet was open — show the new set
        // and ask again.
        final status = await service.checkStatus();
        if (!mounted) return;
        if (status != null && !status.needsAcceptance) {
          Navigator.of(context).pop();
          return;
        }
        setState(() {
          _saving = false;
          _docs = documentsForPrompt(
            status ?? const LegalStatus(needsAcceptance: true, documents: []),
            service.documents,
          );
          _notice = 'These documents were updated a moment ago. '
              'Please take a look, then tap "I agree" again.';
        });
      case LegalAcceptOutcome.failed:
        setState(() {
          _saving = false;
          _error = result.message ?? legalAcceptGenericError;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(6.w, 3.h, 6.w, 2.h),
        decoration: BoxDecoration(
          color: CommonColors.whiteColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(6.w)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(2.5.w),
                  decoration: BoxDecoration(
                    color: CommonColors.appYellowColor.withValues(alpha: 0.35),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.gavel_rounded, color: CommonColors.blackColor, size: 24),
                ),
                SizedBox(height: 1.6.h),
                Text(
                  "We've updated our Terms & Conditions and Privacy Policy",
                  style: AppType.style(FontSize.s13, w: FontWeight.w700, color: CommonColors.blackColor, height: 1.3),
                ),
                SizedBox(height: 1.h),
                Text(
                  'Please take a moment to read them. Tapping "I agree" means you '
                  'accept the updated versions.',
                  style: AppType.style(FontSize.s10, color: CommonColors.textColor2, height: 1.5),
                ),
                SizedBox(height: 1.6.h),
                for (final doc in _docs) _DocLink(doc: doc),
                if (_notice != null) ...[
                  SizedBox(height: 1.2.h),
                  Text(
                    _notice!,
                    style: AppType.style(FontSize.s9, w: FontWeight.w500, color: CommonColors.textColor2, height: 1.4),
                  ),
                ],
                if (_error != null) ...[
                  SizedBox(height: 1.2.h),
                  Text(
                    _error!,
                    style: AppType.style(FontSize.s9, w: FontWeight.w500, color: CommonColors.materialRed, height: 1.4),
                  ),
                ],
                SizedBox(height: 2.4.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _agree,
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size.fromHeight(5.8.h),
                      backgroundColor: CommonColors.blackColor,
                      disabledBackgroundColor: CommonColors.blackColor.withValues(alpha: 0.6),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3.w)),
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.4, color: CommonColors.whiteColor),
                          )
                        : Text(
                            'I agree',
                            style: AppType.style(FontSize.s11, w: FontWeight.w700, color: CommonColors.whiteColor),
                          ),
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

class _DocLink extends StatelessWidget {
  const _DocLink({required this.doc});

  final LegalDocument doc;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => openLegalUrl(doc.url),
      borderRadius: BorderRadius.circular(2.w),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 1.h),
        child: Row(
          children: [
            const Icon(Icons.description_outlined, size: 20, color: CommonColors.materialBlue),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                doc.title,
                style: AppType.style(
                  FontSize.s11,
                  w: FontWeight.w600,
                  color: CommonColors.materialBlue,
                  decoration: TextDecoration.underline,
                  decorationColor: CommonColors.materialBlue,
                ),
              ),
            ),
            const Icon(Icons.open_in_new_rounded, size: 18, color: CommonColors.materialBlue),
          ],
        ),
      ),
    );
  }
}
