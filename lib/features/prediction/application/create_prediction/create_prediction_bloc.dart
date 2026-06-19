// features/prediction/application/create_prediction/create_prediction_bloc.dart
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
    on<CreatePredictionReset>(_onReset);
  }

  final CreatePredictionUseCase _createPredictionUseCase;

  // ── Event Handlers ─────────────────────────────────────────────────────────

  Future<void> _onStarted(
    CreatePredictionStarted event,
    Emitter<CreatePredictionState> emit,
  ) async {
    emit(const CreatePredictionUploading());

    final result = await _createPredictionUseCase(
      CreatePredictionParams(
        imageFile: event.imageFile,
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

    if (isClosed) return;

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
              message: _getFriendlyErrorMessage(prediction.errorMessage),
            ),
          ));
        }
      },
    );
  }

  void _onReset(
    CreatePredictionReset event,
    Emitter<CreatePredictionState> emit,
  ) {
    emit(const CreatePredictionInitial());
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