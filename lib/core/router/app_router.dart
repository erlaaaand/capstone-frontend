import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:mobile_app/core/router/route_guard.dart';
import 'package:mobile_app/core/router/route_names.dart';
import 'package:mobile_app/core/theme/app_colors.dart';
import 'package:mobile_app/injection_container.dart';

// ── Feature: Auth ─────────────────────────────────────────────────────────────
import 'package:mobile_app/features/auth/presentation/pages/splash_page.dart';
import 'package:mobile_app/features/auth/presentation/pages/login_page.dart';
import 'package:mobile_app/features/auth/presentation/pages/register_page.dart';

// ── Feature: Prediction ───────────────────────────────────────────────────────
import 'package:mobile_app/features/prediction/application/create_prediction/create_prediction_bloc.dart';
import 'package:mobile_app/features/prediction/application/prediction_list/prediction_list_bloc.dart';
import 'package:mobile_app/features/prediction/domain/entities/prediction.dart';
import 'package:mobile_app/features/prediction/presentation/pages/scan_page.dart';
import 'package:mobile_app/features/prediction/presentation/pages/prediction_history_page.dart';
import 'package:mobile_app/features/prediction/presentation/pages/prediction_result_page.dart';

// ── Feature: User ─────────────────────────────────────────────────────────────
import 'package:mobile_app/features/user/application/profile_bloc.dart';
import 'package:mobile_app/features/user/presentation/pages/profile_page.dart';

// ── Feature: AI Health ────────────────────────────────────────────────────────
import 'package:mobile_app/features/ai_health/application/ai_health_cubit.dart';

/// Konfigurasi navigasi aplikasi menggunakan [GoRouter].
///
/// Struktur rute:
/// ```
/// /                      → SplashPage (cek sesi)
/// /login                 → LoginPage
/// /register              → RegisterPage
/// /app/scan              → ScanPage          ─┐
/// /app/scan/result/:id   → PredictionResultPage │ ShellRoute
/// /app/history           → PredictionHistoryPage │ (BottomNav)
/// /app/profile           → ProfilePage        ─┘
/// ```
///
/// AuthBloc di-provide di root (App widget), sehingga semua halaman
/// dapat mengakses tanpa BlocProvider tambahan.
class AppRouter {
  AppRouter(this._guard);

  final RouteGuard _guard;

  late final GoRouter router = GoRouter(
    initialLocation: RoutePaths.splash,
    debugLogDiagnostics: true,
    redirect: (context, state) => _guard.redirect(state),
    routes: [
      // ── Splash ─────────────────────────────────────────────────────────────
      // AuthBloc diakses via context.read<AuthBloc>() dari provider di root.
      GoRoute(
        path: RoutePaths.splash,
        name: RouteNames.splash,
        builder: (context, state) => const SplashPage(),
      ),

      // ── Auth ────────────────────────────────────────────────────────────────
      // LoginPage & RegisterPage menggunakan BlocConsumer<AuthBloc> —
      // AuthBloc sudah tersedia dari MultiBlocProvider di App widget.
      GoRoute(
        path: RoutePaths.login,
        name: RouteNames.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: RoutePaths.register,
        name: RouteNames.register,
        builder: (context, state) => const RegisterPage(),
      ),

      // ── Main Shell ─────────────────────────────────────────────────────────
      // ShellRoute membungkus semua halaman yang memerlukan BottomNavigationBar.
      // AiHealthCubit di-provide di sini agar status AI tersedia selama
      // user berada di dalam shell (scan, riwayat, profil).
      ShellRoute(
        builder: (context, state, child) => BlocProvider<AiHealthCubit>(
          create: (_) => sl<AiHealthCubit>()
            ..fetchCurrentStatus()
            ..startStatusStream(),
          child: _ShellScaffold(
            location: state.matchedLocation,
            child: child,
          ),
        ),
        routes: [
          // ── Scan / Home ───────────────────────────────────────────────────
          GoRoute(
            path: RoutePaths.scan,
            name: RouteNames.scan,
            builder: (context, state) => BlocProvider<CreatePredictionBloc>(
              create: (_) => sl<CreatePredictionBloc>(),
              child: const ScanPage(),
            ),
            routes: [
              // Sub-route: hasil prediksi (dapat diakses dari scan & history)
              GoRoute(
                path: 'result/:predictionId',
                name: RouteNames.predictionResult,
                builder: (context, state) {
                  final id = state.pathParameters['predictionId'] ?? '';
                  final prediction = state.extra as Prediction?;
                  return PredictionResultPage(
                    predictionId: id,
                    prediction: prediction,
                  );
                },
              ),
            ],
          ),

          // ── History ───────────────────────────────────────────────────────
          GoRoute(
            path: RoutePaths.predictionHistory,
            name: RouteNames.predictionHistory,
            builder: (context, state) => BlocProvider<PredictionListBloc>(
              create: (_) => sl<PredictionListBloc>(),
              child: const PredictionHistoryPage(),
            ),
          ),

          // ── Profile ───────────────────────────────────────────────────────
          // ProfileBloc di-provide per-route (factory) agar fresh setiap
          // kali halaman dibuka. ProfilePage.initState akan dispatch
          // ProfileLoadRequested secara otomatis.
          GoRoute(
            path: RoutePaths.profile,
            name: RouteNames.profile,
            builder: (context, state) => BlocProvider<ProfileBloc>(
              create: (_) => sl<ProfileBloc>(),
              child: const ProfilePage(),
            ),
          ),
        ],
      ),
    ],

    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                color: AppColors.error, size: 48),
            const SizedBox(height: 16),
            Text(
              'Halaman tidak ditemukan',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.uri.toString(),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.goNamed(RouteNames.scan),
              child: const Text('Kembali ke Beranda'),
            ),
          ],
        ),
      ),
    ),
  );
}

// ── Shell Scaffold ─────────────────────────────────────────────────────────────

/// Scaffold utama yang membungkus halaman-halaman dalam ShellRoute.
///
/// Menampilkan [NavigationBar] di bagian bawah dan meng-highlight tab
/// yang sesuai berdasarkan [location] saat ini.
///
/// Navigasi antar tab dilakukan via [GoRouter.goNamed] sehingga GoRouter
/// mengelola back stack dengan benar.
class _ShellScaffold extends StatelessWidget {
  const _ShellScaffold({
    required this.location,
    required this.child,
  });

  final String location;
  final Widget child;

  int get _selectedIndex {
    if (location.startsWith(RoutePaths.predictionHistory)) return 1;
    if (location.startsWith(RoutePaths.profile)) return 2;
    return 0; // scan (default)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.goNamed(RouteNames.scan);
            case 1:
              context.goNamed(RouteNames.predictionHistory);
            case 2:
              context.goNamed(RouteNames.profile);
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.camera_alt_outlined),
            selectedIcon: Icon(Icons.camera_alt_rounded),
            label: 'Scan',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history_rounded),
            label: 'Riwayat',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
