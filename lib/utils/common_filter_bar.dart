import 'package:arobo_app/utils/common_images.dart';
import 'package:arobo_app/utils/screen_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sizer/sizer.dart';
import '../models/filter_category_model.dart';
import 'common_colors.dart';

// ─────────────────────────────────────────────
//  DESIGN TOKENS
// ─────────────────────────────────────────────
class _F {
  static const accent       = Color(0xFF3B5BDB);
  static const accentLight  = Color(0xFFEEF2FF);
  static const accentDark   = Color(0xFF2946C4);
  static const ink          = Color(0xFF0F172A);
  static const inkMid       = Color(0xFF64748B);
  static const inkLight     = Color(0xFFADB5BD);
  static const border       = Color(0xFFE9ECEF);
  static const cardBg       = Color(0xFFFFFFFF);
  static const bg           = Color(0xFFF4F7FF);
  static const divider      = Color(0xFFF1F5F9);
  static const greenBg      = Color(0xFFE6F5F3);
  static const greenFg      = Color(0xFF0F7B6C);
}

// ─────────────────────────────────────────────
//  FILTER CATEGORIES — with Policy added,
//  "Solo Friendly" removed from Solo-Traveller
// ─────────────────────────────────────────────
final List<FilterCategory> _appFilterCategories = [
  FilterCategory(
    title: 'Sort',
    svgPath: CommonImages.sort,
    options: [
      FilterOptionModel(title: 'Relevance',          query: ''),
      FilterOptionModel(title: 'Price: Low to High', query: 'sort_by=base_price&sort_order=ASC'),
      FilterOptionModel(title: 'Price: High to Low', query: 'sort_by=base_price&sort_order=DESC'),
      FilterOptionModel(title: 'Newest on Top',      query: ''),
      FilterOptionModel(title: 'Female-Exclusive',   query: ''),
      FilterOptionModel(title: 'High Rated Treks',   query: ''),
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
      FilterOptionModel(title: '7D+',     query: ''),
    ],
  ),
  FilterCategory(
    title: 'Policy',
    svgPath: CommonImages.filter, // reuse filter icon; swap if you have a policy svg
    options: [
      FilterOptionModel(title: 'Flexible',  query: 'policy=flexible'),
      FilterOptionModel(title: 'Standard',  query: 'policy=standard'),
    ],
  ),
  FilterCategory(
    title: 'Offers',
    svgPath: CommonImages.discount,
    options: [
      FilterOptionModel(title: 'Special Offers',   query: ''),
      FilterOptionModel(title: 'Early Bird',        query: ''),
      FilterOptionModel(title: 'Last Minute Deals', query: ''),
      FilterOptionModel(title: 'Exclusive Deals',   query: ''),
    ],
  ),
  FilterCategory(
    title: 'Solo',
    svgPath: CommonImages.solo,
    options: [
      // "Solo Friendly" removed per request
      FilterOptionModel(title: 'Solo Traveller',        query: ''),
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

// ─────────────────────────────────────────────
//  PUBLIC: query string builder
//  Call this with the list of selected titles
//  to get the query params for your API call.
// ─────────────────────────────────────────────
String buildFilterQueryString(List<String> selectedTitles) {
  final parts = <String>[];
  for (final cat in _appFilterCategories) {
    for (final opt in cat.options) {
      if (selectedTitles.contains(opt.title) && opt.query.isNotEmpty) {
        parts.add(opt.query);
      }
    }
  }
  return parts.join('&');
}

// ─────────────────────────────────────────────
//  FILTER BAR WIDGET
// ─────────────────────────────────────────────
class CommonFilterBar extends StatefulWidget {
  /// Called with the list of selected option TITLES whenever filters change.
  /// Use [buildFilterQueryString] to convert titles → API query string.
  final Function(List<String> selectedTitles) onFiltersChanged;

  const CommonFilterBar({super.key, required this.onFiltersChanged});

  @override
  State<CommonFilterBar> createState() => CommonFilterBarState();
}

class CommonFilterBarState extends State<CommonFilterBar> {
  // FIX: single source of truth — List<String> of selected option titles
  List<String> _selected = [];

  int get _count => _selected.length;

  // ── Public API called by parent to sync state (e.g. after chip removal) ──
  // FIX: no firstWhere, no crash — just assign and rebuild
  void updateFilters(List<String> newTitles) {
    if (!mounted) return;
    setState(() => _selected = List.from(newTitles));
  }

  // ── Safe helpers ──────────────────────────────────────────────────────────

  /// Returns the selected option title for a category, or null if none.
  String? _selectedLabelFor(FilterCategory cat) {
    for (final opt in cat.options) {
      if (_selected.contains(opt.title)) return opt.title;
    }
    return null;
  }

  bool _catHasSelection(FilterCategory cat) =>
      cat.options.any((o) => _selected.contains(o.title));

  // ── Bottom sheet ──────────────────────────────────────────────────────────

  void _openSheet([String? openCategoryTitle]) {
    // FIX: work entirely with List<String> — no FilterOptionModel in temp state
    List<String> temp = List.from(_selected);
    String activeCat = openCategoryTitle ?? _appFilterCategories.first.title;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheet) {
          final currentCat = _appFilterCategories
              .firstWhere((c) => c.title == activeCat);

          return Container(
            height: 90.h,
            decoration: const BoxDecoration(
              color: _F.cardBg,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // ── Sheet header ──────────────────────────────────────
                _SheetHeader(
                  count: temp.length,
                  onClose: () => Navigator.pop(ctx),
                  onClearAll: () {
                    setSheet(() => temp.clear());
                    setState(() => _selected.clear());
                    widget.onFiltersChanged([]);
                  },
                ),

                // ── Body: two-column layout ───────────────────────────
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left: category list
                      Container(
                        width: 36.w,
                        color: _F.bg,
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: _appFilterCategories.length,
                          itemBuilder: (_, i) {
                            final cat = _appFilterCategories[i];
                            final isCurrent = activeCat == cat.title;
                            // FIX: safe check using temp list of strings
                            final hasSel = cat.options
                                .any((o) => temp.contains(o.title));

                            return _CategoryTile(
                              cat: cat,
                              isCurrent: isCurrent,
                              hasSel: hasSel,
                              onTap: () =>
                                  setSheet(() => activeCat = cat.title),
                            );
                          },
                        ),
                      ),

                      // Right: options list
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Category label
                            Padding(
                              padding: EdgeInsets.fromLTRB(
                                  4.w, 1.8.h, 4.w, 0.8.h),
                              child: Text(
                                currentCat.title.toUpperCase(),
                                textScaler: const TextScaler.linear(1.0),
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: FontSize.s8,
                                  fontWeight: FontWeight.w700,
                                  color: _F.inkLight,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                itemCount: currentCat.options.length,
                                itemBuilder: (_, i) {
                                  final opt = currentCat.options[i];
                                  // FIX: compare String to String — never crashes
                                  final isOn = temp.contains(opt.title);

                                  return _OptionTile(
                                    label: opt.title,
                                    isSelected: isOn,
                                    onTap: () {
                                      setSheet(() {
                                        if (currentCat.title == 'Sort') {
                                          // Single-select for Sort:
                                          // FIX: remove all sort titles by name — not by object
                                          for (final o in currentCat.options) {
                                            temp.remove(o.title);
                                          }
                                          if (!isOn) temp.add(opt.title);
                                        } else {
                                          // Single-select per category
                                          for (final o in currentCat.options) {
                                            temp.remove(o.title);
                                          }
                                          if (!isOn) temp.add(opt.title);
                                        }
                                      });
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Footer ────────────────────────────────────────────
                _SheetFooter(
                  count: temp.length,
                  onClear: () {
                    setSheet(() => temp.clear());
                    setState(() => _selected.clear());
                    widget.onFiltersChanged([]);
                  },
                  onApply: () {
                    // FIX: clean assignment — no firstWhere, no crash
                    setState(() => _selected = List.from(temp));
                    widget.onFiltersChanged(List.from(temp));
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 4.5.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        // FIX: using ListView not Row — no overflow
        itemCount: _appFilterCategories.length + 1, // +1 for main filter btn
        separatorBuilder: (_, __) => SizedBox(width: 2.w),
        itemBuilder: (_, i) {
          // ── Main filter button ───────────────────────────────────
          if (i == 0) {
            return _FilterMainBtn(
              count: _count,
              onTap: () {
                if (_count > 0) {
                  // Tapping the active filter btn clears all
                  setState(() => _selected.clear());
                  widget.onFiltersChanged([]);
                } else {
                  _openSheet();
                }
              },
            );
          }

          // ── Category shortcut chips ───────────────────────────────
          final cat = _appFilterCategories[i - 1];
          final label = _selectedLabelFor(cat);
          final isActive = label != null;

          return _CategoryChip(
            cat: cat,
            label: label,
            isActive: isActive,
            onTap: () => _openSheet(cat.title),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  EXTRACTED SUB-WIDGETS (keep build() clean)
// ─────────────────────────────────────────────

class _FilterMainBtn extends StatelessWidget {
  final int count;
  final VoidCallback onTap;
  const _FilterMainBtn({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final active = count > 0;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 4.5.h,
        padding: EdgeInsets.symmetric(horizontal: 3.5.w),
        decoration: BoxDecoration(
          color: active ? _F.accent : _F.cardBg,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: active ? _F.accent : _F.border,
            width: active ? 0 : 1,
          ),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: _F.accent.withValues(alpha: 0.28),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              active ? Icons.tune_rounded : Icons.tune_rounded,
              size: 15,
              color: active ? Colors.white : _F.inkMid,
            ),
            SizedBox(width: 1.5.w),
            Text(
              active ? '$count Applied' : 'Filters',
              textScaler: const TextScaler.linear(1.0),
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: FontSize.s10,
                fontWeight: FontWeight.w600,
                color: active ? Colors.white : _F.ink,
              ),
            ),
            if (active) ...[
              SizedBox(width: 1.5.w),
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded,
                    size: 10, color: Colors.white),
              ),
            ] else ...[
              SizedBox(width: 1.w),
              Icon(Icons.keyboard_arrow_down_rounded,
                  size: 14, color: _F.inkLight),
            ],
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final FilterCategory cat;
  final String? label;
  final bool isActive;
  final VoidCallback onTap;
  const _CategoryChip(
      {required this.cat,
      required this.label,
      required this.isActive,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 4.5.h,
        padding: EdgeInsets.symmetric(horizontal: 2.8.w),
        decoration: BoxDecoration(
          color: isActive ? _F.accentLight : _F.cardBg,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isActive ? _F.accent : _F.border,
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              cat.svgPath,
              colorFilter: ColorFilter.mode(
                isActive ? _F.accent : _F.inkLight,
                BlendMode.srcIn,
              ),
              width: 3.5.w,
              height: 3.5.w,
            ),
            SizedBox(width: 1.5.w),
            Text(
              _truncate(label ?? cat.title),
              textScaler: const TextScaler.linear(1.0),
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: FontSize.s9,
                fontWeight:
                    isActive ? FontWeight.w700 : FontWeight.w400,
                color: isActive ? _F.accent : _F.inkMid,
              ),
            ),
            SizedBox(width: 1.w),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 13,
              color: isActive ? _F.accent : _F.inkLight,
            ),
          ],
        ),
      ),
    );
  }

  String _truncate(String s) =>
      s.length > 12 ? '${s.substring(0, 11)}…' : s;
}

class _SheetHeader extends StatelessWidget {
  final int count;
  final VoidCallback onClose;
  final VoidCallback onClearAll;
  const _SheetHeader(
      {required this.count,
      required this.onClose,
      required this.onClearAll});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Drag handle
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 4),
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: _F.border,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
          child: Row(
            children: [
              const Icon(Icons.tune_rounded, size: 20, color: _F.accent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  count > 0 ? 'Filters ($count)' : 'Filter Treks',
                  textScaler: const TextScaler.linear(1.0),
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: FontSize.s15,
                    fontWeight: FontWeight.w700,
                    color: _F.ink,
                  ),
                ),
              ),
              if (count > 0)
                GestureDetector(
                  onTap: onClearAll,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _F.accentLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Clear all',
                      textScaler: const TextScaler.linear(1.0),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: FontSize.s9,
                        fontWeight: FontWeight.w600,
                        color: _F.accent,
                      ),
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onClose,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _F.bg,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close_rounded,
                      size: 16, color: _F.inkMid),
                ),
              ),
            ],
          ),
        ),
        Divider(height: 1, color: _F.divider),
      ],
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final FilterCategory cat;
  final bool isCurrent;
  final bool hasSel;
  final VoidCallback onTap;
  const _CategoryTile(
      {required this.cat,
      required this.isCurrent,
      required this.hasSel,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
        decoration: BoxDecoration(
          color: isCurrent ? _F.cardBg : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: isCurrent ? _F.accent : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              cat.svgPath,
              colorFilter: ColorFilter.mode(
                isCurrent ? _F.accent : _F.inkLight,
                BlendMode.srcIn,
              ),
              width: 3.8.w,
              height: 3.8.w,
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: Text(
                cat.title,
                textScaler: const TextScaler.linear(1.0),
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: FontSize.s10,
                  fontWeight:
                      isCurrent ? FontWeight.w700 : FontWeight.w400,
                  color: isCurrent ? _F.accent : _F.inkMid,
                ),
              ),
            ),
            if (hasSel)
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: _F.accent,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _OptionTile(
      {required this.label,
      required this.isSelected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 130),
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.6.h),
        decoration: BoxDecoration(
          color: isSelected
              ? _F.accentLight
              : Colors.transparent,
          border: Border(
            bottom: BorderSide(color: _F.divider, width: 0.8),
          ),
        ),
        child: Row(
          children: [
            // Animated radio/check
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 5.w,
              height: 5.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? _F.accent : Colors.transparent,
                border: Border.all(
                  color: isSelected ? _F.accent : _F.border,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded,
                      size: 11, color: Colors.white)
                  : null,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                label,
                textScaler: const TextScaler.linear(1.0),
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: FontSize.s11,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? _F.accent : _F.ink,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded,
                  size: 16, color: _F.accent),
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
  const _SheetFooter(
      {required this.count,
      required this.onClear,
      required this.onApply});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(4.w, 1.2.h, 4.w, 2.h),
      decoration: BoxDecoration(
        color: _F.cardBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Clear button
            OutlinedButton(
              onPressed: onClear,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                    horizontal: 5.w, vertical: 1.4.h),
                side: const BorderSide(color: _F.border),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'Clear',
                textScaler: const TextScaler.linear(1.0),
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: FontSize.s11,
                  fontWeight: FontWeight.w500,
                  color: _F.inkMid,
                ),
              ),
            ),
            SizedBox(width: 3.w),
            // Apply button
            Expanded(
              child: ElevatedButton(
                onPressed: onApply,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 1.4.h),
                  backgroundColor: _F.accent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  shadowColor: _F.accent.withValues(alpha: 0.4),
                ),
                child: Text(
                  count > 0 ? 'Apply  $count filter${count > 1 ? 's' : ''}' : 'Apply',
                  textScaler: const TextScaler.linear(1.0),
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: FontSize.s12,
                    fontWeight: FontWeight.w700,
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