import 'package:arobo_app/utils/common_colors.dart';
import 'package:arobo_app/utils/common_images.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class DiscountCardModel {
  final String title;
  final String subtitle;
  final Color color;
  final String code;
  final String offerAmount;
  final String imagePath;
  final double? imageHeight;

  // Add detailed content
  final String? detailedDescription;
  final String? howToApply;
  final String? termsAndConditions;
  final String? footerNote;

  DiscountCardModel({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.code,
    required this.offerAmount,
    required this.imagePath,
    this.imageHeight,
    this.detailedDescription,
    this.howToApply,
    this.termsAndConditions,
    this.footerNote,
  });
}

// Example usage:
final List<DiscountCardModel> discountCards = [
  DiscountCardModel(
    title: 'Trips more than 3 Days',
    subtitle: 'Long adventures deserve\ngreat beginnings',
    color: CommonColors.discountCardColor,
    code: 'NEWBONUS',
    offerAmount: '200/-',
    imagePath: CommonImages.firsttrek,
    imageHeight: 12.h,
    detailedDescription:
        'First Trek Special – Get ₹200 OFF! \nStart your trekking journey with Aorbo! Perfect for beginners looking to explore the mountains for the first time. Book your debut adventure and enjoy ₹200 OFF on treks lasting 3 days or more.',
    howToApply:
        'How to Apply:\n• Browse our collection of 3+ day trek packages\n• Select your preferred trek and dates\n• Add participants and proceed to checkout\n• Enter coupon code NEWBONUS in the promo field\n• Enjoy instant ₹200 discount on your first adventure!',
    termsAndConditions:
        'Terms and Conditions:\n• Eligibility: Valid only for first-time trekkers with Aorbo\n• Discount Details: Flat ₹200 off on treks of 3 days or more\n• Validity: Limited period offer, apply during checkout\n• One-Time Use: One coupon per user account\n• Minimum Booking: Valid on bookings above ₹2000\n• Cannot Be Combined: Not valid with other promotional offers\n• Verification: First-time user verification required',
    footerNote:
        'Start Your Trekking Journey Today! \nTake the first step towards adventure. Use NEWBONUS and make your debut trek both memorable and budget-friendly!',
  ),
  DiscountCardModel(
    title: 'Trips more than 3 Days',
    subtitle: 'Invite your buddy and unlock duo-discounts!',
    color: CommonColors.discountCardColor2,
    code: 'TWINTRIP',
    offerAmount: '100/-',
    imagePath: CommonImages.discount2,
    imageHeight: 14.h,
    detailedDescription:
        'Buddy Trek Offer – Get ₹100 OFF Each! \nAdventures are twice the fun with friends! Book together with your buddy and both of you save ₹100 on your individual bookings. Perfect for creating shared memories on the trails.',
    howToApply:
        'How to Apply:\n• Both friends must book the same trek simultaneously\n• Select identical trek dates and package\n• Proceed to checkout for both bookings\n• Enter coupon code TWINTRIP for each booking\n• Both participants receive ₹100 discount instantly!',
    termsAndConditions:
        'Terms and Conditions:\n• Eligibility: Valid for exactly 2 participants booking together\n• Discount Details: ₹100 off per person (₹200 total savings)\n• Validity: Must be applied during simultaneous booking\n• Booking Requirement: Both bookings must be identical\n• Minimum Value: Valid on individual bookings above ₹1500\n• Cannot Be Combined: Not applicable with other offers\n• Verification: Both participants\' details required',
    footerNote:
        'Double the Fun, Double the Savings! \nGrab your adventure buddy and hit the trails together. Use TWINTRIP for amazing duo discounts!',
  ),
  DiscountCardModel(
    title: 'On Group trek booking !',
    subtitle: 'Explore the chilly trails\nwith hot deals!',
    color: CommonColors.discountCardColor3,
    code: 'SNOWGO',
    offerAmount: '250/-',
    imagePath: CommonImages.discount3,
    imageHeight: 12.h,
    detailedDescription:
        'Winter Trek Special – Get ₹250 OFF! \nEmbrace the winter wonderland! Book snow treks and high-altitude adventures during winter season and enjoy ₹250 OFF. Perfect for those seeking snowy peaks and frozen lakes.',
    howToApply:
        'How to Apply:\n• Choose from our winter/snow trek collection\n• Select trek dates during winter season (Dec-Feb)\n• Add all participants to your booking\n• Proceed to checkout and review booking details\n• Enter coupon code SNOWGO in the discount field\n• Receive instant ₹250 off your winter adventure!',
    termsAndConditions:
        'Terms and Conditions:\n• Eligibility: Valid only for winter/snow treks during Dec-Feb\n• Discount Details: Flat ₹250 off on qualifying winter treks\n• Validity: Seasonal offer valid during winter months only\n• Trek Types: Applicable on high-altitude and snow treks only\n• Minimum Booking: Valid on bookings above ₹3000\n• Weather Dependent: Subject to trek availability and weather conditions\n• Cannot Be Combined: Not valid with other seasonal offers',
    footerNote:
        'Conquer the Winter Mountains! \nDon\'t let the cold stop your adventures. Use SNOWGO and experience the magic of winter trekking!',
  ),
  DiscountCardModel(
    title: 'Pocket-friendly escapes !',
    subtitle: 'Avoid the weekend rush,\ntravel midweek & save!',
    color: CommonColors.discountCardColor4,
    code: 'TREONOMY',
    offerAmount: '125/-',
    imagePath: CommonImages.discount4,
    imageHeight: 12.h,
    detailedDescription:
        'Weekday Explorer – Get ₹125 OFF! \nBeat the weekend crowds and save money! Book your trek for weekdays (Monday to Thursday) and enjoy peaceful trails with ₹125 discount. Perfect for flexible schedules.',
    howToApply:
        'How to Apply:\n• Browse treks with weekday departure dates\n• Select Monday to Thursday start dates only\n• Choose your preferred weekday trek package\n• Add participants and proceed to payment\n• Enter coupon code TREONOMY at checkout\n• Enjoy ₹125 savings on your peaceful weekday adventure!',
    termsAndConditions:
        'Terms and Conditions:\n• Eligibility: Valid only for Monday-Thursday departures\n• Discount Details: Flat ₹125 off on weekday bookings\n• Validity: Year-round offer for qualifying weekday treks\n• Date Restriction: Not valid for Friday-Sunday departures\n• Minimum Booking: Valid on bookings above ₹1800\n• Availability: Subject to trek schedule and guide availability\n• Cannot Be Combined: Not applicable with weekend offers',
    footerNote:
        'Smart Savings for Smart Travelers! \nChoose weekday adventures for peaceful trails and pocket-friendly prices. Use TREONOMY now!',
  ),
  DiscountCardModel(
    title: 'Chill vibes, epic trails !',
    subtitle: 'You\'ve trekked before?\nHere\'s a thank you!',
    color: CommonColors.discountCardColor5,
    code: 'LOYALSTEP',
    offerAmount: '180/-',
    imagePath: CommonImages.discount5,
    imageHeight: 12.h,
    detailedDescription:
        'Loyal Trekker Reward – Get ₹180 OFF! \nWelcome back, adventure champion! As a returning trekker with Aorbo, enjoy ₹180 OFF on your next expedition. Your loyalty to adventure deserves special rewards.',
    howToApply:
        'How to Apply:\n• Log in to your existing Aorbo account\n• Browse and select your next adventure\n• System automatically detects your previous bookings\n• Proceed to checkout with your selected trek\n• Enter coupon code LOYALSTEP in the promo section\n• Enjoy instant ₹180 loyalty discount!',
    termsAndConditions:
        'Terms and Conditions:\n• Eligibility: Valid only for returning customers with previous bookings\n• Discount Details: Flat ₹180 off for loyal trekkers\n• Validity: Permanent offer for qualifying repeat customers\n• Account Verification: Must use same registered account\n• Minimum Booking: Valid on bookings above ₹2200\n• Usage Limit: Can be used multiple times throughout the year\n• Cannot Be Combined: Not valid with first-timer offers',
    footerNote:
        'Your Adventure Continues! \nThank you for choosing Aorbo again. Use LOYALSTEP and keep exploring new heights with us!',
  ),
  // Add more cards as needed
];
