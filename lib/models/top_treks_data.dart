import 'package:freezed_annotation/freezed_annotation.dart';

import '../utils/common_colors.dart';
import '../utils/common_images.dart';

part 'top_treks_data.freezed.dart';
part 'top_treks_data.g.dart';

@freezed
class TopTreksDataResponseModel with _$TopTreksDataResponseModel {
  const factory TopTreksDataResponseModel({
    bool? success,
    String? message,
    List<TopTreksData>? data,
    int? count
  }) = _TopTreksDataResponseModel;

  factory TopTreksDataResponseModel.fromJson(Map<String, dynamic> json) => _$TopTreksDataResponseModelFromJson(json);
}
@freezed
class TopTreksData with _$TopTreksData {
  const factory TopTreksData({
    String? title,
    String? description,
    String? imagePath,
    List<String>? gradient,
    bool? isFavorite
  }) = _TopTreksData;

  factory TopTreksData.fromJson(Map<String, dynamic> json) => _$TopTreksDataFromJson(json);
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
