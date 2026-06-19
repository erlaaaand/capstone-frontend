class ApiEndpoints {
  ApiEndpoints._();

  // ── Auth ─────────────────────────────────────────────────────────────────
  static const String register = '/auth/register';
  static const String login    = '/auth/login';
  static const String authMe   = '/auth/me';
  static const String logout   = '/auth/logout';

  // ── Users ────────────────────────────────────────────────────────────────
  static const String usersMe = '/users/me';
  static String userById(String id) => '/users/$id';

  // ── Storage ──────────────────────────────────────────────────────────────
  static const String storageUpload = '/storage/upload';
  static String storageDelete(String encodedFileKey) =>
      '/storage/$encodedFileKey';

  // ── Predictions ──────────────────────────────────────────────────────────
  static const String predictions   = '/predictions';
  static const String predictionsMe = '/predictions/user/me';
  static String predictionById(String id) => '/predictions/$id';

  // ── AI Health ────────────────────────────────────────────────────────────
  static const String aiStatusCurrent = '/ai/status/current';
  static const String aiStatusStream  = '/ai/status';
}