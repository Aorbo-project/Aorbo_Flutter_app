import '../repository/referral_repository.dart';
import 'giveaway_bridge.dart';

/// Outcome of an entry request, passed back to the web page as-is.
class EntryResult {
  const EntryResult.ok(this.data)
      : ok = true,
        errorCode = null,
        errorMessage = null;
  const EntryResult.failed(this.errorCode, this.errorMessage)
      : ok = false,
        data = const {};

  final bool ok;
  final Map<String, Object?> data;
  final String? errorCode;
  final String? errorMessage;
}

/// The giveaway's backend calls, as the app sees them.
///
/// DESIGN PHASE: [GiveawayApi.instance] is [PreviewGiveawayApi] — sample
/// data, no network, so the screens can be reviewed before the backend
/// exists. The backend phase adds the real implementation:
///   createWebCode → POST campaign/web-code   (login + Play Integrity)
///   submitEntry   → POST campaign/entries    (login + Play Integrity,
///                                             Idempotency-Key = request id)
abstract class GiveawayApi {
  static GiveawayApi instance = PreviewGiveawayApi();

  /// One-time code that signs the web page in (60 s, single use).
  /// Null when there is none — the page then shows its public view.
  Future<String?> createWebCode();

  Future<EntryResult> submitEntry({required String requestId, required EntrySubmission entry});

  /// The signed-in user's own referral code, for the share sheet.
  Future<String?> myReferralCode();
}

class PreviewGiveawayApi implements GiveawayApi {
  @override
  Future<String?> createWebCode() async => null;

  @override
  Future<EntryResult> submitEntry({required String requestId, required EntrySubmission entry}) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    return const EntryResult.ok({'entryNumber': '01842', 'status': 'valid', 'round': 'R1'});
  }

  // Real call — the referral code already exists for every signed-in user.
  @override
  Future<String?> myReferralCode() async {
    final info = await ReferralRepository().getReferralInfo();
    final code = info.code;
    return (code == null || code.isEmpty) ? null : code;
  }
}
