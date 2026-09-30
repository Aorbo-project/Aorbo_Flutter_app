import 'package:arobo_app/legal/legal_documents.dart';
import 'package:flutter_test/flutter_test.dart';

import 'legal_fixtures.dart';

void main() {
  group('parseLegalDocuments', () {
    test('reads the server list — keys, titles, URLs, versions, flags', () {
      final docs = parseLegalDocuments(documentsReply());
      expect(docs.map((d) => d.key), ['terms', 'privacy', 'user_agreement', 'refund']);
      expect(docs.first.title, 'Terms & Conditions');
      expect(docs.first.url, 'https://aorbotreks.com/terms');
      expect(docs.first.version, '2026-09-30');
      expect(docs.where((d) => d.requiresAcceptance).map((d) => d.key), ['terms', 'privacy']);
    });

    test('accepts the data map or the bare list too', () {
      final body = documentsReply();
      expect(parseLegalDocuments(body['data']), hasLength(4));
      expect(parseLegalDocuments((body['data'] as Map)['documents']), hasLength(4));
    });

    test('drops entries it cannot safely open, and repeated keys', () {
      final docs = parseLegalDocuments({
        'data': {
          'documents': [
            {'key': 'terms', 'title': 'Terms', 'url': 'https://aorbotreks.com/terms', 'version': 'v1'},
            {'key': 'terms', 'title': 'Terms again', 'url': 'https://evil.example/terms', 'version': 'v9'},
            {'key': 'x1', 'title': 'Script', 'url': 'javascript:alert(1)'},
            {'key': 'x2', 'title': 'Intent', 'url': 'intent://scan/#Intent;end'},
            {'key': 'x3', 'title': 'No url'},
            {'title': 'No key', 'url': 'https://aorbotreks.com/a'},
            {'key': '', 'title': 'Empty key', 'url': 'https://aorbotreks.com/b'},
            'not a map',
          ],
        },
      });
      expect(docs, hasLength(1));
      expect(docs.single.title, 'Terms');
    });

    test('garbage → empty list, never a throw', () {
      for (final body in [null, 'html', 42, <String, dynamic>{}, {'data': 'x'}, {'data': {'documents': 'x'}}]) {
        expect(parseLegalDocuments(body), isEmpty, reason: '$body');
      }
    });

    test('an entry that omits requiresAcceptance inherits it from the known list', () {
      final known = parseLegalDocuments(documentsReply());
      final docs = parseLegalDocuments({
        'documents': [
          {'key': 'terms', 'title': 'Terms & Conditions', 'url': 'https://aorbotreks.com/terms', 'version': 'v2'},
          {'key': 'new_doc', 'title': 'New', 'url': 'https://aorbotreks.com/new', 'version': 'v1'},
        ],
      }, inheritFrom: known);
      expect(docs[0].requiresAcceptance, isTrue);
      expect(docs[1].requiresAcceptance, isFalse);
    });

    test('toJson round-trips (the offline cache)', () {
      final docs = parseLegalDocuments(documentsReply());
      expect(parseLegalDocuments(docs.map((d) => d.toJson()).toList()), docs);
    });
  });

  group('fallback list', () {
    test('has the four documents, titles + URLs only — no versions', () {
      expect(fallbackLegalDocuments.map((d) => d.key), ['terms', 'privacy', 'user_agreement', 'refund']);
      expect(fallbackLegalDocuments.every((d) => d.version == null), isTrue);
      expect(fallbackLegalDocuments.every((d) => isOpenableLegalUrl(d.url)), isTrue);
    });

    test('can never be "accepted" — nothing to send', () {
      final asRequired = fallbackLegalDocuments
          .map((d) => LegalDocument(key: d.key, title: d.title, url: d.url, requiresAcceptance: true))
          .toList();
      expect(documentsToAccept(asRequired), isEmpty);
    });
  });

  group('legalUrlFor / documentsForDisplay', () {
    test("the server's URL wins", () {
      final docs = parseLegalDocuments({
        'documents': [
          {'key': 'terms', 'title': 'T', 'url': 'https://aorbotreks.com/terms-v2', 'version': '2'},
        ],
      });
      expect(legalUrlFor('terms', docs), 'https://aorbotreks.com/terms-v2');
    });

    test('falls back to the built-in URL when the list is not loaded', () {
      expect(legalUrlFor('terms', const []), 'https://aorbotreks.com/terms');
      expect(legalUrlFor('privacy', const []), 'https://aorbotreks.com/privacy-policy');
      expect(legalUrlFor('refund', const []), 'https://aorbotreks.com/refund-policy');
    });

    test('unknown key → null', () {
      expect(legalUrlFor('nope', parseLegalDocuments(documentsReply())), isNull);
    });

    test('Profile shows the server list, or the fallback offline', () {
      final docs = parseLegalDocuments(documentsReply());
      expect(documentsForDisplay(docs), docs);
      expect(documentsForDisplay(const []), fallbackLegalDocuments);
    });
  });

  group('documentsToAccept', () {
    test('every document that requires acceptance, at its current version', () {
      expect(documentsToAccept(parseLegalDocuments(documentsReply(termsVersion: 't3', privacyVersion: 'p2'))), [
        {'key': 'terms', 'version': 't3'},
        {'key': 'privacy', 'version': 'p2'},
      ]);
    });

    test('a required document with no version is not sent', () {
      final docs = [
        const LegalDocument(key: 'terms', title: 'T', url: 'https://a.b/t', requiresAcceptance: true),
        const LegalDocument(key: 'privacy', title: 'P', url: 'https://a.b/p', version: 'p1', requiresAcceptance: true),
      ];
      expect(documentsToAccept(docs), [
        {'key': 'privacy', 'version': 'p1'},
      ]);
    });

    test('adds a document the status still wants but the list lacks — once', () {
      final status = LegalStatus.fromJson({
        'data': {
          'needsAcceptance': true,
          'documents': [
            {'key': 'terms', 'version': 'OTHER', 'needsAcceptance': true},
            {'key': 'community', 'version': 'c1', 'needsAcceptance': true},
            {'key': 'refund', 'version': 'r1', 'needsAcceptance': false},
          ],
        },
      });
      expect(documentsToAccept(parseLegalDocuments(documentsReply()), status: status), [
        {'key': 'terms', 'version': '2026-09-30'},
        {'key': 'privacy', 'version': '2026-09-30'},
        {'key': 'community', 'version': 'c1'},
      ]);
    });
  });

  group('buildAcceptBody', () {
    test('matches POST customer/legal/accept', () {
      final docs = documentsToAccept(parseLegalDocuments(documentsReply()));
      expect(buildAcceptBody(docs, source: LegalAcceptSource.login, appVersion: '1.0.0+22'), {
        'documents': [
          {'key': 'terms', 'version': '2026-09-30'},
          {'key': 'privacy', 'version': '2026-09-30'},
        ],
        'source': 'login',
        'appVersion': '1.0.0+22',
      });
      expect(LegalAcceptSource.updatePrompt, 'update_prompt');
    });

    test('leaves appVersion out when unknown', () {
      expect(buildAcceptBody(const [], source: 'login', appVersion: null).containsKey('appVersion'), isFalse);
    });

    test('pubspecVersion joins version + build number', () {
      expect(pubspecVersion('1.0.0', '22'), '1.0.0+22');
      expect(pubspecVersion('1.0.0', ''), '1.0.0');
      expect(pubspecVersion(null, '22'), isNull);
    });
  });

  group('interpretAcceptReply', () {
    final statusBody = {
      'success': true,
      'data': {
        'needsAcceptance': false,
        'documents': [
          {
            'key': 'terms',
            'title': 'Terms & Conditions',
            'url': 'https://aorbotreks.com/terms',
            'version': '2026-09-30',
            'acceptedVersion': '2026-09-30',
            'needsAcceptance': false,
          },
        ],
      },
    };

    test('200 success → accepted, with the new status', () {
      final r = interpretAcceptReply(200, statusBody);
      expect(r.outcome, LegalAcceptOutcome.accepted);
      expect(r.isAccepted, isTrue);
      expect(r.status!.needsAcceptance, isFalse);
      expect(r.status!.documents.single.acceptedVersion, '2026-09-30');
    });

    test('409 LEGAL_VERSION_OUTDATED → outdated, with the current list', () {
      final known = parseLegalDocuments(documentsReply());
      final r = interpretAcceptReply(409, {
        'success': false,
        'code': 'LEGAL_VERSION_OUTDATED',
        'data': {
          'documents': [
            // requiresAcceptance omitted → taken from the known list
            {'key': 'terms', 'title': 'Terms & Conditions', 'url': 'https://aorbotreks.com/terms', 'version': '2026-10-15'},
          ],
        },
      }, known: known);
      expect(r.outcome, LegalAcceptOutcome.outdated);
      expect(r.currentDocuments.single.version, '2026-10-15');
      expect(r.currentDocuments.single.requiresAcceptance, isTrue);
    });

    test('a different 409, 4xx, or success:false → failed with the server message', () {
      expect(interpretAcceptReply(409, {'success': false, 'code': 'OTHER'}).outcome, LegalAcceptOutcome.failed);
      final bad = interpretAcceptReply(400, {'success': false, 'message': 'documents is required'});
      expect(bad.outcome, LegalAcceptOutcome.failed);
      expect(bad.message, 'documents is required');
      expect(interpretAcceptReply(200, {'success': false}).message, legalAcceptGenericError);
      expect(interpretAcceptReply(200, 'not json').outcome, LegalAcceptOutcome.failed);
    });
  });

  group('mergeLegalDocuments', () {
    test('same key replaced in place, new key appended', () {
      final known = parseLegalDocuments(documentsReply());
      const newTerms = LegalDocument(key: 'terms', title: 'Terms', url: 'https://aorbotreks.com/terms', version: 'v2', requiresAcceptance: true);
      const extra = LegalDocument(key: 'extra', title: 'Extra', url: 'https://aorbotreks.com/extra', version: 'e1');
      final merged = mergeLegalDocuments(known, [extra, newTerms]);
      expect(merged.map((d) => d.key), ['terms', 'privacy', 'user_agreement', 'refund', 'extra']);
      expect(merged.first.version, 'v2');
      expect(mergeLegalDocuments(known, const []), known);
    });
  });

  group('LegalStatus', () {
    test('parses GET customer/legal/status', () {
      final s = LegalStatus.fromJson({
        'success': true,
        'data': {
          'needsAcceptance': true,
          'documents': [
            {
              'key': 'privacy',
              'title': 'Privacy Policy',
              'url': 'https://aorbotreks.com/privacy-policy',
              'version': '2026-10-01',
              'acceptedVersion': null,
              'needsAcceptance': true,
            },
          ],
        },
      })!;
      expect(s.needsAcceptance, isTrue);
      expect(s.documents.single.key, 'privacy');
      expect(s.documents.single.acceptedVersion, isNull);
    });

    test('malformed → null (the check stays silent)', () {
      for (final body in [null, 'x', <String, dynamic>{}, {'data': {'documents': []}}, {'data': {'needsAcceptance': 'yes'}}]) {
        expect(LegalStatus.fromJson(body), isNull, reason: '$body');
      }
    });
  });

  group('documentsForPrompt', () {
    final loaded = parseLegalDocuments(documentsReply());

    test('links the documents the status says need agreeing to', () {
      final status = LegalStatus.fromJson({
        'data': {
          'needsAcceptance': true,
          'documents': [
            {'key': 'terms', 'title': 'Terms & Conditions', 'url': 'https://aorbotreks.com/terms', 'version': 'v2', 'needsAcceptance': true},
            {'key': 'privacy', 'title': 'Privacy Policy', 'url': 'https://aorbotreks.com/privacy-policy', 'version': 'p1', 'needsAcceptance': false},
          ],
        },
      })!;
      expect(documentsForPrompt(status, loaded).map((d) => d.key), ['terms']);
    });

    test('a status document without a URL uses the known one', () {
      final status = LegalStatus.fromJson({
        'data': {
          'needsAcceptance': true,
          'documents': [
            {'key': 'privacy', 'title': 'Privacy Policy', 'version': 'p2', 'needsAcceptance': true},
          ],
        },
      })!;
      expect(documentsForPrompt(status, loaded).single.url, 'https://aorbotreks.com/privacy-policy');
    });

    test('names none → every required document; nothing loaded → built-in Terms + Privacy', () {
      const status = LegalStatus(needsAcceptance: true, documents: []);
      expect(documentsForPrompt(status, loaded).map((d) => d.key), ['terms', 'privacy']);
      expect(documentsForPrompt(status, const []).map((d) => d.key), ['terms', 'privacy']);
    });
  });

  group('shouldShowLegalPrompt', () {
    const needs = LegalStatus(needsAcceptance: true, documents: []);
    const upToDate = LegalStatus(needsAcceptance: false, documents: []);

    test('only for a logged-in user who needs to agree and has not been asked this run', () {
      expect(shouldShowLegalPrompt(loggedIn: true, status: needs, alreadyShownThisSession: false), isTrue);
      expect(shouldShowLegalPrompt(loggedIn: false, status: needs, alreadyShownThisSession: false), isFalse);
      expect(shouldShowLegalPrompt(loggedIn: true, status: needs, alreadyShownThisSession: true), isFalse);
      expect(shouldShowLegalPrompt(loggedIn: true, status: upToDate, alreadyShownThisSession: false), isFalse);
      expect(shouldShowLegalPrompt(loggedIn: true, status: null, alreadyShownThisSession: false), isFalse);
    });
  });
}
