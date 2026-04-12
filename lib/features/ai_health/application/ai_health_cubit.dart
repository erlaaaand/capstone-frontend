import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/core/error/failures.dart';
import 'package:mobile_app/core/usecases/usecase.dart';
import 'package:mobile_app/features/ai_health/application/ai_health_state.dart';
import 'package:mobile_app/features/ai_health/domain/use_cases/get_current_ai_status_use_case.dart';
import 'package:mobile_app/features/ai_health/domain/use_cases/stream_ai_status_use_case.dart';

/// Mengelola state status AI service.
///
/// Dua mode operasi:
/// 1. **REST** (`fetchCurrentStatus`) — satu kali, untuk initial check.
/// 2. **SSE** (`startStatusStream`)   — real-time, long-lived.
///
/// Dipanggil dari halaman yang membutuhkan AI availability info (ScanPage, AppBar).
///
/// ```dart
/// // Di ScanPage initState / BlocProvider:
/// context.read<AiHealthCubit>()
///   ..fetchCurrentStatus()
///   ..startStatusStream();
///
/// // Di BlocBuilder:
/// switch (state) {
///   AiHealthLoaded s => AiStatusBanner(
///       isOffline: s.showBanner,
///       message: s.aiStatus.displayMessage,
///       onRetry: () => context.read<AiHealthCubit>().fetchCurrentStatus(),
///     ),
///   AiHealthChecking() => const LinearProgressIndicator(),
///   _ => const SizedBox.shrink(),
/// }
/// ```
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

  // ── REST ──────────────────────────────────────────────────────────────────

  /// Ambil snapshot status AI satu kali via REST.
  ///
  /// Aman dipanggil berulang (retry, app resume).
  /// Tidak membatalkan SSE subscription yang sedang berjalan.
  Future<void> fetchCurrentStatus() async {
    if (isClosed) return;

    final wasStreaming =
        state is AiHealthLoaded && (state as AiHealthLoaded).isStreaming;

    emit(const AiHealthChecking());

    final result = await _getCurrentAiStatusUseCase();

    if (isClosed) return;

    result.fold(
      (failure) => emit(AiHealthFailure(failure: failure)),
      (status)  => emit(AiHealthLoaded(
        aiStatus: status,
        isStreaming: wasStreaming,
      )),
    );
  }

  // ── SSE ───────────────────────────────────────────────────────────────────

  /// Mulai subscription SSE untuk update real-time.
  ///
  /// Jika subscription sudah aktif, method ini adalah no-op.
  /// Gunakan [restartStatusStream] untuk force reconnect.
  void startStatusStream() {
    if (_sseSubscription != null) return;

    _sseSubscription = _streamAiStatusUseCase(const NoParams()).listen(
      (either) {
        if (isClosed) return;

        either.fold(
          (failure) {
            // Error dari stream — simpan status terakhir jika ada
            final lastStatus = _lastKnownStatus;
            _cancelSseSubscription();
            emit(AiHealthStreamError(
              failure: failure,
              lastKnownStatus: lastStatus,
            ));
          },
          (status) {
            if (!isClosed) {
              emit(AiHealthLoaded(aiStatus: status, isStreaming: true));
            }
          },
        );
      },
      onError: (Object error) {
        if (isClosed) return;
        final lastStatus = _lastKnownStatus;
        _cancelSseSubscription();
        emit(AiHealthStreamError(
          failure: const _StreamLostFailure(),
          lastKnownStatus: lastStatus,
        ));
      },
      onDone: () {
        if (isClosed) return;
        _cancelSseSubscription();
        // Server menutup stream — tandai tidak lagi streaming
        if (state is AiHealthLoaded) {
          emit((state as AiHealthLoaded).copyWith(isStreaming: false));
        }
      },
      cancelOnError: true,
    );
  }

  /// Hentikan SSE subscription.
  void stopStatusStream() => _cancelSseSubscription();

  /// Stop lalu start ulang SSE (untuk reconnect setelah error).
  void restartStatusStream() {
    _cancelSseSubscription();
    startStatusStream();
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  Future<void> close() {
    _cancelSseSubscription();
    return super.close();
  }

  // ── Internal ──────────────────────────────────────────────────────────────

  void _cancelSseSubscription() {
    _sseSubscription?.cancel();
    _sseSubscription = null;
  }

  /// Ambil status terakhir yang diketahui dari state saat ini.
  dynamic get _lastKnownStatus => switch (state) {
        AiHealthLoaded s       => s.aiStatus,
        AiHealthStreamError s  => s.lastKnownStatus,
        _                      => null,
      };
}

// ── Internal Failure ──────────────────────────────────────────────────────────

/// Digunakan secara internal di [AiHealthCubit] ketika SSE stream
/// terputus tanpa pesan error dari server.
///
/// Extends [ServerFailure] sehingga tidak perlu menambah sealed case baru
/// di [Failure] hierarchy yang sudah ada di core.
class _StreamLostFailure extends ServerFailure {
  const _StreamLostFailure()
      : super(message: 'Koneksi status AI terputus. Data mungkin tidak terkini.');
}
