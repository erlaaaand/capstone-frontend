import 'package:mobile_app/core/router/route_guard.dart';
import 'package:mobile_app/core/router/route_names.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ── Page imports (akan diisi saat feature dibangun) ─────────────────────────
// import 'package:mobile_app/features/auth/presentation/pages/splash_page.dart';
// import 'package:mobile_app/features/auth/presentation/pages/login_page.dart';
// import 'package:mobile_app/features/auth/presentation/pages/register_page.dart';
// import 'package:mobile_app/features/prediction/presentation/pages/scan_page.dart';
// import 'package:mobile_app/features/prediction/presentation/pages/prediction_result_page.dart';
// import 'package:mobile_app/features/prediction/presentation/pages/prediction_history_page.dart';
// import 'package:mobile_app/features/user/presentation/pages/profile_page.dart';

/// Konfigurasi navigasi aplikasi menggunakan [GoRouter].
///
/// Gunakan via [AppRouter.router] yang di-inject ke [MaterialApp.router].
class AppRouter {
  AppRouter(this._guard);

  final RouteGuard _guard;

  late final GoRouter router = GoRouter(
    initialLocation: RoutePaths.splash,
    debugLogDiagnostics: true,
    redirect: (context, state) => _guard.redirect(state),
    routes: [
      // ── Splash ─────────────────────────────────────────────────────────
      GoRoute(
        path: RoutePaths.splash,
        name: RouteNames.splash,
        builder: (context, state) => const _PlaceholderPage(label: 'Splash'),
      ),

      // ── Auth ───────────────────────────────────────────────────────────
      GoRoute(
        path: RoutePaths.login,
        name: RouteNames.login,
        builder: (context, state) => const _PlaceholderPage(label: 'Login'),
      ),
      GoRoute(
        path: RoutePaths.register,
        name: RouteNames.register,
        builder: (context, state) =>
            const _PlaceholderPage(label: 'Register'),
      ),

      // ── Main Shell (dengan BottomNavigationBar) ─────────────────────────
      ShellRoute(
        builder: (context, state, child) => _ShellScaffold(child: child),
        routes: [
          // Scan / Home
          GoRoute(
            path: RoutePaths.scan,
            name: RouteNames.scan,
            builder: (context, state) =>
                const _PlaceholderPage(label: 'Scan'),
            routes: [
              GoRoute(
                path: 'result/:predictionId',
                name: RouteNames.predictionResult,
                builder: (context, state) {
                  final id = state.pathParameters['predictionId'] ?? '';
                  return _PlaceholderPage(label: 'Result ($id)');
                },
              ),
            ],
          ),

          // History
          GoRoute(
            path: RoutePaths.predictionHistory,
            name: RouteNames.predictionHistory,
            builder: (context, state) =>
                const _PlaceholderPage(label: 'History'),
          ),

          // Profile
          GoRoute(
            path: RoutePaths.profile,
            name: RouteNames.profile,
            builder: (context, state) =>
                const _PlaceholderPage(label: 'Profile'),
          ),
        ],
      ),
    ],

    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Halaman tidak ditemukan: ${state.uri}'),
      ),
    ),
  );
}

// ── Placeholder (dihapus saat feature dibangun) ─────────────────────────────

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(label)),
        body: Center(child: Text('$label Page\n(Coming soon)')),
      );
}

// ── Shell Scaffold (BottomNav placeholder) ────────────────────────────────

class _ShellScaffold extends StatelessWidget {
  const _ShellScaffold({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: child,
        bottomNavigationBar: NavigationBar(
          destinations: const [
            NavigationDestination(icon: Icon(Icons.camera_alt_outlined), label: 'Scan'),
            NavigationDestination(icon: Icon(Icons.history_outlined), label: 'Riwayat'),
            NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profil'),
          ],
        ),
      );
}
