// A pickup's small map pin (owner, 17 Nov 2026): tap -> Google Maps. Trek page: the spot on
// the map; booked ticket: directions to it. Google Maps URLs need no API key and cost nothing
// (developers.google.com/maps/documentation/urls). No pin when the pickup has none.
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_tokens.dart';
import '../theme/app_typography.dart';

/// The Google Maps link for a pickup: the place, or directions to it.
Uri pickupMapsUri(double lat, double lon, {bool directions = false}) {
  final at = '${lat.toStringAsFixed(7)},${lon.toStringAsFixed(7)}';
  return directions
      ? Uri.https('www.google.com', '/maps/dir/', {'api': '1', 'destination': at})
      : Uri.https('www.google.com', '/maps/search/', {'api': '1', 'query': at});
}

/// Is this a pin we can show? (Both parts, inside the world.)
bool hasPickupPin(double? lat, double? lon) =>
    lat != null && lon != null && lat.abs() <= 90 && lon.abs() <= 180 && !(lat == 0 && lon == 0);

class PickupPinButton extends StatelessWidget {
  const PickupPinButton({
    super.key,
    required this.lat,
    required this.lon,
    this.directions = false,
    this.size = 28,
  });

  final double lat;
  final double lon;
  final bool directions;
  final double size;

  Future<void> _open() async {
    final uri = pickupMapsUri(lat, lon, directions: directions);
    // The Google Maps app if it is there, else the browser.
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: directions ? 'Directions to the pickup' : 'Show the pickup on the map',
      child: InkWell(
        key: const ValueKey('pickup-pin'),
        customBorder: const CircleBorder(),
        onTap: _open,
        child: Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(color: AppColors.forestSoft, shape: BoxShape.circle),
          child: Icon(Icons.location_on_outlined, size: size * 0.56, color: AppColors.forest),
        ),
      ),
    );
  }
}

/// Trek page Route: the pickup under its city — "[Bus stand] Mahatma Gandhi Bus Station  (pin)".
/// One grey line; the pin shows only with a real pin (tap = the spot in Google Maps).
class RoutePickupLine extends StatelessWidget {
  const RoutePickupLine({super.key, required this.place, this.label, this.lat, this.lon, required this.fontSize});

  final String place;
  final String? label;
  final double? lat;
  final double? lon;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      key: const ValueKey('route-pickup-place'),
      children: [
        if ((label ?? '').isNotEmpty)
          Container(
            margin: const EdgeInsets.only(right: 6),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(color: AppColors.forestSoft, borderRadius: BorderRadius.circular(4)),
            child: Text(label!, textScaler: const TextScaler.linear(1.0),
                style: AppType.style(fontSize * 0.88, w: FontWeight.w600, color: AppColors.forest)),
          ),
        Expanded(
          // Two lines: a long station name is shown in full on a phone (seen at 390 px).
          child: Text(place, maxLines: 2, overflow: TextOverflow.ellipsis, textScaler: const TextScaler.linear(1.0),
              style: AppType.style(fontSize, color: const Color(0xFF6B7280))),
        ),
        if (hasPickupPin(lat, lon))
          Padding(padding: const EdgeInsets.only(left: 6), child: PickupPinButton(lat: lat!, lon: lon!, size: 24)),
      ],
    );
  }
}

/// Booked ticket: the Boarding Point value — name, then "Bus stand · Platform 1 exit", and a
/// pin for Google Maps directions. Older pickups: just the name, no pin.
class TicketPickupValue extends StatelessWidget {
  const TicketPickupValue({
    super.key,
    required this.name,
    this.kind,
    this.note,
    this.lat,
    this.lon,
    required this.fontSize,
    required this.inkColor,
    required this.mutedColor,
  });

  final String name;
  final String? kind;
  final String? note;
  final double? lat;
  final double? lon;
  final double fontSize;
  final Color inkColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    final k = (kind ?? '').trim();
    final n = (note ?? '').trim();
    return Row(
      key: const ValueKey('ticket-boarding-point'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(name, textAlign: TextAlign.end, style: AppType.style(fontSize, w: FontWeight.w500, color: inkColor)),
              if (k.isNotEmpty || n.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text.rich(
                    TextSpan(children: [
                      if (k.isNotEmpty)
                        TextSpan(text: n.isNotEmpty ? '$k · ' : k,
                            style: AppType.style(fontSize * 0.9, w: FontWeight.w600, color: AppColors.forest)),
                      if (n.isNotEmpty) TextSpan(text: n),
                    ]),
                    textAlign: TextAlign.end,
                    style: AppType.style(fontSize * 0.9, color: mutedColor),
                  ),
                ),
            ],
          ),
        ),
        if (hasPickupPin(lat, lon))
          Padding(padding: const EdgeInsets.only(left: 8), child: PickupPinButton(lat: lat!, lon: lon!, directions: true)),
      ],
    );
  }
}
