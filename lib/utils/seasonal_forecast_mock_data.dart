import 'package:arobo_app/utils/common_images.dart';
import 'package:flutter/material.dart';

/// Shared mock data for the Seasonal Forecast redesign (Top 5 / Avoid per
/// season, editorial-curated — no live weather data, no promo framing).
/// Used by both the dashboard home-screen preview and the full Seasonal
/// Forecast screen so the two stay in sync during design review. Backend
/// wiring (admin curation → real API) is intentionally disconnected for now.
enum TrekSeason { spring, summer, monsoon, autumn, winter }

class SeasonalPick {
  final String trekName;
  final String reason;
  final String imagePath;

  const SeasonalPick({
    required this.trekName,
    required this.reason,
    required this.imagePath,
  });
}

class SeasonInfo {
  final String label;
  final String dateRange;
  final String blurb;
  final List<SeasonalPick> topPicks;
  final List<SeasonalPick> avoidPicks;

  const SeasonInfo({
    required this.label,
    required this.dateRange,
    required this.blurb,
    required this.topPicks,
    required this.avoidPicks,
  });
}

const Map<TrekSeason, SeasonInfo> seasonalForecastMockData = {
  TrekSeason.spring: SeasonInfo(
    label: 'Spring',
    dateRange: 'Mar – Apr',
    blurb: 'Snow is melting and meadows are turning green — a calmer window before the summer rush.',
    topPicks: [
      SeasonalPick(trekName: 'Kuari Pass Trek', reason: 'Rhododendron bloom in full swing', imagePath: CommonImages.himalayas),
      SeasonalPick(trekName: 'Brahmatal Trek', reason: 'Last of the snow, thinner crowds', imagePath: CommonImages.manali),
      SeasonalPick(trekName: 'Har Ki Dun Trek', reason: 'Meadows turning green', imagePath: CommonImages.ladhakh),
      SeasonalPick(trekName: 'Nag Tibba Trek', reason: 'Perfect weekend weather', imagePath: CommonImages.munnar),
      SeasonalPick(trekName: 'Chopta Chandrashila Trek', reason: 'Clear sunrise views before summer haze', imagePath: CommonImages.ooty),
    ],
    avoidPicks: [
      SeasonalPick(trekName: 'Chadar Trek', reason: 'Frozen river melting, unsafe ice', imagePath: CommonImages.ladhakh),
      SeasonalPick(trekName: 'High Ladakh Passes', reason: 'Roads still snowbound, closed', imagePath: CommonImages.himalayas),
      SeasonalPick(trekName: 'Roopkund Trek', reason: 'Snow bridges unstable this time of year', imagePath: CommonImages.chardham),
    ],
  ),
  TrekSeason.summer: SeasonInfo(
    label: 'Summer',
    dateRange: 'May – Jun',
    blurb: 'Peak high-altitude window — snowlines are reachable and alpine lakes are fully open.',
    topPicks: [
      SeasonalPick(trekName: 'Hampta Pass Trek', reason: 'Snow-to-green contrast at its peak', imagePath: CommonImages.manali),
      SeasonalPick(trekName: 'Kashmir Great Lakes Trek', reason: 'Alpine lakes fully open', imagePath: CommonImages.himalayas),
      SeasonalPick(trekName: 'Pin Parvati Pass Trek', reason: 'Prime crossing window before monsoon', imagePath: CommonImages.ladhakh),
      SeasonalPick(trekName: 'Rupin Pass Trek', reason: 'Waterfalls and green valleys', imagePath: CommonImages.munnar),
      SeasonalPick(trekName: 'Sar Pass Trek', reason: 'Beginner-friendly snow trek', imagePath: CommonImages.goa),
    ],
    avoidPicks: [
      SeasonalPick(trekName: 'Western Ghats Treks', reason: 'Peak daytime heat, avoid low-altitude trails', imagePath: CommonImages.gokarna),
      SeasonalPick(trekName: 'Valley of Flowers Trek', reason: 'Not yet in bloom, opens later in the season', imagePath: CommonImages.udupi),
      SeasonalPick(trekName: 'Kedarnath Trek (early summer)', reason: 'Trail still being cleared of snow debris', imagePath: CommonImages.chardham),
    ],
  ),
  TrekSeason.monsoon: SeasonInfo(
    label: 'Monsoon',
    dateRange: 'Jul – Mid Sep',
    blurb: 'Rain-shadow regions like Spiti and Lahaul are the only reliably trekkable window right now.',
    topPicks: [
      SeasonalPick(trekName: 'Pin Bhaba Pass Trek', reason: 'Rain-shadow region, the only trekkable window', imagePath: CommonImages.ladhakh),
      SeasonalPick(trekName: 'Spiti Valley Trek', reason: 'Cold desert stays dry through monsoon', imagePath: CommonImages.himalayas),
      SeasonalPick(trekName: 'Bhrigu Lake Trek', reason: 'Lush green meadows in full bloom', imagePath: CommonImages.manali),
      SeasonalPick(trekName: 'Kanamo Peak', reason: 'High-altitude escape from the rains', imagePath: CommonImages.munnar),
      SeasonalPick(trekName: 'Chandratal Lake Trek', reason: 'Clear skies in the rain shadow', imagePath: CommonImages.ooty),
    ],
    avoidPicks: [
      SeasonalPick(trekName: 'Rishikesh–Joshimath Route Treks', reason: 'Landslide-prone approach roads', imagePath: CommonImages.chardham),
      SeasonalPick(trekName: 'Western Ghats Treks', reason: 'Leech-heavy trails, flash flood risk', imagePath: CommonImages.gokarna),
      SeasonalPick(trekName: 'Chardham Yatra Routes', reason: 'Frequent landslides and road blocks', imagePath: CommonImages.udupi),
    ],
  ),
  TrekSeason.autumn: SeasonInfo(
    label: 'Autumn',
    dateRange: 'Mid Sep – Nov',
    blurb: 'Post-monsoon skies give the clearest Himalayan views of the entire year.',
    topPicks: [
      SeasonalPick(trekName: 'Phulara Ridge Trek', reason: 'Crystal clear Himalayan panoramas', imagePath: CommonImages.himalayas),
      SeasonalPick(trekName: 'Kedarkantha Trek (early season)', reason: 'First light snow dusting begins', imagePath: CommonImages.manali),
      SeasonalPick(trekName: 'Dayara Bugyal Trek', reason: 'Golden meadows before winter', imagePath: CommonImages.ladhakh),
      SeasonalPick(trekName: 'Har Ki Dun Trek', reason: 'Best visibility of the year', imagePath: CommonImages.munnar),
      SeasonalPick(trekName: 'Kuari Pass Trek', reason: 'Post-monsoon clarity', imagePath: CommonImages.ooty),
    ],
    avoidPicks: [
      SeasonalPick(trekName: 'Pin Bhaba Pass Trek', reason: 'Access roads closing for winter', imagePath: CommonImages.chardham),
      SeasonalPick(trekName: 'High Passes above 15,000 ft (late Nov)', reason: 'Early snowfall risk', imagePath: CommonImages.goa),
      SeasonalPick(trekName: 'Valley of Flowers Trek', reason: 'National park closes for the season', imagePath: CommonImages.gokarna),
    ],
  ),
  TrekSeason.winter: SeasonInfo(
    label: 'Winter',
    dateRange: 'Dec – Feb',
    blurb: 'Snow trek season — but several high-altitude routes and shrine yatras shut down entirely.',
    topPicks: [
      SeasonalPick(trekName: 'Kedarkantha Trek', reason: "India's most popular snow trek", imagePath: CommonImages.manali),
      SeasonalPick(trekName: 'Brahmatal Trek', reason: 'Frozen lake and snow campsites', imagePath: CommonImages.himalayas),
      SeasonalPick(trekName: 'Dayara Bugyal Trek (winter)', reason: 'Deep snow meadows', imagePath: CommonImages.ladhakh),
      SeasonalPick(trekName: 'Chadar Trek', reason: 'Frozen river walk, peak season', imagePath: CommonImages.udupi),
      SeasonalPick(trekName: 'Ooty Hill Trails', reason: 'Escape the cold, pleasant hill weather', imagePath: CommonImages.ooty),
    ],
    avoidPicks: [
      SeasonalPick(trekName: 'Chardham Yatra (Kedarnath/Badrinath)', reason: 'Shrines closed, extreme cold, avalanche risk', imagePath: CommonImages.chardham),
      SeasonalPick(trekName: 'High Ladakh Passes', reason: 'Roads closed, extreme sub-zero temps', imagePath: CommonImages.goa),
      SeasonalPick(trekName: 'Kashmir Great Lakes Trek', reason: 'Trail buried under snow, inaccessible', imagePath: CommonImages.gokarna),
    ],
  ),
};

TrekSeason currentTrekSeason() {
  final month = DateTime.now().month;
  if (month == 3 || month == 4) return TrekSeason.spring;
  if (month == 5 || month == 6) return TrekSeason.summer;
  if (month == 7 || month == 8 || month == 9) return TrekSeason.monsoon;
  if (month == 10 || month == 11) return TrekSeason.autumn;
  return TrekSeason.winter;
}

/// Line-art glyph per season for [SeasonalGradientCard]'s badge — a
/// sprout, sun, rain cloud, falling leaf and snowflake, in that order,
/// matching India's monsoon-driven 5-window trek calendar instead of a
/// generic 4-season (sun/snowflake/leaf/flower) icon pack. Rendered via
/// SvgPicture.string with a colorFilter, so stroke="black" here is just
/// a placeholder — the badge recolors it to the verdict color.
String seasonGlyphSvg(TrekSeason season) {
  const stroke = 'stroke="black" stroke-width="1.8" fill="none"';
  switch (season) {
    case TrekSeason.spring:
      return '''
<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
  <path d="M12 21V11" $stroke stroke-linecap="round"/>
  <path d="M12 11C12 11 8 10 8 6.5C8 6.5 10 7 12 9C14 7 16 6.5 16 6.5C16 10 12 11 12 11Z" $stroke stroke-linejoin="round"/>
  <path d="M9 14c0 0 -3 .5 -3 3" $stroke stroke-linecap="round"/>
  <path d="M15 14c0 0 3 .5 3 3" $stroke stroke-linecap="round"/>
</svg>''';
    case TrekSeason.summer:
      return '''
<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
  <circle cx="12" cy="12" r="4.2" $stroke/>
  <path d="M12 3v2.2M12 18.8V21M4.5 12H2.7M21.3 12h-1.8M6 6l1.3 1.3M17.7 17.7 16.4 16.4M18 6l-1.3 1.3M7.6 16.4 6.3 17.7" $stroke stroke-linecap="round"/>
</svg>''';
    case TrekSeason.monsoon:
      return '''
<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
  <path d="M7 15a4 4 0 0 1 .4-8 5 5 0 0 1 9.6 1.6A3.5 3.5 0 0 1 17 15H7Z" $stroke stroke-linecap="round"/>
  <path d="M9 18.5 8 20.5M13 18.5l-1 2M17 18.5l-1 2" $stroke stroke-linecap="round"/>
</svg>''';
    case TrekSeason.autumn:
      return '''
<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
  <path d="M18 6c-6 0-11 4-11 10 6 0 11-4 11-10Z" $stroke stroke-linecap="round" stroke-linejoin="round"/>
  <path d="M7 16 18 6" $stroke stroke-linecap="round"/>
</svg>''';
    case TrekSeason.winter:
      return '''
<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
  <path d="M12 3v18M4.5 7.5l15 9M19.5 7.5l-15 9" $stroke stroke-linecap="round"/>
  <path d="M12 3l-1.6 1.6M12 3l1.6 1.6M12 21l-1.6-1.6M12 21l1.6-1.6M4.5 7.5l2.2.3M4.5 7.5l.3-2.2M19.5 7.5l-2.2.3M19.5 7.5l-.3-2.2M4.5 16.5l2.2-.3M4.5 16.5l.3 2.2M19.5 16.5l-2.2-.3M19.5 16.5l-.3 2.2" $stroke stroke-linecap="round"/>
</svg>''';
  }
}

/// Season-themed backdrop for "illustration" mode picks (a transparent-PNG
/// cutout with no photo of its own) — same diagonal-gradient technique as
/// KnowMoreCard's promo background (utils/know_more_card.dart), just one
/// fixed colour pair per season instead of an admin-set gradient. Palette
/// matches the design mockup's season atlas exactly.
LinearGradient seasonBackdropGradient(TrekSeason season) {
  switch (season) {
    case TrekSeason.spring:
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF1C5C50), Color(0xFF0E3B36)],
      );
    case TrekSeason.summer:
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFC98A1D), Color(0xFF5C3A0D)],
      );
    case TrekSeason.monsoon:
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF3E5A6C), Color(0xFF202E38)],
      );
    case TrekSeason.autumn:
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFC1531F), Color(0xFF5C220B)],
      );
    case TrekSeason.winter:
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF4C6E73), Color(0xFF1A2B30)],
      );
  }
}
