import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app/core/constants/app_constants.dart';
import 'package:mobile_app/core/router/route_names.dart';
import 'package:mobile_app/core/theme/app_colors.dart';
import 'package:mobile_app/core/theme/app_dimensions.dart';
import 'package:mobile_app/core/widgets/app_error_widget.dart';
import 'package:mobile_app/core/widgets/app_loading_overlay.dart';
import 'package:mobile_app/core/widgets/app_snackbar.dart';
import 'package:mobile_app/features/prediction/application/prediction_list/prediction_list_bloc.dart';
import 'package:mobile_app/features/prediction/application/prediction_list/prediction_list_event.dart';
import 'package:mobile_app/features/prediction/application/prediction_list/prediction_list_state.dart';
import 'package:mobile_app/features/prediction/domain/entities/prediction.dart';
import 'package:mobile_app/features/prediction/presentation/widgets/prediction_card.dart';

/// Halaman riwayat prediksi milik user.
///
/// Fitur:
/// - Infinite scroll (load more saat mendekati bawah)
/// - Pull-to-refresh
/// - Swipe-to-delete (via [PredictionCard])
/// - Empty state saat belum ada prediksi
class PredictionHistoryPage extends StatefulWidget {
  const PredictionHistoryPage({super.key});

  @override
  State<PredictionHistoryPage> createState() => _PredictionHistoryPageState();
}

class _PredictionHistoryPageState extends State<PredictionHistoryPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Load halaman pertama saat halaman dibuka
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
    // Trigger load more saat 80% dari bawah list
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (currentScroll >= maxScroll * 0.8) {
      context
          .read<PredictionListBloc>()
          .add(const PredictionListNextPageFetched());
    }
  }

  Future<void> _onRefresh() async {
    context
        .read<PredictionListBloc>()
        .add(const PredictionListRefreshed());
    // Tunggu hingga state berubah dari Loading
    await _waitForLoad();
  }

  Future<void> _waitForLoad() async {
    await Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return false;
      return context.read<PredictionListBloc>().state
          is PredictionListLoading;
    });
  }

  void _onDeleteItem(String predictionId) {
    context
        .read<PredictionListBloc>()
        .add(PredictionListItemDeleted(predictionId));
    AppSnackBar.showSuccess(context, 'Prediksi berhasil dihapus.');
  }

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<PredictionListBloc, PredictionListState>(
        listener: _listener,
        builder: (context, state) => Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
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
            :final isLoadingMore, :final isEmpty) =>
          isEmpty
              ? _EmptyView(
                  onScan: () => context.goNamed(RouteNames.scan),
                )
              : _PopulatedView(
                  items: items,
                  hasNextPage: hasNextPage,
                  isLoadingMore: isLoadingMore,
                  scrollController: _scrollController,
                  onDelete: _onDeleteItem,
                  onRefresh: _onRefresh,
                  onTapItem: (p) => context.goNamed(
                    RouteNames.predictionResult,
                    pathParameters: {'predictionId': p.id},
                    extra: p,
                  ),
                ),
        PredictionListFailure(:final failure, :final previousItems,
            :final hasPreviousData) =>
          hasPreviousData
              ? _PopulatedView(
                  items: previousItems,
                  hasNextPage: false,
                  isLoadingMore: false,
                  scrollController: _scrollController,
                  onDelete: _onDeleteItem,
                  onRefresh: _onRefresh,
                  onTapItem: (p) => context.goNamed(
                    RouteNames.predictionResult,
                    pathParameters: {'predictionId': p.id},
                    extra: p,
                  ),
                )
              : AppErrorWidget(
                  failure: failure,
                  onRetry: () => context
                      .read<PredictionListBloc>()
                      .add(const PredictionListFetched()),
                ),
      };
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

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.onScan});

  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) => AppEmptyWidget(
        icon: Icons.history_rounded,
        title: 'Belum Ada Riwayat',
        subtitle: 'Mulai scan durian pertamamu\nuntuk melihat hasilnya di sini.',
        actionLabel: 'Mulai Scan',
        onAction: onScan,
      );
}

class _PopulatedView extends StatelessWidget {
  const _PopulatedView({
    required this.items,
    required this.hasNextPage,
    required this.isLoadingMore,
    required this.scrollController,
    required this.onDelete,
    required this.onRefresh,
    required this.onTapItem,
  });

  final List<Prediction> items;
  final bool hasNextPage;
  final bool isLoadingMore;
  final ScrollController scrollController;
  final void Function(String id) onDelete;
  final Future<void> Function() onRefresh;
  final void Function(Prediction p) onTapItem;

  @override
  Widget build(BuildContext context) => RefreshIndicator(
        onRefresh: onRefresh,
        color: AppColors.primary,
        child: ListView.separated(
          controller: scrollController,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.pagePaddingH,
            vertical: AppDimensions.pagePaddingV,
          ),
          itemCount: items.length + (isLoadingMore ? 1 : 0),
          separatorBuilder: (_, __) =>
              const SizedBox(height: AppDimensions.sm),
          itemBuilder: (context, index) {
            // Load more indicator di item terakhir
            if (index == items.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: AppDimensions.md),
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2.5,
                  ),
                ),
              );
            }

            final prediction = items[index];
            return PredictionCard(
              id: prediction.id,
              imageUrl: prediction.imageUrl,
              status: prediction.status.value,
              createdAt: prediction.createdAt.toIso8601String(),
              varietyName: prediction.predictedClass != null
                  ? (AppConstants.durianVarietyNames[prediction.predictedClass] ??
                      prediction.predictedClass)
                  : null,
              confidenceScore: prediction.confidence?.value,
              onTap: () => onTapItem(prediction),
              onDelete: () => onDelete(prediction.id),
            );
          },
        ),
      );
}
