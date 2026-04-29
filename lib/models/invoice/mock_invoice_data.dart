// ─────────────────────────────────────────────────────────────────────────────
// mock_invoice_data.dart
// AORBO TREKS — Disposable Mock Data
// ⚠️  REMOVE THIS FILE after API integration is complete
// ─────────────────────────────────────────────────────────────────────────────


import 'package:arobo_app/models/treaks/treak_detail_modal.dart';

import 'invoice_model.dart';

// ── Shared sub-objects ────────────────────────────────────────────────────────

const _mockVendor = VendorInfo(
  logoUrl: 'https://via.placeholder.com/80x40?text=VENDOR',
  companyName: 'Trekking Freaks Private Ltd',
  address: 'R NO: 12, Afjalgung, MGBS, Hyderabad – 523456, Telangana, India',
  phones: ['9999999999', '99999999999'],
);

const _mockAorbo = AorboInfo(
  logoAsset: 'assets/images/aorbo_logo.png',
  contactEmail: 'support@aorbotreks.com',
);

final _mockBanner = TrekBanner(
  trekName: 'Gokarna & Dandeli',
  trekSubtitle: 'A round-trip trek covering',
  bookingId: 'AOB123456789',
  tbrId: 'TBR987654321',
  departureCity: 'Hyderabad',
  departureDateTime: DateTime.now(),
  returnCity: 'Hyderabad',
  returnDateTime: DateTime.now(),
  duration: '3D/2N',
);

// DateTime consts can't be const in Dart — use static final in a class
// So we expose mocks as static getters below.

const _mockTrekDetails = TrekDetails(
  trekName: 'Gokarna & Dandeli',
  trekOperator: 'Trekking Freaks Pvt Ltd',
  boardingPoint: 'Nampally Railway Station',
  trekCaptain: 'Avinash',
  captainContact: '79956XXXXXX, 79956XXXXXX',
);

const _mockTravellers = [
  TravellerInfo(name: 'Naga Praveen P', age: 24, gender: 'Male'),
  TravellerInfo(name: 'Renuka', age: 22, gender: 'Female'),
  TravellerInfo(name: 'Nikhil P', age: 26, gender: 'Male'),
  TravellerInfo(name: 'Kranthi Kumar Y', age: 28, gender: 'Male'),
  TravellerInfo(name: 'Abdhur', age: 21, gender: 'Male'),
];

const _mockDisclaimerSection = DisclaimerData(
  sections: [
    DisclaimerSection(
      title: 'Mandatory User Requirement',
      paragraph:
          'Users must carry a valid government-issued photo ID. Vendors may request verification at any time. Refusal or fraud may result in denial of participation without refund.',
    ),
    DisclaimerSection(
      title: 'What We Are Responsible For',
      bullets: [
        'Providing a platform to connect users with verified trek organizers (Vendors).',
        'Conducting basic vendor verification before listing.',
        'Offering a secure system for booking and payment.',
        'First-level customer support and limited emergency coordination (where applicable)',
      ],
    ),
    DisclaimerSection(
      title: 'What We Are Not Responsible For',
      bullets: [
        'Vendor actions, misconduct, or service quality during treks.',
        'Cancellations, delays, or changes by vendors due to weather, low bookings, or emergencies.',
        'Injury, health issues, or property loss during treks. Users\' personal fitness or health conditions.',
        'Any disputes or refund claims between users and vendors.',
        'External services like transport, accommodation, or insurance.',
      ],
    ),
    DisclaimerSection(
      title: 'Indemnity',
      paragraph:
          'Users agree to indemnify Aorbo Treks against any claims, damages, or disputes arising from their actions, use of the platform, or engagement with vendors.',
    ),
    DisclaimerSection(
      title: 'Governing Law',
      paragraph:
          'All matters are governed by Indian law and subject to courts in Hyderabad, Telangana.',
    ),
  ],
  closingStatement:
      'By proceeding, users confirm acceptance of this disclaimer and its terms.',
);

// ── Standard cancellation policy mock ────────────────────────────────────────

final _mockStandardPolicy = CancellationPolicy(
  type: "standard",
  title: 'Cancellation Policy (Standard)',
  rules:  [
    Rules(
      rule: 'Cancelled before Thu, 19 Dec 12:00 PM',
      deduction: '20% (₹1,200)',
    ),
    Rules(
      rule: 'From Thu, 19 Dec 12:00 PM to Sat, 21 Dec 11:59 AM',
      deduction: '50% (₹3,000)',
    ),
    Rules(
      rule: 'From Sat, 21 Dec 12:00 PM to Sun, 22 Dec 11:00 AM',
      deduction: '70% (₹4,199)',
    ),
    Rules(
      rule: 'No refund after Sun, 22 Dec 11:00 AM',
      deduction: '100% (₹5,999)',
    ),
  ],
  descriptionPoints: const [
    'Cancellation fees are applied on a per-slot basis. The cancellation charge mentioned above is calculated based on a seat fare of ₹5,999.',
    'Cancellation charges are determined based on the service start date and time: 22-12-2024 at 10:00.',
    'Tickets cannot be cancelled after the scheduled departure time of the trek from the boarding point.',
    'For group bookings, individual slots may be cancelled.',
  ],
);

// ── Flexible cancellation policy mock ────────────────────────────────────────

final _mockFlexiblePolicy = CancellationPolicy(
  type: "flexible",
  title: 'Flexible Policy',
  rules: [
    Rules(
      rule: 'Advance Payment (₹999)',
      deduction: 'Non-refundable',
    ),
    Rules(
      rule: 'Full Payment Made',
      deduction: '₹999 hold, refund processed',
    ),
    Rules(
      rule: 'Cancellation Notice',
      deduction: '1 day(s) before trek',
    ),
    Rules(
      rule: 'Within 24 hours of departure',
      deduction: '100% (₹4,735)',
    ),
  ],
  descriptionPoints: [
    'GST and taxes are non-refundable. The advance secures your slot and is non-refundable upon cancellation.',
    'The remaining balance will be refunded within 5 to 7 working days, subject to cancellation terms.',
    'Cancellations within 1 day of departure are at the vendor\'s discretion, and Aorbo Treks is not liable.',
    'For group bookings, individual slots may be cancelled.',
    'The cancellation policy will be solely determined and approved by the respective vendor.',
  ],
);

// ─────────────────────────────────────────────────────────────────────────────
// MOCK INVOICE 1 — Standard Policy / Full Payment / PAID
// ─────────────────────────────────────────────────────────────────────────────

class MockInvoiceData {
  MockInvoiceData._();

  /// Template 1 — Standard Policy, Full Payment, Paid
  static InvoiceModel get standardFullPaid => InvoiceModel(
        bookingDate: DateTime(2025, 7, 21, 14, 44),
        vendor: _mockVendor,
        aorbo: _mockAorbo,
        banner: TrekBanner(
          trekName: 'Gokarna & Dandeli',
          trekSubtitle: 'A round-trip trek covering',
          bookingId: 'AOB123456789',
          tbrId: 'TBR987654321',
          departureCity: 'Hyderabad',
          departureDateTime: DateTime(2024, 12, 22, 15, 50),
          returnCity: 'Hyderabad',
          returnDateTime: DateTime(2024, 12, 25, 17, 45),
          duration: '3D/2N',
        ),
        trekDetails: _mockTrekDetails,
        travellers: _mockTravellers,
        payment: const PaymentDetails(
          baseFare: 6000,
          couponDiscount: 500,
          finalBaseFare: 5500,
          gstRate: 0.05,
          gstAmount: 275,
          platformFee: 10,
          totalAmount: 5984,
          status: InvoiceStatus.paid,
          freeCancellation: FreeCancellationAddon(
            amount: 199,
            policyId: 'FC-20241222-001',
          ),
          travelInsurance: TravelInsuranceAddon(
            amount: 200,
            policyId: 'TI-20241222-001',
          ),
        ),
        cancellationPolicy: _mockStandardPolicy,
        serviceStartTime: '10:00',
        disclaimer: _mockDisclaimerSection,
      );

  /// Template 2 — Flexible Policy, Full Payment, Paid
  static InvoiceModel get flexibleFullPaid => InvoiceModel(
        bookingDate: DateTime(2025, 7, 21, 14, 44),
        vendor: _mockVendor,
        aorbo: _mockAorbo,
        banner: TrekBanner(
          trekName: 'Gokarna & Dandeli',
          trekSubtitle: 'A round-trip trek covering',
          bookingId: 'AOB123456790',
          tbrId: 'TBR987654322',
          departureCity: 'Hyderabad',
          departureDateTime: DateTime(2024, 12, 22, 15, 50),
          returnCity: 'Hyderabad',
          returnDateTime: DateTime(2024, 12, 25, 17, 45),
          duration: '3D/2N',
        ),
        trekDetails: _mockTrekDetails,
        travellers: _mockTravellers,
        payment: const PaymentDetails(
          baseFare: 5000,
          couponDiscount: 500,
          finalBaseFare: 4500,
          gstRate: 0.05,
          gstAmount: 225,
          platformFee: 10,
          totalAmount: 4735,
          status: InvoiceStatus.paid,
        ),
        cancellationPolicy: _mockFlexiblePolicy,
        serviceStartTime: '10:00',
        disclaimer: _mockDisclaimerSection,
      );

  /// Template 3 — Flexible Policy, Advance Payment, Partially Paid
  static InvoiceModel get flexibleAdvancePaid => InvoiceModel(
        bookingDate: DateTime(2025, 7, 21, 14, 44),
        vendor: _mockVendor,
        aorbo: _mockAorbo,
        banner: TrekBanner(
          trekName: 'Gokarna & Dandeli',
          trekSubtitle: 'A round-trip trek covering',
          bookingId: 'AOB123456791',
          tbrId: 'TBR987654323',
          departureCity: 'Hyderabad',
          departureDateTime: DateTime(2024, 12, 22, 15, 50),
          returnCity: 'Hyderabad',
          returnDateTime: DateTime(2024, 12, 25, 17, 45),
          duration: '3D/2N',
        ),
        trekDetails: _mockTrekDetails,
        travellers: _mockTravellers,
        payment: const PaymentDetails(
          baseFare: 5000,
          couponDiscount: 500,
          finalBaseFare: 4500,
          gstRate: 0.05,
          gstAmount: 225,
          platformFee: 10,
          totalAmount: 4735,
          status: InvoiceStatus.partiallyPaid,
          // Trek Advance = ₹999 (admin-config) + GST + PF
          trekAdvanceAmount: 1234,
          balanceDue: 3501,
        ),
        cancellationPolicy: _mockFlexiblePolicy,
        serviceStartTime: '10:00',
        disclaimer: _mockDisclaimerSection,
      );
}
