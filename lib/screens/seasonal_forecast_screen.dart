import 'package:arobo_app/controller/dashboard_controller.dart';
import 'package:arobo_app/models/seasonal_picks_data.dart';
import 'package:arobo_app/utils/common_colors.dart';
import 'package:arobo_app/utils/common_images.dart';
import 'package:arobo_app/utils/screen_constants.dart';
import 'package:arobo_app/utils/seasonal_forecast_mock_data.dart';
import 'package:arobo_app/utils/seasonal_gradient_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer_ai/shimmer_ai.dart';
import 'package:sizer/sizer.dart';

/// Seasonal Forecast: per season, a ranked "Top 5" recommended row and a
/// separate "Avoid This Season" row, each a horizontally-swipeable set of
/// SeasonalGradientCards. Backed by the dedicated seasonal_forecast_picks
/// backend (GET /api/v1/discovery/seasonal-picks) — [TrekSeason] is kept
/// only as the shared enum/label/glyph source, not as a data source.
class SeasonalForecastScreen extends StatefulWidget {
  const SeasonalForecastScreen({super.key});

  @override
  State<SeasonalForecastScreen> createState() => _SeasonalForecastScreenState();
}

class _SeasonalForecastScreenState extends State<SeasonalForecastScreen> {
  final _dashboardC = Get.find<DashboardController>();
  TrekSeason? _selected;

  @override
  void initState() {
    super.initState();
    _dashboardC.fetchSeasonalPicks();
  }

  void _selectSeason(TrekSeason season) {
    setState(() => _selected = season);
    _dashboardC.fetchSeasonalPicks(season: season.name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CommonColors.offWhiteColor2,
      appBar: AppBar(
        backgroundColor: CommonColors.whiteColor,
        elevation: 0,
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: CommonColors.blackColor),
        title: Text(
          'Seasonal Forecast',
          style: GoogleFonts.poppins(
            color: CommonColors.blackColor,
            fontSize: FontSize.s11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Obx(() {
        final loading = _dashboardC.seasonalPicksObserver.value
            .maybeWhen(loading: (_) => true, orElse: () => false);
        final data = _dashboardC.seasonalPicksObserver.value
            .maybeWhen(success: (r) => r.data, orElse: () => null);

        final season = TrekSeason.values.firstWhere(
          (s) => s.name == (data?.season ?? _selected?.name),
          orElse: () => _selected ?? TrekSeason.spring,
        );
        // Explicit generic on the empty-list fallback — an inferred `[]`
        // here type-checks fine in debug/JIT but has crashed as
        // List<dynamic> in release/AOT builds when data or its picks are
        // null (e.g. a season with no picks yet).
        final topPicks = data?.topPicks ?? <SeasonalPickItem>[];
        final avoidPicks = data?.avoidPicks ?? <SeasonalPickItem>[];

        return ListView(
          padding: EdgeInsets.only(bottom: 3.h),
          children: [
            SizedBox(height: 1.5.h),
            _buildSeasonChips(season, loading),
            SizedBox(height: 2.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                data?.blurb ?? '',
                style: GoogleFonts.poppins(
                  fontSize: FontSize.s10,
                  fontWeight: FontWeight.w400,
                  color: CommonColors.blackColor.withValues(alpha: 0.65),
                  height: 1.4,
                ),
              ).withShimmerAi(loading: loading),
            ),
            SizedBox(height: 2.5.h),
            _buildSectionHeader('Top 5 for ${data?.label ?? ''}', loading),
            SizedBox(height: 1.2.h),
            _buildCardRow(topPicks, season: season, loading: loading),
            SizedBox(height: 3.h),
            _buildSectionHeader('Avoid This Season', loading),
            SizedBox(height: 1.2.h),
            _buildCardRow(avoidPicks, season: season, loading: loading),
          ],
        );
      }),
    );
  }

  Widget _buildSeasonChips(TrekSeason selected, bool loading) {
    return SizedBox(
      height: 5.5.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        itemCount: TrekSeason.values.length,
        separatorBuilder: (_, __) => SizedBox(width: 2.w),
        itemBuilder: (context, index) {
          final season = TrekSeason.values[index];
          final isSelected = season == selected;
          final label = seasonalForecastMockData[season]!.label;
          return ChoiceChip(
            label: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: FontSize.s9,
                fontWeight: FontWeight.w600,
                color: isSelected ? CommonColors.whiteColor : CommonColors.blackColor,
              ),
            ),
            selected: isSelected,
            selectedColor: CommonColors.darkCyan,
            backgroundColor: CommonColors.whiteColor,
            side: BorderSide(
              color: isSelected
                  ? CommonColors.darkCyan
                  : CommonColors.blackColor.withValues(alpha: 0.15),
            ),
            onSelected: loading ? null : (_) => _selectSeason(season),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool loading) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: FontSize.s12,
          fontWeight: FontWeight.w700,
          color: CommonColors.blackColor,
        ),
      ).withShimmerAi(loading: loading),
    );
  }

  Widget _buildCardRow(
    List<SeasonalPickItem> picks, {
    required TrekSeason season,
    required bool loading,
  }) {
    if (loading) {
      return SizedBox(
        height: 24.h,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          itemCount: 2,
          separatorBuilder: (_, __) => SizedBox(width: 3.w),
          itemBuilder: (context, index) => Container(
            width: 78.w,
            height: 24.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
          ).withShimmerAi(loading: true),
        ),
      );
    }

    if (picks.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: Text(
          'Nothing curated here yet.',
          style: GoogleFonts.poppins(
            fontSize: FontSize.s10,
            color: CommonColors.blackColor.withValues(alpha: 0.45),
          ),
        ),
      );
    }

    return SizedBox(
      height: 24.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        itemCount: picks.length,
        separatorBuilder: (_, __) => SizedBox(width: 3.w),
        itemBuilder: (context, index) {
          final pick = picks[index];
          final pickImageType = parseSeasonalPickImageType(pick.imageType);
          final resolvedImagePath = _fullImageUrl(pick.imagePath);
          // Only "photo" mode falls back to a stock photo when empty — an
          // empty illustration is a valid, handled state inside the card.
          final displayImagePath =
              pickImageType == SeasonalPickImageType.illustration
                  ? resolvedImagePath
                  : (resolvedImagePath.isEmpty
                      ? CommonImages.himalayas
                      : resolvedImagePath);
          return SeasonalGradientCard(
            trekName: pick.trekName ?? '',
            reason: pick.reason ?? '',
            imagePath: displayImagePath,
            imageType: pickImageType,
            isAvoid: pick.isAvoid ?? false,
            season: season,
            width: 78.w,
            height: 24.h,
          );
        },
      ),
    );
  }

  String _fullImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    return 'https://api.aorbotreks.co.in$path';
  }
}
