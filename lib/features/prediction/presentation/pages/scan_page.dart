import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app/core/error/failures.dart';
import 'package:mobile_app/core/router/route_names.dart';
import 'package:mobile_app/core/theme/app_colors.dart';
import 'package:mobile_app/core/theme/app_dimensions.dart';
import 'package:mobile_app/core/theme/app_text_styles.dart';
import 'package:mobile_app/core/utils/file_utils.dart';
import 'package:mobile_app/core/utils/image_hash_utils.dart';
import 'package:mobile_app/core/widgets/app_button.dart';
import 'package:mobile_app/core/widgets/app_error_widget.dart';
import 'package:mobile_app/core/widgets/app_image_picker.dart';
import 'package:mobile_app/core/widgets/app_snackbar.dart';
import 'package:mobile_app/features/ai_health/application/ai_health_cubit.dart';
import 'package:mobile_app/features/ai_health/application/ai_health_state.dart';
import 'package:mobile_app/features/ai_health/presentation/widgets/ai_status_banner.dart';
import 'package:mobile_app/features/ai_health/presentation/widgets/ai_status_indicator.dart';
import 'package:mobile_app/features/prediction/application/create_prediction/create_prediction_bloc.dart';
import 'package:mobile_app/features/prediction/application/create_prediction/create_prediction_event.dart';
import 'package:mobile_app/features/prediction/application/create_prediction/create_prediction_state.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  File? _selectedImage;
  String? _lastUploadedHash;

  Future<void> _pickImage() async {
    final file = await AppImagePickerSheet.show(
      context,
      previousImageHash: _lastUploadedHash,
    );
    if (file != null && mounted) {
      setState(() => _selectedImage = file);
    }
  }

  void _startScan() {
    if (_selectedImage == null) return;

    // Simpan hash untuk dedup check berikutnya
    ImageHashUtils.computeHash(_selectedImage!).then((hash) {
      _lastUploadedHash = hash;
    });

    context
        .read<CreatePredictionBloc>()
        .add(CreatePredictionStarted(_selectedImage!));
  }

  void _reset() {
    setState(() => _selectedImage = null);
    context.read<CreatePredictionBloc>().add(const CreatePredictionReset());
  }

  bool _isAiReady(BuildContext context) {
    final aiState = context.read<AiHealthCubit>().state;
    if (aiState is AiHealthLoaded) return aiState.aiStatus.canScan;
    return true; // Optimistic: izinkan jika status belum diketahui
  }

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<CreatePredictionBloc, CreatePredictionState>(
        listener: _listener,
        builder: (context, state) => Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: _buildAppBar(context, state),
          body: Column(
            children: [
              // AI Status Banner di atas konten
              BlocBuilder<AiHealthCubit, AiHealthState>(
                builder: (context, aiState) {
                  if (aiState is AiHealthLoaded) {
                    return AiStatusBanner(
                      isOffline: aiState.showBanner,
                      message: aiState.aiStatus.displayMessage,
                      onRetry: () =>
                          context.read<AiHealthCubit>().fetchCurrentStatus(),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              Expanded(child: _buildBody(context, state)),
            ],
          ),
        ),
      );

  void _listener(BuildContext context, CreatePredictionState state) {
    if (state is CreatePredictionFailure) {
      if (state.failure is! PredictionFailedFailure) {
        AppSnackBar.showError(context, state.failure.message);
      }
    }
    if (state is CreatePredictionSuccess) {
      // Simpan hash gambar yang berhasil di-upload
      if (_selectedImage != null) {
        ImageHashUtils.computeHash(_selectedImage!).then((hash) {
          LastImageHashCache.save(hash, state.prediction.id);
        });
      }
      context.goNamed(
        RouteNames.predictionResult,
        pathParameters: {'predictionId': state.prediction.id},
        extra: state.prediction,
      );
    }
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    CreatePredictionState state,
  ) =>
      AppBar(
        title: const Text('Scan Durian'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // AI Status Indicator di AppBar
          BlocBuilder<AiHealthCubit, AiHealthState>(
            builder: (context, aiState) {
              if (aiState is AiHealthLoaded) {
                return Padding(
                  padding: EdgeInsets.only(right: AppDimensions.md),
                  child: Center(
                    child: AiStatusIndicator(
                      status: aiState.indicatorValue,
                      showLabel: false,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          if (state is! CreatePredictionInitial)
            TextButton(
              onPressed: _reset,
              child: const Text('Ulangi'),
            ),
        ],
      );

  Widget _buildBody(BuildContext context, CreatePredictionState state) =>
      switch (state) {
        CreatePredictionInitial() => _InitialView(
            selectedImage: _selectedImage,
            onPickImage: _pickImage,
            onStartScan: _selectedImage != null && _isAiReady(context)
                ? _startScan
                : null,
            isAiReady: _isAiReady(context),
          ),
        CreatePredictionUploading(:final progress) => _UploadingView(
            selectedImage: _selectedImage,
            progress: progress,
          ),
        CreatePredictionProcessing() => const _ProcessingView(
            imageUrl: '',
            attempt: 0,
            maxAttempts: 0,
          ),
        CreatePredictionSuccess() => const SizedBox.shrink(),
        CreatePredictionFailure(:final failure) => _FailureView(
            failure: failure,
            onRetry: _selectedImage != null && _isAiReady(context)
                ? _startScan
                : null,
            onPickNew: _pickImage,
          ),
      };
}

// ── Initial View ──────────────────────────────────────────────────────────────

class _InitialView extends StatelessWidget {
  const _InitialView({
    required this.selectedImage,
    required this.onPickImage,
    required this.onStartScan,
    required this.isAiReady,
  });

  final File? selectedImage;
  final VoidCallback onPickImage;
  final VoidCallback? onStartScan;
  final bool isAiReady;

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.pagePaddingH,
            vertical: AppDimensions.pagePaddingV,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Identifikasi Varietasmu',
                style: AppTextStyles.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.xs),
              Text(
                'Pilih atau ambil foto durian untuk\nmengetahui varietasnya secara akurat.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.xl),

              Expanded(
                child: _ImagePickerArea(
                  selectedImage: selectedImage,
                  onTap: onPickImage,
                ),
              ),

              // Metadata file jika gambar sudah dipilih
              if (selectedImage != null) ...[
                SizedBox(height: AppDimensions.md),
                _FileMetadataChip(file: selectedImage!),
              ],

              const SizedBox(height: AppDimensions.lg),

              // Pesan AI offline
              if (!isAiReady)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppDimensions.sm),
                  child: _AiOfflineHint(),
                ),

              AppButton(
                label: 'Mulai Scan',
                onPressed: onStartScan,
                icon: Icons.qr_code_scanner_rounded,
              ),
              const SizedBox(height: AppDimensions.sm),
              AppOutlinedButton(
                label: selectedImage != null ? 'Ganti Gambar' : 'Pilih Gambar',
                onPressed: onPickImage,
                icon: Icons.add_photo_alternate_outlined,
              ),
            ],
          ),
        ),
      );
}

class _FileMetadataChip extends StatelessWidget {
  const _FileMetadataChip({required this.file});

  final File file;

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.md,
          vertical: AppDimensions.xs,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.image_outlined,
              size: 14,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: AppDimensions.xs),
            Flexible(
              child: Text(
                FileUtils.getFileName(file.path),
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: AppDimensions.xs),
            Text(
              '· ${FileUtils.formatFileSize(file.lengthSync())}',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textHint,
              ),
            ),
          ],
        ),
      );
}

class _AiOfflineHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.md,
          vertical: AppDimensions.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.warningLight,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: AppColors.warning,
              size: 16,
            ),
            const SizedBox(width: AppDimensions.xs),
            Expanded(
              child: Text(
                'AI sedang offline. Scan tidak tersedia saat ini.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.warning,
                ),
              ),
            ),
          ],
        ),
      );
}

class _ImagePickerArea extends StatelessWidget {
  const _ImagePickerArea({
    required this.selectedImage,
    required this.onTap,
  });

  final File? selectedImage;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            color: selectedImage != null
                ? Colors.transparent
                : AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
            border: Border.all(
              color: selectedImage != null
                  ? Colors.transparent
                  : AppColors.primary.withOpacity(0.35),
              width: 2,
              strokeAlign: BorderSide.strokeAlignOutside,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: selectedImage != null
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(selectedImage!, fit: BoxFit.cover),
                    Positioned(
                      top: AppDimensions.sm,
                      right: AppDimensions.sm,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.sm,
                          vertical: AppDimensions.xs,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.55),
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusFull),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.edit_rounded,
                                color: Colors.white, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              'Ganti',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add_photo_alternate_outlined,
                        color: AppColors.primary,
                        size: AppDimensions.iconXl,
                      ),
                    ),
                    SizedBox(height: AppDimensions.md),
                    Text(
                      'Tap untuk pilih gambar',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.xs),
                    Text(
                      'JPG, PNG, WebP · Maks. 5MB',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
        ),
      );
}

// ── Uploading View ────────────────────────────────────────────────────────────

class _UploadingView extends StatelessWidget {
  const _UploadingView({
    required this.selectedImage,
    required this.progress,
  });

  final File? selectedImage;
  final double progress;

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (selectedImage != null)
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusXl),
                  child: Image.file(
                    selectedImage!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: AppDimensions.xl),

              // Ikon upload animasi
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cloud_upload_outlined,
                  color: AppColors.primary,
                  size: 36,
                ),
              ),
              SizedBox(height: AppDimensions.md),
              Text('Mengunggah gambar...', style: AppTextStyles.titleLarge),
              const SizedBox(height: AppDimensions.xs),

              if (progress > 0)
                Text(
                  '${(progress * 100).toInt()}% selesai',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                )
              else
                Text(
                  'Mempersiapkan gambar...',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),

              const SizedBox(height: AppDimensions.lg),
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusFull),
                child: LinearProgressIndicator(
                  value: progress > 0 ? progress : null,
                  minHeight: 8,
                  backgroundColor: AppColors.surfaceAlt,
                  color: AppColors.primary,
                ),
              ),

              if (selectedImage != null) ...[
                SizedBox(height: AppDimensions.md),
                Text(
                  FileUtils.formatFileSize(selectedImage!.lengthSync()),
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
}

// ── Processing View ───────────────────────────────────────────────────────────

class _ProcessingView extends StatelessWidget {
  const _ProcessingView({
    required this.imageUrl,
    required this.attempt,
    required this.maxAttempts,
  });

  final String imageUrl;
  final int attempt;
  final int maxAttempts;

  String get _statusMessage {
    final pct = maxAttempts > 0 ? (attempt + 1) / maxAttempts : 0.0;
    if (pct < 0.3) return 'Mendeteksi fitur visual durian...';
    if (pct < 0.6) return 'Mencocokkan pola dengan database varietas...';
    if (pct < 0.85) return 'Menghitung confidence score...';
    return 'Hampir selesai, menyiapkan hasil...';
  }

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animasi AI processing
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Padding(
                  padding: EdgeInsets.all(AppDimensions.lg),
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 4,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.xl),
              Text(
                'AI sedang menganalisis...',
                style: AppTextStyles.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.sm),
              // Pesan status yang berubah sesuai progress
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: Text(
                  _statusMessage,
                  key: ValueKey(_statusMessage),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppDimensions.xl),

              // Progress bar dengan label
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusFull),
                      child: LinearProgressIndicator(
                        value: maxAttempts > 0
                            ? (attempt + 1) / maxAttempts
                            : null,
                        minHeight: 8,
                        backgroundColor: AppColors.surfaceAlt,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.sm),
                  Text(
                    '${attempt + 1}/$maxAttempts',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.sm),
              Text(
                'Proses ini memerlukan beberapa saat.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textHint,
                ),
              ),
            ],
          ),
        ),
      );
}

// ── Failure View ──────────────────────────────────────────────────────────────

class _FailureView extends StatelessWidget {
  const _FailureView({
    required this.failure,
    required this.onRetry,
    required this.onPickNew,
  });

  final dynamic failure;
  final VoidCallback? onRetry;
  final VoidCallback onPickNew;

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppErrorWidget(failure: failure, onRetry: onRetry),
              const SizedBox(height: AppDimensions.lg),
              AppOutlinedButton(
                label: 'Pilih Gambar Lain',
                onPressed: onPickNew,
                icon: Icons.add_photo_alternate_outlined,
                isFullWidth: false,
              ),
            ],
          ),
        ),
      );
}