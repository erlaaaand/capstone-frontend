import 'dart:io';

import 'package:mobile_app/core/theme/app_colors.dart';
import 'package:mobile_app/core/theme/app_dimensions.dart';
import 'package:mobile_app/core/theme/app_text_styles.dart';
import 'package:mobile_app/core/utils/file_utils.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AppImagePickerSheet — bottom sheet pilih sumber gambar
// ─────────────────────────────────────────────────────────────────────────────

/// Tampilkan bottom sheet untuk memilih sumber gambar.
///
/// ```dart
/// final file = await AppImagePickerSheet.show(context);
/// if (file != null) { ... }
/// ```
class AppImagePickerSheet extends StatelessWidget {
  const AppImagePickerSheet._();

  static Future<File?> show(BuildContext context) =>
      showModalBottomSheet<File?>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (_) => const AppImagePickerSheet._(),
      );

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppDimensions.radiusXl),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.lg,
          AppDimensions.md,
          AppDimensions.lg,
          AppDimensions.xl,
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
              'Format: JPG, PNG, WebP · Maksimal 5MB',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: AppDimensions.lg),

            // Kamera
            _SourceTile(
              icon: Icons.camera_alt_rounded,
              label: 'Ambil Foto',
              subtitle: 'Gunakan kamera perangkat',
              iconBgColor: AppColors.primaryLight.withOpacity(0.15),
              iconColor: AppColors.primaryDark,
              onTap: () async {
                final file = await _pickImage(ImageSource.camera);
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
                final file = await _pickImage(ImageSource.gallery);
                if (context.mounted) Navigator.pop(context, file);
              },
            ),
            const SizedBox(height: AppDimensions.md),

            // Batal
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                minimumSize: const Size(double.infinity, AppDimensions.buttonHeightSm),
              ),
              child: const Text('Batal'),
            ),
          ],
        ),
      );

  Future<File?> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final xFile = await picker.pickImage(
        source: source,
        imageQuality: 85,      // kompres sedikit tanpa degradasi visual
        maxWidth: 2048,
        maxHeight: 2048,
      );
      if (xFile == null) return null;

      final file = File(xFile.path);
      FileUtils.validateImage(file); // lempar InvalidFileException jika tidak valid
      return file;
    } catch (_) {
      return null;
    }
  }
}

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
            padding: const EdgeInsets.all(AppDimensions.md),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest
                  .withOpacity(0.5),
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              border: Border.all(
                color: AppColors.divider,
                width: 1,
              ),
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
                const SizedBox(width: AppDimensions.md),
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
