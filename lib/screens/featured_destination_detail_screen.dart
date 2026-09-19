import 'package:arobo_app/controller/dashboard_controller.dart';
import 'package:arobo_app/models/featured_destination_detail.dart';
import 'package:arobo_app/theme/app_tokens.dart';
import 'package:arobo_app/theme/app_typography.dart';
import 'package:arobo_app/utils/screen_constants.dart';
import 'package:arobo_app/widgets/custom_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

/// Read-only detail screen for a "Featured Destination" trek sourced from
/// aorbotreks.com's own API (a separate backend from ours — these treks
/// don't exist in our own DB, so there's no booking flow here). Replaces
/// opening the full website on tap, which was slow/laggy — this fetches the
/// site's lightweight JSON detail endpoint and renders it natively instead.
///
/// [previewTitle]/[previewImage] come from the card that was tapped, so the
/// screen paints instantly (title + hero visible immediately) while the
/// fuller detail streams in behind it, rather than opening blank.
class FeaturedDestinationDetailScreen extends StatefulWidget {
  final String slug;
  final String? previewTitle;
  final String? previewImage;

  const FeaturedDestinationDetailScreen({
    super.key,
    required this.slug,
    this.previewTitle,
    this.previewImage,
  });

  @override
  State<FeaturedDestinationDetailScreen> createState() =>
      _FeaturedDestinationDetailScreenState();
}

class _FeaturedDestinationDetailScreenState
    extends State<FeaturedDestinationDetailScreen> {
  FeaturedDestinationDetail? _detail;
  bool _loading = true;
  bool _failed = false;

  static const _accent = AppColors.teal;
  static const _bg = AppColors.bg;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await Get.find<DashboardController>()
        .fetchFeaturedDestinationDetail(widget.slug);
    if (!mounted) return;
    setState(() {
      _detail = result;
      _failed = result == null;
      _loading = false;
    });
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      // A dead link must never surface an error to the user.
    }
  }

  String get _websiteUrl => 'https://www.aorbotreks.com/treks/${widget.slug}';

  @override
  Widget build(BuildContext context) {
    final detail = _detail;
    final heroImage = (detail?.mainImage.isNotEmpty ?? false)
        ? detail!.mainImage
        : (widget.previewImage ?? '');
    final title = detail?.name.isNotEmpty == true
        ? detail!.name
        : (widget.previewTitle ?? '');

    return Scaffold(
      backgroundColor: _bg,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.only(left: 3.w),
          child: Material(
            color: Colors.black.withValues(alpha: 0.28),
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => Get.back(),
              child: const SizedBox(
                width: 36,
                height: 36,
                child: Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHero(context, heroImage, title, detail),
            Transform.translate(
              offset: const Offset(0, -1),
              child: Container(
                width: 100.w,
                padding: EdgeInsets.fromLTRB(4.w, 2.6.h, 4.w, 4.h),
                decoration: const BoxDecoration(
                  color: _bg,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildQuickFacts(detail),
                    if (_failed) _buildErrorNotice(),
                    if (detail?.description.isNotEmpty ?? false)
                      _sectionShell(
                        title: 'About this trek',
                        child: Text(
                          detail!.description,
                          style: AppType.style(FontSize.s10, color: AppColors.inkMid, height: 1.6),
                        ),
                      ),
                    if (detail?.famousPlaces.isNotEmpty ?? false)
                      _buildChipsSection('Famous places', detail!.famousPlaces, Icons.place_rounded),
                    if (detail?.activities.isNotEmpty ?? false)
                      _buildChipsSection('Activities', detail!.activities, Icons.hiking_rounded),
                    if (detail?.operators.isNotEmpty ?? false)
                      _buildOperatorsSection(detail!.operators),
                    if (detail?.relatedTreks.isNotEmpty ?? false)
                      _buildRelatedTreks(detail!.relatedTreks),
                    _buildCtaRow(detail),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(
    BuildContext context,
    String imageUrl,
    String title,
    FeaturedDestinationDetail? detail,
  ) {
    final topInset = MediaQuery.of(context).viewPadding.top + kToolbarHeight;
    return SizedBox(
      width: 100.w,
      height: topInset + 32.h,
      child: Stack(
        fit: StackFit.expand,
        children: [
          imageUrl.isEmpty
              ? Container(color: _accent.withValues(alpha: 0.15))
              : CustomNetworkImage(
                  imageUrl: imageUrl,
                  width: 100.w,
                  height: topInset + 32.h,
                  fit: BoxFit.cover,
                  borderRadius: 0,
                ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.35, 1.0],
                colors: [Colors.transparent, Colors.black.withValues(alpha: 0.72)],
              ),
            ),
          ),
          if (detail?.priceStart != null)
            Positioned(
              top: topInset + 1.h,
              right: 5.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 3.2.w, vertical: 1.1.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.96),
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.currency_rupee_rounded, size: 12, color: _accent),
                    SizedBox(width: 0.5.w),
                    Text(
                      '${detail!.priceStart} onwards',
                      style: AppType.style(FontSize.s10, w: FontWeight.w700, color: _accent),
                    ),
                  ],
                ),
              ),
            ),
          Positioned(
            left: 5.w,
            right: 5.w,
            bottom: 2.5.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppType.style(
                    FontSize.s19,
                    w: FontWeight.w800,
                    color: Colors.white,
                    height: 1.15,
                    letterSpacing: -0.2,
                    shadows: const [Shadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 2))],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (detail?.state.isNotEmpty ?? false) ...[
                  SizedBox(height: 0.7.h),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on_rounded, size: 14, color: Colors.white),
                      SizedBox(width: 1.w),
                      Text(
                        detail!.state,
                        style: AppType.style(FontSize.s10, w: FontWeight.w500, color: Colors.white.withValues(alpha: 0.92)),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFacts(FeaturedDestinationDetail? detail) {
    return _sectionShell(
      title: 'Trip details',
      isLast: false,
      child: _loading
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _skeletonLine(width: 48.w),
                SizedBox(height: 1.3.h),
                _skeletonLine(width: 56.w),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _factChipsRow(Icons.access_time_rounded, 'Duration', detail?.durationDays ?? '—'),
                SizedBox(height: 1.6.h),
                _factChipsRow(Icons.calendar_month_rounded, 'Departure', detail?.operatingDays ?? '—'),
              ],
            ),
    );
  }

  /// Splits a raw comma-joined value ("3D/2N,4D/3N,5D/4N Days", "THU, FRI,
  /// SAT") into individual pills instead of one run-on line of text — each
  /// option (each duration, each departure day) reads as its own discrete
  /// choice rather than a single blob the eye has to parse.
  Widget _factChipsRow(IconData icon, String label, String value) {
    final options = value
        .replaceAll(RegExp(r'\s*days\s*$', caseSensitive: false), '')
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: _accent.withValues(alpha: 0.10), shape: BoxShape.circle),
          child: Icon(icon, size: 15, color: _accent),
        ),
        SizedBox(width: 2.8.w),
        Padding(
          padding: EdgeInsets.only(top: 0.5.h),
          child: Text(label, style: AppType.style(FontSize.s10, w: FontWeight.w500, color: AppColors.inkMid)),
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: options.isEmpty
              ? Padding(
                  padding: EdgeInsets.only(top: 0.5.h),
                  child: Text(value, style: AppType.style(FontSize.s10, w: FontWeight.w700, color: AppColors.ink)),
                )
              : Wrap(
                  spacing: 1.6.w,
                  runSpacing: 1.h,
                  children: options.map((option) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 2.6.w, vertical: 0.6.h),
                      decoration: BoxDecoration(
                        color: _accent.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: _accent.withValues(alpha: 0.16)),
                      ),
                      child: Text(
                        option,
                        style: AppType.style(FontSize.s9, w: FontWeight.w700, color: AppColors.ink),
                      ),
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }

  Widget _skeletonLine({double width = 60}) {
    return Container(
      height: 1.6.h,
      width: width,
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildErrorNotice() {
    return _sectionShell(
      title: 'Couldn\'t load full details',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.cloud_off_rounded, size: 16, color: AppColors.inkLight),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  'We couldn\'t reach the full trip details right now.',
                  style: AppType.style(FontSize.s10, color: AppColors.inkMid, height: 1.5),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.5.h),
          _outlinedButton('View on website', () => _openUrl(_websiteUrl)),
        ],
      ),
    );
  }

  Widget _buildChipsSection(String title, List<String> items, IconData icon) {
    return _sectionShell(
      title: title,
      child: Wrap(
        spacing: 2.2.w,
        runSpacing: 1.2.h,
        children: items.map((item) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 3.2.w, vertical: 0.9.h),
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: _accent.withValues(alpha: 0.16)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 12, color: _accent),
                SizedBox(width: 1.4.w),
                Text(item, style: AppType.style(FontSize.s9, w: FontWeight.w600, color: AppColors.ink)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOperatorsSection(List<String> operators) {
    return _sectionShell(
      title: 'Operators',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: operators.map((op) {
          final isLast = op == operators.last;
          return Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 1.h),
            child: Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: _accent.withValues(alpha: 0.10), shape: BoxShape.circle),
                  child: Icon(Icons.verified_rounded, size: 14, color: _accent),
                ),
                SizedBox(width: 2.8.w),
                Expanded(
                  child: Text(op, style: AppType.style(FontSize.s10, w: FontWeight.w500, color: AppColors.ink)),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRelatedTreks(List<RelatedTrek> related) {
    return _sectionShell(
      title: 'You may also like',
      child: SizedBox(
        height: 6.h,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: related.length,
          separatorBuilder: (_, __) => SizedBox(width: 2.w),
          itemBuilder: (context, i) {
            final trek = related[i];
            if (trek.id == null) return const SizedBox.shrink();
            return GestureDetector(
              onTap: () => Get.to(
                () => FeaturedDestinationDetailScreen(
                  slug: trek.id.toString(),
                  previewTitle: trek.name,
                ),
              ),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: _accent.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _accent.withValues(alpha: 0.16)),
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trek.name,
                      style: AppType.style(FontSize.s10, w: FontWeight.w700, color: AppColors.ink),
                    ),
                    if (trek.state.isNotEmpty) ...[
                      SizedBox(height: 0.2.h),
                      Text(
                        trek.state,
                        style: AppType.style(FontSize.s8, color: AppColors.inkMid),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCtaRow(FeaturedDestinationDetail? detail) {
    final hasCoords = detail?.latitude != null && detail?.longitude != null;
    return Padding(
      padding: EdgeInsets.only(top: 0.5.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasCoords) ...[
            _outlinedButton(
              'Open in Maps',
              () => _openUrl(
                'https://www.google.com/maps/search/?api=1&query=${detail!.latitude},${detail.longitude}',
              ),
              icon: Icons.map_rounded,
            ),
            SizedBox(height: 1.3.h),
          ],
          _filledButton(
            'View full details on aorbotreks.com',
            () => _openUrl(_websiteUrl),
          ),
        ],
      ),
    );
  }

  Widget _outlinedButton(String label, VoidCallback onTap, {IconData? icon}) {
    return SizedBox(
      width: 100.w - 8.w,
      height: 6.4.h,
      child: OutlinedButton.icon(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: _accent.withValues(alpha: 0.35), width: 1.3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        icon: Icon(icon ?? Icons.open_in_new_rounded, size: 16, color: _accent),
        label: Text(label, style: AppType.style(FontSize.s10, w: FontWeight.w700, color: _accent)),
      ),
    );
  }

  Widget _filledButton(String label, VoidCallback onTap) {
    return Container(
      width: 100.w - 8.w,
      height: 6.4.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: _accent.withValues(alpha: 0.32), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: _accent,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        icon: const Icon(Icons.open_in_new_rounded, size: 16, color: Colors.white),
        label: Text(
          label,
          style: AppType.style(FontSize.s10, w: FontWeight.w700, color: Colors.white),
        ),
      ),
    );
  }

  Widget _sectionShell({required String title, required Widget child, bool isLast = false}) {
    return Container(
      width: 100.w - 8.w,
      margin: EdgeInsets.only(bottom: isLast ? 0 : 1.8.h),
      padding: EdgeInsets.fromLTRB(4.2.w, 2.2.h, 4.2.w, 2.2.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppType.style(FontSize.s12, w: FontWeight.w700, color: _accent, letterSpacing: -0.1),
          ),
          SizedBox(height: 1.4.h),
          child,
        ],
      ),
    );
  }
}
