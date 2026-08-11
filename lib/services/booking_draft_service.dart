// lib/services/booking_draft_service.dart
//
// Persists in-progress booking selections (trek, batch, boarding city,
// selected traveller IDs) BEFORE an order is created. This is distinct
// from SpUtil.pendingOrderId, which only covers the post-order-creation /
// mid-payment window. Without this, a user who picks a batch and selects
// travellers, then gets interrupted (call, app killed, low battery),
// loses everything and has to start over from scratch.
//
// Design note: Traveler objects (from freezed_models/profile/user_profile_model.dart)
// are references to the user's already-saved profile travellers — they
// aren't booking-specific data. So we only persist their IDs, and re-resolve
// the full Traveler objects against UserController.userProfileData on resume.
// This avoids needing Traveler.toJson()/fromJson() entirely.
//
// INTEGRATION POINTS (see accompanying notes for exact call sites):
//   1. Call save(trekC) in TravellerInformationScreen whenever
//      _trekC.travellerDetailList is updated (checkbox toggle, counter
//      change, _autoSelectNewestTraveller) - i.e. right after every
//      `_trekC.travellerDetailList.value = List.from(selectedTravellers);`
//   2. Call checkAndResume(trekC, userC) from DashboardMain.initState(),
//      next to the existing checkPendingOrderOnResume() call.
//   3. Call clear() in TrekController.createTrekOrder() success branch
//      (same place pendingOrderId gets persisted) and in clearBookingData().

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../controller/trek_controller.dart';
import '../controller/user_controller.dart';
import '../utils/shared_preferences.dart';
import '../theme/app_tokens.dart';
import '../theme/app_typography.dart';
import 'app_dialog.dart';
import '../widgets/trek_card_ui.dart';
import '../widgets/logger.dart';

class BookingDraftService {
  BookingDraftService._();

  static const String _draftKey = 'booking_draft_v1';

  /// Drafts older than this are discarded rather than offered for resume -
  /// batch pricing/availability may have changed.
  static const Duration _maxAge = Duration(hours: 12);

  /// Save the current in-progress booking selection.
  /// Call this every time travellerDetailList or the batch selection changes.
  static Future<void> save(TrekController c) async {
    // Nothing worth resuming until a trek + batch is actually selected.
    if (c.trekDetailId.value == 0 || c.trekBatchId.value == 0) return;

    try {
      final travelerIds = c.travellerDetailList
          .map((t) => t.id)
          .whereType<int>()
          .toList();

      final draft = {
        'savedAt': DateTime.now().toIso8601String(),
        'trekDetailId': c.trekDetailId.value,
        'trekBatchId': c.trekBatchId.value,
        'selectedBoardingCityId': c.selectedBoardingCityId.value,
        'trekPersonCount': c.trekPersonCount.value,
        'travelerIds': travelerIds,
      };
      final pref = await SpUtil.getInstance();
      await pref.putString(_draftKey, json.encode(draft));
    } catch (_) {
      // Never let draft-saving crash the booking flow itself.
    }
  }

  /// Clears any saved draft - call on successful order creation
  /// (createTrekOrder success) and in clearBookingData().
  static Future<void> clear() async {
    try {
      final pref = await SpUtil.getInstance();
      await pref.remove(_draftKey);
    } catch (e, st) {
      logger.w('BookingDraftService: failed to clear draft', error: e, stackTrace: st);
    }
  }

  /// Checks for a saved draft and, if found and not stale, re-fetches the
  /// trek's details and shows a bottom sheet with a trek preview + Close /
  /// Continue Booking actions. On continue, re-populates travellerDetailList
  /// by matching saved IDs against the user's current profile travellers.
  ///
  /// Returns true if a draft was restored (caller should then navigate to
  /// TravellerInformationScreen - its initState reads travellerDetailList
  /// automatically, no further wiring needed there).
  static Future<bool> checkAndResume(
    TrekController trekC,
    UserController userC,
  ) async {
    try {
      final pref = await SpUtil.getInstance();
      final raw = pref.getString(_draftKey);
      if (raw == null || raw.isEmpty) return false;

      final Map<String, dynamic> draft = json.decode(raw);
      final savedAt = DateTime.tryParse(draft['savedAt'] ?? '');
      if (savedAt == null || DateTime.now().difference(savedAt) > _maxAge) {
        await clear();
        return false;
      }

      final travelerIds = (draft['travelerIds'] as List?)?.cast<int>() ?? [];
      if (travelerIds.isEmpty) {
        await clear();
        return false;
      }

      final trekDetailId = draft['trekDetailId'] ?? 0;
      final batchId = draft['trekBatchId'] ?? 0;

      // Re-fetch trek details BEFORE showing anything - the preview needs
      // real title/dates, and fare/availability may have changed since the
      // draft was saved, so we never trust cached data across a resume.
      trekC.trekDetailId.value = trekDetailId;
      trekC.trekBatchId.value = batchId;
      await trekC.trekDetail(batchId: batchId);

      final confirmed = await AppSheet.show<bool>(
        child: _BookingResumeSheetContent(
          trekC: trekC,
          travelerCount: travelerIds.length,
        ),
      );

      if (confirmed != true) {
        await clear();
        return false;
      }

      trekC.selectedBoardingCityId.value = draft['selectedBoardingCityId'];
      trekC.trekPersonCount.value = draft['trekPersonCount'] ?? 0;

      // Resolve traveler IDs against the user's current saved profile
      // travellers - if one was deleted since the draft was saved, it's
      // silently dropped rather than crashing the restore.
      final allTravelers =
          userC.userProfileData.value.customer?.travelers ?? const [];
      final restored = allTravelers
          .where((t) => t.id != null && travelerIds.contains(t.id))
          .toList();
      trekC.travellerDetailList.value = restored;

      return true;
    } catch (_) {
      return false;
    }
  }
}

// ─────────────────────────────────────────────
//  RESUME SHEET CONTENT
//  Uses the real TrekCardUI (extracted to lib/widgets/trek_card_ui.dart)
//  so the resume preview looks identical to the checkout screen's trip
//  summary card, rather than a separate hand-built preview.
// ─────────────────────────────────────────────
class _BookingResumeSheetContent extends StatelessWidget {
  final TrekController trekC;
  final int travelerCount;
  const _BookingResumeSheetContent({
    required this.trekC,
    required this.travelerCount,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final data = trekC.trekDetailData.value;
      final isFlexible = data.cancellationPolicy?.id == 5;
      final durationText =
          '${data.durationDays ?? 0}D | ${data.durationNights ?? 0}N';
      final price = '₹${data.basePrice ?? '0'}';
      // TrekDetailData has no imageUrl/image field - only `images` (a list
      // with an isCover flag). Pick the cover image, falling back to the
      // first image if none is flagged.
      final coverImage = () {
        final imgs = data.images ?? const [];
        if (imgs.isEmpty) return null;
        final cover = imgs.where((i) => i.isCover == true);
        return cover.isNotEmpty ? cover.first.url : imgs.first.url;
      }();

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Continue your booking?',
            style: AppType.style(
              15,
              w: FontWeight.w700,
              color: AppColors.inkStrong,
            ),
          ),
          SizedBox(height: 0.6.h),
          Text(
            'You left this trek booking in progress with $travelerCount '
            'traveller${travelerCount > 1 ? 's' : ''} selected.',
            style: AppType.style(11, color: AppColors.inkMid),
          ),
          SizedBox(height: 2.h),
          TrekCardUI(
            title: data.title ?? 'Trek',
            vendorName: data.vendor?.user?.name ?? 'Aorbo Treks',
            isFlexible: isFlexible,
            badgeText: data.badge?.name ?? '',
            durationText: durationText,
            rating: data.averageRating,
            departure: data.startDate ?? '-',
            availableSlots: data.availableSlots ?? 0,
            totalCapacity: data.capacity ?? 0,
            price: price,
            imageUrl: coverImage,
            vendorLogo: data.vendor?.businessLogo,
          ),
          SizedBox(height: 2.5.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Get.back(result: false),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 1.4.h),
                    side: BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  child: Text(
                    'Close',
                    style: AppType.style(
                      12,
                      w: FontWeight.w600,
                      color: AppColors.inkMid,
                    ),
                  ),
                ),
              ),
              SizedBox(width: AppSpace.hMd),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () => Get.back(result: true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.forest,
                    padding: EdgeInsets.symmetric(vertical: 1.4.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Continue Booking',
                    style: AppType.style(
                      12,
                      w: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    });
  }
}
