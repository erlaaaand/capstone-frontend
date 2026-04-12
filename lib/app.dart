import 'package:mobile_app/core/router/app_router.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/injection_container.dart';
import 'package:flutter/material.dart';

/// Root widget aplikasi.
///
/// Menggunakan [MaterialApp.router] dengan [GoRouter] dari [AppRouter].
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final router = sl<AppRouter>().router;

    return MaterialApp.router(
      title: 'Durian Classifier',
      debugShowCheckedModeBanner: false,

      // ── Theme ──────────────────────────────────────────────────────────────
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,

      // ── Router ─────────────────────────────────────────────────────────────
      routerConfig: router,
    );
  }
}
