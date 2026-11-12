import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../freezed_models/treks/trek_detail_model.dart';
import '../../theme/app_tokens.dart';
import '../custom_network_image.dart';
import '../tap_target.dart';

/// The trek page's redesign (owner, 12–13 Nov 2026: "eye-catchy … brand colours only,
/// softly"). Only the brand's forest green, yellow and ink, in soft tints. Every value
/// shown comes from the trek detail the server sends; nothing is worked out here except
/// how to word it. Tests: test/widgets/trek_page_parts_test.dart.
class TrekPageColors {
  static const forestDeep = AppColors.forestDeep;
  static const forest = AppColors.forest;
  static const forestSoft = AppColors.forestSoft;
  static const yellow = AppColors.brandYellow;
  static const yellowSoft = Color(0xFFFFFBD6);
  static const yellowInk = Color(0xFF5C5200);
  static const ink = AppColors.ink;
  static const inkMid = AppColors.inkMid;
  static const inkLight = AppColors.inkLight;
  static const bg = Color(0xFFF4F7F5);
  static const card = Colors.white;
  static const line = Color(0xFFE6ECE8);
}

// ── Key facts ──────────────────────────────────────────────────────────────────────────

/// What the floating card says, worked out from the server's trek detail. Each item is
/// null when the server sent nothing to say it with (that column is then left out).
class TrekKeyFacts {
  const TrekKeyFacts({this.date, this.duration, this.departTime, this.fromCity, this.backDate, this.backTime});

  final String? date; // "Thu 26 Nov"
  final String? duration; // "3 days · 2 nights"
  final String? departTime; // "7:00 PM"
  final String? fromCity; // "From Hyderabad"
  final String? backDate; // "Sun 29 Nov"
  final String? backTime; // "Back 7:30 AM"
}

final _stageFmt = DateFormat('yyyy-MM-dd hh:mm a');
final _dayFmt = DateFormat('EEE d MMM');
final _timeFmt = DateFormat('h:mm a');

DateTime? _stageTime(String? v) {
  if (v == null || v.trim().isEmpty) return null;
  try {
    return _stageFmt.parseStrict(v.trim());
  } catch (_) {
    return null;
  }
}

DateTime? _ymd(String? v) {
  final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch((v ?? '').trim());
  if (m == null) return null;
  final d = DateTime(int.parse(m[1]!), int.parse(m[2]!), int.parse(m[3]!));
  return d.month == int.parse(m[2]!) ? d : null;
}

String _plural(int n, String one) => '$n $one${n == 1 ? '' : 's'}';

/// The key facts for the customer's city (`cityId`; null = the trek's only / earliest one).
TrekKeyFacts trekKeyFacts(TrekDetailData d, {int? cityId}) {
  final stages = d.trekStages ?? const <TrekStages>[];
  bool sameCity(TrekStages s) => cityId == null || s.cityId == cityId;

  final boardings = stages.where((s) => (s.isBoardingPoint == true || s.stageName == 'boarding') && sameCity(s)).toList()
    ..sort((a, b) => (_stageTime(a.dateTime) ?? DateTime(9999)).compareTo(_stageTime(b.dateTime) ?? DateTime(9999)));
  final boarding = boardings.isEmpty ? null : boardings.first;
  final cities = stages.where((s) => s.isBoardingPoint == true && s.cityId != null).map((s) => s.cityId).toSet();

  // The arrival is the server's own tag (Backend utils/returnJourney routeTags).
  final arrivals = stages.where((s) => s.routeRole == 'arrival' && sameCity(s)).toList();
  final arrival = arrivals.length == 1 ? arrivals.first : null;

  final start = _stageTime(boarding?.dateTime) ?? _ymd(d.startDate);
  final back = _stageTime(arrival?.dateTime);

  final days = d.durationDays ?? 0;
  final nights = d.durationNights ?? (days > 0 ? days - 1 : 0);

  String? from;
  if (boarding?.city?.cityName?.trim().isNotEmpty == true && (cityId != null || cities.length <= 1)) {
    from = 'From ${boarding!.city!.cityName!.trim()}';
  } else if (cities.length > 1) {
    from = 'From ${cities.length} cities';
  }

  return TrekKeyFacts(
    date: start == null ? null : _dayFmt.format(start),
    duration: days > 0 ? '${_plural(days, 'day')} · ${_plural(nights, 'night')}' : null,
    departTime: (cityId != null || cities.length <= 1) ? (_stageTime(boarding?.dateTime) == null ? null : _timeFmt.format(_stageTime(boarding!.dateTime)!)) : null,
    fromCity: from,
    backDate: back == null ? null : _dayFmt.format(back),
    backTime: back == null ? null : 'Back ${_timeFmt.format(back)}',
  );
}

/// The floating card under the photo: date, departure, back home.
class TrekKeyFactsCard extends StatelessWidget {
  const TrekKeyFactsCard({super.key, required this.facts});

  final TrekKeyFacts facts;

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      if (facts.date != null || facts.duration != null)
        _fact(Icons.calendar_month_rounded, TrekPageColors.forestSoft, TrekPageColors.forest, facts.date ?? '', facts.duration ?? ''),
      if (facts.departTime != null || facts.fromCity != null)
        _fact(Icons.directions_bus_rounded, TrekPageColors.yellowSoft, TrekPageColors.yellowInk, facts.departTime ?? '', facts.fromCity ?? ''),
      if (facts.backDate != null)
        _fact(Icons.home_rounded, TrekPageColors.forestSoft, TrekPageColors.forestDeep, facts.backDate!, facts.backTime ?? ''),
    ];
    if (items.isEmpty) return const SizedBox.shrink();
    return Container(
      key: const ValueKey('trek-key-facts'),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: TrekPageColors.card,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: TrekPageColors.forestDeep.withValues(alpha: 0.10), blurRadius: 24, offset: const Offset(0, 8))],
      ),
      child: Row(children: [for (final w in items) Expanded(child: w)]),
    );
  }

  Widget _fact(IconData icon, Color bg, Color fg, String main, String sub) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
          child: Icon(icon, size: 20, color: fg),
        ),
        const SizedBox(height: 6),
        if (main.isNotEmpty)
          Text(main, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, textScaler: const TextScaler.linear(1.0),
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w700, color: TrekPageColors.ink)),
        if (sub.isNotEmpty)
          Text(sub, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, textScaler: const TextScaler.linear(1.0),
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: TrekPageColors.inkMid)),
      ],
    );
  }
}

// ── Photo header ───────────────────────────────────────────────────────────────────────

/// The big photo with the destination on it (destination = the heading, owner rule).
class TrekHeroPhotos extends StatefulWidget {
  const TrekHeroPhotos({
    super.key,
    required this.imageUrls,
    required this.destination,
    required this.organiser,
    this.organiserLogo,
    this.tags = const [],
    this.onImageTap,
  });

  final List<String> imageUrls;
  final String destination;
  final String organiser;
  final String? organiserLogo;
  final List<String> tags;
  final void Function(int index)? onImageTap;

  @override
  State<TrekHeroPhotos> createState() => _TrekHeroPhotosState();
}

class _TrekHeroPhotosState extends State<TrekHeroPhotos> {
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    final urls = widget.imageUrls.where((u) => u.trim().isNotEmpty).toList();
    return Stack(
      fit: StackFit.expand,
      children: [
        if (urls.isEmpty)
          Container(color: TrekPageColors.forestSoft, child: const Icon(Icons.landscape_rounded, size: 64, color: TrekPageColors.forest))
        else
          PageView.builder(
            itemCount: urls.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (_, i) => GestureDetector(
              onTap: widget.onImageTap == null ? null : () => widget.onImageTap!(i),
              child: CustomNetworkImage(imageUrl: urls[i], fit: BoxFit.cover),
            ),
          ),
        // Readability scrim under the name (not decoration: white text needs it).
        const IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.45, 1.0],
                colors: [Color(0x33000000), Color(0x00000000), Color(0xCC0B1F14)],
              ),
            ),
          ),
        ),
        Positioned(
          left: 20,
          right: 20,
          bottom: 56,
          child: IgnorePointer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(children: [
                  if (widget.tags.isNotEmpty) _glass(widget.tags.take(2).join(' · ')),
                  if (widget.tags.isNotEmpty && urls.length > 1) const SizedBox(width: 8),
                  if (urls.length > 1) _glass('${_page + 1} / ${urls.length}'),
                ]),
                const SizedBox(height: 10),
                Text(
                  widget.destination,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textScaler: const TextScaler.linear(1.0),
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 30, height: 1.1, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.4),
                ),
                const SizedBox(height: 8),
                Row(children: [
                  Container(
                    width: 24,
                    height: 24,
                    clipBehavior: Clip.antiAlias,
                    decoration: const BoxDecoration(color: TrekPageColors.yellow, shape: BoxShape.circle),
                    child: (widget.organiserLogo ?? '').isNotEmpty
                        ? CustomNetworkImage(imageUrl: widget.organiserLogo!, fit: BoxFit.cover, width: 24, height: 24)
                        : Center(
                            child: Text(widget.organiser.isNotEmpty ? widget.organiser[0].toUpperCase() : '?',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: TrekPageColors.ink)),
                          ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(widget.organiser, maxLines: 1, overflow: TextOverflow.ellipsis, textScaler: const TextScaler.linear(1.0),
                        style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _glass(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.22), borderRadius: BorderRadius.circular(999)),
        child: Text(text, textScaler: const TextScaler.linear(1.0), style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
      );
}

/// A round white button over the photo (back, share, save): the app's 48 dp
/// TapTarget around a 44 px white circle.
class TrekRoundButton extends StatelessWidget {
  const TrekRoundButton({super.key, required this.icon, required this.label, required this.onTap, this.color = TrekPageColors.ink});

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return TapTarget(
      label: label,
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.92), shape: BoxShape.circle),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }
}
