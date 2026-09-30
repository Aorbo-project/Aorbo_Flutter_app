import 'package:flutter/material.dart';

import '../legal/legal_documents.dart';
import '../utils/common_images.dart';

class AboutUsData {
  final String title;
  final String welcomeText;
  final String imagePath;
  final List<AboutUsSection> sections;
  final List<ExpandableLink> links;

  AboutUsData({
    required this.title,
    required this.welcomeText,
    required this.imagePath,
    required this.sections,
    required this.links,
  });
}

class AboutUsSection {
  final String title;
  final String content;

  AboutUsSection({
    required this.title,
    required this.content,
  });
}

class ExpandableLink {
  final String title;
  final String content;
  final VoidCallback? onTap;

  /// Set for a legal document (server key, e.g. 'terms'): the row opens the
  /// website's current page instead of expanding in-app text, so the app
  /// never shows a copy that can drift from the real one.
  final String? legalDocKey;

  ExpandableLink({
    required this.title,
    this.content = '',
    this.onTap,
    this.legalDocKey,
  });
}

// Static data
final aboutUsData = AboutUsData(
  title: 'Discover, Explore, and Conquer the Outdoors',
  welcomeText:
      'Welcome to "Aorbo Treks", your ultimate companion for trekking adventures! Whether you\'re seasoned hiker or a beginner looking to explore nature\'s beauty, we\'re here to guide you every step of the way.',
  imagePath: CommonImages.aboutUs,
  sections: [
    AboutUsSection(
      title: 'Our Mission',
      content:
          'We aim to bridge the Gap between Adventurers and Trusted Trekking Companies.\n\nTo empower adventurers weekly with easy access to credible trekking companies, while giving vendors a powerful way to connect with potential customers.',
    ),
    AboutUsSection(
      title: 'Our Story',
      content:
          'We have identified a crucial gap in the market, one that lies between customers seeking memorable trekking experiences and the trusted vendors who can deliver them. "Aorbo Treks" is the innovative solution designed to address the trust issues, the lack of transparency, and the challenges faced by both trekkers and companies.',
    ),
    AboutUsSection(
      title: 'Join Our Journey',
      content:
          'Whether you\'re hiking a local trail or conquering a mountain peak, "Aorbo Treks" is your trusted partner for planning and inspiration. Let\'s make every step count.',
    ),
    AboutUsSection(
      title: 'Call to Action',
      content:
          'Start your adventure today!\nExplore Trails Now or Join Our Community',
    ),
  ],
  links: [
    // Legal documents open the website's current version (lib/legal/) — the
    // in-app copies that used to live here could contradict the real ones.
    ExpandableLink(
      title: 'Terms and Conditions',
      legalDocKey: LegalDocKeys.terms,
    ),
    ExpandableLink(
      title: 'User Agreement',
      legalDocKey: LegalDocKeys.userAgreement,
    ),
    ExpandableLink(
      title: 'Organiser Verification',
      content: '''
1. Before an organiser can list treks
- Identity verification (PAN and ID proof)
- Business registration documents
- Bank account verification

2. Before a trek goes live
- Every trek listing is reviewed by the Aorbo team

3. After your trek
- Reviews come only from travellers who booked and completed the trek
      ''',
    ),
    ExpandableLink(
      title: 'Blogs',
      content: '''
1. Latest Posts
- Trek experiences
- Safety tips
- Equipment reviews
- Nature photography

2. Featured Content
- Expert advice
- Seasonal recommendations
- Community stories

3. Contribution Guidelines
- Writing standards
- Photo submission
- Content sharing policies
      ''',
    ),
  ],
);
