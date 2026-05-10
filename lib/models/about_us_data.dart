import 'package:flutter/material.dart';

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

  ExpandableLink({
    required this.title,
    required this.content,
    this.onTap,
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
    ExpandableLink(
      title: 'Terms and Conditions',
      content: '''
1. Acceptance of Terms
By accessing and using Aorbo Treks, you agree to be bound by these terms.

2. User Responsibilities
- Provide accurate information
- Maintain account security
- Follow trekking guidelines and safety protocols

3. Booking and Cancellation
- Clear booking procedures
- Transparent cancellation policies
- Refund terms and conditions

4. Safety Guidelines
- Follow trek leader instructions
- Use recommended equipment
- Adhere to safety protocols
      ''',
    ),
    ExpandableLink(
      title: 'User Agreement',
      content: '''
1. Account Creation and Management
- One account per user
- Accurate information required
- Account security responsibilities

2. User Conduct
- Respectful communication
- Honest reviews and feedback
- No misuse of platform

3. Privacy and Data
- Data collection practices
- Information usage
- User privacy rights
      ''',
    ),
    ExpandableLink(
      title: 'Licenses',
      content: '''
1. Trek Operator Licenses
- Verified operators
- Valid permits and certifications
- Regular compliance checks

2. Guide Certifications
- Professional qualifications
- Safety training
- First aid certification

3. Equipment Standards
- Quality assurance
- Regular maintenance
- Safety compliance
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
