import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/common_btn.dart';
import '../utils/common_colors.dart';
import '../utils/screen_constants.dart';

// ─────────────────────────────────────────────
//  DESIGN TOKENS  (matches Help screen)
// ─────────────────────────────────────────────
class _C {
  static const bg = CommonColors.whiteColor;
  static const cardBg = CommonColors.whiteColor;
  static const ink = CommonColors.blackColor;
  static const inkMid = CommonColors.cFF6B7280;
  static const inkLight = CommonColors.grey_AEAEAE;
  static const teal = CommonColors.cFF0F7B6C;
  static const tealSoft = CommonColors.cFFE6F5F3;
  static const iconBadgeBg = CommonColors.cFF111827;
  static const divider = CommonColors.cFFF3F4F6;
}

class _NC {
  static const ink = Color(0xFF0F172A);
}

class ContactSupportScreen extends StatefulWidget {
  const ContactSupportScreen({super.key});

  @override
  State<ContactSupportScreen> createState() => _ContactSupportScreenState();
}

class _ContactSupportScreenState extends State<ContactSupportScreen>
    with TickerProviderStateMixin {
  // ── Form controllers ──
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _subjectCtrl = TextEditingController();
  final TextEditingController _messageCtrl = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // ── Support topic selection ──
  final List<Map<String, dynamic>> _topics = [
    {'icon': Icons.event_outlined, 'label': 'Booking Issue'},
    {'icon': Icons.payments_outlined, 'label': 'Payment'},
    {'icon': Icons.hiking_outlined, 'label': 'Trek Query'},
    {'icon': Icons.help_outline_rounded, 'label': 'Other'},
  ];
  int? _selectedTopic;

  // ── Animations ──
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  // Staggered card animations
  late final List<AnimationController> _cardCtrls;
  late final List<Animation<double>> _cardFades;
  late final List<Animation<Offset>> _cardSlides;

  static const String _supportEmail = 'support@aorbotreks.com';

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOutCubic));

    // 4 staggered sections
    _cardCtrls = List.generate(
      4,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 450),
      ),
    );
    _cardFades = _cardCtrls
        .map((c) => CurvedAnimation(parent: c, curve: Curves.easeOut))
        .toList();
    _cardSlides = _cardCtrls
        .map((c) => Tween<Offset>(
              begin: const Offset(0, 0.08),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: c, curve: Curves.easeOutCubic)))
        .toList();

    _fadeCtrl.forward();
    _runStagger();
  }

  Future<void> _runStagger() async {
    for (int i = 0; i < _cardCtrls.length; i++) {
      await Future.delayed(const Duration(milliseconds: 90));
      if (mounted) _cardCtrls[i].forward();
    }
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    for (final c in _cardCtrls) {
      c.dispose();
    }
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _subjectCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  //  Email launcher
  // ─────────────────────────────────────────────
  Future<void> _sendEmail() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTopic == null) {
      _showSnack('Please select a support topic', isError: true);
      return;
    }

    HapticFeedback.lightImpact();

    final topicLabel = _topics[_selectedTopic!]['label'];
    final subject = '[$topicLabel] ${_subjectCtrl.text.trim()}';
    final body =
        'Hello Aorbo Support Team,\n\n${_messageCtrl.text.trim()}\n\n'
        '— — — — — — — — — —\n'
        'Name: ${_nameCtrl.text.trim()}\n'
        'Email: ${_emailCtrl.text.trim()}\n'
        'Topic: $topicLabel';

    final Uri mailUri = Uri(
      scheme: 'mailto',
      path: _supportEmail,
      query: _encodeQuery({'subject': subject, 'body': body}),
    );

    try {
      final launched = await launchUrl(
        mailUri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        _showSnack('No email app found on this device', isError: true);
      }
    } catch (_) {
      _showSnack('Could not open email client', isError: true);
    }
  }

  String _encodeQuery(Map<String, String> params) {
    return params.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  Future<void> _copyEmail() async {
    HapticFeedback.selectionClick();
    await Clipboard.setData(const ClipboardData(text: _supportEmail));
    _showSnack('Email copied to clipboard');
  }

  void _showSnack(String msg, {bool isError = false}) {
    Get.snackbar(
      isError ? 'Error' : 'Success',
      msg,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isError ? CommonColors.materialRed : _C.ink,
      colorText: Colors.white,
      margin: EdgeInsets.all(4.w),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
    );
  }

  // ─────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 2.h),

                  // ── 1. Header card ──
                  _staggered(0, _buildHeaderCard()),
                  SizedBox(height: 2.5.h),

                  // ── 2. Quick contact options ──
                  _staggered(1, _buildSectionLabel('QUICK CONTACT')),
                  SizedBox(height: 1.h),
                  _staggered(1, _buildQuickContactCard()),
                  SizedBox(height: 2.5.h),

                  // ── 3. Topic selector ──
                  _staggered(2, _buildSectionLabel('WHAT DO YOU NEED HELP WITH?')),
                  SizedBox(height: 1.h),
                  _staggered(2, _buildTopicGrid()),
                  SizedBox(height: 2.5.h),

                  // ── 4. Email form ──
                  _staggered(3, _buildSectionLabel('YOUR DETAILS')),
                  SizedBox(height: 1.h),
                  _staggered(3, _buildFormCard()),
                  SizedBox(height: 3.h),

                  // ── Submit button ──
                  _staggered(3, _buildSendButton()),
                  SizedBox(height: 2.h),

                  // ── Response time note ──
                  _staggered(3, _buildResponseNote()),
                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _staggered(int idx, Widget child) {
    return FadeTransition(
      opacity: _cardFades[idx],
      child: SlideTransition(position: _cardSlides[idx], child: child),
    );
  }

  // ─────────────────────────────────────────────
  //  APP BAR
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
        'Contact Support',
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
            color: CommonColors.blackColor.withOpacity(0.08),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: _C.iconBadgeBg,
              borderRadius: BorderRadius.circular(3.w),
            ),
            child: const Center(
              child: Icon(
                Icons.mark_email_unread_outlined,
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
                  'Send us a message',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: FontSize.s13,
                    fontWeight: FontWeight.w600,
                    color: _C.ink,
                  ),
                ),
                SizedBox(height: 0.4.h),
                Text(
                  'Share your concern and our team will get back to you via email.',
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
  //  QUICK CONTACT CARD (email row with copy)
  // ─────────────────────────────────────────────
  Widget _buildQuickContactCard() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(4.w),
        border: Border.all(color: _C.divider),
        boxShadow: [
          BoxShadow(
            color: CommonColors.blackColor.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 11.w,
            height: 11.w,
            decoration: BoxDecoration(
              color: _C.tealSoft,
              borderRadius: BorderRadius.circular(2.5.w),
            ),
            child: Icon(
              Icons.alternate_email_rounded,
              color: _C.teal,
              size: 5.w,
            ),
          ),
          SizedBox(width: 3.5.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Email',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: FontSize.s9,
                    fontWeight: FontWeight.w500,
                    color: _C.inkMid,
                  ),
                ),
                SizedBox(height: 0.3.h),
                Text(
                  _supportEmail,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: FontSize.s11,
                    fontWeight: FontWeight.w600,
                    color: _C.ink,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _copyEmail,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: _C.divider,
                borderRadius: BorderRadius.circular(2.w),
              ),
              child: Row(
                children: [
                  Icon(Icons.copy_rounded, size: 3.5.w, color: _C.ink),
                  SizedBox(width: 1.w),
                  Text(
                    'Copy',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: FontSize.s9,
                      fontWeight: FontWeight.w600,
                      color: _C.ink,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  TOPIC GRID (chips)
  // ─────────────────────────────────────────────
  Widget _buildTopicGrid() {
    return Wrap(
      spacing: 2.5.w,
      runSpacing: 1.5.h,
      children: List.generate(_topics.length, (i) {
        final isSelected = _selectedTopic == i;
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _selectedTopic = i);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            width: 43.w,
            padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 1.6.h),
            decoration: BoxDecoration(
              color: isSelected ? _C.ink : _C.cardBg,
              borderRadius: BorderRadius.circular(3.w),
              border: Border.all(
                color: isSelected ? _C.ink : _C.divider,
                width: isSelected ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? _C.ink.withOpacity(0.15)
                      : CommonColors.blackColor.withOpacity(0.04),
                  blurRadius: isSelected ? 12 : 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  _topics[i]['icon'],
                  size: 5.w,
                  color: isSelected ? Colors.white : _C.ink,
                ),
                SizedBox(width: 2.5.w),
                Expanded(
                  child: Text(
                    _topics[i]['label'],
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: FontSize.s10,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : _C.ink,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ─────────────────────────────────────────────
  //  FORM CARD
  // ─────────────────────────────────────────────
  Widget _buildFormCard() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(4.w),
        border: Border.all(color: _C.divider),
        boxShadow: [
          BoxShadow(
            color: CommonColors.blackColor.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildField(
            controller: _nameCtrl,
            label: 'Full Name',
            hint: 'John Doe',
            icon: Icons.person_outline_rounded,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Name is required' : null,
          ),
          SizedBox(height: 1.8.h),
          _buildField(
            controller: _emailCtrl,
            label: 'Your Email',
            hint: 'you@example.com',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Email is required';
              final emailRegex = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,4}$');
              if (!emailRegex.hasMatch(v.trim())) return 'Enter a valid email';
              return null;
            },
          ),
          SizedBox(height: 1.8.h),
          _buildField(
            controller: _subjectCtrl,
            label: 'Subject',
            hint: 'Brief summary of your issue',
            icon: Icons.subject_rounded,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Subject is required' : null,
          ),
          SizedBox(height: 1.8.h),
          _buildField(
            controller: _messageCtrl,
            label: 'Message',
            hint: 'Describe your concern in detail...',
            icon: Icons.message_outlined,
            maxLines: 5,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Message is required';
              if (v.trim().length < 10) return 'Please provide more detail';
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 1.w, bottom: 0.7.h),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: FontSize.s10,
              fontWeight: FontWeight.w600,
              color: _C.ink,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: FontSize.s10,
            color: _C.ink,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontFamily: 'Poppins',
              fontSize: FontSize.s10,
              color: _C.inkLight,
            ),
            prefixIcon: maxLines == 1
                ? Icon(icon, color: _C.inkMid, size: 5.w)
                : Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Icon(icon, color: _C.inkMid, size: 5.w),
                  ),
            filled: true,
            fillColor: CommonColors.cFFF9F9F7,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.6.h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(3.w),
              borderSide: BorderSide(color: _C.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(3.w),
              borderSide: BorderSide(color: _C.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(3.w),
              borderSide: BorderSide(color: _C.ink, width: 1.4),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(3.w),
              borderSide: const BorderSide(color: CommonColors.materialRed),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(3.w),
              borderSide:
                  const BorderSide(color: CommonColors.materialRed, width: 1.4),
            ),
            errorStyle: TextStyle(
              fontFamily: 'Poppins',
              fontSize: FontSize.s8,
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  //  SEND BUTTON
  // ─────────────────────────────────────────────
  Widget _buildSendButton() {
    return CommonButton(
      fontSize: FontSize.s12,
      width: double.infinity,
      isFullWidth: true,
      textColor: CommonColors.whiteColor,
      fontFamily: 'Poppins',
      text: 'Send Email',
      onPressed: _sendEmail,
      gradient: CommonColors.filterGradient,
    );
  }

  // ─────────────────────────────────────────────
  //  RESPONSE TIME NOTE
  // ─────────────────────────────────────────────
  Widget _buildResponseNote() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        color: _C.tealSoft,
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(color: _C.teal.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.schedule_rounded, color: _C.teal, size: 4.5.w),
          SizedBox(width: 2.5.w),
          Expanded(
            child: Text(
              'Our team typically responds within 24 hours.',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: FontSize.s9,
                color: _C.teal,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
