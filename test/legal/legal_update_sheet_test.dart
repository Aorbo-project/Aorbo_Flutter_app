import 'package:arobo_app/legal/legal_documents.dart' show legalAcceptNetworkError;
import 'package:arobo_app/legal/legal_links_text.dart';
import 'package:arobo_app/legal/legal_service.dart';
import 'package:arobo_app/legal/legal_update_sheet.dart';
import 'package:arobo_app/repository/repository.dart' show ApiReply;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import 'legal_fixtures.dart';

Map<String, dynamic> _needs(bool needs, {String termsVersion = '2026-09-30'}) => {
      'success': true,
      'data': {
        'needsAcceptance': needs,
        'documents': [
          {
            'key': 'terms',
            'title': 'Terms & Conditions',
            'url': 'https://aorbotreks.com/terms',
            'version': termsVersion,
            'acceptedVersion': null,
            'needsAcceptance': needs,
          },
          {
            'key': 'privacy',
            'title': 'Privacy Policy',
            'url': 'https://aorbotreks.com/privacy-policy',
            'version': '2026-09-30',
            'acceptedVersion': null,
            'needsAcceptance': needs,
          },
        ],
      },
    };

Widget _app(Widget home) => Sizer(
      builder: (context, orientation, deviceType) => GetMaterialApp(home: home),
    );

void main() {
  late FakeLegalApi api;
  late bool loggedIn;
  final original = LegalService.instance;

  setUp(() {
    Get.testMode = true;
    api = FakeLegalApi()..status = _needs(true);
    loggedIn = true;
    LegalService.instance = LegalService(
      api: api,
      appVersion: () async => '1.0.0+22',
      isLoggedIn: () => loggedIn,
      currentUserId: () => 1,
    );
  });

  tearDown(() {
    LegalService.instance = original;
    Get.reset();
  });

  testWidgets('sign-in links: two separate tappable spans', (tester) async {
    await tester.pumpWidget(_app(const Scaffold(
      body: LegalLinksText(linkStyle: TextStyle(), separatorStyle: TextStyle()),
    )));
    final rich = tester.widget<RichText>(find.byType(RichText).last);
    final spans = <TextSpan>[];
    rich.text.visitChildren((s) {
      if (s is TextSpan && s.text != null) spans.add(s);
      return true;
    });
    expect(spans.map((s) => s.text), ['Terms & Conditions', ' | ', 'Privacy Policy']);
    expect(spans[0].recognizer, isA<TapGestureRecognizer>());
    expect(spans[1].recognizer, isNull);
    expect(spans[2].recognizer, isA<TapGestureRecognizer>());
    expect(identical(spans[0].recognizer, spans[2].recognizer), isFalse);
    // Disposing the screen disposes both recognizers without error.
    await tester.pumpWidget(_app(const SizedBox()));
  });

  testWidgets('update sheet: network error keeps it open; "I agree" then closes it', (tester) async {
    await tester.pumpWidget(_app(const Scaffold(body: SizedBox())));
    final shown = maybeShowLegalUpdatePrompt(settle: Duration.zero);
    await tester.pumpAndSettle();

    expect(find.text("We've updated our Terms & Conditions and Privacy Policy"), findsOneWidget);
    expect(find.text('Terms & Conditions'), findsOneWidget);
    expect(find.text('Privacy Policy'), findsOneWidget);

    // Back button can't dismiss it.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('I agree'), findsOneWidget);

    // Network error → message shown, sheet stays.
    api.acceptError = Exception('offline');
    await tester.tap(find.text('I agree'));
    await tester.pumpAndSettle();
    expect(find.text(legalAcceptNetworkError), findsOneWidget);
    expect(find.text('I agree'), findsOneWidget);

    // Success → closes.
    api.acceptError = null;
    await tester.tap(find.text('I agree'));
    await tester.pumpAndSettle();
    expect(find.text('I agree'), findsNothing);
    await shown;
    expect(api.acceptBodies.last['source'], 'update_prompt');
  });

  testWidgets('update sheet: a 409 asks again with the new version', (tester) async {
    await tester.pumpWidget(_app(const Scaffold(body: SizedBox())));
    maybeShowLegalUpdatePrompt(settle: Duration.zero);
    await tester.pumpAndSettle();

    api.acceptReplies.add(const ApiReply(409, {
      'success': false,
      'code': 'LEGAL_VERSION_OUTDATED',
      'data': {
        'documents': [
          {'key': 'terms', 'title': 'Terms & Conditions', 'url': 'https://aorbotreks.com/terms', 'version': '2026-10-15', 'requiresAcceptance': true},
        ],
      },
    }));
    // The server's status now reports the new Terms version too.
    api.status = _needs(true, termsVersion: '2026-10-15');
    await tester.tap(find.text('I agree'));
    await tester.pumpAndSettle();
    expect(find.textContaining('updated a moment ago'), findsOneWidget);
    expect(find.text('I agree'), findsOneWidget);

    await tester.tap(find.text('I agree'));
    await tester.pumpAndSettle();
    expect(find.text('I agree'), findsNothing);
    final sent = api.acceptBodies.last['documents'] as List;
    expect(sent.first, {'key': 'terms', 'version': '2026-10-15'});
  });

  testWidgets('nothing to agree to, or logged out → no sheet', (tester) async {
    await tester.pumpWidget(_app(const Scaffold(body: SizedBox())));
    api.status = _needs(false);
    maybeShowLegalUpdatePrompt(settle: Duration.zero);
    await tester.pumpAndSettle();
    expect(find.text('I agree'), findsNothing);

    api.status = _needs(true);
    loggedIn = false;
    maybeShowLegalUpdatePrompt(settle: Duration.zero);
    await tester.pumpAndSettle();
    expect(find.text('I agree'), findsNothing);
    expect(api.statusCalls, 1);
  });

  testWidgets('shown at most once per app run', (tester) async {
    await tester.pumpWidget(_app(const Scaffold(body: SizedBox())));
    maybeShowLegalUpdatePrompt(settle: Duration.zero);
    await tester.pumpAndSettle();
    await tester.tap(find.text('I agree'));
    await tester.pumpAndSettle();

    maybeShowLegalUpdatePrompt(settle: Duration.zero);
    await tester.pumpAndSettle();
    expect(find.text('I agree'), findsNothing);
    expect(api.statusCalls, 1);
  });
}
