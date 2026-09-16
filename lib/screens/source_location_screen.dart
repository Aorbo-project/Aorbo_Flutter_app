import 'dart:async';

import 'package:arobo_app/controller/dashboard_controller.dart';
import 'package:arobo_app/services/location_cache_service.dart';
import 'package:arobo_app/theme/app_button.dart';
import 'package:arobo_app/theme/app_tokens.dart';
import 'package:arobo_app/theme/app_typography.dart';
import 'package:arobo_app/utils/custom_snackbar.dart';
import 'package:arobo_app/utils/screen_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

/// Which dashboard field opened the sheet.
enum PickTarget { from, to }

// ─────────────────────────────────────────────
//  THEME TOKENS (all routed through app_tokens)
// ─────────────────────────────────────────────
class _T {
  _T._();

  static const bg = AppColors.bg;
  static const card = AppColors.surface;
  static const forestDeep = AppColors.forestDeep;
  static const forest = AppColors.forest;
  static const forestSoft = AppColors.forestSoft;
  static const focusBg = Color(0xFFEFF5EF);
  static const border = AppColors.border;
  static const divider = AppColors.divider;
  static const ink = AppColors.ink;
  static const inkMid = AppColors.inkMid;
  static const inkLight = AppColors.inkLight;
  static const amber = AppColors.amber;
  static const warning = AppColors.warning;
  static const warningSoft = AppColors.warningSoft;
  static const clay = Color(0xFFCB6D42);
  static const error = AppColors.danger;
  static const skeleton = Color(0xFFEDF0EB);
}

enum _Tab { cities, treks }

enum _ListState { idle, loading, empty, error, noNetwork, ready }

// Fixed row heights.
const double _kCityHeaderExtent = 24.0;
const double _kTileExtent = 44.0;

/// Curated tier-1 departure cities, in display order. The backend's
/// isPopular flag is sparsely set on cities (unlike treks), which is why
/// metros like Hyderabad/Bangalore never surfaced — these names are
/// matched against the LIVE list, so nothing shows that doesn't exist.
/// Both spellings cover cities the API may name differently.
const List<String> _kTopCityNames = [
  'Delhi',
  'Mumbai',
  'Bengaluru',
  'Bangalore',
  'Hyderabad',
  'Pune',
  'Chennai',
  'Kolkata',
  'Ahmedabad',
  'Jaipur',
  'Lucknow',
  'Chandigarh',
  'Dehradun',
  'Haridwar',
];

extension on String {
  String get _normalized {
    var s = toLowerCase().trim();
    s = s.replaceAllMapped(
      _Diacritics.pattern,
      (m) => _Diacritics.map[m[0]!] ?? '',
    );
    s = s.replaceAll(RegExp(r'[^a-z0-9\s]'), ' ');
    s = s.replaceAll(RegExp(r'\s+'), ' ');
    return s.trim();
  }
}

class _Diacritics {
  static final map = <String, String>{
    'á': 'a',
    'à': 'a',
    'ä': 'a',
    'â': 'a',
    'ã': 'a',
    'å': 'a',
    'ā': 'a',
    'é': 'e',
    'è': 'e',
    'ë': 'e',
    'ê': 'e',
    'ē': 'e',
    'í': 'i',
    'ì': 'i',
    'ï': 'i',
    'î': 'i',
    'ī': 'i',
    'ó': 'o',
    'ò': 'o',
    'ö': 'o',
    'ô': 'o',
    'õ': 'o',
    'ø': 'o',
    'ō': 'o',
    'ú': 'u',
    'ù': 'u',
    'ü': 'u',
    'û': 'u',
    'ū': 'u',
    'ñ': 'n',
    'ń': 'n',
    'ç': 'c',
    'ć': 'c',
    'ś': 's',
    'š': 's',
    'ý': 'y',
    'ÿ': 'y',
    'ź': 'z',
    'ż': 'z',
    'ř': 'r',
    'ŕ': 'r',
    'ł': 'l',
    'đ': 'd',
    'ß': 'ss',
  };
  static final pattern = RegExp(
    '[' + map.keys.map((c) => RegExp.escape(c)).join() + ']',
  );
}

int _levenshteinCapped(String a, String b, int max) {
  if (a == b) return 0;
  final la = a.length, lb = b.length;
  if ((la - lb).abs() > max) return max + 1;
  if (la == 0) return lb;
  if (lb == 0) return la;
  var prev = List<int>.generate(lb + 1, (i) => i);
  var curr = List<int>.filled(lb + 1, 0);
  for (var i = 1; i <= la; i++) {
    curr[0] = i;
    var rowMin = i;
    final ci = a[i - 1];
    for (var j = 1; j <= lb; j++) {
      final cost = ci == b[j - 1] ? 0 : 1;
      final v = [
        prev[j] + 1,
        curr[j - 1] + 1,
        prev[j - 1] + cost,
      ].reduce((x, y) => x < y ? x : y);
      curr[j] = v;
      if (v < rowMin) rowMin = v;
    }
    if (rowMin > max) return max + 1;
    final tmp = prev;
    prev = curr;
    curr = tmp;
  }
  return prev[lb];
}

class _Debouncer {
  _Debouncer(this.duration);
  final Duration duration;
  Timer? _t;
  void run(void Function() fn) {
    _t?.cancel();
    _t = Timer(duration, fn);
  }

  void cancel() {
    _t?.cancel();
    _t = null;
  }

  void dispose() => cancel();
}

/// One pickable location — pre-normalized search key, popular flag, and
/// (treks) the state shown as trailing context.
class _Entry {
  final int id;
  final String name;
  final String normalized;
  final bool isPopular;
  final String? state;
  const _Entry({
    required this.id,
    required this.name,
    required this.normalized,
    this.isPopular = false,
    this.state,
  });
}

/// A flattened browse row — either a static letter label (cities) or a
/// tile. Static = scrolls away with content, so nothing can ever stack
/// at the top edge.
class _Row {
  const _Row.header(this.label) : entry = null;
  const _Row.tile(this.entry) : label = null;
  final String? label;
  final _Entry? entry;
  bool get isHeader => label != null;
}

/// A resolved recent route — both endpoints validated against the
/// current lists. Tapping it fills BOTH fields at once.
class _RoutePair {
  final _Entry from;
  final _Entry to;
  const _RoutePair(this.from, this.to);
}

class _Scored {
  final _Entry entry;
  final int score;
  const _Scored(this.entry, this.score);
}

class _FilterResult {
  final _ListState state;
  final List<_Entry> items;
  final List<_Entry> recent;
  final List<_RoutePair> routes;
  final String? query;
  const _FilterResult({
    required this.state,
    required this.items,
    this.recent = const [],
    this.routes = const [],
    this.query,
  });
}

/// Case-insensitive substring range for query highlighting, if any.
TextRange? _matchRange(String name, String query) {
  final q = query.trim();
  if (q.isEmpty) return null;
  final i = name.toLowerCase().indexOf(q.toLowerCase());
  if (i < 0) return null;
  return TextRange(start: i, end: i + q.length);
}

// ─────────────────────────────────────────────
//  SOURCE LOCATION — BOTTOM SHEET
// ─────────────────────────────────────────────
class SourceLocationSheet extends StatefulWidget {
  final PickTarget initialTarget;

  const SourceLocationSheet({super.key, this.initialTarget = PickTarget.from});

  /// Opens the sheet. Returns `true` when a complete route was picked.
  static Future<bool?> show(
    BuildContext context, {
    PickTarget initialTarget = PickTarget.from,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (_) => SourceLocationSheet(initialTarget: initialTarget),
    );
  }

  @override
  State<SourceLocationSheet> createState() => _SourceLocationSheetState();
}

class _SourceLocationSheetState extends State<SourceLocationSheet> {
  final DashboardController _dashboardC = Get.find<DashboardController>();
  _Tab _tab = _Tab.cities;
  late final TextEditingController _fromCtrl;
  late final TextEditingController _toCtrl;
  final FocusNode _fromFocus = FocusNode();
  final FocusNode _toFocus = FocusNode();
  final _Debouncer _searchDebounce = _Debouncer(
    const Duration(milliseconds: 180),
  );
  final RxString _query = ''.obs;
  StreamSubscription<String>? _querySub;
  Timer? _loadingTimeout;

  List<_Entry> _cityEntries = const [];
  List<_Entry> _trekEntries = const [];
  final Map<String, _Entry> _cityByName = {};
  final Map<String, _Entry> _trekByName = {};

  final Rx<_FilterResult> _filtered = Rx<_FilterResult>(
    const _FilterResult(state: _ListState.idle, items: []),
  );

  // Browse list. The controller exists only so a tab switch / cleared
  // search can snap the list back to the top — no scroll listener, no
  // per-frame work, no viewport resizing. The chip sections live INSIDE
  // the scroll view, so they leave and return with plain scrolling.
  final ScrollController _scrollCtrl = ScrollController();
  List<_Row> _browseRows = const [];

  // Dedupe memory for _commit — see _commit for why.
  List<_Entry>? _lastItems;
  List<_Entry>? _lastRecent;
  List<_RoutePair>? _lastRoutes;
  String? _lastQuery;
  _ListState? _lastState;

  bool _navigatingBack = false;
  bool _itemTapInFlight = false;
  String _errorMessage = '';
  String _citiesError = '';
  String _treksError = '';
  Worker? _citiesWorker;
  Worker? _treksWorker;
  Worker? _errorWorker;
  Worker? _loadingWorker;

  @override
  void initState() {
    super.initState();
    _fromCtrl = TextEditingController(
      text: _dashboardC.fromController.value.text,
    );
    _toCtrl = TextEditingController(text: _dashboardC.toController.value.text);

    _fromCtrl.addListener(_onFromChanged);
    _toCtrl.addListener(_onToChanged);
    _fromFocus.addListener(_onFromFocusChange);
    _toFocus.addListener(_onToFocusChange);

    _citiesWorker = ever(_dashboardC.citiesData, (_) {
      if (!mounted) return;
      if (_dashboardC.citiesData.value.data != null) _citiesError = '';
      _rebuildCityCache();
      _revalidatePersistedIds();
      _refreshFiltered();
    });

    _treksWorker = ever(_dashboardC.trekData, (_) {
      if (!mounted) return;
      if (_dashboardC.trekData.value.data != null) _treksError = '';
      _rebuildTrekCache();
      _revalidatePersistedIds();
      _refreshFiltered();
    });

    _errorWorker = ever(_dashboardC.errorMessage, (err) {
      if (!mounted) return;
      if (err.toLowerCase().contains('cities')) _citiesError = err;
      if (err.toLowerCase().contains('trek')) _treksError = err;
      _refreshFiltered();
    });

    _loadingWorker = ever(_dashboardC.isLoadingCities, (_) {
      if (!mounted) return;
      // The flag is shared by cities/treks/states fetches and toggles
      // several times per fetch. When this tab already has data nothing
      // visible depends on it (the offline banner reads the flag through
      // the Obx directly) — skip the redundant full refresh.
      final hasData =
          (_tab == _Tab.cities ? _cityEntries : _trekEntries).isNotEmpty;
      if (hasData) return;
      _refreshFiltered();
    });

    _rebuildCityCache();
    _rebuildTrekCache();
    _revalidatePersistedIds();

    unawaited(_bootstrapData());

    _querySub = _query.listen((q) {
      // Returning to the browse view (query cleared) → back to the top.
      if (q.trim().isEmpty) _resetBrowseScroll();
      _refreshFiltered();
    });
    _refreshFiltered();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Let the sheet's entrance animation settle before raising the
      // keyboard, so the two never fight over the layout.
      Future.delayed(const Duration(milliseconds: 350), () {
        if (!mounted) return;
        _applyInitialTarget();
      });
    });
  }

  /// Boots the cache service (recents + routes), then applies
  /// stale-while-revalidate to the lists: hydrate from disk if the
  /// controller has nothing, and only hit the network when even the
  /// cache is empty.
  Future<void> _bootstrapData() async {
    await LocationCacheService.instance.ensureReady();
    if (!mounted) return;

    if (_dashboardC.citiesData.value.data == null ||
        _dashboardC.trekData.value.data == null) {
      await _dashboardC.hydrateLocationCache();
      if (!mounted) return;
    }
    if (_dashboardC.citiesData.value.data == null &&
        !_dashboardC.isLoadingCities.value) {
      _dashboardC.fetchCitiesList();
    }
    if (_dashboardC.trekData.value.data == null &&
        !_dashboardC.isLoadingCities.value) {
      _dashboardC.fetchTrekList();
    }
    if (mounted) _refreshFiltered();
  }

  /// Lands on the field the user tapped on the dashboard. Tapping "To"
  /// without a valid departure falls back to the departure field.
  void _applyInitialTarget() {
    if (widget.initialTarget == PickTarget.to && _hasValidFromSelection) {
      _setActiveField(_Tab.treks);
      return;
    }
    _setActiveField(_Tab.cities);
  }

  int get _fromCityId => _dashboardC.selectedCityId.value;
  int get _selectedTrekId => _dashboardC.selectedTrekId.value;
  set _fromCityId(int v) => _dashboardC.selectedCityId.value = v;
  set _selectedTrekId(int v) => _dashboardC.selectedTrekId.value = v;
  bool get _hasValidFromSelection => _fromCityId != 0;
  bool get _hasValidToSelection => _selectedTrekId != 0;

  /// True while the list on screen for the ACTIVE tab is still the exact
  /// object hydrated from disk — i.e. the network refresh hasn't landed.
  bool get _servingCityCache {
    final marker = LocationCacheService.instance.lastLoadedCityCache;
    return marker != null && identical(_dashboardC.citiesData.value, marker);
  }

  bool get _servingTrekCache {
    final marker = LocationCacheService.instance.lastLoadedTrekCache;
    return marker != null && identical(_dashboardC.trekData.value, marker);
  }

  bool get _servingCacheOnTab =>
      _tab == _Tab.cities ? _servingCityCache : _servingTrekCache;

  @override
  void dispose() {
    _fromCtrl.removeListener(_onFromChanged);
    _toCtrl.removeListener(_onToChanged);
    _fromFocus.removeListener(_onFromFocusChange);
    _toFocus.removeListener(_onToFocusChange);
    _querySub?.cancel();
    _searchDebounce.dispose();
    _loadingTimeout?.cancel();
    _citiesWorker?.dispose();
    _treksWorker?.dispose();
    _errorWorker?.dispose();
    _loadingWorker?.dispose();
    _fromCtrl.dispose();
    _toCtrl.dispose();
    _fromFocus.dispose();
    _toFocus.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  // ── TEXT / FOCUS PLUMBING ──────────────────────────────────────────────
  void _onFromChanged() {
    final text = _fromCtrl.text;
    _dashboardC.fromController.value.text = text;
    if (_fromCityId != 0) {
      String? selectedName;
      for (final e in _cityEntries) {
        if (e.id == _fromCityId) {
          selectedName = e.name;
          break;
        }
      }
      if (selectedName == null ||
          selectedName.toLowerCase() != text.trim().toLowerCase()) {
        _fromCityId = 0;
      }
    }
    if (mounted) setState(() {});
  }

  void _onToChanged() {
    final text = _toCtrl.text;
    _dashboardC.toController.value.text = text;
    if (_selectedTrekId != 0) {
      String? selectedName;
      for (final e in _trekEntries) {
        if (e.id == _selectedTrekId) {
          selectedName = e.name;
          break;
        }
      }
      if (selectedName == null ||
          selectedName.toLowerCase() != text.trim().toLowerCase()) {
        _selectedTrekId = 0;
      }
    }
    if (mounted) setState(() {});
  }

  void _onFromFocusChange() {
    if (!mounted || _itemTapInFlight) return;
    if (_fromFocus.hasFocus && _tab != _Tab.cities) {
      setState(() => _tab = _Tab.cities);
      _query.value = _fromCtrl.text;
      _refreshFiltered();
      _resetBrowseScroll();
    }
    if (mounted) setState(() {});
  }

  void _onToFocusChange() {
    if (!mounted || _itemTapInFlight) return;
    if (_toFocus.hasFocus && _tab != _Tab.treks) {
      if (!_hasValidFromSelection) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) FocusScope.of(context).requestFocus(_fromFocus);
        });
        return;
      }
      setState(() => _tab = _Tab.treks);
      _query.value = _toCtrl.text;
      _refreshFiltered();
      _resetBrowseScroll();
    }
    if (mounted) setState(() {});
  }

  void _setActiveField(_Tab tab) {
    if (tab == _Tab.treks && !_hasValidFromSelection) {
      _fromFocus.requestFocus();
      HapticFeedback.mediumImpact();
      return;
    }
    if (_tab != tab) {
      setState(() => _tab = tab);
      // Fresh tab → fresh list from the top.
      _resetBrowseScroll();
    }
    final ctrl = tab == _Tab.cities ? _fromCtrl : _toCtrl;
    final hasSelection = tab == _Tab.cities
        ? _hasValidFromSelection
        : _hasValidToSelection;
    if (hasSelection) {
      _query.value = '';
      ctrl.selection = TextSelection(
        baseOffset: 0,
        extentOffset: ctrl.text.length,
      );
    } else {
      _query.value = ctrl.text;
    }
    _refreshFiltered();
    (tab == _Tab.cities ? _fromFocus : _toFocus).requestFocus();
  }

  // ── CACHES ─────────────────────────────────────────────────────────────
  void _rebuildCityCache() {
    final apiData = _dashboardC.citiesData.value.data;
    final entries = <_Entry>[];
    final seen = <String>{};
    if (apiData != null) {
      for (final c in apiData) {
        final name = (c.cityName ?? '').trim();
        if (name.isEmpty) continue;
        final lower = name.toLowerCase();
        if (seen.contains(lower)) continue;
        seen.add(lower);
        entries.add(
          _Entry(
            id: c.id ?? 0,
            name: name,
            normalized: name._normalized,
            isPopular: c.isPopular == true,
          ),
        );
      }
    }
    entries.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
    _cityEntries = entries;
    _cityByName
      ..clear()
      ..addAll({for (final e in entries) e.name.toLowerCase(): e});
  }

  void _rebuildTrekCache() {
    final apiData = _dashboardC.trekData.value.data;
    final entries = <_Entry>[];
    final seen = <String>{};
    if (apiData != null) {
      for (final t in apiData) {
        final name = (t.name ?? '').trim();
        if (name.isEmpty) continue;
        final lower = name.toLowerCase();
        if (seen.contains(lower)) continue;
        seen.add(lower);
        final state = (t.state ?? '').trim();
        entries.add(
          _Entry(
            id: t.id ?? 0,
            name: name,
            normalized: name._normalized,
            isPopular: t.isPopular == true,
            state: state.isEmpty ? null : state,
          ),
        );
      }
    }
    entries.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
    _trekEntries = entries;
    _trekByName
      ..clear()
      ..addAll({for (final e in entries) e.name.toLowerCase(): e});
  }

  void _revalidatePersistedIds() {
    if (_dashboardC.citiesData.value.data != null &&
        _fromCityId != 0 &&
        _nameForId(_fromCityId, _cityEntries) == null) {
      _fromCityId = 0;
      if (_fromCtrl.text.isNotEmpty) _fromCtrl.clear();
    }
    if (_dashboardC.trekData.value.data != null &&
        _selectedTrekId != 0 &&
        _nameForId(_selectedTrekId, _trekEntries) == null) {
      _selectedTrekId = 0;
      if (_toCtrl.text.isNotEmpty) _toCtrl.clear();
    }
  }

  String? _nameForId(int id, List<_Entry> entries) {
    if (id == 0) return null;
    for (final e in entries) {
      if (e.id == id) return e.name;
    }
    return null;
  }

  _Entry? _resolveEntryByName(String name) {
    return (_tab == _Tab.cities ? _cityByName : _trekByName)[name
        .trim()
        .toLowerCase()];
  }

  // ── SEARCH ─────────────────────────────────────────────────────────────
  void _onSearchChanged(String value) {
    _searchDebounce.run(() {
      if (!mounted) return;
      _query.value = value;
    });
  }

  void _refreshFiltered() {
    if (!mounted) return;
    final query = _query.value.trim();
    final isCities = _tab == _Tab.cities;
    final entries = isCities ? _cityEntries : _trekEntries;
    final tabError = isCities ? _citiesError : _treksError;

    // Persisted recents, resolved against the CURRENT list so a renamed /
    // removed location quietly drops out of the chips.
    final recent = <_Entry>[];
    final names = isCities
        ? LocationCacheService.instance.recentCities()
        : LocationCacheService.instance.recentTreks();
    final byName = isCities ? _cityByName : _trekByName;
    for (final n in names) {
      final e = byName[n.trim().toLowerCase()];
      if (e != null) recent.add(e);
    }

    // Persisted recent routes — BOTH endpoints must still resolve,
    // otherwise the chip would tap into a dead selection.
    //
    // Destination step: a stored route only matters if it CONTINUES from
    // the departure the user already locked in — anything else ("Mumbai
    // → …" while departing from Delhi) is noise and is filtered out.
    // Departure step: all routes shown (picking the city completes one).
    final routes = <_RoutePair>[];
    for (final r in LocationCacheService.instance.recentRoutes()) {
      final f = _cityByName[r.fromCity.trim().toLowerCase()];
      final t = _trekByName[r.toTrek.trim().toLowerCase()];
      if (f == null || t == null) continue;
      if (_tab == _Tab.treks && f.id != _fromCityId) continue;
      routes.add(_RoutePair(f, t));
    }

    if (entries.isNotEmpty) {
      _loadingTimeout?.cancel();
      _loadingTimeout = null;
      if (query.isEmpty) {
        _buildBrowseRows();
        _commit(_ListState.ready, entries, recent, routes: routes);
        return;
      }
      final result = _computeFiltered(entries, query);
      _commit(
        result.isEmpty ? _ListState.empty : _ListState.ready,
        result,
        recent,
        routes: routes,
        query: query,
      );
      return;
    }

    if (tabError.isNotEmpty) {
      _loadingTimeout?.cancel();
      _loadingTimeout = null;
      _errorMessage = tabError;
      _commit(
        _isNetworkError(tabError) ? _ListState.noNetwork : _ListState.error,
        const [],
        recent,
      );
      return;
    }

    _loadingTimeout?.cancel();
    _loadingTimeout = Timer(const Duration(seconds: 15), () {
      if (!mounted) return;
      _errorMessage = 'Taking too long to load. Please check your connection.';
      _commit(_ListState.error, const [], const []);
    });
    _commit(_ListState.loading, const [], recent);
  }

  /// Assigns `_filtered` only when something the UI shows actually
  /// changed. Without this, every loading-flag toggle / error-message
  /// rewrite fired a worker → a fresh result → a full rebuild for nothing.
  void _commit(
    _ListState state,
    List<_Entry> items,
    List<_Entry> recent, {
    List<_RoutePair> routes = const [],
    String? query,
  }) {
    final q = query ?? '';
    final itemsSame =
        identical(items, _lastItems) ||
        _listEquals(items, _lastItems ?? const []);
    final recentSame =
        identical(recent, _lastRecent) ||
        _listEquals(recent, _lastRecent ?? const []);
    final routesSame =
        identical(routes, _lastRoutes) ||
        _routesEquals(routes, _lastRoutes ?? const []);
    if (_lastState == state &&
        (_lastQuery ?? '') == q &&
        itemsSame &&
        recentSame &&
        routesSame) {
      return;
    }
    _lastState = state;
    _lastQuery = q;
    _lastItems = items;
    _lastRecent = recent;
    _lastRoutes = routes;
    _filtered.value = _FilterResult(
      state: state,
      items: items,
      recent: recent,
      routes: routes,
      query: q.isEmpty ? null : q,
    );
  }

  bool _listEquals(List<_Entry> a, List<_Entry> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id || a[i].name != b[i].name) return false;
    }
    return true;
  }

  bool _routesEquals(List<_RoutePair> a, List<_RoutePair> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].from.id != b[i].from.id || a[i].to.id != b[i].to.id) {
        return false;
      }
    }
    return true;
  }

  bool _isNetworkError(String error) {
    final lower = error.toLowerCase();
    return lower.contains('network') ||
        lower.contains('socket') ||
        lower.contains('internet') ||
        lower.contains('connection') ||
        lower.contains('timeout') ||
        lower.contains('handshake');
  }

  List<_Entry> _computeFiltered(List<_Entry> source, String rawQuery) {
    final q = rawQuery._normalized;
    if (q.isEmpty) return source;
    final prefix = <_Entry>[];
    final wordPrefix = <_Entry>[];
    final substring = <_Entry>[];
    for (final e in source) {
      final norm = e.normalized;
      if (norm.startsWith(q)) {
        prefix.add(e);
        continue;
      }
      var wp = false;
      for (final token in norm.split(' ')) {
        if (token.isEmpty) continue;
        if (token.startsWith(q)) {
          wp = true;
          break;
        }
      }
      if (wp) {
        wordPrefix.add(e);
      } else if (norm.contains(q)) {
        substring.add(e);
      }
    }
    final direct = [...prefix, ...wordPrefix, ...substring];
    if (direct.length >= 6) return direct;
    final fuzzy = <_Scored>[];
    final seen = direct.map((e) => e.name.toLowerCase()).toSet();
    final maxDist = q.length <= 3 ? 1 : 2;
    for (final e in source) {
      if (seen.contains(e.name.toLowerCase())) continue;
      var best = _levenshteinCapped(q, e.normalized, maxDist);
      for (final token in e.normalized.split(' ')) {
        if (token.isEmpty) continue;
        final d = _levenshteinCapped(q, token, maxDist);
        if (d < best) best = d;
      }
      if (best <= maxDist) fuzzy.add(_Scored(e, best));
    }
    fuzzy.sort((a, b) => a.score.compareTo(b.score));
    return [...direct, ...fuzzy.map((s) => s.entry)];
  }

  /// Relaxed fuzzy pass for the empty state — "Did you mean…?" chips.
  List<_Entry> _didYouMean(String rawQuery) {
    final q = rawQuery._normalized;
    if (q.isEmpty) return const [];
    final entries = _tab == _Tab.cities ? _cityEntries : _trekEntries;
    final maxDist = q.length <= 4 ? 2 : 3;
    final scored = <_Scored>[];
    for (final e in entries) {
      var best = _levenshteinCapped(q, e.normalized, maxDist);
      for (final token in e.normalized.split(' ')) {
        if (token.isEmpty) continue;
        final d = _levenshteinCapped(q, token, maxDist);
        if (d < best) best = d;
      }
      if (best <= maxDist) scored.add(_Scored(e, best));
    }
    scored.sort((a, b) => a.score.compareTo(b.score));
    if (scored.length > 3) scored.removeRange(3, scored.length);
    return [for (final s in scored) s.entry];
  }

  // ── BROWSE ROWS ────────────────────────────────────────────────────────
  /// Cities: flat rows with STATIC letter labels between groups (they
  /// scroll away — nothing pinned, nothing can stack). Treks: flat rows
  /// only; each row carries its own state text.
  void _buildBrowseRows() {
    if (_tab == _Tab.cities) {
      final buckets = <String, List<_Entry>>{};
      for (final e in _cityEntries) {
        final first = e.name.trim().isNotEmpty
            ? e.name.trim().toUpperCase()[0]
            : '#';
        final letter = (first.compareTo('A') >= 0 && first.compareTo('Z') <= 0)
            ? first
            : '#';
        (buckets[letter] ??= []).add(e);
      }
      final keys = buckets.keys.toList()..sort();
      if (keys.isNotEmpty && keys.first == '#') {
        keys.removeAt(0);
        keys.add('#');
      }

      final rows = <_Row>[];
      for (final k in keys) {
        rows.add(_Row.header(k));
        rows.addAll([for (final e in buckets[k]!) _Row.tile(e)]);
      }
      _browseRows = rows;
    } else {
      _browseRows = [for (final e in _trekEntries) _Row.tile(e)];
    }
  }

  /// Tab switched / query cleared → next frame, snap the browse list back
  /// to the top.
  void _resetBrowseScroll() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_scrollCtrl.hasClients) _scrollCtrl.jumpTo(0);
    });
  }

  // ── SELECTION ──────────────────────────────────────────────────────────
  Future<void> _onItemTap(_Entry entry) async {
    if (_itemTapInFlight) return;
    _itemTapInFlight = true;
    try {
      HapticFeedback.selectionClick();
      if (_tab == _Tab.cities) {
        if (entry.id == 0) return;
        _fromCityId = entry.id;
        _fromCtrl.text = entry.name;
        _fromCtrl.selection = TextSelection.collapsed(
          offset: entry.name.length,
        );
        unawaited(LocationCacheService.instance.addRecentCity(entry.name));
        if (!_hasValidToSelection) {
          _setActiveField(_Tab.treks);
        } else {
          FocusScope.of(context).unfocus();
          _query.value = '';
          setState(() {});
        }
      } else {
        if (!_hasValidFromSelection) {
          FocusScope.of(context).requestFocus(_fromFocus);
          return;
        }
        if (entry.id == 0) return;
        _selectedTrekId = entry.id;
        _toCtrl.text = entry.name;
        _toCtrl.selection = TextSelection.collapsed(offset: entry.name.length);
        unawaited(LocationCacheService.instance.addRecentTrek(entry.name));
        if (_hasValidFromSelection) {
          FocusScope.of(context).unfocus();
          await _closeWithResult();
        }
      }
    } finally {
      _itemTapInFlight = false;
    }
  }

  /// One tap fills BOTH fields — the fastest possible path for a repeat
  /// traveller. IDs are set BEFORE the text so the change-listeners'
  /// validation sees a matching selection and keeps it.
  Future<void> _onRouteTap(_RoutePair route) async {
    if (_itemTapInFlight) return;
    _itemTapInFlight = true;
    try {
      HapticFeedback.selectionClick();
      _fromCityId = route.from.id;
      _fromCtrl.text = route.from.name;
      _selectedTrekId = route.to.id;
      _toCtrl.text = route.to.name;
      unawaited(LocationCacheService.instance.addRecentCity(route.from.name));
      unawaited(LocationCacheService.instance.addRecentTrek(route.to.name));
      FocusScope.of(context).unfocus();
      _query.value = '';
      if (mounted) setState(() {});
      await _closeWithResult();
    } finally {
      _itemTapInFlight = false;
    }
  }

  Future<void> _closeWithResult() async {
    if (_navigatingBack) return;
    if (!_hasValidFromSelection || !_hasValidToSelection) return;
    _navigatingBack = true;
    HapticFeedback.mediumImpact();
    // The completed route becomes the newest "recent route" chip. This is
    // the single funnel: trek pick, CTA and route-chip tap all pass here.
    unawaited(
      LocationCacheService.instance.addRecentRoute(
        _fromCtrl.text.trim(),
        _toCtrl.text.trim(),
      ),
    );
    if (!mounted) return;
    // true → the caller refetches availability and opens the calendar.
    Navigator.pop(context, true);
  }

  void _clearField(TextEditingController controller) {
    _searchDebounce.cancel();
    if (controller == _fromCtrl) {
      _fromCtrl.clear();
      _dashboardC.fromController.value.text = '';
      _fromCityId = 0;
      // No departure → destination is meaningless; clear the cascade.
      _toCtrl.clear();
      _dashboardC.toController.value.text = '';
      _selectedTrekId = 0;
      _setActiveField(_Tab.cities);
      _query.value = '';
      _refreshFiltered();
    } else {
      _toCtrl.clear();
      _dashboardC.toController.value.text = '';
      _selectedTrekId = 0;
      _query.value = '';
      _refreshFiltered();
    }
    if (mounted) setState(() {});
  }

  /// Manual refresh of the active tab (offline banner's ↻).
  void _refreshTab() {
    _dashboardC.errorMessage.value = '';
    if (_tab == _Tab.cities) {
      _citiesError = '';
      _dashboardC.fetchCitiesList();
    } else {
      _treksError = '';
      _dashboardC.fetchTrekList();
    }
  }

  /// Error-screen retry: refetch every list that has no data at all.
  void _retry() {
    _dashboardC.errorMessage.value = '';
    if (_dashboardC.citiesData.value.data == null) {
      _citiesError = '';
      _dashboardC.fetchCitiesList();
    }
    if (_dashboardC.trekData.value.data == null) {
      _treksError = '';
      _dashboardC.fetchTrekList();
    }
  }

  void _onSubmitField() {
    final text = (_tab == _Tab.cities ? _fromCtrl : _toCtrl).text.trim();
    if (text.isEmpty) return;
    if (_tab == _Tab.cities) {
      final m = _resolveEntryByName(text);
      if (m == null || m.id == 0) {
        CustomSnackBar.show(
          context,
          message: 'No exact match — pick a city from the list',
        );
        return;
      }
      _onItemTap(m);
    } else {
      if (!_hasValidFromSelection) {
        FocusScope.of(context).requestFocus(_fromFocus);
        return;
      }
      final m = _resolveEntryByName(text);
      if (m == null || m.id == 0) {
        CustomSnackBar.show(
          context,
          message: 'No exact match — pick a trek from the list',
        );
        return;
      }
      _onItemTap(m);
    }
  }

  String? _fromErrorText() {
    if (_fromFocus.hasFocus) return null;
    if (_fromCtrl.text.trim().isNotEmpty && _fromCityId == 0) {
      return 'Pick a city from the list';
    }
    return null;
  }

  String? _toErrorText() {
    if (_toFocus.hasFocus) return null;
    if (_toCtrl.text.trim().isNotEmpty && _selectedTrekId == 0) {
      return 'Pick a trek from the list';
    }
    return null;
  }

  bool _isSelectedEntry(_Entry e) {
    if (e.id == 0) return false;
    return _tab == _Tab.cities ? _fromCityId == e.id : _selectedTrekId == e.id;
  }

  String _timeAgo(DateTime? t) {
    if (t == null) return 'earlier';
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 1) return 'just now';
    if (d.inMinutes < 60) return '${d.inMinutes} min ago';
    if (d.inHours < 24) return '${d.inHours} h ago';
    return '${d.inDays} d ago';
  }

  // ── BUILD ───────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    ScreenConstant.setScreenAwareConstant(context);
    final mq = MediaQuery.of(context);

    // The sheet's top edge stops JUST BELOW the dashboard header's logo:
    // status bar + the header's top spacing (20) + logo height (7.h) + a
    // small breathing gap. Tune the gap if the header ever changes.
    final double maxSheetHeight = mq.size.height - reservedTopFor(mq);

    // KEYBOARD: the sheet SHRINKS by the keyboard height instead of being
    // pushed up off-screen by the viewInsets padding (which is taller than
    // the reserved top gap). The top edge — drag handle + close button —
    // therefore stays pinned just below the dashboard logo whether the
    // keyboard is up or not; the Expanded body absorbs the shrink and the
    // list keeps scrolling above the keyboard.
    double sheetHeight = maxSheetHeight - mq.viewInsets.bottom;
    if (sheetHeight < 220) sheetHeight = 220;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Padding(
        // Keyboard rides up underneath the sheet's bottom edge.
        padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeOutCubic,
          builder: (context, v, child) => Transform.translate(
            offset: Offset(0, (1 - v) * 40),
            child: Opacity(opacity: v, child: child),
          ),
          child: Container(
            height: sheetHeight,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: _T.bg,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              boxShadow: [
                BoxShadow(
                  color: _T.forestDeep.withValues(alpha: 0.20),
                  blurRadius: 30,
                  offset: const Offset(0, -8),
                ),
              ],
            ),
            child: Stack(
              children: [
                SafeArea(
                  top: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSlimHeader(),
                      _buildRouteCard(),
                      Expanded(child: _buildBody()),
                    ],
                  ),
                ),
                _buildStickyFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static double reservedTopFor(MediaQueryData mq) =>
      mq.padding.top + 20 + 7.h + 12;

  // ── SLIM HEADER (handle + close only — the fields speak for themselves)
  Widget _buildSlimHeader() {
    return SizedBox(
      height: 38,
      child: Stack(
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: _T.inkLight.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: _RoundIconButton(
                icon: Icons.close_rounded,
                onTap: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── ROUTE CARD — travel-app route picker ───────────────────────────────
  //
  // Origin dot → connecting line → destination marker: the visual grammar
  // of every route picker, so the card reads as ONE journey instead of two
  // form fields. The connecting line and the card border animate to forest
  // green once the route is complete — a quiet "you're done here" cue.
  //
  // Both TextFields stay permanently mounted; the inactive step's value is
  // an overlay that fades in over the field, so focus and the keyboard
  // move between steps without detach/reattach flicker.

  Widget _buildRouteCard() {
    final routeComplete = _hasValidFromSelection && _hasValidToSelection;
    final editing = _fromFocus.hasFocus || _toFocus.hasFocus;
    final settled = routeComplete && !editing;
    final lineColor = settled ? _T.forest.withValues(alpha: 0.55) : _T.divider;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      margin: const EdgeInsets.fromLTRB(14, 4, 14, 6),
      decoration: BoxDecoration(
        color: _T.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: settled ? _T.forest.withValues(alpha: 0.30) : _T.border,
          width: 1,
        ),
        boxShadow: AppShadows.soft(0.05),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _stepRow(
            label: 'DEPARTURE CITY',
            hint: 'e.g. Delhi, Mumbai',
            controller: _fromCtrl,
            focusNode: _fromFocus,
            active: _fromFocus.hasFocus,
            done: _hasValidFromSelection,
            isOrigin: true,
            lineColor: lineColor,
            onTap: () => _setActiveField(_Tab.cities),
            errorText: _fromErrorText(),
          ),
          _stepRow(
            label: 'DESTINATION TREK',
            hint: 'e.g. Kedarkantha, Roopkund',
            controller: _toCtrl,
            focusNode: _toFocus,
            active: _toFocus.hasFocus,
            done: _hasValidToSelection,
            isOrigin: false,
            lineColor: lineColor,
            onTap: () => _setActiveField(_Tab.treks),
            errorText: _toErrorText(),
          ),
        ],
      ),
    );
  }

  Widget _stepRow({
    required String label,
    required String hint,
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool active,
    required bool done,
    required bool isOrigin,
    required Color lineColor,
    required VoidCallback onTap,
    String? errorText,
  }) {
    final value = controller.text.trim();

    return GestureDetector(
      // Inactive row = one large tap target that activates the step.
      // Active row (onTap: null) lets taps fall through to the TextField.
      behavior: HitTestBehavior.translucent,
      onTap: active ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        color: active ? _T.focusBg : Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Route marker column ─────────────────────────────────
              // The line is drawn as flex segments inside each row, so it
              // always runs marker-center → marker-center no matter how
              // the row heights change (e.g. error text appearing).
              SizedBox(
                width: 38,
                child: Column(
                  children: [
                    Expanded(
                      child: isOrigin
                          ? const SizedBox.shrink()
                          : _lineSeg(lineColor),
                    ),
                    isOrigin
                        ? _originMarker(active: active, done: done)
                        : _destMarker(active: active, done: done),
                    Expanded(
                      child: isOrigin
                          ? _lineSeg(lineColor)
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
              // ── Label + input / summary ──────────────────────────────
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppType.style(
                        FontSize.s8,
                        w: FontWeight.w700,
                        color: active
                            ? _T.forest
                            : (done ? _T.inkMid : _T.inkLight),
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    SizedBox(
                      height: 28,
                      child: Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          TextField(
                            controller: controller,
                            focusNode: focusNode,
                            onChanged: _onSearchChanged,
                            onSubmitted: (_) => _onSubmitField(),
                            textInputAction: TextInputAction.done,
                            maxLines: 1,
                            style: AppType.style(
                              12.5,
                              w: FontWeight.w600,
                              color: _T.ink,
                            ),
                            decoration: InputDecoration(
                              isCollapsed: true,
                              border: InputBorder.none,
                              hintText: hint,
                              hintStyle: AppType.style(
                                12,
                                w: FontWeight.w500,
                                color: _T.inkLight,
                              ),
                            ),
                          ),
                          // Inactive summary — covers the field beneath and
                          // fades away when the step becomes active.
                          Positioned.fill(
                            child: IgnorePointer(
                              ignoring: active,
                              child: GestureDetector(
                                onTap: active ? null : onTap,
                                child: AnimatedOpacity(
                                  duration: const Duration(milliseconds: 150),
                                  opacity: active ? 0.0 : 1.0,
                                  child: ColoredBox(
                                    color: active ? _T.focusBg : _T.card,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        value.isNotEmpty
                                            ? value
                                            : 'Tap to choose',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppType.style(
                                          value.isNotEmpty ? 12.5 : 12,
                                          w: value.isNotEmpty
                                              ? FontWeight.w600
                                              : FontWeight.w500,
                                          color: value.isNotEmpty
                                              ? _T.ink
                                              : _T.inkLight,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (errorText != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Text(
                          errorText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppType.style(
                            FontSize.s8,
                            w: FontWeight.w600,
                            color: _T.error,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // ── Clear ────────────────────────────────────────────────
              AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
                opacity: value.isNotEmpty ? 1.0 : 0.0,
                child: IgnorePointer(
                  ignoring: value.isEmpty,
                  child: GestureDetector(
                    onTap: () => _clearField(controller),
                    child: SizedBox(
                      width: 36,
                      height: 36,
                      child: Center(
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: _T.divider,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 12,
                            color: _T.inkMid,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Origin: a map-style dot — outlined when untouched, solid forest with
  /// a soft halo when active, forest circle with a check when picked.
  /// Lives in a fixed 22px box so the line endpoints never jump.
  Widget _originMarker({required bool active, required bool done}) {
    return SizedBox(
      width: 22,
      height: 22,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: done ? 20 : (active ? 14 : 10),
          height: done ? 20 : (active ? 14 : 10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done || active ? _T.forest : _T.card,
            border: done || active
                ? null
                : Border.all(color: _T.inkLight, width: 2.2),
            boxShadow: (active && !done)
                ? [
                    BoxShadow(
                      color: _T.forest.withValues(alpha: 0.30),
                      blurRadius: 8,
                      spreadRadius: 3,
                    ),
                  ]
                : null,
          ),
          child: done
              ? const Icon(Icons.check_rounded, size: 12, color: Colors.white)
              : null,
        ),
      ),
    );
  }

  /// Destination: a mountain badge — outlined terrain icon when untouched,
  /// solid forest when active, check when picked.
  Widget _destMarker({required bool active, required bool done}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: (done || active) ? _T.forest : _T.card,
        borderRadius: BorderRadius.circular(8),
        border: (done || active)
            ? null
            : Border.all(color: _T.divider, width: 1.4),
        boxShadow: (active && !done)
            ? [
                BoxShadow(
                  color: _T.forest.withValues(alpha: 0.30),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Icon(
        done ? Icons.check_rounded : Icons.terrain_rounded,
        size: 14,
        color: (done || active) ? Colors.white : _T.inkLight,
      ),
    );
  }

  /// One half of the connecting route line (animated so the "route
  /// complete" green flows through it).
  Widget _lineSeg(Color color) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 2,
      color: color,
    );
  }

  // ── BODY ───────────────────────────────────────────────────────────────
  Widget _buildBody() {
    return Obx(() {
      final result = _filtered.value;
      final isSearching = (result.query ?? '').trim().isNotEmpty;

      if (result.state == _ListState.loading ||
          result.state == _ListState.idle) {
        return _buildShimmer();
      }
      if (result.state == _ListState.error ||
          result.state == _ListState.noNetwork) {
        return _buildError(
          result.state == _ListState.noNetwork
              ? 'No internet connection'
              : _errorMessage,
        );
      }
      if (result.state == _ListState.empty) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_servingCacheOnTab) _buildCacheBanner(),
            Expanded(child: _buildEmpty(result.query ?? '')),
          ],
        );
      }

      // Ready. One scrollable surface: the chip sections are the list's
      // leading content, so they scroll away and come back with plain
      // scrolling — no animations, no viewport resizing, nothing to
      // misfire. The ONLY fixed element above the list is the offline
      // banner (it's status, not content).
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_servingCacheOnTab) _buildCacheBanner(),
          if (isSearching) _buildMatchCount(result.items.length),
          Expanded(
            child: isSearching
                ? _buildSearchList(result)
                : _buildBrowseList(result),
          ),
        ],
      );
    });
  }

  /// Amber, honest, dismissible-by-success: shows only while the list on
  /// screen is literally the disk-cached copy and the network hasn't
  /// landed yet (or failed).
  Widget _buildCacheBanner() {
    final isCities = _tab == _Tab.cities;
    final savedAt = isCities
        ? LocationCacheService.instance.citiesSavedAt
        : LocationCacheService.instance.treksSavedAt;
    final failed = (isCities ? _citiesError : _treksError).isNotEmpty;
    final refreshing = _dashboardC.isLoadingCities.value;
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 6, 20, 0),
      padding: const EdgeInsets.fromLTRB(10, 5, 2, 5),
      decoration: BoxDecoration(
        color: _T.warningSoft,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: _T.warning.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(
            failed ? Icons.cloud_off_rounded : Icons.history_rounded,
            size: 14,
            color: _T.warning,
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              failed
                  ? "Couldn't refresh — showing your saved list"
                  : 'Updating your saved list…',
              style: AppType.style(
                FontSize.s9,
                w: FontWeight.w600,
                color: _T.ink,
              ),
            ),
          ),
          Text(
            'Updated ${_timeAgo(savedAt)}',
            style: AppType.style(FontSize.s8, color: _T.inkMid),
          ),
          const SizedBox(width: 2),
          refreshing
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: Padding(
                    padding: EdgeInsets.all(3),
                    child: CircularProgressIndicator(
                      strokeWidth: 1.8,
                      color: _T.warning,
                    ),
                  ),
                )
              : IconButton(
                  onPressed: _refreshTab,
                  icon: const Icon(
                    Icons.refresh_rounded,
                    size: 16,
                    color: _T.warning,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildMatchCount(int n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 10, 24, 2),
      child: Text(
        '$n match${n == 1 ? '' : 'es'}',
        style: AppType.style(
          FontSize.s9,
          w: FontWeight.w600,
          color: _T.inkLight,
        ),
      ),
    );
  }

  /// The suggestion sections shown at the top of the browse list.
  /// Returns them as widgets so the list can embed them as content.
  List<Widget> _buildChipSections(_FilterResult result) {
    final routes = result.routes;
    final recents = result.recent;

    // Cities: curated tier-1 metros first (in curated order), then any
    // API-flagged popular cities not already included. The isPopular
    // flag alone is sparsely set for cities, which is why top metros
    // never surfaced before. Treks: API-flagged only.
    final List<_Entry> popular;
    final String popularTitle;
    final IconData popularIcon;
    final Color popularIconColor;
    if (_tab == _Tab.cities) {
      final seen = <String>{};
      popular = [];
      for (final n in _kTopCityNames) {
        final e = _cityByName[n.trim().toLowerCase()];
        if (e != null && e.id != 0 && seen.add(e.name.toLowerCase())) {
          popular.add(e);
        }
      }
      for (final e in _cityEntries) {
        if (e.isPopular && seen.add(e.name.toLowerCase())) popular.add(e);
      }
      popularTitle = 'TOP CITIES';
      popularIcon = Icons.location_city_rounded;
      popularIconColor = _T.forest;
    } else {
      popular = _trekEntries.where((e) => e.isPopular).toList();
      popularTitle = 'POPULAR TREKS';
      popularIcon = Icons.local_fire_department_rounded;
      popularIconColor = _T.amber;
    }

    final sections = <Widget>[];
    if (routes.isNotEmpty) {
      sections.add(
        _chipSection(
          title: _tab == _Tab.treks
              ? 'FROM ${_fromCtrl.text.trim().toUpperCase()}'
              : 'RECENT ROUTES',
          icon: Icons.route_rounded,
          iconColor: _T.forest,
          count: routes.length,
          itemBuilder: (i) => _RouteChip(
            route: routes[i],
            compact: _tab == _Tab.treks,
            onTap: () => _onRouteTap(routes[i]),
          ),
          // Clearing wipes the ENTIRE route history — only offered on
          // the departure step, where all routes are actually visible.
          trailing: _tab == _Tab.cities
              ? GestureDetector(
                  onTap: () {
                    unawaited(
                      LocationCacheService.instance.clearRecentRoutes(),
                    );
                    _refreshFiltered();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Text(
                      'Clear',
                      style: AppType.style(
                        FontSize.s9,
                        w: FontWeight.w700,
                        color: _T.clay,
                      ),
                    ),
                  ),
                )
              : null,
        ),
      );
    }
    if (recents.isNotEmpty) {
      sections.add(
        _chipSection(
          title: 'RECENT',
          icon: Icons.history_rounded,
          iconColor: _T.inkMid,
          count: recents.length > 6 ? 6 : recents.length,
          itemBuilder: (i) => _SuggestionChip(
            label: recents[i].name,
            isRecent: true,
            onTap: () => _onItemTap(recents[i]),
          ),
          trailing: GestureDetector(
            onTap: () {
              unawaited(
                _tab == _Tab.cities
                    ? LocationCacheService.instance.clearRecentCities()
                    : LocationCacheService.instance.clearRecentTreks(),
              );
              _refreshFiltered();
            },
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Text(
                'Clear',
                style: AppType.style(
                  FontSize.s9,
                  w: FontWeight.w700,
                  color: _T.clay,
                ),
              ),
            ),
          ),
        ),
      );
    }
    if (popular.isNotEmpty) {
      sections.add(
        _chipSection(
          title: popularTitle,
          icon: popularIcon,
          iconColor: popularIconColor,
          count: popular.length > 10 ? 10 : popular.length,
          itemBuilder: (i) => _SuggestionChip(
            label: popular[i].name,
            isRecent: false,
            icon: popularIcon,
            iconColor: popularIconColor,
            onTap: () => _onItemTap(popular[i]),
          ),
        ),
      );
    }
    return sections;
  }

  /// One labelled horizontal chip row (title + icon + optional trailing
  /// action + scrollable chips). Shared by routes / recents / popular.
  Widget _chipSection({
    required String title,
    required IconData icon,
    required Color iconColor,
    required int count,
    required Widget Function(int) itemBuilder,
    Widget? trailing,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(26, 8, 20, 5),
          child: Row(
            children: [
              Icon(icon, size: 12, color: iconColor),
              const SizedBox(width: 5),
              Text(
                title,
                style: AppType.style(
                  FontSize.s8,
                  w: FontWeight.w800,
                  color: _T.inkMid,
                  letterSpacing: 1,
                ),
              ),
              const Spacer(),
              if (trailing != null) trailing,
            ],
          ),
        ),
        SizedBox(
          height: 38,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: count,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (ctx, i) => itemBuilder(i),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchList(_FilterResult result) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 2, 20, 90),
      itemCount: result.items.length,
      itemBuilder: (ctx, i) => _EntryTile(
        entry: result.items[i],
        query: result.query ?? '',
        isCity: _tab == _Tab.cities,
        isSelected: _isSelectedEntry(result.items[i]),
        showState: _tab == _Tab.treks,
        onTap: () => _onItemTap(result.items[i]),
      ),
    );
  }

  /// Browse surface — ONE scroll view. The chip sections (routes /
  /// recents / top cities / popular treks) are the list's leading
  /// content, followed by a labeled divider, then the full list. They
  /// scroll away with the content and come back with plain scrolling:
  /// the standard, unfailable pattern.
  Widget _buildBrowseList(_FilterResult result) {
    final sections = _buildChipSections(result);
    final hasSections = sections.isNotEmpty;

    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 90),
      itemCount: _browseRows.length + (hasSections ? 2 : 0),
      itemBuilder: (ctx, i) {
        if (hasSections) {
          if (i == 0) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [const SizedBox(height: 6), ...sections],
            );
          }
          if (i == 1) {
            return _ListDividerHeader(
              label: _tab == _Tab.cities ? 'ALL CITIES' : 'ALL TREKS',
            );
          }
          i -= 2;
        }
        final row = _browseRows[i];
        if (row.isHeader) return _LetterHeader(row.label!);
        final e = row.entry!;
        return _EntryTile(
          entry: e,
          query: '',
          isCity: _tab == _Tab.cities,
          isSelected: _isSelectedEntry(e),
          showState: _tab == _Tab.treks,
          onTap: () => _onItemTap(e),
        );
      },
    );
  }

  /// Hidden while a field is focused — with the keyboard up the footer
  /// would just float over the list. Slides in when focus drops.
  Widget _buildStickyFooter() {
    final editing = _fromFocus.hasFocus || _toFocus.hasFocus;
    final canContinue = _hasValidFromSelection && _hasValidToSelection;
    final show = canContinue && !editing;
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      bottom: show ? 16 : -120,
      left: 20,
      right: 20,
      child: AppButton.primary(
        text: 'Choose Departure Date',
        onPressed: _closeWithResult,
        prefixIcon: const Icon(
          Icons.calendar_month_rounded,
          size: 20,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      itemCount: 9,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (_, i) {
        if (i == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                for (var k = 0; k < 3; k++)
                  Container(
                    width: const [110.0, 96.0, 84.0][k],
                    height: 34,
                    margin: EdgeInsets.only(right: k == 2 ? 0 : 8),
                    decoration: BoxDecoration(
                      color: _T.skeleton,
                      borderRadius: BorderRadius.circular(17),
                    ),
                  ),
              ],
            ),
          );
        }
        return Container(
          margin: const EdgeInsets.only(bottom: 4),
          height: _kTileExtent,
          child: Row(
            children: [
              const SizedBox(width: 10),
              Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: _T.skeleton,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: _T.skeleton,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              const SizedBox(width: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmpty(String q) {
    final suggestions = _didYouMean(q);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: const BoxDecoration(
                color: _T.forestSoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 30,
                color: _T.forest,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'No matches for "$q"',
              textAlign: TextAlign.center,
              style: AppType.style(
                FontSize.s13,
                w: FontWeight.w700,
                color: _T.ink,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Check the spelling, or try one of these',
              textAlign: TextAlign.center,
              style: AppType.style(10.5, color: _T.inkMid),
            ),
            if (suggestions.isNotEmpty) ...[
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  for (final e in suggestions)
                    _SuggestionChip(
                      label: e.name,
                      isRecent: false,
                      onTap: () => _onItemTap(e),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildError(String msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: const BoxDecoration(
                color: _T.forestSoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                size: 30,
                color: _T.forest,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              "Couldn't load the list",
              style: AppType.style(
                FontSize.s13,
                w: FontWeight.w700,
                color: _T.ink,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              msg,
              textAlign: TextAlign.center,
              style: AppType.style(10.5, color: _T.inkMid, height: 1.4),
            ),
            const SizedBox(height: 16),
            AppButton.secondary(
              text: 'Retry',
              onPressed: _retry,
              isFullWidth: false,
              width: 128,
              height: 40,
              prefixIcon: const Icon(
                Icons.refresh_rounded,
                size: 16,
                color: AppColors.forest,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  PIECES
// ─────────────────────────────────────────────

/// The labeled boundary between the suggestion sections and the full
/// list, inside the shared scroll view. "───── ALL CITIES ─────"
class _ListDividerHeader extends StatelessWidget {
  const _ListDividerHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 6),
      child: Row(
        children: [
          const Expanded(child: Divider(height: 1, color: _T.divider)),
          const SizedBox(width: 10),
          Text(
            label,
            style: AppType.style(
              FontSize.s8,
              w: FontWeight.w800,
              color: _T.inkLight,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(child: Divider(height: 1, color: _T.divider)),
        ],
      ),
    );
  }
}

/// Static letter label between city groups. Scrolls away with the list —
/// deliberately NOT pinned, so nothing can ever pile up at the top edge.
class _LetterHeader extends StatelessWidget {
  const _LetterHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _kCityHeaderExtent,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          width: 20,
          height: 18,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _T.forestSoft,
            borderRadius: BorderRadius.circular(6),
          ),
          child: FittedBox(
            child: Text(
              label,
              style: AppType.style(
                FontSize.s8,
                w: FontWeight.w800,
                color: _T.forestDeep,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Dense 44px single-line row. Deliberately lightweight: a plain
/// GestureDetector + Containers (no Material/InkWell/AnimatedContainer —
/// hundreds of implicit animation controllers inside a scrolling list
/// were a real jank source). Cities: dot + name. Treks: icon + name,
/// with state (or a POPULAR badge) as trailing context.
class _EntryTile extends StatelessWidget {
  const _EntryTile({
    required this.entry,
    required this.query,
    required this.isCity,
    required this.isSelected,
    required this.showState,
    required this.onTap,
  });

  final _Entry entry;
  final String query;
  final bool isCity;
  final bool isSelected;
  final bool showState;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final nameStyle = AppType.style(
      FontSize.s12,
      w: isSelected ? FontWeight.w700 : FontWeight.w600,
      color: isSelected ? _T.forestDeep : _T.ink,
    );
    final range = _matchRange(entry.name, query);
    final Widget name;
    if (range == null) {
      name = Text(
        entry.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: nameStyle,
      );
    } else {
      name = Text.rich(
        TextSpan(
          style: nameStyle,
          children: [
            TextSpan(text: entry.name.substring(0, range.start)),
            TextSpan(
              text: entry.name.substring(range.start, range.end),
              style: nameStyle.copyWith(
                color: _T.forest,
                fontWeight: FontWeight.w800,
              ),
            ),
            TextSpan(text: entry.name.substring(range.end)),
          ],
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    final Widget leading;
    if (isCity) {
      leading = isSelected
          ? Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: _T.forest,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 12,
                color: Colors.white,
              ),
            )
          : Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: _T.inkLight,
                shape: BoxShape.circle,
              ),
            );
    } else {
      leading = Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: isSelected ? _T.forest : _T.forestSoft,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          isSelected ? Icons.check_rounded : Icons.hiking_rounded,
          size: 13,
          color: isSelected ? Colors.white : _T.forest,
        ),
      );
    }

    Widget? trailing;
    if (!isSelected && entry.isPopular) {
      trailing = Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.amberSoft,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.local_fire_department_rounded,
              size: 8,
              color: _T.amber,
            ),
            const SizedBox(width: 3),
            Text(
              'POPULAR',
              style: AppType.style(
                FontSize.s7,
                w: FontWeight.w800,
                color: _T.amber,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      );
    } else if (!isCity && showState && (entry.state ?? '').isNotEmpty) {
      trailing = ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 96),
        child: Text(
          entry.state!,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.right,
          style: AppType.style(FontSize.s8, color: _T.inkLight),
        ),
      );
    }

    return SizedBox(
      height: _kTileExtent,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          color: isSelected ? _T.forestSoft : Colors.transparent,
          child: Row(
            children: [
              SizedBox(width: 24, height: 24, child: Center(child: leading)),
              const SizedBox(width: 10),
              Expanded(child: name),
              if (trailing != null) ...[const SizedBox(width: 8), trailing],
            ],
          ),
        ),
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({
    required this.label,
    required this.isRecent,
    required this.onTap,
    this.icon,
    this.iconColor,
  });

  final String label;
  final bool isRecent;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final IconData effectiveIcon =
        icon ??
        (isRecent
            ? Icons.history_rounded
            : Icons.local_fire_department_rounded);
    final Color effectiveColor =
        iconColor ?? (isRecent ? _T.inkLight : _T.amber);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: _T.card,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: _T.border, width: 0.8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(effectiveIcon, size: 11, color: effectiveColor),
            const SizedBox(width: 5),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 34.w),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppType.style(
                  FontSize.s10,
                  w: FontWeight.w600,
                  color: _T.ink,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A recent full route. Departure step: "Delhi → Kedarkantha". Destination
/// step (compact): "→ Kedarkantha" — the departure is already locked in
/// and shown in the card above, so the chip only names the trek.
class _RouteChip extends StatelessWidget {
  const _RouteChip({
    required this.route,
    required this.onTap,
    this.compact = false,
  });

  final _RoutePair route;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      color: _T.card,
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: _T.forest.withValues(alpha: 0.30), width: 0.9),
    );

    if (compact) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: decoration,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.arrow_forward_rounded, size: 11, color: _T.clay),
              const SizedBox(width: 5),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 38.w),
                child: Text(
                  route.to.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppType.style(
                    FontSize.s10,
                    w: FontWeight.w700,
                    color: _T.forestDeep,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: decoration,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.route_rounded, size: 12, color: _T.forest),
            const SizedBox(width: 6),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 26.w),
              child: Text(
                route.from.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppType.style(
                  FontSize.s10,
                  w: FontWeight.w600,
                  color: _T.ink,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Icon(
                Icons.arrow_forward_rounded,
                size: 10,
                color: _T.clay,
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 28.w),
              child: Text(
                route.to.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppType.style(
                  FontSize.s10,
                  w: FontWeight.w700,
                  color: _T.forestDeep,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.onTap,
    this.size = 16,
    this.box = 32,
  });

  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final double box;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: box,
      height: box,
      child: Material(
        color: _T.card,
        shape: const CircleBorder(
          side: BorderSide(color: _T.border, width: 0.8),
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Center(
            child: Icon(icon, size: size, color: _T.inkMid),
          ),
        ),
      ),
    );
  }
}
