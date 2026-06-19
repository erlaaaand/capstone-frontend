import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/core/theme/app_colors.dart';
import 'package:mobile_app/core/theme/app_dimensions.dart';
import 'package:mobile_app/core/theme/app_text_styles.dart';
import 'package:mobile_app/core/utils/date_formatter.dart';
import 'package:mobile_app/core/widgets/app_loading_overlay.dart';
import 'package:mobile_app/features/prediction/presentation/widgets/prediction_status_badge.dart';

class PredictionCard extends StatelessWidget {
  const PredictionCard({
    super.key,
    required this.id,
    required this.imageUrl,
    required this.status,
    required this.createdAt,
    this.varietyName,
    this.confidenceScore,
    this.onTap,
    this.onDelete,
  });

  final String id;
  final String imageUrl;
  final String status;
  final String createdAt;
  final String? varietyName;
  final double? confidenceScore;
  final VoidCallback? onTap;

  final VoidCallback? onDelete;

  String get _pct => confidenceScore != null
      ? '${(confidenceScore! * 100).toStringAsFixed(1)}%'
      : '-';

  Color get _confidenceColor {
    if (confidenceScore == null) return AppColors.textHint;
    if (confidenceScore! >= 0.8) return AppColors.confidenceHigh;
    if (confidenceScore! >= 0.5) return AppColors.confidenceMedium;
    return AppColors.confidenceLow;
  }

  @override
  Widget build(BuildContext context) => Dismissible(
        key: ValueKey(id),
        direction: DismissDirection.endToStart,
        background: _DeleteBackground(),
        onDismissed: (_) => onDelete?.call(),
        confirmDismiss: (_) async {
          if (onDelete == null) return false;
          onDelete!.call();
          return false;
        },
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.all(AppDimensions.md),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                // Thumbnail
                _Thumbnail(imageUrl: imageUrl),
                SizedBox(width: AppDimensions.md),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        varietyName ?? 'Memproses...',
                        style: AppTextStyles.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppDimensions.xs),

                      // Confidence dengan warna
                      if (confidenceScore != null)
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _confidenceColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Kepercayaan: $_pct',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: _confidenceColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: AppDimensions.sm),

                      Row(
                        children: [
                          PredictionStatusBadge.fromString(status),
                          const Spacer(),
                          Text(
                            DateFormatter.toRelative(createdAt),
                            style: AppTextStyles.labelSmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textHint,
                  size: AppDimensions.iconMd,
                ),
              ],
            ),
          ),
        ),
      );
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          width: 72,
          height: 72,
          fit: BoxFit.cover,
          placeholder: (_, __) => const AppShimmer(width: 72, height: 72),
          errorWidget: (_, __, ___) => Container(
            width: 72,
            height: 72,
            color: AppColors.surfaceAlt,
            child: const Icon(
              Icons.image_not_supported_outlined,
              color: AppColors.textHint,
            ),
          ),
        ),
      );
}

class _DeleteBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppDimensions.lg),
        decoration: BoxDecoration(
          color: AppColors.errorLight,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.delete_outline_rounded, color: AppColors.error),
            const SizedBox(height: 2),
            Text(
              'Hapus',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
}