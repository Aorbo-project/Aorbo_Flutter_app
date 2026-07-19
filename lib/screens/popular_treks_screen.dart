import 'package:arobo_app/controller/dashboard_controller.dart';
import 'package:arobo_app/utils/common_colors.dart';
import 'package:arobo_app/utils/screen_constants.dart';
import 'package:arobo_app/utils/top_treks_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

class PopularTreksScreen extends StatefulWidget {
  const PopularTreksScreen({super.key});

  @override
  State<PopularTreksScreen> createState() => _PopularTreksScreenState();
}

class _PopularTreksScreenState extends State<PopularTreksScreen> {
  final ScrollController _scrollController = ScrollController();
  final Map<int, bool> _favoriteTreks = {};

  final _dashboardC = Get.find<DashboardController>();

  String _getFullImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    return 'https://api.aorbotreks.co.in$path';
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _toggleFavorite(int id, bool currentlyFavorite) async {
    setState(() => _favoriteTreks[id] = !currentlyFavorite);
    final success = await _dashboardC.toggleTopTrekFavorite(
      id,
      currentlyFavorite,
    );
    if (!success && mounted) {
      setState(() => _favoriteTreks[id] = currentlyFavorite);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CommonColors.offWhiteColor2,
      appBar: AppBar(
        backgroundColor: CommonColors.whiteColor,
        elevation: 2,
        shadowColor: CommonColors.shadowColor.withValues(alpha: 0.25),
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: CommonColors.blackColor),
        title: Text(
          'Popular Treks',
          textScaler: const TextScaler.linear(1.0),
          style: GoogleFonts.poppins(
            fontSize: FontSize.s14,
            fontWeight: FontWeight.w500,
            color: CommonColors.blackColor,
          ),
        ),
      ),
      body: Obx(() {
        final topTreksData = _dashboardC.topTreksObserver.value.maybeWhen(
          success: (response) => response.data ?? [],
          orElse: () => [],
        );

        return GridView.builder(
          controller: _scrollController,
          padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 2.h),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 3.w,
            mainAxisSpacing: 2.h,
            childAspectRatio: 0.8, // 4:5 portrait — matches the dashboard carousel card and the recommended upload spec
          ),
          itemCount: topTreksData.length,
          itemBuilder: (context, index) {
            final trekData = topTreksData[index];
            final isTrending = trekData.badgeType == 'trending';
            final trekId = trekData.id;
            final isFavorite =
                _favoriteTreks[trekId] ?? (trekData.isFavorite ?? false);
            return LayoutBuilder(
              builder: (context, constraints) {
                return TopTreksCard(
                  imagePath: _getFullImageUrl(trekData.imagePath),
                  title: trekData.title ?? "",
                  description: trekData.description ?? "",
                  kicker: trekData.kicker,
                  meta: trekData.meta,
                  badgeText: isTrending ? 'Trending' : 'Top Pick',
                  badgeIcon: isTrending
                      ? Icons.local_fire_department_rounded
                      : Icons.star_rounded,
                  isFavorite: isFavorite,
                  onFavoriteTap: trekId == null
                      ? null
                      : () => _toggleFavorite(trekId, isFavorite),
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                );
              },
            );
          },
        );
      }),
    );
  }
}
