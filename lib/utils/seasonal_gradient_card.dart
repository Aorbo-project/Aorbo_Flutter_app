import 'package:arobo_app/utils/common_colors.dart';
import 'package:arobo_app/utils/seasonal_forecast_mock_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/custom_network_image.dart';

/// Whether a pick's [SeasonalGradientCard.imagePath] is a full photo (the
/// default — rendered edge-to-edge, `BoxFit.cover`) or a transparent-
/// background illustration/icon with no photo of its own (rendered
/// `BoxFit.contain` inside a fixed slot over an automatic season-themed
/// gradient, mirroring KnowMoreCard's illustration technique — see
/// [seasonBackdropGradient]).
enum SeasonalPickImageType { photo, illustration }

/// Parses the API's `imageType` string ("photo" / "illustration").
/// Defaults to [SeasonalPickImageType.photo] for null/unrecognised values —
/// same default as the backend column — so old cached responses or a typo'd
/// value never crash the card, just render as a normal photo card.
SeasonalPickImageType parseSeasonalPickImageType(String? value) {
  return value == 'illustration'
      ? SeasonalPickImageType.illustration
      : SeasonalPickImageType.photo;
}

/// Seasonal Forecast's card — rebuilt on the same full-bleed-photo +
/// bottom scrim + top-left pill + top-right chip grammar as
/// [TopTreksCard] (see top_treks_card.dart), so the whole dashboard reads
/// as one component family instead of two. The trek photo fills the
/// entire card; the scrim tints teal for a Recommended verdict or ember
/// for Avoid, and the badge pill carries a season-specific glyph (see
/// [seasonGlyphSvg]) instead of a generic eco/warning icon.
class SeasonalGradientCard extends StatelessWidget {
  final String trekName;
  final String reason;
  final String imagePath;
  final SeasonalPickImageType imageType;
  final bool isAvoid;
  final TrekSeason season;
  final double width;
  final double height;
  final VoidCallback? onTap;

  const SeasonalGradientCard({
    super.key,
    required this.trekName,
    required this.reason,
    required this.imagePath,
    this.imageType = SeasonalPickImageType.photo,
    required this.isAvoid,
    required this.season,
    required this.width,
    required this.height,
    this.onTap,
  });

  /// The background layer — a full-bleed cover photo, or (illustration
  /// mode) just the automatic season gradient. The illustration graphic
  /// itself lives in [_buildIllustrationImage], laid out as part of the
  /// row in [build] — not here — since illustration mode needs it beside
  /// the text, not stacked behind it.
  Widget _buildBackground() {
    if (imageType == SeasonalPickImageType.illustration || imagePath.isEmpty) {
      // Photo mode with nothing set also falls back to the season
      // gradient, rather than crashing on Image.asset('').
      return DecoratedBox(
        decoration: BoxDecoration(gradient: seasonBackdropGradient(season)),
      );
    }

    return imagePath.startsWith('http')
        ? CustomNetworkImage(
            imageUrl: imagePath,
            width: width,
            height: height,
            fit: BoxFit.cover,
            borderRadius: 22,
          )
        : Image.asset(
            imagePath,
            width: width,
            height: height,
            fit: BoxFit.cover,
          );
  }

  /// The illustration graphic, contained (never stretched/cropped) — no
  /// image uploaded yet just renders nothing, leaving the gradient alone
  /// as a complete, valid look rather than a broken/empty box.
  Widget _buildIllustrationImage() {
    if (imagePath.isEmpty) return const SizedBox.shrink();
    return imagePath.startsWith('http')
        ? CustomNetworkImage(
            imageUrl: imagePath,
            fit: BoxFit.contain,
            hasTransparentBackground: true,
            borderRadius: 0,
          )
        : Image.asset(imagePath, fit: BoxFit.contain);
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(24);
    final Color verdictColor =
        isAvoid ? CommonColors.appRedColor : CommonColors.darkCyan;

    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: radius,
            color: CommonColors.grey200,
            border: Border.all(
              color: CommonColors.whiteColor.withValues(alpha: 0.18),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: CommonColors.blackColor.withValues(alpha: 0.16),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background — full-bleed trek photo, or (illustration
              // mode) an automatic season gradient with the cutout
              // contained in a fixed slot. See _buildBackground().
              _buildBackground(),

              // Bottom scrim — teal-tinted for Recommended, ember-tinted
              // for Avoid, so the verdict reads as colour before text.
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: radius,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.22, 0.6, 1.0],
                    colors: [
                      Colors.transparent,
                      CommonColors.blackColor.withValues(alpha: 0.38),
                      Color.lerp(
                        CommonColors.blackColor,
                        verdictColor,
                        0.28,
                      )!.withValues(alpha: 0.88),
                    ],
                  ),
                ),
              ),

              // Season badge — glyph + verdict label, same slot as
              // TopTreksCard's "Top Pick" pill.
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: CommonColors.whiteColor.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                        color: CommonColors.blackColor.withValues(alpha: 0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 13,
                        height: 13,
                        child: SvgPicture.string(
                          seasonGlyphSvg(season),
                          colorFilter: ColorFilter.mode(
                            verdictColor,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        isAvoid ? 'AVOID' : 'RECOMMENDED',
                        textScaler: const TextScaler.linear(1.0),
                        style: GoogleFonts.poppins(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w700,
                          color: verdictColor,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Top-right chip — a small warning chip for an Avoid pick,
              // same slot as the heart-save on TopTreksCard. Recommended
              // picks leave this corner empty; the carousel order already
              // carries the ranking, so the card doesn't repeat it.
              if (isAvoid)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: CommonColors.blackColor.withValues(alpha: 0.32),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: CommonColors.appRedColor2.withValues(alpha: 0.6),
                      ),
                    ),
                    child: Icon(
                      Icons.priority_high_rounded,
                      size: 15,
                      color: CommonColors.appRedColor2,
                    ),
                  ),
                ),

              // Illustration mode: icon + text side by side (mirrors
              // KnowMoreCard's What's New layout exactly, not just the
              // icon's position) — uses the space a bottom-anchored block
              // would otherwise leave empty on the right. More top
              // clearance than before, now that text no longer needs
              // reserved space below the icon.
              if (imageType == SeasonalPickImageType.illustration)
                Positioned(
                  top: height * 0.30,
                  bottom: height * 0.10,
                  left: 14,
                  right: 14,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: width * 0.34,
                        height: double.infinity,
                        child: _buildIllustrationImage(),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              trekName,
                              textScaler: const TextScaler.linear(1.0),
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: CommonColors.whiteColor,
                                letterSpacing: -0.2,
                                height: 1.15,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              reason,
                              textScaler: const TextScaler.linear(1.0),
                              style: GoogleFonts.poppins(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w400,
                                color: CommonColors.whiteColor.withValues(alpha: 0.82),
                                height: 1.3,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              else
                // Photo mode: trek name + reason overlaid on the scrim at
                // the bottom, unchanged from the original design.
                Positioned(
                  left: 14,
                  right: 14,
                  bottom: 14,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        trekName,
                        textScaler: const TextScaler.linear(1.0),
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: CommonColors.whiteColor,
                          letterSpacing: -0.2,
                          height: 1.1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        reason,
                        textScaler: const TextScaler.linear(1.0),
                        style: GoogleFonts.poppins(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w400,
                          color: CommonColors.whiteColor.withValues(alpha: 0.82),
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
