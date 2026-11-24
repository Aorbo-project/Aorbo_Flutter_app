// The ticket an organiser sold directly, as the customer sees it in the app
// (owner, 24 Nov 2026). View-only for money: no cancel / refund / pay buttons.
// Contact the organiser for changes; rate & review after the trip; "Not my booking".

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../freezed_models/booking/booking_history_model.dart';
import '../theme/app_tokens.dart';
import '../theme/app_typography.dart';
import '../utils/ist_date_utils.dart';
import '../utils/screen_constants.dart';
import 'offline_ticket.dart';

class _T {
  static const ink = AppColors.inkStrong;
  static const inkMid = Color(0xFF64748B);
  static const inkFaint = Color(0xFF94A3B8);
  static const hairline = Color(0xFFDDE3EC);
  static const accent = AppColors.teal;
  static const accentSoft = AppColors.tealSoft;
}

class OfflineTicketScreen extends StatelessWidget {
  const OfflineTicketScreen({super.key, required this.booking, required this.details});

  final BookingHistoryData booking;
  final OfflineTicketDetails details;

  bool get _completed => (booking.trekStatus ?? '').toLowerCase() == 'completed';

  String _date(String? raw) {
    final dt = raw == null ? null : ISTDateUtils.toIST(raw);
    if (dt == null) return raw ?? '-';
    const d = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d[dt.weekday - 1]}, ${dt.day} ${m[dt.month - 1]} ${dt.year}';
  }

  String _inr(double v) {
    final s = v.round().toString();
    if (s.length <= 3) return '₹$s';
    final last3 = s.substring(s.length - 3);
    var rest = s.substring(0, s.length - 3);
    final parts = <String>[];
    while (rest.length > 2) {
      parts.insert(0, rest.substring(rest.length - 2));
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) parts.insert(0, rest);
    return '₹${parts.join(',')},$last3';
  }

  // Preview build: never dial or message anyone.
  void _contact(String what, String who) {
    Get.snackbar('Sample screen', 'Would $what $who', snackPosition: SnackPosition.BOTTOM, margin: EdgeInsets.all(4.w));
  }

  @override
  Widget build(BuildContext context) {
    final trek = booking.trek;
    final headline = (trek?.destination?.name ?? '').isNotEmpty ? trek!.destination!.name! : (trek?.title ?? '-');

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: _T.ink), onPressed: Get.back),
        title: Text('Your ticket', style: AppType.style(FontSize.s14, w: FontWeight.w700, color: _T.ink)),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 4.h),
        children: [
          // ── Header ──
          _card(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.6.w, vertical: 0.6.h),
                decoration: BoxDecoration(color: _T.accentSoft, borderRadius: BorderRadius.circular(20)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.storefront_rounded, size: 3.6.w, color: _T.accent),
                  SizedBox(width: 1.4.w),
                  Flexible(
                    child: Text('Booked directly with ${details.organiserName}',
                        style: AppType.style(FontSize.s9, w: FontWeight.w600, color: _T.accent)),
                  ),
                ]),
              ),
              SizedBox(height: 1.6.h),
              Text(headline, style: AppType.style(FontSize.s18, w: FontWeight.w800, color: _T.ink)),
              if ((trek?.title ?? '').isNotEmpty && trek!.title != headline) ...[
                SizedBox(height: 0.4.h),
                Text(trek.title!, style: AppType.style(FontSize.s10, color: _T.inkMid)),
              ],
              SizedBox(height: 1.4.h),
              Row(children: [
                Icon(Icons.event_rounded, size: 4.w, color: _T.inkMid),
                SizedBox(width: 1.6.w),
                Text(_date(booking.batch?.startDate), style: AppType.style(FontSize.s11, w: FontWeight.w600, color: _T.ink)),
                const Spacer(),
                _statusBadge(),
              ]),
              SizedBox(height: 1.2.h),
              Text('Ticket ${details.ticketNumber}', style: AppType.style(FontSize.s9, color: _T.inkFaint)),
            ],
          ),

          // ── Pickup ──
          _section('Pickup', Icons.directions_bus_rounded, [
            Text(details.pickupPoint, style: AppType.style(FontSize.s12, w: FontWeight.w600, color: _T.ink)),
            SizedBox(height: 0.4.h),
            Text(details.pickupTime, style: AppType.style(FontSize.s10, color: _T.inkMid)),
          ]),

          // ── Captain ──
          _section('Captain', Icons.flag_rounded, [
            Row(children: [
              Expanded(child: Text(details.captainName, style: AppType.style(FontSize.s12, w: FontWeight.w600, color: _T.ink))),
              _pillButton(Icons.call_rounded, 'Call', () => _contact('call', details.captainName)),
            ]),
          ]),

          // ── Travellers ──
          _section('${details.travellers.length} traveller${details.travellers.length == 1 ? '' : 's'}', Icons.group_rounded, [
            for (final t in details.travellers)
              Padding(
                padding: EdgeInsets.only(bottom: 0.5.h),
                child: Text(t, style: AppType.style(FontSize.s11, color: _T.ink)),
              ),
          ]),

          // ── Payment (read-only) ──
          _section('Payment', Icons.receipt_long_rounded, [
            _moneyRow('Paid to organiser', _inr(details.paid)),
            if (details.due > 0) _moneyRow('Due at pickup', _inr(details.due), strong: true),
            Divider(height: 2.h, color: _T.hairline),
            _moneyRow('Total', _inr(details.total)),
            SizedBox(height: 0.8.h),
            Text('Paid directly to ${details.organiserName}. Aorbo did not take this payment.',
                style: AppType.style(FontSize.s9, color: _T.inkFaint)),
          ]),

          // ── Changes go to the organiser ──
          Container(
            margin: EdgeInsets.only(top: 1.6.h),
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppColors.amberSoft,
              borderRadius: BorderRadius.circular(3.5.w),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Changes or cancellation?', style: AppType.style(FontSize.s11, w: FontWeight.w700, color: _T.ink)),
              SizedBox(height: 0.5.h),
              Text('You booked this trip with ${details.organiserName} directly. Contact them for any change.',
                  style: AppType.style(FontSize.s10, color: _T.inkMid, height: 1.35)),
              SizedBox(height: 1.4.h),
              Row(children: [
                Expanded(child: _outlineButton(Icons.call_rounded, 'Call', () => _contact('call', details.organiserName))),
                SizedBox(width: 3.w),
                Expanded(child: _outlineButton(Icons.chat_rounded, 'WhatsApp', () => _contact('message', details.organiserName))),
              ]),
            ]),
          ),

          // ── Rate & review ──
          SizedBox(height: 2.2.h),
          if (_completed)
            SizedBox(
              height: 6.h,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _T.ink,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3.w)),
                ),
                onPressed: () => _contact('open rating for', headline),
                icon: const Icon(Icons.star_rounded, color: AppColors.gold),
                label: Text('Rate & review', style: AppType.style(FontSize.s12, w: FontWeight.w700, color: Colors.white)),
              ),
            )
          else
            Center(
              child: Text('You can rate this trip after it ends.',
                  style: AppType.style(FontSize.s9, color: _T.inkFaint)),
            ),

          // ── Wrong number ──
          SizedBox(height: 2.4.h),
          Center(
            child: TextButton(
              onPressed: () => _confirmNotMine(context),
              child: Text('Not my booking', style: AppType.style(FontSize.s10, w: FontWeight.w600, color: AppColors.danger)),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmNotMine(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.fromLTRB(5.w, 3.h, 5.w, 3.h),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Not your booking?', style: AppType.style(FontSize.s14, w: FontWeight.w700, color: _T.ink)),
          SizedBox(height: 1.h),
          Text('We\'ll hide it from your account and tell ${details.organiserName} the phone number may be wrong.',
              style: AppType.style(FontSize.s10, color: _T.inkMid, height: 1.35)),
          SizedBox(height: 2.4.h),
          Row(children: [
            Expanded(child: _outlineButton(Icons.close_rounded, 'Keep it', Get.back)),
            SizedBox(width: 3.w),
            Expanded(
              child: SizedBox(
                height: 5.6.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.danger,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3.w)),
                  ),
                  onPressed: () {
                    Get.back();
                    _contact('hide this ticket and tell', details.organiserName);
                  },
                  child: Text('Hide it', style: AppType.style(FontSize.s11, w: FontWeight.w700, color: Colors.white)),
                ),
              ),
            ),
          ]),
        ]),
      ),
    );
  }

  Widget _statusBadge() {
    final c = _completed ? AppColors.success : AppColors.info;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.4.w, vertical: 0.4.h),
      decoration: BoxDecoration(color: c.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(_completed ? 'Completed' : 'Upcoming', style: AppType.style(FontSize.s9, w: FontWeight.w700, color: c)),
    );
  }

  Widget _card({required List<Widget> children}) => Container(
        padding: EdgeInsets.all(4.5.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(3.8.w),
          border: Border.all(color: _T.hairline),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
      );

  Widget _section(String title, IconData icon, List<Widget> body) => Padding(
        padding: EdgeInsets.only(top: 1.6.h),
        child: _card(children: [
          Row(children: [
            Icon(icon, size: 4.w, color: _T.inkMid),
            SizedBox(width: 1.6.w),
            Text(title.toUpperCase(),
                style: AppType.style(FontSize.s8, w: FontWeight.w700, color: _T.inkFaint, letterSpacing: 1)),
          ]),
          SizedBox(height: 1.2.h),
          ...body,
        ]),
      );

  Widget _moneyRow(String label, String value, {bool strong = false}) => Padding(
        padding: EdgeInsets.only(bottom: 0.6.h),
        child: Row(children: [
          Expanded(child: Text(label, style: AppType.style(FontSize.s10, color: _T.inkMid))),
          Text(value,
              style: AppType.style(strong ? FontSize.s12 : FontSize.s11,
                  w: strong ? FontWeight.w800 : FontWeight.w600, color: strong ? AppColors.amber : _T.ink)),
        ]),
      );

  Widget _pillButton(IconData icon, String label, VoidCallback onTap) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 3.4.w, vertical: 0.8.h),
          decoration: BoxDecoration(color: _T.accentSoft, borderRadius: BorderRadius.circular(20)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 3.8.w, color: _T.accent),
            SizedBox(width: 1.2.w),
            Text(label, style: AppType.style(FontSize.s10, w: FontWeight.w700, color: _T.accent)),
          ]),
        ),
      );

  Widget _outlineButton(IconData icon, String label, VoidCallback onTap) => SizedBox(
        height: 5.6.h,
        child: OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: _T.ink,
            side: const BorderSide(color: _T.hairline),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3.w)),
          ),
          onPressed: onTap,
          icon: Icon(icon, size: 4.2.w),
          label: Text(label, style: AppType.style(FontSize.s11, w: FontWeight.w600, color: _T.ink)),
        ),
      );
}
