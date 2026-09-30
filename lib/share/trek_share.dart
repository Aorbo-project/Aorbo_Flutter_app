import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../controller/trek_controller.dart';
import '../freezed_models/treks/trek_detail_model.dart' show TrekDetailData;
import '../freezed_models/treks/treks_model_data.dart' show TrekData;
import '../screens/trek_details_screen.dart';
import '../utils/custom_snackbar.dart';
import 'trek_link.dart';

/// Share button on the trek screen: the phone's own share sheet, so every
/// installed app (Messages, WhatsApp, Instagram, Snapchat, Gmail…) is offered.
class TrekShare {
  TrekShare._();

  static Future<void> share({required TrekLink link, required String title, String? startDate}) async {
    await Share.share(
      TrekShareText.build(title: title, startDate: startDate, link: link.toUri()),
      subject: title.trim().isEmpty ? 'A trek on Aorbo Treks' : '${title.trim()} on Aorbo Treks',
    );
  }
}

/// Opens the trek a shared link points to.
class TrekLinkOpener {
  TrekLinkOpener._();

  static bool _opening = false;

  /// A shared date that has passed or no longer exists falls back to the
  /// trek's next upcoming one; a trek that is no longer live gets a plain
  /// message, not an error.
  static Future<void> open(TrekLink link) async {
    if (_opening) return;
    _opening = true;
    try {
      final trekC = Get.find<TrekController>();
      trekC.trekDetailId.value = link.trekId;
      var ok = await trekC.trekDetail(
          batchId: link.batchId ?? 0, cityId: link.cityId, showErrors: false);
      final shared = trekC.trekDetailData.value;
      if (ok && link.batchId != null &&
          (shared.batchId == null || TrekLink.isPastDate(shared.startDate))) {
        ok = await trekC.trekDetail(batchId: 0, cityId: link.cityId, showErrors: false);
      }
      final data = trekC.trekDetailData.value;
      if (!ok || data.id != link.trekId) {
        final ctx = Get.context;
        if (ctx != null && ctx.mounted) {
          CustomSnackBar.show(ctx, message: "This trek isn't available any more.");
        }
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
