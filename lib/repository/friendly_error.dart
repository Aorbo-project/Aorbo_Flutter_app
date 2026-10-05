import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';

/// Plain-English texts for failures the app cannot explain better.
class FriendlyText {
  FriendlyText._();

  static const String noInternet = 'No internet connection. Please try again.';
  static const String tooSlow = 'The server is taking too long. Please try again.';
  static const String serverBusy = 'Our servers are busy. Please try again in a minute.';
  static const String generic = 'Something went wrong. Please try again.';
}

/// A failed API call, carrying text that is fit to show the customer.
/// `toString()` is that text, so existing `e.toString()` call sites show it
/// as is (no "Exception: " prefix, no Dio paragraph).
class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode, this.code});

  /// Shown to the customer.
  final String message;

  /// The HTTP status, when the server answered.
  final int? statusCode;

  /// The server's machine code (`code` in the body), when it sent one.
  final String? code;

  /// From a Dio failure: the server's own message when it is one written
  /// for people, otherwise a plain sentence for the kind of failure.
  factory ApiException.fromDio(DioException e) => ApiException(
        friendlyError(e),
        statusCode: e.response?.statusCode,
        code: _bodyCode(e.response?.data),
      );

  @override
  String toString() => message;
}

String? _bodyCode(Object? data) {
  if (data is Map && data['code'] is String) return data['code'] as String;
  return null;
}

/// The message a server reply carries, if any (`{message}` or `[{message}]`).
String? serverMessageOf(Object? data) {
  if (data is Map && data['message'] is String) return data['message'] as String;
  if (data is List && data.isNotEmpty && data.first is Map) {
    final m = (data.first as Map)['message'];
    if (m is String) return m;
  }
  return null;
}

// Developer / framework text that must never reach the screen (scan D5:
// Dio's "This exception was thrown because the response has a status code
// of 503 and RequestOptions.validateStatus ...", "Receive Timeout
// Exception", "Response Body Null", parse errors, raw server faults).
final RegExp _developerText = RegExp(
  r'exception\b|validatestatus|requestoptions|\bdio\b|status code of|'
  r'response body null|is not a subtype|null check|nosuchmethod|'
  r'typeerror|\bsocket|errno|econn|etimedout|\bstack\b|'
  r'sequelize|sql|undefined|is not a function|cannot read|'
  r'unexpected token|<html|<!doctype',
  caseSensitive: false,
);

/// Whether [text] reads as a sentence written for a customer.
bool isFriendlyText(String text) {
  final t = text.trim();
  return t.isNotEmpty && t.length <= 200 && !t.contains('\n') && !_developerText.hasMatch(t);
}

String _ofStatus(int? status) {
  if (status != null && status >= 500) return FriendlyText.serverBusy;
  return FriendlyText.generic;
}

/// One mapping from any failure to text fit for the customer (scan D5).
/// Log the raw error separately; never show it.
String friendlyError(Object? error) {
  if (error == null) return FriendlyText.generic;
  if (error is ApiException) {
    return isFriendlyText(error.message) ? error.message : _ofStatus(error.statusCode);
  }
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return FriendlyText.tooSlow;
      case DioExceptionType.connectionError:
        return FriendlyText.noInternet;
      case DioExceptionType.badResponse:
        final message = serverMessageOf(error.response?.data);
        if (message != null && isFriendlyText(message)) return message;
        return _ofStatus(error.response?.statusCode);
      case DioExceptionType.unknown:
        if (error.error is SocketException) return FriendlyText.noInternet;
        if (error.error is TimeoutException) return FriendlyText.tooSlow;
        return FriendlyText.generic;
      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
        return FriendlyText.generic;
    }
  }
  if (error is TimeoutException) return FriendlyText.tooSlow;
  if (error is SocketException) return FriendlyText.noInternet;
  if (error is String) return isFriendlyText(error) ? error.trim() : FriendlyText.generic;
  var text = error.toString();
  if (text.startsWith('Exception: ')) text = text.substring('Exception: '.length);
  return isFriendlyText(text) ? text.trim() : FriendlyText.generic;
}
