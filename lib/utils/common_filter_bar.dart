import 'package:arobo_app/utils/common_images.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sizer/sizer.dart';

import '../models/filter_category_model.dart';

class _T {
  static const primary = Color(0xFF4F46E5);
  static const primaryHover = Color(0xFF4338CA);
  static const primarySoft = Color(0xFFC7D2FE);
  static const primaryMuted = Color(0xFFEEF2FF);

  static const ink900 = Color(0xFF0F172A);
  static const ink700 = Color(0xFF334155);
  static const ink500 = Color(0xFF64748B);
  static const ink400 = Color(0xFF94A3B8);
  static const ink300 = Color(0xFFCBD5E1);
  static const ink200 = Color(0xFFE2E8F0);
  static const ink100 = Color(0xFFF1F5F9);
  static const ink050 = Color(0xFFF8FAFC);

  static const surface = Color(0xFFFFFFFF);

  static BoxShadow get shadowXs => BoxShadow(
        color: const Color(0xFF0F172A).withOpacity(0.03),
        blurRadius: 2,
        offset: const Offset(0, 1),
      );

  static BoxShadow get shadowSm => BoxShadow(
        color: const Color(0xFF0F172A).withOpacity(0.05),
        blurRadius: 8,
        offset: const Offset(0, 3),
      );

  static BoxShadow shadowPrimary(double opacity) => BoxShadow(
        color: _T.primary.withOpacity(opacity),
        blurRadius: 16,
        offset: const Offset(0, 6),
      );

  static const easeOut = Curves.easeOutCubic;
  static const spring = Curves.easeOutBack;
  static const durFast = Duration(milliseconds: 150);
  static const durMed = Duration(milliseconds: 250);
}

const _multiSelectCategories = {'Offers'};

bool _isMultiSelect(String categoryTitle) =>
    _multiSelectCategories.contains(categoryTitle);

final List<FilterCategory> _appFilterCategories = [
  FilterCategory(
    title: 'Sort',
    svgPath: CommonImages.sort,
    options: [
      FilterOptionModel(title: 'Relevance', query: ''),
      FilterOptionModel(
        title: 'Price: Low to High',
        query: 'sort_by=base_price&sort_order=ASC',
      ),
      FilterOptionModel(
        title: 'Price: High to Low',
        query: 'sort_by=base_price&sort_order=DESC',
      ),
      FilterOptionModel(title: 'Newest on Top', query: ''),
      FilterOptionModel(title: 'Female-Exclusive', query: ''),
      FilterOptionModel(title: 'High Rated Treks', query: ''),
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
      FilterOptionModel(title: '7D+', query: ''),
    ],
  ),
  FilterCategory(
    title: 'Policy',
    svgPath: CommonImages.filter,
    options: [
      FilterOptionModel(title: 'Flexible', query: 'policy=flexible'),
      FilterOptionModel(title: 'Standard', query: 'policy=standard'),
    ],
  ),
  FilterCategory(
    title: 'Offers',
    svgPath: CommonImages.discount,
    options: [
      FilterOptionModel(title: 'Special Offers', query: ''),
      FilterOptionModel(title: 'Early Bird', query: ''),
      FilterOptionModel(title: 'Last Minute Deals', query: ''),
      FilterOptionModel(title: 'Exclusive Deals', query: ''),
    ],
  ),
  FilterCategory(
    title: 'Solo',
    svgPath: CommonImages.solo,
    options: [
      FilterOptionModel(title: 'Solo Traveller', query: ''),
      FilterOptionModel(title: 'Female Solo Traveller', query: ''),
    ],
  ),
  FilterCategory(
    title: 'Rating',
    svgPath: CommonImages.stars,
    options: [
      FilterOptionModel(title: '4+ Rated', query: ''),
      FilterOptionModel(title: '3+ Rated', query: ''),
    ],
  ),
];

String buildFilterQueryString(List<String> selectedTitles) {
  final parts = <String>[];
  final seen = <String>{};

  for (final cat in _appFilterCategories) {
    final selectedInCategory = cat.options
        .where((opt) =>
            selectedTitles.contains(opt.title) && opt.query.isNotEmpty)
        .toList();

    if (selectedInCategory.isEmpty) continue;

    if (_isMultiSelect(cat.title)) {
      for (final opt in selectedInCategory) {
        if (seen.add(opt.query)) {
          parts.add(opt.query);
        }
      }
    } else {
      final query = selectedInCategory.first.query;
      if (seen.add(query)) {
        parts.add(query);
      }
    }
  }

  return parts.join('&');
}

class _MainFilterButton extends StatefulWidget {
  final int count;
  final VoidCallback onTap;

  const _MainFilterButton({
    required this.count,
    required this.onTap,
  });

  @override
  State<_MainFilterButton> createState() => _MainFilterButtonState();
}

class _MainFilterButtonState extends State<_MainFilterButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.count > 0;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: _T.durFast,
        curve: _T.easeOut,
        height: 5.4.h,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        decoration: BoxDecoration(
          gradient: active
              ? const LinearGradient(
                  colors: [_T.primary, _T.primaryHover],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: active ? null : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(18),
          border: active ? null : Border.all(color: _T.ink200),
          boxShadow: active ? [_T.shadowPrimary(0.16)] : [_T.shadowSm],
        ),
        transform: Matrix4.identity()..scale(_pressed ? 0.98 : 1.0),
        child: Row(
          children: [
            Container(
              width: 7.5.w,
              height: 7.5.w,
              constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
              decoration: BoxDecoration(
                color:
                    active ? Colors.white.withOpacity(0.16) : _T.primaryMuted,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.tune_rounded,
                color: active ? Colors.white : _T.primary,
                size: 18,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                active ? '${widget.count} applied' : 'Filters',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10.8, // FIX: Removed .sp to prevent massive text scaling
                  fontWeight: FontWeight.w700,
                  color: active ? Colors.white : _T.ink900,
                  height: 1.0,
                ),
              ),
            ),
            SizedBox(width: 2.w),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: active ? Colors.white : _T.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class CommonFilterBar extends StatefulWidget {
  final Function(List<String> selectedTitles) onFiltersChanged;

  const CommonFilterBar({super.key, required this.onFiltersChanged});

  @override
  State<CommonFilterBar> createState() => CommonFilterBarState();
}

class CommonFilterBarState extends State<CommonFilterBar> {
  List<String> _selected = [];

  int get _count => _selected.length;

  void updateFilters(List<String> newTitles) {
    if (!mounted) return;
    setState(() => _selected = List.unmodifiable(newTitles));
    widget.onFiltersChanged(List.unmodifiable(newTitles));
  }

  void _openSheet([String? openCategoryTitle]) async {
    HapticFeedback.selectionClick();

    final result = await showModalBottomSheet<List<String>>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      enableDrag: true,
      builder: (_) => _FilterSheetContent(
        initialSelections: List.from(_selected),
        initialCategory: openCategoryTitle ?? _appFilterCategories.first.title,
      ),
    );

    if (!mounted || result == null) return;

    setState(() => _selected = List.unmodifiable(result));
    widget.onFiltersChanged(List.unmodifiable(result));
  }

  void _clearAll() {
    HapticFeedback.lightImpact();
    setState(() => _selected = []);
    widget.onFiltersChanged([]);
  }

  @override
  Widget build(BuildContext context) {
    final hasFilters = _selected.isNotEmpty;

    return Material(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.06),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(4.w, 1.2.h, 4.w, 1.2.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _MainFilterButton(
                      count: _count,
                      onTap: () => _openSheet(),
                    ),
                  ),
                  SizedBox(width: 2.5.w),
                  _QuickActionChip(
                    label: hasFilters ? 'Clear' : 'Sort',
                    icon: hasFilters
                        ? Icons.restart_alt_rounded
                        : Icons.swap_vert_rounded,
                    onTap: hasFilters ? _clearAll : () => _openSheet('Sort'),
                    filled: hasFilters,
                  ),
                ],
              ),
              SizedBox(height: 1.1.h),
              SizedBox(
                height: 5.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _appFilterCategories.length,
                  separatorBuilder: (_, __) => SizedBox(width: 1.5.w),
                  itemBuilder: (_, i) {
                    final cat = _appFilterCategories[i];
                    final count = cat.options
                        .where((o) => _selected.contains(o.title))
                        .length;

                    return _CategoryMiniChip(
                      cat: cat,
                      isActive: count > 0,
                      count: count > 0 ? count : null,
                      onTap: () => _openSheet(cat.title),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterSheetContent extends StatefulWidget {
  final List<String> initialSelections;
  final String initialCategory;

  const _FilterSheetContent({
    required this.initialSelections,
    required this.initialCategory,
  });

  @override
  State<_FilterSheetContent> createState() => _FilterSheetContentState();
}

class _FilterSheetContentState extends State<_FilterSheetContent>
    with SingleTickerProviderStateMixin {
  late List<String> _draftSelected;
  late String _activeCategory;
  late AnimationController _controller;
  late Animation<double> _fade;

  FilterCategory get _currentCategory {
    try {
      return _appFilterCategories.firstWhere(
        (c) => c.title == _activeCategory,
      );
    } catch (_) {
      return _appFilterCategories.first;
    }
  }

  @override
  void initState() {
    super.initState();
    _draftSelected = List.from(widget.initialSelections);

    final exists = _appFilterCategories.any(
      (c) => c.title == widget.initialCategory,
    );
    _activeCategory =
        exists ? widget.initialCategory : _appFilterCategories.first.title;

    _controller = AnimationController(
      vsync: this,
      duration: _T.durFast,
    )..forward();

    _fade = CurvedAnimation(parent: _controller, curve: _T.easeOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _switchCategory(String title) {
    if (_activeCategory == title) return;
    HapticFeedback.selectionClick();
    _controller.reset();
    setState(() => _activeCategory = title);
    _controller.forward();
  }

  void _toggleOption(FilterOptionModel opt) {
    HapticFeedback.selectionClick();

    setState(() {
      final cat = _currentCategory;
      final isCurrentSelection = _draftSelected.contains(opt.title);

      if (_isMultiSelect(cat.title)) {
        if (isCurrentSelection) {
          _draftSelected.remove(opt.title);
        } else {
          _draftSelected.add(opt.title);
        }
      } else {
        _draftSelected.removeWhere(
          (t) => cat.options.any((o) => o.title == t),
        );

        if (!isCurrentSelection) {
          _draftSelected.add(opt.title);
        }
      }
    });
  }

  void _clearAllDraft() {
    HapticFeedback.lightImpact();
    setState(() => _draftSelected.clear());
  }

  void _apply() {
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop(List<String>.from(_draftSelected));
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Material(
        color: Colors.transparent,
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.68,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                Container(
                  height: 4,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_T.primarySoft, _T.primary, _T.primarySoft],
                    ),
                  ),
                ),
                _SheetHeader(
                  count: _draftSelected.length,
                  onClose: () => Navigator.of(context).pop(),
                  onClearAll: _clearAllDraft,
                ),
                const Divider(height: 1, color: _T.ink100),
                Padding(
                  padding: EdgeInsets.fromLTRB(4.w, 1.1.h, 4.w, 0.8.h),
                  child: SizedBox(
                    height: 4.8.h,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: _appFilterCategories.length,
                      separatorBuilder: (_, __) => SizedBox(width: 1.2.w),
                      itemBuilder: (_, i) {
                        final cat = _appFilterCategories[i];
                        final active = _activeCategory == cat.title;
                        final count = cat.options
                            .where((o) => _draftSelected.contains(o.title))
                            .length;

                        return _SheetCategoryTab(
                          title: cat.title,
                          icon: cat.svgPath,
                          active: active,
                          count: count > 0 ? count : null,
                          onTap: () => _switchCategory(cat.title),
                        );
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: FadeTransition(
                    opacity: _fade,
                    child: AnimatedSwitcher(
                      duration: _T.durFast,
                      child: _OptionList(
                        key: ValueKey(_activeCategory),
                        category: _currentCategory,
                        selected: _draftSelected,
                        onTap: _toggleOption,
                      ),
                    ),
                  ),
                ),
                _SheetFooter(
                  count: _draftSelected.length,
                  onClear: _clearAllDraft,
                  onApply: _apply,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickActionChip extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;

  const _QuickActionChip({
    required this.label,
    required this.icon,
    required this.onTap,
    this.filled = false,
  });

  @override
  State<_QuickActionChip> createState() => _QuickActionChipState();
}

class _QuickActionChipState extends State<_QuickActionChip> {
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
        curve: _T.easeOut,
        height: 5.4.h,
        padding: EdgeInsets.symmetric(horizontal: 3.8.w),
        decoration: BoxDecoration(
          color: widget.filled ? _T.primaryMuted : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: widget.filled ? _T.primarySoft : _T.ink200,
          ),
          boxShadow: [_T.shadowXs],
        ),
        transform: Matrix4.identity()..scale(_pressed ? 0.98 : 1.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(widget.icon, size: 18, color: _T.primary),
            SizedBox(width: 1.5.w),
            Text(
              widget.label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10.0, // FIX: Removed .sp
                fontWeight: FontWeight.w600,
                color: _T.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryMiniChip extends StatefulWidget {
  final FilterCategory cat;
  final bool isActive;
  final int? count;
  final VoidCallback onTap;

  const _CategoryMiniChip({
    required this.cat,
    required this.isActive,
    required this.onTap,
    this.count,
  });

  @override
  State<_CategoryMiniChip> createState() => _CategoryMiniChipState();
}

class _CategoryMiniChipState extends State<_CategoryMiniChip> {
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
        curve: _T.easeOut,
        height: 4.8.h,
        padding: EdgeInsets.symmetric(horizontal: 3.4.w),
        decoration: BoxDecoration(
          color: widget.isActive ? _T.primaryMuted : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: widget.isActive ? _T.primarySoft : _T.ink200,
          ),
          boxShadow: [_T.shadowXs],
        ),
        transform: Matrix4.identity()..scale(_pressed ? 0.98 : 1.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _TinySvgIcon(
              path: widget.cat.svgPath,
              color: widget.isActive ? _T.primary : _T.ink400,
              size: 14,
            ),
            SizedBox(width: 1.6.w),
            Text(
              widget.cat.title,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 9.2, // FIX: Removed .sp
                fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w500,
                color: widget.isActive ? _T.primary : _T.ink500,
              ),
            ),
            if (widget.count != null) ...[
              SizedBox(width: 1.w),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _T.primary,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${widget.count}',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TinySvgIcon extends StatelessWidget {
  final String path;
  final Color color;
  final double size;

  const _TinySvgIcon({
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
          Icons.filter_alt_rounded,
          size: size,
          color: color.withOpacity(0.35),
        ),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  final int count;
  final VoidCallback onClose;
  final VoidCallback onClearAll;

  const _SheetHeader({
    required this.count,
    required this.onClose,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(4.w, 1.0.h, 4.w, 1.0.h),
      child: Row(
        children: [
          Container(
            width: 12.w,
            height: 12.w,
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_T.primaryMuted, Color(0xFFF5F7FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.tune_rounded,
              size: 22,
              color: _T.primary,
            ),
          ),
          SizedBox(width: 3.2.w),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count > 0 ? 'Filters ($count)' : 'Filter Treks',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14.5, // FIX: Removed .sp
                    fontWeight: FontWeight.w700,
                    color: _T.ink900,
                    height: 1.0,
                  ),
                ),
                SizedBox(height: 0.25.h),
                Text(
                  count > 0
                      ? '$count selected'
                      : 'Refine by duration, policy, offers, and more',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 8.3, // FIX: Removed .sp
                    color: _T.ink400,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
          if (count > 0) ...[
            SizedBox(width: 2.w),
            _HeaderGhostButton(
              label: 'Clear',
              icon: Icons.delete_outline_rounded,
              onTap: onClearAll,
            ),
          ],
          SizedBox(width: 2.w),
          _HeaderRoundButton(
            icon: Icons.close_rounded,
            onTap: onClose,
          ),
        ],
      ),
    );
  }
}

class _HeaderGhostButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderGhostButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  State<_HeaderGhostButton> createState() => _HeaderGhostButtonState();
}

class _HeaderGhostButtonState extends State<_HeaderGhostButton> {
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
        padding: EdgeInsets.symmetric(horizontal: 3.2.w, vertical: 1.1.h),
        decoration: BoxDecoration(
          color: _pressed ? _T.primary.withOpacity(0.08) : _T.primaryMuted,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(widget.icon, size: 16, color: _T.primary),
            SizedBox(width: 1.2.w),
            Text(
              widget.label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 9.0, // FIX: Removed .sp
                fontWeight: FontWeight.w600,
                color: _T.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderRoundButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderRoundButton({
    required this.icon,
    required this.onTap,
  });

  @override
  State<_HeaderRoundButton> createState() => _HeaderRoundButtonState();
}

class _HeaderRoundButtonState extends State<_HeaderRoundButton> {
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
        width: 11.w,
        height: 11.w,
        constraints: const BoxConstraints(minWidth: 42, minHeight: 42),
        decoration: BoxDecoration(
          color: _pressed ? _T.ink100 : _T.ink050,
          shape: BoxShape.circle,
          border: Border.all(color: _T.ink100),
        ),
        child: Icon(widget.icon, color: _T.ink500, size: 22),
      ),
    );
  }
}

class _SheetCategoryTab extends StatelessWidget {
  final String title;
  final String icon;
  final bool active;
  final int? count;
  final VoidCallback onTap;

  const _SheetCategoryTab({
    required this.title,
    required this.icon,
    required this.active,
    required this.onTap,
    this.count,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: _T.durFast,
        curve: _T.easeOut,
        padding: EdgeInsets.symmetric(horizontal: 3.4.w, vertical: 1.1.h),
        decoration: BoxDecoration(
          color: active ? _T.primaryMuted : _T.ink050,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: active ? _T.primarySoft : _T.ink200,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _TinySvgIcon(
              path: icon,
              color: active ? _T.primary : _T.ink400,
              size: 14,
            ),
            SizedBox(width: 1.4.w),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 9.5, // FIX: Removed .sp
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                color: active ? _T.primary : _T.ink500,
              ),
            ),
            if (count != null) ...[
              SizedBox(width: 1.w),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _T.primary,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _OptionList extends StatelessWidget {
  final FilterCategory category;
  final List<String> selected;
  final ValueChanged<FilterOptionModel> onTap;

  const _OptionList({
    super.key,
    required this.category,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final multi = _isMultiSelect(category.title);

    return Padding(
      padding: EdgeInsets.fromLTRB(4.w, 0.8.h, 4.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                category.title.toUpperCase(),
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10.0, // FIX: Removed .sp
                  fontWeight: FontWeight.w700,
                  color: _T.ink400,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Container(
                  height: 1,
                  color: _T.ink100,
                ),
              ),
              if (multi)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    'multi-select',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 8.2, // FIX: Removed .sp
                      fontStyle: FontStyle.italic,
                      color: _T.ink300,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 1.2.h),
          Expanded(
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(bottom: 1.5.h),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisExtent: 7.2.h,
                crossAxisSpacing: 3.2.w,
                mainAxisSpacing: 1.4.h,
              ),
              itemCount: category.options.length,
              itemBuilder: (_, i) {
                final opt = category.options[i];
                final isSelected = selected.contains(opt.title);

                return _OptionCard(
                  title: opt.title,
                  isSelected: isSelected,
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
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionCard({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_OptionCard> createState() => _OptionCardState();
}

class _OptionCardState extends State<_OptionCard> {
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
        curve: _T.easeOut,
        padding: EdgeInsets.symmetric(horizontal: 3.8.w, vertical: 1.2.h),
        decoration: BoxDecoration(
          color: widget.isSelected
              ? _T.primaryMuted
              : _pressed
                  ? _T.ink050
                  : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: widget.isSelected ? _T.primarySoft : _T.ink200,
            width: widget.isSelected ? 1.3 : 1,
          ),
          boxShadow: widget.isSelected ? [_T.shadowXs] : const [],
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: _T.durFast,
              curve: _T.spring,
              width: 5.2.w,
              height: 5.2.w,
              constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.isSelected ? _T.primary : Colors.transparent,
                border: Border.all(
                  color: widget.isSelected ? _T.primary : _T.ink200,
                  width: widget.isSelected ? 0 : 1.3,
                ),
              ),
              child: widget.isSelected
                  ? const Icon(Icons.check_rounded, size: 13, color: Colors.white)
                  : null,
            ),
            SizedBox(width: 2.8.w),
            Expanded(
              child: Text(
                widget.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 9.8, // FIX: Removed .sp
                  fontWeight:
                      widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: widget.isSelected ? _T.primary : _T.ink700,
                  height: 1.15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetFooter extends StatelessWidget {
  final int count;
  final VoidCallback onClear;
  final VoidCallback onApply;

  const _SheetFooter({
    required this.count,
    required this.onClear,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(4.w, 1.2.h, 4.w, 1.8.h),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _T.ink100)),
      ),
      child: SafeArea(
        top: false,
        minimum: EdgeInsets.only(bottom: 1.h),
        child: Row(
          children: [
            SizedBox(
              height: 5.2.h,
              child: OutlinedButton(
                onPressed: onClear,
                style: OutlinedButton.styleFrom(
                  foregroundColor: _T.ink500,
                  side: const BorderSide(color: _T.ink200),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 4.6.w),
                ),
                child: Text(
                  'Clear',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10.0, // FIX: Removed .sp
                    fontWeight: FontWeight.w600,
                    color: _T.ink500,
                  ),
                ),
              ),
            ),
            SizedBox(width: 2.5.w),
            Expanded(
              child: SizedBox(
                height: 5.2.h,
                child: ElevatedButton(
                  onPressed: count > 0 ? onApply : null,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: _T.primary,
                    disabledBackgroundColor: _T.ink100,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: count > 0
                          ? const LinearGradient(
                              colors: [_T.primary, _T.primaryHover],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        count > 0 ? 'Apply • $count selected' : 'Apply',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10.5, // FIX: Removed .sp
                          fontWeight: FontWeight.w600,
                          color: count > 0 ? Colors.white : _T.ink400,
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
    );
  }
}