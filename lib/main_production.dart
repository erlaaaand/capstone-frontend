import 'package:mobile_app/app.dart';
import 'package:mobile_app/core/config/app_config.dart';
import 'package:mobile_app/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await AppConfig.initialize(AppFlavor.production);
  await initializeDateFormatting('id_ID');
  await initDependencies();

  runApp(const App());
}
