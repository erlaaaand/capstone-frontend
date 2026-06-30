import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/core/constants/app_constants.dart';
import 'package:mobile_app/core/theme/app_colors.dart';
import 'package:mobile_app/core/theme/app_dimensions.dart';
import 'package:mobile_app/core/utils/date_formatter.dart';
import 'package:mobile_app/core/widgets/app_loading_overlay.dart';
import 'package:mobile_app/features/prediction/domain/entities/prediction.dart';
import 'package:mobile_app/features/prediction/presentation/widgets/prediction_status_badge.dart';

class PredictionCard extends StatelessWidget {
  const PredictionCard({
    super.key,
    required this.prediction,
    this.onTap,
  });

  final Prediction prediction;
  final VoidCallback? onTap;

  String get _pct => prediction.confidence != null
      ? '${(prediction.confidence!.value * 100).toStringAsFixed(1)}%'
      : '-';

  Color get _confidenceColor {
    if (prediction.confidence == null) return AppColors.textHint;
    if (prediction.confidence!.value >= 0.8) return AppColors.confidenceHigh;
    if (prediction.confidence!.value >= 0.5) return AppColors.confidenceMedium;
    return AppColors.confidenceLow;
  }

  String _getTitle() {
    if (prediction.isFailed) {
      return prediction.errorMessage ?? 'Gagal memproses gambar';
    }
    if (prediction.isPending) {
      return 'Sedang memproses...';
    }
    final variety = prediction.predictedClass;
    return variety != null 
      ? (AppConstants.durianVarietyNames[variety] ?? variety)
      : 'Tidak diketahui';
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.md),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Row(
            children: [
              _Thumbnail(imageUrl: prediction.imageUrl),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Judul / Nama Varietas ──
                    Text(
                      _getTitle(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: prediction.isFailed ? Theme.of(context).colorScheme.error : null,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppDimensions.xs),
                    
                    // ── Tingkat Kepercayaan ──
                    if (prediction.confidence != null)
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(color: _confidenceColor, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Kepercayaan: $_pct',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: _confidenceColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    
                    // ── Informasi Harga Pasar (Fitur Utama) ──
                    if (prediction.isSuccess) ...[
                      const SizedBox(height: 4),
                      if (prediction.marketPriceSummary != null)
                        Text(
                          'Rp ${prediction.marketPriceSummary!.minPriceKg} - Rp ${prediction.marketPriceSummary!.maxPriceKg} /kg',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: AppColors.success, // Menonjolkan harga dengan warna hijau/sukses
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      else
                        Text(
                          'Harga pasar tidak tersedia',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.textHint,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],

                    const SizedBox(height: AppDimensions.sm),
                    
                    // ── Status dan Tanggal ──
                    Row(
                      children: [
                        PredictionStatusBadge(prediction: prediction),
                        const Spacer(),
                        Text(
                          DateFormatter.toRelative(prediction.createdAt.toIso8601String()),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: Theme.of(context).colorScheme.onSurfaceVariant, size: AppDimensions.iconMd),
            ],
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
            child: const Icon(Icons.image_not_supported_outlined, color: AppColors.textHint),
          ),
        ),
      );
}