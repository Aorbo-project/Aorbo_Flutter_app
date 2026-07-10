import 'package:arobo_app/utils/app_theme.dart';
import 'package:arobo_app/utils/common_images.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/filter_category_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// FIX 1: Only "Offers" is truly multi-select.
//   - Rating: selecting 4+ and 4.5+ is contradictory → must be single-select
//   - Solo: "Solo Traveller" and "Female Solo" are mutually exclusive → single-select
//   - Offers: user may want to see multiple offer types → keep multi-select
// ─────────────────────────────────────────────────────────────────────────────
const _multiSelectCategories = {'Offers'};
const _sortCategoryTitle = 'Sort';

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
      // FIX 2: "7D+" should match 7 OR MORE days, not exactly 7
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
// FIX 3: Completely rewritten to properly parse and merge query params.
//   - Single-select categories: last selected option wins, params set in a map
//   - Multi-select categories (Offers): values for same key are comma-separated
//   - Eliminates duplicate/conflicting query params
// ─────────────────────────────────────────────────────────────────────────────
String buildFilterQueryString(
  List<String> selectedTitles, {
  bool groupBooking = false,
}) {
  // Map for single-value params (sort_by, duration_days, policy, solo, gender, min_rating)
  final singleParams = <String, String>{};
  // Map for multi-value params (offer) — values collected into a list
  final multiParams = <String, List<String>>{};

  for (final cat in _appFilterCategories) {
    final selectedOpts = cat.options
        .where((o) => selectedTitles.contains(o.title) && o.query.isNotEmpty)
        .toList();
    if (selectedOpts.isEmpty) continue;

    final isMulti = _isMultiSelect(cat.title);

    // For single-select: pick the last-selected option
    // For multi-select: use all selected options
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
      // Parse each key=value pair from the option's query string
      // e.g. "sort_by=base_price&sort_order=ASC" → {sort_by: base_price, sort_order: ASC}
      // e.g. "solo=true&gender=female" → {solo: true, gender: female}
      for (final pair in opt.query.split('&')) {
        final kv = pair.split('=');
        if (kv.length != 2) continue;

        final key = kv[0];
        final value = kv[1];

        if (isMulti) {
          // Multi-select: collect all values for the same key
          // e.g. offer=special + offer=early_bird → offer: [special, early_bird]
          multiParams.putIfAbsent(key, () => []).add(value);
        } else {
          // Single-select: set/overwrite the value
          singleParams[key] = value;
        }
      }
    }
  }

  // Build the final query string
  final parts = <String>[];

  // Single-value params: key=value
  for (final entry in singleParams.entries) {
    parts.add('${entry.key}=${entry.value}');
  }

  // Multi-value params: key=value1,value2 (comma-separated)
  for (final entry in multiParams.entries) {
    parts.add('${entry.key}=${entry.value.join(',')}');
  }

  if (groupBooking) parts.add('group_booking=true');

  return parts.join('&');
}

// ─────────────────────────────────────────────────────────────────────────────
// Example outputs of the FIXED buildFilterQueryString:
//
//   Sort "Price: Low → High" only:
//     → sort_by=base_price&sort_order=ASC
//
//   Duration "7D+" only:
//     → min_duration_days=7
//
//   Offers "Special Offers" + "Early Bird":
//     → offer=special,early_bird           (was: offer=special&offer=early_bird ❌)
//
//   Solo "Female Solo" only:
//     → solo=true&gender=female
//
//   Rating "4.5+ Stars" only:
//     → min_rating=4.5
//
//   Everything combined (Sort=Top Rated, Duration=3D/2N, Policy=Flexible,
//   Offers=Special+Early Bird, Solo=Female Solo, Rating=4.5+, Group=true):
//     → sort_by=rating&sort_order=DESC&duration_days=3&policy=flexible
//       &offer=special,early_bird&solo=true&gender=female&min_rating=4.5
//       &group_booking=true
// ─────────────────────────────────────────────────────────────────────────────

class FilterSheetResult {
  final List<String> selectedTitles;
  final bool groupBookingEnabled;

  const FilterSheetResult({
    required this.selectedTitles,
    required this.groupBookingEnabled,
  });
}

class CommonFilterBar extends StatefulWidget {
  final Function(List<String> selectedTitles) onFiltersChanged;
  final ValueChanged<bool>? onGroupBookingChanged;

  const CommonFilterBar({
    super.key,
    required this.onFiltersChanged,
    this.onGroupBookingChanged,
  });

  @override
  State<CommonFilterBar> createState() => CommonFilterBarState();
}

class CommonFilterBarState extends State<CommonFilterBar>
    with SingleTickerProviderStateMixin {
  static const double _barHeight = 48.0;

  List<String> _selected = [];
  bool _groupBookingEnabled = false;

  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  bool get _hasFilters => _selected.isNotEmpty || _groupBookingEnabled;
  int get _count => _selected.length + (_groupBookingEnabled ? 1 : 0);

  late final List<FilterOptionModel> _quickSortOptions;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _pulse = Tween<double>(
      begin: 0.88,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    final sortCat = _appFilterCategories.firstWhere(
      (c) => c.title == _sortCategoryTitle,
    );
    _quickSortOptions = sortCat.options;
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _syncPulse() {
    if (_hasFilters) {
      if (!_pulseCtrl.isAnimating) _pulseCtrl.repeat(reverse: true);
    } else {
      _pulseCtrl.stop();
      _pulseCtrl.reset();
    }
  }

  void _toggleQuickSort(FilterOptionModel opt) {
    HapticFeedback.lightImpact();
    List<String> next = List.from(_selected);

    final sortTitles = _quickSortOptions.map((o) => o.title).toSet();
    next.removeWhere((t) => sortTitles.contains(t));

    if (!_selected.contains(opt.title) && opt.title != 'Recommended') {
      next.add(opt.title);
    }

    setState(() => _selected = List.unmodifiable(next));
    _syncPulse();
    widget.onFiltersChanged(List.unmodifiable(next));
  }

  void updateFilters(List<String> newTitles) {
    if (!mounted) return;
    setState(() => _selected = List.unmodifiable(newTitles));
    _syncPulse();
    widget.onFiltersChanged(List.unmodifiable(newTitles));
  }

  void _clearAll() {
    HapticFeedback.mediumImpact();
    setState(() {
      _selected = [];
      _groupBookingEnabled = false;
    });
    _syncPulse();
    widget.onFiltersChanged([]);
    widget.onGroupBookingChanged?.call(false);
  }

  Future<void> _openSheet([String? openCategoryTitle]) async {
    HapticFeedback.selectionClick();

    final result = await showModalBottomSheet<FilterSheetResult>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      enableDrag: true,
      builder: (_) => _FilterSheetContent(
        initialSelections: List.from(_selected),
        initialCategory: openCategoryTitle ?? _appFilterCategories.first.title,
        initialGroupBooking: _groupBookingEnabled,
      ),
    );

    if (!mounted || result == null) return;

    setState(() {
      _selected = List.unmodifiable(result.selectedTitles);
      _groupBookingEnabled = result.groupBookingEnabled;
    });
    _syncPulse();
    widget.onFiltersChanged(List.unmodifiable(result.selectedTitles));
    widget.onGroupBookingChanged?.call(result.groupBookingEnabled);
  }

  void _removeFilter(String title) {
    HapticFeedback.lightImpact();
    final next = List<String>.from(_selected)..remove(title);
    setState(() => _selected = List.unmodifiable(next));
    _syncPulse();
    widget.onFiltersChanged(List.unmodifiable(next));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _barHeight,
      decoration: BoxDecoration(
        color: AroboTheme.cardBg,
        boxShadow: AroboTheme.softShadow(0.05),
        border: Border(
          bottom: BorderSide(color: AroboTheme.border, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              physics: const BouncingScrollPhysics(),
              itemCount:
                  _quickSortOptions.length +
                  _selected
                      .where((t) => !_quickSortOptions.any((o) => o.title == t))
                      .length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (_, index) {
                if (index < _quickSortOptions.length) {
                  final opt = _quickSortOptions[index];
                  final isSelected =
                      _selected.contains(opt.title) ||
                      (opt.title == 'Recommended' &&
                          !_selected.any(
                            (t) => _quickSortOptions.any((o) => o.title == t),
                          ));

                  return _QuickChip(
                    label: opt.title,
                    isSelected: isSelected,
                    onTap: () => _toggleQuickSort(opt),
                  );
                }

                final advancedFilters = _selected
                    .where((t) => !_quickSortOptions.any((o) => o.title == t))
                    .toList();
                final filterTitle =
                    advancedFilters[index - _quickSortOptions.length];

                return _ActiveChip(
                  label: filterTitle,
                  onRemove: () => _removeFilter(filterTitle),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10, left: 4),
            child: _FilterButton(
              count: _count,
              pulse: _hasFilters ? _pulse : null,
              onTap: () => _openSheet(),
              onClear: _hasFilters ? _clearAll : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _QuickChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AroboTheme.primary : AroboTheme.elevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AroboTheme.primary : AroboTheme.border,
            width: 0.8,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AroboTheme.label(
              size: 10.5,
              weight: FontWeight.w700,
              color: isSelected ? Colors.white : AroboTheme.ink400,
            ),
          ),
        ),
      ),
    );
  }
}

class _ActiveChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _ActiveChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 12, right: 4, top: 4, bottom: 4),
      decoration: BoxDecoration(
        color: AroboTheme.teal.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AroboTheme.teal.withOpacity(0.3), width: 0.8),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: AroboTheme.label(
              size: 10.5,
              weight: FontWeight.w700,
              color: AroboTheme.teal,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: AroboTheme.teal.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close_rounded,
                size: 10,
                color: AroboTheme.teal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterButton extends StatefulWidget {
  final int count;
  final Animation<double>? pulse;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _FilterButton({
    required this.count,
    required this.onTap,
    this.pulse,
    this.onClear,
  });

  @override
  State<_FilterButton> createState() => _FilterButtonState();
}

class _FilterButtonState extends State<_FilterButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final hasFilters = widget.count > 0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedSize(
          duration: AroboTheme.durFast,
          curve: AroboTheme.easeOut,
          child: widget.onClear != null
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: widget.onClear,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AroboTheme.elevated,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AroboTheme.border),
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: AroboTheme.ink400,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                )
              : const SizedBox.shrink(),
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedBuilder(
            animation: widget.pulse ?? kAlwaysCompleteAnimation,
            builder: (_, child) {
              final s = widget.pulse != null
                  ? 0.97 + 0.03 * widget.pulse!.value
                  : (_pressed ? 0.94 : 1.0);
              return Transform.scale(scale: s, child: child);
            },
            child: AnimatedContainer(
              duration: AroboTheme.durFast,
              curve: AroboTheme.easeOut,
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: hasFilters ? AroboTheme.primary : AroboTheme.cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: hasFilters ? AroboTheme.primary : AroboTheme.border,
                  width: 0.9,
                ),
                boxShadow: hasFilters
                    ? [
                        BoxShadow(
                          color: AroboTheme.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Center(
                    child: Icon(
                      Icons.tune_rounded,
                      size: 18,
                      color: hasFilters ? Colors.white : AroboTheme.ink400,
                    ),
                  ),
                  if (hasFilters)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: AroboTheme.danger,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: Center(
                          child: Text(
                            '${widget.count}',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 8,
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
        ),
      ],
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
        // FIX: Single-select — remove all other options in this category first
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
          color: AroboTheme.bg,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AroboTheme.radiusXl),
          ),
          border: Border.all(color: AroboTheme.border, width: 0.8),
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
            Container(height: 1, color: AroboTheme.border),
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
                    decoration: BoxDecoration(
                      color: AroboTheme.cardBg,
                      border: Border(
                        right: BorderSide(color: AroboTheme.border),
                      ),
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
            color: AroboTheme.ink600,
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
                AroboTheme.primary,
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

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 14, 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AroboTheme.primary,
              borderRadius: BorderRadius.circular(13),
              boxShadow: [
                BoxShadow(
                  color: AroboTheme.primary.withOpacity(0.2),
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
                    total > 0 ? 'Filters  ·  $total active' : 'Filter Treks',
                    key: ValueKey(total),
                    style: AroboTheme.label(
                      size: 16,
                      weight: FontWeight.w800,
                      color: AroboTheme.ink,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  total > 0
                      ? 'Tap a chip in the bar to remove'
                      : 'Narrow down your perfect trek',
                  style: AroboTheme.label(size: 10.5, color: AroboTheme.ink400),
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
          color: _pressed
              ? AroboTheme.primary.withOpacity(0.1)
              : AroboTheme.elevated,
          borderRadius: BorderRadius.circular(AroboTheme.radiusPill),
          border: Border.all(
            color: _pressed
                ? AroboTheme.primary.withOpacity(0.4)
                : AroboTheme.border,
          ),
          boxShadow: AroboTheme.softShadow(),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(widget.icon, size: 13, color: AroboTheme.primary),
            const SizedBox(width: 5),
            Text(
              widget.label,
              style: AroboTheme.label(
                size: 11,
                weight: FontWeight.w700,
                color: AroboTheme.primary,
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
          color: _pressed ? AroboTheme.surfaceCard : AroboTheme.elevated,
          shape: BoxShape.circle,
          border: Border.all(color: AroboTheme.border),
          boxShadow: AroboTheme.softShadow(),
        ),
        child: Icon(widget.icon, color: AroboTheme.ink400, size: 20),
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
          color: active
              ? AroboTheme.primary.withOpacity(0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active
                ? AroboTheme.primary.withOpacity(0.2)
                : Colors.transparent,
            width: 1.0,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                _SvgIcon(
                  path: cat.svgPath,
                  color: active ? AroboTheme.primary : AroboTheme.ink400,
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
                        color: active
                            ? AroboTheme.primary
                            : AroboTheme.iconBadge,
                        shape: BoxShape.circle,
                        border: Border.all(color: AroboTheme.cardBg, width: 1),
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
                color: active ? AroboTheme.primary : AroboTheme.ink400,
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
        color: value ? AroboTheme.primary.withOpacity(0.05) : AroboTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: value ? AroboTheme.primary : AroboTheme.border,
          width: 0.9,
        ),
        boxShadow: AroboTheme.softShadow(),
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: AroboTheme.durFast,
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: value ? AroboTheme.primary : AroboTheme.elevated,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: SvgPicture.asset(
                CommonImages.group,
                width: 18,
                height: 18,
                colorFilter: ColorFilter.mode(
                  value ? Colors.white : AroboTheme.ink400,
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
                    color: value ? AroboTheme.primary : AroboTheme.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Exclusive deals for 4+ members',
                  style: AroboTheme.label(size: 9.5, color: AroboTheme.ink400),
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
            activeTrackColor: AroboTheme.primary,
            inactiveTrackColor: AroboTheme.elevated,
            inactiveThumbColor: AroboTheme.ink400,
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
                  color: AroboTheme.ink400,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(child: Container(height: 1, color: AroboTheme.border)),
              if (multi) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AroboTheme.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(AroboTheme.radiusPill),
                    border: Border.all(
                      color: AroboTheme.primary.withOpacity(0.3),
                      width: 0.7,
                    ),
                  ),
                  child: Text(
                    'multi‑select',
                    style: AroboTheme.label(
                      size: 9,
                      color: AroboTheme.primary,
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
                ? AroboTheme.primary.withOpacity(0.06)
                : _pressed
                ? AroboTheme.surfaceCard
                : AroboTheme.cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: widget.isSelected ? AroboTheme.primary : AroboTheme.border,
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
                  color: widget.isSelected
                      ? AroboTheme.primary
                      : Colors.transparent,
                  border: Border.all(
                    color: widget.isSelected
                        ? AroboTheme.primary
                        : AroboTheme.ink600,
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
                    color: widget.isSelected
                        ? AroboTheme.primary
                        : AroboTheme.ink200,
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
        color: AroboTheme.cardBg,
        border: Border(top: BorderSide(color: AroboTheme.border)),
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
              gradient: hasFilters ? AroboTheme.primaryGradient : null,
              color: hasFilters ? null : AroboTheme.elevated,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: hasFilters ? AroboTheme.primary : AroboTheme.border,
                width: hasFilters ? 0 : 1,
              ),
              boxShadow: hasFilters
                  ? [
                      BoxShadow(
                        color: AroboTheme.primary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: hasFilters ? onApply : null,
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
                          color: hasFilters ? Colors.white : AroboTheme.ink400,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          hasFilters
                              ? 'Apply  ·  $count selected'
                              : 'Select filters to apply',
                          style: AroboTheme.label(
                            size: 12,
                            weight: FontWeight.w800,
                            color: hasFilters
                                ? Colors.white
                                : AroboTheme.ink400,
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
