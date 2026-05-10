class Coupon {
  final String code;
  final String discount;
  final String description;
  final String sideText;
  final bool isValid;
  final String? validUntil;
  final List<String>? terms;

  const Coupon({
    required this.code,
    required this.discount,
    required this.description,
    required this.sideText,
    this.isValid = true,
    this.validUntil,
    this.terms,
  });
}

// List of available coupons
class CouponData {
  static const List<Coupon> coupons = [
    Coupon(
      code: "TREK100",
      discount: "Get Flat ₹100 off",
      description:
          "Start your trekking journey with a special discount on your first booking!",
      sideText: "Flat 100/- off",
      terms: [
        "Valid on first booking only",
        "Cannot be combined with other offers",
        "Valid until December 31, 2024",
      ],
    ),
    Coupon(
      code: "EXPLORE50",
      discount: "Save 50% (Up to ₹500)!",
      description:
          "Limited-time offer to fuel your adventure spirit—grab it before it's gone!",
      sideText: "upto 50% off",
      terms: [
        "Maximum discount of ₹500",
        "Valid for limited time only",
        "Cannot be combined with other offers",
      ],
    ),
    Coupon(
      code: "ADVENTURE250",
      discount: "Get Flat ₹250 Off on Premium Treks!",
      description:
          "Explore breathtaking destinations when you book a trek above ₹5,000",
      sideText: "Flat 100/- off",
      terms: [
        "Minimum booking amount ₹5,000",
        "Valid on premium treks only",
        "Subject to availability",
      ],
    ),
    Coupon(
      code: "WEEKENDTREK",
      discount: "Get Flat ₹150 Off Weekend Adventures!",
      description: "Make your weekends exciting plan a trek and save ₹150!",
      sideText: "Flat 150/- off",
      terms: [
        "Valid only on weekend treks",
        "Booking must be made 48 hours in advance",
        "Subject to availability",
      ],
    ),
  ];
}
