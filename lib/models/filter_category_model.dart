import 'package:arobo_app/utils/common_images.dart';

class FilterCategory {
  final String title;
  final String svgPath;
  final List<FilterOptionModel> options;
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
    List<FilterOptionModel>? options,
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

class FilterOptionModel {
  final String title;
  final String query;

  FilterOptionModel({
    required this.title,
    required this.query
  });

}



final List<FilterCategory> filterCategories = [
  FilterCategory(
    title: 'Sort',
    svgPath: CommonImages.sort,
    options: [
      FilterOptionModel(
        title: 'Relevance',
        query: ""
      ),
      FilterOptionModel(
          title: 'Price ~ Low to high',
          query: "sort_by=base_price&sort_order=ASC"
      ),
      FilterOptionModel(
          title: 'Price ~ High to low',
          query: "sort_by=base_price&sort_order=DESC"
      ),
      FilterOptionModel(
          title: 'Newest on Top',
          query: ""
      ),
      FilterOptionModel(
          title: 'Female-Exclusive',
          query: ""
      )
      ,
      FilterOptionModel(
          title: 'High Rated Treks',
          query: ""
      )
    ],
  ),
  FilterCategory(
    title: 'Duration',
    svgPath: CommonImages.duration,
    options: [
      FilterOptionModel(
          title: '2D/1N',
          query: "duration_days=2"
      ),
      FilterOptionModel(
          title: '3D/2N',
          query: "duration_days=3"
      ),
      FilterOptionModel(
          title: '4D/3N',
          query: "duration_days=4"
      ),
      FilterOptionModel(
          title: '5D/4N',
          query: "duration_days=5"
      ),
      FilterOptionModel(
          title: '6D/5N',
          query: "duration_days6"
      ),
      FilterOptionModel(
          title: 'More',
          query: ""
      ),
    ],
  ),
  FilterCategory(
    title: 'Offers',
    svgPath: CommonImages.discount,
    options: [
      FilterOptionModel(
          title: 'Special Offers',
          query: ""
      ),
      FilterOptionModel(
          title: 'Early Bird',
          query: ""
      ),
      FilterOptionModel(
          title: 'Last Minute Deals',
          query: ""
      ),
      FilterOptionModel(
          title: 'Exclusive Deals',
          query: ""
      )
    ],
  ),
  FilterCategory(
    title: 'Solo-Traveller',
    svgPath: CommonImages.solo,
    options: [ FilterOptionModel(
        title: 'Solo Friendly',
        query: ""
    ), FilterOptionModel(
        title: 'Solo - Traveller',
        query: ""
    ), FilterOptionModel(
        title: 'Solo - Female Traveller',
        query: ""
    )],
  ),
  FilterCategory(
    title: 'High Rated Treks',
    svgPath: CommonImages.stars,
    options: [ FilterOptionModel(
        title: '4+ Rated',
        query: ""
    ), FilterOptionModel(
        title: '3+ Rated',
        query: ""
    )],
  ),
];
