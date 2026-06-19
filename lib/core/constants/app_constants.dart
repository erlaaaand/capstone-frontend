import 'package:mobile_app/core/config/env_config.dart';
class AppConstants {
  AppConstants._();

  // ── Storage ────────────────────────────────────────────────────────────
  static const int maxUploadSizeBytes = 10 * 1024 * 1024;

  static const List<String> allowedMimeTypes = [
    'image/jpeg',
    'image/png',
    'image/webp',
    'image/jpg'
  ];

  static const List<String> allowedExtensions = ['jpg', 'jpeg', 'png', 'webp'];

  // ── Prediction Polling ──────────────────────────────────────────────────
  static Duration get predictionPollInterval =>
      Duration(milliseconds: EnvConfig.predictionPollIntervalMs);

  static int get predictionPollMaxAttempts =>
      EnvConfig.predictionPollMaxAttempts;

  // ── Durian Varieties ────────────────────────────────────────────────────
  static const Map<String, String> durianVarietyNames = {
    'D13':  'Golden Bun',
    'D197': 'Musang King',
    'D2':   'Dato Nina',
    'D24':  'Sultan',
  };

  static List<String> get durianClasses => EnvConfig.durianClasses;

  // ── Network ─────────────────────────────────────────────────────────────
  static const Duration connectTimeout = Duration(seconds: 15);

  static const Duration receiveTimeout = Duration(seconds: 30);

  static const Duration sendTimeout = Duration(seconds: 60);

  // ── Pagination ──────────────────────────────────────────────────────────
  static const int defaultPageSize = 10;

  // ── UI ──────────────────────────────────────────────────────────────────
  static const Duration animationDuration = Duration(milliseconds: 250);

  static const Duration snackBarDuration = Duration(seconds: 3);
}
