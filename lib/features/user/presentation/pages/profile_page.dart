import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app/core/router/route_names.dart';
import 'package:mobile_app/core/theme/app_colors.dart';
import 'package:mobile_app/core/theme/app_dimensions.dart';
import 'package:mobile_app/core/theme/app_text_styles.dart';
import 'package:mobile_app/core/widgets/app_button.dart';
import 'package:mobile_app/core/widgets/app_error_widget.dart';
import 'package:mobile_app/core/widgets/app_loading_overlay.dart';
import 'package:mobile_app/core/widgets/app_snackbar.dart';
import 'package:mobile_app/features/auth/application/auth_bloc.dart';
import 'package:mobile_app/features/auth/application/auth_event.dart';
import 'package:mobile_app/features/user/application/profile_bloc.dart';
import 'package:mobile_app/features/user/application/profile_event.dart';
import 'package:mobile_app/features/user/application/profile_state.dart';
import 'package:mobile_app/features/user/domain/entities/user.dart';
import 'package:mobile_app/features/user/presentation/widgets/edit_profile_form.dart';
import 'package:mobile_app/features/user/presentation/widgets/profile_header.dart';

/// Halaman Profil.
///
/// Menampilkan:
/// - [ProfileHeader] dengan data user
/// - Form edit nama ([EditNameSection])
/// - Form ubah password ([EditPasswordSection])
/// - Tombol logout
///
/// [ProfileBloc] di-provide dari luar (injection container / app_router).
/// [AuthBloc] diakses untuk dispatch logout event.
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(const ProfileLoadRequested());
  }

  void _onLogout() {
    showDialog<bool>(
      context: context,
      builder: (_) => const _LogoutDialog(),
    ).then((confirmed) {
      if (confirmed == true && mounted) {
        context.read<AuthBloc>().add(const AuthLogoutRequested());
        context.goNamed(RouteNames.login);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listenWhen: (_, current) =>
          current is ProfileUpdateSuccess || current is ProfileFailure,
      listener: (context, state) {
        if (state is ProfileUpdateSuccess) {
          AppSnackBar.showSuccess(context, state.message);
        } else if (state is ProfileFailure && state.user != null) {
          // Hanya tampil snackbar saat error update (bukan error load awal).
          AppSnackBar.showError(context, state.failure.message);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Profil Saya'),
            backgroundColor: AppColors.background,
            scrolledUnderElevation: 0,
          ),
          body: switch (state) {
            ProfileInitial() || ProfileLoading() => const Center(
                child: AppLoadingIndicator(size: 40),
              ),
            ProfileFailure(user: null, failure: final failure) =>
              AppErrorWidget(
                failure: failure,
                onRetry: () => context
                    .read<ProfileBloc>()
                    .add(const ProfileLoadRequested()),
              ),
            _ => _buildContent(context, state),
          },
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, ProfileState state) {
    // Ambil user dari state apapun yang membawa data.
    final user = switch (state) {
      ProfileLoaded(user: final u)         => u,
      ProfileUpdating(user: final u)       => u,
      ProfileUpdateSuccess(user: final u)  => u,
      ProfileFailure(user: final u?)       => u,
      _ => null,
    };

    if (user == null) return const SizedBox.shrink();

    final isUpdating = state is ProfileUpdating;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.pagePaddingH,
            vertical: AppDimensions.pagePaddingV,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header ───────────────────────────────────────────────
              ProfileHeader(
                email: user.email,
                fullName: user.fullName,
                createdAt: user.createdAt,
                isActive: user.isActive,
              ),
              const SizedBox(height: AppDimensions.lg),

              // ── Edit Nama ────────────────────────────────────────────
              EditNameSection(user: user),
              const SizedBox(height: AppDimensions.md),

              // ── Edit Password ────────────────────────────────────────
              EditPasswordSection(userId: user.id),
              const SizedBox(height: AppDimensions.lg),

              // ── Info Akun ────────────────────────────────────────────
              _AccountInfoCard(user: user),
              const SizedBox(height: AppDimensions.lg),

              // ── Logout ───────────────────────────────────────────────
              AppDestructiveButton(
                label: 'Keluar',
                onPressed: isUpdating ? null : _onLogout,
                icon: Icons.logout_rounded,
              ),
              const SizedBox(height: AppDimensions.xl),
            ],
          ),
        ),

        // Overlay saat update sedang berjalan
        if (isUpdating)
          const AppLoadingOverlay(message: 'Menyimpan perubahan...'),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _AccountInfoCard — informasi read-only akun
// ─────────────────────────────────────────────────────────────────────────────

class _AccountInfoCard extends StatelessWidget {
  const _AccountInfoCard({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(AppDimensions.md),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppDimensions.xs),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusSm),
                  ),
                  child: const Icon(
                    Icons.info_outline_rounded,
                    size: AppDimensions.iconSm + 4,
                    color: AppColors.info,
                  ),
                ),
                const SizedBox(width: AppDimensions.sm),
                Text('Info Akun', style: AppTextStyles.titleLarge),
              ],
            ),
            const SizedBox(height: AppDimensions.md),
            const Divider(height: 1),
            const SizedBox(height: AppDimensions.sm),
            _InfoRow(
              label: 'Email',
              value: user.email,
              icon: Icons.email_outlined,
            ),
            const SizedBox(height: AppDimensions.sm),
            _InfoRow(
              label: 'ID Pengguna',
              value: user.id,
              icon: Icons.fingerprint_rounded,
              isMonospace: true,
            ),
          ],
        ),
      );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
    this.isMonospace = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool isMonospace;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: AppDimensions.iconSm, color: AppColors.textHint),
          const SizedBox(width: AppDimensions.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.labelMedium),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: isMonospace
                      ? AppTextStyles.bodySmall.copyWith(
                          fontFamily: 'monospace',
                          letterSpacing: 0.3,
                        )
                      : AppTextStyles.bodySmall,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ],
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _LogoutDialog — konfirmasi sebelum logout
// ─────────────────────────────────────────────────────────────────────────────

class _LogoutDialog extends StatelessWidget {
  const _LogoutDialog();

  @override
  Widget build(BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        ),
        title: const Text('Keluar dari Akun?'),
        content: Text(
          'Anda akan keluar dari sesi ini. Masuk kembali diperlukan untuk menggunakan aplikasi.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Keluar'),
          ),
        ],
      );
}
