import 'dart:convert';
import 'dart:developer';

import 'package:arobo_app/repository/network_url.dart';
import 'package:arobo_app/repository/repository.dart';
import 'package:arobo_app/share/trek_link.dart';

/// The two trek-share endpoints (backend routes/v1/shareRoutes.js).
class TrekShareRepository {
  final Repository _repository = Repository();

  /// POST share/treks → the link for this trek card (an opaque code the
  /// server creates or reuses). Throws a readable message on failure.
  Future<TrekLink> createLink({required int trekId, int? batchId, int? cityId}) async {
    final dynamic response;
    try {
      response = await _repository.postApiCall(
        url: NetworkUrl.trekShareCreate,
        body: json.encode({
          'trekId': trekId,
          if (batchId != null && batchId > 0) 'batchId': batchId,
          if (cityId != null && cityId > 0) 'cityId': cityId,
        }),
      );
    } catch (e) {
      log('createLink error: $e');
      throw 'Could not create a share link. Please try again.';
    }
    final data = response is Map ? response['data'] : null;
    final link = data is Map ? TrekLink.fromCode(data['code']?.toString()) : null;
    if (link == null) throw 'Could not create a share link. Please try again.';
    return link;
  }

  /// GET share/treks/<code> → the trek card it points to, or null when the
  /// code is unknown or the server can't be reached.
  Future<TrekTarget?> resolve(TrekLink link) async {
    try {
      final response = await _repository.getApiCall(url: NetworkUrl.trekShareResolve(link.code));
      return response is Map && response['success'] == true ? TrekTarget.fromJson(response['data']) : null;
    } catch (e) {
      log('resolve error: $e');
      return null;
    }
  }
}
