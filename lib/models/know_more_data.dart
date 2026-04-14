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
    'customGradient': CommonColors.gradientknowYellow,
    'textColor': CommonColors.blackColor,
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
  },
  {
    'title': 'Countless Organizers',
    'subtitle':
        'Choose from an extensive network of trusted trek organizers, All in one place !',
    'imagePath': 'assets/images/img/knowmore2.png',
    'customGradient': CommonColors.gradientknow2,
    'textColor': CommonColors.whiteColor,
    'detailedTitle': 'Your Gateway to Trusted Trek Organizers',
    'detailedDescription':
        'We\'ve partnered with the best trek organizers across the country to bring you a diverse range of experiences. Each organizer is carefully vetted to ensure your adventure is both safe and memorable.',
    'bulletPoints': [
      {
        'title': 'Verified Organizers',
        'description':
            'Every trek organizer goes through our strict verification process.'
      },
      {
        'title': 'Diverse Experiences',
        'description':
            'From local experts to national operators, find the perfect match for your trek style.'
      },
      {
        'title': 'Quality Assurance',
        'description':
            'Regular quality checks and traveler feedback ensure consistent high standards.'
      },
      {
        'title': 'Direct Communication',
        'description':
            'Connect directly with organizers while booking through our secure platform.'
      }
    ],
    'callToAction': 'Choose your perfect trek organizer today and embark on an unforgettable journey!'
  },
  {
    'title': 'Boundless Adventure',
    'subtitle':
        'Explore confidently with Aorbo Treks, where your safety is our priority.',
    'imagePath': 'assets/images/img/knowmore3.png',
    'customGradient': CommonColors.gradientknow3,
    'textColor': CommonColors.whiteColor,
    'detailedTitle': 'Safety First, Adventure Always',
    'detailedDescription':
        'At Aorbo Treks, we believe that the best adventures are safe adventures. Our comprehensive safety measures ensure you can focus on the experience while we take care of the rest.',
    'bulletPoints': [
      {
        'title': 'Expert Guides',
        'description':
            'Certified guides with extensive local knowledge and safety training.'
      },
      {
        'title': 'Emergency Support',
        'description':
            '24/7 emergency assistance and comprehensive trek insurance coverage.'
      },
      {
        'title': 'Weather Monitoring',
        'description':
            'Real-time weather updates and route adjustments for your safety.'
      },
      {
        'title': 'Quality Equipment',
        'description':
            'Access to high-quality trekking gear and safety equipment.'
      }
    ],
    'callToAction':
        'Your safety is our priority. Trek with confidence knowing you\'re in good hands.'
  },
  {
    'title': 'Free Cancellation',
    'subtitle':
        'Plans changed ? No worries cancel for free before 3 days to the trek.',
    'imagePath': 'assets/images/img/knowmore4.png',
    'customGradient': CommonColors.gradientknow4,
    'textColor': CommonColors.whiteColor,
    'detailedTitle': 'Flexible Booking, Peace of Mind',
    'detailedDescription':
        'Life is unpredictable, and we get that. Our free cancellation policy gives you the flexibility to book with confidence.',
    'bulletPoints': [
      {
        'title': 'Free Cancellation',
        'description':
            'Cancel up to 3 days before your trek starts, no questions asked.'
      },
      {
        'title': 'Easy Refunds',
        'description': 'Get your refund processed quickly and hassle-free.'
      },
      {
        'title': 'Reschedule Option',
        'description':
            'Can\'t make it? Reschedule your trek for a more convenient date.'
      },
      {
        'title': 'Transparent Policy',
        'description':
            'Clear cancellation terms with no hidden charges or conditions.'
      }
    ],
    'callToAction':
        'Book your trek today with the confidence of free cancellation!'
  },
  {
    'title': 'Refer and earn',
    'subtitle':
        'Invite your friends and earn rewards for initial booking they make !',
    'imagePath': 'assets/images/img/knowmore5.png',
    'customGradient': CommonColors.gradientknow5,
    'textColor': CommonColors.whiteColor,
    'detailedTitle': 'Share the Joy of Trekking, Earn Rewards',
    'detailedDescription':
        'Love trekking with us? Spread the word and get rewarded! Our refer-and-earn program makes sharing adventures even more rewarding.',
    'bulletPoints': [
      {
        'title': 'Easy Referrals',
        'description':
            'Share your unique referral code with friends and family in just a few clicks.'
      },
      {
        'title': 'Generous Rewards',
        'description':
            'Earn exciting rewards for every friend who books their first trek.'
      },
      {
        'title': 'Track Progress',
        'description':
            'Monitor your referrals and rewards easily in your account.'
      },
      {
        'title': 'Double Benefits',
        'description':
            'Both you and your friend get special discounts on bookings.'
      }
    ],
    'callToAction':
        'Start referring today and earn rewards while sharing the joy of trekking!'
  },
];
