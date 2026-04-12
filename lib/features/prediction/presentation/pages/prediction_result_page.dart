import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app/core/constants/app_constants.dart';
import 'package:mobile_app/core/router/route_names.dart';
import 'package:mobile_app/core/theme/app_colors.dart';
import 'package:mobile_app/core/theme/app_dimensions.dart';
import 'package:mobile_app/core/theme/app_text_styles.dart';
import 'package:mobile_app/core/widgets/app_button.dart';
import 'package:mobile_app/core/widgets/app_loading_overlay.dart';
import 'package:mobile_app/features/prediction/domain/entities/prediction.dart';
import 'package:mobile_app/features/prediction/presentation/widgets/confidence_gauge.dart';
import 'package:mobile_app/features/prediction/presentation/widgets/durian_variety_card.dart';
import 'package:mobile_app/features/prediction/presentation/widgets/prediction_status_badge.dart';

/// Halaman detail hasil prediksi.
///
/// Dapat diakses dari dua kondisi:
/// 1. Navigasi dari [ScanPage] setelah sukses — menerima [Prediction] via `extra`
/// 2. Navigasi dari [PredictionHistoryPage] — menerima [Prediction] via `extra`
///
/// Route: `/app/scan/result/:predictionId`
class PredictionResultPage extends StatelessWidget {
  const PredictionResultPage({
    super.key,
    required this.predictionId,
    this.prediction,
  });

  /// ID prediksi dari path parameter.
  final String predictionId;

  /// Objek prediksi, dikirim via GoRouter `extra` untuk menghindari refetch.
  final Prediction? prediction;

  @override
  Widget build(BuildContext context) {
    if (prediction == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Hasil Prediksi')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: AppColors.error,
                size: AppDimensions.iconXxl,
              ),
              const SizedBox(height: AppDimensions.md),
              Text(
                'Data prediksi tidak tersedia.',
                style: AppTextStyles.headlineSmall,
              ),
              const SizedBox(height: AppDimensions.xl),
              AppButton(
                label: 'Kembali ke Scan',
                onPressed: () => context.goNamed(RouteNames.scan),
                isFullWidth: false,
              ),
            ],
          ),
        ),
      );
    }

    final p = prediction!;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: CustomScrollView(
        slivers: [
          // ── SliverAppBar dengan gambar durian ─────────────────────────────
          SliverAppBar(
            expandedHeight: AppDimensions.imagePreviewHeight,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: _HeroImage(imageUrl: p.imageUrl),
              title: Text(
                'Hasil Prediksi',
                style: AppTextStyles.titleLarge.copyWith(
                  color: AppColors.white,
                  shadows: [
                    const Shadow(
                      color: Colors.black54,
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: AppDimensions.md),
                child: Center(
                  child: PredictionStatusBadge.fromString(p.status.value),
                ),
              ),
            ],
          ),

          // ── Konten ────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.pagePaddingH,
                AppDimensions.lg,
                AppDimensions.pagePaddingH,
                AppDimensions.xxl,
              ),
              child: p.isSuccess && p.predictedClass != null
                  ? _SuccessContent(prediction: p)
                  : p.isFailed
                      ? _FailedContent(prediction: p)
                      : _PendingContent(prediction: p),
            ),
          ),
        ],
      ),

      // ── Bottom action bar ────────────────────────────────────────────────
      bottomNavigationBar: _BottomBar(prediction: p),
    );
  }
}

// ── Content sections ──────────────────────────────────────────────────────────

class _SuccessContent extends StatelessWidget {
  const _SuccessContent({required this.prediction});

  final Prediction prediction;

  @override
  Widget build(BuildContext context) {
    final p = prediction;
    final varietyName = AppConstants.durianVarietyNames[p.predictedClass] ??
        p.predictedClass ??
        'Tidak diketahui';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Kartu varietas utama ─────────────────────────────────────────
        DurianVarietyCard(
          varietyCode: p.predictedClass!,
          varietyName: varietyName,
          localName: null,
          origin: null,
          description: _varietyDescription(p.predictedClass!),
          imageUrl: p.imageUrl,
          confidenceWidget: ConfidenceGauge(
            score: p.confidence?.value ?? 0.0,
            varietyCode: p.predictedClass,
          ),
        ),
        const SizedBox(height: AppDimensions.xl),

        // ── Skor semua kelas ─────────────────────────────────────────────
        if (p.allScores != null && p.allScores!.isNotEmpty) ...[
          Text('Perbandingan Varietas', style: AppTextStyles.headlineSmall),
          const SizedBox(height: AppDimensions.md),
          _AllScoresSection(
            allScores: p.allScores!,
            predictedClass: p.predictedClass,
          ),
          const SizedBox(height: AppDimensions.xl),
        ],

        // ── Metadata ────────────────────────────────────────────────────
        _MetadataSection(prediction: p),
      ],
    );
  }

  String? _varietyDescription(String code) => switch (code) {
        'D197' =>
          'Musang King atau Mao Shan Wang adalah varietas premium asal Malaysia '
              'yang terkenal dengan rasa creamy, pahit manis yang seimbang, '
              'dan warna daging kuning emas.',
        'D24' =>
          'Sultan atau D24 adalah varietas klasik Malaysia dengan rasa manis '
              'dan sedikit pahit. Dagingnya lembut dengan tekstur creamy.',
        'D200' =>
          'Durian D200 dikenal dengan ukuran buah yang besar dan rasa yang '
              'kaya. Teksturnya lembut dengan rasa manis yang intens.',
        'D101' =>
          'Durian D101 memiliki daging berwarna kuning pucat hingga kuning. '
              'Rasanya manis dengan aroma yang harum dan khas.',
        'D13' =>
          'Durian D13 atau Kunyit memiliki warna daging kuning seperti '
              'kunyit. Rasanya manis dengan sedikit pahit yang menyegarkan.',
        'D2' =>
          'Durian D2 adalah varietas dengan cita rasa manis dan tekstur '
              'yang lembut. Cocok untuk pemula yang baru mengenal durian.',
        _ => null,
      };
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
          padding: const EdgeInsets.all(AppDimensions.md),
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
  const _FailedContent({required this.prediction});

  final Prediction prediction;

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
                  prediction.errorMessage ??
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

class _PendingContent extends StatelessWidget {
  const _PendingContent({required this.prediction});

  final Prediction prediction;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: AppDimensions.lg),
          Text(
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
            Text('Informasi Prediksi', style: AppTextStyles.titleMedium),
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

class _HeroImage extends StatelessWidget {
  const _HeroImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) => CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (_, __) =>
            const AppShimmer(width: double.infinity, height: double.infinity),
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

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.prediction});

  final Prediction prediction;

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
                  onPressed: () => context.goNamed(RouteNames.scan),
                  icon: Icons.qr_code_scanner_rounded,
                ),
              ),
            ],
          ),
        ),
      );
}
