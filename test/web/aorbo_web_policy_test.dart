import 'package:arobo_app/legal/legal_service.dart';
import 'package:arobo_app/web/aorbo_web_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('decideWebNavigation', () {
    WebNavDecision decide(String url, {String? home}) =>
        decideWebNavigation(Uri.parse(url), home: home == null ? null : Uri.parse(home));

    test("Aorbo's website opens in the app", () {
      expect(decide('https://aorbotreks.com/terms'), WebNavDecision.allow);
      expect(decide('https://www.aorbotreks.com/privacy-policy'), WebNavDecision.allow);
      expect(decide('https://AORBOTREKS.com/refund-policy'), WebNavDecision.allow);
    });

    test('the host the server gave for the document opens in the app too', () {
      expect(
        decide('https://legal.example.in/terms', home: 'https://legal.example.in/terms'),
        WebNavDecision.allow,
      );
    });

    test('other sites, e-mail and phone links open outside the app', () {
      expect(decide('https://www.google.com/'), WebNavDecision.openExternally);
      expect(decide('http://aorbotreks.com/terms'), WebNavDecision.openExternally);
      expect(decide('mailto:care@aorbotreks.com'), WebNavDecision.openExternally);
      expect(decide('tel:112'), WebNavDecision.openExternally);
    });

    test('everything else is dropped', () {
      expect(decide('intent://scan/#Intent;scheme=zxing;end'), WebNavDecision.block);
      expect(decide('file:///data/data/com.aorbotreks.app/x'), WebNavDecision.block);
      expect(decide('javascript:alert(1)'), WebNavDecision.block);
    });
  });

  test("the app view hides the site's menu, footer, cookie banner and loading bar", () {
    expect(
      kAppViewCss,
      startsWith('.site-nav,.site-footer,#cookie-banner,.route-progress{display:none!important}'),
    );
    // The document itself is resized, never hidden.
    for (final content in ['.legal', '.prose', '.blog-card', '.page-title']) {
      expect(RegExp('(^|[},])${RegExp.escape(content)}[^{]*\\{display:none').hasMatch(kAppViewCss), isFalse);
    }
  });

  test('the style is injected inside a single-quoted JS string, so it may hold no quote or backslash', () {
    expect(kAppViewCss.contains("'"), isFalse);
    expect(kAppViewCss.contains(r'\'), isFalse);
    expect(kAppViewScript, contains(kAppViewCss));
  });

  test("text zoom follows the phone's font setting within the app's 1.0–1.15× range", () {
    expect(appViewTextZoom(1.0), 100);
    expect(appViewTextZoom(1.1), 110);
    expect(appViewTextZoom(1.3), 115);
    expect(appViewTextZoom(2.0), 115);
    expect(appViewTextZoom(0.85), 100);
  });

  test('legalTitleFor finds the built-in titles by key or URL', () {
    expect(legalTitleFor(key: 'refund'), 'Refund & Cancellation Policy');
    expect(legalTitleFor(url: 'https://aorbotreks.com/privacy-policy'), 'Privacy Policy');
    expect(legalTitleFor(key: 'nope'), 'Legal');
  });
}
