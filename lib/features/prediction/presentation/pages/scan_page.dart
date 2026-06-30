// features/prediction/presentation/pages/scan_page.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_app/core/router/route_names.dart';
import 'package:mobile_app/core/theme/app_dimensions.dart';
import 'package:mobile_app/core/utils/file_utils.dart';
import 'package:mobile_app/core/widgets/app_button.dart';
import 'package:mobile_app/core/widgets/app_snackbar.dart';
import 'package:mobile_app/core/widgets/theme_toggle_button.dart';
import 'package:mobile_app/features/ai_health/application/ai_health_cubit.dart';
import 'package:mobile_app/features/ai_health/application/ai_health_state.dart';
import 'package:mobile_app/features/ai_health/presentation/widgets/ai_status_banner.dart';
import 'package:mobile_app/features/ai_health/presentation/widgets/ai_status_indicator.dart';
import 'package:mobile_app/features/prediction/application/create_prediction/create_prediction_bloc.dart';
import 'package:mobile_app/features/prediction/application/create_prediction/create_prediction_event.dart';
import 'package:mobile_app/features/ai_health/domain/entities/ai_status.dart';
import 'package:mobile_app/features/prediction/presentation/pages/prediction_result_page.dart'
    show PredictionResultPageArgs;

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;

  Future<void> _captureFromCamera() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 2048,
      );
      if (picked != null && mounted) {
        setState(() => _selectedImage = File(picked.path));
      }
    } catch (_) {
      if (mounted) {
        AppSnackBar.showError(
          context,
          'Gagal membuka kamera. Periksa izin aplikasi.',
        );
      }
    }
  }

  void _startScan() {
    final image = _selectedImage;
    if (image == null || !_isAiReady()) return;

    context.read<CreatePredictionBloc>().add(CreatePredictionStarted(image));

    context.pushNamed(
      RouteNames.predictionResult,
      pathParameters: const {'predictionId': 'pending'},
      extra: PredictionResultPageArgs(localImageFile: image),
    );

    setState(() => _selectedImage = null);
  }

  bool _isAiReady() {
    final aiState = context.read<AiHealthCubit>().state;
    if (aiState is AiHealthLoaded) return aiState.aiStatus.canScan;
    return true;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: const Text('Scan Durian'),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            const ThemeToggleButton(),
            const SizedBox(width: 8),
            BlocBuilder<AiHealthCubit, AiHealthState>(
              builder: (context, aiState) {
                AiStatusValue indicatorValue = AiStatusValue.checking;

                if (aiState is AiHealthLoaded) {
                  indicatorValue = switch (aiState.aiStatus.status) {
                    AiServiceStatus.online  => AiStatusValue.online,
                    AiServiceStatus.offline => AiStatusValue.offline,
                    AiServiceStatus.loading => AiStatusValue.checking,
                  };
                } else if (aiState is AiHealthStreamError || aiState is AiHealthFailure) {
                  indicatorValue = AiStatusValue.offline;
                }

                return Padding(
                  padding: const EdgeInsets.only(right: AppDimensions.md),
                  child: Center(
                    child: AiStatusIndicator(
                      status: indicatorValue,
                      showLabel: false,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
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
            Expanded(
              child: _InitialView(
                selectedImage: _selectedImage,
                onCapture: _captureFromCamera,
                onStartScan: _selectedImage != null && _isAiReady()
                    ? _startScan
                    : null,
                isAiReady: _isAiReady(),
              ),
            ),
          ],
        ),
      );
}

// ── Initial View ──────────────────────────────────────────────────────────────

class _InitialView extends StatelessWidget {
  const _InitialView({
    required this.selectedImage,
    required this.onCapture,
    required this.onStartScan,
    required this.isAiReady,
  });

  final File? selectedImage;
  final VoidCallback onCapture;
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
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.xs),
              Text(
                'Ambil foto durian dengan kamera untuk\nmengetahui varietasnya secara akurat.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.xl),

              Expanded(
                child: _CameraPreviewArea(
                  selectedImage: selectedImage,
                  onTap: onCapture,
                ),
              ),

              if (selectedImage != null) ...[
                const SizedBox(height: AppDimensions.md),
                _FileMetadataChip(file: selectedImage!),
              ],

              const SizedBox(height: AppDimensions.lg),

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
                label: selectedImage != null ? 'Foto Ulang' : 'Buka Kamera',
                onPressed: onCapture,
                icon: Icons.camera_alt_outlined,
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
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.md,
          vertical: AppDimensions.xs,
        ),
        decoration: BoxDecoration(
          // Menggunakan secondaryContainer agar aman di Dark Mode
          color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.5),
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_outlined,
              size: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: AppDimensions.xs),
            Flexible(
              child: Text(
                FileUtils.getFileName(file.path),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: AppDimensions.xs),
            Text(
              '· ${FileUtils.formatFileSize(file.lengthSync())}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
                  ),
            ),
          ],
        ),
      );
}

class _AiOfflineHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.md,
          vertical: AppDimensions.sm,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        child: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Theme.of(context).colorScheme.onErrorContainer,
              size: 16,
            ),
            const SizedBox(width: AppDimensions.xs),
            Expanded(
              child: Text(
                'AI sedang offline. Scan tidak tersedia saat ini.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
              ),
            ),
          ],
        ),
      );
}

class _CameraPreviewArea extends StatelessWidget {
  const _CameraPreviewArea({
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
                : Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
            border: Border.all(
              color: selectedImage != null
                  ? Colors.transparent
                  : Theme.of(context).colorScheme.primary.withOpacity(0.35),
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
                          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.camera_alt_rounded,
                                color: Colors.white, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              'Foto Ulang',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
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
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.camera_alt_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: AppDimensions.iconXl,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.md),
                    Text(
                      'Tap untuk buka kamera',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    const SizedBox(height: AppDimensions.xs),
                    Text(
                      'Pastikan durian terlihat jelas',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
        ),
      );
}