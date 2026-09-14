import 'package:get/get.dart';

import '../repository/network_url.dart';
import '../repository/repository.dart';
import '../widgets/logger.dart';

class TicketItem {
  final int id;
  final String? ticketId;
  final String? subject;
  final String? channel;
  final int? bookingId;
  final String? bookingNumber;
  final String? tbrId;
  final String? issueType;
  final String status;
  final String priority;
  final DateTime? createdAt;
  final DateTime? resolvedAt;
  final bool hasBouncedReply;

  TicketItem({
    required this.id,
    this.ticketId,
    this.subject,
    this.channel,
    this.bookingId,
    this.bookingNumber,
    this.tbrId,
    this.issueType,
    required this.status,
    required this.priority,
    this.createdAt,
    this.resolvedAt,
    this.hasBouncedReply = false,
  });

  factory TicketItem.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) =>
        v == null ? null : DateTime.tryParse(v.toString());
    return TicketItem(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      ticketId: json['ticket_id']?.toString(),
      subject: json['subject']?.toString(),
      channel: json['channel']?.toString(),
      bookingId: json['booking_id'] is int
          ? json['booking_id']
          : int.tryParse('${json['booking_id']}'),
      bookingNumber: json['booking_number']?.toString(),
      tbrId: json['tbr_id']?.toString(),
      issueType: json['issue_type']?.toString(),
      status: json['status']?.toString() ?? 'open',
      priority: json['priority']?.toString() ?? 'medium',
      createdAt: parseDate(json['created_at']),
      resolvedAt: parseDate(json['resolved_at']),
      hasBouncedReply: json['has_bounced_reply'] == true,
    );
  }
}

class TicketMessageItem {
  final int id;
  final String direction; // 'inbound' | 'outbound'
  final String authorType; // 'customer' | 'vendor' | 'staff' | 'system'
  final String? authorDisplayName;
  final String bodyText;
  final String? status; // outbound delivery: sent/delivered/bounced/failed/queued
  final DateTime? createdAt;
  final List<TicketAttachmentItem> attachments;

  bool get isFromAgent => authorType == 'staff' || authorType == 'system';

  TicketMessageItem({
    required this.id,
    required this.direction,
    required this.authorType,
    this.authorDisplayName,
    required this.bodyText,
    this.status,
    this.createdAt,
    this.attachments = const [],
  });

  factory TicketMessageItem.fromJson(Map<String, dynamic> json) {
    return TicketMessageItem(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      direction: json['direction']?.toString() ?? 'inbound',
      authorType: json['author_type']?.toString() ?? 'customer',
      authorDisplayName: json['author_display_name']?.toString(),
      bodyText: json['body_text']?.toString() ?? '',
      status: json['status']?.toString(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.tryParse(json['created_at'].toString()),
      attachments: (json['attachments'] as List<dynamic>? ?? [])
          .map((e) => TicketAttachmentItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class TicketAttachmentItem {
  final int id;
  final String fileName;
  final String? mimeType;
  final String storageUrl;

  TicketAttachmentItem({
    required this.id,
    required this.fileName,
    this.mimeType,
    required this.storageUrl,
  });

  factory TicketAttachmentItem.fromJson(Map<String, dynamic> json) {
    return TicketAttachmentItem(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      fileName: json['file_name']?.toString() ?? 'attachment',
      mimeType: json['mime_type']?.toString(),
      storageUrl: json['storage_url']?.toString() ?? '',
    );
  }
}

/// Support-ticket list + thread. Mirrors NotificationController's shape
/// (plain GetxController, .obs state, Repository().getApiCall) rather than
/// adding to TrekController, which already spans ~20 unrelated concerns.
class TicketController extends GetxController {
  final Repository repository = Repository();

  final tickets = <TicketItem>[].obs;
  final isLoading = false.obs;
  String? error;

  final messages = <TicketMessageItem>[].obs;
  final isMessagesLoading = false.obs;

  Future<void> fetchMyTickets() async {
    try {
      isLoading.value = true;
      final response = await repository.getApiCall(url: NetworkUrl.myTickets);
      if (response != null && response['success'] == true) {
        final List<dynamic> rows = response['data'] ?? [];
        tickets.assignAll(
          rows.map((e) => TicketItem.fromJson(e as Map<String, dynamic>)).toList(),
        );
        error = null;
      } else {
        error = 'Failed to load tickets';
      }
    } catch (e) {
      logger.e('fetchMyTickets error: $e');
      error = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchTicketMessages(int ticketId) async {
    try {
      isMessagesLoading.value = true;
      final response = await repository.getApiCall(
        url: NetworkUrl.ticketMessages(ticketId),
      );
      if (response != null && response['success'] == true) {
        final List<dynamic> rows = response['data'] ?? [];
        messages.assignAll(
          rows
              .map((e) => TicketMessageItem.fromJson(e as Map<String, dynamic>))
              .toList(),
        );
      }
    } catch (e) {
      logger.e('fetchTicketMessages error: $e');
    } finally {
      isMessagesLoading.value = false;
    }
  }
}
