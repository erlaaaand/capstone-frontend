import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  EnvConfig._();

  // ── Backend NestJS ──────────────────────────────────────────────────────────
  static String get apiBaseUrl => _require('API_BASE_URL');
  static String get appBaseUrl => _require('APP_BASE_URL');

  // ── AI FastAPI Microservice ─────────────────────────────────────────────────
  static String get fastapiBaseUrl => _require('FASTAPI_BASE_URL');
  static String get fastapiApiKey => _require('FASTAPI_API_KEY');

  // ── Storage ─────────────────────────────────────────────────────────────────
  static String get storageProvider => _get('STORAGE_PROVIDER', 'local');
  static bool get isS3Storage => storageProvider == 's3';

  // ── Durian Classes ──────────────────────────────────────────────────────────
  static List<String> get durianClasses =>
      _get('DURIAN_CLASSES', 'D13,D197,D2,D24')
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

  // ── Debug ───────────────────────────────────────────────────────────────────
  static bool get enableLogging =>
      _get('ENABLE_LOGGING', 'false').toLowerCase() == 'true';

  // ── Helpers ─────────────────────────────────────────────────────────────────
  static String _require(String key) {
    final value = dotenv.env[key];
    if (value == null || value.isEmpty) {
      throw StateError(
        '[EnvConfig] Environment variable "$key" not found. '
        'Make sure file .env is properly configured.',
      );
    }
    return value;
  }

  static String _get(String key, String fallback) =>
      dotenv.env[key]?.isNotEmpty == true ? dotenv.env[key]! : fallback;
}