import 'package:arobo_app/controller/dashboard_controller.dart';
import 'package:arobo_app/utils/app_theme.dart';
import 'package:arobo_app/utils/common_colors.dart';
import 'package:arobo_app/utils/screen_constants.dart';
import 'package:arobo_app/utils/know_more_card.dart';
import 'package:arobo_app/models/know_more_data.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:get/get.dart';
import 'package:shimmer_ai/shimmer_ai.dart';

const _emphasizedDecelerate = Cubic(0.05, 0.7, 0.1, 1.0);

String _getFullImageUrl(String? path) {
  if (path == null || path.isEmpty) return '';
  if (path.startsWith('http')) return path;
  return 'https://api.aorbotreks.co.in$path';
}

class KnowMoreScreen extends StatelessWidget {
  const KnowMoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardC = Get.find<DashboardController>();

    return Scaffold(
      backgroundColor: CommonColors.offWhiteColor2,
      appBar: AppBar(
        backgroundColor: CommonColors.whiteColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: CommonColors.blackColor),
        title: Text(
          "What's New",
          textScaler: const TextScaler.linear(1.0),
          style: GoogleFonts.poppins(
            fontSize: FontSize.s14,
            fontWeight: FontWeight.w600,
            color: CommonColors.blackColor,
          ),
        ),
      ),
      body: Obx(() {
        final loading = dashboardC.whatsNewObserver.value.maybeWhen(
          loading: (_) => true,
          orElse: () => false,
        );

        final response = dashboardC.whatsNewObserver.value.maybeWhen(
          success: (data) => data.data ?? [],
          orElse: () => <KnowMoreData>[],
        );

        final items = response.map<KnowMoreData>((e) {
          return KnowMoreData(
            title: e.title ?? '',
            subtitle: e.subtitle ?? '',
            hasKnowMore: e.hasKnowMore ?? false,
            imagePath: _getFullImageUrl(e.imagePath),
            textColour: e.textColour ?? '#FFFFFF',
            gradient: (e.gradient?.isNotEmpty ?? false)
                ? e.gradient
                : const ['#0F7B6C', '#1AA090'],
            detailedTitle: e.detailedTitle,
            detailedDescription: e.detailedDescription,
            bulletPoints: e.bulletPoints,
            callToAction: e.callToAction,
          );
        }).toList();

        if (loading) {
          return ListView.separated(
            padding: EdgeInsets.symmetric(
              horizontal: ScreenConstant.size16,
              vertical: ScreenConstant.size16,
            ),
            itemCount: 4,
            separatorBuilder: (_, __) => SizedBox(height: 2.h),
            itemBuilder: (context, index) => SizedBox(
              height: 22.h,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(20),
                ),
              ).withShimmerAi(loading: true),
            ),
          );
        }

        if (items.isEmpty) {
          return const _EmptyState();
        }

        return ListView.separated(
          padding: EdgeInsets.symmetric(
            horizontal: ScreenConstant.size16,
            vertical: ScreenConstant.size16,
          ),
          itemCount: items.length,
          separatorBuilder: (_, __) => SizedBox(height: 2.h),
          itemBuilder: (context, index) {
            final cardData = items[index];
            return _AnimatedEntrance(
              delay: index * 70,
              child: SizedBox(
                height: 22.h,
                child: KnowMoreCard(
                  widthFraction: 100,
                  trailingMargin: 0,
                  gradientColors: cardData.gradient ?? [],
                  imagePath: cardData.imagePath ?? '',
                  title: cardData.title ?? '',
                  subtitle: cardData.subtitle ?? '',
                  textColor: cardData.textColour != null
                      ? AppTheme.hexToColor(cardData.textColour)
                      : null,
                  onKnowMoreTap: cardData.hasKnowMore == false
                      ? null
                      : () {
                          Get.toNamed(
                            '/know-more-details',
                            arguments: {'knowMoreData': cardData},
                          );
                        },
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_awesome_outlined,
              size: 40,
              color: CommonColors.blackColor.withValues(alpha: 0.25),
            ),
            SizedBox(height: 2.h),
            Text(
              'Nothing new right now',
              textAlign: TextAlign.center,
              textScaler: const TextScaler.linear(1.0),
              style: GoogleFonts.poppins(
                fontSize: FontSize.s12,
                fontWeight: FontWeight.w600,
                color: CommonColors.blackColor.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedEntrance extends StatelessWidget {
  final Widget child;
  final int delay;

  const _AnimatedEntrance({required this.child, this.delay = 0});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + delay),
      curve: _emphasizedDecelerate,
      builder: (context, value, c) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 16),
            child: c,
          ),
        );
      },
      child: child,
    );
  }
}
