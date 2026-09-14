import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../controller/ticket_controller.dart';
import '../theme/app_tokens.dart';
import '../theme/app_typography.dart';
import '../utils/screen_constants.dart';
import '../widgets/app_shimmer.dart';
import 'ticket_detail_screen.dart';

class _TC {
  static const open = AppColors.info;
  static const inProgress = AppColors.warning;
  static const resolved = AppColors.success;
  static const closed = AppColors.inkLight;
  static const escalated = AppColors.danger;
}

Color _statusColor(String status) {
  switch (status.toLowerCase()) {
    case 'open':
    case 'pending':
      return _TC.open;
    case 'in_progress':
      return _TC.inProgress;
    case 'resolved':
      return _TC.resolved;
    case 'closed':
      return _TC.closed;
    case 'escalated':
      return _TC.escalated;
    default:
      return AppColors.inkLight;
  }
}

String _statusLabel(String status) {
  if (status.isEmpty) return status;
  return status
      .split('_')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');
}

class MyTicketsScreen extends StatefulWidget {
  const MyTicketsScreen({super.key});

  @override
  State<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen> {
  final TicketController _ticketC = Get.put(TicketController());

  @override
  void initState() {
    super.initState();
    _ticketC.fetchMyTickets();
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
          'My Tickets',
          style: AppType.style(FontSize.s15, w: FontWeight.w600, color: AppColors.ink),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.forest,
        onRefresh: _ticketC.fetchMyTickets,
        child: Obx(() {
          if (_ticketC.isLoading.value && _ticketC.tickets.isEmpty) {
            return ListView(
              padding: EdgeInsets.all(4.w),
              children: List.generate(
                4,
                (_) => Padding(
                  padding: EdgeInsets.only(bottom: 2.h),
                  child: AppShimmer(
                    child: Container(
                      height: 12.h,
                      decoration: BoxDecoration(
                        color: AppColors.elevated,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }

          if (_ticketC.tickets.isEmpty) {
            return ListView(
              children: [
                SizedBox(height: 14.h),
                _buildEmptyState(),
              ],
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(4.w),
            itemCount: _ticketC.tickets.length,
            itemBuilder: (context, i) => _TicketCard(ticket: _ticketC.tickets[i]),
          );
        }),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 22.w,
              height: 22.w,
              decoration: BoxDecoration(
                color: AppColors.forestSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.confirmation_number_outlined, size: 9.w, color: AppColors.forest),
            ),
            SizedBox(height: 2.4.h),
            Text(
              'No tickets yet',
              textAlign: TextAlign.center,
              style: AppType.style(FontSize.s14, w: FontWeight.w700, color: AppColors.ink),
            ),
            SizedBox(height: 0.7.h),
            Text(
              'When you report an issue or raise a support request, it will show up here with the latest status.',
              textAlign: TextAlign.center,
              style: AppType.style(FontSize.s10, color: AppColors.inkMid, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final TicketItem ticket;
  const _TicketCard({required this.ticket});

  String _formatDate(DateTime? d) {
    if (d == null) return '-';
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(ticket.status);
    return GestureDetector(
      onTap: () => Get.to(() => TicketDetailScreen(ticketId: ticket.id)),
      child: Container(
        margin: EdgeInsets.only(bottom: 2.h),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
          boxShadow: AppShadows.soft(),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    ticket.subject?.isNotEmpty == true
                        ? ticket.subject!
                        : (ticket.issueType ?? 'Support ticket'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppType.style(FontSize.s12, w: FontWeight.w700, color: AppColors.ink),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    border: Border.all(color: color.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    _statusLabel(ticket.status),
                    style: AppType.style(FontSize.s8, w: FontWeight.w700, color: color),
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.h),
            Text(
              ticket.ticketId ?? '#${ticket.id}',
              style: AppType.style(FontSize.s9, color: AppColors.inkLight),
            ),
            if (ticket.bookingNumber != null) ...[
              SizedBox(height: 0.4.h),
              Text(
                'Booking ${ticket.bookingNumber}',
                style: AppType.style(FontSize.s9, color: AppColors.inkMid),
              ),
            ],
            SizedBox(height: 1.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(ticket.createdAt),
                  style: AppType.style(FontSize.s8, color: AppColors.inkLight),
                ),
                if (ticket.hasBouncedReply)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline_rounded, size: 3.2.w, color: AppColors.danger),
                      SizedBox(width: 1.w),
                      Text(
                        'Reply undelivered',
                        style: AppType.style(FontSize.s8, w: FontWeight.w600, color: AppColors.danger),
                      ),
                    ],
                  )
                else
                  Icon(Icons.arrow_forward_rounded, size: 4.w, color: AppColors.inkLight),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
