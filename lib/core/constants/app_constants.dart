import 'package:mobile_app/core/config/env_config.dart';

/// Konstanta aplikasi yang bersumber dari env atau nilai tetap.
class AppConstants {
  AppConstants._();

  // ── Storage ────────────────────────────────────────────────────────────
  /// Ukuran maksimal file upload dalam bytes (5 MB sesuai API spec).
  static const int maxUploadSizeBytes = 5 * 1024 * 1024;

  /// Tipe MIME yang diizinkan untuk upload (JPG, PNG, WebP).
  static const List<String> allowedMimeTypes = [
    'image/jpeg',
    'image/png',
    'image/webp',
  ];

  /// Ekstensi file yang diizinkan.
  static const List<String> allowedExtensions = ['jpg', 'jpeg', 'png', 'webp'];

  // ── Prediction Polling ──────────────────────────────────────────────────
  /// Interval polling status prediksi.
  static Duration get predictionPollInterval =>
      Duration(milliseconds: EnvConfig.predictionPollIntervalMs);

  /// Maksimal percobaan polling sebelum dinyatakan timeout.
  static int get predictionPollMaxAttempts =>
      EnvConfig.predictionPollMaxAttempts;

  // ── Durian Varieties ────────────────────────────────────────────────────
  /// Nama populer per kode varietas (sesuai Swagger & FastAPI CLASS_NAMES).
  static const Map<String, String> durianVarietyNames = {
    'D101': 'Durian D101',
    'D13':  'Durian D13',
    'D197': 'Musang King / Mao Shan Wang',
    'D2':   'Durian D2',
    'D200': 'Durian D200',
    'D24':  'Sultan / D24',
  };

  /// Daftar kode varietas dari env (alphabetical, sesuai model AI).
  static List<String> get durianClasses => EnvConfig.durianClasses;

  // ── Network ─────────────────────────────────────────────────────────────
  /// Timeout koneksi.
  static const Duration connectTimeout = Duration(seconds: 15);

  /// Timeout menerima respons.
  static const Duration receiveTimeout = Duration(seconds: 30);

  /// Timeout kirim data (untuk upload file).
  static const Duration sendTimeout = Duration(seconds: 60);

  // ── Pagination ──────────────────────────────────────────────────────────
  /// Jumlah item per halaman untuk list prediksi.
  static const int defaultPageSize = 10;

  // ── UI ──────────────────────────────────────────────────────────────────
  /// Durasi animasi standar.
  static const Duration animationDuration = Duration(milliseconds: 250);

  /// Durasi snackbar tampil.
  static const Duration snackBarDuration = Duration(seconds: 3);
}
