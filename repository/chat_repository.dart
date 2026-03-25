import 'dart:convert';
import 'package:arobo_app/utils/app_logger.dart';
import 'package:arobo_app/models/chat/chat_model.dart';
import 'package:arobo_app/models/chat/message_model.dart';
import 'package:arobo_app/repository/network_url.dart';
import 'package:arobo_app/repository/repository.dart';

class ChatRepository {
  final Repository _repository = Repository();

  /// Create or get existing chat for the customer
  /// Returns ChatModel
  Future<ChatModel?> createOrGetChat({
    String? subject,
    String? initialMessage,
  }) async {
    try {
      final Map<String, dynamic> body = {};
      if (subject != null) body['subject'] = subject;
      if (initialMessage != null) body['initialMessage'] = initialMessage;

      final response = await _repository.postApiCall(
        url: NetworkUrl.createOrGetChat,
        body: json.encode(body),
      );

      if (response != null && response['success'] == true) {
        final chatData = response['data']['chat'];
        return ChatModel.fromJson(chatData);
      }
      return null;
    } catch (e) {
      appLog('Error creating/getting chat: $e');
      rethrow;
    }
  }

  /// Get chat messages with pagination
  /// Returns list of MessageModel
  Future<List<MessageModel>> getChatMessages({
    required int chatId,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final url =
          '${NetworkUrl.getChatMessages(chatId)}?page=$page&limit=$limit';

      final response = await _repository.getApiCall(url: url);

      if (response != null && response['success'] == true) {
        final List<dynamic> messagesData = response['data']['messages'];
        return messagesData
            .map((messageJson) => MessageModel.fromJson(messageJson))
            .toList();
      }
      return [];
    } catch (e) {
      appLog('Error fetching chat messages: $e');
      rethrow;
    }
  }

  /// Mark all admin messages as read for customer
  Future<bool> markMessagesAsRead({required int chatId}) async {
    try {
      final response = await _repository.patchApiCall(
        url: NetworkUrl.markMessagesAsRead(chatId),
        body: json.encode({}),
      );

      if (response != null && response['success'] == true) {
        return true;
      }
      return false;
    } catch (e) {
      appLog('Error marking messages as read: $e');
      rethrow;
    }
  }

  /// Get chat details
  Future<ChatModel?> getChatDetails({required int chatId}) async {
    try {
      final url = NetworkUrl.getChatMessages(chatId);

      final response = await _repository.getApiCall(url: url);

      if (response != null && response['success'] == true) {
        final chatData = response['data']['chat'];
        return ChatModel.fromJson(chatData);
      }
      return null;
    } catch (e) {
      appLog('Error fetching chat details: $e');
      rethrow;
    }
  }
}
