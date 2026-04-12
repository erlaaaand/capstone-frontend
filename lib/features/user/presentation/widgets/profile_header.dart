import 'package:mobile_app/core/theme/app_colors.dart';
import 'package:mobile_app/core/theme/app_dimensions.dart';
import 'package:mobile_app/core/theme/app_text_styles.dart';
import 'package:mobile_app/core/utils/date_formatter.dart';
import 'package:flutter/material.dart';

/// Header halaman profil — avatar inisial, nama, email, dan tanggal bergabung.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.email,
    this.fullName,
    this.createdAt,
    this.isActive = true,
  });

  final String email;
  final String? fullName;
  final String? createdAt;
  final bool isActive;

  String get _initials {
    final name = fullName?.trim();
    if (name == null || name.isEmpty) {
      return email.isNotEmpty ? email[0].toUpperCase() : '?';
    }
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.xl,
          horizontal: AppDimensions.lg,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        ),
        child: Column(
          children: [
            // Avatar inisial
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.25),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.white.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  _initials,
                  style: AppTextStyles.headlineLarge.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.md),

            // Nama
            Text(
              fullName ?? 'Pengguna',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.white,
              ),
              textAlign: TextAlign.center,
            ),

            // Email
            const SizedBox(height: AppDimensions.xs),
            Text(
              email,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.white.withOpacity(0.8),
              ),
            ),

            // Status + tanggal bergabung
            if (createdAt != null) ...[
              const SizedBox(height: AppDimensions.md),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Aktif / nonaktif badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.sm,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.successLight.withOpacity(0.9)
                          : AppColors.errorLight.withOpacity(0.9),
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusFull),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isActive
                              ? Icons.verified_outlined
                              : Icons.block_outlined,
                          size: 12,
                          color: isActive ? AppColors.success : AppColors.error,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isActive ? 'Aktif' : 'Nonaktif',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: isActive ? AppColors.success : AppColors.error,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimensions.sm),
                  Text(
                    'Bergabung ${DateFormatter.toDate(createdAt!)}',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      );
}
