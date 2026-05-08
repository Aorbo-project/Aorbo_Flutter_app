import 'package:arobo_app/utils/common_images.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/filter_category_model.dart';

// ─────────────────────────────────────────────
//  DESIGN TOKENS  (Light Theme)
// ─────────────────────────────────────────────
class _T {
  static const accent = Color(0xFF6C5CE7);
  static const accentDeep = Color(0xFF4834D4);
  static const accentSoft = Color(0x1A6C5CE7);
  static const accentGlow = Color(0x336C5CE7);
  static const borderAccent = Color(0xFF9B8FF5);

  static const bg = Color(0xFFF5F5FA);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceElevated = Color(0xFFF0F0F8);
  static const surfaceCard = Color(0xFFE8E8F5);
  static const border = Color(0xFFDDDDEE);

  static const ink50 = Color(0xFF1A1A2E);
  static const ink200 = Color(0xFF4A4A6A);
  static const ink400 = Color(0xFF8888AA);
  static const ink600 = Color(0xFFCCCCDD);

  static const success = Color(0xFF00B894);
  static const successSoft = Color(0x1A00B894);

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.07),
          blurRadius: 12,
          offset: const Offset(0, 3),
        ),
      ];

  static List<BoxShadow> accentGlowShadow(double opacity) => [
        BoxShadow(
          color: accent.withOpacity(opacity),
          blurRadius: 16,
          spreadRadius: -2,
          offset: const Offset(0, 4),
        ),
      ];

  static TextStyle label({
    double size = 13,
    FontWeight weight = FontWeight.w500,
    Color color = ink50,
    double letterSpacing = 0,
    double height = 1.3,
  }) =>
      TextStyle(
        fontFamily: 'Poppins',
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
      );

  static const durFast = Duration(milliseconds: 160);
  static const durMed = Duration(milliseconds: 260);
  static const easeOut = Curves.easeOutCubic;
  static const spring = Curves.easeOutBack;
}

// ─────────────────────────────────────────────
//  DATA
// ─────────────────────────────────────────────
const _multiSelectCategories = {'Offers', 'Solo', 'Rating'};

bool _isMultiSelect(String categoryTitle) =>
    _multiSelectCategories.contains(categoryTitle);

final List<FilterCategory> _appFilterCategories = [
  FilterCategory(
    title: 'Sort',
    svgPath: CommonImages.sort,
    options: [
      FilterOptionModel(title: 'Relevance', query: 'sort_by=relevance'),
      FilterOptionModel(
          title: 'Price: Low → High',
          query: 'sort_by=base_price&sort_order=ASC'),
      FilterOptionModel(
          title: 'Price: High → Low',
          query: 'sort_by=base_price&sort_order=DESC'),
      FilterOptionModel(
          title: 'Newest First',
          query: 'sort_by=created_at&sort_order=DESC'),
      FilterOptionModel(
          title: 'Female‑Exclusive', query: 'sort_by=female_exclusive'),
      FilterOptionModel(
          title: 'Top Rated', query: 'sort_by=rating&sort_order=DESC'),
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
      FilterOptionModel(title: '7D+', query: 'duration_days=7'),
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
      FilterOptionModel(
          title: 'Female Solo', query: 'solo=true&gender=female'),
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

// ─────────────────────────────────────────────
//  QUERY BUILDER
// ─────────────────────────────────────────────
String buildFilterQueryString(
  List<String> selectedTitles, {
  bool groupBooking = false,
}) {
  final parts = <String>[];

  for (final cat in _appFilterCategories) {
    final selectedOpts = cat.options
        .where((o) => selectedTitles.contains(o.title) && o.query.isNotEmpty)
        .toList();

    if (selectedOpts.isEmpty) continue;

    if (_isMultiSelect(cat.title)) {
      parts.addAll(selectedOpts.map((o) => o.query));
    } else {
      parts.add(selectedOpts.last.query);
    }
  }

  if (groupBooking) parts.add('group_booking=true');

  return parts.join('&');
}

// ─────────────────────────────────────────────
//  RESULT MODEL
// ─────────────────────────────────────────────
class FilterSheetResult {
  final List<String> selectedTitles;
  final bool groupBookingEnabled;

  const FilterSheetResult({
    required this.selectedTitles,
    required this.groupBookingEnabled,
  });
}

// ─────────────────────────────────────────────
//  PUBLIC FILTER BAR
// ─────────────────────────────────────────────
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
  static const double _barHeight = 60.0;

  List<String> _selected = [];
  bool _groupBookingEnabled = false;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  bool get _hasFilters => _selected.isNotEmpty || _groupBookingEnabled;
  int get _count => _selected.length + (_groupBookingEnabled ? 1 : 0);

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  void updateFilters(List<String> newTitles) {
    if (!mounted) return;
    setState(() => _selected = List.unmodifiable(newTitles));
    widget.onFiltersChanged(List.unmodifiable(newTitles));
  }

  void _clearAll() {
    HapticFeedback.mediumImpact();
    setState(() {
      _selected = [];
      _groupBookingEnabled = false;
    });
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
        initialCategory:
            openCategoryTitle ?? _appFilterCategories.first.title,
        initialGroupBooking: _groupBookingEnabled,
      ),
    );

    if (!mounted || result == null) return;

    setState(() {
      _selected = List.unmodifiable(result.selectedTitles);
      _groupBookingEnabled = result.groupBookingEnabled;
    });
    widget.onFiltersChanged(List.unmodifiable(result.selectedTitles));
    widget.onGroupBookingChanged?.call(result.groupBookingEnabled);
  }

  void _removeFilter(String title) {
    HapticFeedback.lightImpact();
    final next = List<String>.from(_selected)..remove(title);
    setState(() => _selected = List.unmodifiable(next));
    widget.onFiltersChanged(List.unmodifiable(next));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _barHeight,
      decoration: BoxDecoration(
        color: _T.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border(
          bottom: BorderSide(color: _T.border, width: 1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        child: Row(
          children: [
            Expanded(
              child: _hasFilters
                  ? _ActiveChipRow(
                      selected: _selected,
                      groupBooking: _groupBookingEnabled,
                      onChipTap: (cat) => _openSheet(cat),
                      onChipRemove: _removeFilter,
                    )
                  : _EmptyFilterHint(onTap: _openSheet),
            ),
            const SizedBox(width: 10),
            _FilterButton(
              count: _count,
              pulse: _hasFilters ? _pulse : null,
              onTap: () => _openSheet(),
              onClear: _hasFilters ? _clearAll : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  EMPTY STATE HINT
// ─────────────────────────────────────────────
class _EmptyFilterHint extends StatelessWidget {
  final VoidCallback onTap;
  const _EmptyFilterHint({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Row(
        children: [
          Icon(Icons.search_rounded, size: 16, color: _T.ink400),
          const SizedBox(width: 8),
          Text(
            'Filter & sort treks…',
            style: _T.label(size: 12, color: _T.ink400),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  ACTIVE CHIP ROW
// ─────────────────────────────────────────────
class _ActiveChipRow extends StatelessWidget {
  final List<String> selected;
  final bool groupBooking;
  final void Function(String categoryTitle) onChipTap;
  final void Function(String title) onChipRemove;

  const _ActiveChipRow({
    required this.selected,
    required this.groupBooking,
    required this.onChipTap,
    required this.onChipRemove,
  });

  String? _categoryForTitle(String title) {
    for (final cat in _appFilterCategories) {
      if (cat.options.any((o) => o.title == title)) return cat.title;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final chips = [
      ...selected.map((t) => (t, false)),
      // groupBooking chip — isGroup = true means no remove icon
      if (groupBooking) ('Group Booking', true),
    ];

    return ListView.separated(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      itemCount: chips.length,
      separatorBuilder: (_, __) => const SizedBox(width: 6),
      itemBuilder: (_, i) {
        final (title, isGroup) = chips[i];
        return _ActiveChip(
          label: title,
          onTap: isGroup
              ? null
              : () {
                  final cat = _categoryForTitle(title);
                  if (cat != null) onChipTap(cat);
                },
          // ← no onRemove for group booking chip
          onRemove: isGroup ? null : () => onChipRemove(title),
        );
      },
    );
  }
}

class _ActiveChip extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  const _ActiveChip({required this.label, this.onTap, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(left: 10, right: 4, top: 5, bottom: 5),
        decoration: BoxDecoration(
          color: _T.accentSoft,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: _T.borderAccent, width: 0.8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: _T.label(
                  size: 10.5, weight: FontWeight.w600, color: _T.accent),
            ),
            if (onRemove != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onRemove,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: _T.accent.withOpacity(0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close_rounded, size: 10, color: _T.accent),
                ),
              ),
            ] else
              // small right padding when no remove icon, so chip doesn't look cramped
              const SizedBox(width: 6),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  FILTER BUTTON
// ─────────────────────────────────────────────
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
        if (widget.onClear != null) ...[
          GestureDetector(
            onTap: widget.onClear,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: _T.surfaceElevated,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _T.border),
                boxShadow: _T.cardShadow,
              ),
              child: Icon(Icons.close_rounded, size: 15, color: _T.ink400),
            ),
          ),
          const SizedBox(width: 6),
        ],
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedBuilder(
            animation: widget.pulse ?? kAlwaysCompleteAnimation,
            builder: (_, child) {
              final scale = widget.pulse != null
                  ? 0.97 + 0.03 * widget.pulse!.value
                  : 1.0;
              return Transform.scale(scale: scale, child: child);
            },
            child: AnimatedContainer(
              duration: _T.durFast,
              curve: _T.easeOut,
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: hasFilters
                    ? const LinearGradient(
                        colors: [_T.accent, _T.accentDeep],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: hasFilters ? null : _T.surfaceElevated,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: hasFilters ? _T.accent : _T.border,
                  width: 0.8,
                ),
                boxShadow:
                    hasFilters ? _T.accentGlowShadow(0.25) : _T.cardShadow,
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Center(
                    child: Icon(
                      Icons.tune_rounded,
                      size: 20,
                      color: hasFilters ? Colors.white : _T.ink400,
                    ),
                  ),
                  if (hasFilters)
                    Positioned(
                      top: -3,
                      right: -3,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: _T.success,
                          shape: BoxShape.circle,
                          border: Border.all(color: _T.surface, width: 1.5),
                        ),
                        child: Center(
                          child: Text(
                            '${widget.count}',
                            style: _T.label(
                              size: 8,
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
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  BOTTOM SHEET CONTENT
// ─────────────────────────────────────────────
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

    final exists =
        _appFilterCategories.any((c) => c.title == widget.initialCategory);
    _activeCategory =
        exists ? widget.initialCategory : _appFilterCategories.first.title;

    _fadeCtrl = AnimationController(vsync: this, duration: _T.durFast)
      ..forward();
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: _T.easeOut);
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
        _draft.removeWhere((t) => cat.options.any((o) => o.title == t));
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
    Navigator.of(context).pop(FilterSheetResult(
      selectedTitles: List<String>.from(_draft),
      groupBookingEnabled: _groupBooking,
    ));
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
          color: _T.bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
          border: Border.all(color: _T.border, width: 0.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 30,
              offset: const Offset(0, -6),
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

            Container(height: 1, color: _T.border),

            _GroupBookingCard(
              value: _groupBooking,
              onChanged: (v) => setState(() => _groupBooking = v),
            ),

            // ── Main body: vertical tab rail (left) + option grid (right) ──
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── LEFT: vertical category rail ──────────────────────
                  Container(
                    width: 90,
                    decoration: BoxDecoration(
                      color: _T.surface,
                      border: Border(
                        right: BorderSide(color: _T.border, width: 1),
                      ),
                    ),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      physics: const BouncingScrollPhysics(),
                      itemCount: _appFilterCategories.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 6),
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

                  // ── RIGHT: options grid ───────────────────────────────
                  Expanded(
                    child: FadeTransition(
                      opacity: _fade,
                      child: AnimatedSwitcher(
                        duration: _T.durFast,
                        transitionBuilder: (child, anim) => FadeTransition(
                          opacity: anim,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.04, 0),
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

            _SheetFooter(
              count: total,
              onApply: _apply,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  SHEET TOP ACCENT
// ─────────────────────────────────────────────
class _SheetTopAccent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: _T.border,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 2,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.transparent, _T.accent, Colors.transparent],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  SHEET HEADER
// ─────────────────────────────────────────────
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
      padding: const EdgeInsets.fromLTRB(20, 10, 16, 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_T.accent, _T.accentDeep],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: _T.accentGlowShadow(0.20),
            ),
            child: const Icon(Icons.tune_rounded,
                size: 22, color: Colors.white),
          ),
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedSwitcher(
                  duration: _T.durFast,
                  child: Text(
                    total > 0 ? 'Filters  ·  $total active' : 'Filter Treks',
                    key: ValueKey(total),
                    style: _T.label(
                        size: 17,
                        weight: FontWeight.w700,
                        color: _T.ink50),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  total > 0
                      ? 'Tap a chip to remove'
                      : 'Narrow down your perfect trek',
                  style: _T.label(size: 11, color: _T.ink400),
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

// ─────────────────────────────────────────────
//  GHOST PILL BUTTON
// ─────────────────────────────────────────────
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
        duration: _T.durFast,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _pressed ? _T.accentSoft : _T.surfaceElevated,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: _T.border),
          boxShadow: _T.cardShadow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(widget.icon, size: 14, color: _T.accent),
            const SizedBox(width: 5),
            Text(widget.label,
                style: _T.label(
                    size: 11, weight: FontWeight.w600, color: _T.accent)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  ROUND ICON BUTTON
// ─────────────────────────────────────────────
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
        duration: _T.durFast,
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _pressed ? _T.surfaceCard : _T.surfaceElevated,
          shape: BoxShape.circle,
          border: Border.all(color: _T.border),
          boxShadow: _T.cardShadow,
        ),
        child: Icon(widget.icon, color: _T.ink400, size: 20),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  VERTICAL CATEGORY TAB  (replaces horizontal _CategoryTab inside sheet)
// ─────────────────────────────────────────────
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
        duration: _T.durFast,
        curve: _T.easeOut,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: active ? _T.accentSoft : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active ? _T.accent : Colors.transparent,
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
                  color: active ? _T.accent : _T.ink400,
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
                        color: _T.accent,
                        shape: BoxShape.circle,
                        border: Border.all(color: _T.surface, width: 1),
                      ),
                      child: Center(
                        child: Text(
                          '$count',
                          style: _T.label(
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
              style: _T.label(
                size: 9.5,
                weight: active ? FontWeight.w700 : FontWeight.w500,
                color: active ? _T.accent : _T.ink400,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  GROUP BOOKING CARD
// ─────────────────────────────────────────────
class _GroupBookingCard extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _GroupBookingCard({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: _T.durFast,
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: value ? _T.accentSoft : _T.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: value ? _T.accent : _T.border,
          width: 0.9,
        ),
        boxShadow: value ? _T.accentGlowShadow(0.10) : _T.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: value ? _T.accent : _T.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: SvgPicture.asset(
                CommonImages.group,
                width: 18,
                height: 18,
                colorFilter: ColorFilter.mode(
                  value ? Colors.white : _T.ink400,
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
                  style: _T.label(
                      size: 12,
                      weight: FontWeight.w700,
                      color: value ? _T.accent : _T.ink50),
                ),
                const SizedBox(height: 2),
                Text(
                  'Exclusive deals for 4+ members',
                  style: _T.label(size: 9.5, color: _T.ink400),
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
            activeColor: Colors.white,
            activeTrackColor: _T.accent,
            inactiveTrackColor: _T.surfaceElevated,
            inactiveThumbColor: _T.ink400,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  OPTION GRID
// ─────────────────────────────────────────────
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
                style: _T.label(
                  size: 10,
                  weight: FontWeight.w700,
                  color: _T.ink400,
                  letterSpacing: 1.6,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(child: Container(height: 1, color: _T.border)),
              if (multi) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _T.accentSoft,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: _T.borderAccent, width: 0.7),
                  ),
                  child: Text(
                    'multi‑select',
                    style: _T.label(
                        size: 9,
                        color: _T.accent,
                        weight: FontWeight.w600),
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
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisExtent: 60,
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

// ─────────────────────────────────────────────
//  OPTION CARD
// ─────────────────────────────────────────────
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
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = _scaleCtrl;
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
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: _T.durFast,
          curve: _T.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? _T.accentSoft
                : _pressed
                    ? _T.surfaceCard
                    : _T.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isSelected ? _T.accent : _T.border,
              width: widget.isSelected ? 1.0 : 0.8,
            ),
            boxShadow: widget.isSelected
                ? _T.accentGlowShadow(0.10)
                : _T.cardShadow,
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: _T.durFast,
                curve: _T.spring,
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      widget.isSelected ? _T.accent : Colors.transparent,
                  border: Border.all(
                    color: widget.isSelected ? _T.accent : _T.ink600,
                    width: widget.isSelected ? 0 : 1.5,
                  ),
                ),
                child: widget.isSelected
                    ? const Icon(Icons.check_rounded,
                        size: 12, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.option.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: _T.label(
                    size: 10.5,
                    weight: widget.isSelected
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: widget.isSelected ? _T.accent : _T.ink200,
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

// ─────────────────────────────────────────────
//  SHEET FOOTER
// ─────────────────────────────────────────────
class _SheetFooter extends StatelessWidget {
  final int count;
  final VoidCallback onApply;

  const _SheetFooter({
    required this.count,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    final hasFilters = count > 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      decoration: BoxDecoration(
        color: _T.surface,
        border: Border(top: BorderSide(color: _T.border, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 4),
        child: SizedBox(
          height: 50,
          width: double.infinity,
          child: AnimatedContainer(
            duration: _T.durFast,
            decoration: BoxDecoration(
              gradient: hasFilters
                  ? const LinearGradient(
                      colors: [_T.accent, _T.accentDeep],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: hasFilters ? null : _T.surfaceCard,
              borderRadius: BorderRadius.circular(16),
              boxShadow: hasFilters ? _T.accentGlowShadow(0.25) : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: hasFilters ? onApply : null,
                borderRadius: BorderRadius.circular(16),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        size: 16,
                        color: hasFilters ? Colors.white : _T.ink400,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        hasFilters
                            ? 'Apply  ·  $count selected'
                            : 'Select filters to apply',
                        style: _T.label(
                          size: 12,
                          weight: FontWeight.w700,
                          color: hasFilters ? Colors.white : _T.ink400,
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
    );
  }
}

// ─────────────────────────────────────────────
//  SVG ICON HELPER
// ─────────────────────────────────────────────
class _SvgIcon extends StatelessWidget {
  final String path;
  final Color color;
  final double size;

  const _SvgIcon({
    required this.path,
    required this.color,
    required this.size,
  });

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
          color: color.withOpacity(0.5),
        ),
      ),
    );
  }
}
