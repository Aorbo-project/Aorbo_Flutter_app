# Partial Payment Implementation

## Overview

The partial payment option has been unlocked and implemented according to the specified formula. Users can now select the "Pay ₹999" option and see the correct advance amount and remaining balance.

## Implementation Details

### 1. Partial Payment Logic

- **Advance Amount**: Fixed ₹999 per person
- **Remaining Amount**: Final Payable (FP) - Advance
- **Payment Flow**:
  - At booking: Show advance amount
  - Before trek start: Pay remaining balance

### 2. Updated `_calculateTotalFare()` Method

The method now handles both payment options:

```dart
String _calculateTotalFare() {
  if (_selectedPaymentOption == 'partial') {
    // Show advance amount (₹999 per person)
    double advanceAmount = 999.0 * _adultCount;
    return advanceAmount.toStringAsFixed(0);
  } else {
    // Show complete fare with GST
    double finalPayable = _calculateFullFareAmount();
    return finalPayable.toStringAsFixed(0);
  }
}
```

### 3. New Helper Methods

#### `_calculateFullFareAmount()`

- Calculates the complete fare using the formula:
  1. Base Fare (BF) = Price × Number of travellers
  2. Vendor Discount (VD) = % or flat discount
  3. Fare Price (FPRE) = BF - VD
  4. Coupon Discount (CD) = At booking
  5. Net Fare (NF) = FPRE - CD
  6. Platform Fee (PF) = ₹5
  7. Subtotal = NF + PF
  8. GST (5%) = round(0.05 × Subtotal)
  9. Final Payable = Subtotal + GST + Insurance + Cancellation

#### `_calculateRemainingAmount()`

- Calculates remaining amount: Full Fare - Advance
- Ensures remaining amount doesn't go below 0

#### `_getTotalFareSubtitleText()`

- **Partial Payment**: "Pay ₹[remaining] now, ₹[remaining] before trek start"
- **Full Payment**: "Tax Included"

### 4. Updated TotalFareModal

The modal now properly displays:

#### For Partial Payment:

- **Advance Payment (₹999 per person)**: Shows the advance amount
- **Remaining Amount**: Shows the balance to be paid later
- **Amount Payable Now**: Shows only the advance amount

#### For Full Payment:

- **Total Basic Cost**: Base fare
- **GST (5%)**: Tax calculation
- **Platform Fees**: ₹5
- **Insurance/Cancellation**: If selected
- **Vendor/Coupon Discount**: If applicable
- **Total Amount**: Complete fare

### 5. UI Updates

#### Traveller Information Screen

- **Total Fare Display**: Shows advance amount for partial payment
- **Subtitle Text**: Dynamic text based on payment option
- **Fare Breakdown Modal**: Proper calculation display

#### Payment Button

- **Text**: "Pay Now" (shows advance amount for partial)
- **Amount**: ₹999 per person for partial payment

## Example Calculation

### Case Study: Partial Payment Trek

**Inputs:**

- BF = ₹6000
- VD = 10% (₹600) → FPRE = ₹5400
- No Coupon
- PF = ₹5
- GST = 5%
- 1 Adult

**Calculation:**

1. FPRE = ₹5400
2. NF = ₹5400
3. Subtotal = ₹5400 + ₹5 = ₹5405
4. GST = ₹270.25 → ₹270 (rounded)
5. FP = ₹5405 + ₹270 = ₹5675

**Partial Payment:**

- Advance = ₹999
- Remaining = ₹5675 - ₹999 = ₹4676

**Display:**

- ✅ At booking: "Advance Paid ₹999"
- ✅ Pending: "Pay ₹4676 before trek start"

## Key Features

### 1. Dynamic Fare Calculation

- Automatically switches between advance and full fare
- Maintains proper GST calculation on subtotal
- Handles all discounts correctly

### 2. Clear User Communication

- Shows advance amount clearly
- Displays remaining balance
- Explains payment timeline

### 3. Proper State Management

- Stores correct amount in controller
- Updates UI based on payment option
- Maintains fare breakdown accuracy

### 4. Debug Information

- Comprehensive logging for development
- Shows calculation steps
- Helps troubleshoot issues

## Testing Scenarios

### 1. Partial Payment Selection

- Select "Pay ₹999" option
- Verify advance amount is ₹999 × number of adults
- Check subtitle shows remaining amount
- Confirm fare breakdown shows advance and remaining

### 2. Full Payment Selection

- Select "Pay Full Amount" option
- Verify total amount includes GST
- Check subtitle shows "Tax Included"
- Confirm fare breakdown shows complete breakdown

### 3. Multiple Adults

- Change adult count
- Verify advance amount scales correctly
- Check remaining amount calculation
- Confirm GST calculation accuracy

### 4. Discounts

- Apply vendor discounts
- Verify discount affects remaining amount
- Check GST calculation on discounted subtotal
- Confirm advance amount remains fixed

## Future Enhancements

### 1. Dynamic Advance Amount

- Make ₹999 configurable per trek
- Support for different advance percentages
- Vendor-specific advance rules

### 2. Payment Tracking

- Track advance payments
- Show payment history
- Handle multiple payment installments

### 3. Reminder System

- Notify users about remaining balance
- Send payment reminders
- Track payment deadlines

### 4. Advanced Discount Rules

- Minimum advance requirements
- Discount eligibility based on payment type
- Complex discount combinations

## Notes

- All calculations maintain proper null safety
- GST is calculated correctly on subtotal
- Platform fee is added before GST calculation
- Negative amounts are prevented
- Debug logging is included for development
- The implementation is backward compatible
- Partial payment option is now fully functional
