import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/core/error/failures.dart';
import 'package:mobile_app/core/usecases/usecase.dart';
import 'package:mobile_app/features/ai_health/application/ai_health_state.dart';
import 'package:mobile_app/features/ai_health/domain/use_cases/get_current_ai_status_use_case.dart';
import 'package:mobile_app/features/ai_health/domain/use_cases/stream_ai_status_use_case.dart';

class AiHealthCubit extends Cubit<AiHealthState> {
  AiHealthCubit({
    required GetCurrentAiStatusUseCase getCurrentAiStatusUseCase,
    required StreamAiStatusUseCase streamAiStatusUseCase,
  })  : _getCurrentAiStatusUseCase = getCurrentAiStatusUseCase,
        _streamAiStatusUseCase = streamAiStatusUseCase,
        super(const AiHealthInitial());

  final GetCurrentAiStatusUseCase _getCurrentAiStatusUseCase;
  final StreamAiStatusUseCase _streamAiStatusUseCase;

  StreamSubscription<dynamic>? _sseSubscription;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;

  // ── REST ──────────────────────────────────────────────────────────────────

  Future<void> fetchCurrentStatus() async {
    if (isClosed) return;

    final wasStreaming =
        state is AiHealthLoaded && (state as AiHealthLoaded).isStreaming;

    emit(const AiHealthChecking());

    final result = await _getCurrentAiStatusUseCase();

    if (isClosed) return;

    result.fold(
      (failure) => emit(AiHealthFailure(failure: failure)),
      (status) => emit(AiHealthLoaded(
        aiStatus: status,
        isStreaming: wasStreaming,
      )),
    );
  }

  // ── SSE (Stream) ──────────────────────────────────────────────────────────
  
  void startStatusStream() {
    if (_sseSubscription != null) return;
    _reconnectTimer?.cancel();

    _sseSubscription = _streamAiStatusUseCase(const NoParams()).listen(
      (either) {
        if (isClosed) return;

        either.fold(
          (failure) {
            _handleStreamDisconnection(failure);
          },
          (status) {
            _reconnectAttempts = 0; // Reset percobaan jika berhasil konek
            if (!isClosed) {
              emit(AiHealthLoaded(aiStatus: status, isStreaming: true));
            }
          },
        );
      },
      onError: (Object error) {
        if (isClosed) return;
        _handleStreamDisconnection(const _StreamLostFailure());
      },
      onDone: () {
        if (isClosed) return;
        _handleStreamDisconnection(const _StreamLostFailure());
      },
      cancelOnError: true,
    );
  }

  void stopStatusStream() {
    _cancelSseSubscription();
    _reconnectTimer?.cancel();
    _reconnectAttempts = 0;
    
    if (state is AiHealthLoaded) {
      emit((state as AiHealthLoaded).copyWith(isStreaming: false));
    }
  }

  void restartStatusStream() {
    stopStatusStream();
    startStatusStream();
  }

  // ── Auto-Reconnect Logic ──────────────────────────────────────────────────

  void _handleStreamDisconnection(Failure failure) {
    final lastStatus = _lastKnownStatus;
    _cancelSseSubscription();

    if (_reconnectAttempts < _maxReconnectAttempts) {
      _reconnectAttempts++;
      final delaySeconds = 2 * _reconnectAttempts; 

      emit(AiHealthStreamError(
        failure: _ReconnectingFailure(delaySeconds),
        lastKnownStatus: lastStatus,
      ));

      _reconnectTimer?.cancel();
      _reconnectTimer = Timer(Duration(seconds: delaySeconds), () {
        if (!isClosed) startStatusStream();
      });
    } else {
      emit(AiHealthStreamError(
        failure: failure,
        lastKnownStatus: lastStatus,
      ));
    }
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  Future<void> close() {
    _cancelSseSubscription();
    _reconnectTimer?.cancel();
    return super.close();
  }

  // ── Internal ──────────────────────────────────────────────────────────────

  void _cancelSseSubscription() {
    _sseSubscription?.cancel();
    _sseSubscription = null;
  }

  dynamic get _lastKnownStatus => switch (state) {
        AiHealthLoaded s      => s.aiStatus,
        AiHealthStreamError s => s.lastKnownStatus,
        _                     => null,
      };
}

// ── Internal Failures ────────────────────────────────────────────────────────
class _StreamLostFailure extends ServerFailure {
  const _StreamLostFailure()
      : super(message: 'Koneksi ke server AI terputus. Sentuh untuk mencoba lagi.');
}

class _ReconnectingFailure extends ServerFailure {
  const _ReconnectingFailure(int seconds)
      : super(message: 'Koneksi terputus. Mencoba menyambung kembali dalam $seconds detik...');
}