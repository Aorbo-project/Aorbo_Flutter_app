Policy Overview
Refunds, fees, and add-ons (like insurance or free cancellation) follow strict, advance-defined logic.

GST (5%) is always refunded if the trek/service is not delivered (e.g., customer cancels before departure); company must adjust GST returns for these.

Platform Fee is non-refundable in all scenarios and is part of platform revenue, but remains taxable.

Insurance/Add-ons are non-refundable, except if free cancellation is bought and terms allow a refund; payment must be passed to insurers swiftly.

All refunds go back to the original payment method; cash refunds need extra manual tracking.

Strict time rules: Server evaluates time in UTC down to the second. Refund logic is bound to either "greater than 24h" or "24h or less" before trek starts.

Cancel is idempotent: Only the first valid cancel is allowed; repeats return an error (409 Conflict).

Structure & Logic with Simplified Examples
Blocks of Cases
Base Fare Only: Refund and retention when only the main amount is paid, advancing or in full.

Add-ons: How insurance and free cancellation affect refund deductions.

Coupons: Discounts of all types (flat, percent, group, conditional) impact refund calculations and GST.

Mixed/Edge Cases: When add-ons + coupons mix, and for boundary, operator, and payment edge cases.

Example Scenarios
Scenario Type Example Inputs Cancel Time What’s Held What’s Refunded Key Rule
Advance Only (Base) Fare ₹5,999, Advance ₹999, Fee ₹15, GST ₹299.95 >24h 999 + 15 299.95 GST refundable, fees non-refundable
same ≤24h or after start 999 + 15 299.95 No fare refund, GST still refunded
Full Payment Paid ₹6,313.95 (fare + fee + GST) >24h 999 + 15 Rest Hold advance, refund balance + GST
same =24h or less 5,999 + 15 0 100% deduction at 24h cutoff
Insurance Add-On Fare + Insurance ₹150 >24h 999 + 15 + 150 299.95 Insurance non-refundable
Free Cancellation Add-On Paid add-on ₹200 >24h 15 + 200 999 + 299.95 Add-on lets advance be refunded
Coupon Discount ₹500 off, Advance ₹999 >24h 999 + 15 GST recalculated on net Refund on post-discount GST
Operator Cancels Any N/A 0 All paid (+ add-ons if not activated) Trek not delivered, full refund
Double Cancel Any scenario N/A 1st: as above, 2nd: error As first Second attempt = error 409
Special Rules
If the trek is canceled by the operator, full refund including GST and possibly add-ons (if not yet passed to insurer).

When booking has coupons, GST is computed on net price after discount, and refunds respect this.

In multi-trek or group bookings, each trek’s refund is calculated independently; discounts are re-allocated as needed.

All time calculations are server-UTC; local device times do not affect refund eligibility.

If double cancel is attempted, only one gets processed; the rest are rejected.

Real-World Example
User pays Advance + Platform Fee + GST (₹1,313.95) for a trek.

Cancels 3 days (>72h) before trek: Company holds advance + fee, refunds GST.

Cancels 12h before trek: Company holds advance + fee, refunds GST (since trek isn’t delivered).

Cancels at exactly 24h: Same as above, but company can treat this as "no fare refund" if strict cutoff applied.

This policy ensures clarity and fairness—users know in advance what they lose or get back, and edge cases are covered systematically. Each case in the PDF follows a clear format with input values, calculation, and rules; full coverage is achieved for every possible scenario.

IN DETAIL :

Legal / Accounting Notes (must be implemented in
design)

1. GST handling: GST = 5% on taxable base. For cancellations before service
   delivery, GST should be refunded to customer and your accounting should reflect
   reversal/adjustment to GST returns. Consult your finance team to ensure
   compliance and timely remittance adjustments.
2. Platform Fee: Treated as Aorbo revenue — non-refundable by default. Still
   taxable; GST treatment on platform fee may differ depending on how you classify
   charges (consult tax advisor).
3. Insurance / Add-ons (not in these base cases): If charged, insurer payment flow
   must be immediate (we forward insurer portion to insurer) — design checkout so
   optional add-ons are fully collected at booking time.
4. Refund Source: Always refund to original payment instrument where possible.
   Cash refunds require reconciliation and explicit manual process.
5. Time precision & timezone: All server comparisons must be in UTC with
   second-level precision; UI should show clear absolute times.
6. Idempotency & Disputes: Implement idempotency tokens for cancel operations;
   second cancel attempt must return 409 Conflict. Implement a robust audit
   trail for refunds (who, when, reason) to defend against disputes.
   How I’ll Structure the 100 Study Cases
   I’ll break them into blocks of ~20 each so it’s readable and usable:
7. Base Fare Only (Advance & Full Pay) → ~10–15 cases
8. With Add-ons (Insurance, Free Cancellation, Both) → ~15–20 cases
9. With Coupons (5 coupon types × timing variations) → ~20–25 cases
10. Mixed Cases (Add-ons + Coupons + GST + Platform Fee) → ~25–30 cases
11. Boundary & Edge Cases (exact 24h, after trek start, double cancellation, GST
    refund logic, etc.) → ~15–20 cases
    📌 Example Format (for every case)
    I’ll keep it super clean for devs:
    Case ID: FLEX-ADV-001
    Scenario: Advance-only, no add-ons, cancel >24h
    Inputs:

- Original Fare: ₹5,999
- Advance: ₹999
- Platform Fee: ₹15
- GST: ₹300
- Add-ons: None
- Coupon: None
  Action: Cancel 72h before trek
  Calculation:
  Pay Now = 999 + 15 + 300 = ₹1,314
  Balance Later = ₹5,000
  Expected Output:
  Deduction = ₹999 + ₹15
  Refund = ₹300
  Rule: Advance non-refundable, platform fee non-refundable, GST
  refundable
  📌 Legal / Compliance Coverage
  ●
  ●
  ●
  ●
  ●
  ●
  ●
  GST: Discount applied before GST (taxable value reduced). Refund only if trek not
  delivered (per RCM).
  Platform Fee: Always non-refundable.
  Insurance: Non-refundable (we pass it to insurer).
  Free Cancellation: Only works if cancellation >24h. Within 24h, add-on is consumed.
  Refund Source: Always back to original method, 5–7 business days.
  Double Cancel: Second cancel attempt → 409 Conflict.
  After Trek Start: No refund, all charges consumed.
  Assumptions used in these 20 cases
  ●
  Original Fare (trek price): ₹5,999
  ●
  Advance (where applicable): ₹999
  ●
  Platform Fee: ₹15 (nominal fixed)
  ●
  GST: 5% on Original Fare = 5% × 5,999 = ₹299.95 (round
  half
  \_
  \_
  up to 2 decimals)
  ●
  No add-ons (Insurance / Free Cancellation) and no coupons in these base cases.
  ●
  Time to departure expressed in hours.
  “≤24h” means 24 hours or less.
  “>24h” means strictly greater than 24 hours;
  ●
  Refund rules used:
  ○
  ○
  ○
  ○
  ○
  Platform Fee: non-refundable (keeps platform from being out-of-pocket).
  Advance: non-refundable when user paid only advance; for full-paid
  cancellations >24h, advance amount is the deduction (unless free-cancel add-on
  applied — not in base cases).
  GST: refundable if the service (trek) is not delivered (customer cancelled before
  departure). (Legal note below — ensure tax/accounting handles adjustments.)
  Cancellation ≤24h or after start: no refund (100% deduction).
  Double cancel attempts: second attempt → 409 Conflict.
  Format used per case
  ●
  ●
  ●
  ●
  ●
  ●
  ●
  Case ID
  Scenario
  Inputs (fare, advance or full, platform fee, GST)
  Action / Time to departure
  Pay Now (amount actually collected at booking time)
  Balance Later (if advance only)
  Expected Output — Deduction (what is retained) / Refund (what is returned) / Rule
  (short reason)
  BLOCK — 20 Base-Fare Study Cases
  Case: BASE-001
  Scenario: Advance-only booking; cancel 10 days before departure (>72h)
  Inputs: Fare ₹5,999; Advance ₹999; Platform Fee ₹15; GST ₹299.95
  Action: Cancel 240h before trek
  Pay Now: 999 + 15 + 299.95 = ₹1,313.95
  Balance Later: ₹5,000
  Expected Output:
  ●
  Deduction = Advance + Platform Fee = 999 + 15 = ₹1,014.00
  ●
  Refund = GST = ₹299.95
  ●
  Rule: Advance non-refundable; platform fee non-refundable; GST refundable (trek not
  provided).
  Case: BASE-002
  Scenario: Advance-only booking; cancel 3 days before (72h exactly)
  Inputs: same as BASE-001
  Action: Cancel exactly 72.00h before trek
  Pay Now: ₹1,313.95
  Balance Later: ₹5,000
  Expected Output:
  ●
  Deduction = Advance + Platform Fee = ₹1,014.00
  ●
  Refund = GST = ₹299.95
  ●
  Rule: Advance non-refundable. (72h boundary falls into >24h behavior for flexible
  policy.)
  Note: In standard-slab policies 72h may map elsewhere; for flexible base cases we
  treat any >24h as refundable of GST.
  Case: BASE-003
  Scenario: Advance-only booking; cancel exactly 24h before departure
  Inputs: same
  Action: Cancel at 24.00h before trek
  Pay Now: ₹1,313.95
  Balance Later: ₹5,000
  Expected Output:
  ●
  Deduction = Advance + Platform Fee = ₹1,014.00
  ●
  Refund = GST = ₹299.95
  ●
  Rule: Advance non-refundable. (Flexible policy defines 24h as cutoff — for free-cancel
  handling user must have purchased add-on; here base case no add-on.)
  Case: BASE-004
  Scenario: Advance-only booking; cancel 12h before departure (<24h)
  Inputs: same
  Action: Cancel at 12.00h before trek
  Pay Now: ₹1,313.95
  Balance Later: ₹5,000
  Expected Output:
  ●
  Deduction = Advance + Platform Fee = ₹1,014.00
  ●
  Refund = GST = ₹299.95
  ●
  Rule: Advance non-refundable; since only advance was paid, no further refund.
  (Note: Base model refunds GST when trek not delivered; user cancellation still means service
  not delivered → GST refundable.)
  Case: BASE-005
  Scenario: Advance-only booking; cancel after trek start (post-departure)
  Inputs: same
  Action: Cancel after trek has started
  Pay Now: ₹1,313.95
  Balance Later: ₹5,000
  Expected Output:
  ●
  Deduction = Advance + Platform Fee = ₹1,014.00
  ●
  Refund = GST = ₹299.95 (if tax rules require refund; but operationally if trek started,
  company may treat as non-refundable — confirm with finance).
  ●
  Rule: Advance non-refundable. (Legal: if service partially consumed, GST adjustment
  may be required — see Legal Notes.)
  Case: BASE-006
  Scenario: Full payment at booking (no add-ons); cancel 10 days before (>72h)
  Inputs: Fare ₹5,999; Platform Fee ₹15; GST ₹299.95; Full paid at booking => Paid = ₹6,313.95
  Action: Cancel 240h before trek
  Pay Now: ₹6,313.95
  Balance Later: N/A
  Expected Output:
  ●
  Deduction = Advance + Platform Fee = 999 + 15 = ₹1,014.00
  ●
  Refund = Paid Now − Deduction = 6,313.95 − 1,014 = ₹5,299.95
  (Equivalent to (Fare − Advance) + GST = 5,000 + 299.95 = 5,299.95)
  ●
  Rule: Hold advance portion; platform fee non-refundable; GST refunded.
  Case: BASE-007
  Scenario: Full payment; cancel exactly 72h before
  Inputs: same as BASE-006
  Action: Cancel at 72.00h
  Pay Now: ₹6,313.95
  Expected Output:
  ●
  Deduction = ₹1,014.00
  ●
  Refund = ₹5,299.95
  ●
  Rule: same as BASE-006.
  Case: BASE-008
  Scenario: Full payment; cancel 48h before (just within multi-day)
  Inputs: same
  Action: Cancel at 48.00h
  Expected Output:
  ●
  Deduction = ₹1,014.00
  ●
  Refund = ₹5,299.95
  ●
  Rule: >24h branch applies (refund rest after holding advance).
  Case: BASE-009
  Scenario: Full payment; cancel 25h before (just over 24h)
  Inputs: same
  Action: Cancel at 25.00h
  Expected Output:
  ●
  Deduction = ₹1,014.00
  ●
  Refund = ₹5,299.95
  ●
  Rule: still >24h; refund rest.
  Case: BASE-010
  Scenario: Full payment; cancel exactly 24.00h before departure (boundary)
  Inputs: same
  Action: Cancel at 24.00h
  Expected Output:
  ●
  Deduction = Full Fare = ₹5,999.00 plus platform fee retained? For consistency with
  flexible rule, cancellation at 24h is no refund.
  ●
  Refund = ₹0.00
  ●
  Rule: 100% deduction at the 24h boundary.
  Dev note: boundary behavior is strict — exactly 24.000h => no refund.
  Case: BASE-011
  Scenario: Full payment; cancel 23.99h before (fractional just under 24h)
  Inputs: same
  Action: Cancel at 23.99h
  Expected Output:
  ●
  Deduction = Full Fare = ₹5,999.00 + Platform fee consumed => effectively no refund.
  ●
  Refund = ₹0.00
  ●
  Rule: within 24h => no refund.
  Case: BASE-012
  Scenario: Full payment; cancel 12h before (within 24h)
  Inputs: same
  Action: Cancel at 12.00h
  Expected Output:
  ●
  ●
  ●
  Deduction = ₹5,999.00 (full fare)
  Refund = ₹0.00
  Rule: no refund within 24h.
  Case: BASE-013
  Scenario: Full payment; cancel at trek start time (0h)
  Inputs: same
  Action: Cancel at 0.00h (trek start)
  Expected Output:
  ●
  Deduction = ₹5,999.00
  ●
  Refund = ₹0.00
  ●
  Rule: cancellation at start → no refund.
  Case: BASE-014
  Scenario: Full payment; cancel 1 minute after trek start (after start)
  Inputs: same
  Action: Cancel at +0.0167h after start
  Expected Output:
  ●
  Deduction = ₹5,999.00
  ●
  Refund = ₹0.00
  ●
  Rule: after trek start → no refunds.
  Case: BASE-015
  Scenario: Double cancel attempt (advance-only booking), user cancels >24h then re-sends
  cancel request
  Inputs: Advance-only, same values
  Action: First cancel at 72h → Second cancel request immediate after
  Pay Now: ₹1,313.95
  Expected Output:
  ●
  ●
  ●
  1st request: success → Deduction = ₹1,014.00, Refund = ₹299.95
  2nd request: 409 Conflict (no changes)
  Rule: idempotency enforced.
  Case: BASE-016
  Scenario: User pays full, then initiates cancellation and disputes because payment gateway
  shows deducted but booking not confirmed; cancel >24h. This tests payment-state race.
  Inputs: Full-paid, same values
  Action: Cancel at 48h; system must verify payment settled before processing refund
  Expected Output:
  ●
  If payment settled: Deduction = ₹1,014.00, Refund = ₹5,299.95
  ●
  If payment unsettled (gateway rollback): Cancellation rejected until Settlement; user
  shown pending state.
  ●
  Rule: always verify settlement before issuing refund.
  Case: BASE-017
  Scenario: Timezone normalization test — user in IST cancels “24 hours before” local time but
  server UTC normalization matters.
  Inputs: Full-paid; trek start at 2025-12-22 11:00 UTC; user cancels at 2025-12-21 11:00 IST
  (which maps to 2025-12-21 05:30 UTC, i.e. 29.5h before).
  Action: Calculate slab using UTC normalized times.
  Expected Output:
  ●
  Since normalized time >24h, Deduction = ₹1,014.00, Refund = ₹5,299.95.
  ●
  Rule: always compare times in UTC on server.
  Case: BASE-018
  Scenario: Small fractional time edges — user cancels at 24h + 1 second; should be treated
  > 24h.
  > Inputs: Full-paid
  > Action: Cancel at 24h 0m 1s before trek
  > Expected Output:
  > ●
  > Deduction = ₹1,014.00, Refund = ₹5,299.95
  > ●
  > Rule: compare time with second-level precision; use strict > vs <= semantics.
  > Case: BASE-019
  > Scenario: Refund accounting test — customer cancels >24h; ensure refund includes GST
  > reconciliation.
  > Inputs: Full-paid; same values
  > Action: Cancel at 48h
  > Expected Output:
  > ●
  > Deduction = ₹1,014.00 (advance + platform fee)
  > ●
  > Refund = ₹5,299.95 (this includes refund of GST ₹299.95)
  > ●
  > Rule: Finance must record reversal of GST remittance (adjust returns) and refund GST
  > amount to customer.
  > Case: BASE-020
  > Scenario: Chargeback / merchant liability — user claims refund not received after 7 business
  > days. System must show refund status.
  > Inputs: Full-paid, cancel >24h
  > Action: Refund triggered, but gateway chargeback initiated.
  > Expected Output:
  > ●
  > System shows refund Pending with timestamp; operations to investigate. If refund
  > failed, retry logic and notifications must be triggered.
  > ●
  > Rule: implement retries and clear UX for user; legal holds may apply for disputes.
  > BLOCK 2 — Add-ons Study Cases (21–40)
  > Common Values
  > ●
  > ●
  > ●
  > ●
  > ●
  > ●
  > ●
  > Original Fare: ₹5,999
  > Advance (when allowed): ₹999
  > Platform Fee: ₹15 (always)
  > GST: ₹299.95 (5% of trek price, rounded half-up)
  > Insurance: ₹150
  > Free Cancellation: ₹200
  > Add-ons are non-refundable (except Free Cancellation effect: refund advance if
  > cancelled >24h).
  > A. Insurance Only (Cases 21–26)
  > Case: ADD-021
  > Scenario: Advance-only + Insurance; cancel >72h
  > Inputs: Fare ₹5,999; Advance ₹999; Fee ₹15; GST ₹299.95; Insurance ₹150
  > Pay Now: 999 + 15 + 299.95 + 150 = ₹1,463.95
  > Balance Later: ₹5,000
  > Action: Cancel 240h before trek
  > Expected Output:
  > ●
  > Deduction = Advance (₹999) + Fee (₹15) + Insurance (₹150) = ₹1,164
  > ●
  > Refund = GST ₹299.95
  > ●
  > Rule: Advance & Insurance non-refundable.
  > Case: ADD-022
  > Scenario: Advance-only + Insurance; cancel ≤24h
  > Pay Now: ₹1,463.95
  > Action: Cancel 12h before trek
  > Expected Output:
  > ●
  > Deduction = ₹999 + ₹15 + ₹150 = ₹1,164
  > ●
  > Refund = GST ₹299.95
  > ●
  > Rule: Advance & Insurance non-refundable.
  > Case: ADD-023
  > Scenario: Advance-only + Insurance; cancel after trek start
  > Pay Now: ₹1,463.95
  > Action: Cancel after start
  > Expected Output:
  > ●
  > Deduction = ₹1,164
  > ●
  > Refund = GST ₹299.95 (if trek not provided)
  > ●
  > Rule: After start → no trek refund; Insurance already consumed.
  > Case: ADD-024
  > Scenario: Full Payment + Insurance; cancel >72h
  > Pay Now: 5,999 + 15 + 299.95 + 150 = ₹6,463.95
  > Expected Output:
  > ●
  > Deduction = Advance (₹999) + Fee (₹15) + Insurance (₹150) = ₹1,164
  > ●
  > Refund = Paid − Deduction = 6,463.95 − 1,164 = ₹5,299.95
  > ●
  > Rule: Hold advance; Insurance consumed.
  > Case: ADD-025
  > Scenario: Full Payment + Insurance; cancel exactly 24h
  > Pay Now: ₹6,463.95
  > Expected Output:
  > ●
  > Deduction = Full Fare (₹5,999) + Fee (₹15) + Insurance (₹150) = ₹6,164
  > ●
  > Refund = GST only = ₹299.95
  > ●
  > Rule: At 24h cutoff → 100% trek deduction; Insurance consumed.
  > Case: ADD-026
  > Scenario: Full Payment + Insurance; cancel within 12h
  > Pay Now: ₹6,463.95
  > Expected Output:
  > ●
  > Deduction = Full Paid = ₹6,463.95
  > ●
  > Refund = ₹0
  > ●
  > Rule: Within 24h → no refund; Insurance consumed.
  > B. Free Cancellation Only (Cases 27–32)
  > Case: ADD-027
  > Scenario: Advance-only + Free Cancellation; cancel >72h
  > Pay Now: 999 + 15 + 299.95 + 200 = ₹1,513.95
  > Balance Later: ₹5,000
  > Expected Output:
  > ●
  > Deduction = Fee (₹15) + Add-on (₹200) = ₹215
  > ●
  > Refund = Advance (₹999) + GST (₹299.95) = ₹1,298.95
  > ●
  > Rule: Free Cancellation covers advance when >24h.
  > Case: ADD-028
  > Scenario: Advance-only + Free Cancellation; cancel ≤24h
  > Pay Now: ₹1,513.95
  > Expected Output:
  > ●
  > Deduction = Advance (₹999) + Fee (₹15) + Add-on (₹200) = ₹1,214
  > ●
  > Refund = GST (₹299.95)
  > ●
  > Rule: Within 24h, add-on consumed, advance not refunded.
  > Case: ADD-029
  > Scenario: Advance-only + Free Cancellation; cancel after trek start
  > Pay Now: ₹1,513.95
  > Expected Output:
  > ●
  > Deduction = ₹1,214
  > ●
  > Refund = GST (₹299.95)
  > ●
  > Rule: No trek refund after start; add-on consumed.
  > Case: ADD-030
  > Scenario: Full Payment + Free Cancellation; cancel >72h
  > Pay Now: 5,999 + 15 + 299.95 + 200 = ₹6,513.95
  > Expected Output:
  > ●
  > Deduction = Fee (₹15) + Add-on (₹200) = ₹215
  > ●
  > Refund = 6,513.95 − 215 = ₹6,298.95
  > ●
  > Rule: Advance refunded thanks to add-on.
  > Case: ADD-031
  > Scenario: Full Payment + Free Cancellation; cancel ≤24h
  > Pay Now: ₹6,513.95
  > Expected Output:
  > ●
  > Deduction = Fee (₹15) + Add-on (₹200) + Advance (₹999) = ₹1,214
  > ●
  > Refund = 6,513.95 − 1,214 = ₹5,299.95
  > ●
  > Rule: Within 24h, advance retained, add-on consumed.
  > Case: ADD-032
  > Scenario: Full Payment + Free Cancellation; cancel after trek start
  > Pay Now: ₹6,513.95
  > Expected Output:
  > ●
  > Deduction = ₹6,513.95
  > ●
  > Refund = ₹0
  > ●
  > Rule: Add-on void once trek has started.
  > C. Insurance + Free Cancellation (Cases 33–40)
  > Case: ADD-033
  > Scenario: Advance-only + Insurance + Free Cancellation; cancel >72h
  > Pay Now: 999 + 15 + 299.95 + 200 + 150 = ₹1,663.95
  > Balance Later: ₹5,000
  > Expected Output:
  > ●
  > Deduction = Fee (₹15) + Insurance (₹150) + Add-on (₹200) = ₹365
  > ●
  > Refund = Advance (₹999) + GST (₹299.95) = ₹1,298.95
  > ●
  > Rule: Advance refunded by add-on; Insurance consumed.
  > Case: ADD-034
  > Scenario: Advance-only + Insurance + Free Cancellation; cancel ≤24h
  > Pay Now: ₹1,663.95
  > Expected Output:
  > ●
  > Deduction = Advance (₹999) + Fee (₹15) + Insurance (₹150) + Add-on (₹200) = ₹1,364
  > ●
  > Refund = GST (₹299.95)
  > ●
  > Rule: Within 24h, advance held, add-on consumed.
  > Case: ADD-035
  > Scenario: Advance-only + Insurance + Free Cancellation; cancel after trek start
  > Pay Now: ₹1,663.95
  > Expected Output:
  > ●
  > Deduction = ₹1,364
  > ●
  > Refund = GST (₹299.95)
  > ●
  > Rule: After start → no trek refund; Insurance consumed.
  > Case: ADD-036
  > Scenario: Full Payment + Insurance + Free Cancellation; cancel >72h
  > Pay Now: 5,999 + 15 + 299.95 + 200 + 150 = ₹6,663.95
  > Expected Output:
  > ●
  > Deduction = Fee (₹15) + Insurance (₹150) + Add-on (₹200) = ₹365
  > ●
  > Refund = 6,663.95 − 365 = ₹6,298.95
  > ●
  > Rule: Advance refunded thanks to add-on; Insurance consumed.
  > Case: ADD-037
  > Scenario: Full Payment + Insurance + Free Cancellation; cancel 48h before
  > Pay Now: ₹6,663.95
  > Expected Output:
  > ●
  > Deduction = ₹365
  > ●
  > ●
  > Refund = ₹6,298.95
  > Rule: same as >72h.
  > Case: ADD-038
  > Scenario: Full Payment + Insurance + Free Cancellation; cancel exactly 24h
  > Pay Now: ₹6,663.95
  > Expected Output:
  > ●
  > Deduction = Advance (₹999) + Fee (₹15) + Insurance (₹150) + Add-on (₹200) = ₹1,364
  > ●
  > Refund = 6,663.95 − 1,364 = ₹5,299.95
  > ●
  > Rule: At 24h cutoff → advance not refunded; add-on consumed.
  > Case: ADD-039
  > Scenario: Full Payment + Insurance + Free Cancellation; cancel ≤12h
  > Pay Now: ₹6,663.95
  > Expected Output:
  > ●
  > Deduction = Full Paid = ₹6,663.95
  > ●
  > Refund = ₹0
  > ●
  > Rule: Within 24h → add-on void; Insurance consumed.
  > Case: ADD-040
  > Scenario: Full Payment + Insurance + Free Cancellation; cancel after trek start
  > Pay Now: ₹6,663.95
  > Expected Output:
  > ●
  > Deduction = ₹6,663.95
  > ●
  > Refund = ₹0
  > ●
  > Rule: After start → no refund; add-ons consumed.
  > BLOCK 3 — Coupons Study Cases (41–70)
  > Common Values
  > ●
  > ●
  > ●
  > Fare (base trek price): ₹5,999
  > Advance: ₹999 (only when advance booking allowed)
  > Platform Fee: ₹15
  > ●
  > GST: 5% on discounted trek price (after coupon) → taxable base reduced, per GST
  > law.
  > ●
  > ●
  > Coupon types:

1. Flat Discount (e.g., ₹500 off)
2. Percentage Discount (e.g., 20% off)
3. Flat Up-To Discount (e.g., 20% up to ₹500)
4. Group Discount (10% off for 5+ people)
5. Conditional Discount (Book 3 treks → 15% off)
   Deduction rules same as before (Advance/Platform Fee non-refundable, GST refunded if
   trek not delivered).
   A. Flat Discount (₹500 off) – Cases 41–46
   Case: COUP-041
   Scenario: Advance-only + Flat ₹500 off; cancel >72h
   Inputs: Fare ₹5,999 − 500 = ₹5,499; Advance ₹999; Fee ₹15; GST = 5% × 5,499 = ₹274.95
   Pay Now: 999 + 15 + 274.95 = ₹1,288.95
   Balance Later: 4,500
   Action: Cancel 240h before trek
   Expected Output:
   ●
   Deduction = 999 + 15 = ₹1,014.00
   ●
   Refund = GST ₹274.95
   ●
   Rule: Advance non-refundable; GST refundable.
   Case: COUP-042
   Scenario: Advance-only + Flat ₹500 off; cancel ≤24h
   Expected Output:
   ●
   Deduction = 999 + 15 = ₹1,014.00
   ●
   Refund = GST ₹274.95
   ●
   Rule: Same as above.
   Case: COUP-043
   Scenario: Full Payment + Flat ₹500 off; cancel >72h
   Pay Now: 5,499 + 15 + 274.95 = ₹5,788.95
   Expected Output:
   ●
   ●
   ●
   Deduction = 999 + 15 = ₹1,014.00
   Refund = 5,788.95 − 1,014 = ₹4,774.95
   Rule: Hold advance; platform fee retained.
   Case: COUP-044
   Scenario: Full Payment + Flat ₹500 off; cancel ≤24h
   Expected Output:
   ●
   Deduction = 5,499 + 15 = ₹5,514.00
   ●
   Refund = GST only = ₹274.95
   ●
   Rule: 100% trek fare deduction at ≤24h.
   Case: COUP-045
   Scenario: Full Payment + Flat ₹500 off; cancel at 24h boundary
   Expected Output:
   ●
   Deduction = ₹5,514.00
   ●
   Refund = ₹274.95
   ●
   Rule: Strict cutoff → no fare refund.
   Case: COUP-046
   Scenario: Full Payment + Flat ₹500 off; cancel after trek start
   Expected Output:
   ●
   Deduction = ₹5,788.95
   ●
   Refund = ₹0.00
   ●
   Rule: After start → no refund.
   B. Percentage Discount (20% off) – Cases 47–52
   Case: COUP-047
   Scenario: Advance-only + 20% off; cancel >72h
   Inputs: Fare 5,999 − 20% = 4,799; Advance = 999; Fee 15; GST = 5% × 4,799 = ₹239.95
   Pay Now: 999 + 15 + 239.95 = ₹1,253.95
   Balance Later: 3,800
   Expected Output:
   ●
   Deduction = 999 + 15 = ₹1,014.00
   ●
   Refund = ₹239.95
   ●
   Rule: Advance non-refundable.
   Case: COUP-048
   Scenario: Advance-only + 20% off; cancel ≤24h
   Expected Output:
   ●
   Deduction = ₹1,014.00
   ●
   Refund = ₹239.95
   Case: COUP-049
   Scenario: Full Payment + 20% off; cancel >72h
   Pay Now: 4,799 + 15 + 239.95 = ₹5,053.95
   Expected Output:
   ●
   Deduction = ₹1,014.00
   ●
   Refund = 5,053.95 − 1,014 = ₹4,039.95
   Case: COUP-050
   Scenario: Full Payment + 20% off; cancel ≤24h
   Expected Output:
   ●
   Deduction = ₹4,814.00
   ●
   Refund = GST ₹239.95
   Case: COUP-051
   Scenario: Full Payment + 20% off; cancel at 24h
   Expected Output:
   ●
   Deduction = ₹4,814.00
   ●
   Refund = ₹239.95
   Case: COUP-052
   Scenario: Full Payment + 20% off; cancel after trek start
   Expected Output:
   ●
   Deduction = ₹5,053.95
   ●
   Refund = 0
   C. Flat Up-To Discount (20% up to ₹500) – Cases 53–58
   Case: COUP-053
   Scenario: Advance-only + 20% Up-To ₹500; cancel >72h
   Inputs: 20% of 5,999 = 1,199.80 → capped at 500 → Net fare = 5,499
   GST = 274.95
   Pay Now: 999 + 15 + 274.95 = ₹1,288.95
   Balance Later: 4,500
   Expected Output: Deduction = 1,014; Refund = 274.95
   Case: COUP-054
   Scenario: Advance-only + Up-To coupon; cancel ≤24h
   Refund = 274.95; Deduction = 1,014
   Case: COUP-055
   Scenario: Full Payment + Up-To coupon; cancel >72h
   Pay Now: 5,499 + 15 + 274.95 = ₹5,788.95
   Refund = 4,774.95; Deduction = 1,014
   Case: COUP-056
   Scenario: Full Payment + Up-To coupon; cancel ≤24h
   Deduction = 5,514; Refund = 274.95
   Case: COUP-057
   Scenario: Full Payment + Up-To coupon; cancel at 24h
   Deduction = 5,514; Refund = 274.95
   Case: COUP-058
   Scenario: Full Payment + Up-To coupon; cancel after trek start
   Refund = 0; Deduction = 5,788.95
   D. Group Discount (10% off, 5+ trekkers) – Cases 59–64
   Case: COUP-059
   Scenario: Advance-only, Group discount 10% off; cancel >72h
   Fare per person = 5,999 − 600 = 5,399
   GST = 269.95
   Pay Now: 999 + 15 + 269.95 = ₹1,283.95
   Expected Output: Deduction = 1,014; Refund = 269.95
   Case: COUP-060
   Scenario: Advance-only + Group; cancel ≤24h
   Refund = 269.95; Deduction = 1,014
   Case: COUP-061
   Scenario: Full Payment + Group; cancel >72h
   Pay Now: 5,399 + 15 + 269.95 = ₹5,683.95
   Refund = 4,669.95; Deduction = 1,014
   Case: COUP-062
   Scenario: Full Payment + Group; cancel ≤24h
   Deduction = 5,414; Refund = 269.95
   Case: COUP-063
   Scenario: Full Payment + Group; cancel at 24h
   Same as above
   Case: COUP-064
   Scenario: Full Payment + Group; cancel after trek start
   Refund = 0; Deduction = 5,683.95
   E. Conditional Discount (15% off when 3 treks booked) –
   Cases 65–70
   Case: COUP-065
   Scenario: Advance-only + Conditional 15% off; cancel >72h
   Fare = 5,099
   GST = 254.95
   Pay Now: 999 + 15 + 254.95 = ₹1,268.95
   Refund = 254.95; Deduction = 1,014
   Case: COUP-066
   Scenario: Advance-only + Conditional; cancel ≤24h
   Same values; Refund = 254.95; Deduction = 1,014
   Case: COUP-067
   Scenario: Full Payment + Conditional; cancel >72h
   Pay Now: 5,099 + 15 + 254.95 = ₹5,368.95
   Refund = 4,354.95; Deduction = 1,014
   Case: COUP-068
   Scenario: Full Payment + Conditional; cancel ≤24h
   Deduction = 5,114; Refund = 254.95
   Case: COUP-069
   Scenario: Full Payment + Conditional; cancel at 24h
   Same as above
   Case: COUP-070
   Scenario: Full Payment + Conditional; cancel after trek start
   Refund = 0; Deduction = 5,368.95
   BLOCK 4 — Mixed & Edge Cases (71–100)
   A. Coupons + Add-ons (71–80)
   Case: MIX-071
   Scenario: Full payment + Flat ₹500 coupon + Insurance; cancel >72h
   Inputs: Fare = 5,999 − 500 = 5,499; GST = 274.95; Fee 15; Insurance 150
   Pay Now: 5,499 + 15 + 274.95 + 150 = ₹5,938.95
   Expected Output:
   ●
   Deduction = Advance 999 + Fee 15 + Insurance 150 = 1,164
   ●
   Refund = 5,938.95 − 1,164 = ₹4,774.95
   Case: MIX-072
   Scenario: Full payment + Flat ₹500 coupon + Insurance; cancel ≤24h
   Expected Output:
   ●
   Deduction = 5,499 + 15 + 150 = ₹5,664
   ●
   Refund = GST 274.95
   Case: MIX-073
   Scenario: Full payment + 20% coupon + Free Cancellation; cancel >72h
   Inputs: Fare = 4,799; GST = 239.95; Fee 15; Add-on 200
   Pay Now: 4,799 + 15 + 239.95 + 200 = ₹5,253.95
   Expected Output:
   ●
   Deduction = Fee 15 + Add-on 200 = 215
   ●
   Refund = 5,253.95 − 215 = ₹5,038.95
   Case: MIX-074
   Scenario: Full payment + 20% coupon + Free Cancellation; cancel ≤24h
   Expected Output:
   ●
   Deduction = 999 + 15 + 200 = 1,214
   ●
   Refund = 5,253.95 − 1,214 = ₹4,039.95
   Case: MIX-075
   Scenario: Advance-only + Group coupon (10%) + Free Cancellation; cancel >72h
   Fare = 5,399; GST = 269.95
   Pay Now: 999 + 15 + 269.95 + 200 = ₹1,483.95
   Expected Output:
   ●
   Deduction = 15 + 200 = 215
   ●
   Refund = 999 + 269.95 = 1,268.95
   Case: MIX-076
   Scenario: Advance-only + Group coupon (10%) + Free Cancellation; cancel ≤24h
   Expected Output:
   ●
   Deduction = 999 + 15 + 200 = 1,214
   ●
   Refund = GST 269.95
   Case: MIX-077
   Scenario: Full payment + Conditional coupon (15%) + Insurance + Free Cancellation; cancel
   > 72h
   > Fare = 5,099; GST = 254.95
   > Pay Now: 5,099 + 15 + 254.95 + 150 + 200 = ₹5,718.95
   > Expected Output:
   > ●
   > Deduction = 15 + 150 + 200 = 365
   > ●
   > Refund = 5,718.95 − 365 = ₹5,353.95
   > Case: MIX-078
   > Scenario: Full payment + Conditional coupon + Insurance + Free Cancellation; cancel ≤24h
   > Expected Output:
   > ●
   > Deduction = 999 + 15 + 150 + 200 = 1,364
   > ●
   > Refund = 5,718.95 − 1,364 = ₹4,354.95
   > Case: MIX-079
   > Scenario: Advance-only + Up-To coupon (20% up to ₹500) + Insurance; cancel >72h
   > Fare = 5,499; GST = 274.95
   > Pay Now: 999 + 15 + 274.95 + 150 = ₹1,438.95
   > Expected Output:
   > ●
   > Deduction = 999 + 15 + 150 = 1,164
   > ●
   > Refund = GST 274.95
   > Case: MIX-080
   > Scenario: Advance-only + Up-To coupon + Insurance; cancel ≤24h
   > Expected Output:
   > ●
   > ●
   > Deduction = 1,164
   > Refund = GST 274.95
   > B. Operator-Initiated Cancellations (81–85)
   > Case: MIX-081
   > Scenario: Operator cancels trek (force majeure), full payment user
   > Expected Output:
   > ●
   > Refund = Full fare + GST
   > ●
   > Deduction = 0 (add-ons refunded only if not activated with insurer — else insurer covers
   > separately)
   > Case: MIX-082
   > Scenario: Operator cancels trek, advance-only user
   > Expected Output:
   > ●
   > Refund = Advance + GST + Platform Fee
   > ●
   > Deduction = 0
   > Case: MIX-083
   > Scenario: Operator cancels trek but user had Free Cancellation add-on
   > Expected Output:
   > ●
   > Refund = Full paid (including add-on)
   > ●
   > Rule: since trek not delivered, even add-on refunded
   > Case: MIX-084
   > Scenario: Operator cancels trek, insurance was bought
   > Expected Output:
   > ●
   > ●
   > Refund = Trek fare + GST + Platform Fee
   > Insurance = refunded if not activated
   > Case: MIX-085
   > Scenario: Operator cancels trek after partial start (e.g., weather stop on day 2 of 5)
   > Expected Output:
   > ●
   > Partial refund pro-rated by unused days; GST adjusted proportionally
   > C. Multi-Trek Bookings (86–90)
   > Case: MIX-086
   > Scenario: User books 3 treks in one transaction, no coupon, cancels 1 trek >72h
   > Expected Output:
   > ●
   > Refund applies only to cancelled trek per policy
   > Case: MIX-087
   > Scenario: Group of 5 (with Group discount), cancels 2 people >72h
   > Expected Output:
   > ●
   > Cancelled trekkers refunded according to discount-adjusted fare
   > ●
   > Remaining fares unchanged
   > Case: MIX-088
   > Scenario: 2 treks booked, one with Insurance, one without, cancel >72h
   > Expected Output:
   > ●
   > Trek 1 (with insurance) → Deduct insurance, refund balance
   > ●
   > Trek 2 (without insurance) → Deduct advance, refund balance
   > Case: MIX-089
   > Scenario: Multi-trek, coupon applied across basket, cancel one trek
   > Expected Output:
   > ●
   > Discount re-applied proportionally to remaining treks
   > ●
   > Cancelled trek refund calculated on adjusted discounted price
   > Case: MIX-090
   > Scenario: Multi-trek booking, one trek cancelled ≤24h, one >72h
   > Expected Output:
   > ●
   > Trek 1 (≤24h) → no refund
   > ●
   > Trek 2 (>72h) → refund per rules
   > D. Payment & Refund Edge Cases (91–95)
   > Case: MIX-091
   > Scenario: User cancels, refund initiated, but payment method expired (old card)
   > Expected Output:
   > ●
   > Refund fails, system retries → fallback to manual refund method
   > Case: MIX-092
   > Scenario: Refund processed but bank dispute (chargeback) raised
   > Expected Output:
   > ●
   > Refund marked as complete; ops team must provide proof to bank
   > Case: MIX-093
   > Scenario: Partial payment settlement (gateway captured only half) then cancellation
   > Expected Output:
   > ●
   > Refund only against settled amount; balance auto-voided
   > Case: MIX-094
   > Scenario: Refund exceeds coupon-adjusted amount due to bug (over-refund risk)
   > Expected Output:
   > ●
   > System validation: refund ≤ (paid − deductions)
   > Case: MIX-095
   > Scenario: Refund pending >7 business days
   > Expected Output:
   > ●
   > Ops escalation triggered; audit log shows refund request ID
   > E. Timezone & Precision Edge Cases (96–100)
   > Case: MIX-096
   > Scenario: Trek start at Dec 31, 23:00 UTC; user cancels at Jan 1, 03:30 IST
   > Expected Output:
   > ●
   > System converts to UTC; calculates correctly as 24.5h before
   > Case: MIX-097
   > Scenario: Cancellation at exactly 24h 0m 0s vs 23h 59m 59s
   > Expected Output:
   > ●
   > First = no refund; second = refund (strict inequality)
   > Case: MIX-098
   > Scenario: User device shows different local time due to DST/offset
   > Expected Output:
   > ●
   > Refund slab based only on server UTC time
   > Case: MIX-099
   > Scenario: Cancel at 24h + 1 sec; treated as >24h
   > Expected Output:
   > ●
   > Deduction = advance only; refund balance
   > Case: MIX-100
   > Scenario: Cancel at trek start time
   > Expected Output:
   > ●
   > Refund = 0; strict cutoff
