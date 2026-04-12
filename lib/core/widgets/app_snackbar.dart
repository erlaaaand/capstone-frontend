import 'package:mobile_app/core/theme/app_colors.dart';
import 'package:mobile_app/core/theme/app_dimensions.dart';
import 'package:mobile_app/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

enum SnackBarType { success, error, warning, info }

/// Helper untuk menampilkan snackbar yang konsisten di seluruh app.
///
/// ```dart
/// AppSnackBar.show(context, 'Login berhasil!', type: SnackBarType.success);
/// AppSnackBar.showError(context, failure.message);
/// ```
class AppSnackBar {
  AppSnackBar._();

  static void show(
    BuildContext context,
    String message, {
    SnackBarType type = SnackBarType.info,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final config = _config(type);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(config.icon, color: config.iconColor, size: 20),
              const SizedBox(width: AppDimensions.sm),
              Expanded(
                child: Text(
                  message,
                  style: AppTextStyles.bodySmall.copyWith(color: config.textColor),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          backgroundColor: config.backgroundColor,
          duration: duration,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          margin: const EdgeInsets.all(AppDimensions.md),
          action: actionLabel != null
              ? SnackBarAction(
                  label: actionLabel,
                  textColor: config.iconColor,
                  onPressed: onAction ?? () {},
                )
              : null,
        ),
      );
  }

  static void showSuccess(BuildContext context, String message) =>
      show(context, message, type: SnackBarType.success);

  static void showError(BuildContext context, String message) =>
      show(context, message, type: SnackBarType.error);

  static void showWarning(BuildContext context, String message) =>
      show(context, message, type: SnackBarType.warning);

  static void showInfo(BuildContext context, String message) =>
      show(context, message, type: SnackBarType.info);

  static _SnackBarConfig _config(SnackBarType type) => switch (type) {
        SnackBarType.success => const _SnackBarConfig(
            icon: Icons.check_circle_outline_rounded,
            backgroundColor: AppColors.successLight,
            iconColor: AppColors.success,
            textColor: Color(0xFF1B5E20),
          ),
        SnackBarType.error => const _SnackBarConfig(
            icon: Icons.error_outline_rounded,
            backgroundColor: AppColors.errorLight,
            iconColor: AppColors.error,
            textColor: Color(0xFF7F0000),
          ),
        SnackBarType.warning => const _SnackBarConfig(
            icon: Icons.warning_amber_rounded,
            backgroundColor: AppColors.warningLight,
            iconColor: AppColors.warning,
            textColor: Color(0xFF7F4000),
          ),
        SnackBarType.info => const _SnackBarConfig(
            icon: Icons.info_outline_rounded,
            backgroundColor: AppColors.infoLight,
            iconColor: AppColors.info,
            textColor: Color(0xFF003087),
          ),
      };
}

class _SnackBarConfig {
  const _SnackBarConfig({
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    required this.textColor,
  });

  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;
}
