import 'dart:async';
import 'dart:collection';
import 'package:arobo_app/controller/dashboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:arobo_app/utils/screen_constants.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:arobo_app/theme/app_tokens.dart';
import 'package:arobo_app/theme/app_typography.dart';

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
  static const heroBg = AppColors.bg;
  static const ink = Color(0xFF16261E);
  static const inkMid = Color(0xFF5C6F63);
  static const inkLight = Color(0xFF9DABA1);
  static const error = Color(0xFFC13A2B);
  static const errorSoft = Color(0xFFFCEDEA);
}

enum _Tab { cities, treks }

enum _ListState { idle, loading, empty, error, noNetwork, ready }

// ─────────────────────────────────────────────
//  FALLBACK POPULAR DATA
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
  bool _navigatingBack = false;
  bool _itemTapInFlight = false;
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

    _fromCtrl.addListener(_onFromChanged);
    _toCtrl.addListener(_onToChanged);
    _fromFocus.addListener(_onFromFocusChange);
    _toFocus.addListener(_onToFocusChange);

    _citiesWorker = ever(_dashboardC.citiesData, (_) {
      if (!mounted) return;
      final data = _dashboardC.citiesData.value.data;
      if (data != null) {
        _citiesError = '';
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
      if (fromValid) {
        setState(() {
          _tab = _Tab.treks;
        });
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
  bool get _hasValidFromSelection =>
      _fromCityId != 0 || _pendingCityName != null;
  bool get _hasValidToSelection =>
      _selectedTrekId != 0 || _pendingTrekName != null;

  void _maybeAutoComplete() {
    if (_fromCityId != 0 && _selectedTrekId != 0 && !_navigatingBack)
      _closeWithResult();
  }

  void _onFromChanged() {
    final text = _fromCtrl.text;
    _dashboardC.fromController.value.text = text;
    if (_fromCityId != 0) {
      final selectedName = _nameForCityId(_fromCityId);
      if (selectedName == null ||
          selectedName.toLowerCase() != text.trim().toLowerCase())
        _fromCityId = 0;
    }
    if (_pendingCityName != null &&
        _pendingCityName!.toLowerCase() != text.trim().toLowerCase())
      _pendingCityName = null;
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
    if (_pendingTrekName != null &&
        _pendingTrekName!.toLowerCase() != text.trim().toLowerCase())
      _pendingTrekName = null;
    if (mounted) setState(() {});
  }

  void _onFromFocusChange() {
    if (!mounted || _itemTapInFlight) return;
    if (_fromFocus.hasFocus && _tab != _Tab.cities)
      _setActiveField(_Tab.cities);
    if (mounted) setState(() {});
  }

  void _onToFocusChange() {
    if (!mounted || _itemTapInFlight) return;
    if (_toFocus.hasFocus && _tab != _Tab.treks) {
      if (!_hasValidFromSelection) {
        FocusScope.of(context).requestFocus(_fromFocus);
        return;
      }
      _setActiveField(_Tab.treks);
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
    super.dispose();
  }

  void _setActiveField(_Tab tab) {
    if (tab == _Tab.treks && !_hasValidFromSelection) {
      _fromFocus.requestFocus();
      HapticFeedback.mediumImpact();
      return;
    }
    if (_tab != tab) {
      setState(() => _tab = tab);
      _query.value = _activeRawText;
      _refreshFiltered();
    }
    if (tab == _Tab.cities) {
      _fromFocus.requestFocus();
    } else {
      _toFocus.requestFocus();
    }
  }

  String get _activeRawText =>
      _tab == _Tab.cities ? _fromCtrl.text : _toCtrl.text;

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
        _setActiveField(_Tab.treks);
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
        if (_fromCityId != 0 && _selectedTrekId != 0) await _closeWithResult();
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
        if ((c.cityName ?? '').trim().toLowerCase() == lower)
          return _NamedEntry(id: c.id ?? 0, name: (c.cityName ?? '').trim());
      }
    }
    for (final c in _popularCitiesFallback) {
      if (c.toLowerCase() == lower) return _NamedEntry(id: 0, name: c);
    }
    return null;
  }

  _NamedEntry? _resolveTrekByName(String name) {
    final lower = name.toLowerCase();
    final data = _dashboardC.trekData.value.data;
    if (data != null) {
      for (final t in data) {
        if ((t.name ?? '').trim().toLowerCase() == lower)
          return _NamedEntry(id: t.id ?? 0, name: (t.name ?? '').trim());
      }
    }
    for (final t in _popularTreksFallback) {
      if (t.toLowerCase() == lower) return _NamedEntry(id: 0, name: t);
    }
    return null;
  }

  Future<void> _closeWithResult() async {
    if (_navigatingBack) return;
    if (_fromCityId == 0 || _selectedTrekId == 0) return;
    _navigatingBack = true;

    // Premium haptic feedback upon completing the route
    HapticFeedback.mediumImpact();

    // Return true to tell the Dashboard to automatically open the calendar
    Navigator.pop(context, true);
  }

  void _clearField(TextEditingController controller) {
    _searchDebounce.cancel();
    if (controller == _fromCtrl) {
      _fromCtrl.clear();
      _dashboardC.fromController.value.text = '';
      _fromCityId = 0;
      _pendingCityName = null;
      _toCtrl.clear();
      _dashboardC.toController.value.text = '';
      _selectedTrekId = 0;
      _pendingTrekName = null;
      _setActiveField(_Tab.cities);
      _query.value = '';
      _refreshFiltered();
    } else {
      _toCtrl.clear();
      _dashboardC.toController.value.text = '';
      _selectedTrekId = 0;
      _pendingTrekName = null;
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
        if (_fromCityId != 0 && _selectedTrekId != 0) _closeWithResult();
      }
    }
  }

  String? _fromErrorText() {
    if (_fromFocus.hasFocus) return null;
    if (_pendingCityName != null) return null;
    if (_fromCtrl.text.trim().isNotEmpty && _fromCityId == 0)
      return 'Please pick a city from the list';
    return null;
  }

  String? _toErrorText() {
    if (_toFocus.hasFocus) return null;
    if (_pendingTrekName != null) return null;
    if (_toCtrl.text.trim().isNotEmpty && _selectedTrekId == 0)
      return 'Please pick a trek from the list';
    return null;
  }

  // ───────────────────────────────────────────
  //  PREMIUM BUILD
  // ───────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    ScreenConstant.setScreenAwareConstant(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
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
                  _buildPremiumAppBar(),
                  _buildHeroRouteCard(),
                  _buildContextualSuggestions(),
                  Expanded(child: _buildSearchResults()),
                ],
              ),
            ),
            _buildStickyFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumAppBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(12, 8, 20, 16),
      child: Row(
        children: [
          IconButton(
            onPressed: Get.back,
            icon: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _T.card,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: _T.ink,
              ),
            ),
          ),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Plan your trek",
                style: AppType.style(
                  FontSize.s16,
                  w: FontWeight.w700,
                  color: _T.ink,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 2),
              Text(
                "Where does the journey begin?",
                style: AppType.style(FontSize.s10, color: _T.inkMid),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroRouteCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: _T.card,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: _T.pine.withAlpha(12),
            blurRadius: 30,
            offset: Offset(0, 15),
          ),
          BoxShadow(
            color: _T.pine.withAlpha(6),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
        border: Border.all(color: _T.divider, width: 0.5),
      ),
      child: Column(
        children: [
          _buildPremiumField(
            label: 'DEPARTURE CITY',
            hint: 'e.g. Delhi, Mumbai',
            controller: _fromCtrl,
            focusNode: _fromFocus,
            icon: Icons.trip_origin,
            isActive: _tab == _Tab.cities,
            onTap: () => _setActiveField(_Tab.cities),
            errorText: _fromErrorText(),
          ),
          _buildDividerWithIcon(),
          _buildPremiumField(
            label: 'DESTINATION TREK',
            hint: 'e.g. Kedarkantha, Roopkund',
            controller: _toCtrl,
            focusNode: _toFocus,
            icon: Icons.terrain,
            isActive: _tab == _Tab.treks,
            onTap: () => _setActiveField(_Tab.treks),
            errorText: _toErrorText(),
          ),
        ],
      ),
    );
  }

  Widget _buildDividerWithIcon() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: CustomPaint(
            painter: _DashedLinePainter(_T.divider),
            child: Container(height: 1),
          ),
        ),
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _T.card,
            shape: BoxShape.circle,
            border: Border.all(color: _T.divider, width: 1.5),
          ),
          child: Icon(Icons.hiking_rounded, size: 16, color: _T.clay),
        ),
      ],
    );
  }

  Widget _buildPremiumField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required FocusNode focusNode,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
    String? errorText,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isActive ? _T.focusBg : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: isActive ? _T.forest : _T.mossSoft,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    icon,
                    color: isActive ? Colors.white : _T.forest,
                    size: 20,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: AppType.style(
                          FontSize.s9,
                          w: FontWeight.w700,
                          color: _T.inkMid,
                          letterSpacing: 0.8,
                        ),
                      ),
                      SizedBox(height: 6),
                      TextField(
                        controller: controller,
                        focusNode: focusNode,
                        onChanged: _onSearchChanged,
                        onSubmitted: (_) => _onSubmitField(),
                        textInputAction: TextInputAction.done,
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
                          FontSize.s13,
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
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _T.divider,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
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
                padding: EdgeInsets.only(top: 8, left: 58),
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

  Widget _buildContextualSuggestions() {
    return Obx(() {
      final isSearching = _query.value.trim().isNotEmpty;
      if (isSearching) return SizedBox.shrink();
      final result = _filtered.value;
      final items = result.recent.isNotEmpty
          ? result.recent
          : (_tab == _Tab.cities
                ? _popularCitiesFallback
                : _popularTreksFallback);
      final title = result.recent.isNotEmpty
          ? "RECENT SEARCHES"
          : (_tab == _Tab.cities ? "POPULAR DEPARTURES" : "TRENDING TREKS");
      if (items.isEmpty) return SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(24, 20, 24, 12),
            child: Row(
              children: [
                Text(
                  title,
                  style: AppType.style(
                    FontSize.s10,
                    w: FontWeight.w700,
                    color: _T.inkMid,
                    letterSpacing: 0.8,
                  ),
                ),
                Spacer(),
                if (result.recent.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _RecentSearches.clear(_tab);
                      _refreshFiltered();
                    },
                    child: Text(
                      "Clear",
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
            height: 48,
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (_, __) => SizedBox(width: 10),
              itemBuilder: (ctx, i) => _PremiumChip(
                label: items[i],
                isCity: _tab == _Tab.cities,
                onTap: () => _onItemTap(items[i]),
              ),
            ),
          ),
          SizedBox(height: 12),
        ],
      );
    });
  }

  Widget _buildSearchResults() {
    return Obx(() {
      final result = _filtered.value;
      if (result.state == _ListState.loading) return _buildPremiumShimmer();
      if (result.state == _ListState.empty) return _buildPremiumEmpty();
      if (result.state == _ListState.error ||
          result.state == _ListState.noNetwork) {
        return _buildPremiumError(
          result.state == _ListState.noNetwork
              ? 'No internet connection'
              : _errorMessage,
        );
      }
      final items = result.items;
      if (items.isEmpty) return SizedBox.shrink();

      return ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        itemCount: items.length,
        itemBuilder: (ctx, i) => _PremiumListItem(
          label: items[i],
          query: result.query ?? '',
          isCity: _tab == _Tab.cities,
          onTap: () => _onItemTap(items[i]),
        ),
      );
    });
  }

  Widget _buildStickyFooter() {
    final canContinue = _hasValidFromSelection && _hasValidToSelection;
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      bottom: canContinue ? 24 : -100,
      left: 24,
      right: 24,
      child: GestureDetector(
        onTap: _closeWithResult,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [_T.pine, _T.forest]),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _T.forest.withAlpha(80),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.calendar_month_rounded,
                  size: 20,
                  color: Colors.white,
                ),
                const SizedBox(width: 10),
                Text(
                  "Choose Departure Date",
                  style: AppType.style(
                    FontSize.s13,
                    w: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumShimmer() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: 6,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (_, __) => Container(
        margin: EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _T.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _T.divider, width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _T.divider,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Container(
                height: 16,
                decoration: BoxDecoration(
                  color: _T.divider,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _T.mossSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.search_off_rounded, size: 36, color: _T.forest),
          ),
          SizedBox(height: 20),
          Text(
            "No matches found",
            style: AppType.style(
              FontSize.s14,
              w: FontWeight.w700,
              color: _T.ink,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Try a different spelling or search term",
            style: AppType.style(FontSize.s11, color: _T.inkMid),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumError(String msg) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off_rounded, size: 48, color: _T.inkLight),
          SizedBox(height: 16),
          Text(msg, style: AppType.style(FontSize.s12, color: _T.inkMid)),
          SizedBox(height: 16),
          GestureDetector(
            onTap: _retry,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: _T.forest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "Retry",
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

class _PremiumChip extends StatelessWidget {
  final String label;
  final bool isCity;
  final VoidCallback onTap;
  const _PremiumChip({
    required this.label,
    required this.isCity,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: _T.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _T.divider, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isCity ? Icons.location_city_rounded : Icons.terrain_rounded,
              size: 16,
              color: isCity ? _T.forest : _T.clay,
            ),
            SizedBox(width: 8),
            Text(
              label,
              style: AppType.style(
                FontSize.s11,
                w: FontWeight.w600,
                color: _T.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PremiumListItem extends StatelessWidget {
  final String label;
  final String query;
  final bool isCity;
  final VoidCallback onTap;
  const _PremiumListItem({
    required this.label,
    required this.query,
    required this.isCity,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _T.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _T.divider, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isCity ? _T.mossSoft : _T.claySoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                isCity ? Icons.location_city_rounded : Icons.terrain_rounded,
                color: isCity ? _T.forest : _T.clay,
                size: 22,
              ),
            ),
            SizedBox(width: 16),
            Expanded(child: _buildHighlightedText(label, query)),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: _T.inkLight),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightedText(String text, String query) {
    if (query.isEmpty)
      return Text(
        text,
        style: AppType.style(FontSize.s12, w: FontWeight.w600, color: _T.ink),
      );
    final q = query.toLowerCase();
    final lower = text.toLowerCase();
    final idx = lower.indexOf(q);
    if (idx == -1)
      return Text(
        text,
        style: AppType.style(FontSize.s12, w: FontWeight.w600, color: _T.ink),
      );
    return RichText(
      text: TextSpan(
        style: AppType.style(FontSize.s12, w: FontWeight.w600, color: _T.ink),
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
