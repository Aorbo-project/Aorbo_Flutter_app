import 'dart:async';

import 'package:arobo_app/controller/dashboard_controller.dart';
import 'package:arobo_app/models/top_treks_data.dart';
import 'package:arobo_app/theme/app_tokens.dart';
import 'package:arobo_app/utils/common_colors.dart';
import 'package:arobo_app/utils/featured_destination_nav.dart';
import 'package:arobo_app/utils/screen_constants.dart';
import 'package:arobo_app/utils/top_treks_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:arobo_app/theme/app_typography.dart';

class PopularTreksScreen extends StatefulWidget {
  const PopularTreksScreen({super.key});

  @override
  State<PopularTreksScreen> createState() => _PopularTreksScreenState();
}

class _PopularTreksScreenState extends State<PopularTreksScreen> {
  final ScrollController _scrollController = ScrollController();

  final _dashboardC = Get.find<DashboardController>();

  // Local `_favoriteTreks` map REMOVED — favorites now live in
  // `_dashboardC.favoriteTrekOverrides`, shared with the Dashboard, so
  // likes survive back-navigation and stay in sync across both screens.

  // Free-text "search for a destination or trek" — separate from the
  // dashboard's From/To/Date booking-route search, this is the simple
  // name search (same one the aorbotreks.com website has). null results
  // means "no search active, show the normal Top Treks list"; an empty
  // (non-null) list means "searched, found nothing".
  final _searchController = TextEditingController();
  Timer? _debounce;
  List<TopTreksData>? _searchResults;
  bool _searching = false;

  String _getFullImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    return 'https://api.aorbotreks.co.in$path';
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      setState(() {
        _searchResults = null;
        _searching = false;
      });
      return;
    }
    setState(() => _searching = true);
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      final results = await _dashboardC.searchFeaturedDestinations(trimmed);
      // Guard against a slower, now-stale request landing after the user
      // has kept typing — only apply results that still match the field.
      if (!mounted || _searchController.text.trim() != trimmed) return;
      setState(() {
        _searchResults = results;
        _searching = false;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _toggleFavorite(int id, bool currentlyFavorite) async {
    // Optimistic write to the SHARED map — the Dashboard carousel reads the
    // same map, so a like here instantly reflects there too. No setState
    // needed: every Obx subscribed to the RxMap rebuilds automatically.
    _dashboardC.favoriteTrekOverrides[id] = !currentlyFavorite;
    final success = await _dashboardC.toggleTopTrekFavorite(
      id,
      currentlyFavorite,
    );
    if (!success) {
      // API failed → roll the shared state back.
      _dashboardC.favoriteTrekOverrides[id] = currentlyFavorite;
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
          style: AppType.style(
            FontSize.s14,
            w: FontWeight.w500,
            color: CommonColors.blackColor,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: Obx(() {
              final topTreksData = _dashboardC.topTreksObserver.value.maybeWhen(
                success: (response) => response.data ?? [],
                orElse: () => [],
              );

              // Capture the shared favorites via `.value` INSIDE this Obx so
              // the grid subscribes to it. Any like/unlike — made here OR on
              // the Dashboard — rebuilds this grid, even while covered by
              // another route. (The capture must happen here, not inside
              // itemBuilder — itemBuilder runs during layout, outside GetX's
              // tracking.)
              final favoriteOverrides = _dashboardC.favoriteTrekOverrides.value;

              final displayData = _searchResults ?? topTreksData;

              if (_searchResults != null && _searchResults!.isEmpty && !_searching) {
                return _buildNoResults();
              }

              return GridView.builder(
                controller: _scrollController,
                padding: EdgeInsets.fromLTRB(4.w, 1.h, 4.w, 2.h),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 3.w,
                  mainAxisSpacing: 2.h,
                  childAspectRatio:
                      0.8, // 4:5 portrait — matches the dashboard carousel card and the recommended upload spec
                ),
                itemCount: displayData.length,
                itemBuilder: (context, index) {
                  final trekData = displayData[index];
                  final isTrending = trekData.badgeType == 'trending';
                  final trekId = trekData.id;
                  // Session overrides (likes made this session on ANY
                  // screen) win over the server snapshot delivered with the
                  // last fetch.
                  final isFavorite =
                      favoriteOverrides[trekId] ?? (trekData.isFavorite ?? false);
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      return TopTreksCard(
                        onTap: () => openFeaturedDestination(trekData),
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
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(4.w, 1.6.h, 4.w, 0.6.h),
      child: Container(
        height: 6.h,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.search_rounded, size: 19, color: AppColors.inkMid),
            SizedBox(width: 2.5.w),
            Expanded(
              child: MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  style: AppType.style(FontSize.s11, w: FontWeight.w500, color: AppColors.ink),
                  decoration: InputDecoration(
                    hintText: 'Search for a destination or trek...',
                    hintStyle: AppType.style(FontSize.s11, color: AppColors.inkLight),
                    border: InputBorder.none,
                    isCollapsed: true,
                  ),
                ),
              ),
            ),
            if (_searching)
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.teal),
              )
            else if (_searchController.text.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _searchController.clear();
                  _onSearchChanged('');
                },
                child: Icon(Icons.close_rounded, size: 18, color: AppColors.inkLight),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 40, color: AppColors.inkLight),
            SizedBox(height: 1.5.h),
            Text(
              'No treks found for "${_searchController.text.trim()}"',
              textAlign: TextAlign.center,
              style: AppType.style(FontSize.s11, w: FontWeight.w600, color: AppColors.inkMid),
            ),
          ],
        ),
      ),
    );
  }
}
