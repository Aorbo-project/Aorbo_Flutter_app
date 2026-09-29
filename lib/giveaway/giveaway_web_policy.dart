import 'giveaway_config.dart';

enum WebNavAction {
  /// Load inside the giveaway screen.
  allow,

  /// Hand to the phone's browser / the matching app, outside Aorbo.
  openExternally,

  /// Drop it.
  block,
}

/// Which URLs the giveaway's in-app browser may load. Only Aorbo's own
/// campaign pages load inside the app (and only they can talk to it through
/// the bridge); ordinary web links leave for the phone's browser; everything
/// else (http, intent:, javascript:, file:, data:, …) is dropped.
class GiveawayWebPolicy {
  GiveawayWebPolicy._();

  static bool isCampaignPage(Uri uri) {
    if (uri.scheme != 'https') return false;
    if (uri.host.toLowerCase() != GiveawayConfig.webHost) return false;
    if (uri.hasPort && uri.port != 443) return false;
    if (uri.userInfo.isNotEmpty) return false;
    final path = uri.path;
    return path == GiveawayConfig.pathPrefix || path.startsWith('${GiveawayConfig.pathPrefix}/');
  }

  static WebNavAction decide(Uri uri) {
    if (isCampaignPage(uri)) return WebNavAction.allow;
    if (uri.scheme == 'https' && uri.host.isNotEmpty) return WebNavAction.openExternally;
    if (uri.scheme == 'mailto' || uri.scheme == 'tel') return WebNavAction.openExternally;
    return WebNavAction.block;
  }
}
