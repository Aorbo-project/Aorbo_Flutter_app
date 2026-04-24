import 'package:freezed_annotation/freezed_annotation.dart';

import '../utils/common_colors.dart';
part 'know_more_data.freezed.dart';
part 'know_more_data.g.dart';

@freezed
class WhatsNewDataResponseModel with _$WhatsNewDataResponseModel {
  const factory WhatsNewDataResponseModel({
    bool? success,
    String? message,
    List<KnowMoreData>? data,
    int? count
  }) = _WhatsNewDataResponseModel;

  factory WhatsNewDataResponseModel.fromJson(Map<String, dynamic> json) => _$WhatsNewDataResponseModelFromJson(json);
}

@freezed
class KnowMoreData with _$KnowMoreData {
  const factory KnowMoreData({
    String? title,
    String? subtitle,
    String? imagePath,
    bool? hasKnowMore,
    List<String>? customGradient,
    String? textColor,
    String? detailedTitle,
    String? detailedDescription,
    List<BulletPointModel>? bulletPoints,
    String? callToAction,
  }) = _KnowMoreData;

  factory KnowMoreData.fromJson(Map<String, dynamic> json) => _$KnowMoreDataFromJson(json);

  static KnowMoreData get dummy => KnowMoreData(
    title: "New Feature",
    subtitle: "Check out what's new",
    imagePath: "assets/images/sample.png",
    hasKnowMore: true,
    customGradient: ["#FF5733", "#FFC300"],
    textColor: "#FFFFFF",
    detailedTitle: "Amazing Update",
    detailedDescription:
    "We’ve introduced new features to improve your experience.",
    bulletPoints: [
      BulletPointModel(
        title: "Fast",
        description: "Experience faster performance",
      ),
      BulletPointModel(
        title: "Secure",
        description: "Improved security features",
      ),
    ],
    callToAction: "Explore Now",
  );

}

@freezed
class BulletPointModel with _$BulletPointModel {
  const factory BulletPointModel({
    String? title,
    String? description
  }) = _BulletPointModel;

  factory BulletPointModel.fromJson(Map<String, dynamic> json) => _$BulletPointModelFromJson(json);
}



final List<Map<String, dynamic>> knowMoreCardsData = [
  {
    'title': 'Variety of Treks',
    'subtitle':
        'From Serene trails to thrilling climbs, find treks that match your vibes !',
    'imagePath': 'assets/images/img/knowmore1.png',
    'detailedTitle': 'Discover Trekking with Aorbo Treks',
    'detailedDescription':
        'Adventure is closer than you think—Trekking for everyone, at prices you won\'t believe! Trekking isn\'t just for mountain experts—it\'s for YOU! Whether you\'re completely new or have heard of trekking but didn\'t know where to start, Aorbo Treks is here to show you just how easy and affordable it is.',
    'bulletPoints': [
      {
        'title': 'Not Just for Pros',
        'description':
            'Whether it\'s a peaceful forest walk or a riverside adventure, trekking is for everyone, no experience required!'
      },
      {
        'title': 'Affordable Adventure',
        'description':
            'Trekking doesn\'t have to be expensive. Find amazing treks at prices you can actually afford.'
      },
      {
        'title': 'Forget the Crowds',
        'description':
            'Skip the tourist traps and explore hidden gems by foot—nature is waiting.'
      },
      {
        'title': 'Meet New People',
        'description':
            'Join fellow adventurers and share unforgettable moments along the way.'
      },
      {
        'title': 'Freedom to Explore',
        'description':
            'Trekking lets you experience nature on your terms, without breaking the bank.'
      }
    ],
    'callToAction':
        'Ready to start your adventure? With Aorbo Treks, it\'s simple:\n• Easy booking\n• Treks for every budget\n• Free cancellations for your peace of mind'
  }
];
