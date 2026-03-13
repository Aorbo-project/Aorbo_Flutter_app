import 'package:arobo_app/utils/common_colors.dart';
import 'package:arobo_app/utils/screen_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/filter_category_model.dart';
import 'package:sizer/sizer.dart';

class FilterModal extends StatefulWidget {
  final List<String> selectedFilters;
  final Function(List<String>) onApply;
  final int initialCategoryIndex;

  const FilterModal({
    super.key,
    required this.selectedFilters,
    required this.onApply,
    this.initialCategoryIndex = 0,
  });

  static Future<List<String>?> show(
    BuildContext context,
    List<String> selectedFilters, {
    int initialCategoryIndex = 0,
  }) async {
    return await Navigator.of(context).push<List<String>>(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) => FilterModal(
          selectedFilters: selectedFilters,
          initialCategoryIndex: initialCategoryIndex,
          onApply: (filters) {
            Navigator.pop(context, filters);
          },
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(-1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            )),
            child: child,
          );
        },
      ),
    );
  }

  @override
  State<FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  late List<FilterCategory> categories;
  late int selectedCategoryIndex;
  Map<String, String?> selectedOptionsByCategory = {};

  @override
  void initState() {
    super.initState();
    categories = List.from(filterCategories);
    selectedCategoryIndex = widget.initialCategoryIndex;

    for (var filter in widget.selectedFilters) {
      for (var category in categories) {
        if (category.options.contains(filter)) {
          selectedOptionsByCategory[category.title] = filter;
          break;
        }
      }
    }
  }

  void _selectCategory(int index) {
    setState(() {
      selectedCategoryIndex = index;
    });
  }

  void _selectOption(String categoryTitle, String option) {
    setState(() {
      selectedOptionsByCategory[categoryTitle] = option;
    });
  }

  @override
  Widget build(BuildContext context) {
    final category = categories[selectedCategoryIndex];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Container(
          width: 100.w,
          height: 100.h,
          color: CommonColors.whiteColor,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: CommonColors.whiteColor,
                  boxShadow: [
                    BoxShadow(
                      color: CommonColors.blackColor.withOpacity(0.05),
                      blurRadius: 1.w,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filter',
                      textScaler: const TextScaler.linear(1.0),
                      style: GoogleFonts.poppins(
                        fontSize: FontSize.s15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.close, size: 6.w),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 40.w,
                      color: CommonColors.whiteColor,
                      child: ListView.builder(
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final isSelected = selectedCategoryIndex == index;
                          return InkWell(
                            onTap: () => _selectCategory(index),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? CommonColors.filterGradient
                                    : null,
                              ),
                              padding: EdgeInsets.symmetric(
                                vertical: 1.8.h,
                                horizontal: 4.w,
                              ),
                              child: Row(
                                children: [
                                  SvgPicture.asset(
                                    categories[index].svgPath,
                                    height: 4.5.w,
                                    width: 4.5.w,
                                    colorFilter: ColorFilter.mode(
                                        CommonColors.blackColor,
                                        BlendMode.srcIn),
                                  ),
                                  SizedBox(width: 2.5.w),
                                  Expanded(
                                    child: Text(
                                      categories[index].title,
                                      textScaler: const TextScaler.linear(1.0),
                                      style: GoogleFonts.poppins(
                                        fontSize: FontSize.s10,
                                        fontWeight: isSelected
                                            ? FontWeight.w500
                                            : FontWeight.normal,
                                        color: isSelected
                                            ? CommonColors.whiteColor
                                            : Colors.black,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 4.w,
                                    color: isSelected
                                        ? CommonColors.whiteColor
                                        : Colors.transparent,
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(vertical: 1.h),
                        itemCount: category.options.length,
                        itemBuilder: (context, index) {
                          final option = category.options[index];
                          final isSelected =
                              selectedOptionsByCategory[category.title] ==
                                  option;
                          return ListTile(
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 5.w),
                            title: Text(
                              option,
                              textScaler: const TextScaler.linear(1.0),
                              style: GoogleFonts.poppins(
                                fontSize: FontSize.s11,
                                color: isSelected
                                    ? CommonColors.blueColor
                                    : CommonColors.blackColor,
                                fontWeight: isSelected
                                    ? FontWeight.w500
                                    : FontWeight.normal,
                              ),
                            ),
                            trailing: GestureDetector(
                              onTap: () =>
                                  _selectOption(category.title, option),
                              child: Container(
                                width: 6.w,
                                height: 6.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: isSelected
                                      ? CommonColors.radioBtnGradient
                                      : null,
                                  border: isSelected
                                      ? null
                                      : Border.all(
                                          color: Colors.grey.shade400,
                                          width: 0.5.w),
                                ),
                                child: isSelected
                                    ? Center(
                                        child: Container(
                                          width: 2.w,
                                          height: 2.w,
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ),
                            onTap: () => _selectOption(category.title, option),
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: CommonColors.whiteColor,
                  boxShadow: [
                    BoxShadow(
                      color: CommonColors.blackColor.withValues(alpha: 0.05),
                      blurRadius: 1.w,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final selectedFilters = selectedOptionsByCategory.values
                          .where((option) => option != null)
                          .map((option) => option!)
                          .toList();
                      widget.onApply(selectedFilters);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 1.8.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(2.w),
                      ),
                    ),
                    child: Text(
                      'Apply',
                      textScaler: const TextScaler.linear(1.0),
                      style: GoogleFonts.poppins(
                        fontSize: FontSize.s12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
