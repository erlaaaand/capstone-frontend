// features/prediction/application/create_prediction/create_prediction_bloc.dart
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/core/error/failures.dart';
import 'package:mobile_app/core/utils/image_hash_utils.dart';
import 'package:mobile_app/features/prediction/application/create_prediction/create_prediction_event.dart';
import 'package:mobile_app/features/prediction/application/create_prediction/create_prediction_state.dart';
import 'package:mobile_app/features/prediction/domain/use_cases/create_prediction_use_case.dart';

class CreatePredictionBloc
    extends Bloc<CreatePredictionEvent, CreatePredictionState> {
  CreatePredictionBloc({
    required CreatePredictionUseCase createPredictionUseCase,
  })  : _createPredictionUseCase = createPredictionUseCase,
        super(const CreatePredictionInitial()) {
    on<CreatePredictionStarted>(_onStarted);
    on<CreatePredictionCanceled>(_onCanceled);
    on<CreatePredictionReset>(_onReset);
  }

  final CreatePredictionUseCase _createPredictionUseCase;

  CancelToken? _cancelToken;

  // ── Event Handlers ─────────────────────────────────────────────────────────

  Future<void> _onStarted(
    CreatePredictionStarted event,
    Emitter<CreatePredictionState> emit,
  ) async {
    _cancelToken = CancelToken();
    emit(const CreatePredictionUploading());

    final result = await _createPredictionUseCase(
      CreatePredictionParams(
        imageFile: event.imageFile,
        cancelToken: _cancelToken,
        onUploadProgress: (sent, total) {
          if (!isClosed && total > 0) {
            if (sent >= total) {
              emit(const CreatePredictionProcessing());
            } else {
              emit(CreatePredictionUploading(progress: sent / total));
            }
          }
        },
      ),
    );

    final wasCanceled = _cancelToken?.isCancelled ?? false;
    _cancelToken = null;

    if (isClosed) return;

    if (wasCanceled) {
      emit(const CreatePredictionInitial());
      return;
    }

    result.fold(
      (failure) => emit(CreatePredictionFailure(failure)),
      (prediction) {
        if (prediction.isSuccess) {
          ImageHashUtils.computeHash(event.imageFile).then((hash) {
            LastImageHashCache.save(hash, prediction.id);
          });
          emit(CreatePredictionSuccess(prediction));
        } else {
          emit(CreatePredictionFailure(
            PredictionFailedFailure(
              message: prediction.errorMessage ?? 'AI gagal memproses gambar.',
            ),
          ));
        }
      },
    );
  }

  void _onCanceled(
    CreatePredictionCanceled event,
    Emitter<CreatePredictionState> emit,
  ) {
    _cancelToken?.cancel('Dibatalkan oleh pengguna.');
  }

  void _onReset(
    CreatePredictionReset event,
    Emitter<CreatePredictionState> emit,
  ) {
    _cancelToken?.cancel('Direset oleh pengguna.');
    _cancelToken = null;
    emit(const CreatePredictionInitial());
  }

  @override
  Future<void> close() {
    _cancelToken?.cancel('Bloc ditutup.');
    return super.close();
  }
}