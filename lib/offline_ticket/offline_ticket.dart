// An organiser's own sale (an "offline ticket") shown in the customer's My Bookings
// (owner, 24 Nov 2026). The customer paid the organiser directly, so the app is
// VIEW-ONLY for money: no cancel, refund or payment here — changes go to the organiser.
// Rate & review is allowed after the trip. The server enforces the same rules.
//
// DESIGN STAGE: the server part is not built yet. `--dart-define=OFFLINE_TICKET_PREVIEW=true`
// adds two sample tickets to My Bookings so the screens can be reviewed on a phone.

import '../freezed_models/booking/booking_history_model.dart';

/// `booking_source` the server will send for an organiser's offline ticket.
const String kOfflineTicketSource = 'offline_ticket';

bool isOfflineTicket(BookingHistoryData b) => b.bookingSource == kOfflineTicketSource;

/// Design preview only (never on in a store build unless passed at build time).
const bool kOfflineTicketPreview = bool.fromEnvironment('OFFLINE_TICKET_PREVIEW');

/// What the ticket screen shows beyond the list card.
class OfflineTicketDetails {
  const OfflineTicketDetails({
    required this.ticketNumber,
    required this.organiserName,
    required this.organiserPhone,
    required this.pickupPoint,
    required this.pickupTime,
    required this.captainName,
    required this.captainPhone,
    required this.travellers,
    required this.total,
    required this.paid,
  });

  final String ticketNumber;
  final String organiserName;
  final String organiserPhone;
  final String pickupPoint;
  final String pickupTime;
  final String captainName;
  final String captainPhone;
  final List<String> travellers;
  final double total;
  final double paid;

  double get due => (total - paid) < 0 ? 0 : total - paid;
}

// ── Sample data (preview only) ──────────────────────────────────────────────

const String _sampleOrganiser = 'Demo Summit Treks';

final List<BookingHistoryData> offlineTicketSamples = [
  BookingHistoryData(
    id: -9001,
    bookingSource: kOfflineTicketSource,
    bookingNumber: 'DS/26-27/0012',
    bookingDate: '2026-11-22T10:30:00.000Z',
    trekStatus: 'upcoming',
    totalTravelers: 3,
    trek: const Trek(
      title: 'Gokarna & Dandeli Weekend Trip',
      durationDays: 3,
      durationNights: 2,
      vendor: Vendor(businessName: _sampleOrganiser),
      destination: Destination(name: 'Gokarna & Dandeli'),
    ),
    batch: const Batch(startDate: '2026-12-05', startTime: '9:30 PM'),
  ),
  BookingHistoryData(
    id: -9002,
    bookingSource: kOfflineTicketSource,
    bookingNumber: 'DS/26-27/0007',
    bookingDate: '2026-10-28T08:00:00.000Z',
    trekStatus: 'completed',
    ratingGiven: false,
    totalTravelers: 1,
    trek: const Trek(
      title: 'Kudremukh Peak Trek',
      durationDays: 2,
      durationNights: 1,
      vendor: Vendor(businessName: _sampleOrganiser),
      destination: Destination(name: 'Kudremukh'),
    ),
    batch: const Batch(startDate: '2026-11-07', startTime: '10:00 PM'),
  ),
];

const Map<int, OfflineTicketDetails> _sampleDetails = {
  -9001: OfflineTicketDetails(
    ticketNumber: 'DS/26-27/0012',
    organiserName: _sampleOrganiser,
    organiserPhone: '90000 00000',
    pickupPoint: 'Majestic Bus Stand, Bengaluru',
    pickupTime: 'Fri 5 Dec · 9:30 PM',
    captainName: 'Ravi Kumar',
    captainPhone: '90000 00001',
    travellers: ['Abhishek', 'Kiran', 'Sai'],
    total: 17670,
    paid: 6000,
  ),
  -9002: OfflineTicketDetails(
    ticketNumber: 'DS/26-27/0007',
    organiserName: _sampleOrganiser,
    organiserPhone: '90000 00000',
    pickupPoint: 'Silk Board Junction, Bengaluru',
    pickupTime: 'Fri 7 Nov · 10:00 PM',
    captainName: 'Suresh Naik',
    captainPhone: '90000 00002',
    travellers: ['Abhishek'],
    total: 4200,
    paid: 4200,
  ),
};

OfflineTicketDetails? offlineTicketDetailsFor(BookingHistoryData b) =>
    b.id == null ? null : _sampleDetails[b.id!];
