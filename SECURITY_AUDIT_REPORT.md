# 🛡️ Aoerbo Trek Platform — Security Threat Model & Attack Simulation

**Classification:** CONFIDENTIAL | **Version:** 1.0 | **Date:** 2026-02-28  
**Platform:** Aoerbo Trek (Node.js + Sequelize + SQL)  
**Prepared by:** Senior Cybersecurity Architect

---

## Executive Summary

This document provides a production-grade security threat model for the Aoerbo Trek platform. The analysis is based on **direct source code audit** and covers 12 attack categories with 50+ individual threat vectors. **Several critical vulnerabilities were identified in the live codebase** and are flagged with `🔴 FOUND IN CODE` markers.

> [!CAUTION]
> **Critical findings from code audit:**
> - OTP returned in API response (`otp_code` field — `authController.js:330`)
> - OTP generated with `Math.random()` — not cryptographically secure
> - Hardcoded JWT secret fallback: `"vendor_jwt_secret"` / `"your-secret-key"`
> - CORS configured as `origin: *` (allow all origins)
> - No rate-limiting middleware on any endpoint
> - 7-day JWT token expiry with no refresh token rotation
> - Commented-out error handling in `verifyOtpOLD` / `sendOtpOLD`
> - File uploads without strict extension whitelist enforcement
> - Debug `console.log` statements in production code paths

---

## Table of Contents

1. [Authentication Attacks](#1-authentication-attacks)
2. [Account Takeover Attacks](#2-account-takeover-attacks)
3. [Session Attacks](#3-session-attacks)
4. [Broken Access Control](#4-broken-access-control)
5. [API Attacks](#5-api-attacks)
6. [Business Logic Attacks](#6-business-logic-attacks)
7. [Payment Exploits](#7-payment-exploits)
8. [File Upload Vulnerabilities](#8-file-upload-vulnerabilities)
9. [Injection Attacks](#9-injection-attacks)
10. [Infrastructure Risks](#10-infrastructure-risks)
11. [Enumeration Attacks](#11-enumeration-attacks)
12. [Rate Limit Abuse](#12-rate-limit-abuse)

---

## 1. Authentication Attacks

### 1.1 OTP Brute Force

| Field | Detail |
|-------|--------|
| **Severity** | 🔴 CRITICAL |
| **Status** | 🔴 FOUND IN CODE |

**Attack Scenario:** Attacker sends all 999,999 combinations to `/api/vendor/auth/verify-otp` to guess the 6-digit OTP.

**Attack Flow:**
1. Trigger OTP via `POST /api/vendor/auth/send-otp` with victim's mobile
2. Script iterates 100000–999999 against `POST /api/vendor/auth/verify-otp`
3. No rate limiting exists → all attempts accepted
4. Attacker receives JWT token on correct guess

**Codebase Evidence:**
- `authController.js:302` — OTP is 6-digit: `Math.floor(100000 + Math.random() * 900000)`
- No failed-attempt counter on `verifyOtp`
- No IP-based or device-based lockout

**Mitigation:**
```javascript
// Add to verifyOtp - BEFORE OTP lookup
const failedKey = `otp_fail:${mobile}`;
const failedCount = await redis.incr(failedKey);
await redis.expire(failedKey, 900); // 15min window

if (failedCount > 5) {
  await UserOtp.update({ status: "EXPIRED" }, { where: { mobile, status: "PENDING" } });
  return res.status(429).json({ status: false, message: "Too many attempts. Request new OTP." });
}
// On SUCCESS: await redis.del(failedKey);
```

**Detection:** Alert on >5 OTP verification failures per mobile per 15 minutes.  
**Tools:** Burp Suite Intruder, custom Python script, OWASP ZAP

---

### 1.2 OTP Returned in API Response

| Field | Detail |
|-------|--------|
| **Severity** | 🔴 CRITICAL |
| **Status** | 🔴 FOUND IN CODE — `authController.js:330` |

**Attack Scenario:** The `sendOtp` endpoint returns the OTP in the response body. Any attacker can read it from the network response.

**Codebase Evidence:**
```javascript
// authController.js:325-331
return res.json({
    status: true,
    message: user ? "OTP sent for login" : "OTP sent for onboarding",
    is_registered: !!user,
    resend_count: resendCount + 1,
    otp_code: otp // ← CRITICAL: Remove in production
});
```

**Mitigation:** Remove `otp_code` from response immediately. Use SMS gateway (MSG91, Twilio) to deliver OTP only via SMS.

---

### 1.3 Predictable OTP Generation

| Field | Detail |
|-------|--------|
| **Severity** | 🔴 HIGH |
| **Status** | 🔴 FOUND IN CODE — `authController.js:302` |

**Attack Scenario:** `Math.random()` is not cryptographically secure. Attackers can predict future OTPs if they observe enough samples.

**Mitigation:**
```javascript
const crypto = require('crypto');
const otp = crypto.randomInt(100000, 999999);
```

---

### 1.4 OTP Replay Attack

| Field | Detail |
|-------|--------|
| **Severity** | 🟠 HIGH |

**Attack Scenario:** Attacker intercepts a valid OTP and replays it after the legitimate user's session.

**Current Protection:** OTP status set to `VERIFIED` after use (line 644) — **partial protection**.

**Gap:** No device fingerprint or request-ID binding. OTP is not tied to the session that requested it.

**Mitigation:** Bind OTP to `(mobile + device_id + request_nonce)`. Store `request_nonce` with OTP record, require it on verification.

---

### 1.5 SMS Flooding / OTP Draining

| Field | Detail |
|-------|--------|
| **Severity** | 🟠 HIGH |
| **Status** | 🟡 PARTIALLY MITIGATED |

**Current Protection:** `sendOtp` has a progressive delay (1min → 5min → 1hr → 1day → block). But it counts **all historical OTPs** for that mobile — not time-windowed.

**Gap:** An attacker can target different mobile numbers. No IP-based throttling exists.

**Mitigation:** Add per-IP rate limiting: max 10 OTP requests per IP per hour. Add CAPTCHA after 2nd resend.

---

### 1.6 OTP Race Condition

| Field | Detail |
|-------|--------|
| **Severity** | 🟠 HIGH |

**Attack Scenario:** Two concurrent `verifyOtp` requests with the same valid OTP. Both find `status: PENDING` before either updates to `VERIFIED`. Both get JWT tokens (double-login).

**Mitigation:**
```javascript
const [updatedRows] = await UserOtp.update(
  { status: "VERIFIED" },
  { where: { id: otpRecord.id, status: "PENDING" } }
);
if (updatedRows === 0) {
  return res.status(401).json({ status: false, message: "OTP already used" });
}
```

---

### 1.7 Long OTP Expiry

| Field | Detail |
|-------|--------|
| **Severity** | 🟡 MEDIUM |
| **Status** | 🔴 FOUND IN CODE |

**Current:** 5 minutes (`authController.js:303`). **Recommendation:** Reduce to 2–3 minutes for production.

---

### 1.8 Session Not Bound to OTP

| Field | Detail |
|-------|--------|
| **Severity** | 🟠 HIGH |

**Attack Scenario:** After OTP verification, the JWT is generated without binding to the specific OTP session. An attacker who obtains the JWT has full access for 7 days.

**Mitigation:** Include `otp_session_id` in JWT claims. Implement refresh token rotation with short-lived access tokens (15min) + long-lived refresh tokens (7d with rotation).

---

## 2. Account Takeover Attacks

### 2.1 Credential Stuffing (Vendor Login)

| Field | Detail |
|-------|--------|
| **Severity** | 🟠 HIGH |

**Attack Scenario:** `login_old` endpoint accepts email/password. Attacker uses leaked credential databases to attempt mass login.

**Current Protection:** None — no failed login counter, no CAPTCHA, no account lockout.

**Mitigation:**
- Max 5 failed logins per account per 15 minutes → temporary lockout
- CAPTCHA after 3rd failure
- Notify user via email/SMS on login from new device

**Detection:** Monitor for >10 failed logins from same IP within 5 minutes.

---

### 2.2 Password Spraying

| Field | Detail |
|-------|--------|
| **Severity** | 🟡 MEDIUM |

**Attack Scenario:** Attacker tries common passwords against many vendor accounts to avoid per-account lockout.

**Mitigation:** Global rate limit on login endpoint per IP. Enforce minimum password complexity (12+ chars, mixed case, symbols). Monitor login patterns across accounts from the same IP.

---

## 3. Session Attacks

### 3.1 Hardcoded JWT Secret Fallback

| Field | Detail |
|-------|--------|
| **Severity** | 🔴 CRITICAL |
| **Status** | 🔴 FOUND IN CODE |

**Codebase Evidence:**
```javascript
// authController.js:12
const JWT_SECRET = process.env.JWT_SECRET || "vendor_jwt_secret";

// customerAuthMiddleware.js:21
jwt.verify(token, process.env.JWT_SECRET || "your-secret-key");
```

**Attack Scenario:** If `JWT_SECRET` env var is unset, anyone can forge valid JWTs using the known fallback secret.

**Mitigation:** Remove all fallback secrets. Fail hard if `JWT_SECRET` is not set:
```javascript
const JWT_SECRET = process.env.JWT_SECRET;
if (!JWT_SECRET) throw new Error("FATAL: JWT_SECRET not configured");
```

---

### 3.2 Overly Long JWT Expiry

| Field | Detail |
|-------|--------|
| **Severity** | 🟠 HIGH |
| **Status** | 🔴 FOUND IN CODE — 7 days |

**Mitigation:** Access token: 15 minutes. Refresh token: 7 days with rotation. Implement token blacklist for logout.

---

### 3.3 No Token Revocation

| Field | Detail |
|-------|--------|
| **Severity** | 🟠 HIGH |

**Attack Scenario:** Stolen JWTs remain valid for 7 days. No mechanism to invalidate tokens on logout, password change, or suspicious activity.

**Mitigation:** Implement Redis-based token blacklist. Add `jti` claim to JWTs. On logout/password change, blacklist the `jti`.

---

### 3.4 CORS Misconfiguration

| Field | Detail |
|-------|--------|
| **Severity** | 🔴 CRITICAL |
| **Status** | 🔴 FOUND IN CODE — `app.js:61,79` |

**Codebase Evidence:**
```javascript
// app.js:61
origin: true, // Allow all origins temporarily

// app.js:79
res.header('Access-Control-Allow-Origin', '*');
```

**Attack Scenario:** Any malicious website can make authenticated API requests on behalf of logged-in users (CSRF/data theft).

**Mitigation:**
```javascript
const corsOptions = {
  origin: ['https://admin.aoerbotrek.com', 'https://vendor.aoerbotrek.com'],
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
};
```

---

## 4. Broken Access Control

### 4.1 IDOR / BOLA (Broken Object-Level Authorization)

| Field | Detail |
|-------|--------|
| **Severity** | 🔴 CRITICAL |

**Attack Scenario:** Vendor A accesses Vendor B's bookings by changing `vendor_id` or `booking_id` in API requests.

**Attack Flow:**
1. Vendor A is authenticated with `vendor.id = 5`
2. Sends `GET /api/vendor/bookings/123` (belongs to vendor 7)
3. If controller doesn't validate ownership → data leak

**Mitigation:** Every controller must verify `req.user.id === resource.vendor_id`:
```javascript
const booking = await Booking.findByPk(req.params.id);
if (booking.vendor_id !== req.user.id) {
  return res.status(403).json({ message: "Forbidden" });
}
```

**Tools:** Autorize (Burp extension), manual testing with two vendor accounts.

---

### 4.2 Privilege Escalation

| Field | Detail |
|-------|--------|
| **Severity** | 🔴 CRITICAL |

**Attack Scenario:** Vendor modifies JWT payload to include `role: "admin"` and accesses `/api/admin/*` endpoints.

**Current Risk:** JWT claims include `role: "vendor"` but if the admin middleware only checks the JWT claim without a DB lookup, forged tokens work.

**Mitigation:** Always verify role from database, not JWT claims alone:
```javascript
const user = await User.findByPk(decoded.user_id, { include: Role });
if (user.Role.name !== 'admin') return res.status(403).json({...});
```

---

### 4.3 Mass Assignment

| Field | Detail |
|-------|--------|
| **Severity** | 🟠 HIGH |

**Attack Scenario:** Attacker sends `{ "status": "active", "role_id": 1 }` in profile update to escalate privileges.

**Mitigation:** Explicitly whitelist allowed fields:
```javascript
const allowed = ['name', 'phone', 'company_info'];
const updates = {};
allowed.forEach(f => { if (req.body[f] !== undefined) updates[f] = req.body[f]; });
await Vendor.update(updates, { where: { id: req.user.id } });
```

---

## 5. API Attacks

### 5.1 API Documentation Exposure

| Field | Detail |
|-------|--------|
| **Severity** | 🟡 MEDIUM |
| **Status** | 🔴 FOUND IN CODE — `app.js:227-264` |

**Issue:** `GET /api` returns full endpoint documentation including all routes. Useful for attackers to discover attack surface.

**Mitigation:** Remove this endpoint in production or protect it behind admin auth.

---

### 5.2 Debug/Test Endpoints in Production

| Field | Detail |
|-------|--------|
| **Severity** | 🟡 MEDIUM |
| **Status** | 🔴 FOUND IN CODE |

**Endpoints found:** `GET /test`, `GET /api/vendor/treks/health`, `GET /health`

**Mitigation:** Disable `/test` in production. Keep `/health` but limit response to `{status: "OK"}` only.

---

### 5.3 Hidden Admin Endpoints

| Field | Detail |
|-------|--------|
| **Severity** | 🟠 HIGH |

**Attack Scenario:** Attacker discovers `/api/admin/*` routes (25+ endpoints) via directory brute-forcing.

**Mitigation:** Place admin API on a separate internal-only port or behind VPN/IP whitelist.

---

## 6. Business Logic Attacks

### 6.1 Coupon Stacking / Abuse

| Field | Detail |
|-------|--------|
| **Severity** | 🟠 HIGH |

**Attack Flow:**
1. Apply coupon `TREK50` for 50% off
2. In same request, manipulate `coupon_id` to stack another discount
3. Combined discount exceeds intended limit

**Mitigation:** Server-side enforce single coupon per booking. Validate total discount never exceeds max allowed percentage. Log all coupon usage with customer_id and IP.

---

### 6.2 Refund Abuse

| Field | Detail |
|-------|--------|
| **Severity** | 🔴 CRITICAL |

**Attack Flow:**
1. Book trek, pay full amount
2. Immediately cancel → get refund
3. Repeat to drain vendor payouts or exploit refund timing gaps

**Mitigation:** Minimum hold period before cancellation refund. Progressive refund reduction. Flag accounts with >3 cancellations in 30 days for manual review.

---

### 6.3 Inventory Race Condition

| Field | Detail |
|-------|--------|
| **Severity** | 🔴 CRITICAL |

**Attack Scenario:** Two users book the last slot simultaneously. Both `createBooking` requests see `available_slots = 1`, both proceed. Result: overbooking.

**Mitigation:**
```javascript
// Use database-level lock
const result = await sequelize.query(
  `UPDATE batches SET available_slots = available_slots - :count 
   WHERE id = :batchId AND available_slots >= :count`,
  { replacements: { batchId, count: travelerCount } }
);
if (result[1] === 0) throw new Error("Insufficient slots");
```

---

### 6.4 Vendor Payout Manipulation

| Field | Detail |
|-------|--------|
| **Severity** | 🔴 CRITICAL |

**Attack Scenario:** Compromised vendor account modifies bank details, then triggers payout to attacker's account.

**Mitigation:** Bank detail changes require admin approval + OTP verification. Mandatory cooling period (48hrs) after bank change. Dual-approval for payouts above threshold.

---

## 7. Payment Exploits

### 7.1 Price Tampering

| Field | Detail |
|-------|--------|
| **Severity** | 🔴 CRITICAL |

**Attack Flow:**
1. Intercept `createBooking` request
2. Modify `price_per_person` from ₹5000 to ₹1
3. If server trusts client-supplied price → booking at ₹1

**Mitigation:** **Never trust client-supplied prices.** Always fetch price from database:
```javascript
const trek = await Trek.findByPk(trekId);
const serverPrice = trek.price_per_person;
const totalAmount = serverPrice * travelerCount;
```

---

### 7.2 Payment Confirmation Bypass

| Field | Detail |
|-------|--------|
| **Severity** | 🔴 CRITICAL |

**Attack Scenario:** Attacker sends fake payment success webhook to confirm booking without actual payment.

**Mitigation:** Always verify payment with payment gateway server-side:
```javascript
const paymentVerified = await razorpay.payments.fetch(paymentId);
if (paymentVerified.status !== 'captured' || paymentVerified.amount !== expectedAmount) {
  throw new Error("Payment verification failed");
}
```

Validate webhook signatures using the gateway's secret key.

---

## 8. File Upload Vulnerabilities

### 8.1 Web Shell Upload

| Field | Detail |
|-------|--------|
| **Severity** | 🔴 CRITICAL |

**Current Code (`authController.js:807-817`):** File filter checks extension but uses regex — verify it blocks `.php`, `.jsp`, `.exe`, `.sh`.

**Mitigation:**
```javascript
fileFilter: (req, file, cb) => {
  const allowed = ['.jpg', '.jpeg', '.png', '.webp'];
  const ext = path.extname(file.originalname).toLowerCase();
  const mimeAllowed = ['image/jpeg', 'image/png', 'image/webp'];
  if (allowed.includes(ext) && mimeAllowed.includes(file.mimetype)) {
    cb(null, true);
  } else {
    cb(new Error('Only image files allowed'), false);
  }
};
```

Also: serve uploads from a separate domain/CDN. Never execute uploaded files.

---

### 8.2 SVG XSS

| Field | Detail |
|-------|--------|
| **Severity** | 🟠 HIGH |

**Attack Scenario:** Upload SVG containing `<script>alert(document.cookie)</script>`. When served, script executes in user's browser.

**Mitigation:** Block SVG uploads. If required, sanitize with DOMPurify server-side. Serve all uploads with `Content-Type: application/octet-stream` and `Content-Disposition: attachment`.

---

## 9. Injection Attacks

### 9.1 SQL Injection via Raw Queries

| Field | Detail |
|-------|--------|
| **Severity** | 🔴 CRITICAL |
| **Status** | 🟡 PARTIALLY AT RISK |

**Codebase Evidence:** `authController.js:153-155` uses parameterized queries (`replacements: [user.id]`) — **good**. But any raw query with string concatenation is vulnerable.

**Mitigation:** Audit all `sequelize.query()` calls. Enforce parameterized queries exclusively. Consider a linting rule to flag string concatenation in SQL.

**Tools:** SQLMap, Burp Suite Scanner

---

## 10. Infrastructure Risks

### 10.1 Environment Variable Exposure

| Field | Detail |
|-------|--------|
| **Severity** | 🔴 CRITICAL |
| **Status** | 🔴 `.env` file found in repo |

**Issue:** `.env` file (2597 bytes) present in project root. If committed to git, secrets are exposed.

**Mitigation:** Verify `.env` is in `.gitignore`. Rotate all secrets that may have been committed. Use cloud secret managers (AWS Secrets Manager, GCP Secret Manager).

---

### 10.2 Error Messages in Production

| Field | Detail |
|-------|--------|
| **Severity** | 🟡 MEDIUM |
| **Status** | 🟢 PARTIALLY HANDLED |

**Current:** `app.js:304` — error details only in development mode. **Good.** But `console.error` calls throughout code may expose info in logs.

---

### 10.3 Cloud Misconfigurations

| Field | Detail |
|-------|--------|
| **Severity** | 🔴 CRITICAL |

**Checklist:**
- [ ] S3/Cloud Storage buckets are private (no public access)
- [ ] Database ports (3306/5432) not exposed to internet
- [ ] Redis not publicly accessible
- [ ] SSH keys rotated regularly
- [ ] Firebase security rules properly configured
- [ ] No debug endpoints accessible from internet

---

## 11. Enumeration Attacks

### 11.1 Phone Number Discovery

| Field | Detail |
|-------|--------|
| **Severity** | 🟠 HIGH |
| **Status** | 🔴 FOUND IN CODE |

**Issue:** `sendOtp` returns `is_registered: true/false` (line 328) — reveals whether a phone number is registered.

**Mitigation:** Return identical response regardless of registration status:
```javascript
return res.json({ status: true, message: "If this number is registered, an OTP has been sent." });
```

---

### 11.2 Email Enumeration

| Field | Detail |
|-------|--------|
| **Severity** | 🟡 MEDIUM |
| **Status** | 🔴 FOUND IN CODE — `authController.js:105-110` |

**Issue:** `checkEmailAndProceed` explicitly returns `"Email already registered"` with `exists: true`.

**Mitigation:** Return generic response: `"If this email is available, you may proceed."`

---

## 12. Rate Limit Abuse

### 12.1 No Rate Limiting Middleware

| Field | Detail |
|-------|--------|
| **Severity** | 🔴 CRITICAL |
| **Status** | 🔴 FOUND IN CODE |

**Issue:** No `express-rate-limit` or equivalent middleware. All endpoints accept unlimited requests.

**Mitigation:**
```javascript
const rateLimit = require('express-rate-limit');

const apiLimiter = rateLimit({ windowMs: 15 * 60 * 1000, max: 100 });
const authLimiter = rateLimit({ windowMs: 15 * 60 * 1000, max: 10 });
const otpLimiter = rateLimit({ windowMs: 60 * 60 * 1000, max: 5 });

app.use('/api/', apiLimiter);
app.use('/api/vendor/auth/', authLimiter);
app.use('/api/v1/customer/auth/', otpLimiter);
```

---

### 12.2 SMS Credit Draining

| Field | Detail |
|-------|--------|
| **Severity** | 🟠 HIGH |

**Attack Scenario:** Attacker scripts OTP requests for thousands of different mobile numbers, draining SMS credits.

**Mitigation:** Per-IP limit on OTP requests (10/hour). CAPTCHA on OTP request. Monitor SMS gateway spend with alerts.

---

*Continued in [SECURITY_THREAT_MODEL_PART2.md](./SECURITY_THREAT_MODEL_PART2.md)*
