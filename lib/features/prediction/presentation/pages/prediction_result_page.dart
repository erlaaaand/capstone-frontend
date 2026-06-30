// features/prediction/presentation/pages/prediction_result_page.dart
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app/core/constants/app_constants.dart';
import 'package:mobile_app/core/error/failures.dart';
import 'package:mobile_app/core/router/route_names.dart';
import 'package:mobile_app/core/theme/app_colors.dart';
import 'package:mobile_app/core/theme/app_dimensions.dart';
import 'package:mobile_app/core/theme/app_text_styles.dart';
import 'package:mobile_app/core/widgets/app_button.dart';
import 'package:mobile_app/core/widgets/app_loading_overlay.dart';
import 'package:mobile_app/features/prediction/application/create_prediction/create_prediction_bloc.dart';
import 'package:mobile_app/features/prediction/application/create_prediction/create_prediction_event.dart';
import 'package:mobile_app/features/prediction/application/create_prediction/create_prediction_state.dart';
import 'package:mobile_app/features/prediction/domain/entities/prediction.dart';
import 'package:mobile_app/features/prediction/domain/use_cases/get_prediction_by_id_use_case.dart';
import 'package:mobile_app/features/prediction/presentation/widgets/confidence_gauge.dart';
import 'package:mobile_app/features/prediction/presentation/widgets/durian_variety_card.dart';
import 'package:mobile_app/features/prediction/presentation/widgets/durian_variety_skeleton_card.dart';
import 'package:mobile_app/features/prediction/presentation/widgets/prediction_status_badge.dart';
import 'package:mobile_app/injection_container.dart';

class PredictionResultPageArgs {
  const PredictionResultPageArgs({
    this.prediction,
    this.localImageFile,
  });

  final Prediction? prediction;
  final File? localImageFile;
}

class PredictionResultPage extends StatefulWidget {
  const PredictionResultPage({
    super.key,
    required this.predictionId,
    this.args,
  });

  final String predictionId;
  final PredictionResultPageArgs? args;

  @override
  State<PredictionResultPage> createState() => _PredictionResultPageState();
}

class _PredictionResultPageState extends State<PredictionResultPage> {
  Prediction? _fetchedPrediction;
  bool _isLoading = false;
  String? _errorMsg;

  bool get _isLiveScan => widget.args?.localImageFile != null;

  @override
  void initState() {
    super.initState();
    if (!_isLiveScan && widget.args?.prediction == null) {
      _fetchPredictionDetail();
    }
  }

  Future<void> _fetchPredictionDetail() async {
    setState(() => _isLoading = true);

    try {
      final useCase = sl<GetPredictionByIdUseCase>();
      
      final result = await useCase(GetPredictionByIdParams(widget.predictionId));

      if (mounted) {
        setState(() {
          _isLoading = false;
          result.fold(
            (failure) => _errorMsg = failure.message,
            (prediction) => _fetchedPrediction = prediction,
          );
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMsg = 'Gagal memuat data sistem: \n$e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLiveScan) {
      if (_isLoading) {
        return Scaffold(
          appBar: AppBar(title: const Text('Memuat Detail...')),
          body: const Padding(
            padding: EdgeInsets.all(AppDimensions.pagePaddingH),
            child: DurianVarietySkeletonCard(),
          ),
        );
      }

      final prediction = _fetchedPrediction ?? widget.args?.prediction;

      if (prediction == null) {
        return Scaffold(
          appBar: AppBar(title: const Text('Hasil Prediksi')),
          body: Center(child: Text(_errorMsg ?? 'Data prediksi tidak ditemukan.')),
        );
      }

      return _ResultScaffold(
        heroImage: _HeroImage(imageUrl: prediction.imageUrl),
        statusBadge: PredictionStatusBadge(prediction: prediction),
        body: _bodyForFinalPrediction(prediction),
        bottomBar: const _NormalBottomBar(),
      );
    }

    // ── MODE LIVE SCAN ──
    final localImage = widget.args!.localImageFile!;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        final state = context.read<CreatePredictionBloc>().state;
        if (state is CreatePredictionUploading ||
            state is CreatePredictionProcessing) {
          context.read<CreatePredictionBloc>().add(
                const CreatePredictionCanceled(),
              );
        }
      },
      child: BlocBuilder<CreatePredictionBloc, CreatePredictionState>(
        builder: (context, state) => switch (state) {
          CreatePredictionSuccess(:final prediction) => _ResultScaffold(
              heroImage: _HeroImage(localFile: localImage),
              statusBadge: PredictionStatusBadge(prediction: prediction),
              body: _bodyForFinalPrediction(prediction),
              bottomBar: _NormalBottomBar(
                onScanLagi: () => _resetAndGoToScan(context),
              ),
            ),
          CreatePredictionFailure(:final failure) => _ResultScaffold(
              heroImage: _HeroImage(localFile: localImage),
              statusBadge: PredictionStatusBadge.fromString('FAILED'),
              body: _LiveFailedContent(
                failure: failure,
                onRetry: () => context
                    .read<CreatePredictionBloc>()
                    .add(CreatePredictionStarted(localImage)),
              ),
              bottomBar: _RetryBottomBar(
                onRetry: () => context
                    .read<CreatePredictionBloc>()
                    .add(CreatePredictionStarted(localImage)),
                onPickNew: () => _resetAndGoToScan(context),
              ),
            ),
          _ => _ResultScaffold(
              heroImage: _HeroImage(localFile: localImage),
              statusBadge: PredictionStatusBadge.fromString('PENDING'),
              body: const DurianVarietySkeletonCard(),
              bottomBar: _CancelBottomBar(
                onCancel: () {
                  context
                      .read<CreatePredictionBloc>()
                      .add(const CreatePredictionCanceled());
                  context.pop();
                },
              ),
            ),
        },
      ),
    );
  }

  void _resetAndGoToScan(BuildContext context) {
    context.read<CreatePredictionBloc>().add(const CreatePredictionReset());
    context.goNamed(RouteNames.scan);
  }

  Widget _bodyForFinalPrediction(Prediction p) {
    if (p.isStrictSuccess && p.predictedClass != null) {
      return _SuccessContent(prediction: p);
    }
    if (p.isFailed || (p.isSuccess && !p.hasHighConfidence)) {
      return _FailedContent(
        prediction: p,
        customMessage: (p.isSuccess && !p.hasHighConfidence)
            ? 'Hasil prediksi tidak meyakinkan. Mohon foto ulang dengan pencahayaan yang lebih baik.'
            : null,
      );
    }
    return _PendingContent(prediction: p);
  }
}

// ── Scaffold reusable ──────────────────────────────────────────────────────────

class _ResultScaffold extends StatelessWidget {
  const _ResultScaffold({
    required this.heroImage,
    required this.statusBadge,
    required this.body,
    required this.bottomBar,
  });

  final Widget heroImage;
  final Widget statusBadge;
  final Widget body;
  final Widget bottomBar;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: AppDimensions.imagePreviewHeight,
              pinned: true,
              backgroundColor: AppColors.primary,
              flexibleSpace: FlexibleSpaceBar(
                background: heroImage,
                title: Text(
                  'Hasil Prediksi',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.white,
                    shadows: const [
                      Shadow(color: Colors.black54, blurRadius: 8),
                    ],
                  ),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: AppDimensions.md),
                  child: Center(
                    child: statusBadge,
                  ),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.pagePaddingH,
                  AppDimensions.lg,
                  AppDimensions.pagePaddingH,
                  AppDimensions.xxl,
                ),
                child: body,
              ),
            ),
          ],
        ),
        bottomNavigationBar: bottomBar,
      );
}

// ── Hero Image (dual source: File lokal atau URL) ─────────────────────────────

class _HeroImage extends StatelessWidget {
  const _HeroImage({this.imageUrl, this.localFile});

  final String? imageUrl;
  final File? localFile;

  @override
  Widget build(BuildContext context) {
    if (localFile != null) {
      return Image.file(localFile!, fit: BoxFit.cover);
    }
    if (imageUrl != null) {
      return CachedNetworkImage(
        imageUrl: imageUrl!,
        fit: BoxFit.cover,
        placeholder: (_, __) => const AppShimmer(
          width: double.infinity,
          height: double.infinity,
        ),
        errorWidget: (_, __, ___) => Container(
          color: AppColors.surfaceAlt,
          child: const Icon(
            Icons.broken_image_outlined,
            size: AppDimensions.iconXl,
            color: AppColors.textHint,
          ),
        ),
      );
    }
    return Container(color: AppColors.surfaceAlt);
  }
}

// ── Content sections (mode final / riwayat) ───────────────────────────────────

class _SuccessContent extends StatelessWidget {
  const _SuccessContent({required this.prediction});

  final Prediction prediction;

  @override
  Widget build(BuildContext context) {
    final p = prediction;
    final varietyName = p.predictedClass != null 
        ? (AppConstants.durianVarietyNames[p.predictedClass] ?? p.predictedClass!)
        : 'Tidak diketahui';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DurianVarietyCard(
          varietyCode: p.predictedClass ?? '',
          varietyName: varietyName,
          localName: p.localName, 
          origin: p.origin,
          description: p.description ?? 'Deskripsi varietas tidak tersedia.',
          imageUrl: p.imageUrl,
          confidenceWidget: ConfidenceGauge(
            score: p.confidence?.value ?? 0.0,
            varietyCode: p.predictedClass,
          ),
          marketPriceSummary: p.marketPriceSummary,
        ),
        const SizedBox(height: AppDimensions.xl),

        if (p.allScores != null && p.allScores!.isNotEmpty) ...[
          const Text('Perbandingan Varietas', style: AppTextStyles.headlineSmall),
          const SizedBox(height: AppDimensions.md),
          _AllScoresSection(
            allScores: p.allScores!,
            predictedClass: p.predictedClass,
          ),
          const SizedBox(height: AppDimensions.xl),
        ],

        _MetadataSection(prediction: p),
      ],
    );
  }
}

class _AllScoresSection extends StatelessWidget {
  const _AllScoresSection({
    required this.allScores,
    required this.predictedClass,
  });

  final Map<String, double> allScores;
  final String? predictedClass;

  @override
  Widget build(BuildContext context) {
    final sorted = allScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: sorted.map((entry) {
        final isTop = entry.key == predictedClass;
        return Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.sm),
          child: _ScoreBar(
            code: entry.key,
            score: entry.value,
            isHighlighted: isTop,
            varietyName:
                AppConstants.durianVarietyNames[entry.key] ?? entry.key,
          ),
        );
      }).toList(),
    );
  }
}

class _ScoreBar extends StatefulWidget {
  const _ScoreBar({
    required this.code,
    required this.score,
    required this.isHighlighted,
    required this.varietyName,
  });

  final String code;
  final double score;
  final bool isHighlighted;
  final String varietyName;

  @override
  State<_ScoreBar> createState() => _ScoreBarState();
}

class _ScoreBarState extends State<_ScoreBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _anim = Tween<double>(begin: 0, end: widget.score).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _anim,
        builder: (_, __) => Container(
          padding: EdgeInsets.all(AppDimensions.md),
          decoration: BoxDecoration(
            color: widget.isHighlighted
                ? AppColors.primary.withOpacity(0.08)
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            border: Border.all(
              color: widget.isHighlighted
                  ? AppColors.primary.withOpacity(0.3)
                  : AppColors.divider,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    widget.code,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: widget.isHighlighted
                          ? AppColors.primaryDark
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.sm),
                  Expanded(
                    child: Text(
                      widget.varietyName,
                      style: AppTextStyles.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${(_anim.value * 100).toStringAsFixed(1)}%',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: widget.isHighlighted
                          ? AppColors.primaryDark
                          : AppColors.textSecondary,
                      fontWeight: widget.isHighlighted
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.xs),
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusFull),
                child: LinearProgressIndicator(
                  value: _anim.value,
                  minHeight: 6,
                  backgroundColor: AppColors.divider,
                  color: widget.isHighlighted
                      ? AppColors.primary
                      : AppColors.textHint,
                ),
              ),
            ],
          ),
        ),
      );
}

class _FailedContent extends StatelessWidget {
  const _FailedContent({
    required this.prediction,
    this.customMessage,
  });

  final Prediction prediction;
  final String? customMessage;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.xl),
            decoration: BoxDecoration(
              color: AppColors.errorLight,
              borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.cancel_outlined,
                  color: AppColors.error,
                  size: AppDimensions.iconXxl,
                ),
                const SizedBox(height: AppDimensions.md),
                Text(
                  'AI Gagal Menganalisis',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.error,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.sm),
                Text(
                  customMessage ?? prediction.errorMessage ??
                      'Terjadi kesalahan saat memproses gambar. '
                          'Pastikan gambar menampilkan durian dengan jelas.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.xl),
          _MetadataSection(prediction: prediction),
        ],
      );
}

class _LiveFailedContent extends StatelessWidget {
  const _LiveFailedContent({required this.failure, required this.onRetry});

  final Failure failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(AppDimensions.xl),
        decoration: BoxDecoration(
          color: AppColors.errorLight,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.cancel_outlined,
              color: AppColors.error,
              size: AppDimensions.iconXxl,
            ),
            const SizedBox(height: AppDimensions.md),
            Text(
              'AI Gagal Menganalisis',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.sm),
            Text(
              failure.message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
}

class _PendingContent extends StatelessWidget {
  const _PendingContent({required this.prediction});

  final Prediction prediction;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: AppDimensions.lg),
          const Text(
            'Sedang diproses...',
            style: AppTextStyles.headlineSmall,
          ),
          const SizedBox(height: AppDimensions.sm),
          Text(
            'AI masih menganalisis gambar Anda.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.xl),
          _MetadataSection(prediction: prediction),
        ],
      );
}

class _MetadataSection extends StatelessWidget {
  const _MetadataSection({required this.prediction});

  final Prediction prediction;

  String _formatDate(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(AppDimensions.md),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Informasi Prediksi', style: AppTextStyles.titleMedium),
            const Divider(height: AppDimensions.lg),
            _MetaRow(
              label: 'ID',
              value: prediction.id.substring(0, 8).toUpperCase(),
            ),
            const SizedBox(height: AppDimensions.xs),
            _MetaRow(
              label: 'Waktu Scan',
              value: _formatDate(prediction.createdAt),
            ),
            const SizedBox(height: AppDimensions.xs),
            _MetaRow(
              label: 'Diperbarui',
              value: _formatDate(prediction.updatedAt),
            ),
          ],
        ),
      );
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textHint,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: AppTextStyles.bodySmall),
          ),
        ],
      );
}

// ── Bottom bars ───────────────────────────────────────────────────────────────

class _NormalBottomBar extends StatelessWidget {
  const _NormalBottomBar({this.onScanLagi});

  final VoidCallback? onScanLagi;

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.pagePaddingH,
            AppDimensions.sm,
            AppDimensions.pagePaddingH,
            AppDimensions.md,
          ),
          child: Row(
            children: [
              Expanded(
                child: AppOutlinedButton(
                  label: 'Riwayat',
                  onPressed: () =>
                      context.goNamed(RouteNames.predictionHistory),
                  icon: Icons.history_rounded,
                ),
              ),
              const SizedBox(width: AppDimensions.sm),
              Expanded(
                child: AppButton(
                  label: 'Scan Lagi',
                  onPressed: onScanLagi ??
                      () => context.goNamed(RouteNames.scan),
                  icon: Icons.qr_code_scanner_rounded,
                ),
              ),
            ],
          ),
        ),
      );
}

class _CancelBottomBar extends StatelessWidget {
  const _CancelBottomBar({required this.onCancel});

  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.pagePaddingH,
            AppDimensions.sm,
            AppDimensions.pagePaddingH,
            AppDimensions.md,
          ),
          child: AppOutlinedButton(
            label: 'Batalkan Scan',
            onPressed: onCancel,
            icon: Icons.close_rounded,
          ),
        ),
      );
}

class _RetryBottomBar extends StatelessWidget {
  const _RetryBottomBar({
    required this.onRetry,
    required this.onPickNew,
  });

  final VoidCallback onRetry;
  final VoidCallback onPickNew;

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.pagePaddingH,
            AppDimensions.sm,
            AppDimensions.pagePaddingH,
            AppDimensions.md,
          ),
          child: Row(
            children: [
              Expanded(
                child: AppOutlinedButton(
                  label: 'Scan Baru',
                  onPressed: onPickNew,
                  icon: Icons.add_photo_alternate_outlined,
                ),
              ),
              const SizedBox(width: AppDimensions.sm),
              Expanded(
                child: AppButton(
                  label: 'Coba Lagi',
                  onPressed: onRetry,
                  icon: Icons.refresh_rounded,
                ),
              ),
            ],
          ),
        ),
      );
}