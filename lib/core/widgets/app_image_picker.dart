import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_app/core/theme/app_colors.dart';
import 'package:mobile_app/core/theme/app_dimensions.dart';
import 'package:mobile_app/core/theme/app_text_styles.dart';
import 'package:mobile_app/core/utils/file_utils.dart';
import 'package:mobile_app/core/utils/image_hash_utils.dart';

class AppImagePickerSheet extends StatelessWidget {
  const AppImagePickerSheet._({this.previousImageHash});

  final String? previousImageHash;

  static Future<File?> show(
    BuildContext context, {
    String? previousImageHash,
  }) =>
      showModalBottomSheet<File?>(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (_) => AppImagePickerSheet._(
          previousImageHash: previousImageHash,
        ),
      );

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppDimensions.radiusXl),
          ),
        ),
        padding: EdgeInsets.fromLTRB(
          AppDimensions.lg,
          AppDimensions.md,
          AppDimensions.lg,
          AppDimensions.xl + MediaQuery.viewPaddingOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              ),
            ),
            const SizedBox(height: AppDimensions.lg),
            Text('Pilih Sumber Gambar', style: AppTextStyles.headlineSmall),
            const SizedBox(height: AppDimensions.xs),
            Text(
              'Format: JPG, PNG, WebP · Maks. 5MB',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: AppDimensions.lg),

            // Tip kualitas foto
            _PhotoTipBanner(),
            const SizedBox(height: AppDimensions.lg),

            // Kamera
            _SourceTile(
              icon: Icons.camera_alt_rounded,
              label: 'Ambil Foto',
              subtitle: 'Langsung dari kamera perangkat',
              iconBgColor: AppColors.primaryLight.withOpacity(0.15),
              iconColor: AppColors.primaryDark,
              onTap: () async {
                final file = await _pickAndValidate(
                  context,
                  ImageSource.camera,
                );
                if (context.mounted) Navigator.pop(context, file);
              },
            ),
            const SizedBox(height: AppDimensions.sm),

            // Galeri
            _SourceTile(
              icon: Icons.photo_library_outlined,
              label: 'Pilih dari Galeri',
              subtitle: 'Gambar tersimpan di perangkat',
              iconBgColor: AppColors.secondaryLight.withOpacity(0.15),
              iconColor: AppColors.secondaryDark,
              onTap: () async {
                final file = await _pickAndValidate(
                  context,
                  ImageSource.gallery,
                );
                if (context.mounted) Navigator.pop(context, file);
              },
            ),
            SizedBox(height: AppDimensions.md),

            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                minimumSize:
                    const Size(double.infinity, AppDimensions.buttonHeightSm),
              ),
              child: const Text('Batal'),
            ),
          ],
        ),
      );

  /// Ambil gambar, validasi, dan periksa duplikasi.
  Future<File?> _pickAndValidate(
    BuildContext context,
    ImageSource source,
  ) async {
    try {
      final picker = ImagePicker();
      final xFile = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 2048,
        maxHeight: 2048,
      );
      if (xFile == null) return null;

      final file = File(xFile.path);

      // Validasi format & ukuran
      try {
        FileUtils.validateImage(file);
      } catch (e) {
        if (context.mounted) {
          _showErrorSnackBar(context, e.toString().replaceAll('InvalidFileException: ', ''));
        }
        return null;
      }

      // Cek duplikasi dengan hash
      if (previousImageHash != null) {
        final isDup =
            await ImageHashUtils.matchesHash(file, previousImageHash!);
        if (isDup && context.mounted) {
          final proceed = await _showDuplicateDialog(context);
          if (!proceed) return null;
        }
      }

      return file;
    } catch (_) {
      return null;
    }
  }

  Future<bool> _showDuplicateDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        ),
        title: const Text('Gambar Sama Terdeteksi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gambar ini identik dengan yang pernah di-scan sebelumnya. '
              'Melanjutkan akan memperbarui hasil scan.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: AppDimensions.md),
            Container(
              padding: const EdgeInsets.all(AppDimensions.sm),
              decoration: BoxDecoration(
                color: AppColors.warningLight,
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.warning,
                    size: 16,
                  ),
                  const SizedBox(width: AppDimensions.xs),
                  Expanded(
                    child: Text(
                      'Gunakan gambar berbeda untuk menghemat penyimpanan.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Pilih Gambar Lain'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            child: const Text('Lanjutkan'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}

// ── Photo Tip Banner ──────────────────────────────────────────────────────────

class _PhotoTipBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(AppDimensions.sm),
        decoration: BoxDecoration(
          color: AppColors.infoLight,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(color: AppColors.info.withOpacity(0.25)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.lightbulb_outline_rounded,
              color: AppColors.info,
              size: 16,
            ),
            const SizedBox(width: AppDimensions.xs),
            Expanded(
              child: Text(
                'Tips: Ambil foto dengan pencahayaan baik, durian terlihat jelas, '
                'dan latar belakang tidak terlalu ramai.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.info,
                ),
              ),
            ),
          ],
        ),
      );
}

// ── Source Tile ───────────────────────────────────────────────────────────────

class _SourceTile extends StatelessWidget {
  const _SourceTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.iconBgColor,
    required this.iconColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final Color iconBgColor;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          child: Container(
            padding: EdgeInsets.all(AppDimensions.md),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withOpacity(0.5),
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                  child: Icon(icon, color: iconColor, size: AppDimensions.iconMd),
                ),
                SizedBox(width: AppDimensions.md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: AppTextStyles.titleMedium),
                    Text(subtitle, style: AppTextStyles.bodySmall),
                  ],
                ),
                const Spacer(),
                Icon(Icons.chevron_right_rounded,
                    color: AppColors.textHint, size: AppDimensions.iconMd),
              ],
            ),
          ),
        ),
      );
}