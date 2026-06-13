import 'package:flutter/material.dart';
import 'package:mobile_app/core/theme/app_colors.dart';
import 'package:mobile_app/core/theme/app_dimensions.dart';
import 'package:mobile_app/core/theme/app_text_styles.dart';

/// Banner status AI yang ditampilkan di atas halaman Scan ketika
/// AI service tidak tersedia.
///
/// Upgrade v2:
/// - Animasi masuk/keluar dengan AnimatedSize
/// - Ikon yang lebih kontekstual
/// - Tombol retry dengan feedback loading
class AiStatusBanner extends StatelessWidget {
  const AiStatusBanner({
    super.key,
    required this.isOffline,
    this.message,
    this.onRetry,
    this.isRetrying = false,
  });

  final bool isOffline;
  final String? message;
  final VoidCallback? onRetry;

  /// Tampilkan spinner pada tombol retry saat sedang mencoba ulang.
  final bool isRetrying;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Visibility(
        visible: isOffline,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.md,
              vertical: AppDimensions.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.errorLight,
              border: const Border(
                bottom: BorderSide(color: AppColors.error, width: 0.5),
              ),
            ),
            child: Row(
              children: [
                // Ikon berkedip saat offline
                _PulsingIcon(),
                const SizedBox(width: AppDimensions.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'AI Offline',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        message ??
                            'Fitur scan tidak tersedia saat ini.',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.error.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                if (onRetry != null)
                  GestureDetector(
                    onTap: isRetrying ? null : onRetry,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.sm,
                        vertical: AppDimensions.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.12),
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusFull),
                        border: Border.all(
                          color: AppColors.error.withOpacity(0.3),
                        ),
                      ),
                      child: isRetrying
                          ? const SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                                color: AppColors.error,
                              ),
                            )
                          : Text(
                              'Coba lagi',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.error,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PulsingIcon extends StatefulWidget {
  @override
  State<_PulsingIcon> createState() => _PulsingIconState();
}

class _PulsingIconState extends State<_PulsingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _controller,
        builder: (_, __) => Icon(
          Icons.smart_toy_outlined,
          color: AppColors.error
              .withOpacity(0.5 + _controller.value * 0.5),
          size: 18,
        ),
      );
}