import 'dart:io';

import 'package:mobile_app/core/theme/app_colors.dart';
import 'package:mobile_app/core/theme/app_dimensions.dart';
import 'package:mobile_app/core/theme/app_text_styles.dart';
import 'package:mobile_app/core/utils/file_utils.dart';
import 'package:mobile_app/core/widgets/app_button.dart';
import 'package:flutter/material.dart';

/// Preview gambar yang telah dipilih user sebelum proses upload & prediksi.
///
/// Menampilkan:
/// - Thumbnail gambar full-width
/// - Nama file + ukuran
/// - Tombol ganti gambar
/// - Tombol scan (aksi utama)
class ImageUploadPreview extends StatelessWidget {
  const ImageUploadPreview({
    super.key,
    required this.file,
    required this.onScan,
    required this.onReselect,
    this.isLoading = false,
  });

  final File file;
  final VoidCallback onScan;
  final VoidCallback onReselect;
  final bool isLoading;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Gambar Preview ────────────────────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            child: Stack(
              children: [
                Image.file(
                  file,
                  width: double.infinity,
                  height: AppDimensions.imagePreviewHeight,
                  fit: BoxFit.cover,
                ),
                // Overlay gelap saat loading
                if (isLoading)
                  Positioned.fill(
                    child: ColoredBox(
                      color: Colors.black.withOpacity(0.4),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.white,
                          strokeWidth: 2.5,
                        ),
                      ),
                    ),
                  ),
                // Badge ganti gambar (pojok kanan atas)
                if (!isLoading)
                  Positioned(
                    top: AppDimensions.sm,
                    right: AppDimensions.sm,
                    child: _ReselectBadge(onTap: onReselect),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.md),

          // ── Info File ─────────────────────────────────────────────────────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.sm),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                ),
                child: const Icon(
                  Icons.image_outlined,
                  color: AppColors.primary,
                  size: AppDimensions.iconMd,
                ),
              ),
              const SizedBox(width: AppDimensions.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      FileUtils.getFileName(file.path),
                      style: AppTextStyles.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      FileUtils.formatFileSize(file.lengthSync()),
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.lg),

          // ── Tombol Scan ───────────────────────────────────────────────────
          AppButton(
            label: isLoading ? 'Sedang Memproses...' : 'Scan Durian',
            onPressed: isLoading ? null : onScan,
            isLoading: isLoading,
            icon: Icons.document_scanner_outlined,
          ),
        ],
      );
}

class _ReselectBadge extends StatelessWidget {
  const _ReselectBadge({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.sm,
            vertical: AppDimensions.xs,
          ),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.55),
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.refresh_rounded,
                  color: AppColors.white, size: 14),
              const SizedBox(width: 4),
              Text(
                'Ganti',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.white,
                ),
              ),
            ],
          ),
        ),
      );
}
