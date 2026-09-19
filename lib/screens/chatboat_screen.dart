import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controller/trek_controller.dart';
import '../controller/user_controller.dart';
import '../freezed_models/booking/cancellation_data_model.dart';
import '../models/refund/refund_status_model.dart';
import '../utils/common_booked_card.dart';
import '../utils/screen_constants.dart';
import '../repository/network_url.dart';
import '../repository/repository.dart';
import '../freezed_models/booking/booking_history_model.dart';
import 'package:arobo_app/theme/app_tokens.dart';
import 'package:arobo_app/theme/app_typography.dart';

// Support-request email — same address used by ContactSupportScreen and the
// v1 issue-submission backend's staff alert. No live team to staff a real
// support chat (2026-09-15 decision), so this is the escalation path.
const String _supportEmail = 'care@aorbotreks.com';

class Message {
  final String text;
  final bool isBot;
  final MessageType type;
  final DateTime timestamp;

  Message({
    required this.text,
    required this.isBot,
    required this.type,
    required this.timestamp,
  });
}

enum MessageType {
  welcome,
  trekSelection,
  concernCategories,
  refundInfo,
  faqList,
  answer,
  systemMessage,
}

// Concern categories for a selected booking (2026-09-15 redesign). Modern,
// customer-facing names rather than raw backend enum values — "Cancellation
// & Refund" and "Trek Organiser Behaviour" don't correspond 1:1 to
// IssueReport.issue_type today; this pass is UI/content structure only
// (per the "dummy questions to see UI reference" ask), so no ticket gets
// submitted here yet — every category ends in the same real, working
// escalation this app already has: email.
const List<String> _concernCategories = [
  'Trek Organiser Behaviour',
  'Trek Service',
  'Cancellation & Refund',
  'Something Else',
];

const String _cancellationRefundCategory = 'Cancellation & Refund';

// PLACEHOLDER content (explicitly asked for as dummy, 2026-09-15) — stands
// in for the real thing: admin-authored FAQs per category, the same way
// FaqCategory/FAQ already works for the Help screen (controllers/admin/
// faqController.js#getCustomerFAQs). Swap this map for a real fetch once
// that content exists and is scoped per concern-category.
const Map<String, List<Map<String, String>>> _dummyFaqsByCategory = {
  'Trek Organiser Behaviour': [
    {
      'q': 'The organiser was unprofessional or rude',
      'a': "We're sorry to hear this — every organiser on Aorbo is expected to maintain professional conduct. Please share the trek date and what happened so our team can look into it.",
    },
    {
      'q': "The organiser didn't follow the promised itinerary",
      'a': 'Please share what was promised versus what was actually delivered, and we will follow up with the organiser directly.',
    },
    {
      'q': 'I have safety concerns about this organiser',
      'a': 'Your safety is our top priority. Please share specifics and our team will review this urgently.',
    },
  ],
  'Trek Service': [
    {
      'q': "The trek experience didn't match what was advertised",
      'a': 'Please share which parts of the trek fell short of the listing, and we will follow up with the vendor.',
    },
    {
      'q': 'Poor quality accommodation or meals during the trek',
      'a': 'Please share details (photos help) and we will raise this with the vendor and organiser.',
    },
    {
      'q': 'Guide or support staff were not adequately equipped',
      'a': 'Safety equipment gaps are taken seriously. Please share specifics so we can investigate.',
    },
  ],
  _cancellationRefundCategory: [
    {
      'q': 'How long does a refund take to process?',
      'a': 'Refunds are typically processed within 5-7 business days after approval, depending on your bank.',
    },
    {
      'q': 'Why was my refund amount less than expected?',
      'a': "Refund amounts follow the cancellation policy's time-slab deductions — see the breakdown above for this booking.",
    },
    {
      'q': 'Can I get a full refund if the trek is cancelled by the organiser?',
      'a': "Yes — if a trek is cancelled by the organiser, you're eligible for a full refund or free rescheduling.",
    },
  ],
  'Something Else': [
    {
      'q': 'I have a general question about my booking',
      'a': "Type your question and email us at $_supportEmail — we're happy to help.",
    },
    {
      'q': 'I want to suggest a feature or share feedback',
      'a': "We'd love to hear it — please email us at $_supportEmail.",
    },
  ],
};

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final List<Message> messages = [];
  late AnimationController _typingAnimationController;

  final Repository _repository = Repository();
  final UserController _userC = Get.find<UserController>();
  final TrekController _trekC = Get.find<TrekController>();

  // Booking-first support flow (2026-09-15, mirrors Zomato's post-order
  // support chat): pick the booking, pick a concern category, see real
  // cancellation/refund data when relevant plus admin-curated FAQs
  // (dummy for now), escalate by email if still unresolved.
  List<BookingHistoryData> _recentBookings = [];
  bool _loadingBookings = false;
  BookingHistoryData? selectedBooking;
  // Bumped on every _showTrekSelection call; a response only gets applied if
  // it's still the latest request. Same out-of-order-response pattern this
  // app already fixed for calculate-fare — picking category B before
  // category A's fetch returns must not let A's stale bookings land after B's.
  int _trekFetchGeneration = 0;

  String? selectedConcernCategory;
  String? selectedFaqQuestion;

  bool _loadingRefundInfo = false;
  // Populated by _showRefundInfo() — one of these two, depending on whether
  // the booking is already cancelled (real data either way).
  RefundCalculation? _refundPreview;
  RefundStatusData? _refundStatus;

  @override
  void initState() {
    super.initState();
    _typingAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _addMessage(
      'Hello, I am the Aorbo Treks assistant bot.',
      true,
      MessageType.welcome,
    );

    // Live agent chat and generic FAQ-category browsing both removed
    // (2026-09-15) — no team to staff live chat, and no real customer-facing
    // FAQ content exists yet. The flow now goes straight into picking a
    // booking, mirroring Zomato's post-order support chat.
    _showTrekSelection();

    // Fire-and-forget: warms the customer's profile in case a future step
    // in this flow needs it.
    _userC.getUserProfile();
  }

  @override
  void dispose() {
    _typingAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addMessage(String text, bool isBot, MessageType type) {
    setState(() {
      messages.add(Message(
        text: text,
        isBot: isBot,
        type: type,
        timestamp: DateTime.now(),
      ));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Entry point of the booking-first flow. Uses the same real
  // endpoint/model the Bookings History screen already uses — no fake Trek
  // class, no local date parsing, real backend-computed trek_status only.
  Future<void> _showTrekSelection() async {
    final int myGeneration = ++_trekFetchGeneration;
    setState(() {
      _loadingBookings = true;
      _recentBookings = [];
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      _addMessage(
        'Please select the booking you need help with:',
        true,
        MessageType.trekSelection,
      );
    });

    try {
      final response = await _repository.getApiCall(
        url: NetworkUrl.bookingHistoryWithStatus(page: 1),
      );
      if (!mounted || myGeneration != _trekFetchGeneration) return;
      if (response != null) {
        final model = BookingHistoryModel.fromJson(
          response as Map<String, dynamic>,
        );
        final bookings = model.data ?? <BookingHistoryData>[];
        setState(() {
          _recentBookings = bookings.take(5).toList();
        });
      }
    } catch (e) {
      debugPrint('Error loading recent bookings in ChatScreen: $e');
    } finally {
      if (mounted && myGeneration == _trekFetchGeneration) {
        setState(() => _loadingBookings = false);
      }
    }
  }

  void _handleTrekSelection(BookingHistoryData booking) {
    final label = booking.trek?.title ?? booking.bookingNumber ?? 'this trek';
    setState(() {
      selectedBooking = booking;
      selectedConcernCategory = null;
      selectedFaqQuestion = null;
      _refundPreview = null;
      _refundStatus = null;
      _addMessage(label, false, MessageType.trekSelection);
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      _addMessage(
        'How can we help you with this booking?',
        true,
        MessageType.concernCategories,
      );
    });
  }

  void _handleConcernCategorySelection(String category) {
    setState(() {
      selectedConcernCategory = category;
      selectedFaqQuestion = null;
      _addMessage(category, false, MessageType.concernCategories);
    });

    if (category == _cancellationRefundCategory) {
      _showRefundInfo();
    } else {
      _showFaqList();
    }
  }

  // Real data — reuses the exact controller methods the Cancellation screen
  // (booking_cancle_screen.dart) and post-cancellation tracking screen
  // already call. Not cancelled yet -> the time-slab refund preview. Already
  // cancelled -> when it happened + live refund status.
  Future<void> _showRefundInfo() async {
    setState(() => _loadingRefundInfo = true);
    Future.delayed(const Duration(milliseconds: 500), () {
      _addMessage('', true, MessageType.refundInfo);
    });

    final booking = selectedBooking;
    final bookingId = booking?.id;
    if (booking == null || bookingId == null) {
      if (mounted) setState(() => _loadingRefundInfo = false);
      return;
    }

    final bool isCancelled = booking.trekStatus?.toLowerCase() == 'cancelled';
    try {
      if (isCancelled) {
        await _trekC.fetchRefundStatus(bookingId.toString());
        final data = _trekC.refundStatusObserver.value.maybeWhen(
          success: (m) => m?.data,
          orElse: () => null,
        );
        if (mounted) setState(() => _refundStatus = data);
      } else {
        await _trekC.fetchCancellationDetails(bookingId.toString());
        final data = _trekC.cancellationDetailsResponseObserver.value.maybeWhen(
          success: (m) => m?.data?.refundCalculation,
          orElse: () => null,
        );
        if (mounted) setState(() => _refundPreview = data);
      }
    } catch (e) {
      debugPrint('Error loading refund info in ChatScreen: $e');
    } finally {
      if (mounted) setState(() => _loadingRefundInfo = false);
    }

    _showFaqList();
  }

  // Reads selectedConcernCategory directly (set by the caller just before
  // this) rather than taking a parameter — the faqList bubble itself always
  // renders from that same live state, matching how trekSelection reads
  // _recentBookings live rather than freezing data at message-creation time.
  void _showFaqList() {
    Future.delayed(const Duration(milliseconds: 400), () {
      _addMessage(
        'Here are some common questions about this:',
        true,
        MessageType.faqList,
      );
    });
  }

  void _handleFaqQuestionTap(String question) {
    setState(() {
      selectedFaqQuestion = selectedFaqQuestion == question ? null : question;
    });
  }

  Future<void> _openSupportEmail() async {
    final bookingNumber = selectedBooking?.bookingNumber;
    final subject = [
      if (bookingNumber != null) 'Booking $bookingNumber',
      if (selectedConcernCategory != null) selectedConcernCategory!,
    ].join(' - ');
    final mailUri = Uri(
      scheme: 'mailto',
      path: _supportEmail,
      query: subject.isNotEmpty ? 'subject=${Uri.encodeComponent(subject)}' : null,
    );
    try {
      final launched = await launchUrl(mailUri, mode: LaunchMode.externalApplication);
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No email app found on this device')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open email client')),
      );
    }
  }

  // Zomato-style plain text-link list — a bordered card of stacked rows,
  // not the pill/chip style used for the old category browser.
  Widget _plainLinkRow(String label, VoidCallback? onTap, {bool isLast = false}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 1.6.h),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(bottom: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: Text(
          label,
          style: AppType.style(
            FontSize.s10,
            w: FontWeight.w600,
            color: onTap == null ? AppColors.inkLight : AppColors.info,
          ),
        ),
      ),
    );
  }

  // FAQ row — same bordered-list shape as _plainLinkRow, but an accordion:
  // tapping expands the answer in place instead of navigating away.
  Widget _faqRow(String question, String answer, {bool isLast = false}) {
    final bool expanded = selectedFaqQuestion == question;
    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => _handleFaqQuestionTap(question),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 1.6.h),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      question,
                      style: AppType.style(FontSize.s10, w: FontWeight.w600, color: AppColors.ink),
                    ),
                  ),
                  Icon(
                    expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: AppColors.inkLight,
                  ),
                ],
              ),
            ),
          ),
          if (expanded)
            Padding(
              padding: EdgeInsets.fromLTRB(3.5.w, 0, 3.5.w, 1.6.h),
              child: Text(
                answer,
                style: AppType.style(FontSize.s9, color: AppColors.inkMid, height: 1.4),
              ),
            ),
        ],
      ),
    );
  }

  Widget _emailUsButton() {
    return InkWell(
      onTap: _openSupportEmail,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.1.h),
        decoration: BoxDecoration(
          color: AppColors.forestSoft,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.forest, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.email_outlined, size: 16, color: AppColors.forest),
            SizedBox(width: 1.5.w),
            Text(
              'Email us at $_supportEmail',
              style: AppType.style(FontSize.s9, w: FontWeight.w700, color: AppColors.forest),
            ),
          ],
        ),
      ),
    );
  }

  Widget _refundLoadingOrEmpty() {
    if (_loadingRefundInfo) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 1.h),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.forest),
          ),
        ),
      );
    }
    return Text(
      "We couldn't load the refund details for this booking right now. "
      "Please email us at $_supportEmail.",
      style: AppType.style(FontSize.s10, color: AppColors.inkMid, height: 1.4),
    );
  }

  Widget _refundInfoCard() {
    final booking = selectedBooking;
    final bool isCancelled = booking?.trekStatus?.toLowerCase() == 'cancelled';

    if (_loadingRefundInfo) return _refundLoadingOrEmpty();

    if (isCancelled) {
      final data = _refundStatus;
      if (data == null) return _refundLoadingOrEmpty();
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(3.5.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(3.w),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (data.cancellationDate != null) ...[
              Text('CANCELLED ON', style: AppType.style(FontSize.s8, w: FontWeight.w700, color: AppColors.inkLight, letterSpacing: 0.5)),
              SizedBox(height: 0.3.h),
              Text(data.cancellationDate!, style: AppType.style(FontSize.s10, w: FontWeight.w600, color: AppColors.ink)),
              SizedBox(height: 1.2.h),
            ],
            Text('REFUND STATUS', style: AppType.style(FontSize.s8, w: FontWeight.w700, color: AppColors.inkLight, letterSpacing: 0.5)),
            SizedBox(height: 0.3.h),
            Text(
              data.statusMessage ?? data.refundStatus ?? 'Not yet available',
              style: AppType.style(FontSize.s10, w: FontWeight.w600, color: AppColors.ink),
            ),
            if (data.refundAmount != null) ...[
              SizedBox(height: 1.2.h),
              Text('REFUND AMOUNT', style: AppType.style(FontSize.s8, w: FontWeight.w700, color: AppColors.inkLight, letterSpacing: 0.5)),
              SizedBox(height: 0.3.h),
              Text('₹${data.refundAmount!.toStringAsFixed(0)}', style: AppType.style(FontSize.s10, w: FontWeight.w600, color: AppColors.ink)),
            ],
          ],
        ),
      );
    }

    final refund = _refundPreview;
    if (refund == null) return _refundLoadingOrEmpty();
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(3.5.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('IF YOU CANCEL NOW', style: AppType.style(FontSize.s8, w: FontWeight.w700, color: AppColors.inkLight, letterSpacing: 0.5)),
          SizedBox(height: 0.3.h),
          if (refund.slabInfo != null) ...[
            Text(refund.slabInfo!, style: AppType.style(FontSize.s10, w: FontWeight.w600, color: AppColors.ink)),
            SizedBox(height: 1.2.h),
          ],
          if (refund.refund != null) ...[
            Text('ESTIMATED REFUND', style: AppType.style(FontSize.s8, w: FontWeight.w700, color: AppColors.inkLight, letterSpacing: 0.5)),
            SizedBox(height: 0.3.h),
            Text('₹${refund.refund!.toStringAsFixed(0)}', style: AppType.style(FontSize.s10, w: FontWeight.w600, color: AppColors.success)),
          ],
          if (refund.message != null) ...[
            SizedBox(height: 1.2.h),
            Text(refund.message!, style: AppType.style(FontSize.s9, color: AppColors.inkMid, height: 1.4)),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message) {
    final isBot = message.isBot;

    Widget content;
    switch (message.type) {
      case MessageType.systemMessage:
        content = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
              decoration: BoxDecoration(
                color: AppColors.elevated,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                message.text,
                style: AppType.style(FontSize.s9, w: FontWeight.w500, color: AppColors.inkMid),
              ),
            ),
          ],
        );
        break;

      case MessageType.trekSelection:
        content = message.isBot
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: AppType.style(FontSize.s11, w: FontWeight.w500, color: AppColors.ink),
                  ),
                  SizedBox(height: 1.h),
                  if (_loadingBookings)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 1.h),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.forest),
                        ),
                      ),
                    )
                  else if (_recentBookings.isEmpty)
                    Text(
                      "You don't have any bookings yet. Email us at "
                      "$_supportEmail if you need help.",
                      style: AppType.style(FontSize.s10, color: AppColors.inkMid, height: 1.4),
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final b in _recentBookings)
                          Padding(
                            padding: EdgeInsets.only(bottom: 1.h),
                            child: CommonBookedCard(
                              booking: b,
                              onViewDetailsTap: () => _handleTrekSelection(b),
                            ),
                          ),
                      ],
                    ),
                ],
              )
            : Text(
                message.text,
                style: AppType.style(FontSize.s11, w: FontWeight.w500, color: Colors.white),
              );
        break;

      // "How can we help you with this booking?" — the 4 concern
      // categories, as plain text links (Zomato reference), not pill/chip
      // buttons.
      case MessageType.concernCategories:
        content = message.isBot
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: AppType.style(FontSize.s11, w: FontWeight.w500, color: AppColors.ink),
                  ),
                  SizedBox(height: 1.2.h),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(3.w),
                      border: Border.all(color: AppColors.border),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (int i = 0; i < _concernCategories.length; i++)
                          _plainLinkRow(
                            _concernCategories[i],
                            () => _handleConcernCategorySelection(_concernCategories[i]),
                            isLast: i == _concernCategories.length - 1,
                          ),
                      ],
                    ),
                  ),
                ],
              )
            : Text(
                message.text,
                style: AppType.style(FontSize.s11, w: FontWeight.w500, color: Colors.white),
              );
        break;

      // Real cancellation-preview / refund-status card for the
      // Cancellation & Refund category — reuses TrekController's existing
      // fetch methods (see _showRefundInfo), same data the real
      // Cancellation screen shows.
      case MessageType.refundInfo:
        content = _refundInfoCard();
        break;

      // Admin-curated FAQ list for the selected concern category (dummy
      // content for now — see _dummyFaqsByCategory) + the real email
      // escalation, always shown alongside it.
      case MessageType.faqList:
        final faqs = _dummyFaqsByCategory[selectedConcernCategory] ?? const [];
        content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: AppType.style(FontSize.s11, w: FontWeight.w500, color: AppColors.ink),
            ),
            SizedBox(height: 1.2.h),
            if (faqs.isNotEmpty)
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(3.w),
                  border: Border.all(color: AppColors.border),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int i = 0; i < faqs.length; i++)
                      _faqRow(
                        faqs[i]['q']!,
                        faqs[i]['a']!,
                        isLast: i == faqs.length - 1,
                      ),
                  ],
                ),
              ),
            SizedBox(height: 1.2.h),
            _emailUsButton(),
          ],
        );
        break;

      case MessageType.answer:
        content = MarkdownText(
          text: message.text,
          style: AppType.style(FontSize.s11, w: FontWeight.w500, color: isBot ? AppColors.ink : Colors.white),
        );
        break;

      default:
        content = Text(
          message.text,
          style: AppType.style(FontSize.s11, w: FontWeight.w500, color: isBot ? AppColors.ink : Colors.white),
        );
    }

    // System messages are centered without bubble
    if (message.type == MessageType.systemMessage) {
      return Container(
        margin: EdgeInsets.only(bottom: 2.h),
        child: content,
      );
    }

    // The bot-message bubble box (shadow + rounded corners) would otherwise
    // wrap rich content that already has its own visual structure — the
    // booking ticket cards, the category/FAQ bordered lists, the refund
    // info card — producing a "container behind the cards" look. These bot
    // messages skip the bubble entirely. The customer's own short echoed
    // selections (isBot: false) for the same message types still get the
    // normal colored bubble.
    final bool isRichBotContent = isBot &&
        (message.type == MessageType.trekSelection ||
            message.type == MessageType.concernCategories ||
            message.type == MessageType.refundInfo ||
            message.type == MessageType.faqList);
    if (isRichBotContent) {
      return Container(
        margin: EdgeInsets.only(bottom: 2.h),
        child: content,
      );
    }

    return Align(
      alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.only(
          left: isBot ? 2.w : 10.w,
          right: isBot ? 10.w : 2.w,
          bottom: 2.h,
        ),
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: isBot ? AppColors.elevated : AppColors.forest,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isBot ? 0 : 4.w),
            topRight: Radius.circular(isBot ? 4.w : 0),
            bottomLeft: Radius.circular(4.w),
            bottomRight: Radius.circular(4.w),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: content,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.elevated,
      appBar: AppBar(
        backgroundColor: AppColors.forestSoft.withValues(alpha: 0.2),
        scrolledUnderElevation: 0,
        elevation: 0,
        automaticallyImplyLeading: true,
        centerTitle: false,
        title: Text(
          'Chat with Aorbo',
          style: AppType.style(FontSize.s15, w: FontWeight.w500, color: AppColors.ink),
        ),
      ),
      // No free-text input field (removed 2026-09-15 — not needed; the
      // guided booking-first flow is the only path, there's nothing for
      // free text to do here anymore).
      body: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        itemCount: messages.length,
        itemBuilder: (context, index) {
          return AnimatedSize(
            duration: const Duration(milliseconds: 200),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: 1,
              child: _buildMessageBubble(messages[index]),
            ),
          );
        },
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
