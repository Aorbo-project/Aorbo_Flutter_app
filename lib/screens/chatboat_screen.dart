import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:get/get.dart';
import '../models/chat_data.dart' as chat_data_defaults;
import '../controller/chat_controller.dart';
import '../utils/common_booked_card.dart';
import '../utils/screen_constants.dart';
import '../repository/faq_repository.dart';
import '../repository/network_url.dart';
import '../repository/repository.dart';
import '../freezed_models/booking/booking_history_model.dart';
import '../services/socket_service.dart';
import 'package:arobo_app/theme/app_tokens.dart';
import 'package:arobo_app/theme/app_typography.dart';

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
  category,
  trekSelection,
  question,
  answer,
  liveMessage,
  systemMessage,
  modeSelector,
}

enum ChatMode {
  faq,
  liveChat,
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  String? selectedCategory;
  String? selectedQuestion;
  final ScrollController _scrollController = ScrollController();
  final List<Message> messages = [];
  late AnimationController _typingAnimationController;

  // Live chat related state
  ChatMode currentMode = ChatMode.faq;
  final TextEditingController _messageController = TextEditingController();
  bool isTyping = false;
  bool isConnectedToSupport = false;

  // Chat controller for live chat
  final ChatController _chatController = Get.put(ChatController());
  final FaqRepository _faqRepository = FaqRepository();
  final SocketService _socketService = SocketService();
  final Repository _repository = Repository();

  // BUGFIX (2026-09-14): _loadChatbotFaqs() used to clear()/addAll() the
  // IMPORTED chatbotData map from models/chat_data.dart in place — mutating
  // a module-level fallback-content constant as if it were a live per-screen
  // cache. Now screen-local: seeded once from the import, only ever mutated
  // here.
  late final Map<String, dynamic> _chatbotData =
      Map<String, dynamic>.from(chat_data_defaults.chatbotData);

  // Trek-context step (2026-09-14): after picking a category, the customer
  // picks one of their real recent bookings before seeing FAQs, so a
  // follow-up "Report an Issue" carries real booking context. No fabricated
  // per-FAQ status field — only which TREKS are offered is filtered
  // (real trek_status from the backend), the FAQ list itself stays the
  // category's real, unfiltered list.
  List<BookingHistoryData> _recentBookings = [];
  bool _loadingBookings = false;
  BookingHistoryData? selectedBooking;

  List<String> get categories => _chatbotData.keys.toList();

  List<String> get questionsList {
    if (selectedCategory != null) {
      return List<String>.from(_chatbotData[selectedCategory]!['questions']);
    }
    return [];
  }

  String? get answer {
    if (selectedQuestion != null && selectedCategory != null) {
      return _chatbotData[selectedCategory]!['answers'][selectedQuestion];
    }
    return null;
  }

  // Heuristic, not a hardcoded category list — real category names come
  // from the backend (FaqRepository().fetchCustomerFaqs()) and aren't fixed.
  bool _categoryWantsRecentTreksOnly(String category) {
    return RegExp(
      r'issue|service|complaint|problem|safety',
      caseSensitive: false,
    ).hasMatch(category);
  }

  // Get all messages (FAQ + Live Chat combined)
  List<Message> get allMessages {
    List<Message> combinedMessages = List.from(messages);

    // Add live chat messages from controller if in live chat mode
    if (currentMode == ChatMode.liveChat && isConnectedToSupport) {
      for (var liveMsg in _chatController.messages) {
        combinedMessages.add(Message(
          text: liveMsg.message ?? '',
          isBot: liveMsg.senderType == 'admin',
          type: MessageType.liveMessage,
          timestamp: liveMsg.createdAt ?? DateTime.now(),
        ));
      }
    }

    return combinedMessages;
  }

  @override
  void initState() {
    super.initState();
    _typingAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    // Add welcome message
    _addMessage(
      'Hello, I am the Aorbo Treks assistant bot.',
      true,
      MessageType.welcome,
    );

    // Check if arguments specify starting live chat instantly
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null && args['mode'] == 'liveChat') {
      currentMode = ChatMode.liveChat;
      _initializeLiveChat();
    } else {
      // Show mode selector after welcome
      _showModeSelector();
    }

    // Listen to ChatController messages for updates
    _chatController.messages.listen((_) {
      if (mounted && currentMode == ChatMode.liveChat && isConnectedToSupport) {
        setState(() {});
      }
    });

    // Listen to typing indicator
    _chatController.isAdminTyping.listen((_) {
      if (mounted && currentMode == ChatMode.liveChat && isConnectedToSupport) {
        setState(() {});
      }
    });

    _loadChatbotFaqs();
    _socketService.addListener('faq:updated', _handleFaqRefresh);
  }

  Future<void> _handleFaqRefresh(dynamic _) async {
    if (mounted) {
      await _loadChatbotFaqs();
    }
  }

  Future<void> _loadChatbotFaqs() async {
    try {
      final categories = await _faqRepository.fetchCustomerFaqs();
      if (categories.isNotEmpty) {
        final Map<String, dynamic> newChatbotData = {};
        for (var cat in categories) {
          final String catName = cat['name'] ?? '';
          if (catName.isEmpty) continue;

          final faqs = cat['faqs'] as List<dynamic>;
          final List<String> questions = [];
          final Map<String, String> answers = {};

          for (var faq in faqs) {
            final String q = faq['question'] ?? '';
            final String a = faq['answer'] ?? '';
            if (q.isNotEmpty && a.isNotEmpty) {
              questions.add(q);
              answers[q] = a;
            }
          }

          if (questions.isNotEmpty) {
            newChatbotData[catName] = {
              'questions': questions,
              'answers': answers,
            };
          }
        }

        if (mounted && newChatbotData.isNotEmpty) {
          setState(() {
            _chatbotData.clear();
            _chatbotData.addAll(newChatbotData);
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading FAQs in ChatScreen: $e');
    }
  }

  @override
  void dispose() {
    // BUGFIX (2026-09-14): this listener was added in initState with no
    // matching removeListener — a real leak (the `if (mounted)` guard
    // inside _handleFaqRefresh only prevented a crash on a disposed
    // widget, it never actually detached the listener from SocketService).
    _socketService.removeListener('faq:updated', _handleFaqRefresh);
    _typingAnimationController.dispose();
    _scrollController.dispose();
    _messageController.dispose();
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

  void _showModeSelector() {
    Future.delayed(const Duration(milliseconds: 500), () {
      _addMessage(
        'How can I help you today?',
        true,
        MessageType.modeSelector,
      );
    });
  }

  void _showCategories() {
    Future.delayed(const Duration(milliseconds: 500), () {
      _addMessage(
        'Please select a category for your inquiry:',
        true,
        MessageType.category,
      );
    });
  }

  void _handleCategorySelection(String category) {
    setState(() {
      selectedCategory = category;
      selectedQuestion = null;
      selectedBooking = null;
      _addMessage(category, false, MessageType.category);
    });

    _showTrekSelection(category);
  }

  // Trek-context step, inserted between category and FAQ list (2026-09-14).
  // Uses the same real endpoint/model the Bookings History screen already
  // uses — no fake Trek class, no local date parsing, real backend-computed
  // trek_status only.
  Future<void> _showTrekSelection(String category) async {
    setState(() => _loadingBookings = true);
    Future.delayed(const Duration(milliseconds: 500), () {
      _addMessage(
        'Which trek is this about?',
        true,
        MessageType.trekSelection,
      );
    });

    try {
      final response = await _repository.getApiCall(
        url: NetworkUrl.bookingHistoryWithStatus(page: 1),
      );
      if (!mounted) return;
      if (response != null) {
        final model = BookingHistoryModel.fromJson(
          response as Map<String, dynamic>,
        );
        var bookings = model.data ?? <BookingHistoryData>[];
        if (_categoryWantsRecentTreksOnly(category)) {
          bookings = bookings
              .where(
                (b) => ['ongoing', 'completed'].contains(
                  (b.trekStatus ?? '').toLowerCase(),
                ),
              )
              .toList();
        }
        setState(() {
          _recentBookings = bookings.take(5).toList();
        });
      }
    } catch (e) {
      debugPrint('Error loading recent bookings in ChatScreen: $e');
    } finally {
      if (mounted) setState(() => _loadingBookings = false);
    }
  }

  void _handleTrekSelection(BookingHistoryData booking) {
    final label = booking.trek?.title ?? booking.bookingNumber ?? 'this trek';
    setState(() {
      selectedBooking = booking;
      _addMessage(label, false, MessageType.trekSelection);
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      _addMessage(
        'Please select your question:',
        true,
        MessageType.question,
      );
    });
  }

  void _skipTrekSelection() {
    setState(() {
      selectedBooking = null;
      _addMessage('Not about a specific trek', false, MessageType.trekSelection);
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      _addMessage(
        'Please select your question:',
        true,
        MessageType.question,
      );
    });
  }

  void _handleQuestionSelection(String question) {
    setState(() {
      selectedQuestion = question;
      _addMessage(question, false, MessageType.question);
    });

    // Show answer after question selection
    Future.delayed(const Duration(milliseconds: 600), () {
      if (answer != null) {
        _addMessage(answer!, true, MessageType.answer);
        // Instead of looping back to categories, offer live chat or more questions
        Future.delayed(const Duration(milliseconds: 800), () {
          _showPostAnswerOptions();
        });
      }
    });
  }

  void _showPostAnswerOptions() {
    _addMessage(
      'Did this answer help? What would you like to do next?',
      true,
      MessageType.modeSelector,
    );
  }

  void _handleModeSelection(ChatMode mode) {
    setState(() {
      currentMode = mode;
      _addMessage(
        mode == ChatMode.faq ? 'Browse FAQs' : 'Chat with Live Support',
        false,
        MessageType.systemMessage,
      );
    });

    if (mode == ChatMode.faq) {
      _showCategories();
    } else {
      _initializeLiveChat();
    }
  }

  void _initializeLiveChat() async {
    _addMessage(
      'Connecting you to our support team...',
      true,
      MessageType.systemMessage,
    );

    try {
      // Initialize the chat controller
      await _chatController.initializeChat();
      if (!mounted) return;

      setState(() {
        isConnectedToSupport = true;
      });

      _addMessage(
        'Connected! You can now chat with our support team.',
        true,
        MessageType.systemMessage,
      );
    } catch (e) {
      _addMessage(
        'Failed to connect. Please try again.',
        true,
        MessageType.systemMessage,
      );
    }
  }

  void _handleSendMessage() async {
    if (currentMode == ChatMode.liveChat && isConnectedToSupport) {
      // Use ChatController for live chat
      _chatController.sendMessage();
    } else {
      // Handle FAQ mode text input if needed
      final text = _messageController.text.trim();
      if (text.isEmpty) return;

      _addMessage(text, false, MessageType.liveMessage);
      _messageController.clear();

      setState(() {
        isTyping = true;
      });

      try {
        final result = await _faqRepository.fetchChatbotReply(text);
        if (!mounted) return;

        setState(() {
          isTyping = false;
        });

        if (result != null && result['match'] == true && result['faq'] != null) {
          final faq = result['faq'];
          _addMessage(faq['answer'] ?? '', true, MessageType.answer);
        } else {
          // Fallback message if no match found
          _addMessage("I'm sorry, I couldn't quite understand that. Would you like to check our FAQs or connect with support?", true, MessageType.answer);
          Future.delayed(const Duration(milliseconds: 600), () {
            _showPostAnswerOptions();
          });
        }
      } catch (e) {
        setState(() {
          isTyping = false;
        });
        _addMessage("An error occurred. Please try again.", true, MessageType.answer);
      }
    }
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.elevated,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: AppColors.border,
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: currentMode == ChatMode.liveChat && isConnectedToSupport
                      ? _chatController.messageController
                      : _messageController,
                  decoration: InputDecoration(
                    hintText: currentMode == ChatMode.faq
                        ? 'Or type your question...'
                        : 'Type a message...',
                    hintStyle: AppType.style(FontSize.s11, color: AppColors.inkLight),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 1.2.h,
                    ),
                  ),
                  style: AppType.style(FontSize.s11, color: AppColors.ink),
                  maxLines: 4,
                  minLines: 1,
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: (text) {
                    // Trigger typing indicator in live chat mode
                    if (currentMode == ChatMode.liveChat && isConnectedToSupport) {
                      _chatController.onTyping();
                    }
                  },
                ),
              ),
            ),
            SizedBox(width: 2.w),
            InkWell(
              onTap: _handleSendMessage,
              borderRadius: BorderRadius.circular(25),
              child: Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color: AppColors.forest,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _modeOptionButton({
    required IconData icon,
    required String label,
    required bool filled,
    required VoidCallback onTap,
  }) {
    final Color fg = filled ? Colors.white : AppColors.forest;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 2.2.w, vertical: 1.5.h),
        decoration: BoxDecoration(
          color: filled ? AppColors.forest : AppColors.forestSoft,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.forest, width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: fg, size: 18),
            SizedBox(height: 0.4.h),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppType.style(FontSize.s9, w: FontWeight.w600, color: fg),
            ),
          ],
        ),
      ),
    );
  }

  Widget _skipTrekButton() {
    return InkWell(
      onTap: _skipTrekSelection,
      child: Text(
        _recentBookings.isEmpty
            ? "Doesn't apply to a specific trek — continue"
            : 'Not one of these — continue anyway',
        style: AppType.style(
          FontSize.s10,
          w: FontWeight.w600,
          color: AppColors.info,
        ),
      ),
    );
  }

  // "Report Issue" reuses the already-correct IssueReportScreen (fixing its
  // long-standing unreachability at the same time) rather than building new
  // ticket-creation UI here. Carries the trek context if one was picked.
  void _handleReportIssue() {
    _addMessage('Report an Issue', false, MessageType.systemMessage);
    Get.toNamed(
      '/issue-report',
      arguments: {'bookingId': selectedBooking?.id},
    );
  }

  Widget _buildMessageBubble(Message message) {
    final isBot = message.isBot;

    Widget content;
    switch (message.type) {
      case MessageType.modeSelector:
        content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: AppType.style(FontSize.s11, w: FontWeight.w500, color: AppColors.ink),
            ),
            SizedBox(height: 1.h),
            Row(
              children: [
                Expanded(
                  child: _modeOptionButton(
                    icon: Icons.quiz_outlined,
                    label: 'Browse FAQs',
                    filled: false,
                    onTap: () => _handleModeSelection(ChatMode.faq),
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: _modeOptionButton(
                    icon: Icons.confirmation_number_outlined,
                    label: 'Report Issue',
                    filled: false,
                    onTap: _handleReportIssue,
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: _modeOptionButton(
                    icon: Icons.support_agent,
                    label: 'Live Support',
                    filled: true,
                    onTap: () => _handleModeSelection(ChatMode.liveChat),
                  ),
                ),
              ],
            ),
          ],
        );
        break;

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

      case MessageType.liveMessage:
        content = Text(
          message.text,
          style: AppType.style(FontSize.s11, w: FontWeight.w500, color: isBot ? AppColors.ink : Colors.white),
        );
        break;

      case MessageType.category:
        content = message.isBot
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: AppType.style(FontSize.s11, w: FontWeight.w500, color: isBot ? AppColors.ink : Colors.white),
                  ),
                  if (isBot) ...[
                    SizedBox(height: 1.h),
                    Wrap(
                      spacing: 2.w,
                      runSpacing: 1.h,
                      children: categories.map((category) {
                        return InkWell(
                          onTap: () => _handleCategorySelection(category),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 3.w,
                              vertical: 1.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.forest.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.forest,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              category,
                              style: AppType.style(FontSize.s10, w: FontWeight.w500, color: AppColors.forest),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              )
            : Text(
                message.text,
                style: AppType.style(FontSize.s11, w: FontWeight.w500, color: isBot ? AppColors.ink : Colors.white),
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
                    _skipTrekButton()
                  else ...[
                    SizedBox(
                      height: 24.h,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _recentBookings.length,
                        itemBuilder: (context, i) => SizedBox(
                          width: 68.w,
                          child: CommonBookedCard(
                            booking: _recentBookings[i],
                            onViewDetailsTap: () =>
                                _handleTrekSelection(_recentBookings[i]),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 1.h),
                    _skipTrekButton(),
                  ],
                ],
              )
            : Text(
                message.text,
                style: AppType.style(FontSize.s11, w: FontWeight.w500, color: Colors.white),
              );
        break;

      case MessageType.question:
        content = message.isBot
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: AppType.style(FontSize.s11, w: FontWeight.w500, color: isBot ? AppColors.ink : Colors.white),
                  ),
                  if (isBot) ...[
                    SizedBox(height: 1.h),
                    ...questionsList.map((question) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 1.h),
                        child: InkWell(
                          onTap: () => _handleQuestionSelection(question),
                          child: Container(
                            width: 60.w,
                            padding: EdgeInsets.symmetric(
                              horizontal: 3.w,
                              vertical: 1.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.forest
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.forest,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              question,
                              style: AppType.style(FontSize.s10, w: FontWeight.w500, color: AppColors.forest),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ],
              )
            : Text(
                message.text,
                style: AppType.style(FontSize.s11, w: FontWeight.w500, color: isBot ? AppColors.ink : Colors.white),
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

    // Mode selector and other bot messages use full width or custom alignment
    if (message.type == MessageType.modeSelector) {
      return Container(
        margin: EdgeInsets.only(
          left: 2.w,
          right: 2.w,
          bottom: 2.h,
        ),
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: AppColors.elevated,
          borderRadius: BorderRadius.circular(4.w),
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

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          left: 2.w,
          right: 10.w,
          bottom: 2.h,
        ),
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: AppColors.elevated,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(0),
            topRight: Radius.circular(4.w),
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Support is typing',
              style: AppType.style(
                FontSize.s11,
                color: AppColors.inkMid,
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(width: 2.w),
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.forest),
              ),
            ),
          ],
        ),
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
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: currentMode == ChatMode.liveChat && isConnectedToSupport
                  ? _chatController.scrollController
                  : _scrollController,
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              itemCount: allMessages.length + (currentMode == ChatMode.liveChat && _chatController.isAdminTyping.value ? 1 : 0),
              itemBuilder: (context, index) {
                final messagesToShow = allMessages;

                // Show typing indicator at the end if admin is typing
                if (currentMode == ChatMode.liveChat &&
                    _chatController.isAdminTyping.value &&
                    index == messagesToShow.length) {
                  return _buildTypingIndicator();
                }

                return AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: 1,
                    child: _buildMessageBubble(messagesToShow[index]),
                  ),
                );
              },
            ),
          ),
          _buildInputArea(),
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
