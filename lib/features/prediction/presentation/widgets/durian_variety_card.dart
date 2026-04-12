import 'package:cached_network_image/cached_network_image.dart';
import 'package:mobile_app/core/theme/app_colors.dart';
import 'package:mobile_app/core/theme/app_dimensions.dart';
import 'package:mobile_app/core/theme/app_text_styles.dart';
import 'package:mobile_app/core/widgets/app_loading_overlay.dart';
import 'package:flutter/material.dart';

/// Kartu utama hasil prediksi — menampilkan varietas, asal, deskripsi,
/// gambar durian, dan confidence gauge.
class DurianVarietyCard extends StatelessWidget {
  const DurianVarietyCard({
    super.key,
    required this.varietyCode,
    required this.varietyName,
    required this.localName,
    required this.origin,
    required this.description,
    required this.imageUrl,
    required this.confidenceWidget,
  });

  final String varietyCode;
  final String varietyName;
  final String? localName;
  final String? origin;
  final String? description;
  final String imageUrl;

  /// Slot untuk [ConfidenceGauge] agar kartu tidak bergantung langsung.
  final Widget confidenceWidget;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Gambar durian ───────────────────────────────────────────────
            _DurianImage(imageUrl: imageUrl),

            Padding(
              padding: const EdgeInsets.all(AppDimensions.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Kode varietas ─────────────────────────────────────────
                  _VarietyCodeChip(code: varietyCode),
                  const SizedBox(height: AppDimensions.sm),

                  // ── Nama ──────────────────────────────────────────────────
                  Text(varietyName, style: AppTextStyles.headlineMedium),

                  if (localName != null) ...[
                    const SizedBox(height: AppDimensions.xs),
                    Text(
                      localName!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],

                  // ── Gauge ─────────────────────────────────────────────────
                  const SizedBox(height: AppDimensions.lg),
                  Center(child: confidenceWidget),
                  const SizedBox(height: AppDimensions.xs),
                  Center(
                    child: Text(
                      'Tingkat kepercayaan AI',
                      style: AppTextStyles.bodySmall,
                    ),
                  ),

                  // ── Divider ───────────────────────────────────────────────
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppDimensions.md),
                    child: Divider(),
                  ),

                  // ── Asal ──────────────────────────────────────────────────
                  if (origin != null)
                    _InfoRow(
                      icon: Icons.place_outlined,
                      label: 'Asal',
                      value: origin!,
                    ),

                  // ── Deskripsi ─────────────────────────────────────────────
                  if (description != null) ...[
                    const SizedBox(height: AppDimensions.md),
                    Text('Deskripsi', style: AppTextStyles.titleMedium),
                    const SizedBox(height: AppDimensions.xs),
                    _ExpandableDescription(text: description!),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _DurianImage extends StatelessWidget {
  const _DurianImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) => CachedNetworkImage(
        imageUrl: imageUrl,
        height: AppDimensions.imagePreviewHeight,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(
          height: AppDimensions.imagePreviewHeight,
          color: AppColors.surfaceAlt,
          child: const Center(
            child: AppShimmer(width: double.infinity, height: double.infinity),
          ),
        ),
        errorWidget: (_, __, ___) => Container(
          height: AppDimensions.imagePreviewHeight,
          color: AppColors.surfaceAlt,
          child: const Icon(
            Icons.broken_image_outlined,
            size: AppDimensions.iconXl,
            color: AppColors.textHint,
          ),
        ),
      );
}

class _VarietyCodeChip extends StatelessWidget {
  const _VarietyCodeChip({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.sm,
          vertical: AppDimensions.xs,
        ),
        decoration: BoxDecoration(
          color: AppColors.primaryLight.withOpacity(0.15),
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        ),
        child: Text(
          code,
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: AppDimensions.iconSm + 2, color: AppColors.primary),
          const SizedBox(width: AppDimensions.xs),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: AppTextStyles.bodyMedium,
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      );
}

class _ExpandableDescription extends StatefulWidget {
  const _ExpandableDescription({required this.text});

  final String text;

  @override
  State<_ExpandableDescription> createState() => _ExpandableDescriptionState();
}

class _ExpandableDescriptionState extends State<_ExpandableDescription> {
  bool _expanded = false;
  static const _maxLines = 4;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.text,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.65,
            ),
            maxLines: _expanded ? null : _maxLines,
            overflow: _expanded ? null : TextOverflow.ellipsis,
          ),
          if (widget.text.length > 200) ...[
            const SizedBox(height: AppDimensions.xs),
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Text(
                _expanded ? 'Tampilkan lebih sedikit' : 'Selengkapnya',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      );
}
