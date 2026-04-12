import 'package:mobile_app/core/error/failures.dart';
import 'package:mobile_app/core/theme/app_colors.dart';
import 'package:mobile_app/core/theme/app_dimensions.dart';
import 'package:mobile_app/core/theme/app_text_styles.dart';
import 'package:mobile_app/core/widgets/app_button.dart';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AppErrorWidget — tampilan error generik dengan tombol retry
// ─────────────────────────────────────────────────────────────────────────────

class AppErrorWidget extends StatelessWidget {
  const AppErrorWidget({
    super.key,
    required this.failure,
    this.onRetry,
    this.compact = false,
  });

  final Failure failure;
  final VoidCallback? onRetry;

  /// Mode compact untuk inline error (bukan full screen).
  final bool compact;

  /// Pilih icon berdasarkan tipe failure.
  IconData get _icon => switch (failure) {
        NoInternetFailure()  => Icons.wifi_off_rounded,
        TimeoutFailure()     => Icons.timer_off_outlined,
        UnauthorizedFailure() => Icons.lock_outline_rounded,
        AiOfflineFailure()   => Icons.smart_toy_outlined,
        _                    => Icons.error_outline_rounded,
      };

  Color get _iconColor => switch (failure) {
        NoInternetFailure()  => AppColors.warning,
        AiOfflineFailure()   => AppColors.statusFailed,
        UnauthorizedFailure() => AppColors.info,
        _                    => AppColors.error,
      };

  @override
  Widget build(BuildContext context) {
    if (compact) return _buildCompact(context);
    return _buildFull(context);
  }

  Widget _buildFull(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: _iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(_icon, color: _iconColor, size: 40),
              ),
              const SizedBox(height: AppDimensions.lg),
              Text(
                'Terjadi Kesalahan',
                style: AppTextStyles.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.sm),
              Text(
                failure.message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              if (onRetry != null) ...[
                const SizedBox(height: AppDimensions.xl),
                AppButton(
                  label: 'Coba Lagi',
                  onPressed: onRetry,
                  icon: Icons.refresh_rounded,
                  isFullWidth: false,
                ),
              ],
            ],
          ),
        ),
      );

  Widget _buildCompact(BuildContext context) => Container(
        padding: const EdgeInsets.all(AppDimensions.md),
        decoration: BoxDecoration(
          color: AppColors.errorLight,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(color: AppColors.error.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(_icon, color: _iconColor, size: AppDimensions.iconMd),
            const SizedBox(width: AppDimensions.sm),
            Expanded(
              child: Text(
                failure.message,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
              ),
            ),
            if (onRetry != null)
              IconButton(
                icon: const Icon(Icons.refresh_rounded,
                    size: AppDimensions.iconSm + 4),
                color: AppColors.error,
                onPressed: onRetry,
                tooltip: 'Coba lagi',
              ),
          ],
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// AppEmptyWidget — empty state saat list kosong
// ─────────────────────────────────────────────────────────────────────────────

class AppEmptyWidget extends StatelessWidget {
  const AppEmptyWidget({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String subtitle;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 40),
                ),
                const SizedBox(height: AppDimensions.lg),
              ],
              Text(
                title,
                style: AppTextStyles.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.sm),
              Text(
                subtitle,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: AppDimensions.xl),
                AppButton(
                  label: actionLabel!,
                  onPressed: onAction,
                  isFullWidth: false,
                ),
              ],
            ],
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// AppNoInternetWidget — khusus no-internet
// ─────────────────────────────────────────────────────────────────────────────

class AppNoInternetWidget extends StatelessWidget {
  const AppNoInternetWidget({super.key, this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => AppErrorWidget(
        failure: const NoInternetFailure(),
        onRetry: onRetry,
      );
}
