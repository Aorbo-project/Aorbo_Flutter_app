import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../controller/ticket_controller.dart';
import '../theme/app_tokens.dart';
import '../theme/app_typography.dart';
import '../utils/screen_constants.dart';
import '../widgets/app_shimmer.dart';

class TicketDetailScreen extends StatefulWidget {
  final int ticketId;
  const TicketDetailScreen({super.key, required this.ticketId});

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  // Same TicketController instance the list screen already registered
  // (Get.find, not Get.put) — one shared source of truth, matching the
  // DashboardController reuse pattern in booking_upcoming_screen.dart.
  late final TicketController _ticketC;

  @override
  void initState() {
    super.initState();
    _ticketC = Get.isRegistered<TicketController>()
        ? Get.find<TicketController>()
        : Get.put(TicketController());
    _ticketC.fetchTicketMessages(widget.ticketId);
  }

  String _formatDateTime(DateTime? d) {
    if (d == null) return '';
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final hour = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final ampm = d.hour < 12 ? 'AM' : 'PM';
    final minute = d.minute.toString().padLeft(2, '0');
    return '${d.day} ${months[d.month - 1]}, $hour:$minute $ampm';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Ticket #${widget.ticketId}',
          style: AppType.style(FontSize.s14, w: FontWeight.w600, color: AppColors.ink),
        ),
      ),
      body: Obx(() {
        if (_ticketC.isMessagesLoading.value) {
          return ListView(
            padding: EdgeInsets.all(4.w),
            children: List.generate(
              3,
              (_) => Padding(
                padding: EdgeInsets.only(bottom: 2.h),
                child: const LineSkeleton(widthFactor: 0.8, height: 6),
              ),
            ),
          );
        }

        final messages = _ticketC.messages;
        if (messages.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.chat_bubble_outline_rounded, size: 12.w, color: AppColors.inkLight),
                  SizedBox(height: 2.h),
                  Text(
                    'No replies yet',
                    style: AppType.style(FontSize.s12, w: FontWeight.w700, color: AppColors.ink),
                  ),
                  SizedBox(height: 0.8.h),
                  Text(
                    'Our support team will reply here — you\'ll also get an email when they do.',
                    textAlign: TextAlign.center,
                    style: AppType.style(FontSize.s10, color: AppColors.inkMid, height: 1.5),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(4.w),
          itemCount: messages.length,
          itemBuilder: (context, i) => _MessageBubble(message: messages[i], formatDate: _formatDateTime),
        );
      }),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final TicketMessageItem message;
  final String Function(DateTime?) formatDate;
  const _MessageBubble({required this.message, required this.formatDate});

  @override
  Widget build(BuildContext context) {
    final isFromAgent = message.isFromAgent;
    return Align(
      alignment: isFromAgent ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(maxWidth: 78.w),
        margin: EdgeInsets.only(bottom: 1.6.h),
        padding: EdgeInsets.symmetric(horizontal: 3.8.w, vertical: 1.4.h),
        decoration: BoxDecoration(
          color: isFromAgent ? AppColors.elevated : AppColors.forestSoft,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isFromAgent ? 4 : AppRadius.lg),
            topRight: Radius.circular(isFromAgent ? AppRadius.lg : 4),
            bottomLeft: Radius.circular(AppRadius.lg),
            bottomRight: Radius.circular(AppRadius.lg),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isFromAgent)
              Padding(
                padding: EdgeInsets.only(bottom: 0.4.h),
                child: Text(
                  'Aorbo Support',
                  style: AppType.style(FontSize.s8, w: FontWeight.w700, color: AppColors.forest),
                ),
              ),
            Text(
              message.bodyText,
              style: AppType.style(FontSize.s11, color: AppColors.ink, height: 1.4),
            ),
            if (message.attachments.isNotEmpty) ...[
              SizedBox(height: 1.h),
              ...message.attachments.map(
                (a) => Padding(
                  padding: EdgeInsets.only(bottom: 0.4.h),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.attach_file_rounded, size: 3.2.w, color: AppColors.inkMid),
                      SizedBox(width: 1.w),
                      Flexible(
                        child: Text(
                          a.fileName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppType.style(FontSize.s9, color: AppColors.info),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            SizedBox(height: 0.5.h),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  formatDate(message.createdAt),
                  style: AppType.style(FontSize.s7, color: AppColors.inkLight),
                ),
                // 'failed' (never queued) and 'bounced' (a future inbound
                // bounce webhook, not built yet) both mean the same thing to
                // the customer: this reply may not have reached your inbox.
                if (message.status == 'bounced' || message.status == 'failed') ...[
                  SizedBox(width: 1.5.w),
                  Icon(Icons.error_outline_rounded, size: 2.8.w, color: AppColors.danger),
                  SizedBox(width: 0.5.w),
                  Text(
                    'Delivery failed',
                    style: AppType.style(FontSize.s7, w: FontWeight.w600, color: AppColors.danger),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
