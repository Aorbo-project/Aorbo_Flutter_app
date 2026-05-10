import 'package:arobo_app/utils/common_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:get/get.dart';
import '../models/chat_data.dart';
import '../controller/chat_controller.dart';
import '../utils/screen_constants.dart';

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

  List<String> get categories => chatbotData.keys.toList();

  List<String> get questionsList {
    if (selectedCategory != null) {
      return List<String>.from(chatbotData[selectedCategory]!['questions']);
    }
    return [];
  }

  String? get answer {
    if (selectedQuestion != null && selectedCategory != null) {
      return chatbotData[selectedCategory]!['answers'][selectedQuestion];
    }
    return null;
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
    // Show mode selector after welcome
    _showModeSelector();

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
  }

  @override
  void dispose() {
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
      _addMessage(category, false, MessageType.category);
    });

    // Show questions after category selection
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

  void _handleSendMessage() {
    if (currentMode == ChatMode.liveChat && isConnectedToSupport) {
      // Use ChatController for live chat
      _chatController.sendMessage();
    } else {
      // Handle FAQ mode text input if needed
      final text = _messageController.text.trim();
      if (text.isEmpty) return;

      _addMessage(text, false, MessageType.liveMessage);
      _messageController.clear();
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
                  color: CommonColors.offWhiteColor,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: Colors.grey.shade300,
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
                    hintStyle: GoogleFonts.poppins(
                      fontSize: FontSize.s11,
                      color: Colors.grey.shade500,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 1.2.h,
                    ),
                  ),
                  style: GoogleFonts.poppins(
                    fontSize: FontSize.s11,
                    color: CommonColors.blackColor,
                  ),
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
                  color: CommonColors.appBgColor,
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
              style: GoogleFonts.poppins(
                fontSize: FontSize.s11,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 1.h),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _handleModeSelection(ChatMode.faq),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 3.w,
                        vertical: 1.5.h,
                      ),
                      decoration: BoxDecoration(
                        color: CommonColors.appBgColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: CommonColors.appBgColor,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.quiz_outlined,
                            color: CommonColors.appBgColor,
                            size: 18,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            'Browse FAQs',
                            style: GoogleFonts.poppins(
                              fontSize: FontSize.s10,
                              color: CommonColors.appBgColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: InkWell(
                    onTap: () => _handleModeSelection(ChatMode.liveChat),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 3.w,
                        vertical: 1.5.h,
                      ),
                      decoration: BoxDecoration(
                        color: CommonColors.appBgColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: CommonColors.appBgColor,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.support_agent,
                            color: Colors.white,
                            size: 18,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            'Live Support',
                            style: GoogleFonts.poppins(
                              fontSize: FontSize.s10,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
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
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                message.text,
                style: GoogleFonts.poppins(
                  fontSize: FontSize.s9,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
        break;

      case MessageType.liveMessage:
        content = Text(
          message.text,
          style: GoogleFonts.poppins(
            fontSize: FontSize.s11,
            color: isBot ? Colors.black87 : Colors.white,
            fontWeight: FontWeight.w500,
          ),
        );
        break;

      case MessageType.category:
        content = message.isBot
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: GoogleFonts.poppins(
                      fontSize: FontSize.s11,
                      color: isBot ? Colors.black87 : Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
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
                              color: CommonColors.appBgColor
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: CommonColors.appBgColor,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              category,
                              style: GoogleFonts.poppins(
                                fontSize: FontSize.s10,
                                color: CommonColors.appBgColor,
                                fontWeight: FontWeight.w500,
                              ),
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
                style: GoogleFonts.poppins(
                  fontSize: FontSize.s11,
                  color: isBot ? Colors.black87 : Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              );
        break;

      case MessageType.question:
        content = message.isBot
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: GoogleFonts.poppins(
                      fontSize: FontSize.s11,
                      color: isBot ? Colors.black87 : Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
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
                              color: CommonColors.appBgColor
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: CommonColors.appBgColor,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              question,
                              style: GoogleFonts.poppins(
                                fontSize: FontSize.s10,
                                color: CommonColors.appBgColor,
                                fontWeight: FontWeight.w500,
                              ),
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
                style: GoogleFonts.poppins(
                  fontSize: FontSize.s11,
                  color: isBot ? Colors.black87 : Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              );
        break;

      default:
        content = Text(
          message.text,
          style: GoogleFonts.poppins(
            fontSize: FontSize.s11,
            color: isBot ? Colors.black87 : Colors.white,
            fontWeight: FontWeight.w500,
          ),
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
          color: CommonColors.offWhiteColor,
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
          color: isBot ? CommonColors.offWhiteColor : CommonColors.appBgColor,
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
          color: CommonColors.offWhiteColor,
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
              style: GoogleFonts.poppins(
                fontSize: FontSize.s11,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(width: 2.w),
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(CommonColors.appBgColor),
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
      backgroundColor: CommonColors.offWhiteColor,
      appBar: AppBar(
        backgroundColor: CommonColors.lightBlueColor3.withValues(alpha: 0.2),
        scrolledUnderElevation: 0,
        elevation: 0,
        automaticallyImplyLeading: true,
        centerTitle: false,
        title: Text(
          'Chat with Aorbo',
          style: GoogleFonts.poppins(
            fontSize: FontSize.s15,
            fontWeight: FontWeight.w500,
            color: CommonColors.blackColor,
          ),
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
