import 'package:mobile_app/core/theme/app_colors.dart';
import 'package:mobile_app/core/theme/app_dimensions.dart';
import 'package:mobile_app/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AppLoadingOverlay — full screen overlay semi-transparan
// ─────────────────────────────────────────────────────────────────────────────

/// Gunakan dengan [Stack] untuk menutup seluruh halaman saat loading.
///
/// ```dart
/// Stack(
///   children: [
///     MainContent(),
///     if (isLoading) const AppLoadingOverlay(),
///   ],
/// )
/// ```
class AppLoadingOverlay extends StatelessWidget {
  const AppLoadingOverlay({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) => ColoredBox(
        color: Colors.black.withOpacity(0.45),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.xl,
              vertical: AppDimensions.lg,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: AppColors.primary),
                if (message != null) ...[
                  const SizedBox(height: AppDimensions.md),
                  Text(
                    message!,
                    style: AppTextStyles.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// AppLoadingIndicator — inline spinner kecil
// ─────────────────────────────────────────────────────────────────────────────

class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({
    super.key,
    this.size = 24,
    this.color,
    this.strokeWidth = 2.5,
  });

  final double size;
  final Color? color;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: strokeWidth,
          color: color ?? AppColors.primary,
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// AppShimmer — skeleton loading placeholder
// ─────────────────────────────────────────────────────────────────────────────

/// Blok abu-abu beranimasi untuk placeholder saat data belum tersedia.
class AppShimmer extends StatefulWidget {
  const AppShimmer({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  final double width;
  final double height;
  final BorderRadius? borderRadius;

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: (isDark ? Colors.white : Colors.black)
              .withOpacity(_animation.value * 0.12),
          borderRadius: widget.borderRadius ??
              BorderRadius.circular(AppDimensions.radiusSm),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AppPredictionLoadingCard — skeleton spesifik untuk card prediksi
// ─────────────────────────────────────────────────────────────────────────────

class AppPredictionLoadingCard extends StatelessWidget {
  const AppPredictionLoadingCard({super.key});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(AppDimensions.md),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            AppShimmer(
              width: 72,
              height: 72,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            const SizedBox(width: AppDimensions.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppShimmer(width: 140, height: 16),
                  const SizedBox(height: AppDimensions.sm),
                  const AppShimmer(width: 90, height: 12),
                  const SizedBox(height: AppDimensions.sm),
                  AppShimmer(
                    width: 60,
                    height: 24,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusFull),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}
