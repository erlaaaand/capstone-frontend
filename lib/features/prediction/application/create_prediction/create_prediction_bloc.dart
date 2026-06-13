import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/core/constants/app_constants.dart';
import 'package:mobile_app/core/error/failures.dart';
import 'package:mobile_app/core/utils/image_hash_utils.dart';
import 'package:mobile_app/features/prediction/application/create_prediction/create_prediction_event.dart';
import 'package:mobile_app/features/prediction/application/create_prediction/create_prediction_state.dart';
import 'package:mobile_app/features/prediction/domain/use_cases/create_prediction_use_case.dart';
import 'package:mobile_app/features/prediction/domain/use_cases/get_prediction_by_id_use_case.dart';

/// BLoC yang mengelola alur lengkap pembuatan prediksi.
///
/// Upgrade v2:
/// - Setelah sukses, hash gambar disimpan ke [LastImageHashCache]
///   agar ScanPage dapat mendeteksi duplikasi pada scan berikutnya.
///
/// State transitions:
/// ```
/// Initial → Uploading(0%) → Uploading(100%) → Processing(0/N) → ... → Success
///                                                                     → Failure
/// ```
class CreatePredictionBloc
    extends Bloc<CreatePredictionEvent, CreatePredictionState> {
  CreatePredictionBloc({
    required CreatePredictionUseCase createPredictionUseCase,
    required GetPredictionByIdUseCase getPredictionByIdUseCase,
  })  : _createPredictionUseCase = createPredictionUseCase,
        _getPredictionByIdUseCase = getPredictionByIdUseCase,
        super(const CreatePredictionInitial()) {
    on<CreatePredictionStarted>(_onStarted);
    on<CreatePredictionPolled>(_onPolled);
    on<CreatePredictionReset>(_onReset);
  }

  final CreatePredictionUseCase _createPredictionUseCase;
  final GetPredictionByIdUseCase _getPredictionByIdUseCase;

  Timer? _pollTimer;
  int _pollAttempt = 0;

  @override
  Future<void> close() {
    _cancelPolling();
    return super.close();
  }

  // ── Event Handlers ─────────────────────────────────────────────────────────

  Future<void> _onStarted(
    CreatePredictionStarted event,
    Emitter<CreatePredictionState> emit,
  ) async {
    _cancelPolling();
    _pollAttempt = 0;

    emit(const CreatePredictionUploading());

    final result = await _createPredictionUseCase(
      CreatePredictionParams(
        imageFile: event.imageFile,
        onUploadProgress: (sent, total) {
          if (!isClosed && total > 0) {
            emit(CreatePredictionUploading(progress: sent / total));
          }
        },
      ),
    );

    result.fold(
      (failure) => emit(CreatePredictionFailure(failure)),
      (prediction) {
        if (prediction.isComplete) {
          if (prediction.isSuccess) {
            // Simpan hash gambar untuk deteksi duplikasi berikutnya
            ImageHashUtils.computeHash(event.imageFile).then((hash) {
              LastImageHashCache.save(hash, prediction.id);
            });
            emit(CreatePredictionSuccess(prediction));
          } else {
            emit(CreatePredictionFailure(
              PredictionFailedFailure(
                message: _getFriendlyErrorMessage(prediction.errorMessage),
              ),
            ));
          }
        } else {
          emit(CreatePredictionProcessing(
            predictionId: prediction.id,
            attempt: 0,
            maxAttempts: AppConstants.predictionPollMaxAttempts,
            imageUrl: prediction.imageUrl,
          ));
          _startPolling(prediction.id);
        }
      },
    );
  }

  Future<void> _onPolled(
    CreatePredictionPolled event,
    Emitter<CreatePredictionState> emit,
  ) async {
    _pollAttempt++;

    if (_pollAttempt >= AppConstants.predictionPollMaxAttempts) {
      _cancelPolling();
      emit(const CreatePredictionFailure(PredictionTimeoutFailure()));
      return;
    }

    final current = state;
    if (current is CreatePredictionProcessing) {
      emit(CreatePredictionProcessing(
        predictionId: current.predictionId,
        attempt: _pollAttempt,
        maxAttempts: AppConstants.predictionPollMaxAttempts,
        imageUrl: current.imageUrl,
      ));
    }

    final result = await _getPredictionByIdUseCase(
      GetPredictionByIdParams(event.predictionId),
    );

    result.fold(
      (failure) {
        _cancelPolling();
        emit(CreatePredictionFailure(failure));
      },
      (prediction) {
        if (prediction.isSuccess) {
          _cancelPolling();
          emit(CreatePredictionSuccess(prediction));
        } else if (prediction.isFailed) {
          _cancelPolling();
          emit(CreatePredictionFailure(
            PredictionFailedFailure(
              message: _getFriendlyErrorMessage(prediction.errorMessage),
            ),
          ));
        }
        // PENDING: lanjutkan polling
      },
    );
  }

  void _onReset(
    CreatePredictionReset event,
    Emitter<CreatePredictionState> emit,
  ) {
    _cancelPolling();
    _pollAttempt = 0;
    emit(const CreatePredictionInitial());
  }

  // ── Polling Helpers ────────────────────────────────────────────────────────

  void _startPolling(String predictionId) {
    _pollTimer = Timer.periodic(
      AppConstants.predictionPollInterval,
      (_) {
        if (!isClosed) add(CreatePredictionPolled(predictionId));
      },
    );
  }

  void _cancelPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  // ── Helper ─────────────────────────────────────────────────────────────────

  String _getFriendlyErrorMessage(String? rawMessage) {
    if (rawMessage == null) return 'AI gagal memproses gambar.';

    final lowerCaseMessage = rawMessage.toLowerCase();

    if (lowerCaseMessage.contains('bukan gambar buah durian') ||
        lowerCaseMessage.contains('ditolak')) {
      return 'Maaf, gambar ini tidak terdeteksi sebagai durian. '
          'Coba foto dengan sudut yang lebih jelas.';
    }

    if (lowerCaseMessage.contains('timeout') ||
        lowerCaseMessage.contains('timed out')) {
      return 'AI tidak merespons tepat waktu. Coba lagi dalam beberapa saat.';
    }

    if (lowerCaseMessage.contains('network') ||
        lowerCaseMessage.contains('connection')) {
      return 'Koneksi terputus saat memproses. Periksa jaringan dan coba lagi.';
    }

    return rawMessage;
  }
}