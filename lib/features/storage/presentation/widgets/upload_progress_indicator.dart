import 'package:mobile_app/core/theme/app_colors.dart';
import 'package:mobile_app/core/theme/app_dimensions.dart';
import 'package:mobile_app/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

/// Progress bar upload gambar dengan persentase dan label status.
class UploadProgressIndicator extends StatelessWidget {
  const UploadProgressIndicator({
    super.key,
    required this.progress,
    this.label,
  });

  /// Nilai 0.0 – 1.0. Jika null, tampilkan indeterminate.
  final double? progress;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final pct = progress != null ? (progress! * 100).toStringAsFixed(0) : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label ?? 'Mengunggah gambar...',
              style: AppTextStyles.labelMedium,
            ),
            if (pct != null)
              Text(
                '$pct%',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppDimensions.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          child: progress != null
              ? LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: AppColors.primaryLight.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                )
              : const LinearProgressIndicator(
                  minHeight: 6,
                  backgroundColor: Color(0xFFFFE082),
                  valueColor: AlwaysStoppedAnimation(AppColors.primary),
                ),
        ),
      ],
    );
  }
}
