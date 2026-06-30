// features/prediction/presentation/widgets/durian_variety_skeleton_card.dart
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:mobile_app/core/theme/app_colors.dart';
import 'package:mobile_app/core/theme/app_dimensions.dart';

class DurianVarietySkeletonCard extends StatelessWidget {
  const DurianVarietySkeletonCard({super.key});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.06),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Shimmer.fromColors(
          baseColor: AppColors.surfaceAlt,
          highlightColor: AppColors.divider.withOpacity(0.5),
          period: const Duration(milliseconds: 1400),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _Bar(width: 64, height: 22, radius: AppDimensions.radiusSm),
                const SizedBox(height: AppDimensions.sm),

                const _Bar(width: 190, height: 26, radius: AppDimensions.radiusSm),

                const SizedBox(height: AppDimensions.lg),
                const Center(
                  child: _Circle(
                    diameter: AppDimensions.gaugeSize * 0.62,
                  ),
                ),
                const SizedBox(height: AppDimensions.sm),
                const Center(
                  child: _Bar(
                    width: 120,
                    height: 12,
                    radius: AppDimensions.radiusSm,
                  ),
                ),

                SizedBox(height: AppDimensions.md),
                const Divider(),
                SizedBox(height: AppDimensions.md),

                const Row(
                  children: [
                    _Circle(diameter: 16),
                    SizedBox(width: AppDimensions.xs),
                    _Bar(width: 160, height: 14, radius: AppDimensions.radiusSm),
                  ],
                ),

                SizedBox(height: AppDimensions.md),

                const _Bar(width: 100, height: 16, radius: AppDimensions.radiusSm),
                const SizedBox(height: AppDimensions.sm),
                const _Bar(
                  width: double.infinity,
                  height: 14,
                  radius: AppDimensions.radiusSm,
                ),
                const SizedBox(height: AppDimensions.xs),
                const _Bar(
                  width: double.infinity,
                  height: 14,
                  radius: AppDimensions.radiusSm,
                ),
                const SizedBox(height: AppDimensions.xs),
                const _Bar(width: 220, height: 14, radius: AppDimensions.radiusSm),
              ],
            ),
          ),
        ),
      );
}

// ── Primitive shapes ─────────────────────────────────────────────────────────

class _Bar extends StatelessWidget {
  const _Bar({
    required this.width,
    required this.height,
    required this.radius,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(radius),
        ),
      );
}

class _Circle extends StatelessWidget {
  const _Circle({required this.diameter});

  final double diameter;

  @override
  Widget build(BuildContext context) => Container(
        width: diameter,
        height: diameter,
        decoration: const BoxDecoration(
          color: Colors.grey,
          shape: BoxShape.circle,
        ),
      );
}