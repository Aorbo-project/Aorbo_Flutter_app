

import '../models/chat_data.dart';

class ChatCategory {
  final String name;
  final List<String> questions;
  final Map<String, String> answers;

  ChatCategory({
    required this.name,
    required this.questions,
    required this.answers,
  });

  factory ChatCategory.fromMap(String name, Map<String, dynamic> data) {
    return ChatCategory(
      name: name,
      questions: List<String>.from(data['questions']),
      answers: Map<String, String>.from(data['answers']),
    );
  }
}
List<ChatCategory> getChatCategories() {
  return chatbotData.entries
      .map((entry) => ChatCategory.fromMap(entry.key, entry.value))
      .toList();
}
