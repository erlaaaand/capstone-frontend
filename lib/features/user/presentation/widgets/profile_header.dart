import 'package:flutter/material.dart';
import 'package:mobile_app/core/theme/app_colors.dart';
import 'package:mobile_app/core/theme/app_dimensions.dart';
import 'package:mobile_app/core/theme/app_text_styles.dart';

/// Widget header profil.
///
/// Menampilkan:
/// - Avatar dengan inisial nama user ([_AvatarCircle])
/// - Nama lengkap atau email sebagai fallback
/// - Alamat email
/// - Badge status akun (aktif / tidak aktif)
/// - Tanggal bergabung
///
/// Semua data bersifat read-only; tidak ada interaksi di widget ini.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.email,
    required this.createdAt,
    required this.isActive,
    this.fullName,
  });

  final String email;
  final String? fullName;
  final bool isActive;
  final String createdAt;

  /// Nama tampilan: fullName jika ada, fallback ke bagian email sebelum @.
  String get _displayName =>
      fullName?.trim().isNotEmpty == true ? fullName! : email.split('@').first;

  /// Inisial untuk avatar — maks 2 karakter.
  String get _initials {
    final name = fullName?.trim();
    if (name == null || name.isEmpty) {
      return email.isNotEmpty ? email[0].toUpperCase() : '?';
    }
    final parts = name.split(' ').where((w) => w.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first[0].toUpperCase();
  }

  /// Format tanggal ISO 8601 menjadi tampilan yang lebih ramah.
  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Avatar ──────────────────────────────────────────────────
          _AvatarCircle(initials: _initials, isActive: isActive),
          const SizedBox(height: AppDimensions.md),

          // ── Nama ────────────────────────────────────────────────────
          Text(
            _displayName,
            style: AppTextStyles.headlineSmall,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppDimensions.xs),

          // ── Email ───────────────────────────────────────────────────
          Text(
            email,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppDimensions.sm),

          // ── Badge Status ─────────────────────────────────────────────
          _StatusBadge(isActive: isActive),
          const SizedBox(height: AppDimensions.sm),

          // ── Tanggal Bergabung ────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: AppDimensions.iconSm,
                color: AppColors.textHint,
              ),
              const SizedBox(width: AppDimensions.xs),
              Text(
                'Bergabung ${_formatDate(createdAt)}',
                style: AppTextStyles.labelMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _AvatarCircle — lingkaran avatar dengan inisial dan indikator status
// ─────────────────────────────────────────────────────────────────────────────

class _AvatarCircle extends StatelessWidget {
  const _AvatarCircle({
    required this.initials,
    required this.isActive,
  });

  final String initials;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Lingkaran utama avatar
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            initials,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
              height: 1,
            ),
          ),
        ),

        // Indikator online/offline di pojok kanan bawah
        Positioned(
          right: 2,
          bottom: 2,
          child: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? AppColors.success : AppColors.error,
              border: Border.all(color: AppColors.white, width: 2.5),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _StatusBadge — pill badge status akun
// ─────────────────────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.success : AppColors.error;
    final bgColor = isActive ? AppColors.successLight : AppColors.errorLight;
    final label = isActive ? 'Akun Aktif' : 'Akun Nonaktif';
    final icon = isActive ? Icons.verified_rounded : Icons.block_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.sm,
        vertical: AppDimensions.xs,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppDimensions.iconSm, color: color),
          const SizedBox(width: AppDimensions.xs),
          Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
