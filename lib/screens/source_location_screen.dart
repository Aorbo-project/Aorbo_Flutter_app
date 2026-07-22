import 'dart:async';
import 'dart:collection';

import 'package:arobo_app/controller/dashboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:arobo_app/utils/screen_constants.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

// ─────────────────────────────────────────────
//  TREKKING THEME TOKENS
// ─────────────────────────────────────────────
class _T {
  // Greens — pine forest
  static const pineDark = Color(0xFF122B20);
  static const pine = Color(0xFF1B4332);
  static const forest = Color(0xFF2D6A4F);
  static const moss = Color(0xFF52B788);
  static const mossSoft = Color(0xFFDCEFE2);

  // Earth accent — terracotta / sunrise
  static const clay = Color(0xFFCB6D42);
  static const claySoft = Color(0xFFFBEEE6);

  // Surfaces — bg/heroBg matched to the app-wide standard background
  // (CommonColors.offWhiteColor, 0xFFFAFAFA) used on Trek Details, Checkout,
  // My Account, etc. This screen previously had its own tinted F4F6F1/EEF7F1
  // pair, which stood out against every other screen's near-white body.
  static const bg = Color(0xFFFAFAFA);
  static const card = Colors.white;
  static const focusBg = Color(0xFFEFF5EF);
  static const divider = Color(0xFFE4E9E2);
  static const heroBg = Color(0xFFFAFAFA);

  // Ink
  static const ink = Color(0xFF16261E);
  static const inkMid = Color(0xFF5C6F63);
  static const inkLight = Color(0xFF9DABA1);

  // Feedback
  static const error = Color(0xFFC13A2B);
  static const errorSoft = Color(0xFFFCEDEA);
}

enum _Tab { cities, treks }

enum _ListState { idle, loading, empty, error, noNetwork, ready }

// ─────────────────────────────────────────────
//  FALLBACK POPULAR DATA (shown when API data
//  is unavailable, loading, or empty)
// ─────────────────────────────────────────────
const List<String> _popularCitiesFallback = [
  'Hyderabad',
  'Bangalore',
  'Chennai',
  'Mumbai',
  'Pune',
  'Delhi',
  'Kolkata',
  'Visakhapatnam',
  'Mysore',
  'Coimbatore',
  'Kochi',
  'Goa',
];

const List<String> _popularTreksFallback = [
  'Manali',
  'Gokarna',
  'Coorg',
  'Wayanad',
  'Kodaikanal',
  'Ooty',
  'Darjeeling',
  'Rishikesh',
  'McLeod Ganj',
  'Spiti Valley',
  'Valley of Flowers',
  'Hampta Pass',
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

  void dispose() {
    _t?.cancel();
    _t = null;
  }
}

class _RecentSearches {
  static final _cities = <String>[];
  static final _treks = <String>[];
  static const _max = 8;

  static List<String> of(_Tab tab) =>
      List<String>.unmodifiable(tab == _Tab.cities ? _cities : _treks);

  static void add(_Tab tab, String value) {
    final list = tab == _Tab.cities ? _cities : _treks;
    list.removeWhere((e) => e.toLowerCase() == value.toLowerCase());
    list.insert(0, value);
    if (list.length > _max) list.removeLast();
  }

  static void clear(_Tab tab) {
    (tab == _Tab.cities ? _cities : _treks).clear();
  }
}

// ─────────────────────────────────────────────
//  MAIN WIDGET
// ─────────────────────────────────────────────
class SourceLocationScreen extends StatefulWidget {
  const SourceLocationScreen({super.key});

  @override
  State<SourceLocationScreen> createState() => _SourceLocationScreenState();
}

class _SourceLocationScreenState extends State<SourceLocationScreen>
    with TickerProviderStateMixin {
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

  List<String> _citiesSorted = const [];
  List<String> _treksSorted = const [];
  final Map<String, _NormalizedEntry> _cityIndex = HashMap();
  final Map<String, _NormalizedEntry> _trekIndex = HashMap();

  final Rx<_FilterResult> _filtered = Rx<_FilterResult>(
    const _FilterResult(state: _ListState.idle, items: []),
  );

  late final AnimationController _listFadeCtrl;
  late final Animation<double> _listFade;
  late final AnimationController _tabCtrl;

  bool _navigatingBack = false;
  bool _itemTapInFlight = false;
  bool _tabSwitchInFlight = false;

  // Pending (fallback) selections: name waiting to be resolved to a real ID
  // once the API delivers matching data.
  String? _pendingCityName;
  String? _pendingTrekName;

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

    _listFadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    )..value = 1.0;
    _listFade = CurvedAnimation(parent: _listFadeCtrl, curve: Curves.easeOut);

    _tabCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
      value: 0,
    );

    _fromCtrl.addListener(_onFromChanged);
    _toCtrl.addListener(_onToChanged);
    _fromFocus.addListener(_onFromFocusChange);
    _toFocus.addListener(_onToFocusChange);

    _citiesWorker = ever(_dashboardC.citiesData, (_) {
      if (!mounted) return;
      final data = _dashboardC.citiesData.value.data;
      if (data != null) {
        _citiesError = '';
        // Re-resolve a pending fallback city name to a real ID.
        if (_pendingCityName != null) {
          final m = _resolveCityByName(_pendingCityName!);
          if (m != null && m.id != 0) {
            _fromCityId = m.id;
            _pendingCityName = null;
            _maybeAutoComplete();
          }
        }
      }
      _rebuildCityCache();
      _refreshFiltered();
    });

    _treksWorker = ever(_dashboardC.trekData, (_) {
      if (!mounted) return;
      final data = _dashboardC.trekData.value.data;
      if (data != null) {
        _treksError = '';
        if (_pendingTrekName != null) {
          final m = _resolveTrekByName(_pendingTrekName!);
          if (m != null && m.id != 0) {
            _selectedTrekId = m.id;
            _pendingTrekName = null;
            _maybeAutoComplete();
          }
        }
      }
      _rebuildTrekCache();
      _refreshFiltered();
    });

    _errorWorker = ever(_dashboardC.errorMessage, (err) {
      if (!mounted) return;
      if (err.toLowerCase().contains('cities')) {
        _citiesError = err;
      }
      if (err.toLowerCase().contains('trek')) {
        _treksError = err;
      }
      _refreshFiltered();
    });

    _loadingWorker = ever(_dashboardC.isLoadingCities, (_) {
      if (!mounted) return;
      _refreshFiltered();
    });

    _rebuildCityCache();
    _rebuildTrekCache();
    _revalidatePersistedIds();

    // Bootstrap fetches if not already loaded (the dashboard screen may not
    // have triggered them before navigating here).
    if (_dashboardC.citiesData.value.data == null && _citiesError.isEmpty) {
      _dashboardC.fetchCitiesList();
    }
    if (_dashboardC.trekData.value.data == null && _treksError.isEmpty) {
      _dashboardC.fetchTrekList();
    }

    _querySub = _query.listen((_) => _refreshFiltered());

    // Explicit initial refresh so we never render the stale idle empty state.
    _refreshFiltered();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final fromValid = _hasValidFromSelection;
      if (fromValid) {
        setState(() {
          _tab = _Tab.treks;
          _tabCtrl.value = 1.0;
        });
        _query.value = _toCtrl.text;
      }
      // Ensure the list reflects the active tab/field immediately.
      _refreshFiltered();
      FocusScope.of(context).requestFocus(fromValid ? _toFocus : _fromFocus);
    });
  }

  int get _fromCityId => _dashboardC.selectedCityId.value;
  int get _selectedTrekId => _dashboardC.selectedTrekId.value;
  set _fromCityId(int v) => _dashboardC.selectedCityId.value = v;
  set _selectedTrekId(int v) => _dashboardC.selectedTrekId.value = v;

  bool get _hasValidFromSelection =>
      _fromCityId != 0 || _pendingCityName != null;
  bool get _hasValidToSelection =>
      _selectedTrekId != 0 || _pendingTrekName != null;

  void _maybeAutoComplete() {
    if (_fromCityId != 0 && _selectedTrekId != 0 && !_navigatingBack) {
      _closeWithResult();
    }
  }

  void _onFromChanged() {
    final text = _fromCtrl.text;
    _dashboardC.fromController.value.text = text;
    if (_fromCityId != 0) {
      final selectedName = _nameForCityId(_fromCityId);
      if (selectedName == null ||
          selectedName.toLowerCase() != text.trim().toLowerCase()) {
        _fromCityId = 0;
      }
    }
    // If user edits the text, the pending fallback selection is no longer
    // trustworthy.
    if (_pendingCityName != null &&
        _pendingCityName!.toLowerCase() != text.trim().toLowerCase()) {
      _pendingCityName = null;
    }
    if (mounted) setState(() {});
  }

  void _onToChanged() {
    final text = _toCtrl.text;
    _dashboardC.toController.value.text = text;
    if (_selectedTrekId != 0) {
      final selectedName = _nameForTrekId(_selectedTrekId);
      if (selectedName == null ||
          selectedName.toLowerCase() != text.trim().toLowerCase()) {
        _selectedTrekId = 0;
      }
    }
    if (_pendingTrekName != null &&
        _pendingTrekName!.toLowerCase() != text.trim().toLowerCase()) {
      _pendingTrekName = null;
    }
    if (mounted) setState(() {});
  }

  void _onFromFocusChange() {
    if (!mounted || _itemTapInFlight) return;
    if (_fromFocus.hasFocus && _tab != _Tab.cities) {
      _setTab(_Tab.cities);
    }
    if (mounted) setState(() {});
  }

  void _onToFocusChange() {
    if (!mounted || _itemTapInFlight) return;
    if (_toFocus.hasFocus && _tab != _Tab.treks) {
      if (!_hasValidFromSelection) {
        FocusScope.of(context).requestFocus(_fromFocus);
        return;
      }
      _setTab(_Tab.treks);
    }
    if (mounted) setState(() {});
  }

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
    _listFadeCtrl.dispose();
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _setTab(_Tab tab, {bool animate = true}) async {
    if (_tab == tab) return;
    if (_tabSwitchInFlight) return;
    _tabSwitchInFlight = true;
    try {
      if (tab == _Tab.treks && !_hasValidFromSelection) {
        FocusScope.of(context).requestFocus(_fromFocus);
        return;
      }
      if (animate) {
        await _listFadeCtrl.reverse();
        if (!mounted) return;
      }
      setState(() => _tab = tab);
      if (tab == _Tab.cities) {
        _tabCtrl.reverse();
      } else {
        _tabCtrl.forward();
      }
      _query.value = _activeRawText;
      _listFadeCtrl.forward();
      // Always refresh after a tab switch — even if _query didn't emit
      // (e.g. both fields empty → same value → no listener fire).
      _refreshFiltered();
    } finally {
      _tabSwitchInFlight = false;
    }
  }

  String get _activeRawText =>
      _tab == _Tab.cities ? _fromCtrl.text : _toCtrl.text;

  // ── Cache rebuild — merges API data with fallback popular data
  void _rebuildCityCache() {
    final apiData = _dashboardC.citiesData.value.data;
    final entries = <_NamedEntry>[];
    final seen = <String>{};

    if (apiData != null) {
      for (final c in apiData) {
        final name = (c.cityName ?? '').trim();
        if (name.isEmpty) continue;
        final lower = name.toLowerCase();
        if (seen.contains(lower)) continue;
        seen.add(lower);
        entries.add(_NamedEntry(id: c.id ?? 0, name: name));
      }
    }

    for (final name in _popularCitiesFallback) {
      final lower = name.toLowerCase();
      if (!seen.contains(lower)) {
        seen.add(lower);
        entries.add(_NamedEntry(id: 0, name: name));
      }
    }

    entries.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
    _citiesSorted = entries.map((e) => e.name).toList(growable: false);
    _cityIndex
      ..clear()
      ..addAll({
        for (final e in entries)
          e.name.toLowerCase(): _NormalizedEntry(
            id: e.id,
            normalized: e.name._normalized,
          ),
      });
  }

  void _rebuildTrekCache() {
    final apiData = _dashboardC.trekData.value.data;
    final entries = <_NamedEntry>[];
    final seen = <String>{};

    if (apiData != null) {
      for (final t in apiData) {
        final name = (t.name ?? '').trim();
        if (name.isEmpty) continue;
        final lower = name.toLowerCase();
        if (seen.contains(lower)) continue;
        seen.add(lower);
        entries.add(_NamedEntry(id: t.id ?? 0, name: name));
      }
    }

    for (final name in _popularTreksFallback) {
      final lower = name.toLowerCase();
      if (!seen.contains(lower)) {
        seen.add(lower);
        entries.add(_NamedEntry(id: 0, name: name));
      }
    }

    entries.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
    _treksSorted = entries.map((e) => e.name).toList(growable: false);
    _trekIndex
      ..clear()
      ..addAll({
        for (final e in entries)
          e.name.toLowerCase(): _NormalizedEntry(
            id: e.id,
            normalized: e.name._normalized,
          ),
      });
  }

  void _revalidatePersistedIds() {
    if (_fromCityId != 0 && _nameForCityId(_fromCityId) == null) {
      _fromCityId = 0;
      if (_fromCtrl.text.isNotEmpty) _fromCtrl.clear();
    }
    if (_selectedTrekId != 0 && _nameForTrekId(_selectedTrekId) == null) {
      _selectedTrekId = 0;
      if (_toCtrl.text.isNotEmpty) _toCtrl.clear();
    }
  }

  String? _nameForCityId(int id) {
    if (id == 0) return null;
    final data = _dashboardC.citiesData.value.data;
    if (data == null) return null;
    for (final c in data) {
      if ((c.id ?? 0) == id) return (c.cityName ?? '').trim();
    }
    return null;
  }

  String? _nameForTrekId(int id) {
    if (id == 0) return null;
    final data = _dashboardC.trekData.value.data;
    if (data == null) return null;
    for (final t in data) {
      if ((t.id ?? 0) == id) return (t.name ?? '').trim();
    }
    return null;
  }

  void _onSearchChanged(String value) {
    _searchDebounce.run(() {
      if (!mounted) return;
      _query.value = value;
    });
  }

  // ── Core filtering + state resolution
  void _refreshFiltered() {
    if (!mounted) return;

    final query = _query.value.trim();
    final source = _tab == _Tab.cities ? _citiesSorted : _treksSorted;
    final tabError = _tab == _Tab.cities ? _citiesError : _treksError;

    if (source.isNotEmpty) {
      _loadingTimeout?.cancel();
      _loadingTimeout = null;

      if (query.isEmpty) {
        _filtered.value = _FilterResult(
          state: _ListState.ready,
          items: source,
          recent: _RecentSearches.of(_tab),
        );
        return;
      }

      final result = _computeFiltered(source, query);
      _filtered.value = _FilterResult(
        state: result.isEmpty ? _ListState.empty : _ListState.ready,
        items: result,
        query: query,
      );
      return;
    }

    if (tabError.isNotEmpty) {
      _loadingTimeout?.cancel();
      _loadingTimeout = null;
      _errorMessage = tabError;
      _filtered.value = _FilterResult(
        state: _isNetworkError(tabError)
            ? _ListState.noNetwork
            : _ListState.error,
        items: const [],
      );
      return;
    }

    _loadingTimeout?.cancel();
    // Set the message BEFORE flipping state — otherwise the Obx rebuild
    // could read a stale _errorMessage.
    _loadingTimeout = Timer(const Duration(seconds: 15), () {
      if (!mounted) return;
      _errorMessage = 'Taking too long to load. Please check your connection.';
      _filtered.value = const _FilterResult(state: _ListState.error, items: []);
    });
    _filtered.value = const _FilterResult(state: _ListState.loading, items: []);
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

  List<String> _computeFiltered(List<String> source, String rawQuery) {
    final q = rawQuery._normalized;
    if (q.isEmpty) return source;

    final prefix = <String>[];
    final wordPrefix = <String>[];
    final substring = <String>[];
    final indexMap = _tab == _Tab.cities ? _cityIndex : _trekIndex;

    for (final item in source) {
      final lower = item.toLowerCase();
      final norm = indexMap[lower]?.normalized ?? item._normalized;
      if (norm.startsWith(q)) {
        prefix.add(item);
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
        wordPrefix.add(item);
      } else if (norm.contains(q)) {
        substring.add(item);
      }
    }

    final direct = [...prefix, ...wordPrefix, ...substring];
    if (direct.length >= 6) return direct;

    final fuzzy = <_Scored>[];
    final seen = {
      ...prefix,
      ...wordPrefix,
      ...substring,
    }.map((s) => s.toLowerCase()).toSet();
    final maxDist = q.length <= 3 ? 1 : 2;
    for (final item in source) {
      if (seen.contains(item.toLowerCase())) continue;
      final lower = item.toLowerCase();
      final norm = indexMap[lower]?.normalized ?? item._normalized;
      var best = _levenshteinCapped(q, norm, maxDist);
      for (final token in norm.split(' ')) {
        if (token.isEmpty) continue;
        final d = _levenshteinCapped(q, token, maxDist);
        if (d < best) best = d;
      }
      if (best <= maxDist) {
        fuzzy.add(_Scored(item, best));
      }
    }
    fuzzy.sort((a, b) => a.score.compareTo(b.score));
    return [...direct, ...fuzzy.map((s) => s.item)];
  }

  // ── Item selection
  Future<void> _onItemTap(String value) async {
    if (_itemTapInFlight) return;
    _itemTapInFlight = true;
    try {
      HapticFeedback.selectionClick();

      if (_tab == _Tab.cities) {
        final match = _resolveCityByName(value);
        if (match == null) return;

        if (match.id != 0) {
          _fromCityId = match.id;
          _pendingCityName = null;
        } else {
          // Fallback item — accept optimistically, resolve when API lands.
          _fromCityId = 0;
          _pendingCityName = match.name;
        }
        _fromCtrl.text = match.name;
        _fromCtrl.selection = TextSelection.collapsed(
          offset: match.name.length,
        );
        _RecentSearches.add(_Tab.cities, match.name);

        if (_selectedTrekId != 0 ||
            _pendingTrekName != null ||
            _toCtrl.text.isNotEmpty) {
          _toCtrl.clear();
          _dashboardC.toController.value.text = '';
          _selectedTrekId = 0;
          _pendingTrekName = null;
        }

        if (!mounted) return;
        await _setTab(_Tab.treks);
        if (!mounted) return;
        FocusScope.of(context).requestFocus(_toFocus);

        // If we already had a pending trek AND a real city id arrived,
        // try auto-completing now.
        _maybeAutoComplete();
      } else {
        if (!_hasValidFromSelection) {
          FocusScope.of(context).requestFocus(_fromFocus);
          return;
        }
        final match = _resolveTrekByName(value);
        if (match == null) return;

        if (match.id != 0) {
          _selectedTrekId = match.id;
          _pendingTrekName = null;
        } else {
          _selectedTrekId = 0;
          _pendingTrekName = match.name;
        }
        _toCtrl.text = match.name;
        _toCtrl.selection = TextSelection.collapsed(offset: match.name.length);
        _RecentSearches.add(_Tab.treks, match.name);

        // Real IDs are required before close. Pending fallbacks alone
        // cannot complete the flow — they'll auto-complete when the API
        // resolves them.
        if (_fromCityId != 0 && _selectedTrekId != 0) {
          await _closeWithResult();
        }
      }
    } finally {
      _itemTapInFlight = false;
    }
  }

  _NamedEntry? _resolveCityByName(String name) {
    final lower = name.toLowerCase();
    final data = _dashboardC.citiesData.value.data;
    if (data != null) {
      for (final c in data) {
        if ((c.cityName ?? '').trim().toLowerCase() == lower) {
          return _NamedEntry(id: c.id ?? 0, name: (c.cityName ?? '').trim());
        }
      }
    }
    for (final c in _popularCitiesFallback) {
      if (c.toLowerCase() == lower) {
        return _NamedEntry(id: 0, name: c);
      }
    }
    return null;
  }

  _NamedEntry? _resolveTrekByName(String name) {
    final lower = name.toLowerCase();
    final data = _dashboardC.trekData.value.data;
    if (data != null) {
      for (final t in data) {
        if ((t.name ?? '').trim().toLowerCase() == lower) {
          return _NamedEntry(id: t.id ?? 0, name: (t.name ?? '').trim());
        }
      }
    }
    for (final t in _popularTreksFallback) {
      if (t.toLowerCase() == lower) {
        return _NamedEntry(id: 0, name: t);
      }
    }
    return null;
  }

  Future<void> _closeWithResult() async {
    if (_navigatingBack) return;
    // Backend must never receive a 0 id — both real IDs required.
    if (_fromCityId == 0 || _selectedTrekId == 0) return;
    _navigatingBack = true;
    await _listFadeCtrl.reverse();
    if (!mounted) return;
    Get.back();
  }

  /// Consolidated clear handler. Cancels any pending debounce so a stale
  /// typed query can't resurrect itself ~180ms later; resets IDs and
  /// pending names; clears linked fields when clearing From; switches
  /// back to Cities if clearing From while on Treks; refocuses; and
  /// refreshes the list so the snapshot updates immediately.
  void _clearField(TextEditingController controller) {
    _searchDebounce.cancel();

    if (controller == _fromCtrl) {
      _fromCtrl.clear();
      _dashboardC.fromController.value.text = '';
      _fromCityId = 0;
      _pendingCityName = null;

      // To depends on From — clear it too.
      _toCtrl.clear();
      _dashboardC.toController.value.text = '';
      _selectedTrekId = 0;
      _pendingTrekName = null;

      if (_tab != _Tab.cities) {
        _setTab(_Tab.cities);
      }
      _query.value = '';
      _refreshFiltered();
      if (mounted) setState(() {});
      FocusScope.of(context).requestFocus(_fromFocus);
    } else {
      _toCtrl.clear();
      _dashboardC.toController.value.text = '';
      _selectedTrekId = 0;
      _pendingTrekName = null;
      _query.value = '';
      _refreshFiltered();
      if (mounted) setState(() {});
      FocusScope.of(context).requestFocus(_toFocus);
    }
  }

  void _retry() {
    if (_tab == _Tab.cities) {
      _citiesError = '';
      _dashboardC.errorMessage.value = '';
      _dashboardC.fetchCitiesList();
    } else {
      _treksError = '';
      _dashboardC.errorMessage.value = '';
      _dashboardC.fetchTrekList();
    }
  }

  void _onSubmitField() {
    final text = (_tab == _Tab.cities ? _fromCtrl : _toCtrl).text.trim();
    if (text.isEmpty) return;
    if (_tab == _Tab.cities) {
      final m = _resolveCityByName(text);
      if (m == null) {
        _fromCtrl.clear();
        _fromCityId = 0;
        _pendingCityName = null;
      } else {
        if (m.id != 0) {
          _fromCityId = m.id;
          _pendingCityName = null;
        } else {
          _fromCityId = 0;
          _pendingCityName = m.name;
        }
        _fromCtrl.text = m.name;
      }
    } else {
      final m = _resolveTrekByName(text);
      if (m == null) {
        _toCtrl.clear();
        _selectedTrekId = 0;
        _pendingTrekName = null;
      } else {
        if (m.id != 0) {
          _selectedTrekId = m.id;
          _pendingTrekName = null;
        } else {
          _selectedTrekId = 0;
          _pendingTrekName = m.name;
        }
        _toCtrl.text = m.name;
        if (_fromCityId != 0 && _selectedTrekId != 0) {
          _closeWithResult();
        }
      }
    }
  }

  // ───────────────────────────────────────────
  //  BUILD
  // ───────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    ScreenConstant.setScreenAwareConstant(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _T.bg,
        resizeToAvoidBottomInset: true,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Expanded(
              child: SafeArea(
                top: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 0),
                      child: _buildInputCard(),
                    ),
                    SizedBox(height: 2.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: _buildSegmentedTabs(),
                    ),
                    SizedBox(height: 1.6.h),
                    Expanded(
                      child: Obx(() {
                        final result = _filtered.value;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4.w),
                              child: _buildHeaderRow(result),
                            ),
                            SizedBox(height: 1.h),
                            Expanded(child: _buildListArea(result)),
                          ],
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Light hero header — pale mint band, dark ink text
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      color: _T.heroBg,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(1.w, 0.4.h, 4.w, 1.2.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Get.back(),
                splashRadius: 22,
                icon: Icon(
                  Icons.arrow_back_rounded,
                  color: _T.ink,
                  size: 6.w,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 3.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Plan Your Trek',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: FontSize.s16,
                        fontWeight: FontWeight.w700,
                        color: _T.ink,
                        letterSpacing: 0.2,
                      ),
                    ),
                    SizedBox(height: 0.4.h),
                    Text(
                      'Pick your starting city, then choose the trail',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: FontSize.s10,
                        fontWeight: FontWeight.w400,
                        color: _T.inkMid,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Route-style input card: origin ring → dashed trail → terrain pin
  Widget _buildInputCard() {
    final toEnabled = _hasValidFromSelection;
    return Container(
      decoration: BoxDecoration(
        color: _T.card,
        borderRadius: BorderRadius.circular(4.w),
        border: Border.all(color: _T.divider, width: 1),
        boxShadow: [
          BoxShadow(
            color: _T.pine.withValues(alpha: 0.10),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(width: 12.w, child: _buildRouteRail()),
            Expanded(
              child: Column(
                children: [
                  _buildField(
                    controller: _fromCtrl,
                    focusNode: _fromFocus,
                    hint: 'From City',
                    isFocused: _tab == _Tab.cities,
                    enabled: true,
                    errorText: _fromErrorText(),
                    onClear: () => _clearField(_fromCtrl),
                  ),
                  Container(height: 1, color: _T.divider),
                  _buildField(
                    controller: _toCtrl,
                    focusNode: _toFocus,
                    hint: _hasValidFromSelection
                        ? 'Select Trek'
                        : 'Choose a starting city first',
                    isFocused: _tab == _Tab.treks,
                    enabled: toEnabled,
                    errorText: _toErrorText(),
                    onClear: () => _clearField(_toCtrl),
                  ),
                ],
              ),
            ),
            SizedBox(width: 1.w),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteRail() {
    return Padding(
      padding: EdgeInsets.only(left: 2.w, top: 1.4.h, bottom: 1.4.h),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _RailDashPainter(_T.inkLight)),
          ),
          Column(
            children: [
              Expanded(
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(0.9.w),
                    decoration: const BoxDecoration(
                      color: _T.card,
                      shape: BoxShape.circle,
                    ),
                    child: Container(
                      width: 3.6.w,
                      height: 3.6.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _T.mossSoft,
                        border: Border.all(color: _T.forest, width: 2),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(0.6.w),
                    decoration: const BoxDecoration(
                      color: _T.card,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.terrain_rounded,
                      color: _T.clay,
                      size: 5.5.w,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String? _fromErrorText() {
    // Don't nag while the user is actively typing in the focused field,
    // and don't show an error if a fallback selection is pending.
    if (_fromFocus.hasFocus) return null;
    if (_pendingCityName != null) return null;
    if (_fromCtrl.text.trim().isNotEmpty && _fromCityId == 0) {
      return 'Please pick a city from the list';
    }
    return null;
  }

  String? _toErrorText() {
    if (_toFocus.hasFocus) return null;
    if (_pendingTrekName != null) return null;
    if (_toCtrl.text.trim().isNotEmpty && _selectedTrekId == 0) {
      return 'Please pick a trek from the list';
    }
    return null;
  }

  Widget _buildField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    required bool isFocused,
    required bool enabled,
    required VoidCallback onClear,
    String? errorText,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      color: isFocused ? _T.focusBg : Colors.transparent,
      child: Semantics(
        textField: true,
        enabled: enabled,
        label: hint,
        child: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, child) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              enabled: enabled,
              onChanged: _onSearchChanged,
              onSubmitted: (_) => _onSubmitField(),
              textInputAction: TextInputAction.done,
              textAlignVertical: TextAlignVertical.center,
              cursorColor: _T.forest,
              inputFormatters: [LengthLimitingTextInputFormatter(60)],
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: FontSize.s11,
                fontWeight: FontWeight.w500,
                color: enabled ? _T.ink : _T.inkLight,
              ),
              decoration: InputDecoration(
                suffixIcon: value.text.isNotEmpty
                    ? IconButton(
                        splashRadius: 20,
                        tooltip: 'Clear',
                        icon: Icon(
                          Icons.close_rounded,
                          size: 4.6.w,
                          color: _T.inkMid,
                        ),
                        onPressed: onClear,
                      )
                    : null,
                hintText: hint,
                hintStyle: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: FontSize.s11,
                  color: _T.inkLight,
                ),
                errorText: errorText,
                errorStyle: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: FontSize.s8,
                  color: _T.error,
                ),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                isCollapsed: true,
                contentPadding: EdgeInsets.symmetric(
                  vertical: 1.9.h,
                  horizontal: 1.w,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSegmentedTabs() {
    return Obx(() {
      final fromCityId = _dashboardC.selectedCityId.value;
      final trekEnabled = fromCityId != 0 || _pendingCityName != null;
      return LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth;
          return Semantics(
            container: true,
            label: 'Search scope',
            child: Container(
              height: 5.5.h,
              decoration: BoxDecoration(
                color: _T.card,
                borderRadius: BorderRadius.circular(3.w),
                border: Border.all(color: _T.divider, width: 1),
              ),
              child: Stack(
                children: [
                  AnimatedBuilder(
                    animation: _tabCtrl,
                    builder: (_, __) {
                      return Positioned(
                        left: 4 + (w / 2 - 4) * _tabCtrl.value,
                        top: 4,
                        bottom: 4,
                        width: w / 2 - 8,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [_T.pine, _T.forest],
                            ),
                            borderRadius: BorderRadius.circular(2.5.w),
                            boxShadow: [
                              BoxShadow(
                                color: _T.forest.withValues(alpha: 0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _tabButton(
                          label: 'Cities',
                          icon: Icons.location_city_rounded,
                          active: _tab == _Tab.cities,
                          onTap: () =>
                              FocusScope.of(context).requestFocus(_fromFocus),
                        ),
                      ),
                      Expanded(
                        child: _tabButton(
                          label: 'Treks',
                          icon: Icons.hiking,
                          active: _tab == _Tab.treks,
                          enabled: trekEnabled,
                          onTap: trekEnabled
                              ? () => FocusScope.of(
                                  context,
                                ).requestFocus(_toFocus)
                              : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Widget _tabButton({
    required String label,
    required IconData icon,
    required bool active,
    required VoidCallback? onTap,
    bool enabled = true,
  }) {
    final color = !enabled
        ? _T.inkLight
        : active
        ? Colors.white
        : _T.inkMid;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(2.5.w),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 4.4.w, color: color),
              SizedBox(width: 1.8.w),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: FontSize.s11,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  color: color,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderRow(_FilterResult result) {
    final count = result.items.length;
    final loading = result.state == _ListState.loading;
    return Row(
      children: [
        Icon(
          _tab == _Tab.cities ? Icons.explore_outlined : Icons.hiking,
          size: 4.6.w,
          color: _T.forest,
        ),
        SizedBox(width: 2.w),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, anim) =>
              FadeTransition(opacity: anim, child: child),
          child: Text(
            _tab == _Tab.cities ? 'Popular Cities' : 'Popular Treks',
            key: ValueKey(_tab),
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: FontSize.s12,
              fontWeight: FontWeight.w700,
              color: _T.ink,
            ),
          ),
        ),
        const Spacer(),
        // if (!loading && count > 0)
        //   AnimatedSwitcher(
        //     duration: const Duration(milliseconds: 200),
        //     child: Container(
        //       key: ValueKey('${_tab}_$count'),
        //       padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.4.h),
        //       decoration: BoxDecoration(
        //         color: _T.mossSoft,
        //         borderRadius: BorderRadius.circular(2.w),
        //       ),
        //       child: Text(
        //         '$count found',
        //         style: TextStyle(
        //           fontFamily: 'Poppins',
        //           fontSize: FontSize.s8,
        //           fontWeight: FontWeight.w600,
        //           color: _T.forest,
        //         ),
        //       ),
        //     ),
        //   ),
      ],
    );
  }

  Widget _buildListArea(_FilterResult result) {
    switch (result.state) {
      case _ListState.loading:
        return _buildShimmerList();
      case _ListState.error:
        return _buildErrorState(message: _errorMessage, onRetry: _retry);
      case _ListState.noNetwork:
        return _buildErrorState(
          message: 'No internet connection. Please check your network.',
          onRetry: _retry,
          icon: Icons.wifi_off_rounded,
        );
      case _ListState.empty:
        return _buildEmptyState(
          result.query?.isNotEmpty == true
              ? 'No results for "${result.query}"'
              : 'Nothing to show yet',
          result.query?.isNotEmpty == true
              ? 'Try a different spelling or check for typos'
              : null,
        );
      case _ListState.idle:
      case _ListState.ready:
        if (result.items.isEmpty && result.recent.isEmpty) {
          return _buildEmptyState('No results found', null);
        }
        return FadeTransition(opacity: _listFade, child: _buildList(result));
    }
  }

  Widget _buildList(_FilterResult result) {
    final itemIcon = _tab == _Tab.cities
        ? Icons.location_city_rounded
        : Icons.terrain_rounded;
    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        if (result.recent.isNotEmpty && _query.value.trim().isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 1.h),
              child: Row(
                children: [
                  Icon(Icons.history_rounded, size: 3.8.w, color: _T.inkMid),
                  SizedBox(width: 1.5.w),
                  Text(
                    'Recent',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: FontSize.s10,
                      fontWeight: FontWeight.w700,
                      color: _T.inkMid,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      _RecentSearches.clear(_tab);
                      _refreshFiltered();
                      if (mounted) setState(() {});
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 2.w,
                        vertical: 0.4.h,
                      ),
                      child: Text(
                        'Clear',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: FontSize.s9,
                          fontWeight: FontWeight.w600,
                          color: _T.clay,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (result.recent.isNotEmpty && _query.value.trim().isEmpty)
          SliverList(
            delegate: SliverChildBuilderDelegate((ctx, i) {
              final label = result.recent[i];
              return _ListItem(
                key: ValueKey('recent_${_tab}_$label'),
                label: label,
                highlightedQuery: '',
                isRecent: true,
                icon: Icons.history_rounded,
                onTap: () => _onItemTap(label),
              );
            }, childCount: result.recent.length),
          ),
        SliverList(
          delegate: SliverChildBuilderDelegate((ctx, i) {
            final item = result.items[i];
            return _ListItem(
              key: ValueKey('item_${_tab}_$item'),
              label: item,
              highlightedQuery: result.query ?? '',
              isRecent: false,
              icon: itemIcon,
              onTap: () => _onItemTap(item),
            );
          }, childCount: result.items.length),
        ),
        SliverPadding(padding: EdgeInsets.only(bottom: 4.h)),
      ],
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 4.h),
      itemCount: 8,
      itemBuilder: (_, i) => Padding(
        padding: EdgeInsets.symmetric(vertical: 1.3.h, horizontal: 1.w),
        child: Row(
          children: [
            Container(
              width: 9.w,
              height: 9.w,
              decoration: const BoxDecoration(
                color: _T.divider,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 3.w),
            Container(
              width: 45.w + (i * 3.0).clamp(0.0, 20.0),
              height: 1.6.h,
              decoration: BoxDecoration(
                color: _T.divider,
                borderRadius: BorderRadius.circular(1.w),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title, String? subtitle) {
    // SingleChildScrollView instead of a rigid Column so this never
    // overflows when the keyboard is open and squeezes the available
    // height (e.g. typing a query with no matches).
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 18.w,
              height: 18.w,
              decoration: const BoxDecoration(
                color: _T.mossSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.landscape_rounded, size: 9.w, color: _T.forest),
            ),
            SizedBox(height: 2.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: FontSize.s13,
                fontWeight: FontWeight.w700,
                color: _T.ink,
              ),
            ),
            if (subtitle != null) ...[
              SizedBox(height: 0.8.h),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: FontSize.s10,
                  color: _T.inkMid,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState({
    required String message,
    required VoidCallback onRetry,
    IconData icon = Icons.cloud_off_rounded,
  }) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 18.w,
              height: 18.w,
              decoration: const BoxDecoration(
                color: _T.errorSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 9.w, color: _T.error),
            ),
            SizedBox(height: 2.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: FontSize.s12,
                fontWeight: FontWeight.w700,
                color: _T.ink,
              ),
            ),
            SizedBox(height: 2.h),
            ElevatedButton.icon(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: _T.forest,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.4.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3.w),
                ),
              ),
              icon: Icon(Icons.refresh_rounded, size: 4.5.w),
              label: Text(
                'Retry',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: FontSize.s10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  PAINTERS
// ─────────────────────────────────────────────
class _RailDashPainter extends CustomPainter {
  final Color color;
  const _RailDashPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    final x = size.width / 2;
    const dash = 4.0;
    const gap = 5.0;
    var y = size.height * 0.18;
    final endY = size.height * 0.82;
    while (y < endY) {
      final segEnd = (y + dash) > endY ? endY : (y + dash);
      canvas.drawLine(Offset(x, y), Offset(x, segEnd), paint);
      y += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _RailDashPainter oldDelegate) =>
      oldDelegate.color != color;
}

// ─────────────────────────────────────────────
//  DATA CLASSES
// ─────────────────────────────────────────────
class _NamedEntry {
  final int id;
  final String name;
  const _NamedEntry({required this.id, required this.name});
}

class _NormalizedEntry {
  final int id;
  final String normalized;
  const _NormalizedEntry({required this.id, required this.normalized});
}

class _Scored {
  final String item;
  final int score;
  const _Scored(this.item, this.score);
}

class _FilterResult {
  final _ListState state;
  final List<String> items;
  final List<String> recent;
  final String? query;
  const _FilterResult({
    required this.state,
    required this.items,
    this.recent = const [],
    this.query,
  });
}

// ─────────────────────────────────────────────
//  LIST ITEM
// ─────────────────────────────────────────────
class _ListItem extends StatefulWidget {
  final String label;
  final String highlightedQuery;
  final bool isRecent;
  final IconData icon;
  final VoidCallback onTap;
  const _ListItem({
    super.key,
    required this.label,
    required this.highlightedQuery,
    required this.isRecent,
    required this.icon,
    required this.onTap,
  });

  @override
  State<_ListItem> createState() => _ListItemState();
}

class _ListItemState extends State<_ListItem> {
  bool _pressed = false;

  void _set(bool v) {
    if (mounted) setState(() => _pressed = v);
  }

  List<TextSpan> _buildSpans(String text, String query) {
    if (query.isEmpty) return [TextSpan(text: text)];
    final q = query.toLowerCase();
    final lower = text.toLowerCase();
    final spans = <TextSpan>[];
    var start = 0;
    while (true) {
      final idx = lower.indexOf(q, start);
      if (idx == -1) {
        spans.add(TextSpan(text: text.substring(start)));
        break;
      }
      if (idx > start) {
        spans.add(TextSpan(text: text.substring(start, idx)));
      }
      spans.add(
        TextSpan(
          text: text.substring(idx, idx + q.length),
          style: const TextStyle(color: _T.forest, fontWeight: FontWeight.w700),
        ),
      );
      start = idx + q.length;
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final spans = _buildSpans(widget.label, widget.highlightedQuery);
    final badgeBg = widget.isRecent ? _T.claySoft : _T.mossSoft;
    final badgeFg = widget.isRecent ? _T.clay : _T.forest;
    return Semantics(
      button: true,
      label: widget.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _set(true),
        onTapCancel: () => _set(false),
        onTapUp: (_) => _set(false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _pressed ? 0.985 : 1.0,
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            margin: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.3.h),
            padding: EdgeInsets.symmetric(vertical: 1.2.h, horizontal: 2.5.w),
            decoration: BoxDecoration(
              color: _pressed ? _T.focusBg : Colors.transparent,
              borderRadius: BorderRadius.circular(3.w),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 9.w,
                  height: 9.w,
                  decoration: BoxDecoration(
                    color: _pressed ? _T.forest : badgeBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    widget.icon,
                    size: 4.5.w,
                    color: _pressed ? Colors.white : badgeFg,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: RichText(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: FontSize.s11,
                        color: _T.ink,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.1,
                      ),
                      children: spans,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 5.w,
                  color: _pressed ? _T.forest : _T.inkLight,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
