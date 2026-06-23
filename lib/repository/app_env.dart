class AppEnv {
  // ─── LOCAL DEVELOPMENT ───────────────────────────────────────────────────────
  // For physical device: use your machine's LAN IP (run `ipconfig` to find it).
  // For Android emulator: use 10.0.2.2 instead of the LAN IP.
  // Switch to production block below before releasing.
  // ─────────────────────────────────────────────────────────────────────────────
  String apiBaseUrl = "http://10.229.194.22:3001";
  String socketUrl  = "http://10.229.194.22:3001";
  String imageUrl   = "http://10.229.194.22:3001/";

  // ─── PRODUCTION (uncomment to use) ──────────────────────────────────────────
  // String apiBaseUrl = "https://api.aorbotreks.co.in";
  // String socketUrl  = "https://api.aorbotreks.co.in";
  // String imageUrl   = "https://api.aorbotreks.co.in/";
  // ─────────────────────────────────────────────────────────────────────────────

  String razorpayKey = "rzp_test_SW9tLdKrLyka8y";
}
