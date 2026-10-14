/// Rules for the in-app legal document view (LegalDocumentScreen). Pure, so
/// they are unit-tested without a WebView.
library;

/// The customer agreement lives on aorbotreks.com (both spellings serve it).
const Set<String> kLegalWebHosts = {'aorbotreks.com', 'www.aorbotreks.com'};

enum LegalNavAction { allow, openExternally, block }

/// What to do when the document page tries to open [uri].
///
/// Aorbo's website (or the host the server gave for this document, [home])
/// loads in the app; any other web link, e-mail or phone link opens outside
/// the app; every other scheme (intent:, file:, javascript:, …) is dropped.
LegalNavAction decideLegalNavigation(Uri uri, {Uri? home}) {
  final scheme = uri.scheme.toLowerCase();
  final host = uri.host.toLowerCase();
  if (scheme == 'https' &&
      (kLegalWebHosts.contains(host) || (home != null && host == home.host.toLowerCase()))) {
    return LegalNavAction.allow;
  }
  if (scheme == 'https' || scheme == 'http' || scheme == 'mailto' || scheme == 'tel') {
    return LegalNavAction.openExternally;
  }
  return LegalNavAction.block;
}

/// Hides the website's own menu, footer, cookie banner and page-loading bar,
/// so only the document shows under the app's header. Idempotent (safe to run
/// on every progress tick). Class names come from the aorbotreks.com site
/// (React-web: Navbar.jsx `.site-nav`, Footer.jsx `.site-footer`,
/// CookieBanner.jsx `#cookie-banner`, Layout.jsx `.route-progress`); if the
/// site renames them the document still shows, just with its menu.
const String kLegalHideSiteChromeScript = r'''
(function () {
  var id = 'aorbo-app-legal-view';
  if (document.getElementById(id)) return;
  var s = document.createElement('style');
  s.id = id;
  s.textContent =
    '.site-nav,.site-footer,#cookie-banner,.route-progress{display:none!important}' +
    ':root{--nav-h:0px!important}';
  (document.head || document.documentElement).appendChild(s);
})();
''';
