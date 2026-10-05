// Tolerant readers for loosely-typed backend fields — mostly vendor-entered
// data kept in JSON columns, where the same field can arrive as a number, a
// numeric string, a JSON-encoded string or an object depending on how and
// when it was saved. Used as `@JsonKey(fromJson: ...)` on the Freezed models
// and by the hand-written models. A value of an unexpected type becomes null
// (or is left out of a list) instead of throwing a TypeError that blanks the
// whole screen.

import 'dart:convert';

/// 4, 4.0, 4.5 (rounded), "4", " 4.0 " → int. Anything else → null.
int? jsonToInt(Object? v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.isFinite ? v.round() : null;
  if (v is String) {
    final s = v.trim();
    final asInt = int.tryParse(s);
    if (asInt != null) return asInt;
    final asDouble = double.tryParse(s);
    return (asDouble != null && asDouble.isFinite) ? asDouble.round() : null;
  }
  return null;
}

/// A JSON object, or a JSON-encoded object string ('{"night":2}'). Anything
/// else (a list, a number, garbage) → null.
Map<String, dynamic>? jsonToMap(Object? v) {
  if (v is Map) return Map<String, dynamic>.from(v);
  if (v is String) {
    final s = v.trim();
    if (s.startsWith('{')) {
      try {
        final decoded = jsonDecode(s);
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } catch (_) {}
    }
  }
  return null;
}

/// A JSON array, or a JSON-encoded array string ("[1,2]"). Else null.
List<dynamic>? jsonToList(Object? v) {
  if (v is List) return v;
  if (v is String) {
    final s = v.trim();
    if (s.startsWith('[')) {
      try {
        final decoded = jsonDecode(s);
        if (decoded is List) return decoded;
      } catch (_) {}
    }
  }
  return null;
}

/// A list of ids: [1, "2", 3.0], "[1,2]" or "1, 2". Entries that are not
/// numbers are left out. Null/unreadable → null.
List<int>? jsonToIntList(Object? v) {
  if (v == null) return null;
  List<dynamic>? list = jsonToList(v);
  if (list == null && v is String) list = v.split(',');
  if (list == null && v is num) list = [v];
  if (list == null) return null;
  return [
    for (final e in list)
      if (jsonToInt(e) case final int n) n,
  ];
}

/// A free-form value kept in a JSON column (e.g. a customer's
/// emergency_contact): a string stays as it is, an object or array is
/// JSON-encoded, a number or bool becomes its text. Else null.
String? jsonToStringOrJson(Object? v) {
  if (v == null) return null;
  if (v is String) return v;
  if (v is Map || v is List) {
    try {
      return jsonEncode(v);
    } catch (_) {
      return null;
    }
  }
  if (v is num || v is bool) return v.toString();
  return null;
}

/// Any scalar as text (a number stays readable); objects/arrays → null.
String? jsonToStringOrNull(Object? v) {
  if (v == null) return null;
  if (v is String) return v;
  if (v is num || v is bool) return v.toString();
  return null;
}

final RegExp _digitsOnly = RegExp(r'^\d+$');

/// A display name from one list entry: a non-blank string, or an object's
/// `name`. A bare number (or digits-only string) is an id the server could
/// not resolve to a name — not something to show — so it gives null.
String? jsonDisplayName(Object? e) {
  if (e is Map) return jsonDisplayName(e['name']);
  if (e is String) {
    final s = e.trim();
    if (s.isEmpty || _digitsOnly.hasMatch(s)) return null;
    return s;
  }
  return null;
}

/// A list of display names (see [jsonDisplayName]); unreadable entries are
/// left out. Null/unreadable list → null.
List<String>? jsonToNameList(Object? v) {
  final list = jsonToList(v);
  if (list == null) return null;
  return [
    for (final e in list)
      if (jsonDisplayName(e) case final String name) name,
  ];
}
