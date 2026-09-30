// Shared replies + a fake API for the legal tests (not a test file itself).

import 'dart:async';

import 'package:arobo_app/legal/legal_api.dart';
import 'package:arobo_app/repository/repository.dart' show ApiReply;

/// GET legal/documents, as the backend documents it.
Map<String, dynamic> documentsReply({String termsVersion = '2026-09-30', String privacyVersion = '2026-09-30'}) => {
      'success': true,
      'data': {
        'documents': [
          {
            'key': 'terms',
            'title': 'Terms & Conditions',
            'version': termsVersion,
            'url': 'https://aorbotreks.com/terms',
            'requiresAcceptance': true,
          },
          {
            'key': 'privacy',
            'title': 'Privacy Policy',
            'version': privacyVersion,
            'url': 'https://aorbotreks.com/privacy-policy',
            'requiresAcceptance': true,
          },
          {
            'key': 'user_agreement',
            'title': 'User Agreement',
            'version': '2026-09-01',
            'url': 'https://aorbotreks.com/user-agreement',
            'requiresAcceptance': false,
          },
          {
            'key': 'refund',
            'title': 'Refund & Cancellation Policy',
            'version': '2026-09-01',
            'url': 'https://aorbotreks.com/refund-policy',
            'requiresAcceptance': false,
          },
        ],
      },
    };

/// Records calls; each reply/error is settable per test.
class FakeLegalApi implements LegalApi {
  Object? documents = documentsReply();
  Object? documentsError;
  Object? status;
  Object? statusError;
  Object? acceptError;
  final List<ApiReply> acceptReplies = [];
  Map<String, dynamic> acceptedReply = const {'success': true, 'data': {'needsAcceptance': false, 'documents': []}};
  Completer<void>? acceptGate;

  int documentCalls = 0;
  int statusCalls = 0;
  final List<Map<String, dynamic>> acceptBodies = [];

  @override
  Future<Object?> fetchDocuments() async {
    documentCalls++;
    if (documentsError != null) throw documentsError!;
    return documents;
  }

  @override
  Future<Object?> fetchStatus() async {
    statusCalls++;
    if (statusError != null) throw statusError!;
    return status;
  }

  @override
  Future<ApiReply> accept(Map<String, dynamic> body) async {
    acceptBodies.add(body);
    if (acceptGate != null) await acceptGate!.future;
    if (acceptError != null) throw acceptError!;
    return acceptReplies.isNotEmpty ? acceptReplies.removeAt(0) : ApiReply(200, acceptedReply);
  }
}
