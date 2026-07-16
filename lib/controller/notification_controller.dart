import 'package:get/get.dart';

import '../repository/network_url.dart';
import '../repository/repository.dart';
import '../widgets/logger.dart';

class NotificationItem {
  final int id;
  final String title;
  final String message;
  final DateTime? createdAt;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.isRead,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      isRead: json['is_read'] == true,
    );
  }
}

/// Backs the in-app notification inbox (NotificationScreen) with the real
/// backend endpoint (GET /api/v1/customer/notifications) instead of the
/// hardcoded sample list that used to live directly in the screen — the
/// endpoint already existed and was already populated by every push the
/// backend sends, the Flutter app just never called it.
class NotificationController extends GetxController {
  final Repository repository = Repository();

  final notifications = <NotificationItem>[].obs;
  final isLoading = false.obs;
  final unreadCount = 0.obs;
  String? error;

  Future<void> fetchNotifications() async {
    try {
      isLoading.value = true;
      final response = await repository.getApiCall(url: NetworkUrl.notifications);
      if (response != null && response['success'] == true) {
        final data = response['data'];
        final List<dynamic> rows = data?['notifications'] ?? [];
        notifications.value = rows
            .map((e) => NotificationItem.fromJson(e as Map<String, dynamic>))
            .toList();
        unreadCount.value = data?['unread_count'] is int ? data['unread_count'] : 0;
        error = null;
      } else {
        error = 'Failed to load notifications';
      }
    } catch (e) {
      logger.e('fetchNotifications error: $e');
      error = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAsRead(NotificationItem item) async {
    if (item.isRead) return;
    item.isRead = true;
    notifications.refresh();
    if (unreadCount.value > 0) unreadCount.value--;
    try {
      await repository.putApiCall(url: NetworkUrl.notificationRead(item.id), body: {});
    } catch (e) {
      logger.e('markAsRead error: $e');
    }
  }

  Future<void> markAllAsRead() async {
    for (final n in notifications) {
      n.isRead = true;
    }
    notifications.refresh();
    unreadCount.value = 0;
    try {
      await repository.putApiCall(url: NetworkUrl.notificationReadAll, body: {});
    } catch (e) {
      logger.e('markAllAsRead error: $e');
    }
  }
}
