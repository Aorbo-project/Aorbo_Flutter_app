import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'header_scene.dart';

/// Everything visual about the dashboard header. The layout is static —
/// only this object changes per season / festival / collaboration.
class DashboardHeaderTheme {
  final String id;
  final String tagline;
  final String? badgeText; // e.g. "Monsoon Edition", "Diwali Special"
  final List<Color> gradientColors; // static fallback behind the scene
  final Color accent;
  final Color accentLight;
  final Color accentSoft;
  final Color ink;
  final Color inkMid;
  final Color inkLight;
  final String? logoOverrideUrl; // collab logo; falls back to bundled asset
  final HeaderSceneSpec scene; // animated background layers

  const DashboardHeaderTheme({
    required this.id,
    required this.tagline,
    this.badgeText,
    required this.gradientColors,
    required this.accent,
    required this.accentLight,
    required this.accentSoft,
    this.ink = const Color(0xFF111827),
    this.inkMid = const Color(0xFF6B7280),
    this.inkLight = const Color(0xFF9CA3AF),
    this.logoOverrideUrl,
    this.scene = const HeaderSceneSpec([]),
  });

  static Color hexToColor(String? hex, Color fallback) {
    if (hex == null || hex.isEmpty) return fallback;
    var h = hex.replaceAll('#', '');
    if (h.length == 6) h = 'FF$h';
    final v = int.tryParse(h, radix: 16);
    return v == null ? fallback : Color(v);
  }

  /// Parse a theme delivered by the backend. Every field is optional and
  /// falls back to the classic look, so a malformed payload can never
  /// break the header.
  factory DashboardHeaderTheme.fromJson(Map<String, dynamic> json) {
    final rawGradient =
        (json['gradient'] as List?)
            ?.map((e) => hexToColor(e.toString(), const Color(0xFFFEF200)))
            .toList() ??
        const [Color(0xFFFEF200), Color(0xFFFFFFFF)];

    return DashboardHeaderTheme(
      id: json['id']?.toString() ?? 'remote',
      tagline: json['tagline']?.toString() ?? 'Hike Beyond Limits with',
      badgeText: json['badgeText']?.toString(),
      gradientColors: rawGradient.length >= 2
          ? rawGradient
          : [...rawGradient, Colors.white],
      accent: hexToColor(json['accent']?.toString(), const Color(0xFF0F7B6C)),
      accentLight: hexToColor(
        json['accentLight']?.toString(),
        const Color(0xFF1AA090),
      ),
      accentSoft: hexToColor(
        json['accentSoft']?.toString(),
        const Color(0xFFE6F5F3),
      ),
      logoOverrideUrl: (json['logoUrl']?.toString().isEmpty ?? true)
          ? null
          : json['logoUrl'].toString(),
      scene: HeaderSceneSpec.fromJson(json['layers']),
    );
  }

  // ---------------------------------------------------------------------
  // Built-in presets — used until the backend theme endpoint is live,
  // and as the offline fallback afterwards. Their scenes double as the
  // reference for what the backend `layers` JSON should look like.
  // ---------------------------------------------------------------------

  static const classic = DashboardHeaderTheme(
    id: 'classic',
    tagline: 'Hike Beyond Limits with',
    gradientColors: [Color(0xFFFEF200), Color(0xFFFFFFFF)],
    accent: Color(0xFF0F7B6C),
    accentLight: Color(0xFF1AA090),
    accentSoft: Color(0xFFE6F5F3),
    scene: HeaderSceneSpec([
      SceneLayer(
        type: 'sky',
        colors: [Color(0xFFFEF200), Color(0xFFFFFFFF)],
        colorsB: [Color(0xFFF5EA33), Color(0xFFFFFFFF)],
        interval: 12,
      ),
      SceneLayer(
        type: 'mountains',
        colors: [Color(0xFF0F7B6C), Color(0xFF1AA090)],
        opacity: 0.08,
        speed: 0.4,
      ),
      SceneLayer(
        type: 'birds',
        colors: [Color(0xFF111827)],
        count: 3,
        opacity: 0.5,
      ),
      SceneLayer(
        type: 'particles',
        variant: 'sparkle',
        colors: [Color(0xFF0F7B6C)],
        count: 16,
        opacity: 0.6,
      ),
      SceneLayer(type: 'scrim', colors: [Color(0xFFFFFFFF)], opacity: 0.85),
    ]),
  );

  static const monsoon = DashboardHeaderTheme(
    id: 'monsoon',
    tagline: 'Chase Waterfalls this Monsoon with',
    badgeText: 'Monsoon Edition',
    gradientColors: [Color(0xFFBFD9E8), Color(0xFFFFFFFF)],
    accent: Color(0xFF14655B),
    accentLight: Color(0xFF1AA090),
    accentSoft: Color(0xFFE0F0EE),
    scene: HeaderSceneSpec([
      SceneLayer(
        type: 'sky',
        colors: [Color(0xFFAFCEDF), Color(0xFFFFFFFF)],
        colorsB: [Color(0xFF9BBFD4), Color(0xFFF2F7FA)],
        interval: 12,
      ),
      SceneLayer(
        type: 'mountains',
        colors: [Color(0xFF7FA6B8), Color(0xFF5B8FA8)],
        opacity: 0.16,
        speed: 0.5,
      ),
      SceneLayer(
        type: 'clouds',
        colors: [Color(0xFFFFFFFF)],
        count: 5,
        opacity: 0.7,
      ),
      SceneLayer(
        type: 'lightning',
        colors: [Color(0xFFFFFFFF)],
        interval: 9,
        opacity: 0.9,
      ),
      SceneLayer(
        type: 'particles',
        variant: 'rain',
        colors: [Color(0xFF5B8FA8)],
        count: 34,
        opacity: 0.8,
      ),
      SceneLayer(type: 'fog', colors: [Color(0xFFFFFFFF)], opacity: 0.9),
      SceneLayer(type: 'scrim', colors: [Color(0xFFFFFFFF)], opacity: 0.85),
    ]),
  );

  static const autumn = DashboardHeaderTheme(
    id: 'autumn',
    tagline: 'Golden Trails Await with',
    badgeText: 'Autumn Trails',
    gradientColors: [Color(0xFFFFD9A0), Color(0xFFFFFFFF)],
    accent: Color(0xFFB4530A),
    accentLight: Color(0xFFE07B39),
    accentSoft: Color(0xFFFDEBD9),
    scene: HeaderSceneSpec([
      SceneLayer(
        type: 'sky',
        colors: [Color(0xFFFFD9A0), Color(0xFFFFF8EF)],
        colorsB: [Color(0xFFFFC97E), Color(0xFFFFFFFF)],
        interval: 12,
      ),
      SceneLayer(
        type: 'celestial',
        variant: 'sun',
        colors: [Color(0xFFFFB347)],
        x: 0.82,
        y: 0.16,
        size: 0.07,
        opacity: 0.9,
      ),
      SceneLayer(
        type: 'mountains',
        colors: [Color(0xFFD98E4A), Color(0xFFB4530A)],
        opacity: 0.14,
        speed: 0.5,
      ),
      SceneLayer(
        type: 'particles',
        variant: 'leaves',
        colors: [Color(0xFFCC7722), Color(0xFFB4530A), Color(0xFFE0A34C)],
        count: 22,
      ),
      SceneLayer(
        type: 'birds',
        colors: [Color(0xFF6B4A2B)],
        count: 3,
        opacity: 0.5,
      ),
      SceneLayer(type: 'scrim', colors: [Color(0xFFFFFFFF)], opacity: 0.85),
    ]),
  );

  static const winter = DashboardHeaderTheme(
    id: 'winter',
    tagline: 'Conquer Snow Peaks with',
    badgeText: 'Winter Summits',
    gradientColors: [Color(0xFFD6E6F5), Color(0xFFFFFFFF)],
    accent: Color(0xFF1E5AA8),
    accentLight: Color(0xFF4A8AD4),
    accentSoft: Color(0xFFE4EEF9),
    scene: HeaderSceneSpec([
      SceneLayer(
        type: 'sky',
        colors: [Color(0xFFC7DCF0), Color(0xFFFFFFFF)],
        colorsB: [Color(0xFFB3CFE9), Color(0xFFF4F8FC)],
        interval: 14,
      ),
      SceneLayer(
        type: 'celestial',
        variant: 'moon',
        colors: [Color(0xFFF4F7FB)],
        x: 0.8,
        y: 0.14,
        size: 0.055,
        opacity: 0.9,
      ),
      SceneLayer(
        type: 'aurora',
        colors: [Color(0xFF6ED0B8), Color(0xFF7FA8E8)],
        opacity: 0.8,
      ),
      SceneLayer(
        type: 'mountains',
        colors: [Color(0xFF9FBEDD), Color(0xFF7FA6CC)],
        opacity: 0.20,
        speed: 0.4,
      ),
      SceneLayer(
        type: 'particles',
        variant: 'snow',
        colors: [Color(0xFFFFFFFF)],
        count: 30,
      ),
      SceneLayer(type: 'fog', colors: [Color(0xFFFFFFFF)], opacity: 0.8),
      SceneLayer(type: 'scrim', colors: [Color(0xFFFFFFFF)], opacity: 0.85),
    ]),
  );

  static const diwali = DashboardHeaderTheme(
    id: 'diwali',
    tagline: 'Light Up Your Trails this Diwali with',
    badgeText: 'Diwali Special',
    gradientColors: [Color(0xFFFFE0B2), Color(0xFFFFFFFF)],
    accent: Color(0xFFA34A00),
    accentLight: Color(0xFFE07B39),
    accentSoft: Color(0xFFFBEBD6),
    scene: HeaderSceneSpec([
      SceneLayer(
        type: 'sky',
        colors: [Color(0xFFFFDCA8), Color(0xFFFFF6EA)],
        colorsB: [Color(0xFFFFCE8C), Color(0xFFFFFFFF)],
        interval: 10,
      ),
      SceneLayer(
        type: 'fireworks',
        colors: [Color(0xFFE5A50A), Color(0xFFE07B39), Color(0xFFD44B7A)],
        interval: 4,
        opacity: 0.9,
      ),
      SceneLayer(
        type: 'particles',
        variant: 'embers',
        colors: [Color(0xFFE5A50A), Color(0xFFE07B39)],
        count: 22,
      ),
      SceneLayer(
        type: 'particles',
        variant: 'sparkle',
        colors: [Color(0xFFE5A50A)],
        count: 18,
        opacity: 0.7,
      ),
      SceneLayer(type: 'scrim', colors: [Color(0xFFFFFFFF)], opacity: 0.85),
    ]),
  );

  static const spring = DashboardHeaderTheme(
    id: 'spring',
    tagline: 'Bloom-Season Treks Begin with',
    badgeText: 'Spring Blooms',
    gradientColors: [Color(0xFFFBD5E0), Color(0xFFFFFFFF)],
    accent: Color(0xFF0F7B6C),
    accentLight: Color(0xFF1AA090),
    accentSoft: Color(0xFFE6F5F3),
    scene: HeaderSceneSpec([
      SceneLayer(
        type: 'sky',
        colors: [Color(0xFFFBD5E0), Color(0xFFFFFFFF)],
        colorsB: [Color(0xFFF7C2D3), Color(0xFFFDF7F9)],
        interval: 12,
      ),
      SceneLayer(
        type: 'celestial',
        variant: 'sun',
        colors: [Color(0xFFFFD27A)],
        x: 0.83,
        y: 0.15,
        size: 0.06,
        opacity: 0.85,
      ),
      SceneLayer(
        type: 'mountains',
        colors: [Color(0xFF7FBFA8), Color(0xFF4FA88C)],
        opacity: 0.12,
        speed: 0.4,
      ),
      SceneLayer(
        type: 'particles',
        variant: 'petals',
        colors: [Color(0xFFE58BA8), Color(0xFFF2AFC4)],
        count: 20,
      ),
      SceneLayer(
        type: 'birds',
        colors: [Color(0xFF4A6B5C)],
        count: 2,
        opacity: 0.5,
      ),
      SceneLayer(type: 'scrim', colors: [Color(0xFFFFFFFF)], opacity: 0.85),
    ]),
  );
}

/// Owns the active header theme. Swap loadTheme() to your API once the
/// backend endpoint exists — the header updates reactively via Obx.
class HeaderThemeController extends GetxController {
  final Rx<DashboardHeaderTheme> theme = DashboardHeaderTheme.classic.obs;

  @override
  void onInit() {
    super.onInit();
    loadTheme();
  }

  Future<void> loadTheme() async {
    // TODO(backend): replace with your API client, e.g.:
    //
    //   try {
    //     // 1. Render cached theme instantly (GetStorage/shared_preferences):
    //     //    final cached = storage.read('header_theme');
    //     //    if (cached != null) theme.value = DashboardHeaderTheme.fromJson(cached);
    //     // 2. Fetch fresh:
    //     final res = await apiClient.get('/api/v1/app-theme/active');
    //     theme.value = DashboardHeaderTheme.fromJson(res.data['data']);
    //     // 3. Cache: storage.write('header_theme', res.data['data']);
    //   } catch (_) {
    //     theme.value = seasonalFallback(DateTime.now());
    //   }
    //
    // Until then, run on the built-in seasonal presets:
    theme.value = seasonalFallback(DateTime.now());
  }

  DashboardHeaderTheme seasonalFallback(DateTime now) {
    final m = now.month;
    if (m >= 6 && m <= 9) return DashboardHeaderTheme.monsoon;
    if (m == 10 || m == 11) return DashboardHeaderTheme.autumn;
    if (m == 12 || m <= 2) return DashboardHeaderTheme.winter;
    return DashboardHeaderTheme.spring;
  }
}
