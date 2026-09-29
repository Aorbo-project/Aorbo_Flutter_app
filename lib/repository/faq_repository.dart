import 'dart:developer';
import 'package:arobo_app/repository/app_env.dart';
import 'package:arobo_app/repository/network_url.dart';
import 'package:arobo_app/repository/repository.dart';

class FaqRepository {
  final Repository _repository = Repository();

  static const List<Map<String, dynamic>> _fallbackFaqs = [
    {
      'faqs': [
        {
          'question': 'How do I know if a trek organizer is trustworthy?',
          'answer':
              'Every organizer completes identity, business and bank verification with Aorbo before they can list treks, and our team reviews every trek before it goes live. You can also read reviews from past travellers on each trek.',
          'is_active': true,
          'chat_support': false,
          'tags': ['trust', 'safety'],
        },
        {
          'question': 'Will you arrange the stays during the trek?',
          'answer':
              'Stays are arranged by the trek organizer. Each trek page lists exactly what is included — stays, meals, transport — so check it before you book.',
          'is_active': true,
          'chat_support': false,
          'tags': ['stay', 'support'],
        },
        {
          'question': 'Can I customize my trek itinerary?',
          'answer':
              'No — each trek follows the itinerary set by its organizer and reviewed by Aorbo. You choose the date, boarding point and number of travellers when you book.',
          'is_active': true,
          'chat_support': true,
          'tags': ['itinerary', 'cancellation'],
        },
      ],
    },
  ];

  /// Fetches public customer-facing FAQs grouped by active categories.
  Future<List<dynamic>> fetchCustomerFaqs() async {
    final candidates = <String>[
      NetworkUrl.getFaqs,
      '${AppEnv().apiBaseUrl}/api/customer/faqs',
      '${AppEnv().apiBaseUrl}/api/v1/customer/faqs',
    ];

    for (final endpoint in candidates) {
      try {
        final response = await _repository.getApiCall(url: endpoint);
        if (response != null && response['success'] == true) {
          return response['data'] as List<dynamic>;
        }
      } catch (e) {
        final message = e.toString().toLowerCase();
        if (message.contains('404') || message.contains('route not found')) {
          continue;
        }
        log('Error fetching FAQs from $endpoint: $e');
        break;
      }
    }

    return _fallbackFaqs;
  }

  /// Queries the backend chatbot reply endpoint with the user's message.
  Future<Map<String, dynamic>?> fetchChatbotReply(String message) async {
    final encodedMessage = Uri.encodeComponent(message);
    final candidates = <String>[
      NetworkUrl.chatbotReply(message),
      '${AppEnv().apiBaseUrl}/api/customer/chatbot/reply?message=$encodedMessage',
      '${AppEnv().apiBaseUrl}/api/v1/customer/chatbot/reply?message=$encodedMessage',
    ];

    for (final endpoint in candidates) {
      try {
        final response = await _repository.getApiCall(url: endpoint);
        if (response != null && response['success'] == true) {
          return response as Map<String, dynamic>;
        }
      } catch (e) {
        final messageText = e.toString().toLowerCase();
        if (messageText.contains('404') || messageText.contains('route not found')) {
          continue;
        }
        log('Error getting chatbot reply from $endpoint: $e');
        break;
      }
    }

    return {
      'success': true,
      'data': {
        'reply': 'I can help with trek planning, bookings, support, and cancellations. Try asking about your itinerary or booking status.',
      },
    };
  }

  /// Pull live FAQ data for the customer-facing chat experience.
  Future<List<dynamic>> fetchFaqCategories() async {
    try {
      final response = await _repository.getApiCall(url: NetworkUrl.getFaqs);
      if (response != null && response['success'] == true) {
        return response['data'] as List<dynamic>;
      }
      return _fallbackFaqs;
    } catch (e) {
      log('Error fetching FAQ categories: $e');
      return _fallbackFaqs;
    }
  }
}
