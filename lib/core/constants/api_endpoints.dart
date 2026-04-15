/// Semua path endpoint API NestJS.
///
/// Base URL TIDAK disertakan di sini — ditangani oleh [ApiClient] (Dio).
/// Gunakan helper method untuk path yang mengandung parameter dinamis.
class ApiEndpoints {
  ApiEndpoints._();

  // ── Auth ─────────────────────────────────────────────────────────────────
  // POST  /auth/register  → Register akun baru
  // POST  /auth/login     → Login, dapat JWT
  // GET   /auth/me        → Info user dari JWT aktif
  // POST  /auth/logout    → Logout (invalidasi sesi lokal)

  static const String register = '/auth/register';
  static const String login    = '/auth/login';
  static const String authMe   = '/auth/me';
  static const String logout   = '/auth/logout';

  // ── Users ────────────────────────────────────────────────────────────────
  // GET   /users/me       → Profil user sendiri (shortcut dari JWT)
  // GET   /users/:id      → Profil berdasarkan UUID
  // PATCH /users/:id      → Update nama / password

  static const String usersMe = '/users/me';
  static String userById(String id) => '/users/$id';

  // ── Storage ──────────────────────────────────────────────────────────────
  // POST   /storage/upload           → Upload gambar (multipart/form-data)
  // DELETE /storage/:encodedFileKey  → Hapus file (fileKey di-base64url encode)

  static const String storageUpload = '/storage/upload';

  /// [encodedFileKey] harus sudah di-encode base64url sebelum dikirim.
  /// Gunakan [Base64Utils.encodeFileKey].
  static String storageDelete(String encodedFileKey) =>
      '/storage/$encodedFileKey';

  // ── Predictions ──────────────────────────────────────────────────────────
  // POST  /predictions          → Buat prediksi baru (status awal: PENDING)
  // GET   /predictions/user/me  → List prediksi milik user (paginated)
  // GET   /predictions/:id      → Detail prediksi (untuk polling hasil)

  static const String predictions   = '/predictions';
  static const String predictionsMe = '/predictions/user/me';
  static String predictionById(String id) => '/predictions/$id';

  // ── AI Health ────────────────────────────────────────────────────────────
  // GET  /ai/status/current   → Snapshot status AI (REST, no auth)
  // GET  /ai/status           → Stream status AI via SSE (no auth)

  static const String aiStatusCurrent = '/ai/status/current';
  static const String aiStatusStream  = '/ai/status';
}