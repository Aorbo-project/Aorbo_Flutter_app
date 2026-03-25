import 'package:arobo_app/utils/common_images.dart';

class ShortsTreksData {
  final String title;
  final String description;
  final String imagePath;

  ShortsTreksData({
    required this.title,
    required this.description,
    required this.imagePath,
  });
}

final List<Map<String, dynamic>> shortsTreksCardsData = [
  {
    'title': 'Lorem ipsum | Sit amet | consectetur adipiscing elit..',
    'description': '24M views',
    'imagePath': CommonImages.shorts1,
  },
  {
    'title': 'Lorem ipsum | Sit amet | consectetur adipiscing elit..',
    'description': '4M views',
    'imagePath': CommonImages.shorts2,
  },
  {
    'title': 'Lorem ipsum | Sit amet | consectetur adipiscing elit..',
    'description': '4M views',
    'imagePath': CommonImages.shorts3,
  },
  {
    'title': 'Lorem ipsum | Sit amet | consectetur adipiscing elit..',
    'description': '2M views',
    'imagePath': CommonImages.shorts4,
  },
  {
    'title': 'Lorem ipsum | Sit amet | consectetur adipiscing elit..',
    'description': '25M views',
    'imagePath': CommonImages.shorts5,
  },
];
