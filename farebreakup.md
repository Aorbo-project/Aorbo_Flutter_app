📚 Case Studies
Case Study 1: Vendor Discount Only (10% OFF at Trek Creation)
Inputs
●
BF = ₹6000
●
VD = 10% → 600
●
CD = None
●
PF = ₹10
●
GST = 5%
Calculation

1. BF = 6000
2. VD = 600 → FPRE = 6000 − 600 = 5400
3. CD = 0 → NF = 5400
4. Add PF = 5400 + 10 = 5410
5. GST = 5% × 5410 = 270.5 → ₹271
6. FP = 5410 + 271 = ₹5681
   ✅ Output: Final = ₹5681
   Case Study 2: Vendor Discount + Flat Coupon (₹100 OFF)
   Inputs
   ●
   BF = 6000
   ●
   VD = 10% (600) → FPRE = 5400
   ●
   CD = ₹100 OFF
   ●
   PF = ₹10
   ●
   GST = 5%
   Calculation
7. BF = 6000 → VD = 600 → FPRE = 5400
8. CD = 100 → NF = 5400 − 100 = 5300
9. Add PF = 5300 + 10 = 5310
10. GST = 5% × 5310 = 265.5 → ₹266
11. FP = 5310 + 266 = ₹5576
    ✅ Output: Final = ₹5576
    Case Study 3: Vendor Discount + Percentage Coupon (50% up to ₹500)
    Inputs
    ●
    BF = 6000
    ●
    VD = 10% (600) → FPRE = 5400
    ●
    CD = 50% = 2700 but capped at 500
    ●
    ●
    PF = ₹10
    GST = 5%
    Calculation
12. FPRE = 5400
13. CD = min(2700, 500) = 500 → NF = 4900
14. Add PF = 4900 + 10 = 4910
15. GST = 5% × 4910 = 245.5 → ₹246
16. FP = 4910 + 246 = ₹5156
    ✅ Output: Final = ₹5156
    Case Study 4: Vendor Discount + Conditional Coupon (₹250 OFF on
    Premium)
    Inputs
    ●
    BF = 6000
    ●
    VD = 10% (600) → FPRE = 5400
    ●
    CD = ₹250 OFF (valid, trek = Premium)
    ●
    PF = ₹10
    ●
    GST = 5%
    Calculation
17. FPRE = 5400
18. 3. 4. 5. CD = 250 → NF = 5150
             Add PF = 5150 + 10 = 5160
             GST = 5% × 5160 = 258
             FP = 5160 + 258 = ₹5418
             ✅ Output: Final = ₹5418
             Case Study 5: Vendor Discount + Conditional Coupon (₹150 OFF on
             Weekend Trek)
             Inputs
             ●
             BF = 6000
             ●
             VD = 10% (600) → FPRE = 5400
             ●
             CD = ₹150 OFF (valid, trek = Weekend)
             ●
             PF = ₹10
             ●
             GST = 5%
             Calculation
19. FPRE = 5400
20. CD = 150 → NF = 5250
21. Add PF = 5250 + 10 = 5260
22. GST = 5% × 5260 = 263
23. FP = 5260 + 263 = ₹5523
    ✅ Output: Final = ₹5523
    Case Study 6: Vendor Discount + No Coupon
    Inputs
    ●
    ●
    ●
    ●
    ●
    BF = 6000
    VD = 10% (600) → FPRE = 5400
    CD = 0
    PF = ₹10
    GST = 5%
    Calculation
24. FPRE = 5400
25. NF = 5400
26. Add PF = 5400 + 10 = 5410
27. GST = 5% × 5410 = 270.5 → ₹271
28. FP = 5410 + 271 = ₹5681
    ✅ Output: Final = ₹5681
    ⚡ Developer Notes:
    ●
    Always apply Vendor Discount first, then coupon discount.
    ●
    Coupon discount should validate category / trek type / expiry date.
    ●
    PF always added after discounts.
    ●
    GST must be last step, always on (NF + PF).
    ●
    Round GST to nearest rupee.

Fare Calculation with Partial Payments:

📚 Case Studies
Case Study A: Partial Payment Trek — Customer Pays Only Advance at
Booking
Inputs
●
BF = 6000
●
VD = 10% (600) → FPRE = 5400
●
No Coupon
●
PF = ₹10
●
GST = 5%
Calculation

1. FPRE = 5400
2. NF = 5400
3. Subtotal = 5400 + 10 = 5410
4. GST = 271
5. FP = 5410 + 271 = ₹5681
   Advance = 999
   Remaining = 5681 − 999 = ₹4682
   ✅ At booking: Show “Advance Paid ₹999”
   ✅ Pending: Show “Pay ₹4682 before trek start”
   Case Study B: Partial Payment Trek — Customer Pays Full Upfront
   Inputs same as Case A
   FP = ₹5681
   Customer pays full = ₹5681
   ✅ At booking: Show single receipt with full fare.
   ✅ No need to show “advance/remaining”
   Category).
   — just tag internally as Full Paid (Partial Trek
   Case Study C: Partial Payment Trek + Coupon Applied (₹100 OFF)
   Inputs
   ●
   ●
   ●
   BF = 6000
   VD = 10% (600) → 5400
   CD = 100 → 5300
   ●
   ●
   PF = 10 → 5310
   GST = 266
   ●
   FP = 5310 + 266 = ₹5576
   Advance = 999
   Remaining = 5576 − 999 = ₹4577
   ✅ At booking: Show Advance Paid ₹999
   ✅ Pending: Show Remaining ₹4577
   Case Study D: Partial Payment Trek + Percentage Coupon (50% OFF up to
   ₹500)
   Inputs
   ●
   BF = 6000
   ●
   VD = 10% (600) → 5400
   ●
   CD = capped at 500 → 4900
   ●
   PF = 10 → 4910
   ●
   GST = 246
   ●
   FP = 4910 + 246 = ₹5156
   Advance = 999
   Remaining = 5156 − 999 = ₹4157
   ✅ At booking: Show “Advance Paid ₹999”
   ✅ Pending: Show “Remaining ₹4157”
   Case Study E: Customer Pays Remaining Balance Later (Split Flow)
   Suppose Case D applies: FP = ₹5156
   ●
   Booking (Aug 1): Paid ₹999 → System issues receipt: “Advance Paid ₹999, Remaining
   ₹4157 due”
   .
   ●
   Balance Payment (Aug 3): Paid ₹4157 → System marks trek as Fully Paid.
   No new breakup needed — same FP logic is reused.
