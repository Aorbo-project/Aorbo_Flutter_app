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

/// The in-app look of a website page (applied only inside the app — the
/// website itself is unchanged):
///
/// 1. Hides the site's own menu, footer, cookie banner and page-loading bar,
///    so only the document shows under the app's header.
/// 2. Phone sizes: the site is sized for a desktop (16–17 px body, 44 px
///    titles, big section gaps); these bring headings, text, gaps and images
///    down to the app's scale. Tried on a 384-px-wide phone (Terms, the blog
///    list, a blog post) before shipping.
///
/// Class names come from the aorbotreks.com site (React-web: Navbar.jsx,
/// Footer.jsx, CookieBanner.jsx, Layout.jsx, PageHeader.jsx, BlogCard.jsx,
/// BlogDetail.jsx, LegalPage.jsx, styles/*.css). If the site renames them the
/// page still shows, just with the website's own menu and sizes.
const String kAppViewCss =
    '.site-nav,.site-footer,#cookie-banner,.route-progress{display:none!important}'
    ':root{--nav-h:0px!important;--fs-base:0.875rem!important;--fs-lg:0.9375rem!important;'
    '--fs-h1:1.375rem!important;--fs-h2:1.125rem!important;--fs-h3:1rem!important;'
    '--fs-display:1.625rem!important;--section-y:1.25rem!important;--gutter:1rem!important}'
    'body{font-size:0.875rem!important;line-height:1.55!important}'
    'h1{font-size:1.375rem!important}h2{font-size:1.125rem!important}'
    'h3{font-size:1rem!important}h4{font-size:0.95rem!important}'
    // Page header (blog list / post)
    '.page-header{padding:1rem 0 0.875rem!important;margin-bottom:1rem!important}'
    '.page-header__back{margin-bottom:0.75rem!important}'
    '.eyebrow{font-size:0.6875rem!important;margin-bottom:0.375rem!important}'
    '.page-title{font-size:1.375rem!important;line-height:1.25!important}'
    '.page-subtitle{font-size:0.875rem!important;margin-top:0.375rem!important}'
    // Blog list + post
    '.grid-cards{gap:0.875rem!important}'
    '.blog-card__media{aspect-ratio:2/1!important}'
    '.blog-card__body{padding:0.75rem 0.875rem 0.875rem!important}'
    '.blog-card__date{font-size:0.6875rem!important}'
    '.blog-card__title{font-size:0.9375rem!important}'
    '.blog-card__excerpt{font-size:0.8125rem!important;line-height:1.5!important}'
    '.blog-post__meta{font-size:0.8125rem!important}'
    '.blog-post__cover{aspect-ratio:16/9!important;margin-bottom:0.875rem!important}'
    '.blog-post__article{padding:1rem!important}'
    '.prose{font-size:0.875rem!important;line-height:1.6!important}'
    '.prose h1{font-size:1.125rem!important;margin:0 0 0.625rem!important}'
    '.prose h2{font-size:1rem!important;margin:1.25rem 0 0.375rem!important}'
    '.prose h3{font-size:0.9375rem!important;margin:1rem 0 0.375rem!important}'
    '.prose p{margin:0 0 0.625rem!important}'
    // Legal documents
    '.legal-doc{padding:1rem 0 1.5rem!important}'
    '.legal-doc__header{margin-bottom:1rem!important}'
    '.legal-doc__title{font-size:1.125rem!important}'
    '.legal-doc__audience{font-size:0.8125rem!important}'
    '.legal-doc__meta{font-size:0.75rem!important}'
    '.legal-doc__notice{font-size:0.625rem!important;margin-bottom:1.25rem!important}'
    '.legal{font-size:0.8125rem!important;line-height:1.6!important}'
    '.legal h3{font-size:0.875rem!important;margin:1.25rem 0 0.5rem!important}'
    '.legal h4,.legal h5{font-size:0.8125rem!important}'
    '.legal p{margin:0 0 0.625rem!important}'
    '.legal .legal-table table{font-size:0.75rem!important}';

/// Adds [kAppViewCss] to the page once. Idempotent (safe to run on every
/// progress tick).
const String kAppViewScript = '''
(function () {
  var id = 'aorbo-app-view';
  if (document.getElementById(id)) return;
  var s = document.createElement('style');
  s.id = id;
  s.textContent = '$kAppViewCss';
  (document.head || document.documentElement).appendChild(s);
})();
''';

/// Android text zoom for the page: the phone's font-size setting, held to the
/// same 1.0–1.15× range the app's own text uses (main.dart), so a large
/// system font can't blow the page up beyond the rest of the app.
int appViewTextZoom(double systemTextScale) =>
    (systemTextScale.clamp(1.0, 1.15) * 100).round();
