// ─────────────────────────────────────────────────────────────────────────────
// invoice_widget.dart
// AORBO TREKS — Master Invoice Widget
// Single widget renders all 3 invoice templates dynamically
// Pass InvoiceModel → template is auto-resolved from policy type + status
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/invoice/invoice_model.dart';
import 'payment_details_widget.dart';
import 'cancellation_policy_widget.dart';
import 'disclaimer_widget.dart';

// ── Color constants (matching brand palette) ──────────────────────────────────
const _kBannerBg = Color(0xFFFFF9EC);
const _kBannerBorder = Color(0xFFE8D9A0);
const _kSectionIconColor = Color(0xFF378ADD);
const _kDividerColor = Color(0xFFD3D1C7);
const _kMutedText = Color(0xFF888780);
const _kSlotsColor = Color(0xFFBA7517);
const _kBorderColor = Color(0xFFD3D1C7);
const _kHeaderBg = Color(0xFFF1EFE8);

// ─────────────────────────────────────────────────────────────────────────────
// ROOT INVOICE WIDGET
// ─────────────────────────────────────────────────────────────────────────────

class InvoiceWidget extends StatelessWidget {
  final InvoiceModel invoice;

  /// Optional: wrap in a scrollable page. Default: true.
  final bool scrollable;

  const InvoiceWidget({
    super.key,
    required this.invoice,
    this.scrollable = true,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InvoiceCard(invoice: invoice),
        const SizedBox(height: 24),
        _DisclaimerCard(disclaimer: invoice.disclaimer),
      ],
    );

    if (scrollable) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: content,
      );
    }
    return Padding(
      padding: const EdgeInsets.all(16),
      child: content,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// INVOICE CARD
// ─────────────────────────────────────────────────────────────────────────────

class _InvoiceCard extends StatelessWidget {
  final InvoiceModel invoice;

  const _InvoiceCard({required this.invoice});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _kBorderColor, width: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header — booking date + status
          _HeaderRow(invoice: invoice),
          _divider(),

          // 2. Vendor block
          _VendorBlock(invoice: invoice),
          _divider(),

          // 3. Trek banner
          _TrekBannerWidget(banner: invoice.banner),
          _divider(),

          // 4. Trek details + Traveller details (two columns)
          _DetailsRow(
            trekDetails: invoice.trekDetails,
            travellers: invoice.travellers,
          ),
          _divider(),

          // 5. Payment details
          Padding(
            padding: const EdgeInsets.all(16),
            child: PaymentDetailsWidget(
              payment: invoice.payment,
              template: invoice.template,
            ),
          ),
          _divider(),

          // 6. Cancellation policy
          Padding(
            padding: const EdgeInsets.all(16),
            child: CancellationPolicyWidget(
              policy: invoice.cancellationPolicy,
              departureDate: "",
              basePrice: invoice.payment.totalAmount.toString(),
            ),
          ),
          _divider(),

          // 7. Service start time
          _ServiceStartTime(time: invoice.serviceStartTime),
        ],
      ),
    );
  }

  Widget _divider() =>
      const Divider(height: 1, thickness: 0.5, color: _kDividerColor);
}

// ─────────────────────────────────────────────────────────────────────────────
// HEADER ROW — Booking date + status
// ─────────────────────────────────────────────────────────────────────────────

class _HeaderRow extends StatelessWidget {
  final InvoiceModel invoice;

  const _HeaderRow({required this.invoice});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd/MM/yyyy hh:mm a').format(invoice.bookingDate);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 12, color: Colors.black87),
              children: [
                const TextSpan(
                  text: 'Date of Booking : ',
                  style: TextStyle(
                    color: _kSectionIconColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(text: dateStr),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// VENDOR BLOCK — Vendor logo | Company info | AORBO logo
// ─────────────────────────────────────────────────────────────────────────────

class _VendorBlock extends StatelessWidget {
  final InvoiceModel invoice;

  const _VendorBlock({required this.invoice});

  @override
  Widget build(BuildContext context) {
    final vendor = invoice.vendor;
    final aorbo = invoice.aorbo;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Vendor logo
          _LogoBox(imageUrl: vendor.logoUrl),
          const SizedBox(width: 12),

          // Vendor details (center)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  vendor.companyName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  vendor.address,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11, color: _kMutedText),
                ),
                const SizedBox(height: 3),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.phone, size: 11, color: _kMutedText),
                    const SizedBox(width: 3),
                    Text(
                      vendor.phones.join(' , '),
                      style: const TextStyle(
                          fontSize: 11, color: _kMutedText),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.mail_outline, size: 11, color: _kMutedText),
                    const SizedBox(width: 3),
                    Text(
                      aorbo.contactEmail,
                      style: const TextStyle(
                          fontSize: 11, color: _kMutedText),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // AORBO logo
          _LogoBox(assetPath: aorbo.logoAsset),
        ],
      ),
    );
  }
}

class _LogoBox extends StatelessWidget {
  final String? imageUrl;
  final String? assetPath;

  const _LogoBox({this.imageUrl, this.assetPath});

  @override
  Widget build(BuildContext context) {
    Widget image;

    if (assetPath != null) {
      image = Image.asset(
        assetPath!,
        width: 64,
        height: 40,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    } else if (imageUrl != null) {
      image = Image.network(
        imageUrl!,
        width: 64,
        height: 40,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    } else {
      image = _placeholder();
    }

    return Container(
      width: 64,
      height: 40,
      decoration: BoxDecoration(
        border: Border.all(color: _kBorderColor, width: 0.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: image,
      ),
    );
  }

  Widget _placeholder() => Container(
        color: const Color(0xFFF1EFE8),
        child: const Center(
          child: Icon(Icons.image_outlined, size: 20, color: _kMutedText),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// TREK BANNER — Yellow/cream background strip
// ─────────────────────────────────────────────────────────────────────────────

class _TrekBannerWidget extends StatelessWidget {
  final TrekBanner banner;

  const _TrekBannerWidget({required this.banner});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _kBannerBg,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trek name + IDs row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      banner.trekName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      banner.trekSubtitle,
                      style: const TextStyle(
                          fontSize: 12, color: _kMutedText),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _IdRow(label: 'Booking ID', value: banner.bookingId),
                  const SizedBox(height: 2),
                  _IdRow(label: 'TBR ID', value: banner.tbrId),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Departure — Duration — Return
          Row(
            children: [
              // Departure
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDateTime(banner.departureDateTime),
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      banner.departureCity,
                      style: const TextStyle(
                          fontSize: 11, color: _kMutedText),
                    ),
                  ],
                ),
              ),

              // Duration badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: _kBannerBorder, width: 0.5),
                  borderRadius: BorderRadius.circular(6),
                  color: Colors.white.withValues(alpha: 0.6),
                ),
                child: Text(
                  banner.duration,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              // Return
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatDateTime(banner.returnDateTime),
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      banner.returnCity,
                      style: const TextStyle(
                          fontSize: 11, color: _kMutedText),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return DateFormat('EEE, d MMM hh:mm a').format(dt);
  }
}

class _IdRow extends StatelessWidget {
  final String label;
  final String value;

  const _IdRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$label : ',
          style: const TextStyle(fontSize: 11, color: _kMutedText),
        ),
        Text(
          value,
          style: const TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DETAILS ROW — Trek details (left) + Traveller details (right)
// ─────────────────────────────────────────────────────────────────────────────

class _DetailsRow extends StatelessWidget {
  final TrekDetails trekDetails;
  final List<TravellerInfo> travellers;

  const _DetailsRow({
    required this.trekDetails,
    required this.travellers,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trek Details
          Expanded(
            child: _TrekDetailsSection(details: trekDetails),
          ),
          const SizedBox(width: 16),

          // Traveller Details
          Expanded(
            child: _TravellerDetailsSection(travellers: travellers),
          ),
        ],
      ),
    );
  }
}

class _TrekDetailsSection extends StatelessWidget {
  final TrekDetails details;

  const _TrekDetailsSection({required this.details});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(Icons.terrain_outlined, 'TREK DETAILS'),
        const SizedBox(height: 10),
        _detailRow('Trek Name', details.trekName),
        _detailRow('Trek Operator', details.trekOperator),
        _detailRow('Boarding Point', details.boardingPoint),
        _detailRow('Trek Captain', details.trekCaptain),
        _detailRow('Captain Contact', details.captainContact),
      ],
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontSize: 11, color: _kMutedText),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _TravellerDetailsSection extends StatelessWidget {
  final List<TravellerInfo> travellers;

  const _TravellerDetailsSection({required this.travellers});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(Icons.people_outline, 'TRAVELLER DETAILS'),
        const SizedBox(height: 10),

        // Table header
        Row(
          children: const [
            Expanded(
                flex: 5,
                child: Text('Name',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _kMutedText))),
            Expanded(
                flex: 2,
                child: Text('Age',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _kMutedText))),
            Expanded(
                flex: 3,
                child: Text('Gender',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _kMutedText))),
          ],
        ),
        const SizedBox(height: 4),
        const Divider(height: 1, thickness: 0.5, color: _kDividerColor),
        const SizedBox(height: 4),

        // Traveller rows — dynamic
        ...travellers.map((t) => _travellerRow(t)),

        const SizedBox(height: 6),

        // Total slots
        RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 12),
            children: [
              const TextSpan(
                text: 'Total NO of Slots : ',
                style: TextStyle(color: Colors.black87),
              ),
              TextSpan(
                text: travellers.length.toString().padLeft(2, '0'),
                style: const TextStyle(
                  color: _kSlotsColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _travellerRow(TravellerInfo t) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Text(t.name,
                style: const TextStyle(fontSize: 11)),
          ),
          Expanded(
            flex: 2,
            child: Text(t.age.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11)),
          ),
          Expanded(
            flex: 3,
            child: Text(t.gender,
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }
}

// ── Shared section title builder ──────────────────────────────────────────────

Widget _sectionTitle(IconData icon, String title) {
  return Row(
    children: [
      Icon(icon, size: 15, color: _kSectionIconColor),
      const SizedBox(width: 5),
      Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    ],
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// SERVICE START TIME
// ─────────────────────────────────────────────────────────────────────────────

class _ServiceStartTime extends StatelessWidget {
  final String time;

  const _ServiceStartTime({required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _kHeaderBg,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        'Service start time: $time',
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DISCLAIMER CARD
// ─────────────────────────────────────────────────────────────────────────────

class _DisclaimerCard extends StatelessWidget {
  final DisclaimerData disclaimer;

  const _DisclaimerCard({required this.disclaimer});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _kBorderColor, width: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(16),
      child: DisclaimerWidget(disclaimer: disclaimer),
    );
  }
}
