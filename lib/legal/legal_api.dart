import 'package:arobo_app/main.dart';
import 'package:arobo_app/repository/network_url.dart';
import 'package:arobo_app/repository/repository.dart';
import 'package:arobo_app/utils/shared_preferences.dart';
import 'package:dio/dio.dart' show Options;

/// The three legal-document calls, as raw replies. Parsing lives in
/// legal_documents.dart; the rules for when to call live in LegalService.
abstract class LegalApi {
  /// GET legal/documents — public.
  Future<Object?> fetchDocuments();

  /// GET customer/legal/status — null when there is no login token.
  Future<Object?> fetchStatus();

  /// POST customer/legal/accept — returns 2xx AND 4xx replies (a 409 is a
  /// normal answer here); throws on no connection / timeout / 5xx / 401.
  Future<ApiReply> accept(Map<String, dynamic> body);
}

class RemoteLegalApi implements LegalApi {
  RemoteLegalApi({Repository? repository}) : _repo = repository ?? Repository();
  final Repository _repo;

  static const Duration _timeout = Duration(seconds: 10);

  @override
  Future<Object?> fetchDocuments() async {
    // Sent WITHOUT the login token: the list is public, and this runs on the
    // sign-in screen too, where a stale token must never trip the
    // session-expired handling in Repository's interceptor.
    final response = await _repo.dio.get(NetworkUrl.legalDocuments).timeout(_timeout);
    return response.data;
  }

  @override
  Future<Object?> fetchStatus() async {
    // Called straight on dio (no "check your internet" toast) — the status
    // check is silent. An expired token still gets the normal silent refresh.
    final token = sp?.getString(SpUtil.accessToken);
    if (token is! String || token.isEmpty) return null;
    final response = await _repo.dio
        .get(
          NetworkUrl.legalStatus,
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        )
        .timeout(_timeout);
    return response.data;
  }

  @override
  Future<ApiReply> accept(Map<String, dynamic> body) =>
      _repo.postForReply(url: NetworkUrl.legalAccept, body: body);
}
