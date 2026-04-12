import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app/core/router/route_names.dart';
import 'package:mobile_app/core/theme/app_colors.dart';
import 'package:mobile_app/core/theme/app_dimensions.dart';
import 'package:mobile_app/core/theme/app_text_styles.dart';
import 'package:mobile_app/core/widgets/app_button.dart';
import 'package:mobile_app/core/widgets/app_error_widget.dart';
import 'package:mobile_app/core/widgets/app_image_picker.dart';
import 'package:mobile_app/core/widgets/app_snackbar.dart';
import 'package:mobile_app/features/prediction/application/create_prediction/create_prediction_bloc.dart';
import 'package:mobile_app/features/prediction/application/create_prediction/create_prediction_event.dart';
import 'package:mobile_app/features/prediction/application/create_prediction/create_prediction_state.dart';

/// Halaman utama scan durian.
///
/// Flow:
/// 1. User pilih gambar (kamera / galeri)
/// 2. BLoC upload → processing (polling)
/// 3. Sukses → navigasi ke [PredictionResultPage]
/// 4. Gagal → snackbar error + tombol coba lagi
class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  File? _selectedImage;

  // ── Helpers ────────────────────────────────────────────────────────────────

  Future<void> _pickImage() async {
    final file = await AppImagePickerSheet.show(context);
    if (file != null && mounted) {
      setState(() => _selectedImage = file);
    }
  }

  void _startScan() {
    if (_selectedImage == null) return;
    context.read<CreatePredictionBloc>().add(
          CreatePredictionStarted(_selectedImage!),
        );
  }

  void _reset() {
    setState(() => _selectedImage = null);
    context.read<CreatePredictionBloc>().add(const CreatePredictionReset());
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<CreatePredictionBloc, CreatePredictionState>(
        listener: _listener,
        builder: (context, state) => Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          appBar: _buildAppBar(state),
          body: _buildBody(context, state),
        ),
      );

  void _listener(BuildContext context, CreatePredictionState state) {
    if (state is CreatePredictionFailure) {
      AppSnackBar.showError(context, state.failure.message);
    }
    if (state is CreatePredictionSuccess) {
      context.goNamed(
        RouteNames.predictionResult,
        pathParameters: {'predictionId': state.prediction.id},
        extra: state.prediction,
      );
    }
  }

  PreferredSizeWidget _buildAppBar(CreatePredictionState state) => AppBar(
        title: const Text('Scan Durian'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
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
            onStartScan: _selectedImage != null ? _startScan : null,
          ),
        CreatePredictionUploading(:final progress) => _UploadingView(
            selectedImage: _selectedImage,
            progress: progress,
          ),
        CreatePredictionProcessing(
          :final attempt,
          :final maxAttempts,
          :final imageUrl,
        ) =>
          _ProcessingView(
            imageUrl: imageUrl,
            attempt: attempt,
            maxAttempts: maxAttempts,
          ),
        CreatePredictionSuccess() => const SizedBox.shrink(),
        CreatePredictionFailure(:final failure) => _FailureView(
            failure: failure,
            onRetry: _selectedImage != null ? _startScan : null,
            onPickNew: _pickImage,
          ),
      };
}

// ── Sub-views ─────────────────────────────────────────────────────────────────

class _InitialView extends StatelessWidget {
  const _InitialView({
    required this.selectedImage,
    required this.onPickImage,
    required this.onStartScan,
  });

  final File? selectedImage;
  final VoidCallback onPickImage;
  final VoidCallback? onStartScan;

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
              // Header
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

              // Image preview / picker area
              Expanded(
                child: _ImagePickerArea(
                  selectedImage: selectedImage,
                  onTap: onPickImage,
                ),
              ),
              const SizedBox(height: AppDimensions.lg),

              // CTA buttons
              AppButton(
                label: 'Mulai Scan',
                onPressed: onStartScan,
                icon: Icons.qr_code_scanner_rounded,
              ),
              const SizedBox(height: AppDimensions.sm),
              AppOutlinedButton(
                label: selectedImage != null
                    ? 'Ganti Gambar'
                    : 'Pilih Gambar',
                onPressed: onPickImage,
                icon: Icons.add_photo_alternate_outlined,
              ),
            ],
          ),
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
                    // Edit overlay
                    Positioned(
                      top: AppDimensions.sm,
                      right: AppDimensions.sm,
                      child: Container(
                        padding: const EdgeInsets.all(AppDimensions.xs),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit_rounded,
                          color: Colors.white,
                          size: AppDimensions.iconSm,
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
                    const SizedBox(height: AppDimensions.md),
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
              Text('Mengunggah gambar...', style: AppTextStyles.titleLarge),
              const SizedBox(height: AppDimensions.md),
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
              const SizedBox(height: AppDimensions.sm),
              if (progress > 0)
                Text(
                  '${(progress * 100).toInt()}%',
                  style: AppTextStyles.labelMedium,
                ),
            ],
          ),
        ),
      );
}

class _ProcessingView extends StatelessWidget {
  const _ProcessingView({
    required this.imageUrl,
    required this.attempt,
    required this.maxAttempts,
  });

  final String imageUrl;
  final int attempt;
  final int maxAttempts;

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
              Text(
                'Proses ini memerlukan beberapa saat.\nMohon tunggu.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.xl),
              // Attempt indicator
              Text(
                'Percobaan ${attempt + 1} dari $maxAttempts',
                style: AppTextStyles.labelMedium,
              ),
              const SizedBox(height: AppDimensions.sm),
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusFull),
                child: LinearProgressIndicator(
                  value: maxAttempts > 0 ? (attempt + 1) / maxAttempts : null,
                  minHeight: 6,
                  backgroundColor: AppColors.surfaceAlt,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
        ),
      );
}

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
