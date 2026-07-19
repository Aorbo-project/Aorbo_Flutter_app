import 'package:arobo_app/utils/common_colors.dart';
import 'package:arobo_app/utils/seasonal_forecast_mock_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/custom_network_image.dart';

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
    required this.isAvoid,
    required this.season,
    required this.width,
    required this.height,
    this.onTap,
  });

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
              // Full-bleed trek photo — the illustration IS the card,
              // not a corner thumbnail.
              imagePath.startsWith('http')
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
                    ),

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

              // Trek name + reason, overlaid on the scrim.
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
