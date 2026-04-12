/// Semua nama rute dan path yang digunakan di [AppRouter].
///
/// Pisahkan `name` (untuk navigasi via `context.goNamed`) dan
/// `path` (untuk deklarasi route di GoRouter).
class RouteNames {
  RouteNames._();

  // ── Auth ─────────────────────────────────────────────────────────────────
  static const String splash   = 'splash';
  static const String login    = 'login';
  static const String register = 'register';

  // ── Main Shell ────────────────────────────────────────────────────────────
  static const String shell    = 'shell';

  // ── Home / Scan ───────────────────────────────────────────────────────────
  static const String scan     = 'scan';

  // ── Prediction ────────────────────────────────────────────────────────────
  static const String predictionResult  = 'prediction-result';
  static const String predictionHistory = 'prediction-history';

  // ── Profile ───────────────────────────────────────────────────────────────
  static const String profile  = 'profile';
}

class RoutePaths {
  RoutePaths._();

  static const String splash   = '/';
  static const String login    = '/login';
  static const String register = '/register';

  // Shell wraps semua halaman yang butuh BottomNavigationBar
  static const String shell    = '/app';
  static const String scan     = '/app/scan';
  static const String predictionHistory = '/app/history';
  static const String profile  = '/app/profile';

  // Sub-route dari scan
  static const String predictionResult  = '/app/scan/result/:predictionId';

  static String predictionResultPath(String id) =>
      '/app/scan/result/$id';
}
