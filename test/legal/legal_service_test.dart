import 'dart:async';

import 'package:arobo_app/legal/legal_documents.dart';
import 'package:arobo_app/legal/legal_service.dart';
import 'package:arobo_app/repository/repository.dart' show ApiReply;
import 'package:flutter_test/flutter_test.dart';

import 'legal_fixtures.dart';

Map<String, dynamic> _status({required bool needs}) => {
      'success': true,
      'data': {
        'needsAcceptance': needs,
        'documents': [
          {
            'key': 'terms',
            'title': 'Terms & Conditions',
            'url': 'https://aorbotreks.com/terms',
            'version': '2026-09-30',
            'acceptedVersion': needs ? null : '2026-09-30',
            'needsAcceptance': needs,
          },
        ],
      },
    };

void main() {
  late FakeLegalApi api;
  late bool loggedIn;
  late int userId;
  late LegalService service;

  setUp(() {
    api = FakeLegalApi();
    loggedIn = true;
    userId = 7;
    service = LegalService(
      api: api,
      appVersion: () async => '1.0.0+22',
      isLoggedIn: () => loggedIn,
      currentUserId: () => userId,
    );
  });

  group('document list', () {
    test('refresh loads the server list; urlFor uses it', () async {
      expect(service.urlFor('terms'), 'https://aorbotreks.com/terms'); // fallback before load
      expect(await service.refresh(), isTrue);
      expect(service.loadedFromServer, isTrue);
      expect(service.documents, hasLength(4));
    });

    test('a failed fetch is silent and keeps the fallback URLs', () async {
      api.documentsError = Exception('offline');
      expect(await service.refresh(), isFalse);
      expect(service.documents, isEmpty);
      expect(service.urlFor('privacy'), 'https://aorbotreks.com/privacy-policy');
    });

    test('concurrent refreshes share one request', () async {
      await Future.wait([service.refresh(), service.refresh(), service.ensureLoaded()]);
      expect(api.documentCalls, 1);
      await service.ensureLoaded();
      expect(api.documentCalls, 1);
    });
  });

  group('acceptCurrent', () {
    test('fetches the list first, then sends the required documents at their versions', () async {
      final r = await service.acceptCurrent(LegalAcceptSource.login);
      expect(r.isAccepted, isTrue);
      expect(api.documentCalls, 1);
      expect(api.acceptBodies.single, {
        'documents': [
          {'key': 'terms', 'version': '2026-09-30'},
          {'key': 'privacy', 'version': '2026-09-30'},
        ],
        'source': 'login',
        'appVersion': '1.0.0+22',
      });
    });

    test('409 outdated → the list moves to the current versions, and the next try sends them', () async {
      await service.refresh();
      api.acceptReplies.add(const ApiReply(409, {
        'success': false,
        'code': 'LEGAL_VERSION_OUTDATED',
        'data': {
          'documents': [
            {'key': 'terms', 'title': 'Terms & Conditions', 'url': 'https://aorbotreks.com/terms', 'version': '2026-10-15', 'requiresAcceptance': true},
            {'key': 'privacy', 'title': 'Privacy Policy', 'url': 'https://aorbotreks.com/privacy-policy', 'version': '2026-09-30', 'requiresAcceptance': true},
          ],
        },
      }));
      final first = await service.acceptCurrent(LegalAcceptSource.updatePrompt);
      expect(first.outcome, LegalAcceptOutcome.outdated);
      expect(service.documents.firstWhere((d) => d.key == 'terms').version, '2026-10-15');
      expect(service.documents, hasLength(4)); // other documents kept

      final second = await service.acceptCurrent(LegalAcceptSource.updatePrompt);
      expect(second.isAccepted, isTrue);
      expect((api.acceptBodies.last['documents'] as List).first, {'key': 'terms', 'version': '2026-10-15'});
    });

    test('network failure → failed result, never a throw', () async {
      api.acceptError = Exception('SocketException');
      final r = await service.acceptCurrent(LegalAcceptSource.updatePrompt);
      expect(r.outcome, LegalAcceptOutcome.failed);
      expect(r.message, legalAcceptNetworkError);
    });

    test('no list at all (offline, nothing cached) → failed without posting', () async {
      api.documentsError = Exception('offline');
      final r = await service.acceptCurrent(LegalAcceptSource.login);
      expect(r.outcome, LegalAcceptOutcome.failed);
      expect(api.acceptBodies, isEmpty);
    });
  });

  group('recordLoginAcceptance', () {
    test('fire and forget: returns at once and swallows every error', () async {
      api.documentsError = StateError('boom');
      service.recordLoginAcceptance(); // must not throw
      api.documentsError = null;
      api.acceptError = Exception('down');
      service.recordLoginAcceptance();
      await pumpEventQueue();
    });

    test('the dashboard check waits for a sign-in agreement still in flight', () async {
      api.acceptGate = Completer<void>();
      api.status = _status(needs: false);
      service.recordLoginAcceptance();
      final prompt = service.statusForPrompt();
      await pumpEventQueue();
      expect(api.acceptBodies, hasLength(1));
      expect(api.statusCalls, 0, reason: 'status must not be read before the agreement lands');
      api.acceptGate!.complete();
      expect(await prompt, isNull);
      expect(api.statusCalls, 1);
    });
  });

  group('statusForPrompt', () {
    test('needs acceptance → the status, once per app run', () async {
      api.status = _status(needs: true);
      expect((await service.statusForPrompt())?.needsAcceptance, isTrue);
      expect(await service.statusForPrompt(), isNull);
      expect(api.statusCalls, 1);
    });

    test('a different account signing in on this run can still be asked', () async {
      api.status = _status(needs: true);
      expect(await service.statusForPrompt(), isNotNull);
      userId = 8;
      expect(await service.statusForPrompt(), isNotNull);
    });

    test('logged out → never asks, never calls the server', () async {
      loggedIn = false;
      api.status = _status(needs: true);
      expect(await service.statusForPrompt(), isNull);
      expect(await service.checkStatus(), isNull);
      expect(api.statusCalls, 0);
    });

    test('up to date, a failed check, or a garbled reply → nothing, silently', () async {
      api.status = _status(needs: false);
      expect(await service.statusForPrompt(), isNull);
      api.statusError = Exception('timeout');
      expect(await service.statusForPrompt(), isNull);
      api.statusError = null;
      api.status = '<html>';
      expect(await service.statusForPrompt(), isNull);
      // None of those counted as "shown".
      api.status = _status(needs: true);
      expect(await service.statusForPrompt(), isNotNull);
    });

    test('status versions refresh the loaded list', () async {
      await service.refresh();
      api.status = {
        'success': true,
        'data': {
          'needsAcceptance': true,
          'documents': [
            {'key': 'privacy', 'title': 'Privacy Policy', 'url': 'https://aorbotreks.com/privacy-policy', 'version': '2026-11-01', 'needsAcceptance': true},
          ],
        },
      };
      await service.checkStatus();
      final privacy = service.documents.firstWhere((d) => d.key == 'privacy');
      expect(privacy.version, '2026-11-01');
      expect(privacy.requiresAcceptance, isTrue);
    });
  });
}
