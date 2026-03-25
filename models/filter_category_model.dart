import 'package:arobo_app/utils/common_images.dart';

class FilterCategory {
  final String title;
  final String svgPath;
  final List<String> options;
  final bool isSelected;

  FilterCategory({
    required this.title,
    required this.svgPath,
    required this.options,
    this.isSelected = false,
  });

  FilterCategory copyWith({
    String? title,
    String? svgPath,
    List<String>? options,
    bool? isSelected,
  }) {
    return FilterCategory(
      title: title ?? this.title,
      svgPath: svgPath ?? this.svgPath,
      options: options ?? this.options,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

final List<FilterCategory> filterCategories = [
  FilterCategory(
    title: 'Sort',
    svgPath: CommonImages.sort,
    options: [
      'Relevance',
      'Price ~ Low to high',
      'Price ~ High to low',
      'Newest on Top',
      'Female-Exclusive',
      'High Rated Treks',
    ],
  ),
  FilterCategory(
    title: 'Duration',
    svgPath: CommonImages.duration,
    options: [
      '2D/1N',
      '3D/2N',
      '4D/3N',
      '5D/4N',
      '6D/5N',
      'More',
    ],
  ),
  FilterCategory(
    title: 'Offers',
    svgPath: CommonImages.discount,
    options: [
      'Special Offers',
      'Early Bird',
      'Last Minute Deals',
      'Exclusive Deals'
    ],
  ),
  FilterCategory(
    title: 'Solo-Traveller',
    svgPath: CommonImages.solo,
    options: ['Solo Friendly', 'Solo - Traveller', 'Solo - Female Traveller'],
  ),
  FilterCategory(
    title: 'High Rated Treks',
    svgPath: CommonImages.stars,
    options: ['4+ Rated', '3+ Rated'],
  ),
];
