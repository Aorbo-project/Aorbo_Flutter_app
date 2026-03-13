import 'package:arobo_app/utils/common_images.dart';
import 'package:arobo_app/utils/screen_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sizer/sizer.dart';
import '../models/filter_category_model.dart';
import 'common_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class CommonFilterButton extends StatelessWidget {
  final String text;
  final String svgPath;
  final VoidCallback? onPressed;
  final bool showDropdownIcon;
  final double? width;
  final double? height;

  const CommonFilterButton({
    super.key,
    required this.text,
    required this.svgPath,
    this.onPressed,
    this.showDropdownIcon = true,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 5.h,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey.shade300),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2.w),
          ),
          padding: EdgeInsets.only(left: 2.2.w, right: 2.8.w),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(svgPath,
                colorFilter:
                    ColorFilter.mode(CommonColors.blackColor, BlendMode.srcIn),
                height: 5.w,
                width: 5.w),
            SizedBox(width: 2.w),
            Text(
              text,
              textScaler: const TextScaler.linear(1.0),
              style: GoogleFonts.poppins(
                color: CommonColors.blackColor,
                fontSize: FontSize.s10,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CommonFilterBar extends StatefulWidget {
  final Function(List<String>) onFiltersChanged;

  const CommonFilterBar({super.key, required this.onFiltersChanged});

  @override
  State<CommonFilterBar> createState() => CommonFilterBarState();
}

class CommonFilterBarState extends State<CommonFilterBar> {
  List<String> selectedFilters = [];
  Map<String, String?> shortcutSelections = {};

  final List<String> shortcutTitles = [
    'Sort',
    'Duration',
    'Offers',
    'Solo-Traveller',
    'High Rated Treks',
  ];

  void updateFilters(List<String> newFilters) {
    setState(() {
      selectedFilters = List.from(newFilters);
      // Update shortcut selections based on new filters
      for (final title in shortcutTitles) {
        final cat = filterCategories.firstWhere((c) => c.title == title,
            orElse: () => filterCategories[0]);
        final found = cat.options
            .firstWhere((o) => selectedFilters.contains(o), orElse: () => '');
        shortcutSelections[title] = found.isNotEmpty ? found : null;
      }
    });
  }

  void _showFilterBottomSheet([String? categoryTitle]) {
    // Create a temporary list to hold selected filters during modal interaction
    List<String> tempSelectedFilters = List.from(selectedFilters);
    // Track the selected category
    String selectedCategory = categoryTitle ?? 'Sort';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          return Container(
            height: 85.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(4.w)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter',
                        style: GoogleFonts.poppins(
                          fontSize: FontSize.s15,
                          fontWeight: FontWeight.w600,
                          color: CommonColors.blackColor,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: EdgeInsets.all(1.w),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            size: 6.w,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: Colors.grey[200]),
                // Main Content
                Expanded(
                  child: Row(
                    children: [
                      // Left side - Categories
                      Container(
                        width: 35.w,
                        decoration: BoxDecoration(
                          border: Border(
                            right: BorderSide(
                              color: Colors.grey[200]!,
                              width: 1,
                            ),
                          ),
                        ),
                        child: ListView(
                          padding: EdgeInsets.zero,
                          children: filterCategories.map((category) {
                            bool isSelected =
                                selectedCategory == category.title;
                            return GestureDetector(
                              onTap: () {
                                setModalState(() {
                                  selectedCategory = category.title;
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: 2.5.h,
                                  horizontal: 4.w,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? CommonColors.appBgColor.withOpacity(0.1)
                                      : Colors.transparent,
                                  border: Border(
                                    left: BorderSide(
                                      color: isSelected
                                          ? CommonColors.appBgColor
                                          : Colors.transparent,
                                      width: 3,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  category.title,
                                  style: GoogleFonts.poppins(
                                    fontSize: FontSize.s10,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: isSelected
                                        ? CommonColors.appBgColor
                                        : Colors.grey[600],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      // Right side - Options
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 2.h),
                              Text(
                                selectedCategory == 'Sort'
                                    ? 'SORT BY'
                                    : selectedCategory.toUpperCase(),
                                style: GoogleFonts.poppins(
                                  fontSize: FontSize.s9,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[600],
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Expanded(
                                child: ListView(
                                  padding: EdgeInsets.zero,
                                  children: filterCategories
                                      .firstWhere((cat) =>
                                          cat.title == selectedCategory)
                                      .options
                                      .map((option) {
                                    final isSelected =
                                        tempSelectedFilters.contains(option);
                                    return GestureDetector(
                                      onTap: () {
                                        setModalState(() {
                                          if (selectedCategory == 'Sort') {
                                            tempSelectedFilters.removeWhere(
                                                (filter) => filterCategories
                                                    .firstWhere((cat) =>
                                                        cat.title ==
                                                        selectedCategory)
                                                    .options
                                                    .contains(filter));
                                            if (!isSelected) {
                                              tempSelectedFilters.add(option);
                                            }
                                          } else {
                                            if (isSelected) {
                                              tempSelectedFilters
                                                  .remove(option);
                                            } else {
                                              final categoryOptions =
                                                  filterCategories
                                                      .firstWhere((cat) =>
                                                          cat.title ==
                                                          selectedCategory)
                                                      .options
                                                      .toSet();
                                              tempSelectedFilters.removeWhere(
                                                  (filter) => categoryOptions
                                                      .contains(filter));
                                              tempSelectedFilters.add(option);
                                            }
                                          }
                                        });
                                      },
                                      child: Container(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 2.h),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 5.w,
                                              height: 5.w,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: isSelected
                                                      ? CommonColors.appBgColor
                                                      : Colors.grey[400]!,
                                                  width: 2,
                                                ),
                                              ),
                                              child: isSelected
                                                  ? Center(
                                                      child: Container(
                                                        width: 2.5.w,
                                                        height: 2.5.w,
                                                        decoration:
                                                            BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: CommonColors
                                                              .appBgColor,
                                                        ),
                                                      ),
                                                    )
                                                  : null,
                                            ),
                                            SizedBox(width: 3.w),
                                            Text(
                                              option,
                                              style: GoogleFonts.poppins(
                                                fontSize: FontSize.s10,
                                                color: isSelected
                                                    ? CommonColors.appBgColor
                                                    : Colors.grey[800],
                                                fontWeight: isSelected
                                                    ? FontWeight.w500
                                                    : FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Footer
                Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: Colors.grey[200]!),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            setModalState(() {
                              tempSelectedFilters.clear();
                            });
                            setState(() {
                              selectedFilters.clear();
                              shortcutSelections.clear();
                            });
                            widget.onFiltersChanged([]);
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 1.8.h),
                          ),
                          child: Text(
                            'Clear Filters',
                            style: GoogleFonts.poppins(
                              fontSize: FontSize.s11,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              selectedFilters = List.from(tempSelectedFilters);
                              for (final category in filterCategories) {
                                final found = category.options.firstWhere(
                                    (o) => selectedFilters.contains(o),
                                    orElse: () => '');
                                shortcutSelections[category.title] =
                                    found.isNotEmpty ? found : null;
                              }
                            });
                            widget.onFiltersChanged(selectedFilters);
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 1.8.h),
                            backgroundColor: CommonColors.appBgColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Apply',
                            style: GoogleFonts.poppins(
                              fontSize: FontSize.s11,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<FilterCategory> shortcutCats = shortcutTitles
        .map((title) => filterCategories.firstWhere((c) => c.title == title))
        .toList();

    return Container(
      height: 6.h,
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints:
              BoxConstraints(minWidth: MediaQuery.of(context).size.width),
          child: IntrinsicWidth(
            child: Row(
              children: [
                CommonFilterButton(
                  text: 'Filter',
                  svgPath: CommonImages.filter,
                  onPressed: () => _showFilterBottomSheet(),
                  showDropdownIcon: false,
                  height: 4.h,
                ),
                SizedBox(width: 2.w),
                ...shortcutCats.map((cat) {
                  final selected = shortcutSelections[cat.title];
                  return Padding(
                    padding: EdgeInsets.only(right: 2.w),
                    child: InkWell(
                      onTap: () => _showFilterBottomSheet(cat.title),
                      child: Container(
                        height: 5.h,
                        padding: EdgeInsets.symmetric(horizontal: 2.w),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(2.w),
                        ),
                        child: Row(
                          children: [
                            SvgPicture.asset(cat.svgPath,
                                colorFilter: ColorFilter.mode(
                                    CommonColors.blackColor, BlendMode.srcIn),
                                height: 5.w,
                                width: 5.w),
                            SizedBox(width: 1.w),
                            Text(
                              selected ?? cat.title,
                              textScaler: const TextScaler.linear(1.0),
                              style: GoogleFonts.poppins(
                                color: CommonColors.blackColor,
                                fontSize: FontSize.s10,
                              ),
                            ),
                            SizedBox(width: 1.w),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
