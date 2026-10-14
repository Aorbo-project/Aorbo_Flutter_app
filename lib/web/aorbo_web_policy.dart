/// Rules for the in-app view of Aorbo's website (AorboWebPageScreen: legal
/// documents, blog). Pure, so they are unit-tested without a WebView.
library;

/// Aorbo's customer website (both spellings serve it).
const Set<String> kAorboWebHosts = {'aorbotreks.com', 'www.aorbotreks.com'};

enum WebNavDecision { allow, openExternally, block }

/// What to do when the page tries to open [uri].
///
/// Aorbo's website (or the host of the page that was opened, [home])
/// loads in the app; any other web link, e-mail or phone link opens outside
/// the app; every other scheme (intent:, file:, javascript:, …) is dropped.
WebNavDecision decideWebNavigation(Uri uri, {Uri? home}) {
  final scheme = uri.scheme.toLowerCase();
  final host = uri.host.toLowerCase();
  if (scheme == 'https' &&
      (kAorboWebHosts.contains(host) || (home != null && host == home.host.toLowerCase()))) {
    return WebNavDecision.allow;
  }
  if (scheme == 'https' || scheme == 'http' || scheme == 'mailto' || scheme == 'tel') {
    return WebNavDecision.openExternally;
  }
  return WebNavDecision.block;
}

/// Hides the website's own menu, footer, cookie banner and page-loading bar,
/// so only the document shows under the app's header. Idempotent (safe to run
/// on every progress tick). Class names come from the aorbotreks.com site
/// (React-web: Navbar.jsx `.site-nav`, Footer.jsx `.site-footer`,
/// CookieBanner.jsx `#cookie-banner`, Layout.jsx `.route-progress`); if the
/// site renames them the document still shows, just with its menu.
const String kHideSiteChromeScript = r'''
(function () {
  var id = 'aorbo-app-view';
  if (document.getElementById(id)) return;
  var s = document.createElement('style');
  s.id = id;
  s.textContent =
    '.site-nav,.site-footer,#cookie-banner,.route-progress{display:none!important}' +
    ':root{--nav-h:0px!important}';
  (document.head || document.documentElement).appendChild(s);
})();
''';
