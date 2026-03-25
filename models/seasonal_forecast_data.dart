import 'package:arobo_app/utils/common_colors.dart';
import 'package:arobo_app/utils/common_images.dart';

class SeasonalForecastData {
  final String title;
  final String description;
  final String imagePath;

  SeasonalForecastData({
    required this.title,
    required this.description,
    required this.imagePath,
  });
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
