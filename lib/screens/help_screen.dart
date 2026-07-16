import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import '../repository/faq_repository.dart';

import '../utils/common_btn.dart';
import '../utils/common_colors.dart';
import '../utils/screen_constants.dart';

// ─────────────────────────────────────────────
//  DESIGN TOKENS  (matches app-wide pattern)
// ─────────────────────────────────────────────
class _C {
  static const bg = CommonColors.whiteColor;
  static const cardBg = CommonColors.whiteColor;
  static const ink = CommonColors.blackColor;
  static const inkMid = CommonColors.cFF6B7280;
  static const inkLight = CommonColors.grey_AEAEAE;
  static const teal = CommonColors.cFF0F7B6C;
  static const tealSoft = CommonColors.cFFE6F5F3;
  static const iconBadgeBg = CommonColors.cFF111827; // dark black badge
  static const divider = CommonColors.cFFF3F4F6;
  static const shadow = CommonColors.c0A000000;
}

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _NC {
  static const ink = Color(0xFF0F172A);
}

class _HelpScreenState extends State<HelpScreen>
    with SingleTickerProviderStateMixin {
  // ── Same data + state as original ──────────
  List<Map<String, dynamic>> faqList = [
    {
      'question': 'How do I know if a trek organizer is trustworthy?',
      'answer':
          'We carefully vet every trek organizer on Aorbo Treks to ensure they meet our high standards of safety, reliability, and quality service. 🌟 Your adventure and trust are our priorities!',
    },
    {
      'question': 'Will you arrange the stays during the trek?',
      'answer':
          'All our treks include certified guides, first-aid kits, and 24/7 emergency support.',
    },
    {
      'question': 'Can I customize my trek itinerary?',
      'answer':
          'Yes, cancellation and rescheduling are allowed up to 48 hours before departure.',
    },
  ];

  List<bool> expandedList = [];
  List<String?> _faqReactions = [];
  bool _isLoadingFaqs = false;

  // Fade-in animation on load
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    expandedList = List<bool>.filled(faqList.length, false);
    _faqReactions = List<String?>.filled(faqList.length, null);

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

    _loadFaqs();
  }

  Future<void> _loadFaqs() async {
    setState(() {
      _isLoadingFaqs = true;
    });
    try {
      final categories = await FaqRepository().fetchCustomerFaqs();
      if (categories.isNotEmpty) {
        final List<Map<String, dynamic>> loadedFaqs = [];
        for (var cat in categories) {
          final faqs = cat['faqs'] as List<dynamic>;
          for (var faq in faqs) {
            final bool isActive = faq['is_active'] ?? true;
            if (!isActive) continue;

            final List<String> tags = [];
            final rawTags = faq['tag'] ?? faq['tags'];
            if (rawTags is List) {
              for (var t in rawTags) {
                if (t != null) {
                  tags.add(t.toString());
                }
              }
            }

            loadedFaqs.add({
              'question': faq['question'] ?? '',
              'answer': faq['answer'] ?? '',
              'chat_support': faq['chat_support'] ?? false,
              'tags': tags,
            });
          }
        }
        if (mounted && loadedFaqs.isNotEmpty) {
          setState(() {
            faqList = loadedFaqs;
            expandedList = List<bool>.filled(faqList.length, false);
            _faqReactions = List<String?>.filled(faqList.length, null);
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading FAQs in HelpScreen: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingFaqs = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          // Light blue header strip
          Container(
            height: 8.h,
            // color: CommonColors.lightBlueColor3.withValues(alpha: 0.2),
          ),

          FadeTransition(
            opacity: _fade,
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 5.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 2.h),

                    // ── Page header card ──────────────────
                    _buildHeaderCard(),

                    SizedBox(height: 2.h),

                    // ── FAQ section label ─────────────────
                    _buildSectionLabel('FREQUENTLY ASKED QUESTIONS'),
                    SizedBox(height: 1.h),

                    // ── FAQ tiles ─────────────────────────
                    ...faqList.asMap().entries.map(
                      (entry) => _buildFaqTile(entry.key, entry.value),
                    ),

                    SizedBox(height: 3.h),

                    // ── Still need help card ──────────────
                    SizedBox(height: 5.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  APP BAR  — matches all other screens
  // ─────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: CommonColors.whiteColor.withValues(alpha: 0.2),
      scrolledUnderElevation: 0,
      elevation: 0,
      automaticallyImplyLeading: true,
      centerTitle: true,
      iconTheme: const IconThemeData(color: _C.ink),
      title: Text(
        'Help',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: FontSize.s15,
          fontWeight: FontWeight.w700,
          color: _NC.ink,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  HEADER CARD
  //  Black icon badge + title + subtitle
  // ─────────────────────────────────────────────
  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(5.w),
        boxShadow: [
          BoxShadow(
            color: CommonColors.blackColor.withValues(alpha: 0.08),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Dark black icon badge
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: _C.iconBadgeBg,
              borderRadius: BorderRadius.circular(3.w),
            ),
            child: const Center(
              child: Icon(
                Icons.support_agent_outlined,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How can we help you?',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: FontSize.s13,
                    fontWeight: FontWeight.w600,
                    color: _C.ink,
                  ),
                ),
                SizedBox(height: 0.4.h),
                Text(
                  'Browse our FAQs or chat with our support team.',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: FontSize.s9,
                    color: _C.inkMid,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  SECTION LABEL  — matches MyAccount pattern
  // ─────────────────────────────────────────────
  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontFamily: 'Poppins',
        fontSize: FontSize.s8,
        fontWeight: FontWeight.w600,
        color: _C.inkMid,
        letterSpacing: 1.2,
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  FAQ TILE
  //  Custom animated tile — same logic as original
  //  (accordion: only one open at a time)
  //  Upgraded: smooth arrow rotation, teal left
  //  border on expanded content, thumb reaction
  // ─────────────────────────────────────────────
  Widget _buildFaqTile(int index, Map<String, dynamic> faq) {
    final bool isOpen = expandedList[index];

    return Container(
      margin: EdgeInsets.only(bottom: 1.5.h),
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(4.w),
        border: Border.all(
          color: isOpen ? _C.ink.withValues(alpha: 0.3) : _C.divider,
          width: isOpen ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: CommonColors.blackColor.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Question row ──
          InkWell(
            onTap: () {
              setState(() {
                // Same accordion logic as original
                for (int i = 0; i < expandedList.length; i++) {
                  expandedList[i] = false;
                }
                expandedList[index] = !isOpen;
              });
            },
            borderRadius: BorderRadius.circular(4.w),
            splashColor: _C.ink.withValues(alpha: 0.05),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
              child: Row(
                children: [
                  // Question number badge
                  Container(
                    width: 7.w,
                    height: 7.w,
                    decoration: BoxDecoration(
                      color: isOpen ? _C.ink : _C.iconBadgeBg,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: FontSize.s9,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      faq['question'],
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        fontSize: FontSize.s10,
                        color: _C.ink,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  // Animated arrow
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 250),
                    turns: isOpen ? 0.5 : 0,
                    child: Container(
                      width: 7.w,
                      height: 7.w,
                      decoration: BoxDecoration(
                        color: isOpen ? _C.ink : CommonColors.cFFF3F4F6,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 5.w,
                        color: isOpen ? _C.tealSoft : _C.inkMid,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Answer (expands when open) ──
          if (isOpen)
            Container(
              margin: EdgeInsets.fromLTRB(4.w, 0, 4.w, 2.h),
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: CommonColors.cFFF9F9F7,
                borderRadius: BorderRadius.circular(3.w),
                border: const Border(left: BorderSide(color: _C.ink, width: 3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Answer text with Markdown support
                  MarkdownText(
                    text: faq['answer'],
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: FontSize.s10,
                      color: _C.inkMid,
                      height: 1.6,
                    ),
                  ),

                  // Tags display
                  if (faq['tags'] != null && (faq['tags'] as List).isNotEmpty) ...[
                    SizedBox(height: 1.5.h),
                    Wrap(
                      spacing: 1.5.w,
                      runSpacing: 1.h,
                      children: (faq['tags'] as List).map<Widget>((tag) {
                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                          decoration: BoxDecoration(
                            color: CommonColors.cFFF3F4F6,
                            borderRadius: BorderRadius.circular(1.w),
                          ),
                          child: Text(
                            '#$tag',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: FontSize.s8,
                              color: _C.inkMid,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  SizedBox(height: 2.h),
                  // ── "Is this useful?" reaction ──
                  SizedBox(height: 1.2.h),

                  Row(
                    children: [
                      // Yes button
                      _buildReactionBtn(
                        index: index,
                        type: 'yes',
                        icon: Icons.thumb_up_rounded,
                        label: 'Yes',
                        activeColor: CommonColors.materialGreen,
                      ),
                      SizedBox(width: 3.w),
                      // No button
                      _buildReactionBtn(
                        index: index,
                        type: 'no',
                        icon: Icons.thumb_down_rounded,
                        label: 'No',
                        activeColor: CommonColors.materialRed,
                      ),
                    ],
                  ),

                  // Chat with us — only shows when No is tapped AND chat_support is enabled
                  if (_faqReactions[index] == 'no' && faq['chat_support'] == true) ...[
                    SizedBox(height: 1.5.h),
                    CommonButton(
                      fontSize: FontSize.s11,
                      width: 43.w,
                      isFullWidth: false,
                      textColor: CommonColors.whiteColor,
                      fontFamily: 'Poppins',
                      text: 'Contact us',
                      onPressed: () => Get.toNamed('/chatboat', arguments: {'mode': 'liveChat'}),
                      gradient: CommonColors.filterGradient,
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  REACTION BUTTON  (Yes / No thumb)
  // ─────────────────────────────────────────────
  Widget _buildReactionBtn({
    required int index,
    required String type,
    required IconData icon,
    required String label,
    required Color activeColor,
  }) {
    final bool isActive = _faqReactions[index] == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          // Same toggle logic as original
          _faqReactions[index] = _faqReactions[index] == type ? null : type;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: isActive
              ? activeColor.withValues(alpha: 0.1)
              : CommonColors.cFFF3F4F6,
          borderRadius: BorderRadius.circular(2.w),
          border: Border.all(
            color: isActive ? activeColor : _C.divider,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 4.5.w,
              color: isActive ? activeColor : _C.inkLight,
            ),
            SizedBox(width: 1.5.w),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: FontSize.s10,
                fontWeight: FontWeight.w500,
                color: isActive ? activeColor : _C.inkMid,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  STILL NEED HELP CARDr
  //  Teal gradient CTA — matches footer pattern
  //  from AboutUsScreen
  // ─────────────────────────────────────────────
  Widget _buildStillNeedHelpCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 2.5.h, horizontal: 5.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_C.ink, CommonColors.cFF1AA090],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(5.w),
        boxShadow: [
          BoxShadow(
            color: _C.ink.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Still need help?',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: FontSize.s13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 0.4.h),
                Text(
                  'Our support team is available 24/7',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: FontSize.s9,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Get.toNamed('/chatboat'),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(3.w),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: Text(
                'Chat now',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: FontSize.s10,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MarkdownText extends StatelessWidget {
  final String text;
  final TextStyle style;

  const MarkdownText({
    super.key,
    required this.text,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> lines = text.split('\n');
    final List<Widget> children = [];

    for (var line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) {
        children.add(SizedBox(height: 1.h));
        continue;
      }

      if (trimmed.startsWith('# ')) {
        children.add(Padding(
          padding: EdgeInsets.only(top: 1.h, bottom: 0.5.h),
          child: Text(
            trimmed.substring(2),
            style: style.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: style.fontSize! * 1.3,
            ),
          ),
        ));
      } else if (trimmed.startsWith('## ')) {
        children.add(Padding(
          padding: EdgeInsets.only(top: 1.h, bottom: 0.5.h),
          child: Text(
            trimmed.substring(3),
            style: style.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: style.fontSize! * 1.15,
            ),
          ),
        ));
      } else if (trimmed.startsWith('### ')) {
        children.add(Padding(
          padding: EdgeInsets.only(top: 0.8.h, bottom: 0.4.h),
          child: Text(
            trimmed.substring(4),
            style: style.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: style.fontSize! * 1.05,
            ),
          ),
        ));
      } else if (trimmed.startsWith('* ') || trimmed.startsWith('- ')) {
        children.add(Padding(
          padding: EdgeInsets.only(left: 2.w, top: 0.4.h, bottom: 0.4.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("• ", style: style.copyWith(fontWeight: FontWeight.bold)),
              Expanded(
                child: _buildRichText(trimmed.substring(2)),
              ),
            ],
          ),
        ));
      } else {
        children.add(Padding(
          padding: EdgeInsets.only(bottom: 0.8.h),
          child: _buildRichText(trimmed),
        ));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _buildRichText(String rawText) {
    final List<InlineSpan> spans = [];
    final RegExp regex = RegExp(r'(\*\*.*?\*\*|\*.*?\*|`.*?`)');
    
    int lastIndex = 0;
    final matches = regex.allMatches(rawText);

    for (var match in matches) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: rawText.substring(lastIndex, match.start),
          style: style,
        ));
      }

      final matchedStr = match.group(0)!;
      if (matchedStr.startsWith('**') && matchedStr.endsWith('**')) {
        spans.add(TextSpan(
          text: matchedStr.substring(2, matchedStr.length - 2),
          style: style.copyWith(fontWeight: FontWeight.bold),
        ));
      } else if (matchedStr.startsWith('*') && matchedStr.endsWith('*')) {
        spans.add(TextSpan(
          text: matchedStr.substring(1, matchedStr.length - 1),
          style: style.copyWith(fontStyle: FontStyle.italic),
        ));
      } else if (matchedStr.startsWith('`') && matchedStr.endsWith('`')) {
        spans.add(TextSpan(
          text: matchedStr.substring(1, matchedStr.length - 1),
          style: style.copyWith(
            fontFamily: 'Poppins',
            backgroundColor: Colors.grey.withValues(alpha: 0.1),
          ),
        ));
      }

      lastIndex = match.end;
    }

    if (lastIndex < rawText.length) {
      spans.add(TextSpan(
        text: rawText.substring(lastIndex),
        style: style,
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }
}
