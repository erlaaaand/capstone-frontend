import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/core/router/app_router.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/features/auth/application/auth_bloc.dart';
import 'package:mobile_app/injection_container.dart';

/// Root widget aplikasi.
///
/// Menyediakan [AuthBloc] secara global agar dapat diakses oleh semua halaman
/// (SplashPage, LoginPage, RegisterPage, ProfilePage) tanpa harus di-provide
/// ulang per-route.
///
/// Menggunakan [MaterialApp.router] dengan [GoRouter] dari [AppRouter].
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // AuthBloc bersifat singleton dan di-provide di root agar
        // state autentikasi dapat diakses dari seluruh pohon widget.
        BlocProvider<AuthBloc>(
          create: (_) => sl<AuthBloc>(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Durian Classifier',
        debugShowCheckedModeBanner: false,

        // ── Theme ────────────────────────────────────────────────────────────
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,

        // ── Router ───────────────────────────────────────────────────────────
        routerConfig: sl<AppRouter>().router,
      ),
    );
  }
}
