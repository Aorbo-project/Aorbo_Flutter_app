import 'package:freezed_annotation/freezed_annotation.dart';
import '../utils/common_colors.dart';
import '../utils/common_images.dart';

part 'seasonal_forecast_data.freezed.dart';
part 'seasonal_forecast_data.g.dart';

@freezed
class SeasonalForecastDataResponseModel with _$SeasonalForecastDataResponseModel {
  const factory SeasonalForecastDataResponseModel({
    bool? success,
    String? message,
    List<SeasonalForecastData>? data,
    int? count
  }) = _SeasonalForecastDataResponseModel;

  factory SeasonalForecastDataResponseModel.fromJson(Map<String, dynamic> json) => _$SeasonalForecastDataResponseModelFromJson(json);
}
@freezed
class SeasonalForecastData with _$SeasonalForecastData {
  const factory SeasonalForecastData({
    String? title,
    String? description,
    String? imagePath,
    String? color
  }) = _SeasonalForecastData;

  factory SeasonalForecastData.fromJson(Map<String, dynamic> json) => _$SeasonalForecastDataFromJson(json);
}



final List<Map<String, dynamic>> seasonalForecastData = [
  {
    'title': 'Manali Trek',
    'description':
        'People visit Manali in winter for its snow, adventure sports, and peaceful mountain escape.',
    'imagePath': CommonImages.manali,
    'color': CommonColors.sesonal1,
  },
  {
    'title': 'Chardham’s yatra ',
    'description':
        'The Kedarnath trek is prohibited in winter due to extreme cold, snow and avalanche risks.',
    'imagePath': CommonImages.chardham,
    'color': CommonColors.sesonal2,
  },
  {
    'title': 'Ladakh Trek',
    'description':
        'Ladakh experiences extreme cold in winter, with temperatures dropping below freezing.',
    'imagePath': CommonImages.himalayas,
    'color': CommonColors.appYellowColor,
  },
  {
    'title': 'Ooty Trek',
    'description':
        'People visit Ooty in winter for its cool climate, scenic beauty, and peaceful hill retreat.',
    'imagePath': CommonImages.ooty,
    'color': CommonColors.sesonal3,
  },
  {
    'title': 'Himalayas Trek',
    'description':
        'Kashmir offers thrilling winter adventures but watch out for avalanches and icy terrains safety first !',
    'imagePath': CommonImages.manali,
    'color': CommonColors.sesonal4,
  },
];
