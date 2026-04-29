// ─────────────────────────────────────────────────────────────────────────────
// invoice_model.dart
// AORBO TREKS — Invoice Data Models
// All fields are dynamic / API-driven unless marked [ADMIN-CONFIG]
// ─────────────────────────────────────────────────────────────────────────────

// ── Enums ────────────────────────────────────────────────────────────────────

import '../treaks/treak_detail_modal.dart';

enum InvoiceStatus {
  paid,
  partiallyPaid,
}

enum CancellationPolicyType {
  standard,
  flexible,
}

// Template is derived automatically from policyType + status
enum InvoiceTemplate {
  // Standard policy + full payment paid
  standardFullPaid,
  // Flexible policy + full payment paid
  flexibleFullPaid,
  // Flexible policy + advance payment (partially paid)
  flexibleAdvancePaid,
}

InvoiceTemplate resolveTemplate({
  required CancellationPolicyType? policyType,
  required InvoiceStatus status,
}) {
  if (policyType == CancellationPolicyType.standard) {
    return InvoiceTemplate.standardFullPaid;
  }
  if (status == InvoiceStatus.paid) {
    return InvoiceTemplate.flexibleFullPaid;
  }
  return InvoiceTemplate.flexibleAdvancePaid;
}

// ── Vendor ───────────────────────────────────────────────────────────────────

class VendorInfo {
  /// URL or asset path to vendor's logo image
  final String logoUrl;
  final String companyName;
  final String address;
  final List<String> phones;

  const VendorInfo({
    required this.logoUrl,
    required this.companyName,
    required this.address,
    required this.phones,
  });

  factory VendorInfo.fromJson(Map<String, dynamic> json) => VendorInfo(
        logoUrl: json['logoUrl'] as String,
        companyName: json['companyName'] as String,
        address: json['address'] as String,
        phones: List<String>.from(json['phones'] as List),
      );
}

class AorboInfo {
  /// AORBO TREKS logo — asset path (fixed in app assets)
  final String logoAsset;

  /// Support/contact email — from API
  final String contactEmail;

  const AorboInfo({
    required this.logoAsset,
    required this.contactEmail,
  });

  factory AorboInfo.fromJson(Map<String, dynamic> json) => AorboInfo(
        logoAsset: json['logoAsset'] as String,
        contactEmail: json['contactEmail'] as String,
      );
}

// ── Trek Banner ───────────────────────────────────────────────────────────────

class TrekBanner {
  final String trekName;
  final String trekSubtitle;
  final String bookingId;
  final String tbrId;
  final String departureCity;
  final DateTime departureDateTime;
  final String returnCity;
  final DateTime returnDateTime;

  /// e.g. "3D/2N"
  final String duration;

  const TrekBanner({
    required this.trekName,
    required this.trekSubtitle,
    required this.bookingId,
    required this.tbrId,
    required this.departureCity,
    required this.departureDateTime,
    required this.returnCity,
    required this.returnDateTime,
    required this.duration,
  });

  factory TrekBanner.fromJson(Map<String, dynamic> json) => TrekBanner(
        trekName: json['trekName'] as String,
        trekSubtitle: json['trekSubtitle'] as String,
        bookingId: json['bookingId'] as String,
        tbrId: json['tbrId'] as String,
        departureCity: json['departureCity'] as String,
        departureDateTime: DateTime.parse(json['departureDateTime'] as String),
        returnCity: json['returnCity'] as String,
        returnDateTime: DateTime.parse(json['returnDateTime'] as String),
        duration: json['duration'] as String,
      );
}

// ── Trek Details ──────────────────────────────────────────────────────────────

class TrekDetails {
  final String trekName;
  final String trekOperator;
  final String boardingPoint;
  final String trekCaptain;
  final String captainContact;

  const TrekDetails({
    required this.trekName,
    required this.trekOperator,
    required this.boardingPoint,
    required this.trekCaptain,
    required this.captainContact,
  });

  factory TrekDetails.fromJson(Map<String, dynamic> json) => TrekDetails(
        trekName: json['trekName'] as String,
        trekOperator: json['trekOperator'] as String,
        boardingPoint: json['boardingPoint'] as String,
        trekCaptain: json['trekCaptain'] as String,
        captainContact: json['captainContact'] as String,
      );
}

// ── Traveller ─────────────────────────────────────────────────────────────────

class TravellerInfo {
  final String name;
  final int age;
  final String gender;

  const TravellerInfo({
    required this.name,
    required this.age,
    required this.gender,
  });

  factory TravellerInfo.fromJson(Map<String, dynamic> json) => TravellerInfo(
        name: json['name'] as String,
        age: json['age'] as int,
        gender: json['gender'] as String,
      );
}

// ── Add-ons (Standard policy only) ───────────────────────────────────────────

class FreeCancellationAddon {
  final double amount;
  final String policyId;

  const FreeCancellationAddon({
    required this.amount,
    required this.policyId,
  });

  factory FreeCancellationAddon.fromJson(Map<String, dynamic> json) =>
      FreeCancellationAddon(
        amount: (json['amount'] as num).toDouble(),
        policyId: json['policyId'] as String,
      );
}

class TravelInsuranceAddon {
  final double amount;
  final String policyId;

  const TravelInsuranceAddon({
    required this.amount,
    required this.policyId,
  });

  factory TravelInsuranceAddon.fromJson(Map<String, dynamic> json) =>
      TravelInsuranceAddon(
        amount: (json['amount'] as num).toDouble(),
        policyId: json['policyId'] as String,
      );
}

// ── Payment Details ───────────────────────────────────────────────────────────

class PaymentDetails {
  // ── Mandatory (all templates)
  final double baseFare;
  final double finalBaseFare;

  /// GST rate e.g. 0.05 for 5%  — [ADMIN-CONFIG via API]
  final double gstRate;
  final double gstAmount;

  /// Platform fee fixed amount — [ADMIN-CONFIG via API]
  final double platformFee;

  final double totalAmount;
  final InvoiceStatus status;

  // ── Optional
  final double? couponDiscount;

  // ── Standard policy only
  final FreeCancellationAddon? freeCancellation;
  final TravelInsuranceAddon? travelInsurance;

  // ── Flexible advance only
  /// Trek Advance amount (advanceBase + GST + PF) — [ADMIN-CONFIG: advanceBase via API]
  final double? trekAdvanceAmount;
  final double? balanceDue;

  const PaymentDetails({
    required this.baseFare,
    required this.finalBaseFare,
    required this.gstRate,
    required this.gstAmount,
    required this.platformFee,
    required this.totalAmount,
    required this.status,
    this.couponDiscount,
    this.freeCancellation,
    this.travelInsurance,
    this.trekAdvanceAmount,
    this.balanceDue,
  });

  factory PaymentDetails.fromJson(Map<String, dynamic> json) => PaymentDetails(
        baseFare: (json['baseFare'] as num).toDouble(),
        finalBaseFare: (json['finalBaseFare'] as num).toDouble(),
        gstRate: (json['gstRate'] as num).toDouble(),
        gstAmount: (json['gstAmount'] as num).toDouble(),
        platformFee: (json['platformFee'] as num).toDouble(),
        totalAmount: (json['totalAmount'] as num).toDouble(),
        status: InvoiceStatus.values.firstWhere(
          (e) => e.name == json['status'],
        ),
        couponDiscount: json['couponDiscount'] != null
            ? (json['couponDiscount'] as num).toDouble()
            : null,
        freeCancellation: json['freeCancellation'] != null
            ? FreeCancellationAddon.fromJson(
                json['freeCancellation'] as Map<String, dynamic>)
            : null,
        travelInsurance: json['travelInsurance'] != null
            ? TravelInsuranceAddon.fromJson(
                json['travelInsurance'] as Map<String, dynamic>)
            : null,
        trekAdvanceAmount: json['trekAdvanceAmount'] != null
            ? (json['trekAdvanceAmount'] as num).toDouble()
            : null,
        balanceDue: json['balanceDue'] != null
            ? (json['balanceDue'] as num).toDouble()
            : null,
      );
}

// ── Cancellation Policy ───────────────────────────────────────────────────────


// ── Disclaimer ────────────────────────────────────────────────────────────────

class DisclaimerSection {
  final String title;
  final String? paragraph;
  final List<String>? bullets;

  const DisclaimerSection({
    required this.title,
    this.paragraph,
    this.bullets,
  });

  factory DisclaimerSection.fromJson(Map<String, dynamic> json) =>
      DisclaimerSection(
        title: json['title'] as String,
        paragraph:
            json['paragraph'] != null ? json['paragraph'] as String : null,
        bullets: json['bullets'] != null
            ? List<String>.from(json['bullets'] as List)
            : null,
      );
}

class DisclaimerData {
  final List<DisclaimerSection> sections;
  final String closingStatement;

  const DisclaimerData({
    required this.sections,
    required this.closingStatement,
  });

  factory DisclaimerData.fromJson(Map<String, dynamic> json) => DisclaimerData(
        sections: (json['sections'] as List)
            .map((s) =>
                DisclaimerSection.fromJson(s as Map<String, dynamic>))
            .toList(),
        closingStatement: json['closingStatement'] as String,
      );
}

// ── Root Invoice Model ────────────────────────────────────────────────────────

class InvoiceModel {
  final DateTime bookingDate;
  final VendorInfo vendor;
  final AorboInfo aorbo;
  final TrekBanner banner;
  final TrekDetails trekDetails;
  final List<TravellerInfo> travellers;
  final PaymentDetails payment;
  final CancellationPolicy? cancellationPolicy;
  final String serviceStartTime;
  final DisclaimerData disclaimer;

  /// Derived — no need to pass manually
  InvoiceTemplate get template => resolveTemplate(
        policyType: cancellationPolicy?.type == "standard" ? CancellationPolicyType.standard : CancellationPolicyType.flexible ,
        status: payment.status,
      );

  const InvoiceModel({
    required this.bookingDate,
    required this.vendor,
    required this.aorbo,
    required this.banner,
    required this.trekDetails,
    required this.travellers,
    required this.payment,
    required this.cancellationPolicy,
    required this.serviceStartTime,
    required this.disclaimer,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) => InvoiceModel(
        bookingDate: DateTime.parse(json['bookingDate'] as String),
        vendor:
            VendorInfo.fromJson(json['vendor'] as Map<String, dynamic>),
        aorbo: AorboInfo.fromJson(json['aorbo'] as Map<String, dynamic>),
        banner:
            TrekBanner.fromJson(json['banner'] as Map<String, dynamic>),
        trekDetails:
            TrekDetails.fromJson(json['trekDetails'] as Map<String, dynamic>),
        travellers: (json['travellers'] as List)
            .map((t) =>
                TravellerInfo.fromJson(t as Map<String, dynamic>))
            .toList(),
        payment:
            PaymentDetails.fromJson(json['payment'] as Map<String, dynamic>),
        cancellationPolicy: CancellationPolicy.fromJson(
            json['cancellationPolicy'] as Map<String, dynamic>),
        serviceStartTime: json['serviceStartTime'] as String,
        disclaimer:
            DisclaimerData.fromJson(json['disclaimer'] as Map<String, dynamic>),
      );
}
