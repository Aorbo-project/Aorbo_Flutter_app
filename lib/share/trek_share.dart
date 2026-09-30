import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../controller/trek_controller.dart';
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

  /// Resolves the link's code on the server, then opens that trek. A shared
  /// date that has passed or no longer exists falls back to the trek's next
  /// upcoming one; an unknown code or a trek that is no longer live gets a
  /// plain message, not an error.
  static Future<void> open(TrekLink link) async {
    if (_opening) return;
    _opening = true;
    try {
      final target = await TrekShareRepository().resolve(link);
      if (target == null) {
        AppFeedback.warning("This trek isn't available any more.");
        return;
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
      if (!ok || data.id != target.trekId) {
        AppFeedback.warning("This trek isn't available any more.");
        return;
      }
      Get.to(() => TrekDetailsScreen(trek: cardFor(data)));
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
