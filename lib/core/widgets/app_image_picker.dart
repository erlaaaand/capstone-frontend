import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_app/core/constants/app_constants.dart';
import 'package:mobile_app/core/theme/app_colors.dart';
import 'package:mobile_app/core/theme/app_dimensions.dart';
import 'package:mobile_app/core/theme/app_text_styles.dart';
import 'package:mobile_app/core/error/exceptions.dart';
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
  Widget build(BuildContext context) {

    return Container(
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
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            ),
          ),
          const SizedBox(height: AppDimensions.lg),
          const Text('Ambil Foto Durian', style: AppTextStyles.headlineSmall),
          const SizedBox(height: AppDimensions.xs),
          const Text(
            'Format: JPG, PNG, WebP · Maks. ${AppConstants.maxUploadSizeMb}MB',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: AppDimensions.lg),
          const _PhotoTipBanner(),
          const SizedBox(height: AppDimensions.lg),
          
          _SourceTile(
            icon: Icons.camera_alt_rounded,
            label: 'Buka Kamera',
            subtitle: 'Langsung dari kamera perangkat',
            iconBgColor: AppColors.primaryLight.withOpacity(0.15),
            iconColor: AppColors.primaryDark,
            onTap: () async {
              final file = await _pickAndValidate(context, ImageSource.camera);
              if (context.mounted) Navigator.pop(context, file);
            },
          ),
          const SizedBox(height: AppDimensions.md),
          
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
  }

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

      try {
        FileUtils.validateImage(file);
      } on InvalidFileException catch (e) {
        if (context.mounted) _showErrorSnackBar(context, e.message);
        return null;
      }

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
      if (context.mounted) {
        _showErrorSnackBar(context, 'Gagal memproses gambar. Coba lagi.');
      }
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
            const SizedBox(height: AppDimensions.md),
            Container(
              padding: const EdgeInsets.all(AppDimensions.sm),
              decoration: BoxDecoration(
                color: AppColors.warningLight,
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: AppColors.warning, size: 16),
                  const SizedBox(width: AppDimensions.xs),
                  Expanded(
                    child: Text(
                      'Gunakan gambar berbeda untuk menghemat penyimpanan.',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.warning),
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
            child: const Text('Ulangi Foto'),
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

class _PhotoTipBanner extends StatelessWidget {
  const _PhotoTipBanner();

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
            const Icon(Icons.lightbulb_outline_rounded,
                color: AppColors.info, size: 16),
            const SizedBox(width: AppDimensions.xs),
            Expanded(
              child: Text(
                'Tips: Ambil foto dengan pencahayaan baik, durian terlihat jelas, '
                'dan latar belakang tidak terlalu ramai.',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.info),
              ),
            ),
          ],
        ),
      );
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
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
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
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textHint, size: AppDimensions.iconMd),
              ],
            ),
          ),
        ),
      );
}