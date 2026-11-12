import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Trek Route card extras (owner, 12 Nov 2026): each stop's tag ("Boarding",
/// "Meeting point", "Return starts", "Arrival · back home") and the travel line on
/// the two long legs ("≈ 11 h overnight bus"). The server works both out
/// (Backend utils/returnJourney.js routeTags); the app only shows them, and shows
/// nothing when the server sends nothing (older server, bad data).

/// Tag colours per server role: (background, text).
(Color, Color) routeTagColors(String? role) {
  switch (role) {
    case 'boarding':
      return (const Color(0xFFDCFCE7), const Color(0xFF166534));
    case 'meeting_point':
    case 'meeting_and_return':
      return (const Color(0xFFE0F2FE), const Color(0xFF075985));
    case 'return_start':
      return (const Color(0xFFF3E8FF), const Color(0xFF6B21A8));
    case 'arrival':
      return (const Color(0xFFFEE2E2), const Color(0xFF991B1B));
    default:
      return (const Color(0xFFF1F5F9), const Color(0xFF334155));
  }
}

/// "Thu 26/11" from a stop's "YYYY-MM-DD hh:mm AM", or "" when unreadable.
String routeStopDate(String? dateTime) {
  if (dateTime == null || dateTime.trim().isEmpty) return '';
  try {
    final d = DateFormat('yyyy-MM-dd hh:mm a').parseStrict(dateTime.trim());
    return DateFormat('EEE dd/MM').format(d);
  } catch (_) {
    return '';
  }
}

/// The tag and the travel line under a stop's name. Empty when there is nothing to show.
class RouteStopExtras extends StatelessWidget {
  const RouteStopExtras({
    super.key,
    required this.role,
    required this.label,
    required this.travelLabel,
    required this.isLast,
    this.fontSize = 10,
  });

  final String? role;
  final String? label;
  final String? travelLabel;
  final bool isLast;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final tag = (label ?? '').trim();
    // A travel line leads to the NEXT stop, so the last stop never shows one.
    final travel = isLast ? '' : (travelLabel ?? '').trim();
    if (tag.isEmpty && travel.isEmpty) return const SizedBox.shrink();
    final (bg, fg) = routeTagColors(role);
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (tag.isNotEmpty)
            Container(
              key: const ValueKey('route-stop-tag'),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
              child: Text(
                tag,
                textScaler: const TextScaler.linear(1.0),
                style: TextStyle(fontSize: fontSize * 0.85, fontWeight: FontWeight.w600, color: fg),
              ),
            ),
          if (travel.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: tag.isNotEmpty ? 6 : 0),
              child: Container(
                key: const ValueKey('route-stop-travel'),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(999)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.schedule_outlined, size: fontSize, color: const Color(0xFF475569)),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        travel,
                        textScaler: const TextScaler.linear(1.0),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: fontSize * 0.85, color: const Color(0xFF475569)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
