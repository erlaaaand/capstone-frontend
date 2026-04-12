import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Akses semua env variable secara type-safe.
///
/// Semua value diambil dari file `.env.development` atau `.env.production`
/// yang di-load oleh [AppConfig] saat aplikasi pertama kali dijalankan.
class EnvConfig {
  EnvConfig._();

  // ── Backend NestJS ──────────────────────────────────────────────────────────

  /// Base URL API NestJS. Contoh: `http://localhost:3000/api/v1`
  static String get apiBaseUrl => _require('API_BASE_URL');

  /// Base URL aplikasi (untuk konstruksi URL storage lokal).
  static String get appBaseUrl => _require('APP_BASE_URL');

  // ── AI FastAPI Microservice ─────────────────────────────────────────────────

  /// Base URL FastAPI AI service. Contoh: `http://localhost:8000`
  static String get fastapiBaseUrl => _require('FASTAPI_BASE_URL');

  /// API Key untuk AI service (scope: predict, health).
  static String get fastapiApiKey => _require('FASTAPI_API_KEY');

  // ── Storage ─────────────────────────────────────────────────────────────────

  /// Provider storage aktif: `local` atau `s3`.
  static String get storageProvider => _get('STORAGE_PROVIDER', 'local');

  /// Apakah storage menggunakan S3.
  static bool get isS3Storage => storageProvider == 's3';

  // ── Durian Classes ──────────────────────────────────────────────────────────

  /// Daftar kode varietas durian yang didukung AI model.
  /// Urutan WAJIB alphabetical sesuai CLASS_NAMES FastAPI.
  /// Contoh: `['D101', 'D13', 'D197', 'D2', 'D200', 'D24']`
  static List<String> get durianClasses =>
      _get('DURIAN_CLASSES', 'D101,D13,D197,D2,D200,D24')
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

  // ── Prediction Polling ──────────────────────────────────────────────────────

  /// Interval polling prediksi dalam milidetik. Default: 2000ms.
  static int get predictionPollIntervalMs =>
      int.tryParse(_get('PREDICTION_POLL_INTERVAL_MS', '2000')) ?? 2000;

  /// Maksimal jumlah percobaan polling sebelum timeout. Default: 15.
  static int get predictionPollMaxAttempts =>
      int.tryParse(_get('PREDICTION_POLL_MAX_ATTEMPTS', '15')) ?? 15;

  // ── Debug ───────────────────────────────────────────────────────────────────

  /// Aktifkan logging Dio. Default: false.
  static bool get enableLogging =>
      _get('ENABLE_LOGGING', 'false').toLowerCase() == 'true';

  // ── Helpers ─────────────────────────────────────────────────────────────────

  static String _require(String key) {
    final value = dotenv.env[key];
    if (value == null || value.isEmpty) {
      throw StateError(
        '[EnvConfig] Environment variable "$key" tidak ditemukan. '
        'Pastikan file .env sudah benar dan di-load sebelum app berjalan.',
      );
    }
    return value;
  }

  static String _get(String key, String fallback) =>
      dotenv.env[key]?.isNotEmpty == true ? dotenv.env[key]! : fallback;
}
