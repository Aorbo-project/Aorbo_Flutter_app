import 'package:arobo_app/utils/common_colors.dart';
import 'package:arobo_app/utils/common_images.dart';

class TopTreksData {
  final String title;
  final String description;
  final String imagePath;
  final bool isFavorite;

  TopTreksData({
    required this.title,
    required this.description,
    required this.imagePath,
    this.isFavorite = false,
  });
}

final List<Map<String, dynamic>> topTreksCardsData = [
  {
    'title': 'Coorg',
    'description':
        'The SCOTLAND of India, offers misty hills, lush coffee plantations & serene waterfalls.',
    'imagePath': CommonImages.coorg,
    'gradient': 'gradientYellow',
    'isFavorite': false,
  },
  {
    'title': 'Gokarna',
    'description':
        "Escape to Gokarna's serene beaches and spiritual charm. A perfect of peace and adventure !",
    'imagePath': CommonImages.gokarna,
    'textColor': CommonColors.whiteColor,
    'gradient': 'gradientTeal',
    'isFavorite': false,
  },
  {
    'title': 'Goa',
    'description':
        "Dive into Goa's beaches, night life and culture. where every moment feels like a celebration.",
    'imagePath': CommonImages.goa,
    'gradient': 'gradientBlue',
    'isFavorite': false,
  },
  {
    'title': 'Munnar',
    'description':
        'The Crown Jewel of Kerala, Captivates with its emerald tea gardens and tranquil waterfalls. A paradise for Nature lovers !',
    'imagePath': CommonImages.munnar,
    'gradient': 'gradientGreen',
    'textColor': CommonColors.whiteColor,
    'isFavorite': false,
  },
  {
    'title': 'Udupi',
    'description':
        'A coastal gem, offers pristine beaches, ancient temples and world famous cuisine. Dive into culture, serenity and unforgettable sunsets !',
    'imagePath': CommonImages.udupi,
    'gradient': 'gradientBlue',
    'isFavorite': false,
  },
];
