import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/core/constants/app_constants.dart';
import 'package:mobile_app/core/error/failures.dart';
import 'package:mobile_app/features/prediction/application/create_prediction/create_prediction_event.dart';
import 'package:mobile_app/features/prediction/application/create_prediction/create_prediction_state.dart';
import 'package:mobile_app/features/prediction/domain/use_cases/create_prediction_use_case.dart';
import 'package:mobile_app/features/prediction/domain/use_cases/get_prediction_by_id_use_case.dart';

/// BLoC yang mengelola alur lengkap pembuatan prediksi:
///
/// 1. [CreatePredictionStarted] → Upload gambar + buat record PENDING
/// 2. [CreatePredictionPolled]  → Cek status setiap interval
/// 3. [CreatePredictionReset]   → Kembali ke initial, batalkan polling
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

    // Step 1: Upload + Create
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
          // Langka tapi mungkin: prediksi selesai sangat cepat
          if (prediction.isSuccess) {
            emit(CreatePredictionSuccess(prediction));
          } else {
            emit(CreatePredictionFailure(
              PredictionFailedFailure(
                message: prediction.errorMessage ??
                    'AI gagal memproses gambar.',
              ),
            ));
          }
        } else {
          // Normal: mulai polling
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

    // Timeout jika sudah melebihi batas
    if (_pollAttempt >= AppConstants.predictionPollMaxAttempts) {
      _cancelPolling();
      emit(const CreatePredictionFailure(PredictionTimeoutFailure()));
      return;
    }

    // Update attempt counter di state
    final current = state;
    if (current is CreatePredictionProcessing) {
      emit(CreatePredictionProcessing(
        predictionId: current.predictionId,
        attempt: _pollAttempt,
        maxAttempts: AppConstants.predictionPollMaxAttempts,
        imageUrl: current.imageUrl,
      ));
    }

    // Cek status prediksi
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
              message: prediction.errorMessage ??
                  'AI gagal memproses gambar.',
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
        if (!isClosed) {
          add(CreatePredictionPolled(predictionId));
        }
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
    
    // Tangkap keyword error dari backend dan ubah pesannya
    if (rawMessage.toLowerCase().contains('bukan gambar buah durian') || 
        rawMessage.toLowerCase().contains('ditolak')) {
      return 'Maaf, ini bukan durian.'; // 👈 Pesan singkat yang kamu inginkan
    }
    
    // Jika ada error lain, tampilkan apa adanya
    return rawMessage;
  }
}
