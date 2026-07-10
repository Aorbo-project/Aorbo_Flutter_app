class AppEnv {
  // ─── PRODUCTION ──────────────────────────────────────────────────────────────
  String apiBaseUrl = "https://api.aorbotreks.co.in";
  String socketUrl  = "https://api.aorbotreks.co.in";
  String imageUrl   = "https://api.aorbotreks.co.in/";

  // ─── LOCAL DEVELOPMENT (uncomment to use) ───────────────────────────────────
  // Android emulator uses 10.0.2.2 to reach host machine's localhost.
  // For a physical device, replace with your machine's LAN IP (e.g. 192.168.1.X).
  // Switch back to production block above before committing/releasing.
  // ─────────────────────────────────────────────────────────────────────────────
  // String apiBaseUrl = "http://192.168.29.60:3001";
  // String socketUrl  = "http://192.168.29.60:3001";
  // String imageUrl   = "http://192.168.29.60:3001/";

  String razorpayKey = "rzp_test_TBii9P0UpWmSoW";
}