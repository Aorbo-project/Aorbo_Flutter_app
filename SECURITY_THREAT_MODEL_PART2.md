# 🛡️ Aoerbo Trek — Risk Matrix, Blueprints & Checklists

**Continuation of [SECURITY_AUDIT_REPORT.md](./SECURITY_AUDIT_REPORT.md)**

---

## Prioritized Risk Matrix

| # | Vulnerability | Severity | Exploitability | Business Impact | Priority | Found in Code |
|---|-------------|----------|---------------|----------------|----------|--------------|
| 1 | OTP returned in API response | 🔴 CRITICAL | Trivial | Full account takeover | **P0 — FIX NOW** | ✅ Line 330 |
| 2 | Hardcoded JWT secret fallback | 🔴 CRITICAL | Trivial | Full system compromise | **P0 — FIX NOW** | ✅ Lines 12, 21 |
| 3 | CORS allow all origins | 🔴 CRITICAL | Easy | Data theft, CSRF | **P0 — FIX NOW** | ✅ app.js:61,79 |
| 4 | No rate limiting on any endpoint | 🔴 CRITICAL | Easy | Brute force, DoS, SMS drain | **P0 — FIX NOW** | ✅ No middleware |
| 5 | Math.random() for OTP | 🔴 HIGH | Medium | OTP prediction | **P1 — This Sprint** | ✅ Line 302 |
| 6 | 7-day JWT with no revocation | 🟠 HIGH | Medium | Stolen token abuse | **P1 — This Sprint** | ✅ Line 749 |
| 7 | Phone/email enumeration | 🟠 HIGH | Easy | Privacy leak, phishing | **P1 — This Sprint** | ✅ Lines 328, 109 |
| 8 | OTP race condition | 🟠 HIGH | Medium | Double session creation | **P1 — This Sprint** | ✅ Verify flow |
| 9 | Inventory race condition | 🔴 CRITICAL | Medium | Overbooking, revenue loss | **P1 — This Sprint** | Likely |
| 10 | Commented-out error handling | 🟠 HIGH | N/A | Unhandled crashes | **P1 — This Sprint** | ✅ verifyOtpOLD |
| 11 | No IDOR protection verified | 🔴 CRITICAL | Easy | Cross-vendor data access | **P1 — Audit** | Needs audit |
| 12 | Price tampering (client trust) | 🔴 CRITICAL | Easy | Revenue loss | **P1 — Audit** | Needs audit |
| 13 | Payment webhook verification | 🔴 CRITICAL | Medium | Free bookings | **P1 — Audit** | Needs audit |
| 14 | File upload extension bypass | 🟠 HIGH | Medium | RCE via web shell | **P2 — Next Sprint** | Partial filter |
| 15 | API docs endpoint exposed | 🟡 MEDIUM | Trivial | Recon aid | **P2 — Next Sprint** | ✅ app.js:227 |
| 16 | .env in project root | 🟠 HIGH | Depends | Secret exposure | **P2 — Verify** | ✅ .env exists |
| 17 | Mass assignment risk | 🟠 HIGH | Easy | Privilege escalation | **P2 — Next Sprint** | Needs audit |
| 18 | SVG XSS via uploads | 🟡 MEDIUM | Medium | Session hijack | **P3** | — |
| 19 | console.log in production | 🟡 LOW | N/A | Info leak in logs | **P3** | ✅ Multiple |
| 20 | OTP expiry (5min) | 🟡 LOW | N/A | Slightly wide window | **P3** | ✅ Line 303 |

---

## Professional Security Checklist

### 🔴 P0 — Fix Before Next Deploy

- [ ] Remove `otp_code` from sendOtp response (`authController.js:330`)
- [ ] Remove hardcoded JWT secret fallbacks (all files referencing `"vendor_jwt_secret"` and `"your-secret-key"`)
- [ ] Fail startup if `JWT_SECRET` env var is missing
- [ ] Restrict CORS to specific production domains
- [ ] Remove `res.header('Access-Control-Allow-Origin', '*')` from `app.js:79`
- [ ] Install and configure `express-rate-limit` on all routes
- [ ] Apply strict OTP rate limit: 5 requests/hr per mobile, 10/hr per IP

### 🟠 P1 — Fix This Sprint

- [ ] Replace `Math.random()` with `crypto.randomInt()` for OTP generation
- [ ] Reduce JWT expiry to 15min access + 7d refresh with rotation
- [ ] Implement token blacklist (Redis) for logout/password change
- [ ] Add failed OTP attempt counter (max 5 → expire OTP + lockout 15min)
- [ ] Fix OTP race condition with atomic update (`WHERE status = 'PENDING'` returning affected rows)
- [ ] Remove phone enumeration: return generic response from sendOtp
- [ ] Remove email enumeration from `checkEmailAndProceed`
- [ ] Remove or protect `verifyOtpOLD` and `sendOtpOLD` endpoints
- [ ] Fix commented-out error handling in `verifyOtpOLD` and `sendOtpOLD`
- [ ] Audit ALL controllers for IDOR — ensure ownership check on every resource access
- [ ] Verify all booking/payment flows use server-side prices from database
- [ ] Implement payment gateway webhook signature verification

### 🟡 P2 — Fix Next Sprint

- [ ] Remove or auth-protect `/api` documentation endpoint
- [ ] Remove `/test` endpoint from production
- [ ] Verify `.env` is in `.gitignore` and not committed to git history
- [ ] Rotate all secrets if `.env` was ever committed
- [ ] Enforce strict file upload whitelist (extension + MIME + magic bytes)
- [ ] Serve uploads from separate domain/CDN
- [ ] Implement mass assignment protection on all update endpoints
- [ ] Add database-level row locking for inventory (batch slot booking)
- [ ] Add CAPTCHA on OTP request after 2nd resend
- [ ] Implement request signing for mobile app API calls
- [ ] Add `helmet.js` middleware for security headers

### 🔵 P3 — Ongoing

- [ ] Remove all `console.log` from production code
- [ ] Reduce OTP expiry to 2-3 minutes
- [ ] Implement device fingerprinting for OTP binding
- [ ] Set up WAF (Web Application Firewall)
- [ ] Regular dependency audit (`npm audit`)
- [ ] Implement CSP (Content Security Policy) headers
- [ ] Add `X-Content-Type-Options: nosniff` to file responses

---

## Secure OTP Architecture Blueprint (Bank-Level)

```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│ Mobile App  │────▶│  API Gateway │────▶│  OTP Service │
│             │     │  (Rate Limit)│     │  (Isolated)  │
└─────────────┘     └──────────────┘     └──────┬───────┘
                                                │
                    ┌──────────────┐     ┌──────▼───────┐
                    │  SMS Gateway │◀────│    Redis      │
                    │ (MSG91/Twilio)│    │ (OTP Store)   │
                    └──────────────┘     └──────────────┘
```

### Architecture Rules

| Rule | Implementation |
|------|---------------|
| **OTP generation** | `crypto.randomInt(100000, 999999)` — CSPRNG only |
| **OTP storage** | Redis with TTL (120 seconds). Hash OTP: `SHA256(otp + salt)` |
| **OTP delivery** | SMS gateway ONLY. Never in API response |
| **Attempt limiting** | Max 5 verification attempts per OTP → auto-expire |
| **Resend limiting** | Progressive: 60s → 5min → 30min → block. Per-mobile AND per-IP |
| **Session binding** | OTP tied to `(mobile + device_id + ip_hash)` |
| **Race protection** | Atomic Redis `GETDEL` or DB `UPDATE...WHERE status='PENDING'` |
| **Expiry** | 120 seconds (2 minutes) |
| **Audit trail** | Log: mobile (masked), IP, device, timestamp, result. NO OTP value in logs |
| **Monitoring** | Alert on: >10 failures/mobile/hr, >50 OTP requests/IP/hr |

### Implementation (Node.js)

```javascript
const crypto = require('crypto');
const Redis = require('ioredis');
const redis = new Redis(process.env.REDIS_URL);

const OTP_TTL = 120; // 2 minutes
const MAX_ATTEMPTS = 5;
const MAX_RESEND_PER_HOUR = 5;

async function generateAndStoreOTP(mobile, deviceId, ipHash) {
  // Rate check
  const resendKey = `otp:resend:${mobile}`;
  const resendCount = await redis.incr(resendKey);
  if (resendCount === 1) await redis.expire(resendKey, 3600);
  if (resendCount > MAX_RESEND_PER_HOUR) throw new Error('RATE_LIMIT');

  // Generate
  const otp = crypto.randomInt(100000, 999999).toString();
  const salt = crypto.randomBytes(16).toString('hex');
  const hash = crypto.createHash('sha256').update(otp + salt).digest('hex');

  // Store in Redis (auto-expires)
  const otpKey = `otp:${mobile}`;
  await redis.hmset(otpKey, { hash, salt, attempts: 0, deviceId, ipHash });
  await redis.expire(otpKey, OTP_TTL);

  return otp; // Send via SMS only
}

async function verifyOTP(mobile, otpInput, deviceId, ipHash) {
  const otpKey = `otp:${mobile}`;
  const stored = await redis.hgetall(otpKey);
  if (!stored || !stored.hash) throw new Error('OTP_EXPIRED');

  // Attempt limit
  const attempts = parseInt(stored.attempts) + 1;
  if (attempts > MAX_ATTEMPTS) {
    await redis.del(otpKey);
    throw new Error('MAX_ATTEMPTS');
  }
  await redis.hset(otpKey, 'attempts', attempts);

  // Device/IP binding
  if (stored.deviceId !== deviceId || stored.ipHash !== ipHash) {
    throw new Error('DEVICE_MISMATCH');
  }

  // Verify hash
  const hash = crypto.createHash('sha256').update(otpInput + stored.salt).digest('hex');
  if (hash !== stored.hash) throw new Error('INVALID_OTP');

  // Success — delete immediately (one-time use)
  await redis.del(otpKey);
  return true;
}
```

---

## API Hardening Best Practices

### Required Middleware Stack

```javascript
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const hpp = require('hpp');
const mongoSanitize = require('express-mongo-sanitize');
const xss = require('xss-clean');

// 1. Security headers
app.use(helmet());
app.use(helmet.contentSecurityPolicy({
  directives: { defaultSrc: ["'self'"], scriptSrc: ["'self'"], styleSrc: ["'self'", "'unsafe-inline'"] }
}));

// 2. Rate limiting (tiered)
app.use('/api/', rateLimit({ windowMs: 15*60*1000, max: 200 }));
app.use('/api/*/auth/', rateLimit({ windowMs: 15*60*1000, max: 15 }));

// 3. Parameter pollution protection
app.use(hpp());

// 4. Input sanitization
app.use(xss());

// 5. Request size limits (already have 50mb — reduce to 10mb)
app.use(express.json({ limit: '10mb' }));

// 6. Disable X-Powered-By
app.disable('x-powered-by');
```

### Per-Endpoint Rules

| Endpoint Category | Max Rate | Auth Required | Additional |
|-------------------|----------|--------------|------------|
| Auth (OTP/login) | 10/15min | No | CAPTCHA after 3rd |
| Read (GET) | 200/15min | Yes | Cache headers |
| Write (POST/PUT) | 50/15min | Yes | CSRF token |
| Admin | 100/15min | Yes + Admin role | IP whitelist |
| File upload | 10/hr | Yes | Size + type validation |
| Payment webhook | Unlimited | Signature verification | IP whitelist |

---

## Cloud Infrastructure Security Blueprint

```
┌──────────────────────────────────────────────────┐
│                  CDN / WAF Layer                  │
│         (Cloudflare / AWS CloudFront)            │
│    DDoS protection, Bot detection, Geo-blocking  │
└────────────────────┬─────────────────────────────┘
                     │
        ┌────────────▼──────────────┐
        │     Load Balancer         │
        │   (HTTPS termination)     │
        │   SSL/TLS 1.3 only       │
        └─────┬──────────┬─────────┘
              │          │
    ┌─────────▼──┐  ┌────▼─────────┐
    │  App Server │  │  App Server  │
    │  (Private)  │  │  (Private)   │
    └─────┬──────┘  └────┬─────────┘
          │              │
    ┌─────▼──────────────▼─────────┐
    │     Private Subnet           │
    │  ┌─────────┐  ┌──────────┐  │
    │  │  MySQL   │  │  Redis   │  │
    │  │ (No pub) │  │ (No pub) │  │
    │  └─────────┘  └──────────┘  │
    │  ┌─────────────────────┐    │
    │  │  Storage (Private)  │    │
    │  └─────────────────────┘    │
    └──────────────────────────────┘
```

### Infrastructure Checklist

| Control | Action | Status |
|---------|--------|--------|
| **Network** | Database in private subnet, no public IP | [ ] |
| **Network** | Redis in private subnet, auth enabled | [ ] |
| **Network** | App servers in private subnet behind LB | [ ] |
| **TLS** | TLS 1.3 only, disable SSLv3/TLS 1.0/1.1 | [ ] |
| **Firewall** | Security groups: allow only 443 inbound to LB | [ ] |
| **Firewall** | DB: allow only app server security group on 3306 | [ ] |
| **Storage** | S3/cloud storage: block public access | [ ] |
| **Storage** | Enable server-side encryption at rest | [ ] |
| **Secrets** | Use cloud secret manager (not .env files) | [ ] |
| **Secrets** | Rotate JWT secret every 90 days | [ ] |
| **IAM** | Principle of least privilege for service accounts | [ ] |
| **Logging** | Centralized logging (CloudWatch/Datadog) | [ ] |
| **Backup** | Automated daily DB backups, 30-day retention | [ ] |
| **Patching** | Auto-update OS and Node.js dependencies | [ ] |
| **Firebase** | Restrictive security rules (no public write) | [ ] |

---

## Continuous Monitoring Strategy

### Real-Time Alerts (Set Up Immediately)

| Alert | Condition | Channel |
|-------|-----------|---------|
| OTP brute force | >5 failed verifications / mobile / 15min | PagerDuty + SMS |
| Auth failures spike | >50 failed logins / 5min globally | Slack + Email |
| Rate limit triggered | >100 429 responses / 5min | Slack |
| Unusual admin access | Admin login from new IP or outside business hours | SMS + Email |
| Payment anomaly | Booking amount < minimum threshold | PagerDuty |
| Error rate spike | >1% 5xx responses | PagerDuty |
| SMS credit usage | >500 SMS / hour | Email |
| Disk/memory threshold | >80% usage | Slack |
| SSL certificate expiry | 30 days before expiry | Email |
| Dependency vulnerability | `npm audit` finds critical/high CVE | Slack |

### Weekly Review

- Review access logs for unusual patterns
- Check for new endpoints exposed accidentally
- Monitor JWT token usage patterns
- Review file upload logs for suspicious filenames
- Audit admin action logs

### Monthly Tasks

- Run dependency audit (`npm audit`)
- Review and rotate secrets
- Test backup restoration
- Review firewall rules
- Penetration test critical flows (auth, payment, booking)

---

## Red Team Testing Checklist

### Phase 1: Reconnaissance
- [ ] Enumerate all public endpoints (use `/api` endpoint response as starting point)
- [ ] Identify technology stack from response headers
- [ ] Discover hidden endpoints via wordlist brute-force
- [ ] Check for exposed `.env`, `.git`, `package.json`
- [ ] Scan for open ports (database, Redis, admin panel)
- [ ] Review Firebase configuration for misrules

### Phase 2: Authentication Testing
- [ ] OTP brute force (verify rate limiting works)
- [ ] OTP replay after expiry
- [ ] Test with old/legacy OTP endpoints (`sendOtpOLD`, `verifyOtpOLD`)
- [ ] JWT forgery with known fallback secrets
- [ ] JWT token reuse after logout
- [ ] Token expiry boundary testing

### Phase 3: Authorization Testing
- [ ] Access Vendor B's resources with Vendor A's token
- [ ] Access admin endpoints with vendor token
- [ ] Modify role in JWT payload
- [ ] Mass assignment on profile update
- [ ] Access bookings across vendors (IDOR)

### Phase 4: Business Logic Testing
- [ ] Book with modified prices
- [ ] Apply coupon twice / stack coupons
- [ ] Race condition: double-book last slot
- [ ] Cancel-and-rebook for refund arbitrage
- [ ] Manipulate payout amounts
- [ ] Forge payment confirmation webhook

### Phase 5: Injection & Upload Testing
- [ ] SQL injection on all user inputs
- [ ] Upload `.php`, `.jsp`, `.exe` files
- [ ] Upload SVG with embedded JavaScript
- [ ] Upload oversized files (beyond 5MB limit)
- [ ] Path traversal in filename (`../../etc/passwd`)

### Phase 6: Infrastructure Testing
- [ ] Verify database is not publicly accessible
- [ ] Check Redis access without auth
- [ ] Check S3/storage for public access
- [ ] Verify HTTPS everywhere (no HTTP fallback)
- [ ] Check for exposed admin panels
- [ ] Test WAF bypass techniques

### Recommended Tools

| Category | Tools |
|----------|-------|
| **Proxy/Scanner** | Burp Suite Pro, OWASP ZAP |
| **API Testing** | Postman, Insomnia, `httpie` |
| **Brute Force** | Burp Intruder, `ffuf`, `wfuzz` |
| **SQL Injection** | SQLMap |
| **Auth Testing** | Autorize (Burp), JWT.io, `jwt_tool` |
| **Port Scanning** | Nmap, Masscan |
| **Cloud Audit** | ScoutSuite, Prowler (AWS), CloudSploit |
| **Dependency Audit** | `npm audit`, Snyk, OWASP Dependency-Check |
| **Secret Scanning** | GitLeaks, TruffleHog |
| **Load Testing** | k6, Artillery |

---

> [!IMPORTANT]
> **Immediate Action Required:** The 4 P0 items (OTP in response, hardcoded JWT secrets, CORS wildcard, no rate limiting) should be fixed **before the next production deploy**. These are trivial to exploit and each independently leads to full account compromise.
