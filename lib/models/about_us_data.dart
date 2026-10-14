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

  /// Set for a page on the website: the row opens it in the browser.
  final String? url;

  ExpandableLink({
    required this.title,
    this.content = '',
    this.onTap,
    this.legalDocKey,
    this.url,
  });
}

// Static data
final aboutUsData = AboutUsData(
  title: 'Discover, Explore, and Conquer the Outdoors',
  welcomeText:
      'Welcome to Aorbo Treks, the place to find and book treks run by verified trek organisers. Whether you\'re a seasoned hiker or a beginner looking to explore nature\'s beauty, we help you compare treks and book with confidence.',
  imagePath: CommonImages.aboutUs,
  sections: [
    AboutUsSection(
      title: 'Our Mission',
      content:
          'We aim to bridge the gap between adventurers and trusted trek organisers.\n\nWe give adventurers easy access to verified trek organisers, and give organisers a simple way to reach the people looking for their treks.',
    ),
    AboutUsSection(
      title: 'Our Story',
      content:
          'We saw a gap between people looking for memorable treks and the trusted organisers who can deliver them. Aorbo Treks was built to fix the trust issues and the lack of transparency that both trekkers and organisers face.',
    ),
    AboutUsSection(
      title: 'Join Our Journey',
      content:
          'Whether you\'re hiking a local trail or conquering a mountain peak, Aorbo Treks helps you find the right trek and the right organiser. Let\'s make every step count.',
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
- PAN and ID proof
- Bank details, checked against a cancelled cheque
- Business documents such as GST or MSME certificates, where the organiser has them
- Every organiser is reviewed and approved by the Aorbo team

2. Before a trek goes live
- Every trek listing is reviewed by the Aorbo team

3. After your trek
- Reviews come only from travellers who booked the trek, after the trek has ended
      ''',
    ),
    // Opens the real blog on the website (the in-app text was a placeholder
    // outline of features that don't exist).
    ExpandableLink(
      title: 'Blogs',
      url: 'https://www.aorbotreks.com/blogs',
    ),
  ],
);
