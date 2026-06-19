import 'package:flutter_dotenv/flutter_dotenv.dart';

enum AppFlavor { development, production }
class AppConfig {
  AppConfig._();

  static AppFlavor _flavor = AppFlavor.development;

  static bool _initialized = false;
  static AppFlavor get flavor => _flavor;

  static bool get isDevelopment => _flavor == AppFlavor.development;
  static bool get isProduction => _flavor == AppFlavor.production;

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

  static const String appName = 'DurenKu';

  static String get displayVersion => isDevelopment ? 'DEV build' : '1.0.0';
}
