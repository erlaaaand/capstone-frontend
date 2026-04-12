/// Key untuk [FlutterSecureStorage] dan [SharedPreferences].
///
/// Semua key dikumpulkan di sini agar tidak ada typo yang tersebar.
class StorageKeys {
  StorageKeys._();

  // ── Secure Storage (FlutterSecureStorage) ──────────────────────────────
  // Digunakan untuk data sensitif: JWT token, user session.

  /// JWT access token yang didapat dari login / register.
  static const String accessToken = 'secure_access_token';

  /// ID user yang sedang login (UUID).
  static const String userId = 'secure_user_id';

  /// Email user yang sedang login.
  static const String userEmail = 'secure_user_email';

  // ── Shared Preferences ─────────────────────────────────────────────────
  // Digunakan untuk preferensi UI yang tidak sensitif.

  /// Apakah user sudah pernah menyelesaikan onboarding.
  static const String hasSeenOnboarding = 'pref_has_seen_onboarding';

  /// Tema yang dipilih user: `system`, `light`, `dark`.
  static const String themeMode = 'pref_theme_mode';
}
