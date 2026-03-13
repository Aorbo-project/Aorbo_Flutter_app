import 'dart:async';
import 'dart:developer';
import 'package:arobo_app/main.dart';
import 'package:arobo_app/models/chat/chat_model.dart';
import 'package:arobo_app/models/chat/message_model.dart';
import 'package:arobo_app/repository/chat_repository.dart';
import 'package:arobo_app/services/socket_service.dart';
import 'package:arobo_app/utils/custom_snackbar.dart';
import 'package:arobo_app/utils/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatController extends GetxController {
  final ChatRepository _chatRepository = ChatRepository();
  final SocketService _socketService = SocketService();

  // Observable state
  final Rx<ChatModel?> currentChat = Rx<ChatModel?>(null);
  final RxList<MessageModel> messages = <MessageModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMessages = false.obs;
  final RxBool isConnected = false.obs;
  final RxBool isAdminTyping = false.obs;
  final RxInt unreadCount = 0.obs;

  // Text controller for message input
  final TextEditingController messageController = TextEditingController();

  // Scroll controller
  final ScrollController scrollController = ScrollController();

  // Customer ID
  int? _customerId;

  // Typing timer
  Timer? _typingTimer;
  bool _isTyping = false;

  @override
  void onInit() {
    super.onInit();
    _setupSocketListeners();
  }

  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    _socketService.disconnect();
    _typingTimer?.cancel();
    super.onClose();
  }

  /// Initialize chat - Create/get chat, connect socket, load messages
  Future<void> initializeChat() async {
    try {
      isLoading.value = true;

      // Get customer ID from shared preferences
      _customerId = sp!.getInt(SpUtil.userID);
      if (_customerId == null || _customerId == 0) {
        throw Exception('Customer ID not found');
      }

      // Create or get existing chat
      final chat = await _chatRepository.createOrGetChat();
      if (chat == null) {
        throw Exception('Failed to create/get chat');
      }

      currentChat.value = chat;

      // Connect to Socket.IO
      await _socketService.connect(customerId: _customerId!);

      // Join the chat room
      _socketService.joinChat(chatId: chat.id!);

      // Load message history
      await fetchMessages();

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      log('Error initializing chat: $e');
      CustomSnackBar.show(
        Get.context!,
        message: 'Failed to initialize chat. Please try again.',
      );
      rethrow;
    }
  }

  /// Setup socket event listeners
  void _setupSocketListeners() {
    // Listen for connection status
    _socketService.addListener('connected', (_) {
      isConnected.value = true;
      log('✅ Chat connected');
    });

    _socketService.addListener('disconnected', (_) {
      isConnected.value = false;
      log('❌ Chat disconnected');
    });

    // Listen for new messages
    _socketService.addListener('message:received', (data) {
      if (data is MessageModel) {
        _handleIncomingMessage(data);
      }
    });

    // Listen for messages marked as read
    _socketService.addListener('messages:marked_read', (data) {
      _handleMessagesMarkedAsRead(data);
    });

    // Listen for typing indicators
    _socketService.addListener('user:typing', (data) {
      if (data['userType'] == 'admin') {
        isAdminTyping.value = true;
        scrollToBottom();
      }
    });

    _socketService.addListener('user:stop_typing', (data) {
      if (data['userType'] == 'admin') {
        isAdminTyping.value = false;
      }
    });
  }

  /// Fetch message history
  Future<void> fetchMessages({int page = 1, int limit = 50}) async {
    if (currentChat.value?.id == null) return;

    try {
      isLoadingMessages.value = true;

      final fetchedMessages = await _chatRepository.getChatMessages(
        chatId: currentChat.value!.id!,
        page: page,
        limit: limit,
      );

      messages.value = fetchedMessages;

      // Mark messages as read
      await markMessagesAsRead();

      // Scroll to bottom after loading messages
      Future.delayed(const Duration(milliseconds: 300), () {
        scrollToBottom();
      });

      isLoadingMessages.value = false;
    } catch (e) {
      isLoadingMessages.value = false;
      log('Error fetching messages: $e');
      CustomSnackBar.show(
        Get.context!,
        message: 'Failed to load messages',
      );
    }
  }

  /// Send a message
  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty || currentChat.value?.id == null || _customerId == null) {
      return;
    }

    try {
      // Create optimistic message (show immediately in UI)
      final optimisticMessage = MessageModel(
        chatId: currentChat.value!.id,
        message: text,
        senderType: 'customer',
        senderId: _customerId,
        messageType: 'text',
        isRead: false,
        createdAt: DateTime.now(),
      );

      // Add to UI immediately
      messages.add(optimisticMessage);
      messageController.clear();
      scrollToBottom();

      // Send via Socket.IO
      _socketService.sendMessage(
        chatId: currentChat.value!.id!,
        message: text,
        senderId: _customerId!,
      );

      // Stop typing indicator
      _stopTyping();
    } catch (e) {
      log('Error sending message: $e');
      CustomSnackBar.show(
        Get.context!,
        message: 'Failed to send message',
      );
    }
  }

  /// Handle incoming message from socket
  void _handleIncomingMessage(MessageModel message) {
    // Check if message already exists (avoid duplicates)
    final exists = messages.any((m) => m.id == message.id);
    if (!exists) {
      messages.add(message);
      scrollToBottom();

      // Mark as read if from admin
      if (message.isFromAdmin) {
        Future.delayed(const Duration(milliseconds: 500), () {
          markMessagesAsRead();
        });
      }
    }
  }

  /// Handle messages marked as read event
  void _handleMessagesMarkedAsRead(dynamic data) {
    log('Messages marked as read: $data');
    // Update local message status if needed
    for (var message in messages) {
      if (message.senderType == 'customer' && message.isRead == false) {
        final index = messages.indexOf(message);
        messages[index] = message.copyWith(
          isRead: true,
          readAt: DateTime.now(),
        );
      }
    }
  }

  /// Mark messages as read
  Future<void> markMessagesAsRead() async {
    if (currentChat.value?.id == null) return;

    try {
      // Mark via Socket.IO
      _socketService.markAsRead(chatId: currentChat.value!.id!);

      // Also call REST API
      await _chatRepository.markMessagesAsRead(chatId: currentChat.value!.id!);

      // Update unread count
      unreadCount.value = 0;
    } catch (e) {
      log('Error marking messages as read: $e');
    }
  }

  /// Handle typing in text field
  void onTyping() {
    if (currentChat.value?.id == null) return;

    // Start typing indicator
    if (!_isTyping) {
      _isTyping = true;
      _socketService.startTyping(
        chatId: currentChat.value!.id!,
        userName: 'Customer',
      );
    }

    // Reset timer
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () {
      _stopTyping();
    });
  }

  /// Stop typing indicator
  void _stopTyping() {
    if (currentChat.value?.id == null) return;

    if (_isTyping) {
      _isTyping = false;
      _socketService.stopTyping(chatId: currentChat.value!.id!);
      _typingTimer?.cancel();
    }
  }

  /// Scroll to bottom of chat
  void scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Refresh chat (pull to refresh)
  Future<void> refreshChat() async {
    await fetchMessages();
  }
}
