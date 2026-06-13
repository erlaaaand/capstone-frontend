import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app/core/constants/app_constants.dart';
import 'package:mobile_app/core/router/route_names.dart';
import 'package:mobile_app/core/theme/app_colors.dart';
import 'package:mobile_app/core/theme/app_dimensions.dart';
import 'package:mobile_app/core/theme/app_text_styles.dart';
import 'package:mobile_app/core/widgets/app_error_widget.dart';
import 'package:mobile_app/core/widgets/app_loading_overlay.dart';
import 'package:mobile_app/core/widgets/app_snackbar.dart';
import 'package:mobile_app/features/prediction/application/prediction_list/prediction_list_bloc.dart';
import 'package:mobile_app/features/prediction/application/prediction_list/prediction_list_event.dart';
import 'package:mobile_app/features/prediction/application/prediction_list/prediction_list_state.dart';
import 'package:mobile_app/features/prediction/domain/entities/prediction.dart';
import 'package:mobile_app/features/prediction/domain/value_objects/prediction_status.dart';
import 'package:mobile_app/features/prediction/presentation/widgets/prediction_card.dart';

/// Filter status untuk riwayat prediksi.
enum _HistoryFilter { all, success, failed, pending }

/// Halaman riwayat prediksi — versi upgrade.
///
/// Peningkatan:
/// - Stats card: total scan, berhasil, gagal
/// - Filter chip per status
/// - Empty state per filter
/// - Konfirmasi hapus sebelum dismiss
class PredictionHistoryPage extends StatefulWidget {
  const PredictionHistoryPage({super.key});

  @override
  State<PredictionHistoryPage> createState() => _PredictionHistoryPageState();
}

class _PredictionHistoryPageState extends State<PredictionHistoryPage> {
  final _scrollController = ScrollController();
  _HistoryFilter _activeFilter = _HistoryFilter.all;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<PredictionListBloc>().add(const PredictionListFetched());
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (currentScroll >= maxScroll * 0.8) {
      context
          .read<PredictionListBloc>()
          .add(const PredictionListNextPageFetched());
    }
  }

  Future<void> _onRefresh() async {
    context.read<PredictionListBloc>().add(const PredictionListRefreshed());
    await _waitForLoad();
  }

  Future<void> _waitForLoad() async {
    await Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return false;
      return context.read<PredictionListBloc>().state is PredictionListLoading;
    });
  }

  Future<void> _onDeleteItem(String predictionId) async {
    final confirmed = await _showDeleteConfirmation();
    if (!confirmed) return;
    if (!mounted) return;

    context
        .read<PredictionListBloc>()
        .add(PredictionListItemDeleted(predictionId));
    AppSnackBar.showSuccess(context, 'Prediksi berhasil dihapus.');
  }

  Future<bool> _showDeleteConfirmation() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        ),
        title: const Text('Hapus Prediksi?'),
        content: Text(
          'Prediksi dan gambar terkait akan dihapus permanen.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  List<Prediction> _applyFilter(List<Prediction> items) {
    return switch (_activeFilter) {
      _HistoryFilter.all => items,
      _HistoryFilter.success =>
        items.where((p) => p.status.isSuccess).toList(),
      _HistoryFilter.failed =>
        items.where((p) => p.status.isFailed).toList(),
      _HistoryFilter.pending =>
        items.where((p) => p.status.isPending).toList(),
    };
  }

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<PredictionListBloc, PredictionListState>(
        listener: _listener,
        builder: (context, state) => Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            title: const Text('Riwayat Scan'),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                onPressed: () => context
                    .read<PredictionListBloc>()
                    .add(const PredictionListRefreshed()),
                tooltip: 'Refresh',
              ),
            ],
          ),
          body: _buildBody(context, state),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => context.goNamed(RouteNames.scan),
            icon: const Icon(Icons.qr_code_scanner_rounded),
            label: const Text('Scan Baru'),
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
          ),
        ),
      );

  void _listener(BuildContext context, PredictionListState state) {
    if (state is PredictionListFailure && state.hasPreviousData) {
      AppSnackBar.showError(context, state.failure.message);
    }
  }

  Widget _buildBody(BuildContext context, PredictionListState state) =>
      switch (state) {
        PredictionListInitial() => const SizedBox.shrink(),
        PredictionListLoading() => _LoadingView(),
        PredictionListPopulated(:final items, :final hasNextPage,
            :final isLoadingMore) =>
          _buildPopulatedBody(
            context,
            items,
            hasNextPage,
            isLoadingMore,
          ),
        PredictionListFailure(:final failure, :final previousItems,
            :final hasPreviousData) =>
          hasPreviousData
              ? _buildPopulatedBody(context, previousItems, false, false)
              : AppErrorWidget(
                  failure: failure,
                  onRetry: () => context
                      .read<PredictionListBloc>()
                      .add(const PredictionListFetched()),
                ),
      };

  Widget _buildPopulatedBody(
    BuildContext context,
    List<Prediction> allItems,
    bool hasNextPage,
    bool isLoadingMore,
  ) {
    final filtered = _applyFilter(allItems);

    return Column(
      children: [
        // Stats card
        if (allItems.isNotEmpty)
          _StatsRow(items: allItems),

        // Filter chips
        if (allItems.isNotEmpty)
          _FilterChipRow(
            activeFilter: _activeFilter,
            items: allItems,
            onFilterChanged: (f) => setState(() => _activeFilter = f),
          ),

        Expanded(
          child: filtered.isEmpty
              ? _FilterEmptyView(filter: _activeFilter)
              : RefreshIndicator(
                  onRefresh: _onRefresh,
                  color: AppColors.primary,
                  child: ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(
                      AppDimensions.pagePaddingH,
                      AppDimensions.md,
                      AppDimensions.pagePaddingH,
                      AppDimensions.xxl,
                    ),
                    itemCount: filtered.length + (isLoadingMore ? 1 : 0),
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppDimensions.sm),
                    itemBuilder: (context, index) {
                      if (index == filtered.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: AppDimensions.md),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                              strokeWidth: 2.5,
                            ),
                          ),
                        );
                      }

                      final prediction = filtered[index];
                      return PredictionCard(
                        id: prediction.id,
                        imageUrl: prediction.imageUrl,
                        status: prediction.status.value,
                        createdAt: prediction.createdAt.toIso8601String(),
                        varietyName: prediction.predictedClass != null
                            ? (AppConstants.durianVarietyNames[
                                    prediction.predictedClass] ??
                                prediction.predictedClass)
                            : null,
                        confidenceScore: prediction.confidence?.value,
                        onTap: () => context.goNamed(
                          RouteNames.predictionResult,
                          pathParameters: {'predictionId': prediction.id},
                          extra: prediction,
                        ),
                        onDelete: () => _onDeleteItem(prediction.id),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}

// ── Stats Row ─────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.items});

  final List<Prediction> items;

  @override
  Widget build(BuildContext context) {
    final total = items.length;
    final success = items.where((p) => p.status.isSuccess).length;
    final failed = items.where((p) => p.status.isFailed).length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.pagePaddingH,
        AppDimensions.md,
        AppDimensions.pagePaddingH,
        0,
      ),
      child: Row(
        children: [
          _StatChip(
            label: 'Total Scan',
            value: '$total',
            color: AppColors.primary,
            bgColor: AppColors.primary.withOpacity(0.08),
          ),
          const SizedBox(width: AppDimensions.sm),
          _StatChip(
            label: 'Berhasil',
            value: '$success',
            color: AppColors.success,
            bgColor: AppColors.successLight,
          ),
          const SizedBox(width: AppDimensions.sm),
          _StatChip(
            label: 'Gagal',
            value: '$failed',
            color: AppColors.error,
            bgColor: AppColors.errorLight,
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
    required this.bgColor,
  });

  final String label;
  final String value;
  final Color color;
  final Color bgColor;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.sm,
            vertical: AppDimensions.sm,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          child: Column(
            children: [
              Text(
                value,
                style: AppTextStyles.headlineSmall.copyWith(color: color),
              ),
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: color.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
}

// ── Filter Chips ──────────────────────────────────────────────────────────────

class _FilterChipRow extends StatelessWidget {
  const _FilterChipRow({
    required this.activeFilter,
    required this.items,
    required this.onFilterChanged,
  });

  final _HistoryFilter activeFilter;
  final List<Prediction> items;
  final void Function(_HistoryFilter) onFilterChanged;

  int _count(_HistoryFilter f) => switch (f) {
        _HistoryFilter.all => items.length,
        _HistoryFilter.success =>
          items.where((p) => p.status.isSuccess).length,
        _HistoryFilter.failed =>
          items.where((p) => p.status.isFailed).length,
        _HistoryFilter.pending =>
          items.where((p) => p.status.isPending).length,
      };

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.pagePaddingH,
          vertical: AppDimensions.sm,
        ),
        child: Row(
          children: [
            _FilterChip(
              label: 'Semua (${_count(_HistoryFilter.all)})',
              isActive: activeFilter == _HistoryFilter.all,
              onTap: () => onFilterChanged(_HistoryFilter.all),
            ),
            const SizedBox(width: AppDimensions.xs),
            _FilterChip(
              label: 'Berhasil (${_count(_HistoryFilter.success)})',
              isActive: activeFilter == _HistoryFilter.success,
              activeColor: AppColors.success,
              onTap: () => onFilterChanged(_HistoryFilter.success),
            ),
            const SizedBox(width: AppDimensions.xs),
            _FilterChip(
              label: 'Gagal (${_count(_HistoryFilter.failed)})',
              isActive: activeFilter == _HistoryFilter.failed,
              activeColor: AppColors.error,
              onTap: () => onFilterChanged(_HistoryFilter.failed),
            ),
            const SizedBox(width: AppDimensions.xs),
            _FilterChip(
              label: 'Diproses (${_count(_HistoryFilter.pending)})',
              isActive: activeFilter == _HistoryFilter.pending,
              activeColor: AppColors.warning,
              onTap: () => onFilterChanged(_HistoryFilter.pending),
            ),
          ],
        ),
      );
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
    this.activeColor,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {
    final color = activeColor ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.md,
          vertical: AppDimensions.xs,
        ),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.1) : AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          border: Border.all(
            color: isActive ? color : AppColors.divider,
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: isActive ? color : AppColors.textSecondary,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ── Sub-views ─────────────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.pagePaddingH,
          vertical: AppDimensions.pagePaddingV,
        ),
        itemCount: 5,
        separatorBuilder: (_, __) =>
            const SizedBox(height: AppDimensions.sm),
        itemBuilder: (_, __) => const AppPredictionLoadingCard(),
      );
}

class _FilterEmptyView extends StatelessWidget {
  const _FilterEmptyView({required this.filter});

  final _HistoryFilter filter;

  @override
  Widget build(BuildContext context) {
    final message = switch (filter) {
      _HistoryFilter.all =>
        'Mulai scan durian pertamamu\nuntuk melihat hasilnya di sini.',
      _HistoryFilter.success => 'Belum ada prediksi yang berhasil.',
      _HistoryFilter.failed => 'Tidak ada prediksi yang gagal.',
      _HistoryFilter.pending => 'Tidak ada prediksi yang sedang diproses.',
    };

    return AppEmptyWidget(
      icon: Icons.history_rounded,
      title: 'Tidak Ada Data',
      subtitle: message,
    );
  }
}