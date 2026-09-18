// lib/services/location_cache_service.dart
//
// On-device cache powering the location pickers:
//   • stale-while-revalidate list cache (cities + treks)
//   • persistent recent searches (per-field)
//   • persistent recent routes (complete city → trek pairs)
//
// The DashboardController saves every successful cities/treks response
// here and, on relaunch, hydrates from this cache before revalidating
// over the network — so pickers open instantly with the last known list.
// If the refresh fails, the cached list stays on screen and the UI shows
// an "offline · updated X ago" note instead of a dead spinner.
//
// Deliberately NOT a GetX service: a lazily-booted singleton, so it needs
// no binding registration — the first `await` anywhere boots it.
//
// JSON encoding runs on a background isolate (compute) so a large trek
// list can never block the UI thread during a save.

import 'dart:convert';

import 'package:arobo_app/models/dashboard/cities_model.dart';
import 'package:arobo_app/models/dashboard/trek_modal.dart';
import 'package:arobo_app/widgets/logger.dart';
import 'package:flutter/foundation.dart' show compute;
import 'package:shared_preferences/shared_preferences.dart';

/// A complete picked route (departure city + destination trek), stored
/// by name and re-resolved against the live lists at display time.
class RecentRoute {
  final String fromCity;
  final String toTrek;
  const RecentRoute({required this.fromCity, required this.toTrek});

  Map<String, dynamic> toJson() => {'from': fromCity, 'to': toTrek};

  static RecentRoute? fromJson(dynamic j) {
    if (j is! Map) return null;
    final f = (j['from'] ?? '').toString().trim();
    final t = (j['to'] ?? '').toString().trim();
    if (f.isEmpty || t.isEmpty) return null;
    return RecentRoute(fromCity: f, toTrek: t);
  }
}

class LocationCacheService {
  LocationCacheService._();

  static final LocationCacheService instance = LocationCacheService._();

  // Bump the suffix when the stored shape changes in a breaking way.
  static const _kCitiesJson = 'loc_cache.cities.json.v1';
  static const _kCitiesSavedAt = 'loc_cache.cities.savedAt.v1';
  static const _kTreksJson = 'loc_cache.treks.json.v1';
  static const _kTreksSavedAt = 'loc_cache.treks.savedAt.v1';
  static const _kRecentCities = 'loc_cache.recent.cities.v1';
  static const _kRecentTreks = 'loc_cache.recent.treks.v1';
  static const _kRecentRoutes = 'loc_cache.recent.routes.v1';

  static const int _maxRecents = 8;
  static const int _maxRoutes = 6;

  SharedPreferences? _prefs;
  Future<void>? _boot;

  /// The exact instances handed out by loadCities()/loadTreks(). The
  /// picker compares them by identity with the controller's live values:
  /// still identical → the list on screen is still the cached copy (show
  /// the offline note). A successful network fetch assigns a NEW instance,
  /// the identity breaks, and the note disappears on its own.
  GetCities? lastLoadedCityCache;
  TrekModal? lastLoadedTrekCache;

  DateTime? _citiesSavedAt;
  DateTime? _treksSavedAt;

  final List<String> _recentCities = [];
  final List<String> _recentTreks = [];
  final List<RecentRoute> _recentRoutes = [];

  DateTime? get citiesSavedAt => _citiesSavedAt;
  DateTime? get treksSavedAt => _treksSavedAt;

  /// Completes once prefs are open and recents are in memory.
  /// Safe to await from anywhere, repeatedly.
  Future<void> ensureReady() => _boot ??= _bootUp();

  Future<void> _bootUp() async {
    final prefs = await SharedPreferences.getInstance();
    _prefs = prefs;
    _recentCities
      ..clear()
      ..addAll(_decodeStringList(prefs.getString(_kRecentCities)));
    _recentTreks
      ..clear()
      ..addAll(_decodeStringList(prefs.getString(_kRecentTreks)));
    _recentRoutes
      ..clear()
      ..addAll(_decodeRoutes(prefs.getString(_kRecentRoutes)));
    _citiesSavedAt = _readDate(prefs, _kCitiesSavedAt);
    _treksSavedAt = _readDate(prefs, _kTreksSavedAt);
  }

  // ── Cities list cache ────────────────────────────────────────────────

  Future<void> saveCities(GetCities model) async {
    await ensureReady();
    try {
      final encoded = await compute(jsonEncode, model.toJson());
      await _prefs!.setString(_kCitiesJson, encoded);
      _citiesSavedAt = DateTime.now();
      await _prefs!.setInt(
        _kCitiesSavedAt,
        _citiesSavedAt!.millisecondsSinceEpoch,
      );
      lastLoadedCityCache = null; // the live list is now fresh
    } catch (e) {
      logger.w('LocationCache: saveCities failed: $e');
    }
  }

  Future<GetCities?> loadCities() async {
    await ensureReady();
    final raw = _prefs!.getString(_kCitiesJson);
    if (raw == null || raw.isEmpty) return null;
    try {
      final model = GetCities.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      if (model.data?.isNotEmpty != true) return null;
      lastLoadedCityCache = model;
      return model;
    } catch (e) {
      logger.w('LocationCache: loadCities failed: $e');
      return null;
    }
  }

  // ── Treks list cache ──────────────────────────────────────────────────

  Future<void> saveTreks(TrekModal model) async {
    await ensureReady();
    try {
      final encoded = await compute(jsonEncode, model.toJson());
      await _prefs!.setString(_kTreksJson, encoded);
      _treksSavedAt = DateTime.now();
      await _prefs!.setInt(
        _kTreksSavedAt,
        _treksSavedAt!.millisecondsSinceEpoch,
      );
      lastLoadedTrekCache = null; // the live list is now fresh
    } catch (e) {
      logger.w('LocationCache: saveTreks failed: $e');
    }
  }

  Future<TrekModal?> loadTreks() async {
    await ensureReady();
    final raw = _prefs!.getString(_kTreksJson);
    if (raw == null || raw.isEmpty) return null;
    try {
      final model = TrekModal.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      if (model.data?.isNotEmpty != true) return null;
      lastLoadedTrekCache = model;
      return model;
    } catch (e) {
      logger.w('LocationCache: loadTreks failed: $e');
      return null;
    }
  }

  // ── Recent searches (persisted) ──────────────────────────────────────

  List<String> recentCities() => List.unmodifiable(_recentCities);
  List<String> recentTreks() => List.unmodifiable(_recentTreks);

  Future<void> addRecentCity(String value) =>
      _addRecent(_recentCities, _kRecentCities, value);

  Future<void> addRecentTrek(String value) =>
      _addRecent(_recentTreks, _kRecentTreks, value);

  Future<void> clearRecentCities() async {
    await ensureReady();
    _recentCities.clear();
    await _prefs!.setString(_kRecentCities, '[]');
  }

  Future<void> clearRecentTreks() async {
    await ensureReady();
    _recentTreks.clear();
    await _prefs!.setString(_kRecentTreks, '[]');
  }

  Future<void> _addRecent(List<String> list, String key, String value) async {
    final v = value.trim();
    if (v.isEmpty) return;
    await ensureReady();
    list.removeWhere((e) => e.toLowerCase() == v.toLowerCase());
    list.insert(0, v);
    while (list.length > _maxRecents) {
      list.removeLast();
    }
    try {
      await _prefs!.setString(key, jsonEncode(list));
    } catch (e) {
      logger.w('LocationCache: writing recents failed: $e');
    }
  }

  // ── Recent routes (persisted) ────────────────────────────────────────

  List<RecentRoute> recentRoutes() => List.unmodifiable(_recentRoutes);

  Future<void> addRecentRoute(String fromCity, String toTrek) async {
    final f = fromCity.trim();
    final t = toTrek.trim();
    if (f.isEmpty || t.isEmpty) return;
    await ensureReady();
    _recentRoutes.removeWhere(
      (r) =>
          r.fromCity.toLowerCase() == f.toLowerCase() &&
          r.toTrek.toLowerCase() == t.toLowerCase(),
    );
    _recentRoutes.insert(0, RecentRoute(fromCity: f, toTrek: t));
    while (_recentRoutes.length > _maxRoutes) {
      _recentRoutes.removeLast();
    }
    try {
      await _prefs!.setString(
        _kRecentRoutes,
        jsonEncode([for (final r in _recentRoutes) r.toJson()]),
      );
    } catch (e) {
      logger.w('LocationCache: writing recent routes failed: $e');
    }
  }

  Future<void> clearRecentRoutes() async {
    await ensureReady();
    _recentRoutes.clear();
    await _prefs!.setString(_kRecentRoutes, '[]');
  }

  // ── helpers ──────────────────────────────────────────────────────────

  List<String> _decodeStringList(String? raw) {
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) return decoded.whereType<String>().toList();
    } catch (_) {}
    return const [];
  }

  List<RecentRoute> _decodeRoutes(String? raw) {
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      final out = <RecentRoute>[];
      for (final j in decoded) {
        final r = RecentRoute.fromJson(j);
        if (r != null) out.add(r);
      }
      return out;
    } catch (_) {}
    return const [];
  }

  DateTime? _readDate(SharedPreferences prefs, String key) {
    final ms = prefs.getInt(key);
    if (ms == null || ms <= 0) return null;
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }
}
