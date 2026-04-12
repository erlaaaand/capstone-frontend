import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/core/constants/app_constants.dart';
import 'package:mobile_app/features/prediction/application/prediction_list/prediction_list_event.dart';
import 'package:mobile_app/features/prediction/application/prediction_list/prediction_list_state.dart';
import 'package:mobile_app/features/prediction/domain/entities/prediction.dart';
import 'package:mobile_app/features/prediction/domain/use_cases/delete_prediction_use_case.dart';
import 'package:mobile_app/features/prediction/domain/use_cases/get_predictions_use_case.dart';

/// BLoC yang mengelola daftar prediksi (riwayat scan) dengan pagination.
///
/// Flow:
/// - [PredictionListFetched]          → load halaman 1
/// - [PredictionListNextPageFetched]  → load halaman n+1 (append)
/// - [PredictionListRefreshed]        → reset ke halaman 1
/// - [PredictionListItemDeleted]      → optimistic delete lalu konfirmasi ke API
class PredictionListBloc
    extends Bloc<PredictionListEvent, PredictionListState> {
  PredictionListBloc({
    required GetPredictionsUseCase getPredictionsUseCase,
    required DeletePredictionUseCase deletePredictionUseCase,
  })  : _getPredictionsUseCase = getPredictionsUseCase,
        _deletePredictionUseCase = deletePredictionUseCase,
        super(const PredictionListInitial()) {
    on<PredictionListFetched>(_onFetched);
    on<PredictionListNextPageFetched>(_onNextPageFetched);
    on<PredictionListRefreshed>(_onRefreshed);
    on<PredictionListItemDeleted>(_onItemDeleted);
  }

  final GetPredictionsUseCase _getPredictionsUseCase;
  final DeletePredictionUseCase _deletePredictionUseCase;

  // ── Event Handlers ─────────────────────────────────────────────────────────

  Future<void> _onFetched(
    PredictionListFetched event,
    Emitter<PredictionListState> emit,
  ) async {
    // Hindari double-fetch jika sudah ada data
    if (state is PredictionListPopulated) return;

    emit(const PredictionListLoading());
    await _fetchPage(1, emit, reset: true);
  }

  Future<void> _onNextPageFetched(
    PredictionListNextPageFetched event,
    Emitter<PredictionListState> emit,
  ) async {
    final current = state;
    if (current is! PredictionListPopulated) return;
    if (!current.hasNextPage || current.isLoadingMore) return;

    // Tampilkan loading more spinner
    emit(current.copyWith(isLoadingMore: true));
    await _fetchPage(current.currentPage + 1, emit, previousItems: current.items);
  }

  Future<void> _onRefreshed(
    PredictionListRefreshed event,
    Emitter<PredictionListState> emit,
  ) async {
    emit(const PredictionListLoading());
    await _fetchPage(1, emit, reset: true);
  }

  Future<void> _onItemDeleted(
    PredictionListItemDeleted event,
    Emitter<PredictionListState> emit,
  ) async {
    final current = state;
    if (current is! PredictionListPopulated) return;

    // Optimistic update: hapus dari list lokal dulu
    final updatedItems = current.items
        .where((p) => p.id != event.predictionId)
        .toList();
    emit(current.copyWith(items: updatedItems));

    // Konfirmasi ke API (fire-and-forget, error tidak di-surface ke UI)
    await _deletePredictionUseCase(DeletePredictionParams(event.predictionId));
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Future<void> _fetchPage(
    int page,
    Emitter<PredictionListState> emit, {
    bool reset = false,
    List<Prediction> previousItems = const [],
  }) async {
    final result = await _getPredictionsUseCase(
      GetPredictionsParams(
        page: page,
        limit: AppConstants.defaultPageSize,
      ),
    );

    result.fold(
      (failure) {
        emit(PredictionListFailure(
          failure: failure,
          previousItems: previousItems,
        ));
      },
      (paginated) {
        final newItems = reset
            ? paginated.items
            : [...previousItems, ...paginated.items];

        emit(PredictionListPopulated(
          items: newItems,
          hasNextPage: paginated.hasNextPage,
          currentPage: paginated.page,
        ));
      },
    );
  }
}
