import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Flavor aplikasi.
enum AppFlavor { development, production }

/// Konfigurasi global aplikasi.
///
/// Di-inisialisasi sekali di `main_*.dart` sebelum [runApp].
/// Setelah itu semua layer boleh membaca via [AppConfig.flavor] dll.
class AppConfig {
  AppConfig._();

  static AppFlavor _flavor = AppFlavor.development;
  static bool _initialized = false;

  /// Flavor yang sedang berjalan.
  static AppFlavor get flavor => _flavor;

  /// Apakah sedang berjalan di mode development.
  static bool get isDevelopment => _flavor == AppFlavor.development;

  /// Apakah sedang berjalan di mode production.
  static bool get isProduction => _flavor == AppFlavor.production;

  /// Load env file sesuai flavor, lalu tandai sudah initialized.
  ///
  /// Harus dipanggil sebelum [runApp]:
  /// ```dart
  /// await AppConfig.initialize(AppFlavor.development);
  /// ```
  static Future<void> initialize(AppFlavor flavor) async {
    if (_initialized) return;

    _flavor = flavor;
    final envFile = switch (flavor) {
      AppFlavor.development => '.env.development',
      AppFlavor.production  => '.env.production',
    };

    await dotenv.load(fileName: envFile);
    _initialized = true;
  }

  /// Nama aplikasi yang tampil di UI.
  static const String appName = 'Durian Classifier';

  /// Versi tampilan (bukan dari pubspec, agar bisa di-override per flavor).
  static String get displayVersion => isDevelopment ? 'DEV build' : '1.0.0';
}
