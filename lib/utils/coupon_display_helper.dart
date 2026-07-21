import '../models/coupon_code/coupon_code_model.dart';
import 'auth_utils.dart';

/// Composes the display-ready strings CouponGradientCard expects (headline,
/// condition line, badge) from the raw fields the backend actually stores
/// (discount_type/discount_value/min_amount/max_discount_amount) — the
/// backend has no pre-composed "FLAT ₹200 OFF" string, only the numbers.
class CouponDisplayHelper {
  static String headline(CouponCardData coupon) {
    final value = double.tryParse(coupon.discountValue ?? '') ?? 0;
    if (coupon.discountType == 'fixed') {
      return 'FLAT ${AuthUtils.formatPrice(coupon.discountValue ?? '0')} OFF';
    }
    final trimmed = value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toString();
    return '$trimmed% OFF';
  }

  static String conditionText(CouponCardData coupon) {
    final parts = <String>[];

    final maxDiscount = double.tryParse(coupon.maxDiscountAmount ?? '') ?? 0;
    if (coupon.discountType != 'fixed' && maxDiscount > 0) {
      parts.add('Upto ${AuthUtils.formatPrice(coupon.maxDiscountAmount!)}');
    }

    final minAmount = double.tryParse(coupon.minAmount ?? '') ?? 0;
    if (minAmount > 0) {
      parts.add('On orders above ${AuthUtils.formatPrice(coupon.minAmount!)}');
    }

    if (parts.isEmpty) return 'T&C apply';
    return '${parts.join(' · ')} · T&C apply';
  }

  static String? badgeLabel(CouponCardData coupon) {
    final fromBackend = coupon.styling?.badge;
    if (fromBackend != null && fromBackend.trim().isNotEmpty) {
      return fromBackend;
    }
    switch (coupon.discountType) {
      case 'early_bird':
        return 'Early Bird';
      case 'seasonal':
        return 'Seasonal';
      case 'group':
        return 'Group Discount';
      case 'conditional':
        return 'Special Offer';
      case 'fixed':
        return 'Flat Discount';
      default:
        return null;
    }
  }
}
