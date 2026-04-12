import 'package:mobile_app/app.dart';
import 'package:mobile_app/core/config/app_config.dart';
import 'package:mobile_app/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Lock orientasi ke portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 2. Load env.development + set flavor
  await AppConfig.initialize(AppFlavor.development);

  // 3. Inisialisasi locale Indonesia untuk intl
  await initializeDateFormatting('id_ID');

  // 4. Inisialisasi seluruh dependency injection
  await initDependencies();

  runApp(const App());
}
