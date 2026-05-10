import 'package:arobo_app/utils/common_colors.dart';
import 'package:arobo_app/utils/common_images.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class DiscountCardModel {
  final String title;
  final String subtitle;
  final List<String>? gradient;
  final String textColour;
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
    required this.gradient,
    required this.textColour,
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
