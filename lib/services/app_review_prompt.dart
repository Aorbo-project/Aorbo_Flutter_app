import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:in_app_review/in_app_review.dart';

/// Google Play's own in-app rating box ("Rate Aorbo Treks"), shown at a happy
/// moment: right after the customer saves a 4–5 star review of a completed
/// trek. Nothing is stored by Aorbo — the rating goes straight to Google Play.
///
/// Deliberately NOT behind the "Rate us" menu row: Google limits how often the
/// box may appear and never says when it won't, so a button could silently do
/// nothing. "Rate us" keeps opening the Play Store page (my_account_screen).
///
/// Google decides whether the box actually shows (quota, already rated, not a
/// Play install, closed-testing track); every failure is silent.
class AppReviewPrompt {
  AppReviewPrompt._();

  /// Lowest trek-review star rating that leads to the Play rating box.
  static const int minStars = 4;

  /// Lets the screens that save the review finish closing first.
  static const Duration settleDelay = Duration(milliseconds: 900);

  @visibleForTesting
  static InAppReview? reviewOverride;

  static bool shouldAsk(int stars) => stars >= minStars;

  /// Call after a trek review was saved with [stars].
  static Future<void> afterTrekReview(int stars, {Duration delay = settleDelay}) async {
    if (!shouldAsk(stars)) return;
    final review = reviewOverride ?? InAppReview.instance;
    try {
      if (delay > Duration.zero) await Future<void>.delayed(delay);
      if (await review.isAvailable()) await review.requestReview();
    } catch (_) {
      // Not available on this device / install — nothing to show.
    }
  }
}
