import 'package:mobile_app/core/theme/app_colors.dart';
import 'package:mobile_app/core/theme/app_dimensions.dart';
import 'package:mobile_app/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AppButton — Primary
// ─────────────────────────────────────────────────────────────────────────────

/// Tombol utama kuning-emas, dipakai di aksi primer (Login, Scan, Simpan).
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.height = AppDimensions.buttonHeight,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final double height;

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColors.white,
            ),
          )
        : icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: AppDimensions.iconSm),
                  const SizedBox(width: AppDimensions.sm),
                  Text(label),
                ],
              )
            : Text(label);

    final button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: Size(
          isFullWidth ? double.infinity : AppDimensions.buttonMinWidth,
          height,
        ),
      ),
      child: child,
    );

    return isFullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AppOutlinedButton — Outline
// ─────────────────────────────────────────────────────────────────────────────

/// Tombol outline, dipakai di aksi sekunder (Batal, Pilih Ulang).
class AppOutlinedButton extends StatelessWidget {
  const AppOutlinedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.height = AppDimensions.buttonHeight,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final double height;

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          )
        : icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: AppDimensions.iconSm),
                  const SizedBox(width: AppDimensions.sm),
                  Text(label),
                ],
              )
            : Text(label);

    final button = OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: Size(
          isFullWidth ? double.infinity : AppDimensions.buttonMinWidth,
          height,
        ),
      ),
      child: child,
    );

    return isFullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AppTextButton
// ─────────────────────────────────────────────────────────────────────────────

/// Tombol teks tanpa background, untuk link / aksi tersier.
class AppTextButton extends StatelessWidget {
  const AppTextButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) => TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: color ?? AppColors.primary,
          textStyle: AppTextStyles.labelLarge,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.sm,
            vertical: AppDimensions.xs,
          ),
        ),
        child: Text(label),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// AppIconButton
// ─────────────────────────────────────────────────────────────────────────────

/// Tombol ikon bulat dengan background subtle.
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.backgroundColor,
    this.iconColor,
    this.size = AppDimensions.iconXl,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;

  @override
  Widget build(BuildContext context) => Tooltip(
        message: tooltip ?? '',
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: backgroundColor ??
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor ?? Theme.of(context).colorScheme.primary,
              size: size * 0.45,
            ),
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// AppDestructiveButton — merah, untuk hapus
// ─────────────────────────────────────────────────────────────────────────────

class AppDestructiveButton extends StatelessWidget {
  const AppDestructiveButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: AppColors.white,
            minimumSize: const Size(
              double.infinity,
              AppDimensions.buttonHeight,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5, color: AppColors.white),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: AppDimensions.iconSm),
                      const SizedBox(width: AppDimensions.sm),
                    ],
                    Text(label),
                  ],
                ),
        ),
      );
}
