import 'package:flutter/material.dart';
import 'package:mobile_app/core/theme/app_colors.dart';
import 'package:mobile_app/core/theme/app_dimensions.dart';
import 'package:mobile_app/core/theme/app_text_styles.dart';

class AiStatusBanner extends StatelessWidget {
  const AiStatusBanner({
    super.key,
    required this.isOffline,
    this.message,
    this.onRetry,
  });

  final bool isOffline;
  final String? message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Visibility(
        visible: isOffline,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.md,
            vertical: AppDimensions.sm,
          ),
          decoration: const BoxDecoration(
            color: AppColors.errorLight,
            border: Border(
              bottom: BorderSide(color: AppColors.error),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.smart_toy_outlined,
                color: AppColors.error,
                size: AppDimensions.iconSm + 4,
              ),
              const SizedBox(width: AppDimensions.sm),
              Expanded(
                child: Text(
                  message ??
                      'AI service sedang offline. Fitur scan tidak tersedia.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ),
              if (onRetry != null)
                GestureDetector(
                  onTap: onRetry,
                  child: Text(
                    'Coba lagi',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.error,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
