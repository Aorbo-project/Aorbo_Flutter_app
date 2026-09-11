import 'dart:async';
import 'dart:collection';

import 'package:arobo_app/controller/dashboard_controller.dart';
import 'package:arobo_app/theme/app_button.dart';
import 'package:arobo_app/theme/app_tokens.dart';
import 'package:arobo_app/theme/app_typography.dart';
import 'package:arobo_app/utils/custom_snackbar.dart';
import 'package:arobo_app/utils/screen_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

// ─────────────────────────────────────────────
//  TREKKING THEME TOKENS
// ─────────────────────────────────────────────
class _T {
  static const pineDark = Color(0xFF122B20);
  static const pine = AppColors.forestDeep;
  static const forest = AppColors.forest;
  static const moss = Color(0xFF52B688);
  static const mossSoft = Color(0xFFDCEFE2);
  static const clay = Color(0xFFCB6D42);
  static const claySoft = Color(0xFFFBEEE6);
  static const bg = AppColors.bg;
  static const card = Colors.white;
  static const focusBg = Color(0xFFEFF5EF);
  static const divider = Color(0xFFE4E9E2);
  static const ink = Color(0xFF16261E);
  static const inkMid = Color(0xFF5C6F63);
  static const inkLight = Color(0xFF9DABA1);
  static const error = Color(0xFFC13A2B);
}

enum _Tab { cities, treks }

enum _ListState { idle, loading, empty, error, noNetwork, ready }

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
    cancel();
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
//  SCREEN
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
      _refreshFiltered();
    });

    _rebuildCityCache();
    _rebuildTrekCache();
    _revalidatePersistedIds();

    if (_dashboardC.citiesData.value.data == null && _citiesError.isEmpty)
      _dashboardC.fetchCitiesList();
    if (_dashboardC.trekData.value.data == null && _treksError.isEmpty)
      _dashboardC.fetchTrekList();

    _querySub = _query.listen((_) => _refreshFiltered());
    _refreshFiltered();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final fromValid = _hasValidFromSelection;
      final toValid = _hasValidToSelection;
      // Both already picked (e.g. reopening to edit) — the CTA below is the
      // next step; don't force-focus either field.
      if (fromValid && toValid) {
        _refreshFiltered();
        return;
      }
      if (fromValid) {
        setState(() => _tab = _Tab.treks);
        _query.value = _toCtrl.text;
      }
      _refreshFiltered();
      FocusScope.of(context).requestFocus(fromValid ? _toFocus : _fromFocus);
    });
  }

  int get _fromCityId => _dashboardC.selectedCityId.value;
  int get _selectedTrekId => _dashboardC.selectedTrekId.value;
  set _fromCityId(int v) => _dashboardC.selectedCityId.value = v;
  set _selectedTrekId(int v) => _dashboardC.selectedTrekId.value = v;
  bool get _hasValidFromSelection => _fromCityId != 0;
  bool get _hasValidToSelection => _selectedTrekId != 0;

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
    super.dispose();
  }

  // ── TEXT / FOCUS PLUMBING ──────────────────────────────────────────────
  void _onFromChanged() {
    final text = _fromCtrl.text;
    _dashboardC.fromController.value.text = text;
    if (_fromCityId != 0) {
      final selectedName = _nameForCityId(_fromCityId);
      if (selectedName == null ||
          selectedName.toLowerCase() != text.trim().toLowerCase())
        _fromCityId = 0;
    }
    if (mounted) setState(() {});
  }

  void _onToChanged() {
    final text = _toCtrl.text;
    _dashboardC.toController.value.text = text;
    if (_selectedTrekId != 0) {
      final selectedName = _nameForTrekId(_selectedTrekId);
      if (selectedName == null ||
          selectedName.toLowerCase() != text.trim().toLowerCase())
        _selectedTrekId = 0;
    }
    if (mounted) setState(() {});
  }

  void _onFromFocusChange() {
    if (!mounted || _itemTapInFlight) return;
    if (_fromFocus.hasFocus && _tab != _Tab.cities) {
      setState(() => _tab = _Tab.cities);
      _query.value = _fromCtrl.text;
      _refreshFiltered();
    }
    if (mounted) setState(() {});
  }

  void _onToFocusChange() {
    if (!mounted || _itemTapInFlight) return;
    if (_toFocus.hasFocus && _tab != _Tab.treks) {
      if (!_hasValidFromSelection) {
        // Can't pick a destination before a departure — bounce back after
        // the current focus dispatch settles.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) FocusScope.of(context).requestFocus(_fromFocus);
        });
        return;
      }
      setState(() => _tab = _Tab.treks);
      _query.value = _toCtrl.text;
      _refreshFiltered();
    }
    if (mounted) setState(() {});
  }

  void _setActiveField(_Tab tab) {
    if (tab == _Tab.treks && !_hasValidFromSelection) {
      _fromFocus.requestFocus();
      HapticFeedback.mediumImpact();
      return;
    }
    if (_tab != tab) setState(() => _tab = tab);
    final ctrl = tab == _Tab.cities ? _fromCtrl : _toCtrl;
    final hasSelection = tab == _Tab.cities
        ? _hasValidFromSelection
        : _hasValidToSelection;
    if (hasSelection) {
      // Editing a completed field: show the full list and select the text
      // so a single keystroke starts a fresh search.
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

  String get _activeRawText =>
      _tab == _Tab.cities ? _fromCtrl.text : _toCtrl.text;

  // ── CACHES ─────────────────────────────────────────────────────────────
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
    // Only prune once the list has actually LOADED — a null list means
    // "still fetching", not "the saved city no longer exists". Wiping the
    // persisted route on a slow network was a real cold-start bug.
    if (_dashboardC.citiesData.value.data != null &&
        _fromCityId != 0 &&
        _nameForCityId(_fromCityId) == null) {
      _fromCityId = 0;
      if (_fromCtrl.text.isNotEmpty) _fromCtrl.clear();
    }
    if (_dashboardC.trekData.value.data != null &&
        _selectedTrekId != 0 &&
        _nameForTrekId(_selectedTrekId) == null) {
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
    final source = _tab == _Tab.cities ? _citiesSorted : _treksSorted;
    final tabError = _tab == _Tab.cities ? _citiesError : _treksError;

    if (source.isNotEmpty) {
      _loadingTimeout?.cancel();
      _loadingTimeout = null;
      if (query.isEmpty) {
        _filtered.value = _FilterResult(
          state: _ListState.ready,
          items: source,
          recent: _RecentSearches.of(_tab).where((r) {
            return _tab == _Tab.cities
                ? (_resolveCityByName(r)?.id ?? 0) != 0
                : (_resolveTrekByName(r)?.id ?? 0) != 0;
          }).toList(),
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
      if (best <= maxDist) fuzzy.add(_Scored(item, best));
    }
    fuzzy.sort((a, b) => a.score.compareTo(b.score));
    return [...direct, ...fuzzy.map((s) => s.item)];
  }

  // ── SELECTION ──────────────────────────────────────────────────────────
  Future<void> _onItemTap(String value) async {
    if (_itemTapInFlight) return;
    _itemTapInFlight = true;
    try {
      HapticFeedback.selectionClick();
      if (_tab == _Tab.cities) {
        final match = _resolveCityByName(value);
        if (match == null || match.id == 0) return;
        _fromCityId = match.id;
        _fromCtrl.text = match.name;
        _fromCtrl.selection = TextSelection.collapsed(
          offset: match.name.length,
        );
        _RecentSearches.add(_Tab.cities, match.name);
        // The destination is intentionally KEPT when the departure changes
        // — wiping it forced a full re-pick for a one-field edit.
        if (!_hasValidToSelection) {
          _setActiveField(_Tab.treks);
        } else {
          // Route complete again — park the keyboard; the CTA (or the trek
          // field, if they want to change it) takes over.
          FocusScope.of(context).unfocus();
          _query.value = '';
          setState(() {});
        }
      } else {
        if (!_hasValidFromSelection) {
          FocusScope.of(context).requestFocus(_fromFocus);
          return;
        }
        final match = _resolveTrekByName(value);
        if (match == null || match.id == 0) return;
        _selectedTrekId = match.id;
        _toCtrl.text = match.name;
        _toCtrl.selection = TextSelection.collapsed(offset: match.name.length);
        _RecentSearches.add(_Tab.treks, match.name);
        if (_hasValidFromSelection) {
          FocusScope.of(context).unfocus();
          await _closeWithResult();
        }
      }
    } finally {
      _itemTapInFlight = false;
    }
  }

  _NamedEntry? _resolveCityByName(String name) {
    final lower = name.trim().toLowerCase();
    final data = _dashboardC.citiesData.value.data;
    if (data == null) return null;
    for (final c in data) {
      if ((c.cityName ?? '').trim().toLowerCase() == lower)
        return _NamedEntry(id: c.id ?? 0, name: (c.cityName ?? '').trim());
    }
    return null;
  }

  _NamedEntry? _resolveTrekByName(String name) {
    final lower = name.trim().toLowerCase();
    final data = _dashboardC.trekData.value.data;
    if (data == null) return null;
    for (final t in data) {
      if ((t.name ?? '').trim().toLowerCase() == lower)
        return _NamedEntry(id: t.id ?? 0, name: (t.name ?? '').trim());
    }
    return null;
  }

  Future<void> _closeWithResult() async {
    if (_navigatingBack) return;
    if (!_hasValidFromSelection || !_hasValidToSelection) return;
    _navigatingBack = true;
    HapticFeedback.mediumImpact();
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
      // Clearing the origin breaks the route — reset the destination too so
      // the flow restarts cleanly from step 1 (the controller already wipes
      // availability + date when either id drops to 0).
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
      if (m == null || m.id == 0) {
        // Keep what they typed — silently wiping the field was worse.
        CustomSnackBar.show(
          context,
          message: 'No exact match — pick a city from the list',
        );
        return;
      }
      _onItemTap(m.name);
    } else {
      if (!_hasValidFromSelection) {
        FocusScope.of(context).requestFocus(_fromFocus);
        return;
      }
      final m = _resolveTrekByName(text);
      if (m == null || m.id == 0) {
        CustomSnackBar.show(
          context,
          message: 'No exact match — pick a trek from the list',
        );
        return;
      }
      _onItemTap(m.name);
    }
  }

  String? _fromErrorText() {
    if (_fromFocus.hasFocus) return null;
    if (_fromCtrl.text.trim().isNotEmpty && _fromCityId == 0)
      return 'Pick a city from the list';
    return null;
  }

  String? _toErrorText() {
    if (_toFocus.hasFocus) return null;
    if (_toCtrl.text.trim().isNotEmpty && _selectedTrekId == 0)
      return 'Pick a trek from the list';
    return null;
  }

  bool _isSelectedItem(String name) {
    if (_tab == _Tab.cities) {
      if (_fromCityId == 0) return false;
      return _nameForCityId(_fromCityId)?.toLowerCase() == name.toLowerCase();
    }
    if (_selectedTrekId == 0) return false;
    return _nameForTrekId(_selectedTrekId)?.toLowerCase() == name.toLowerCase();
  }

  // ── BUILD ───────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    ScreenConstant.setScreenAwareConstant(context);
    return MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: const TextScaler.linear(1.0)),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Scaffold(
          backgroundColor: _T.bg,
          resizeToAvoidBottomInset: true,
          body: Stack(
            children: [
              SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAppBar(),
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
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 20, 12),
      child: Row(
        children: [
          IconButton(
            onPressed: Get.back,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _T.card,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: _T.ink,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Plan your trek',
                style: AppType.style(
                  FontSize.s13,
                  w: FontWeight.w700,
                  color: _T.ink,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Two quick picks, then pick a date',
                style: AppType.style(FontSize.s10, color: _T.inkMid),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRouteCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      decoration: BoxDecoration(
        color: _T.card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _T.pine.withAlpha(12),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
          BoxShadow(
            color: _T.pine.withAlpha(6),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: _T.divider, width: 0.5),
      ),
      child: Column(
        children: [
          _routeField(
            stepLabel: '1',
            label: 'DEPARTURE CITY',
            hint: 'e.g. Delhi, Mumbai',
            controller: _fromCtrl,
            focusNode: _fromFocus,
            isActive: _tab == _Tab.cities && _fromFocus.hasFocus,
            isDone: _hasValidFromSelection,
            onTap: () => _setActiveField(_Tab.cities),
            errorText: _fromErrorText(),
          ),
          _buildDividerWithIcon(),
          _routeField(
            stepLabel: '2',
            label: 'DESTINATION TREK',
            hint: 'e.g. Kedarkantha, Roopkund',
            controller: _toCtrl,
            focusNode: _toFocus,
            isActive: _tab == _Tab.treks && _toFocus.hasFocus,
            isDone: _hasValidToSelection,
            onTap: () => _setActiveField(_Tab.treks),
            errorText: _toErrorText(),
          ),
        ],
      ),
    );
  }

  Widget _routeField({
    required String stepLabel,
    required String label,
    required String hint,
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool isActive,
    required bool isDone,
    required VoidCallback onTap,
    String? errorText,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? _T.focusBg : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: isDone || isActive ? _T.forest : _T.card,
                    shape: BoxShape.circle,
                    border: isDone || isActive
                        ? null
                        : Border.all(color: _T.divider, width: 1.5),
                  ),
                  child: isDone
                      ? const Icon(
                          Icons.check_rounded,
                          size: 18,
                          color: Colors.white,
                        )
                      : Center(
                          child: Text(
                            stepLabel,
                            style: AppType.style(
                              FontSize.s10,
                              w: FontWeight.w800,
                              color: isActive ? Colors.white : _T.inkMid,
                            ),
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: AppType.style(
                          FontSize.s9,
                          w: FontWeight.w600,
                          color: _T.inkMid,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextField(
                        controller: controller,
                        focusNode: focusNode,
                        onChanged: _onSearchChanged,
                        onSubmitted: (_) => _onSubmitField(),
                        textInputAction: TextInputAction.done,
                        maxLines: 1,
                        decoration: InputDecoration(
                          isCollapsed: true,
                          border: InputBorder.none,
                          hintText: hint,
                          hintStyle: AppType.style(
                            FontSize.s12,
                            color: _T.inkLight,
                          ),
                        ),
                        style: AppType.style(
                          FontSize.s12,
                          w: FontWeight.w600,
                          color: _T.ink,
                        ),
                      ),
                    ],
                  ),
                ),
                if (controller.text.isNotEmpty)
                  GestureDetector(
                    onTap: () => _clearField(controller),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: _T.divider,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 14,
                        color: _T.inkMid,
                      ),
                    ),
                  ),
              ],
            ),
            if (errorText != null)
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 46),
                child: Text(
                  errorText,
                  style: AppType.style(
                    FontSize.s9,
                    color: _T.error,
                    w: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDividerWithIcon() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: CustomPaint(
            painter: _DashedLinePainter(_T.divider),
            child: Container(height: 1),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _T.card,
            shape: BoxShape.circle,
            border: Border.all(color: _T.divider, width: 1.5),
          ),
          child: const Icon(Icons.hiking_rounded, size: 16, color: _T.clay),
        ),
      ],
    );
  }

  // ── BODY ───────────────────────────────────────────────────────────────
  Widget _buildBody() {
    return Obx(() {
      final result = _filtered.value;
      final bothPicked = _hasValidFromSelection && _hasValidToSelection;
      final editing = _fromFocus.hasFocus || _toFocus.hasFocus;

      // Route complete and not being edited → the CTA is the only next
      // step. (Previously tapping a field here showed nothing at all.)
      if (bothPicked && !editing) return _buildRouteReady();

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
      if (result.state == _ListState.empty) return _buildEmpty();
      return _buildContent(result);
    });
  }

  Widget _buildRouteReady() {
    final from = _fromCtrl.text.trim();
    final to = _toCtrl.text.trim();
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.6, end: 1.0),
              duration: const Duration(milliseconds: 450),
              curve: Curves.elasticOut,
              builder: (_, v, child) => Transform.scale(scale: v, child: child),
              child: Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: _T.mossSoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 34,
                  color: _T.forest,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Route locked in',
              style: AppType.style(
                FontSize.s14,
                w: FontWeight.w800,
                color: _T.ink,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    from,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppType.style(
                      FontSize.s11,
                      w: FontWeight.w700,
                      color: _T.inkMid,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 10,
                        height: 1.2,
                        color: _T.inkLight.withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.hiking_rounded,
                        size: 14,
                        color: _T.clay,
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 10,
                        height: 1.2,
                        color: _T.inkLight.withValues(alpha: 0.5),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: Text(
                    to,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppType.style(
                      FontSize.s11,
                      w: FontWeight.w700,
                      color: _T.forest,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Tap a field above to change it',
              style: AppType.style(FontSize.s10, color: _T.inkLight),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(_FilterResult result) {
    final isSearching = _query.value.trim().isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isSearching) _buildSuggestionChips(result),
        if (isSearching)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 4),
            child: Text(
              '${result.items.length} match'
              '${result.items.length == 1 ? '' : 'es'}',
              style: AppType.style(FontSize.s10, color: _T.inkLight),
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 130),
            itemCount: result.items.length,
            itemBuilder: (ctx, i) => _ResultTile(
              label: result.items[i],
              query: result.query ?? '',
              isCity: _tab == _Tab.cities,
              isSelected: _isSelectedItem(result.items[i]),
              onTap: () => _onItemTap(result.items[i]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestionChips(_FilterResult result) {
    final recents = result.recent;
    final popular = _tab == _Tab.cities ? _citiesSorted : _treksSorted;
    final items = recents.isNotEmpty
        ? recents
        : (popular.length > 10 ? popular.sublist(0, 10) : popular);
    if (items.isEmpty) return const SizedBox.shrink();
    final title = recents.isNotEmpty
        ? 'RECENT SEARCHES'
        : (_tab == _Tab.cities ? 'POPULAR DEPARTURES' : 'TRENDING TREKS');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 10),
          child: Row(
            children: [
              Icon(
                recents.isNotEmpty
                    ? Icons.history_rounded
                    : Icons.local_fire_department_rounded,
                size: 13,
                color: _T.inkMid,
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: AppType.style(
                  FontSize.s10,
                  w: FontWeight.w700,
                  color: _T.inkMid,
                  letterSpacing: 0.8,
                ),
              ),
              const Spacer(),
              if (recents.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    _RecentSearches.clear(_tab);
                    _refreshFiltered();
                  },
                  child: Text(
                    'Clear',
                    style: AppType.style(
                      FontSize.s10,
                      w: FontWeight.w600,
                      color: _T.clay,
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(
          height: 46,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (ctx, i) => _SuggestionChip(
              label: items[i],
              isCity: _tab == _Tab.cities,
              onTap: () => _onItemTap(items[i]),
            ),
          ),
        ),
        const SizedBox(height: 6),
      ],
    );
  }

  Widget _buildStickyFooter() {
    final canContinue = _hasValidFromSelection && _hasValidToSelection;
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      bottom: canContinue ? 24 : -120,
      left: 24,
      right: 24,
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
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
      itemCount: 6,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _T.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _T.divider, width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _T.divider,
                borderRadius: BorderRadius.circular(13),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Container(
                height: 14,
                decoration: BoxDecoration(
                  color: _T.divider,
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    final q = _query.value.trim();
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: _T.mossSoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              size: 36,
              color: _T.forest,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            q.isEmpty ? 'Nothing here yet' : 'No matches for "$q"',
            textAlign: TextAlign.center,
            style: AppType.style(
              FontSize.s14,
              w: FontWeight.w700,
              color: _T.ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different spelling or search term',
            style: AppType.style(FontSize.s11, color: _T.inkMid),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 48, color: _T.inkLight),
            const SizedBox(height: 16),
            Text(
              msg,
              textAlign: TextAlign.center,
              style: AppType.style(FontSize.s12, color: _T.inkMid),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _retry,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 26,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: _T.forest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Retry',
                  style: AppType.style(
                    FontSize.s11,
                    w: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  _DashedLinePainter(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    double dashWidth = 6, dashSpace = 6, startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SuggestionChip extends StatelessWidget {
  final String label;
  final bool isCity;
  final VoidCallback onTap;
  const _SuggestionChip({
    required this.label,
    required this.isCity,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _T.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _T.divider, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isCity ? Icons.location_city_rounded : Icons.terrain_rounded,
              size: 15,
              color: isCity ? _T.forest : _T.clay,
            ),
            const SizedBox(width: 7),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 130),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppType.style(
                  FontSize.s11,
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

class _ResultTile extends StatelessWidget {
  final String label;
  final String query;
  final bool isCity;
  final bool isSelected;
  final VoidCallback onTap;
  const _ResultTile({
    required this.label,
    required this.query,
    required this.isCity,
    required this.isSelected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: _T.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? _T.forest : _T.divider,
            width: isSelected ? 1.4 : 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isCity ? _T.mossSoft : _T.claySoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isCity ? Icons.location_city_rounded : Icons.terrain_rounded,
                color: isCity ? _T.forest : _T.clay,
                size: 18,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(child: _buildHighlightedText(label, query)),
            const SizedBox(width: 8),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, size: 19, color: _T.forest)
            else
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 13,
                color: _T.inkLight,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightedText(String text, String query) {
    if (query.isEmpty)
      return Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppType.style(FontSize.s11, w: FontWeight.w600, color: _T.ink),
      );
    final q = query.toLowerCase();
    final lower = text.toLowerCase();
    final idx = lower.indexOf(q);
    if (idx == -1)
      return Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppType.style(FontSize.s11, w: FontWeight.w600, color: _T.ink),
      );
    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: AppType.style(FontSize.s11, w: FontWeight.w600, color: _T.ink),
        children: [
          TextSpan(text: text.substring(0, idx)),
          TextSpan(
            text: text.substring(idx, idx + q.length),
            style: TextStyle(color: _T.forest, fontWeight: FontWeight.w800),
          ),
          TextSpan(text: text.substring(idx + q.length)),
        ],
      ),
    );
  }
}
