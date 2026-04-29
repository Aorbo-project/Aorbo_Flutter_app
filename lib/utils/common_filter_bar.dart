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
class _FC {
  static const accent      = Color(0xFF3B5BDB);
  static const accentLight = Color(0xFFEEF2FF);
  static const ink         = Color(0xFF0F172A);
  static const inkMid      = Color(0xFF64748B);
  static const inkLight    = Color(0xFFADB5BD);
  static const border      = Color(0xFFE9ECEF);
  static const cardBg      = Color(0xFFFFFFFF);
  static const bg          = Color(0xFFF4F7FF);
  static const selectedCat = Color(0xFFEEF2FF);
}

// ─────────────────────────────────────────────
//  FILTER BUTTON (pill style)
// ─────────────────────────────────────────────
class CommonFilterButton extends StatelessWidget {
  final String text;
  final String svgPath;
  final VoidCallback? onPressed;
  final bool isActive;

  const CommonFilterButton({
    super.key,
    required this.text,
    required this.svgPath,
    this.onPressed,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0),
        height: 4.h,
        decoration: BoxDecoration(
          color: isActive ? _FC.accent : _FC.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? _FC.accent
                : _FC.border,
            width: isActive ? 0 : 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: _FC.accent.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
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
            SvgPicture.asset(
              svgPath,
              colorFilter: ColorFilter.mode(
                isActive ? Colors.white : _FC.inkMid,
                BlendMode.srcIn,
              ),
              height: 4.w,
              width: 4.w,
            ),
            SizedBox(width: 1.5.w),
            Text(
              text,
              textScaler: const TextScaler.linear(1.0),
              style: TextStyle(
                fontFamily: 'Poppins',
                color: isActive ? Colors.white : _FC.ink,
                fontSize: FontSize.s10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            if (!isActive) ...[
              SizedBox(width: 1.w),
              Icon(Icons.keyboard_arrow_down_rounded,
                  size: 14, color: _FC.inkLight),
            ] else ...[
              SizedBox(width: 1.w),
              Icon(Icons.close_rounded, size: 13, color: Colors.white),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  FILTER BAR
// ─────────────────────────────────────────────
class CommonFilterBar extends StatefulWidget {
  final Function(List<String>) onFiltersChanged;

  const CommonFilterBar({super.key, required this.onFiltersChanged});

  @override
  State<CommonFilterBar> createState() => CommonFilterBarState();
}

class CommonFilterBarState extends State<CommonFilterBar> {
  // FIX: selectedFilters stores option TITLES (strings) — consistent throughout
  List<String> selectedFilters = [];

  // FIX: updateFilters — safe, no crash on missing match
  void updateFilters(List<String> newFilters) {
    if (!mounted) return;
    setState(() {
      selectedFilters = List.from(newFilters);
    });
  }

  // Returns true if any option in this category is currently selected
  bool _categoryHasSelection(FilterCategory cat) {
    return cat.options.any((o) => selectedFilters.contains(o.title));
  }

  // Returns the selected option title for a category (or null)
  String? _categorySelectedLabel(FilterCategory cat) {
    try {
      final found = cat.options.firstWhere(
        (o) => selectedFilters.contains(o.title),
      );
      return found.title;
    } catch (_) {
      return null;
    }
  }

  void _showFilterBottomSheet([String? categoryTitle]) {
    // FIX: work with List<String> (titles) throughout — no type mismatch
    List<String> tempSelected = List.from(selectedFilters);
    String selectedCat = categoryTitle ?? filterCategories.first.title;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) {
          final currentCat = filterCategories
              .firstWhere((c) => c.title == selectedCat);

          return Container(
            height: 88.h,
            decoration: const BoxDecoration(
              color: _FC.cardBg,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // ── Handle + header ──────────────────────────────────
                Container(
                  padding: EdgeInsets.fromLTRB(5.w, 12, 5.w, 0),
                  child: Column(
                    children: [
                      // Drag handle
                      Container(
                        width: 10.w,
                        height: 4,
                        decoration: BoxDecoration(
                          color: _FC.border,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      SizedBox(height: 1.5.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Filter Treks',
                            textScaler: const TextScaler.linear(1.0),
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: FontSize.s16,
                              fontWeight: FontWeight.w700,
                              color: _FC.ink,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(ctx),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: _FC.bg,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.close_rounded,
                                  size: 18, color: _FC.inkMid),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 1.h),
                      Divider(color: _FC.border, height: 1),
                    ],
                  ),
                ),

                // ── Body: category list + options ────────────────────
                Expanded(
                  child: Row(
                    children: [
                      // Left: category list
                      Container(
                        width: 38.w,
                        decoration: BoxDecoration(
                          color: _FC.bg,
                          border: Border(
                            right: BorderSide(color: _FC.border),
                          ),
                        ),
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: filterCategories.length,
                          itemBuilder: (_, i) {
                            final cat = filterCategories[i];
                            final isActive = selectedCat == cat.title;
                            // FIX: safe check — no crash
                            final hasSelection = _categoryHasSelectionIn(
                                cat, tempSelected);

                            return GestureDetector(
                              onTap: () =>
                                  setModal(() => selectedCat = cat.title),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: EdgeInsets.symmetric(
                                  vertical: 1.8.h,
                                  horizontal: 4.w,
                                ),
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? _FC.cardBg
                                      : Colors.transparent,
                                  border: Border(
                                    left: BorderSide(
                                      color: isActive
                                          ? _FC.accent
                                          : Colors.transparent,
                                      width: 3,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    SvgPicture.asset(
                                      cat.svgPath,
                                      colorFilter: ColorFilter.mode(
                                        isActive ? _FC.accent : _FC.inkLight,
                                        BlendMode.srcIn,
                                      ),
                                      width: 4.w,
                                      height: 4.w,
                                    ),
                                    SizedBox(width: 2.w),
                                    Expanded(
                                      child: Text(
                                        cat.title,
                                        textScaler:
                                            const TextScaler.linear(1.0),
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: FontSize.s10,
                                          fontWeight: isActive
                                              ? FontWeight.w700
                                              : FontWeight.w400,
                                          color: isActive
                                              ? _FC.accent
                                              : _FC.inkMid,
                                        ),
                                      ),
                                    ),
                                    // Dot indicator when category has a selection
                                    if (hasSelection)
                                      Container(
                                        width: 7,
                                        height: 7,
                                        decoration: const BoxDecoration(
                                          color: _FC.accent,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // Right: options
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Category header
                            Padding(
                              padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 1.h),
                              child: Text(
                                currentCat.title == 'Sort'
                                    ? 'Sort by'
                                    : currentCat.title,
                                textScaler: const TextScaler.linear(1.0),
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: FontSize.s9,
                                  fontWeight: FontWeight.w700,
                                  color: _FC.inkMid,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                padding: EdgeInsets.only(bottom: 2.h),
                                itemCount: currentCat.options.length,
                                itemBuilder: (_, i) {
                                  final option = currentCat.options[i];
                                  // FIX: compare title string to title string
                                  final isSelected = tempSelected
                                      .contains(option.title);

                                  return GestureDetector(
                                    onTap: () {
                                      setModal(() {
                                        if (currentCat.title == 'Sort') {
                                          // FIX: clear all sort options first
                                          // using title strings — not FilterOptionModel
                                          for (final opt in filterCategories
                                              .firstWhere((c) =>
                                                  c.title == 'Sort')
                                              .options) {
                                            tempSelected.remove(opt.title);
                                          }
                                          if (!isSelected) {
                                            tempSelected.add(option.title);
                                          }
                                        } else {
                                          // Single-select per category
                                          // FIX: remove other options in this cat first
                                          for (final opt
                                              in currentCat.options) {
                                            tempSelected.remove(opt.title);
                                          }
                                          if (!isSelected) {
                                            tempSelected.add(option.title);
                                          }
                                        }
                                      });
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 4.w, vertical: 1.6.h),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? _FC.accentLight
                                            : Colors.transparent,
                                        border: Border(
                                          bottom: BorderSide(
                                              color: _FC.border,
                                              width: 0.5),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          // Radio indicator
                                          AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 150),
                                            width: 5.w,
                                            height: 5.w,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: isSelected
                                                  ? _FC.accent
                                                  : Colors.transparent,
                                              border: Border.all(
                                                color: isSelected
                                                    ? _FC.accent
                                                    : _FC.inkLight,
                                                width: 1.5,
                                              ),
                                            ),
                                            child: isSelected
                                                ? const Icon(
                                                    Icons.check_rounded,
                                                    size: 11,
                                                    color: Colors.white,
                                                  )
                                                : null,
                                          ),
                                          SizedBox(width: 3.w),
                                          Expanded(
                                            child: Text(
                                              option.title,
                                              textScaler: const TextScaler
                                                  .linear(1.0),
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: FontSize.s11,
                                                fontWeight: isSelected
                                                    ? FontWeight.w600
                                                    : FontWeight.w400,
                                                color: isSelected
                                                    ? _FC.accent
                                                    : _FC.ink,
                                              ),
                                            ),
                                          ),
                                          if (isSelected)
                                            Icon(Icons.check_circle_rounded,
                                                size: 16, color: _FC.accent),
                                        ],
                                      ),
                                    ),
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

                // ── Footer: clear + apply ────────────────────────────
                Container(
                  padding: EdgeInsets.fromLTRB(4.w, 1.2.h, 4.w, 2.h),
                  decoration: BoxDecoration(
                    color: _FC.cardBg,
                    border: Border(top: BorderSide(color: _FC.border)),
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
                        // Clear all
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setModal(() => tempSelected.clear());
                              setState(() {
                                selectedFilters.clear();
                              });
                              widget.onFiltersChanged([]);
                            },
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 1.5.h),
                              side: BorderSide(color: _FC.border),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'Clear all',
                              textScaler: const TextScaler.linear(1.0),
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: FontSize.s11,
                                fontWeight: FontWeight.w500,
                                color: _FC.inkMid,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 3.w),
                        // Apply
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () {
                              // FIX: update state cleanly — no firstWhere crash
                              setState(() {
                                selectedFilters = List.from(tempSelected);
                              });
                              widget.onFiltersChanged(
                                  List.from(tempSelected));
                              Navigator.pop(ctx);
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 1.5.h),
                              backgroundColor: _FC.accent,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              tempSelected.isEmpty
                                  ? 'Apply'
                                  : 'Apply (${tempSelected.length})',
                              textScaler: const TextScaler.linear(1.0),
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: FontSize.s11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // FIX: safe helper — checks using title strings
  bool _categoryHasSelectionIn(
      FilterCategory cat, List<String> selected) {
    return cat.options.any((o) => selected.contains(o.title));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 4.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        itemCount: filterCategories.length + 1, // +1 for the main Filter btn
        separatorBuilder: (_, __) => SizedBox(width: 2.w),
        itemBuilder: (_, i) {
          // First item: main "Filter" button
          if (i == 0) {
            final anyActive = selectedFilters.isNotEmpty;
            return CommonFilterButton(
              text: anyActive
                  ? '${selectedFilters.length} Filters'
                  : 'Filter',
              svgPath: CommonImages.filter,
              onPressed: anyActive
                  // If filters active, tapping clears all
                  ? () {
                      setState(() => selectedFilters.clear());
                      widget.onFiltersChanged([]);
                    }
                  : () => _showFilterBottomSheet(),
              isActive: anyActive,
            );
          }

          // Category shortcut chips
          final cat = filterCategories[i - 1];
          final selected = _categorySelectedLabel(cat);
          final isActive = selected != null;

          return GestureDetector(
            onTap: () => _showFilterBottomSheet(cat.title),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: 4.h,
              padding: EdgeInsets.symmetric(horizontal: 2.5.w),
              decoration: BoxDecoration(
                color: isActive ? _FC.accentLight : _FC.cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive ? _FC.accent : _FC.border,
                  width: isActive ? 1.5 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    cat.svgPath,
                    colorFilter: ColorFilter.mode(
                      isActive ? _FC.accent : _FC.inkLight,
                      BlendMode.srcIn,
                    ),
                    height: 3.5.w,
                    width: 3.5.w,
                  ),
                  SizedBox(width: 1.5.w),
                  Text(
                    // Show selected option label (truncated) or category name
                    selected != null && selected.length > 10
                        ? '${selected.substring(0, 9)}…'
                        : (selected ?? cat.title),
                    textScaler: const TextScaler.linear(1.0),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: isActive ? _FC.accent : _FC.inkMid,
                      fontSize: FontSize.s9,
                      fontWeight:
                          isActive ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  SizedBox(width: 1.w),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 13,
                    color: isActive ? _FC.accent : _FC.inkLight,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}