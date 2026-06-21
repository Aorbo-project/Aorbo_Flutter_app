import 'package:arobo_app/utils/common_images.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/filter_category_model.dart';

// ─────────────────────────────────────────────
//  DESIGN TOKENS  — matched to TravellerInformationScreen (_TI)
// ─────────────────────────────────────────────
class _T {
  // Brand / accent — teal from TravellerInformationScreen
  static const accent     = Color(0xFF0F7B6C); // _TI.teal
  static const accentDeep = Color(0xFF0A5C50);
  static const accentSoft = Color(0xFFE6F5F3); // _TI.tealSoft
  static const accentGlow = Color(0x330F7B6C);
  static const borderAccent = Color(0xFF4DB6A8);

  // Surfaces — off-white / white like the traveller screen
  static const bg             = Color(0xFFF7F8FA); // _TI.bg equivalent
  static const surface        = Color(0xFFFFFFFF);
  static const surfaceElevated= Color(0xFFF1F5F9);
  static const surfaceCard    = Color(0xFFE8F0EE);
  static const border         = Color(0xFFE2E8F0); // _TI.sheetBorder

  // Ink — dark slate, matching _TI.sheetInk family
  static const ink50  = Color(0xFF0F172A); // _TI.sheetInk
  static const ink200 = Color(0xFF334155);
  static const ink400 = Color(0xFF64748B); // _TI.sheetInkMid
  static const ink600 = Color(0xFFCBD5E1);

  // Icon badge — matches _TI.iconBadge
  static const iconBadge = Color(0xFF111827);

  // Status
  static const success     = Color(0xFF0F7B6C);
  static const successSoft = Color(0xFFE6F5F3);

  // Shadows
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ];

  static List<BoxShadow> accentGlowShadow(double opacity) => [
        BoxShadow(
          color: accent.withValues(alpha: opacity),
          blurRadius: 16,
          spreadRadius: -2,
          offset: const Offset(0, 4),
        ),
      ];

  // Typography — Poppins, matching traveller screen
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

  static const durFast = Duration(milliseconds: 180);
  static const durMed  = Duration(milliseconds: 280);
  static const easeOut = Curves.easeOutCubic;
  static const spring  = Curves.easeOutBack;
}

// ─────────────────────────────────────────────
//  MULTI-SELECT CATEGORIES
// ─────────────────────────────────────────────
const _multiSelectCategories = {'Offers', 'Solo', 'Rating'};

bool _isMultiSelect(String categoryTitle) =>
    _multiSelectCategories.contains(categoryTitle);

// ─────────────────────────────────────────────
//  FILTER DATA
// ─────────────────────────────────────────────
final List<FilterCategory> _appFilterCategories = [
  FilterCategory(
    title: 'Sort',
    svgPath: CommonImages.sort,
    options: [
      FilterOptionModel(title: 'Relevance',         query: 'sort_by=relevance'),
      FilterOptionModel(title: 'Price: Low → High', query: 'sort_by=base_price&sort_order=ASC'),
      FilterOptionModel(title: 'Price: High → Low', query: 'sort_by=base_price&sort_order=DESC'),
      FilterOptionModel(title: 'Newest First',      query: 'sort_by=created_at&sort_order=DESC'),
      FilterOptionModel(title: 'Female‑Exclusive',  query: 'sort_by=female_exclusive'),
      FilterOptionModel(title: 'Top Rated',         query: 'sort_by=rating&sort_order=DESC'),
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
      FilterOptionModel(title: '7D+',     query: 'duration_days=7'),
    ],
  ),
  FilterCategory(
    title: 'Policy',
    svgPath: CommonImages.filter,
    options: [
      FilterOptionModel(title: 'Flexible', query: 'policy=flexible'),
      FilterOptionModel(title: 'Standard', query: 'policy=standard'),
      FilterOptionModel(title: 'Strict',   query: 'policy=strict'),
    ],
  ),
  FilterCategory(
    title: 'Offers',
    svgPath: CommonImages.discount,
    options: [
      FilterOptionModel(title: 'Special Offers', query: 'offer=special'),
      FilterOptionModel(title: 'Early Bird',      query: 'offer=early_bird'),
      FilterOptionModel(title: 'Last Minute',     query: 'offer=last_minute'),
      FilterOptionModel(title: 'Exclusive Deals', query: 'offer=exclusive'),
    ],
  ),
  FilterCategory(
    title: 'Solo',
    svgPath: CommonImages.solo,
    options: [
      FilterOptionModel(title: 'Solo Traveller', query: 'solo=true'),
      FilterOptionModel(title: 'Female Solo',    query: 'solo=true&gender=female'),
    ],
  ),
  FilterCategory(
    title: 'Rating',
    svgPath: CommonImages.stars,
    options: [
      FilterOptionModel(title: '4.5+ Stars', query: 'min_rating=4.5'),
      FilterOptionModel(title: '4+ Stars',   query: 'min_rating=4'),
      FilterOptionModel(title: '3.5+ Stars', query: 'min_rating=3.5'),
      FilterOptionModel(title: '3+ Stars',   query: 'min_rating=3'),
    ],
  ),
];

// ─────────────────────────────────────────────
//  QUERY BUILDER
//  Fix: for single-select categories, keep only the last-in-list
//  selected option (respects category definition order, not selection order).
// ─────────────────────────────────────────────
String buildFilterQueryString(
  List<String> selectedTitles, {
  bool groupBooking = false,
}) {
  final parts = <String>[];

  for (final cat in _appFilterCategories) {
    // Preserve category-definition order for stable query strings.
    final selectedOpts = cat.options
        .where((o) => selectedTitles.contains(o.title) && o.query.isNotEmpty)
        .toList();

    if (selectedOpts.isEmpty) continue;

    if (_isMultiSelect(cat.title)) {
      parts.addAll(selectedOpts.map((o) => o.query));
    } else {
      // Single-select: last option in the list wins (most recently added
      // will be last in selectedTitles but we keep the category order here;
      // use selectedTitles.lastIndexOf for selection-time ordering).
      final lastSelected = selectedOpts.reduce((a, b) =>
          selectedTitles.lastIndexOf(a.title) >
                  selectedTitles.lastIndexOf(b.title)
              ? a
              : b);
      parts.add(lastSelected.query);
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
  static const double _barHeight = 62.0;

  List<String> _selected          = [];
  bool         _groupBookingEnabled = false;

  // Pulse controller only active when filters are present.
  late AnimationController _pulseCtrl;
  late Animation<double>   _pulse;

  bool get _hasFilters => _selected.isNotEmpty || _groupBookingEnabled;
  int  get _count      => _selected.length + (_groupBookingEnabled ? 1 : 0);

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _pulse = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  // Keep pulse in sync with filter state.
  void _syncPulse() {
    if (_hasFilters) {
      if (!_pulseCtrl.isAnimating) _pulseCtrl.repeat(reverse: true);
    } else {
      _pulseCtrl.stop();
      _pulseCtrl.reset();
    }
  }

  // ── Public API ────────────────────────────────────────────────────────────

  /// Called externally to push new selections in (e.g. from a parent that
  /// restores saved filters).
  void updateFilters(List<String> newTitles) {
    if (!mounted) return;
    setState(() => _selected = List.unmodifiable(newTitles));
    _syncPulse();
    widget.onFiltersChanged(List.unmodifiable(newTitles));
  }

  void _clearAll() {
    HapticFeedback.mediumImpact();
    setState(() {
      _selected              = [];
      _groupBookingEnabled   = false;
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
        initialCategory:
            openCategoryTitle ?? _appFilterCategories.first.title,
        initialGroupBooking: _groupBookingEnabled,
      ),
    );

    if (!mounted || result == null) return;

    setState(() {
      _selected            = List.unmodifiable(result.selectedTitles);
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

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: _T.durFast,
      height: _barHeight,
      decoration: BoxDecoration(
        color: _T.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border(
          bottom: BorderSide(color: _T.border),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: AnimatedSwitcher(
                duration: _T.durFast,
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(-0.04, 0),
                      end: Offset.zero,
                    ).animate(anim),
                    child: child,
                  ),
                ),
                child: _hasFilters
                    ? _ActiveChipRow(
                        key: const ValueKey('active'),
                        selected: _selected,
                        groupBooking: _groupBookingEnabled,
                        onChipTap: (cat) => _openSheet(cat),
                        onChipRemove: _removeFilter,
                      )
                    : _EmptyFilterHint(
                        key: const ValueKey('hint'),
                        onTap: _openSheet,
                      ),
              ),
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
  const _EmptyFilterHint({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Row(
        children: [
          Icon(Icons.tune_rounded, size: 16, color: _T.ink400),
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
    super.key,
    required this.selected,
    required this.groupBooking,
    required this.onChipTap,
    required this.onChipRemove,
  });

  /// Returns the parent category title for a given option title, or null.
  String? _categoryForTitle(String title) {
    for (final cat in _appFilterCategories) {
      if (cat.options.any((o) => o.title == title)) return cat.title;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // Each entry: (displayTitle, isGroupChip)
    final chips = [
      ...selected.map((t) => (t, false)),
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
          isGroup: isGroup,
          onTap: isGroup
              ? null
              : () {
                  final cat = _categoryForTitle(title);
                  if (cat != null) onChipTap(cat);
                },
          onRemove: isGroup ? null : () => onChipRemove(title),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
//  ACTIVE CHIP
// ─────────────────────────────────────────────
class _ActiveChip extends StatefulWidget {
  final String label;
  final bool isGroup;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  const _ActiveChip({
    required this.label,
    required this.isGroup,
    this.onTap,
    this.onRemove,
  });

  @override
  State<_ActiveChip> createState() => _ActiveChipState();
}

class _ActiveChipState extends State<_ActiveChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _entry;
  late Animation<double>   _scale;

  @override
  void initState() {
    super.initState();
    _entry = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scale = CurvedAnimation(parent: _entry, curve: _T.spring);
    _entry.forward();
  }

  @override
  void dispose() {
    _entry.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: EdgeInsets.only(
            left: 10,
            right: widget.onRemove != null ? 4 : 10,
            top: 5,
            bottom: 5,
          ),
          decoration: BoxDecoration(
            color: widget.isGroup ? _T.surfaceElevated : _T.accentSoft,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: widget.isGroup ? _T.border : _T.borderAccent,
              width: 0.9,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.isGroup)
                Padding(
                  padding: const EdgeInsets.only(right: 5),
                  child: Icon(Icons.groups_rounded,
                      size: 12, color: _T.ink400),
                ),
              Text(
                widget.label,
                style: _T.label(
                  size: 10.5,
                  weight: FontWeight.w600,
                  color: widget.isGroup ? _T.ink400 : _T.accent,
                ),
              ),
              if (widget.onRemove != null) ...[
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: widget.onRemove,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: _T.accent.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close_rounded,
                        size: 10, color: _T.accent),
                  ),
                ),
              ],
            ],
          ),
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
        // Clear button — animates in/out
        AnimatedSize(
          duration: _T.durFast,
          curve: _T.easeOut,
          child: widget.onClear != null
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                        child: Icon(Icons.close_rounded,
                            size: 15, color: _T.ink400),
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                )
              : const SizedBox.shrink(),
        ),

        // Main filter button
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
              duration: _T.durFast,
              curve: _T.easeOut,
              width: 44,
              height: 44,
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
                  width: 0.9,
                ),
                boxShadow: hasFilters
                    ? _T.accentGlowShadow(0.28)
                    : _T.cardShadow,
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
                      top: -4,
                      right: -4,
                      child: AnimatedContainer(
                        duration: _T.durFast,
                        width: 17,
                        height: 17,
                        decoration: BoxDecoration(
                          color: _T.iconBadge,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: _T.surface, width: 1.5),
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
  final String       initialCategory;
  final bool         initialGroupBooking;

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
  late List<String>  _draft;
  late String        _activeCategory;
  late bool          _groupBooking;
  late AnimationController _fadeCtrl;
  late Animation<double>   _fade;

  FilterCategory get _currentCategory => _appFilterCategories.firstWhere(
        (c) => c.title == _activeCategory,
        orElse: () => _appFilterCategories.first,
      );

  @override
  void initState() {
    super.initState();
    _draft        = List.from(widget.initialSelections);
    _groupBooking = widget.initialGroupBooking;

    final exists =
        _appFilterCategories.any((c) => c.title == widget.initialCategory);
    _activeCategory =
        exists ? widget.initialCategory : _appFilterCategories.first.title;

    _fadeCtrl =
        AnimationController(vsync: this, duration: _T.durFast)..forward();
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
      final cat     = _currentCategory;
      final already = _draft.contains(opt.title);

      if (_isMultiSelect(cat.title)) {
        // Multi-select: toggle freely.
        already ? _draft.remove(opt.title) : _draft.add(opt.title);
      } else {
        // Single-select: remove any option belonging to THIS category only,
        // then add the new one (unless it was already selected → deselect).
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
    final total  = _draft.length + (_groupBooking ? 1 : 0);

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: sheetH,
        decoration: BoxDecoration(
          color: _T.bg,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: _T.border, width: 0.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.13),
              blurRadius: 32,
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
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Left: vertical category rail ──────────────────
                  Container(
                    width: 92,
                    decoration: BoxDecoration(
                      color: _T.surface,
                      border: Border(
                          right: BorderSide(color: _T.border)),
                    ),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      physics: const BouncingScrollPhysics(),
                      itemCount: _appFilterCategories.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 4),
                      itemBuilder: (_, i) {
                        final cat    = _appFilterCategories[i];
                        final active = _activeCategory == cat.title;
                        final count  = _categoryCount(cat);
                        return _VerticalCategoryTab(
                          cat: cat,
                          active: active,
                          count: count > 0 ? count : null,
                          onTap: () => _switchCategory(cat.title),
                        );
                      },
                    ),
                  ),

                  // ── Right: option grid ────────────────────────────
                  Expanded(
                    child: FadeTransition(
                      opacity: _fade,
                      child: AnimatedSwitcher(
                        duration: _T.durFast,
                        transitionBuilder: (child, anim) =>
                            FadeTransition(
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
          width: 38,
          height: 4,
          decoration: BoxDecoration(
            color: _T.ink600,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(height: 12),
        // Teal gradient rule — matches the brand colour
        Container(
          height: 2,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                _T.accent,
                Colors.transparent,
              ],
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
      padding: const EdgeInsets.fromLTRB(18, 10, 14, 12),
      child: Row(
        children: [
          // Icon badge — matches _sectionHeader style in traveller screen
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _T.iconBadge,
              borderRadius: BorderRadius.circular(13),
              boxShadow: _T.accentGlowShadow(0.14),
            ),
            child: const Icon(Icons.tune_rounded,
                size: 22, color: Colors.white),
          ),
          const SizedBox(width: 13),

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
                        size: 16,
                        weight: FontWeight.w700,
                        color: _T.ink50),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  total > 0
                      ? 'Tap a chip in the bar to remove'
                      : 'Narrow down your perfect trek',
                  style: _T.label(size: 10.5, color: _T.ink400),
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
        padding:
            const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(
          color: _pressed ? _T.accentSoft : _T.surfaceElevated,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
              color: _pressed ? _T.borderAccent : _T.border),
          boxShadow: _T.cardShadow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(widget.icon, size: 13, color: _T.accent),
            const SizedBox(width: 5),
            Text(widget.label,
                style: _T.label(
                    size: 11,
                    weight: FontWeight.w600,
                    color: _T.accent)),
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
//  VERTICAL CATEGORY TAB
// ─────────────────────────────────────────────
class _VerticalCategoryTab extends StatelessWidget {
  final FilterCategory cat;
  final bool    active;
  final int?    count;
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
        margin: const EdgeInsets.symmetric(horizontal: 7),
        padding:
            const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
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
                        color: active ? _T.accent : _T.iconBadge,
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: _T.surface, width: 1),
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
      margin: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      padding:
          const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: value ? _T.accentSoft : _T.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: value ? _T.accent : _T.border,
          width: 0.9,
        ),
        boxShadow: value ? _T.accentGlowShadow(0.10) : _T.cardShadow,
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: _T.durFast,
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
            activeThumbColor: Colors.white,
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
  final FilterCategory           category;
  final List<String>             selected;
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
          // Section heading row
          Row(
            children: [
              Text(
                category.title.toUpperCase(),
                style: _T.label(
                  size: 9.5,
                  weight: FontWeight.w700,
                  color: _T.ink400,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                  child: Container(height: 1, color: _T.border)),
              if (multi) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _T.accentSoft,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                        color: _T.borderAccent, width: 0.7),
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
          duration: _T.durFast,
          curve: _T.easeOut,
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? _T.accentSoft
                : _pressed
                    ? _T.surfaceCard
                    : _T.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: widget.isSelected ? _T.accent : _T.border,
              width: widget.isSelected ? 1.2 : 0.8,
            ),
            boxShadow: widget.isSelected
                ? _T.accentGlowShadow(0.12)
                : _T.cardShadow,
          ),
          child: Row(
            children: [
              // Checkbox circle
              AnimatedContainer(
                duration: _T.durFast,
                curve: _T.spring,
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.isSelected
                      ? _T.accent
                      : Colors.transparent,
                  border: Border.all(
                    color: widget.isSelected
                        ? _T.accent
                        : _T.ink600,
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

  const _SheetFooter({required this.count, required this.onApply});

  @override
  Widget build(BuildContext context) {
    final hasFilters = count > 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      decoration: BoxDecoration(
        color: _T.surface,
        border: Border(top: BorderSide(color: _T.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
          // Wrap in AnimatedContainer so inactive state looks visually
          // distinct — dark muted card, no glow.
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
              color: hasFilters ? null : _T.surfaceElevated,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: hasFilters ? _T.accent : _T.border,
                width: hasFilters ? 0 : 1,
              ),
              boxShadow:
                  hasFilters ? _T.accentGlowShadow(0.28) : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                // Only tappable when filters are selected.
                onTap: hasFilters ? onApply : null,
                borderRadius: BorderRadius.circular(16),
                splashColor: Colors.white.withValues(alpha: 0.15),
                highlightColor: Colors.transparent,
                child: Center(
                  child: AnimatedSwitcher(
                    duration: _T.durFast,
                    child: Row(
                      key: ValueKey(hasFilters),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          hasFilters
                              ? Icons.check_circle_outline_rounded
                              : Icons.filter_list_rounded,
                          size: 16,
                          color:
                              hasFilters ? Colors.white : _T.ink400,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          hasFilters
                              ? 'Apply  ·  $count selected'
                              : 'Select filters to apply',
                          style: _T.label(
                            size: 12,
                            weight: FontWeight.w700,
                            color: hasFilters
                                ? Colors.white
                                : _T.ink400,
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

// ─────────────────────────────────────────────
//  SVG ICON HELPER
// ─────────────────────────────────────────────
class _SvgIcon extends StatelessWidget {
  final String path;
  final Color  color;
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
          color: color.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
