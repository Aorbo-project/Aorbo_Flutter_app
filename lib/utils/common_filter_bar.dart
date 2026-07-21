import 'package:arobo_app/utils/arobo_theme.dart';
import 'package:arobo_app/utils/common_images.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/filter_category_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// TRAIL THEME TOKENS — matches CommonTrekCard's alpine palette
// ─────────────────────────────────────────────────────────────────────────────
class _FT {
  static const bg = Color(0xFFF6FAF7);
  static const card = Colors.white;
  static const elevated = Color(0xFFF1F7F2);
  static const border = Color(0xFFD8E2DA);
  static const ink = Color(0xFF16281E);
  static const inkMid = Color(0xFF5B6E60);
  static const inkLight = Color(0xFF8FA396);
  static const forest = Color(0xFF2D6A4F);
  static const forestDeep = Color(0xFF1B4332);
  static const forestSoft = Color(0xFFE8F3ED);
  static const amber = Color(0xFFD97706);
  static const amberBg = Color(0xFFFFF8EB);
  static const amberBorder = Color(0xFFF5DFAE);
  static const danger = Color(0xFFDC2626);
  static const gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [forestDeep, forest],
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Only "Offers" is truly multi-select.
// ─────────────────────────────────────────────────────────────────────────────
const _multiSelectCategories = {'Offers'};
bool _isMultiSelect(String categoryTitle) =>
    _multiSelectCategories.contains(categoryTitle);
final List<FilterCategory> _appFilterCategories = [
  FilterCategory(
    title: 'Sort',
    svgPath: CommonImages.sort,
    options: [
      FilterOptionModel(title: 'Recommended', query: 'sort_by=relevance'),
      FilterOptionModel(
        title: 'Price: Low → High',
        query: 'sort_by=base_price&sort_order=ASC',
      ),
      FilterOptionModel(
        title: 'Price: High → Low',
        query: 'sort_by=base_price&sort_order=DESC',
      ),
      FilterOptionModel(
        title: 'Newest First',
        query: 'sort_by=created_at&sort_order=DESC',
      ),
      FilterOptionModel(
        title: 'Top Rated',
        query: 'sort_by=rating&sort_order=DESC',
      ),
    ],
  ),
  FilterCategory(
    title: 'Duration',
    svgPath: CommonImages.duration,
    options: [
      FilterOptionModel(title: '2D / 1N', query: 'duration_days=2'),
      FilterOptionModel(title: '3D / 2N', query: 'duration_days=3'),
      FilterOptionModel(title: '4D / 3N', query: 'duration_days=4'),
      FilterOptionModel(title: '5D / 4N', query: 'duration_days=5'),
      FilterOptionModel(title: '6D / 5N', query: 'duration_days=6'),
      FilterOptionModel(title: '7D+', query: 'min_duration_days=7'),
    ],
  ),
  FilterCategory(
    title: 'Policy',
    svgPath: CommonImages.filter,
    options: [
      FilterOptionModel(title: 'Flexible', query: 'policy=flexible'),
      FilterOptionModel(title: 'Standard', query: 'policy=standard'),
      FilterOptionModel(title: 'Strict', query: 'policy=strict'),
    ],
  ),
  FilterCategory(
    title: 'Offers',
    svgPath: CommonImages.discount,
    options: [
      FilterOptionModel(title: 'Special Offers', query: 'offer=special'),
      FilterOptionModel(title: 'Early Bird', query: 'offer=early_bird'),
      FilterOptionModel(title: 'Last Minute', query: 'offer=last_minute'),
      FilterOptionModel(title: 'Exclusive Deals', query: 'offer=exclusive'),
    ],
  ),
  FilterCategory(
    title: 'Solo',
    svgPath: CommonImages.solo,
    options: [
      FilterOptionModel(title: 'Solo Traveller', query: 'solo=true'),
      FilterOptionModel(title: 'Female Solo', query: 'solo=true&gender=female'),
    ],
  ),
  FilterCategory(
    title: 'Rating',
    svgPath: CommonImages.stars,
    options: [
      FilterOptionModel(title: '4.5+ Stars', query: 'min_rating=4.5'),
      FilterOptionModel(title: '4+ Stars', query: 'min_rating=4'),
      FilterOptionModel(title: '3.5+ Stars', query: 'min_rating=3.5'),
      FilterOptionModel(title: '3+ Stars', query: 'min_rating=3'),
    ],
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// QUERY BUILDER
// ─────────────────────────────────────────────────────────────────────────────
String buildFilterQueryString(
  List<String> selectedTitles, {
  bool groupBooking = false,
}) {
  final singleParams = <String, String>{};
  final multiParams = <String, List<String>>{};
  for (final cat in _appFilterCategories) {
    final selectedOpts = cat.options
        .where((o) => selectedTitles.contains(o.title) && o.query.isNotEmpty)
        .toList();
    if (selectedOpts.isEmpty) continue;
    final isMulti = _isMultiSelect(cat.title);
    final optsToUse = isMulti
        ? selectedOpts
        : [
            selectedOpts.reduce(
              (a, b) =>
                  selectedTitles.lastIndexOf(a.title) >
                      selectedTitles.lastIndexOf(b.title)
                  ? a
                  : b,
            ),
          ];
    for (final opt in optsToUse) {
      for (final pair in opt.query.split('&')) {
        final kv = pair.split('=');
        if (kv.length != 2) continue;
        final key = kv[0];
        final value = kv[1];
        if (isMulti) {
          multiParams.putIfAbsent(key, () => []).add(value);
        } else {
          singleParams[key] = value;
        }
      }
    }
  }
  final parts = <String>[];
  for (final entry in singleParams.entries) {
    parts.add('${entry.key}=${entry.value}');
  }
  for (final entry in multiParams.entries) {
    parts.add('${entry.key}=${entry.value.join(',')}');
  }
  if (groupBooking) parts.add('group_booking=true');
  return parts.join('&');
}

class FilterSheetResult {
  final List<String> selectedTitles;
  final bool groupBookingEnabled;
  const FilterSheetResult({
    required this.selectedTitles,
    required this.groupBookingEnabled,
  });
}

/// Opens the full filter bottom sheet. Returns null if dismissed.
Future<FilterSheetResult?> showAroboFilterSheet(
  BuildContext context, {
  List<String> initialSelections = const [],
  String? initialCategory,
  bool initialGroupBooking = false,
}) {
  HapticFeedback.selectionClick();
  return showModalBottomSheet<FilterSheetResult>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    useSafeArea: true,
    enableDrag: true,
    builder: (_) => _FilterSheetContent(
      initialSelections: List.from(initialSelections),
      initialCategory: initialCategory ?? _appFilterCategories.first.title,
      initialGroupBooking: initialGroupBooking,
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// FLOATING FILTER FAB
// ─────────────────────────────────────────────────────────────────────────────
class AroboFilterFab extends StatefulWidget {
  final List<String> activeFilters;
  final bool groupBookingEnabled;
  final ValueChanged<FilterSheetResult> onResult;
  const AroboFilterFab({
    super.key,
    required this.activeFilters,
    required this.groupBookingEnabled,
    required this.onResult,
  });
  @override
  State<AroboFilterFab> createState() => _AroboFilterFabState();
}

class _AroboFilterFabState extends State<AroboFilterFab> {
  bool _panelOpen = false;
  int get _count =>
      widget.activeFilters.length + (widget.groupBookingEnabled ? 1 : 0);
  @override
  void didUpdateWidget(covariant AroboFilterFab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_count == 0 && _panelOpen) _panelOpen = false;
  }

  Future<void> _openSheet() async {
    setState(() => _panelOpen = false);
    final result = await showAroboFilterSheet(
      context,
      initialSelections: List.from(widget.activeFilters),
      initialGroupBooking: widget.groupBookingEnabled,
    );
    if (!mounted || result == null) return;
    widget.onResult(result);
  }

  void _togglePanel() {
    if (_count == 0) return;
    HapticFeedback.selectionClick();
    setState(() => _panelOpen = !_panelOpen);
  }

  void _removeFilter(String title) {
    HapticFeedback.lightImpact();
    final next = List<String>.from(widget.activeFilters)..remove(title);
    widget.onResult(
      FilterSheetResult(
        selectedTitles: next,
        groupBookingEnabled: widget.groupBookingEnabled,
      ),
    );
  }

  void _removeGroupBooking() {
    HapticFeedback.lightImpact();
    widget.onResult(
      FilterSheetResult(
        selectedTitles: List.from(widget.activeFilters),
        groupBookingEnabled: false,
      ),
    );
  }

  void _clearAll() {
    HapticFeedback.mediumImpact();
    setState(() => _panelOpen = false);
    widget.onResult(
      const FilterSheetResult(selectedTitles: [], groupBookingEnabled: false),
    );
  }

  @override
  Widget build(BuildContext context) {
    final count = _count;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          switchInCurve: Curves.easeOutBack,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: ScaleTransition(
              scale: anim,
              alignment: Alignment.bottomRight,
              child: child,
            ),
          ),
          child: (_panelOpen && count > 0)
              ? Padding(
                  key: const ValueKey('filters-panel'),
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ActiveFiltersPanel(
                    selected: widget.activeFilters,
                    groupBooking: widget.groupBookingEnabled,
                    onRemove: _removeFilter,
                    onRemoveGroupBooking: _removeGroupBooking,
                    onClearAll: _clearAll,
                  ),
                )
              : const SizedBox.shrink(key: ValueKey('filters-panel-empty')),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          transitionBuilder: (child, anim) =>
              ScaleTransition(scale: anim, child: child),
          child: count > 0
              ? Padding(
                  key: const ValueKey('peek-btn'),
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GestureDetector(
                    onTap: _togglePanel,
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: _FT.card,
                        shape: BoxShape.circle,
                        border: Border.all(color: _FT.border),
                        boxShadow: [
                          BoxShadow(
                            color: _FT.forestDeep.withValues(alpha: 0.12),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        _panelOpen
                            ? Icons.close_rounded
                            : Icons.visibility_rounded,
                        size: 18,
                        color: _FT.forest,
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(key: ValueKey('peek-btn-empty')),
        ),
        GestureDetector(
          onTap: _openSheet,
          onLongPress: _togglePanel,
          child: Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              gradient: _FT.gradient,
              borderRadius: BorderRadius.circular(19),
              boxShadow: [
                BoxShadow(
                  color: _FT.forestDeep.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Center(
                  child: Icon(
                    Icons.tune_rounded,
                    size: 24,
                    color: Colors.white,
                  ),
                ),
                if (count > 0)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: _FT.amber,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.8),
                      ),
                      child: Center(
                        child: Text(
                          '$count',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ActiveFiltersPanel extends StatelessWidget {
  final List<String> selected;
  final bool groupBooking;
  final ValueChanged<String> onRemove;
  final VoidCallback onRemoveGroupBooking;
  final VoidCallback onClearAll;
  const _ActiveFiltersPanel({
    required this.selected,
    required this.groupBooking,
    required this.onRemove,
    required this.onRemoveGroupBooking,
    required this.onClearAll,
  });
  @override
  Widget build(BuildContext context) {
    final sections = <Widget>[];
    for (final cat in _appFilterCategories) {
      final opts = cat.options
          .where((o) => selected.contains(o.title))
          .toList();
      if (opts.isEmpty) continue;
      sections.add(
        _PanelSection(
          svgPath: cat.svgPath,
          title: cat.title,
          chips: opts
              .map(
                (o) => _PanelChip(
                  label: o.title,
                  color: _FT.forest,
                  onRemove: () => onRemove(o.title),
                ),
              )
              .toList(),
        ),
      );
    }
    if (groupBooking) {
      sections.add(
        _PanelSection(
          svgPath: CommonImages.group,
          title: 'Extras',
          chips: [
            _PanelChip(
              label: 'Group Booking',
              color: _FT.amber,
              onRemove: onRemoveGroupBooking,
            ),
          ],
        ),
      );
    }
    return Container(
      width: 272,
      constraints: const BoxConstraints(maxHeight: 340),
      decoration: BoxDecoration(
        color: _FT.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _FT.border, width: 0.9),
        boxShadow: const [
          BoxShadow(
            color: Color(0x24000000),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 12, 10),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: _FT.forestSoft,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(
                    Icons.tune_rounded,
                    size: 14,
                    color: _FT.forest,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Active Filters',
                    style: AroboTheme.label(
                      size: 12,
                      weight: FontWeight.w800,
                      color: _FT.ink,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onClearAll,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _FT.danger.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(
                        AroboTheme.radiusPill,
                      ),
                    ),
                    child: Text(
                      'Clear all',
                      style: AroboTheme.label(
                        size: 10,
                        weight: FontWeight.w700,
                        color: _FT.danger,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: _FT.border),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: sections,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PanelSection extends StatelessWidget {
  final String svgPath;
  final String title;
  final List<Widget> chips;
  const _PanelSection({
    required this.svgPath,
    required this.title,
    required this.chips,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _SvgIcon(path: svgPath, color: _FT.inkMid, size: 12),
              const SizedBox(width: 6),
              Text(
                title.toUpperCase(),
                style: AroboTheme.label(
                  size: 8.5,
                  weight: FontWeight.w800,
                  color: _FT.inkMid,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Wrap(spacing: 6, runSpacing: 6, children: chips),
        ],
      ),
    );
  }
}

class _PanelChip extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onRemove;
  const _PanelChip({
    required this.label,
    required this.color,
    required this.onRemove,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 4, top: 4, bottom: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AroboTheme.radiusPill),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AroboTheme.label(
              size: 10,
              weight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(width: 5),
          GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close_rounded, size: 10, color: color),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FILTER SHEET CONTENT
// ─────────────────────────────────────────────────────────────────────────────
class _FilterSheetContent extends StatefulWidget {
  final List<String> initialSelections;
  final String initialCategory;
  final bool initialGroupBooking;
  const _FilterSheetContent({
    required this.initialSelections,
    required this.initialCategory,
    required this.initialGroupBooking,
  });
  @override
  State<_FilterSheetContent> createState() => _FilterSheetContentState();
}

class _FilterSheetContentState extends State<_FilterSheetContent>
    with SingleTickerProviderStateMixin {
  late List<String> _draft;
  late String _activeCategory;
  late bool _groupBooking;
  late AnimationController _fadeCtrl;
  late Animation<double> _fade;
  FilterCategory get _currentCategory => _appFilterCategories.firstWhere(
    (c) => c.title == _activeCategory,
    orElse: () => _appFilterCategories.first,
  );
  @override
  void initState() {
    super.initState();
    _draft = List.from(widget.initialSelections);
    _groupBooking = widget.initialGroupBooking;
    final exists = _appFilterCategories.any(
      (c) => c.title == widget.initialCategory,
    );
    _activeCategory = exists
        ? widget.initialCategory
        : _appFilterCategories.first.title;
    _fadeCtrl = AnimationController(vsync: this, duration: AroboTheme.durFast)
      ..forward();
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: AroboTheme.easeOut);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _switchCategory(String title) {
    if (_activeCategory == title) return;
    HapticFeedback.selectionClick();
    _fadeCtrl.reset();
    setState(() => _activeCategory = title);
    _fadeCtrl.forward();
  }

  void _toggleOption(FilterOptionModel opt) {
    HapticFeedback.selectionClick();
    setState(() {
      final cat = _currentCategory;
      final already = _draft.contains(opt.title);
      if (_isMultiSelect(cat.title)) {
        already ? _draft.remove(opt.title) : _draft.add(opt.title);
      } else {
        final catOptionTitles = cat.options.map((o) => o.title).toSet();
        _draft.removeWhere((t) => catOptionTitles.contains(t));
        if (!already) _draft.add(opt.title);
      }
    });
  }

  void _clearDraft() {
    HapticFeedback.lightImpact();
    setState(() {
      _draft.clear();
      _groupBooking = false;
    });
  }

  void _apply() {
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop(
      FilterSheetResult(
        selectedTitles: List<String>.from(_draft),
        groupBookingEnabled: _groupBooking,
      ),
    );
  }

  int _categoryCount(FilterCategory cat) =>
      cat.options.where((o) => _draft.contains(o.title)).length;
  @override
  Widget build(BuildContext context) {
    final sheetH = MediaQuery.of(context).size.height * 0.82;
    final total = _draft.length + (_groupBooking ? 1 : 0);
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: sheetH,
        decoration: BoxDecoration(
          color: _FT.bg,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AroboTheme.radiusXl),
          ),
          border: Border.all(color: _FT.border, width: 0.8),
          boxShadow: const [
            BoxShadow(
              color: Color(0x21000000),
              blurRadius: 32,
              offset: Offset(0, -6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            _SheetTopAccent(),
            _SheetHeader(
              count: _draft.length,
              groupBooking: _groupBooking,
              onClose: () => Navigator.of(context).pop(),
              onClear: total > 0 ? _clearDraft : null,
            ),
            Container(height: 1, color: _FT.border),
            _GroupBookingCard(
              value: _groupBooking,
              onChanged: (v) => setState(() => _groupBooking = v),
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 92,
                    decoration: const BoxDecoration(
                      color: _FT.elevated,
                      border: Border(right: BorderSide(color: _FT.border)),
                    ),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      physics: const BouncingScrollPhysics(),
                      itemCount: _appFilterCategories.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 4),
                      itemBuilder: (_, i) {
                        final cat = _appFilterCategories[i];
                        final active = _activeCategory == cat.title;
                        final count = _categoryCount(cat);
                        return _VerticalCategoryTab(
                          cat: cat,
                          active: active,
                          count: count > 0 ? count : null,
                          onTap: () => _switchCategory(cat.title),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: FadeTransition(
                      opacity: _fade,
                      child: AnimatedSwitcher(
                        duration: AroboTheme.durFast,
                        transitionBuilder: (child, anim) => FadeTransition(
                          opacity: anim,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.05, 0),
                              end: Offset.zero,
                            ).animate(anim),
                            child: child,
                          ),
                        ),
                        child: _OptionGrid(
                          key: ValueKey(_activeCategory),
                          category: _currentCategory,
                          selected: _draft,
                          onTap: _toggleOption,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _SheetFooter(count: total, onApply: _apply),
          ],
        ),
      ),
    );
  }
}

class _SheetTopAccent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Container(
          width: 38,
          height: 4,
          decoration: BoxDecoration(
            color: _FT.inkLight.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(AroboTheme.radiusPill),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 2,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                _FT.forest,
                _FT.amber,
                Colors.transparent,
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SheetHeader extends StatelessWidget {
  final int count;
  final bool groupBooking;
  final VoidCallback onClose;
  final VoidCallback? onClear;
  const _SheetHeader({
    required this.count,
    required this.groupBooking,
    required this.onClose,
    this.onClear,
  });
  @override
  Widget build(BuildContext context) {
    final total = count + (groupBooking ? 1 : 0);
    return Stack(
      children: [
        const Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(painter: _HeaderRidgePainter()),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 14, 12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: _FT.gradient,
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: [
                    BoxShadow(
                      color: _FT.forestDeep.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  size: 22,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedSwitcher(
                      duration: AroboTheme.durFast,
                      child: Text(
                        total > 0
                            ? 'Filters  ·  $total active'
                            : 'Filter Treks',
                        key: ValueKey(total),
                        style: AroboTheme.label(
                          size: 16,
                          weight: FontWeight.w800,
                          color: _FT.ink,
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      total > 0
                          ? 'Manage them anytime from the floating button'
                          : 'Narrow down your perfect trek',
                      style: AroboTheme.label(size: 10.5, color: _FT.inkMid),
                    ),
                  ],
                ),
              ),
              if (onClear != null) ...[
                _GhostPill(
                  label: 'Clear all',
                  icon: Icons.delete_sweep_rounded,
                  onTap: onClear!,
                ),
                const SizedBox(width: 8),
              ],
              _RoundIconButton(icon: Icons.close_rounded, onTap: onClose),
            ],
          ),
        ),
      ],
    );
  }
}

class _GhostPill extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _GhostPill({
    required this.label,
    required this.icon,
    required this.onTap,
  });
  @override
  State<_GhostPill> createState() => _GhostPillState();
}

class _GhostPillState extends State<_GhostPill> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: AroboTheme.durFast,
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(
          color: _pressed ? _FT.forestSoft : _FT.card,
          borderRadius: BorderRadius.circular(AroboTheme.radiusPill),
          border: Border.all(
            color: _pressed ? _FT.forest.withValues(alpha: 0.4) : _FT.border,
          ),
          boxShadow: AroboTheme.softShadow(),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(widget.icon, size: 13, color: _FT.forest),
            const SizedBox(width: 5),
            Text(
              widget.label,
              style: AroboTheme.label(
                size: 11,
                weight: FontWeight.w700,
                color: _FT.forest,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundIconButton({required this.icon, required this.onTap});
  @override
  State<_RoundIconButton> createState() => _RoundIconButtonState();
}

class _RoundIconButtonState extends State<_RoundIconButton> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: AroboTheme.durFast,
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _pressed ? _FT.forestSoft : _FT.card,
          shape: BoxShape.circle,
          border: Border.all(color: _FT.border),
          boxShadow: AroboTheme.softShadow(),
        ),
        child: Icon(widget.icon, color: _FT.inkMid, size: 20),
      ),
    );
  }
}

class _VerticalCategoryTab extends StatelessWidget {
  final FilterCategory cat;
  final bool active;
  final int? count;
  final VoidCallback onTap;
  const _VerticalCategoryTab({
    required this.cat,
    required this.active,
    required this.onTap,
    this.count,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AroboTheme.durFast,
        curve: AroboTheme.easeOut,
        margin: const EdgeInsets.symmetric(horizontal: 7),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        decoration: BoxDecoration(
          color: active ? _FT.card : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active
                ? _FT.forest.withValues(alpha: 0.35)
                : Colors.transparent,
            width: 1.0,
          ),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: _FT.forestDeep.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                _SvgIcon(
                  path: cat.svgPath,
                  color: active ? _FT.forest : _FT.inkMid,
                  size: 20,
                ),
                if (count != null)
                  Positioned(
                    top: -4,
                    right: -6,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: active ? _FT.forest : _FT.amber,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      child: Center(
                        child: Text(
                          '$count',
                          style: AroboTheme.label(
                            size: 7,
                            weight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              cat.title,
              textAlign: TextAlign.center,
              style: AroboTheme.label(
                size: 9.5,
                weight: active ? FontWeight.w800 : FontWeight.w500,
                color: active ? _FT.forest : _FT.inkMid,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupBookingCard extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const _GroupBookingCard({required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AroboTheme.durFast,
      margin: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: value ? _FT.amberBg : _FT.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: value ? _FT.amber : _FT.border, width: 0.9),
        boxShadow: AroboTheme.softShadow(),
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: AroboTheme.durFast,
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: value ? _FT.amber : _FT.elevated,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: SvgPicture.asset(
                CommonImages.group,
                width: 18,
                height: 18,
                colorFilter: ColorFilter.mode(
                  value ? Colors.white : _FT.inkMid,
                  BlendMode.srcIn,
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
                  'Booking for Groups',
                  style: AroboTheme.label(
                    size: 12,
                    weight: FontWeight.w700,
                    color: value ? _FT.amber : _FT.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Exclusive deals for 4+ members',
                  style: AroboTheme.label(size: 9.5, color: _FT.inkMid),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: (v) {
              HapticFeedback.selectionClick();
              onChanged(v);
            },
            activeThumbColor: Colors.white,
            activeTrackColor: _FT.amber,
            inactiveTrackColor: _FT.elevated,
            inactiveThumbColor: _FT.inkMid,
          ),
        ],
      ),
    );
  }
}

class _OptionGrid extends StatelessWidget {
  final FilterCategory category;
  final List<String> selected;
  final ValueChanged<FilterOptionModel> onTap;
  const _OptionGrid({
    super.key,
    required this.category,
    required this.selected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final multi = _isMultiSelect(category.title);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                category.title.toUpperCase(),
                style: AroboTheme.label(
                  size: 9.5,
                  weight: FontWeight.w800,
                  color: _FT.inkMid,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(child: Container(height: 1, color: _FT.border)),
              if (multi) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _FT.amberBg,
                    borderRadius: BorderRadius.circular(AroboTheme.radiusPill),
                    border: Border.all(color: _FT.amberBorder, width: 0.7),
                  ),
                  child: Text(
                    'multi‑select',
                    style: AroboTheme.label(
                      size: 9,
                      color: _FT.amber,
                      weight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisExtent: 62,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: category.options.length,
              itemBuilder: (_, i) {
                final opt = category.options[i];
                return _OptionCard(
                  option: opt,
                  isSelected: selected.contains(opt.title),
                  onTap: () => onTap(opt),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionCard extends StatefulWidget {
  final FilterOptionModel option;
  final bool isSelected;
  final VoidCallback onTap;
  const _OptionCard({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });
  @override
  State<_OptionCard> createState() => _OptionCardState();
}

class _OptionCardState extends State<_OptionCard>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;
  late AnimationController _scaleCtrl;
  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      lowerBound: 0.94,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onTapDown: (_) {
        setState(() => _pressed = true);
        _scaleCtrl.reverse();
      },
      onTapUp: (_) {
        setState(() => _pressed = false);
        _scaleCtrl.forward();
      },
      onTapCancel: () {
        setState(() => _pressed = false);
        _scaleCtrl.forward();
      },
      child: AnimatedBuilder(
        animation: _scaleCtrl,
        builder: (_, child) =>
            Transform.scale(scale: _scaleCtrl.value, child: child),
        child: AnimatedContainer(
          duration: AroboTheme.durFast,
          curve: AroboTheme.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? _FT.forestSoft
                : _pressed
                ? _FT.elevated
                : _FT.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: widget.isSelected ? _FT.forest : _FT.border,
              width: widget.isSelected ? 1.2 : 0.8,
            ),
            boxShadow: AroboTheme.softShadow(),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: AroboTheme.durFast,
                curve: AroboTheme.spring,
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.isSelected ? _FT.forest : Colors.transparent,
                  border: Border.all(
                    color: widget.isSelected ? _FT.forest : _FT.inkLight,
                    width: widget.isSelected ? 0 : 1.5,
                  ),
                ),
                child: widget.isSelected
                    ? const Icon(
                        Icons.check_rounded,
                        size: 12,
                        color: Colors.white,
                      )
                    : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.option.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AroboTheme.label(
                    size: 10.5,
                    weight: widget.isSelected
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: widget.isSelected ? _FT.forestDeep : _FT.ink,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetFooter extends StatelessWidget {
  final int count;
  final VoidCallback onApply;
  const _SheetFooter({required this.count, required this.onApply});
  @override
  Widget build(BuildContext context) {
    final hasFilters = count > 0;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      decoration: BoxDecoration(
        color: _FT.card,
        border: const Border(top: BorderSide(color: _FT.border)),
        boxShadow: AroboTheme.softShadow(0.05),
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 4),
        child: SizedBox(
          height: 50,
          width: double.infinity,
          child: AnimatedContainer(
            duration: AroboTheme.durFast,
            decoration: BoxDecoration(
              gradient: hasFilters ? _FT.gradient : null,
              color: hasFilters ? null : _FT.elevated,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: hasFilters ? _FT.forestDeep : _FT.border,
                width: hasFilters ? 0 : 1,
              ),
              boxShadow: hasFilters
                  ? [
                      BoxShadow(
                        color: _FT.forestDeep.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                // Always tappable — applying with zero selections clears filters
                onTap: onApply,
                borderRadius: BorderRadius.circular(16),
                splashColor: Colors.white.withValues(alpha: 0.15),
                highlightColor: Colors.transparent,
                child: Center(
                  child: AnimatedSwitcher(
                    duration: AroboTheme.durFast,
                    child: Row(
                      key: ValueKey(hasFilters),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          hasFilters
                              ? Icons.check_circle_outline_rounded
                              : Icons.filter_list_rounded,
                          size: 16,
                          color: hasFilters ? Colors.white : _FT.inkMid,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          hasFilters
                              ? 'Apply  ·  $count selected'
                              : 'Apply (no filters)',
                          style: AroboTheme.label(
                            size: 12,
                            weight: FontWeight.w800,
                            color: hasFilters ? Colors.white : _FT.inkMid,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SvgIcon extends StatelessWidget {
  final String path;
  final Color color;
  final double size;
  const _SvgIcon({required this.path, required this.color, required this.size});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: SvgPicture.asset(
        path,
        fit: BoxFit.contain,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        errorBuilder: (_, __, ___) => Icon(
          Icons.filter_alt_outlined,
          size: size,
          color: color.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Faint ridge line behind the sheet header — same alpine DNA as the trek card
// ─────────────────────────────────────────────────────────────────────────────
class _HeaderRidgePainter extends CustomPainter {
  const _HeaderRidgePainter();
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final ridge = Path()
      ..moveTo(w * 0.45, h)
      ..lineTo(w * 0.56, h * 0.35)
      ..lineTo(w * 0.66, h * 0.75)
      ..lineTo(w * 0.76, h * 0.20)
      ..lineTo(w * 0.88, h * 0.70)
      ..lineTo(w, h * 0.45)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(ridge, Paint()..color = _FT.forest.withValues(alpha: 0.05));
  }

  @override
  bool shouldRepaint(_HeaderRidgePainter old) => false;
}
