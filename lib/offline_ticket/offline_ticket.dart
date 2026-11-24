// An organiser's own sale (an "offline ticket") shown in the customer's My Bookings
// (owner, 24 Nov 2026). It opens the SAME Booking Details screen as any booking, so it
// looks like the rest of the app; only the money actions differ. The customer paid the
// organiser directly, so there is no cancel, refund, ticket download or payment here —
// changes go to the organiser. Rate & review is allowed after the trip. The server
// enforces the same rules.
//
// DESIGN STAGE: the server part is not built yet. `--dart-define=OFFLINE_TICKET_PREVIEW=true`
// adds two sample tickets to My Bookings so the screens can be reviewed on a phone.

import '../freezed_models/booking/booking_history_model.dart';
import '../freezed_models/profile/user_profile_model.dart';

/// `booking_source` the server will send for an organiser's offline ticket.
const String kOfflineTicketSource = 'offline_ticket';

bool isOfflineTicket(BookingHistoryData? b) => b?.bookingSource == kOfflineTicketSource;

/// A review shows on a trek page, so only offline tickets for a trek listed on Aorbo can be
/// rated ("quick" tickets for other trips have no trek). App bookings: always true here.
bool canRateOnAorbo(BookingHistoryData? b) => !isOfflineTicket(b) || b?.trek?.id != null;

/// Design preview only (never on in a store build unless passed at build time).
const bool kOfflineTicketPreview = bool.fromEnvironment('OFFLINE_TICKET_PREVIEW');

// ── Sample data (preview only) ──────────────────────────────────────────────

const String _sampleOrganiser = 'Demo Summit Treks';

TravelersDataModel _t(String name, int age, String gender, {bool primary = false}) =>
    TravelersDataModel(isPrimary: primary, traveler: Traveler(name: name, age: age, gender: gender));

final List<BookingHistoryData> offlineTicketSamples = [
  BookingHistoryData(
    bookingSource: kOfflineTicketSource,
    bookingNumber: 'OB20260012',
    bookingDate: '2026-11-22T10:30:00.000Z',
    status: 'confirmed',
    trekStatus: 'upcoming',
    totalTravelers: 3,
    sourceCityName: 'Bengaluru',
    finalAmount: '17670',
    advanceAmount: '6000',
    remainingAmount: '11670',
    travelers: [
      _t('Abhishek', 25, 'Male', primary: true),
      _t('Kiran', 26, 'Male'),
      _t('Sai', 24, 'Male'),
    ],
    trek: const Trek(
      title: 'Gokarna & Dandeli Weekend Trip',
      duration: '3D 2N',
      durationDays: 3,
      durationNights: 2,
      destinationName: 'Gokarna & Dandeli',
      boardingPoint: 'Majestic Bus Stand, Bengaluru',
      boardingTime: '9:30 PM',
      captainName: 'Ravi Kumar',
      captainPhone: '90000 00001',
      vendor: Vendor(businessName: _sampleOrganiser, phone: '90000 00000'),
      destination: Destination(name: 'Gokarna & Dandeli'),
    ),
    batch: const Batch(tbrId: 'TBR7QK2M4X', startDate: '2026-12-05', endDate: '2026-12-07', startTime: '9:30 PM'),
  ),
  BookingHistoryData(
    bookingSource: kOfflineTicketSource,
    bookingNumber: 'OB20260007',
    bookingDate: '2026-10-28T08:00:00.000Z',
    status: 'completed',
    trekStatus: 'completed',
    ratingGiven: false,
    totalTravelers: 1,
    sourceCityName: 'Bengaluru',
    finalAmount: '4200',
    advanceAmount: '4200',
    remainingAmount: '0',
    travelers: [_t('Abhishek', 25, 'Male', primary: true)],
    trek: const Trek(
      title: 'Kudremukh Peak Trek',
      duration: '2D 1N',
      durationDays: 2,
      durationNights: 1,
      destinationName: 'Kudremukh',
      boardingPoint: 'Silk Board Junction, Bengaluru',
      boardingTime: '10:00 PM',
      captainName: 'Suresh Naik',
      captainPhone: '90000 00002',
      vendor: Vendor(businessName: _sampleOrganiser, phone: '90000 00000'),
      destination: Destination(name: 'Kudremukh'),
    ),
    batch: const Batch(tbrId: 'TBR3HN8W2D', startDate: '2026-11-07', endDate: '2026-11-08', startTime: '10:00 PM'),
  ),
];

/// The sample with this id, in preview builds only.
BookingHistoryData? offlineTicketSampleFor(dynamic id) {
  if (!kOfflineTicketPreview) return null;
  for (final b in offlineTicketSamples) {
    if (b.bookingNumber == '$id') return b;
  }
  return null;
}
