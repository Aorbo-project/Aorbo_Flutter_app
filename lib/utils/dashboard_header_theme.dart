import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'header_scene.dart';
import 'package:arobo_app/theme/app_tokens.dart';
import '../repository/app_env.dart';

class DashboardHeaderTheme {
  final String id;
  final String tagline;
  final String? badgeText;
  final List<Color> gradientColors;
  final Color accent;
  final Color accentLight;
  final Color accentSoft;
  final Color ink;
  final Color inkMid;
  final Color inkLight;
  final String? logoOverrideUrl;
  final HeaderSceneSpec scene;

  const DashboardHeaderTheme({
    required this.id,
    required this.tagline,
    this.badgeText,
    required this.gradientColors,
    required this.accent,
    required this.accentLight,
    required this.accentSoft,
    this.ink = AppColors.ink,
    this.inkMid = AppColors.inkMid,
    this.inkLight = AppColors.inkLight,
    this.logoOverrideUrl,
    this.scene = const HeaderSceneSpec.empty(),
  });

  static Color hexToColor(String? hex, Color fallback) {
    if (hex == null || hex.isEmpty) return fallback;
    var h = hex.replaceAll('#', '');
    if (h.length == 6) h = 'FF$h';
    final v = int.tryParse(h, radix: 16);
    return v == null ? fallback : Color(v);
  }

  factory DashboardHeaderTheme.fromJson(Map<String, dynamic> json) {
    final raw =
        (json['gradient'] as List?)
            ?.map((e) => hexToColor(e.toString(), const Color(0xFFFEF200)))
            .toList() ??
        const [Color(0xFFFEF200), Color(0xFFFFFFFF)];

    return DashboardHeaderTheme(
      id: json['id']?.toString() ?? 'remote',
      tagline: json['tagline']?.toString() ?? 'Hike Beyond Limits with',
      badgeText: json['badgeText']?.toString(),
      gradientColors: raw.length >= 2 ? raw : [...raw, Colors.white],
      accent: hexToColor(json['accent']?.toString(), AppColors.teal),
      accentLight: hexToColor(
        json['accentLight']?.toString(),
        AppColors.tealLight,
      ),
      accentSoft: hexToColor(
        json['accentSoft']?.toString(),
        AppColors.tealSoft,
      ),
      logoOverrideUrl: (json['logoUrl']?.toString().isEmpty ?? true)
          ? null
          : json['logoUrl'].toString(),
      scene: HeaderSceneSpec.fromJson(json['layers']),
    );
  }

  static const classic = DashboardHeaderTheme(
    id: 'classic',
    tagline: 'Hike Beyond Limits with',
    gradientColors: [Color(0xFF7AD7F0), Color(0xFFFFF9C4)],
    accent: AppColors.teal,
    accentLight: AppColors.tealLight,
    accentSoft: AppColors.tealSoft,
    scene: HeaderSceneSpec([
      SceneLayer(
        type: 'sky',
        colors: [Color(0xFF57B9E8), Color(0xFFDFF6FF)],
        colorsB: [Color(0xFF3FA9DC), Color(0xFFFFF8D9)],
        interval: 10,
      ),
      SceneLayer(
        type: 'celestial',
        variant: 'sun',
        colors: [Color(0xFFFFF3B0)],
        x: 0.80,
        y: 0.14,
        size: 0.055,
        opacity: 0.95,
        intensity: 1.2,
      ),
      SceneLayer(
        type: 'clouds',
        colors: [Color(0xFFFFFFFF)],
        count: 6,
        speed: 1.1,
        opacity: 0.92,
      ),
      SceneLayer(
        type: 'mountains',
        variant: 'snow',
        colors: [Color(0xFF2E8368), Color(0xFF4FA88C), Color(0xFF8CC6B2)],
        opacity: 0.88,
        speed: 0.9,
      ),
      SceneLayer(
        type: 'trees',
        variant: 'pine',
        colors: [Color(0xFF2E7D5B), Color(0xFF5D4037)],
        count: 12,
        y: 0.82,
        size: 0.14,
        speed: 0.8,
        opacity: 0.95,
      ),
      SceneLayer(
        type: 'ground',
        variant: 'flowers',
        colors: [Color(0xFF67B26F), Color(0xFF3E8E5A)],
        colorsB: [Color(0xFFFFD54F), Color(0xFFFF8A80), Color(0xFFFFFFFF)],
        size: 0.22,
        speed: 1.0,
        opacity: 0.96,
        edge: 'bottom',
      ),
      SceneLayer(
        type: 'birds',
        colors: [Color(0xFF234E41)],
        count: 4,
        speed: 1.0,
        opacity: 0.65,
      ),
      SceneLayer(
        type: 'particles',
        variant: 'pollen',
        colors: [Color(0xFFFFF59D), Color(0xFFFFFFFF)],
        count: 24,
        opacity: 0.55,
        speed: 0.55,
      ),
      SceneLayer(
        type: 'shimmer',
        colors: [Color(0xFFFFFFFF)],
        interval: 12,
        opacity: 0.45,
      ),
      SceneLayer(
        type: 'frame',
        colors: [Color(0xFF2E8368), Color(0xFFFFD54F)],
        opacity: 0.8,
        speed: 0.6,
      ),
      SceneLayer(type: 'scrim', colors: [Color(0xFFFFFFFF)], opacity: 0.72),
    ]),
  );

  static const spring = DashboardHeaderTheme(
    id: 'spring',
    tagline: 'Valley of Flowers Blooms with',
    gradientColors: [Color(0xFFFBD5E0), Color(0xFFFFFFFF)],
    accent: AppColors.teal,
    accentLight: AppColors.tealLight,
    accentSoft: AppColors.tealSoft,
    scene: HeaderSceneSpec([
      SceneLayer(
        type: 'sky',
        colors: [Color(0xFFFF9EC0), Color(0xFFFFF3F7)],
        colorsB: [Color(0xFFEF6FA0), Color(0xFFFDF7F9)],
        interval: 11,
      ),
      SceneLayer(
        type: 'celestial',
        variant: 'sun',
        colors: [Color(0xFFFFC24B)],
        x: 0.82,
        y: 0.14,
        size: 0.055,
        opacity: 0.9,
        intensity: 1.0,
      ),
      SceneLayer(
        type: 'clouds',
        colors: [Color(0xFFFFF0F5)],
        count: 6,
        speed: 1.0,
        opacity: 0.9,
      ),
      SceneLayer(
        type: 'mountains',
        colors: [Color(0xFF4FA88C), Color(0xFF2E8368), Color(0xFF8CC6B2)],
        opacity: 0.85,
        speed: 0.85,
      ),
      SceneLayer(
        type: 'trees',
        variant: 'blossom',
        colors: [Color(0xFF57A773), Color(0xFF6D4C41), Color(0xFFF2AFC4)],
        count: 12,
        y: 0.80,
        size: 0.15,
        speed: 0.9,
        opacity: 0.96,
      ),
      SceneLayer(
        type: 'ground',
        variant: 'flowers',
        colors: [Color(0xFF67B26F), Color(0xFF4C9A63)],
        colorsB: [Color(0xFFF2AFC4), Color(0xFFFF6FA0), Color(0xFFFFD54F)],
        size: 0.24,
        speed: 1.0,
        opacity: 0.96,
        edge: 'bottom',
      ),
      SceneLayer(
        type: 'particles',
        variant: 'petals',
        colors: [Color(0xFFE58BA8), Color(0xFFF2AFC4), Color(0xFFFF6FA0)],
        count: 70,
        opacity: 1.0,
        speed: 1.0,
      ),
      SceneLayer(
        type: 'particles',
        variant: 'pollen',
        colors: [Color(0xFFFFF59D), Color(0xFFFFFFFF)],
        count: 20,
        opacity: 0.5,
        speed: 0.45,
      ),
      SceneLayer(
        type: 'birds',
        colors: [Color(0xFF4A6B5C)],
        count: 3,
        speed: 0.9,
        opacity: 0.6,
      ),
      SceneLayer(type: 'fog', colors: [Color(0xFFFFF0F5)], opacity: 0.35),
      SceneLayer(
        type: 'frame',
        colors: [Color(0xFFEF6FA0), Color(0xFFFFD1DC)],
        opacity: 0.82,
        speed: 0.6,
      ),
      SceneLayer(
        type: 'shimmer',
        colors: [Color(0xFFFFD6E4)],
        interval: 12,
        opacity: 0.42,
      ),
      SceneLayer(type: 'scrim', colors: [Color(0xFFFFFFFF)], opacity: 0.72),
    ]),
  );

  static const summer = DashboardHeaderTheme(
    id: 'summer',
    tagline: 'Konkan Coastal Escapes with',
    gradientColors: [Color(0xFF4FC3F7), Color(0xFFFFF9C4)],
    accent: Color(0xFF00838F),
    accentLight: Color(0xFF4DD0E1),
    accentSoft: Color(0xFFE0F7FA),
    scene: HeaderSceneSpec([
      SceneLayer(
        type: 'sky',
        colors: [Color(0xFF29B6F6), Color(0xFFE0F7FA)],
        colorsB: [Color(0xFF0288D1), Color(0xFFFFF9C4)],
        interval: 9,
      ),
      SceneLayer(
        type: 'celestial',
        variant: 'sun',
        colors: [Color(0xFFFFF176)],
        x: 0.5,
        y: 0.12,
        size: 0.07,
        opacity: 1.0,
        intensity: 1.45,
      ),
      SceneLayer(
        type: 'clouds',
        colors: [Color(0xFFFFFFFF)],
        count: 7,
        speed: 1.25,
        opacity: 0.95,
      ),
      SceneLayer(
        type: 'mountains',
        colors: [Color(0xFF00897B), Color(0xFF26A69A)],
        opacity: 0.45,
        speed: 0.6,
      ),
      SceneLayer(
        type: 'sea',
        colors: [Color(0xFF00B4D8), Color(0xFF0077B6), Color(0xFFFFFFFF)],
        y: 0.55,
        speed: 1.5,
        count: 22,
        opacity: 0.96,
      ),
      SceneLayer(
        type: 'ground',
        variant: 'sand',
        colors: [Color(0xFFF6D8A8), Color(0xFFE7C078)],
        colorsB: [Color(0xFFFFF3E0), Color(0xFFD7CCC8), Color(0xFFFF8A65)],
        size: 0.26,
        speed: 0.9,
        opacity: 1.0,
        edge: 'bottom',
      ),
      SceneLayer(
        type: 'trees',
        variant: 'palm',
        colors: [Color(0xFF2E7D32), Color(0xFF8D6E63)],
        count: 8,
        y: 0.80,
        size: 0.22,
        speed: 0.9,
        opacity: 0.96,
      ),
      SceneLayer(
        type: 'particles',
        variant: 'sparkle',
        colors: [Color(0xFFFFFFFF), Color(0xFFFFF176)],
        count: 30,
        opacity: 0.65,
        speed: 0.7,
      ),
      SceneLayer(
        type: 'birds',
        colors: [Color(0xFF01579B)],
        count: 4,
        speed: 1.1,
        opacity: 0.65,
      ),
      SceneLayer(
        type: 'shimmer',
        variant: 'heat',
        colors: [Color(0xFFFFF9C4)],
        interval: 6,
        opacity: 0.55,
      ),
      SceneLayer(
        type: 'frame',
        colors: [Color(0xFF00838F), Color(0xFFFFD54F)],
        opacity: 0.82,
        speed: 0.7,
      ),
      SceneLayer(type: 'scrim', colors: [Color(0xFFFFFFFF)], opacity: 0.72),
    ]),
  );

  // ---------------------------------------------------------------------
  // MONSOON — Rain-Soaked Forest Trail.
  // Redesigned ground: Boulders embedded in wet, mossy terrain for realism.
  // Right-side trees completely removed for a cleaner view.
  // ---------------------------------------------------------------------
  static const monsoon = DashboardHeaderTheme(
    id: 'monsoon',
    tagline: 'Rain-Kissed Forest Trails with',
    gradientColors: [Color(0xFF2E3B34), Color(0xFFE9F1EB)],
    accent: Color(0xFF14655B),
    accentLight: Color(0xFF4DD0E1),
    accentSoft: Color(0xFFE0F0EE),
    scene: HeaderSceneSpec([
      // Stormy sky — dark charcoal-green top so rain has contrast
      SceneLayer(
        type: 'sky',
        colors: [Color(0xFF232E28), Color(0xFF4E6659), Color(0xFFB9CCC0)],
        colorsB: [Color(0xFF1B2620), Color(0xFF3E5548), Color(0xFFA5BCAE)],
        interval: 9,
      ),
      SceneLayer(
        type: 'clouds',
        colors: [Color(0xFF344038)],
        count: 7,
        speed: 0.7,
        opacity: 0.55,
      ),
      // A rare lightning flash — subtle, not a strobe
      SceneLayer(
        type: 'lightning',
        colors: [Color(0xFFDCEAE0)],
        x: 0.28,
        opacity: 0.6,
        seed: 6,
      ),
      // Distant misty ridge, kept well above the treeline
      SceneLayer(
        type: 'mountains',
        colors: [Color(0xFF4A6455), Color(0xFF5F7A6A)],
        opacity: 0.38,
        speed: 0.35,
      ),
      SceneLayer(type: 'fog', colors: [Color(0xFFCFDED2)], opacity: 0.24),

      // ---- FOOTING — Layered for extreme realism ----
      // 1. Large embedded boulders (background structure)
      SceneLayer(
        type: 'ground',
        variant: 'boulders',
        colors: [Color(0xFF344038), Color(0xFF1B2620)],
        size: 0.28,
        opacity: 0.85,
        edge: 'bottom',
        seed: 14,
      ),
      // 2. Wet earth terrain with rocks, grass, and moss (foreground detail)
      SceneLayer(
        type: 'ground',
        variant: 'terrain',
        colors: [
          Color(0xFF26332B),
          Color(0xFF3E5548),
        ], // Dark wet earth & wet grass
        colorsB: [
          Color(0xFF335A28), // Fern green
          Color(0xFF5E7B5C), // Wet grass
          Color(0xFF4A6455), // Dark moss
          Color(0xFF2E3B34), // Dark green
        ],
        size: 0.28,
        opacity: 1.0,
        edge: 'bottom',
        seed: 8,
      ),
      // A gentle puddle glint on the wet trail
      SceneLayer(
        type: 'shimmer',
        variant: 'wet',
        colors: [Color(0xFFFFFFFF)],
        interval: 7,
        opacity: 0.35, // Slightly increased to look wetter
      ),

      // ---- RAIN — two calm, believable layers ----
      SceneLayer(
        type: 'particles',
        variant: 'rain',
        colors: [Color(0xFFC7DAD0)],
        count: 55,
        opacity: 0.45,
        speed: 1.5,
        seed: 5,
      ),
      SceneLayer(
        type: 'particles',
        variant: 'rain',
        colors: [Color(0xFFF2F8F4)],
        count: 30,
        opacity: 0.5,
        speed: 2.2,
        seed: 15,
      ),

      // Single light readability scrim
      SceneLayer(type: 'scrim', colors: [Color(0xFFFFFFFF)], opacity: 0.22),
    ]),
  );

  // ---------------------------------------------------------------------
  // AUTUMN — Crisp Daytime.
  // Redesigned ground: Boulders embedded in dry earth with vivid fallen leaves.
  // Right-side trees completely removed to let the landscape breathe.
  // ---------------------------------------------------------------------
  static const autumn = DashboardHeaderTheme(
    id: 'autumn',
    tagline: 'Himalayan Golden Trails with',
    gradientColors: [Color(0xFFE67E22), Color(0xFFFFFFFF)],
    accent: Color(0xFFB4530A),
    accentLight: Color(0xFFE07B39),
    accentSoft: Color(0xFFFDEBD9),
    scene: HeaderSceneSpec([
      // 1. Bright daytime sky — clear blue fading to warm cream at horizon
      SceneLayer(
        type: 'sky',
        colors: [
          Color(0xFF2E5F8A), // Deep daytime blue top
          Color(0xFF7AB8E0), // Mid blue
          Color(0xFFEBF5FB), // Pale misty blue
          Color(0xFFFFF3E0), // Warm cream horizon
        ],
        colorsB: [
          Color(0xFF1F4B72),
          Color(0xFF6AA8D5),
          Color(0xFFE1EFF5),
          Color(0xFFFFEBC8),
        ],
        interval: 14,
        seed: 10,
      ),
      // 2. Gentle afternoon sun — soft and high
      SceneLayer(
        type: 'celestial',
        variant: 'sun',
        colors: [Color(0xFFFFF8E1)],
        x: 0.78,
        y: 0.16,
        size: 0.05,
        opacity: 0.85,
        intensity: 0.8,
        seed: 5,
      ),
      // 3. Wispy daytime clouds
      SceneLayer(
        type: 'clouds',
        colors: [Color(0xFFFFFFFF)],
        count: 5,
        speed: 0.4,
        opacity: 0.75,
        seed: 12,
      ),
      // 4. Distant misty rolling hills — smooth daytime blue-greens
      SceneLayer(
        type: 'mountains',
        colors: [
          Color(0xFF7C9BB3), // Furthest ridge (misty blue)
          Color(0xFF9EB1C4), // Mid ridge
          Color(0xFFBFCEDC), // Near ridge
        ],
        opacity: 0.65,
        speed: 0.4,
        seed: 22,
      ),
      // 5. Soft valley mist
      SceneLayer(
        type: 'fog',
        colors: [Color(0xFFD4E6F1)], // Pale daytime mist
        opacity: 0.3,
        seed: 15,
      ),
      // 6. Background falling leaves — faded, slow, parallax depth
      SceneLayer(
        type: 'particles',
        variant: 'leaves',
        colors: [Color(0xFFE67E22), Color(0xFFD35400)],
        count: 20,
        opacity: 0.5,
        speed: 0.35, // Very slow background drift
        seed: 4,
      ),
      // 7. Foreground Trees (Left only) — bare, skeletal branches
      SceneLayer(
        type: 'trees',
        variant: 'bare',
        colors: [
          Color(0xFF3A241A), // Trunk/branches
          Color(0xFF1A0A05), // Darker inner branches
        ],
        count: 2,
        y: 0.72,
        size: 0.32,
        speed: 0.5,
        opacity: 0.90,
        edge: 'left',
        seed: 7,
      ),
      // ---- FOOTING — Layered for extreme realism ----
      // 1. Large embedded boulders (background structure)
      SceneLayer(
        type: 'ground',
        variant: 'boulders',
        colors: [Color(0xFF5D3A1A), Color(0xFF3E2412)],
        size: 0.28,
        opacity: 0.9,
        edge: 'bottom',
        seed: 14,
      ),
      // 2. Dry earth terrain with rocks, dry grass, and vivid fallen leaves
      SceneLayer(
        type: 'ground',
        variant: 'terrain',
        colors: [
          Color(0xFF5D3A1A), // Dark earth
          Color(0xFF8C6D3F), // Dry golden grass
        ],
        colorsB: [
          Color(0xFFE67E22), // Vivid fallen leaf
          Color(0xFFFFB84C), // Golden fallen leaf
          Color(0xFFA04018), // Dark rust fallen leaf
          Color(0xFFD35400), // Crimson fallen leaf
        ],
        size: 0.28,
        opacity: 1.0,
        edge: 'bottom',
        seed: 8,
      ),
      // 3. Foreground falling leaves — vivid, close-up motion
      SceneLayer(
        type: 'particles',
        variant: 'leaves',
        colors: [
          Color(0xFFE67E22),
          Color(0xFFC0392B),
          Color(0xFFFFB84C),
          Color(0xFFD35400),
        ],
        count: 45,
        opacity: 0.95,
        speed: 0.65, // Smooth daytime drift
        seed: 24,
      ),
      // 4. Birds flying south — elegant seasonal transition
      SceneLayer(
        type: 'birds',
        colors: [Color(0xFF2C3E50)], // Dark silhouettes
        count: 4,
        speed: 0.5,
        opacity: 0.6,
        seed: 3,
      ),
      // 5. Subtle golden dust shimmer
      SceneLayer(
        type: 'shimmer',
        colors: [Color(0xFFFFF8E1)],
        interval: 15,
        opacity: 0.25,
        seed: 9,
      ),
      // 6. Subtle readability scrim
      SceneLayer(type: 'scrim', colors: [Color(0xFFFFFFFF)], opacity: 0.32),
    ]),
  );

  // ---------------------------------------------------------------------
  // WINTER — Alpine Snow Valley. Jagged peaks, frozen lake, heavy snow,
  // frost corners, and breath vapor near the fire.
  // ---------------------------------------------------------------------
  static const winter = DashboardHeaderTheme(
    id: 'winter',
    tagline: 'Snow Summits Await with',
    gradientColors: [Color(0xFFD6E6F5), Color(0xFFFFFFFF)],
    accent: Color(0xFF1E5AA8),
    accentLight: Color(0xFF4A8AD4),
    accentSoft: Color(0xFFE4EEF9),
    scene: HeaderSceneSpec([
      SceneLayer(
        type: 'sky',
        colors: [Color(0xFF0F2A44), Color(0xFF27496D), Color(0xFFDCEBFA)],
        colorsB: [Color(0xFF091A2E), Color(0xFF1A3A5C), Color(0xFFCFE4F7)],
        interval: 14,
      ),
      SceneLayer(
        type: 'particles',
        variant: 'stars',
        colors: [Color(0xFFFFFFFF), Color(0xFFCFE8FF)],
        count: 60,
        opacity: 0.9,
        speed: 0.4,
        seed: 5,
      ),
      SceneLayer(
        type: 'celestial',
        variant: 'moon',
        colors: [Color(0xFFF4F7FB)],
        x: 0.85,
        y: 0.13,
        size: 0.055,
        opacity: 0.95,
      ),
      SceneLayer(
        type: 'clouds',
        colors: [Color(0xFFE7F1FB)],
        count: 5,
        speed: 0.9,
        opacity: 0.8,
      ),
      SceneLayer(
        type: 'mountains',
        variant: 'sharp',
        colors: [Color(0xFF6D97C7), Color(0xFF4A72A6), Color(0xFF2A5288)],
        opacity: 0.95,
        speed: 0.9,
      ),
      // ---- LEFT & RIGHT — snow-pine treeline, rooted right at the ice edge ----
      SceneLayer(
        type: 'trees',
        variant: 'snowpine',
        colors: [Color(0xFF1B3B52), Color(0xFF33475C), Color(0xFFFFFFFF)],
        count: 6,
        y: 0.70,
        size: 0.24,
        speed: 0.7,
        opacity: 0.96,
        edge: 'left',
        seed: 5,
      ),
      SceneLayer(
        type: 'trees',
        variant: 'snowpine',
        colors: [Color(0xFF1B3B52), Color(0xFF33475C), Color(0xFFFFFFFF)],
        count: 6,
        y: 0.70,
        size: 0.24,
        speed: 0.7,
        opacity: 0.96,
        edge: 'right',
        seed: 17,
      ),

      // ---- FOOTING — frozen lake, the single clear ground/ice line ----
      // Top edge sits at y = 1 - 0.28 = 0.72, matching where trees, the
      // igloo, and the campfire are all rooted — nothing floats.
      SceneLayer(
        type: 'ground',
        variant: 'frozenLake',
        colors: [Color(0xFFDCEBFA), Color(0xFFA8C5E0)],
        size: 0.28,
        opacity: 1.0,
        edge: 'bottom',
        seed: 42,
      ),
      // Igloo and campfire sit ON the ice, not above it
      SceneLayer(
        type: 'igloo',
        colors: [Color(0xFFEFF7FF), Color(0xFFBFD8EA)],
        x: 0.15,
        y: 0.76,
        size: 0.13,
        opacity: 1.0,
      ),
      SceneLayer(
        type: 'campfire',
        colors: [Color(0xFFFF9800), Color(0xFFE65100)],
        x: 0.5,
        y: 0.82,
        size: 0.065,
        opacity: 1.0,
      ),
      SceneLayer(
        type: 'particles',
        variant: 'breath',
        colors: [Color(0xFFFFFFFF)],
        x: 0.5,
        y: 0.78,
        count: 3,
        opacity: 0.8,
        speed: 0.8,
        seed: 2,
      ),
      SceneLayer(
        type: 'particles',
        variant: 'snow',
        colors: [Color(0xFFFFFFFF), Color(0xFFDCEEFF)],
        count: 45,
        opacity: 0.78,
        speed: 0.4,
        seed: 11,
      ),
      SceneLayer(
        type: 'particles',
        variant: 'snow',
        colors: [Color(0xFFFFFFFF)],
        count: 30,
        opacity: 0.9,
        speed: 0.8,
        seed: 29,
      ),
      SceneLayer(
        type: 'shimmer',
        variant: 'frost',
        colors: [Color(0xFFDCEEFF)],
        interval: 14,
        opacity: 0.55,
      ),
      // Kept low so stars and moonlight stay the clear focal point
      SceneLayer(type: 'scrim', colors: [Color(0xFFFFFFFF)], opacity: 0.30),
    ]),
  );

  static const List<DashboardHeaderTheme> allSeasonal = [
    spring,
    summer,
    monsoon,
    autumn,
    winter,
  ];
}

class HeaderThemeController extends GetxController {
  final Rx<DashboardHeaderTheme> theme = DashboardHeaderTheme.classic.obs;

  // The on-screen S/S/M/A/W season switcher is a dev-only tool for previewing
  // scenes without touching the backend — it must never ship enabled, since
  // the theme now comes from remote config (GET /api/v1/dashboard-header-theme)
  // and admins control it from the Discovery Panel. Flip to true locally only.
  static const bool debugThemeSwitcherEnabled = false;

  @override
  void onInit() {
    super.onInit();
    loadTheme();
  }

  void debugSetTheme(DashboardHeaderTheme t) => theme.value = t;

  /// Renders the local seasonal theme immediately (never blocks/waits on
  /// network for the dashboard's first paint), then makes one best-effort
  /// attempt to fetch a currently-active remote theme (GET
  /// /api/v1/dashboard-header-theme — see
  /// controllers/v1/dashboardHeaderThemeController.js) and swaps it in if
  /// one exists. Backs two use cases: pushing updated seasonal scene
  /// content without an app release, and time-boxed brand-partner
  /// collaboration takeovers (colors/logo/tagline).
  Future<void> loadTheme() async {
    theme.value = seasonalFallback(DateTime.now());
    await _tryLoadRemoteTheme();
  }

  Future<void> _tryLoadRemoteTheme() async {
    try {
      final uri = Uri.parse(
        '${AppEnv().apiBaseUrl}/api/v1/dashboard-header-theme',
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 6));
      if (response.statusCode != 200) return;

      final body = jsonDecode(response.body);
      final data = body is Map ? body['data'] : null;
      // data is null whenever nothing's currently active on the backend —
      // an expected, routine state, not a failure. Local seasonal fallback
      // set above just keeps showing.
      if (data is! Map) return;

      theme.value = DashboardHeaderTheme.fromJson(
        Map<String, dynamic>.from(data),
      );
    } catch (_) {
      // Silent by design: this is a purely decorative, best-effort remote
      // config fetch layered on top of a theme that's already rendering.
      // Any failure (offline, timeout, malformed response) just leaves the
      // local seasonalFallback() in place — never a toast/error UI for
      // something this low-stakes.
    }
  }

  DashboardHeaderTheme seasonalFallback(DateTime now) {
    final m = now.month;
    if (m == 2 || m == 3) return DashboardHeaderTheme.spring;
    if (m >= 4 && m <= 6) return DashboardHeaderTheme.summer;
    if (m >= 7 && m <= 9) return DashboardHeaderTheme.monsoon;
    if (m == 10 || m == 11) return DashboardHeaderTheme.autumn;
    return DashboardHeaderTheme.winter;
  }
}
