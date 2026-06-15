
class AppEnv {
  // ─── LOCAL DEVELOPMENT ───────────────────────────────────────────────────────
  // Android emulator uses 10.0.2.2 to reach host machine's localhost.
  // For a physical device, replace with your machine's LAN IP (e.g. 192.168.1.X).
  // Switch to production block below before releasing.
  // ─────────────────────────────────────────────────────────────────────────────
  String apiBaseUrl = "http://127.0.0.1:3001";
  String socketUrl  = "http://127.0.0.1:3001";
  String imageUrl   = "http://127.0.0.1:3001/";

  // ─── PRODUCTION (uncomment to use) ──────────────────────────────────────────
  // String apiBaseUrl = "https://api.aorbotreks.co.in";
  // String socketUrl  = "https://api.aorbotreks.co.in";
  // String imageUrl   = "https://api.aorbotreks.co.in/";
  // ─────────────────────────────────────────────────────────────────────────────

  String razorpayKey = "rzp_test_SW9tLdKrLyka8y";
}