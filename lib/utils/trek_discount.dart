// The vendor-discount rule, the same as the server's utils/trekDiscount.js
// (17 Oct 2026). The search card showed ₹7,890 → ₹7,101 (10% off) but the
// checkout card showed ₹7,890 — it printed the base price and never applied
// the discount, though checkout charges ₹7,101.

/// Price per person after the vendor discount, and the card's "10.00% OFF" label.
class TrekDiscountedPrice {
  const TrekDiscountedPrice({required this.base, required this.off, required this.label});

  final double base;
  final double off;

  /// Same text as the search API's discountText ("10.00% OFF" / "₹500 OFF"), or null.
  final String? label;

  double get price => base - off;
  bool get hasDiscount => off > 0;
}

bool _isOn(Object? v) => v == true || v == 1 || v == '1' || v == 'true';

/// 0 off when the discount is off, the type unknown or the value not positive;
/// never more than the price (server rule TF-02 / TF-10).
TrekDiscountedPrice trekDiscountedPrice({
  required Object? basePrice,
  Object? hasDiscount,
  String? discountType,
  Object? discountValue,
}) {
  final base = double.tryParse('${basePrice ?? ''}'.replaceAll(',', '')) ?? 0;
  final value = double.tryParse('${discountValue ?? ''}') ?? 0;
  if (!_isOn(hasDiscount) || base <= 0 || value <= 0) {
    return TrekDiscountedPrice(base: base, off: 0, label: null);
  }
  double off = 0;
  if (discountType == 'percentage') {
    off = base * value / 100;
  } else if (discountType == 'fixed') {
    off = value;
  }
  if (off <= 0) return TrekDiscountedPrice(base: base, off: 0, label: null);
  if (off > base) off = base;
  final label = discountType == 'percentage' ? '$discountValue% OFF' : '₹$discountValue OFF';
  return TrekDiscountedPrice(base: base, off: off, label: label);
}
