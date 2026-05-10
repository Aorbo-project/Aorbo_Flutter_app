# Fare Calculation Implementation

## Overview

The fare calculation has been updated to follow a new formula that includes base fare, vendor discount, coupon discount, platform fee, and GST calculation.

## Formula Implementation

### 1. Base Fare (BF)

- **Formula**: Price set by vendor × Number of travellers
- **Implementation**: `double totalBaseFare = baseFare * _adultCount;`
- **Source**: `travelData.basePrice`

### 2. Vendor Discount (VD)

- **Formula**: % or flat discount defined at trek creation
- **Implementation**:
  - **Percentage**: `totalBaseFare × (discountPercentage / 100)`
  - **Fixed Amount**: Direct value from `travelData.discountValue`
- **Source**: `travelData.hasDiscount` and `travelData.discountType`

### 3. Fare Price (FPRE)

- **Formula**: BF - VD
- **Implementation**: `double farePrice = totalBaseFare - vendorDiscount;`
- **Validation**: Ensures fare doesn't go below 0

### 4. Coupon Discount (CD)

- **Formula**: At booking (flat / % with cap / conditional)
- **Implementation**: Currently returns 0 as placeholder
- **Future**: Can be integrated with existing coupon system
- **Source**: `_calculateCouponDiscount(farePrice)`

### 5. Net Fare (NF)

- **Formula**: FPRE - CD
- **Implementation**: `double netFare = farePrice - couponDiscount;`
- **Validation**: Ensures fare doesn't go below 0

### 6. Platform Fee (PF)

- **Formula**: Flat ₹5 (configurable)
- **Implementation**: `double platformFee = 5.0;`
- **Note**: Can be made configurable based on business requirements

### 7. Subtotal

- **Formula**: NF + PF
- **Implementation**: `double subtotal = netFare + platformFee;`

### 8. GST (5%)

- **Formula**: round(0.05 × Subtotal)
- **Implementation**: `double gst = (subtotal * 0.05).roundToDouble();`

### 9. Final Payable (FP)

- **Formula**: Subtotal + GST + Insurance + Cancellation
- **Implementation**:
  ```dart
  double finalPayable = subtotal + gst;
  finalPayable += insuranceFee; // If selected
  finalPayable += cancellationFee; // If selected
  ```

## Code Changes

### 1. Updated `_calculateTotalFare()` Method

- **File**: `lib/screens/traveller_information_screen.dart`
- **Lines**: 2812-2871
- **Changes**: Complete rewrite to implement new formula

### 2. Updated `TotalFareModal`

- **File**: `lib/utils/total_fare_modal.dart`
- **Changes**:
  - Updated constructor parameters
  - Added separate display for vendor discount and coupon discount
  - Proper GST calculation display

### 3. New Helper Methods

- **`_calculateVendorDiscount()`**: Calculates vendor discount amount
- **`_calculateFarePriceAfterVendorDiscount()`**: Calculates fare after vendor discount
- **`_calculateCouponDiscount()`**: Placeholder for coupon discount calculation
- **`_calculateGST()`**: Calculates GST amount

## Usage

### In Traveller Information Screen

```dart
String totalFare = _calculateTotalFare();
```

### In TotalFareModal

```dart
TotalFareModal(
  baseAmount: basePrice,
  vendorDiscount: _calculateVendorDiscount(),
  couponDiscount: _calculateCouponDiscount(farePrice),
  platformFee: 5.0,
  gst: _calculateGST(),
  // ... other parameters
)
```

## Debug Information

The implementation includes comprehensive debug logging that prints:

- Base fare per person
- Adult count
- Total base fare
- Vendor discount
- Fare price after vendor discount
- Coupon discount
- Net fare
- Platform fee
- Subtotal
- GST (5%)
- Insurance fee
- Cancellation fee
- Final payable amount

## Future Enhancements

### 1. Coupon System Integration

- Implement actual coupon discount calculation
- Support for percentage and fixed amount coupons
- Coupon validation and application

### 2. Platform Fee Configuration

- Make platform fee configurable
- Support for different fee structures
- Dynamic fee calculation based on trek type

### 3. GST Configuration

- Make GST percentage configurable
- Support for different tax rates
- Tax exemption handling

### 4. Discount Validation

- Ensure discounts don't exceed base amounts
- Support for minimum booking amounts
- Complex discount rules

## Testing

To test the implementation:

1. Set different base prices
2. Apply vendor discounts (percentage and fixed)
3. Verify GST calculation (5% of subtotal)
4. Check platform fee addition
5. Validate insurance and cancellation fee addition
6. Ensure total calculation accuracy

## Notes

- All calculations use proper null safety
- Amounts are rounded appropriately
- Negative amounts are prevented
- Debug logging is included for development
- The implementation is backward compatible
