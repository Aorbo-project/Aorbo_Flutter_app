import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../controller/coupon_controller.dart';
import '../controller/dashboard_controller.dart';
import '../controller/trek_controller.dart';
import '../controller/user_controller.dart';
import '../freezed_models/treks/trek_detail_model.dart' show TrekDetailData;
import '../freezed_models/treks/treks_model_data.dart' show TrekData;
import '../repository/trek_share_repository.dart';
import '../screens/trek_details_screen.dart';
import '../services/app_feedback.dart';
import 'trek_link.dart';

/// Share button on the trek screen: the phone's own share sheet, so every
/// installed app (Messages, WhatsApp, Instagram, Snapchat, Gmail…) is offered.
class TrekShare {
  TrekShare._();

  static bool _sharing = false;

  /// Asks the server for this trek card's link code, then opens the share
  /// sheet. Shows its own message if the link can't be made.
  static Future<void> share({
    required int trekId,
    int? batchId,
    int? cityId,
    required String title,
    String? startDate,
  }) async {
    if (_sharing) return;
    _sharing = true;
    try {
      final link = await TrekShareRepository().createLink(trekId: trekId, batchId: batchId, cityId: cityId);
      await Share.share(
        TrekShareText.build(title: title, startDate: startDate, link: link.toUri()),
        subject: title.trim().isEmpty ? 'A trek on Aorbo Treks' : '${title.trim()} on Aorbo Treks',
      );
    } catch (e) {
      AppFeedback.error(e is String ? e : 'Unable to share at the moment. Please try again.');
    } finally {
      _sharing = false;
    }
  }
}

/// Opens the trek a shared link points to.
class TrekLinkOpener {
  TrekLinkOpener._();

  static bool _opening = false;

  /// The trek page needs these, and a guest hasn't reached the dashboard
  /// that normally creates them.
  static void _ensureTrekScreenControllers() {
    if (!Get.isRegistered<DashboardController>()) Get.put(DashboardController(), permanent: true);
    if (!Get.isRegistered<TrekController>()) Get.put(TrekController(), permanent: true);
    if (!Get.isRegistered<CouponController>()) Get.put(CouponController(), permanent: true);
    if (!Get.isRegistered<UserController>()) Get.put(UserController(), permanent: true);
  }

  /// Link before login: the trek page alone, with Continue leading to login.
  static Future<void> openAsGuest(TrekLink link) async {
    _ensureTrekScreenControllers();
    final opened = await open(link, guest: true);
    // Nothing to return to after login.
    if (!opened) await PendingTrekLink.clear();
  }

  /// Resolves the link's code on the server, then opens that trek. A shared
  /// date that has passed or no longer exists falls back to the trek's next
  /// upcoming one; an unknown code, a trek with no upcoming date or a trek
  /// that is no longer live gets a plain message, not an error.
  static Future<bool> open(
    TrekLink link, {
    bool guest = false,
    TrekBookingResume? resume,
  }) async {
    if (_opening) return false;
    _opening = true;
    try {
      final target = await TrekShareRepository().resolve(link);
      if (target == null) {
        AppFeedback.warning("This trek isn't available any more.");
        return false;
      }
      final trekC = Get.find<TrekController>();
      trekC.trekDetailId.value = target.trekId;
      var ok = await trekC.trekDetail(
          batchId: target.batchId ?? 0, cityId: target.cityId, showErrors: false);
      final shared = trekC.trekDetailData.value;
      if (ok && target.batchId != null &&
          (shared.batchId == null || TrekLink.isPastDate(shared.startDate))) {
        ok = await trekC.trekDetail(batchId: 0, cityId: target.cityId, showErrors: false);
      }
      final data = trekC.trekDetailData.value;
      if (!ok || data.id != target.trekId || TrekLink.isPastDate(data.startDate)) {
        AppFeedback.warning("This trek isn't available any more.");
        return false;
      }
      if (resume?.boardingCityId != null) {
        trekC.selectedBoardingCityId.value = resume!.boardingCityId;
      }
      Get.to(() => TrekDetailsScreen(trek: cardFor(data), guest: guest, autoContinue: resume != null));
      return true;
    } finally {
      _opening = false;
    }
  }

  /// The search-card fields the trek screen's header reads, built from the
  /// full detail (a link has no search card behind it).
  static TrekData cardFor(TrekDetailData d) => TrekData(
        id: d.id,
        name: d.title,
        destination: d.destinationData?.name,
        companyName: d.vendor?.businessName,
        vendorLogo: d.vendor?.businessLogo,
        duration: d.duration,
        imageUrl: (d.images ?? const []).isNotEmpty ? d.images!.first.url : null,
      );
}
