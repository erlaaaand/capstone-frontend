import 'package:equatable/equatable.dart';
import 'package:mobile_app/core/error/failures.dart';
import 'package:mobile_app/features/ai_health/domain/entities/ai_status.dart';
import 'package:mobile_app/features/ai_health/presentation/widgets/ai_status_indicator.dart';

/// State untuk [AiHealthCubit].
///
/// Flow REST (initial check):
/// ```
/// AiHealthInitial → AiHealthChecking → AiHealthLoaded
///                                    → AiHealthFailure
/// ```
///
/// Flow SSE (real-time stream):
/// ```
/// AiHealthLoaded → AiHealthLoaded (update)
///               → AiHealthStreamError (koneksi terputus, cubit tetap ada)
/// ```
sealed class AiHealthState extends Equatable {
  const AiHealthState();

  @override
  List<Object?> get props => [];
}

/// State awal sebelum ada pengecekan.
final class AiHealthInitial extends AiHealthState {
  const AiHealthInitial();
}

/// Sedang mengambil status (REST call atau reconnecting SSE).
final class AiHealthChecking extends AiHealthState {
  const AiHealthChecking();
}

/// Status AI berhasil diterima.
///
/// [isStreaming] = true jika sedang ada koneksi SSE aktif.
final class AiHealthLoaded extends AiHealthState {
  const AiHealthLoaded({
    required this.aiStatus,
    this.isStreaming = false,
  });

  final AiStatus aiStatus;

  /// Apakah sedang ada subscription SSE aktif.
  final bool isStreaming;

  /// Mapping ke [AiStatusValue] untuk widget presentasi.
  AiStatusValue get indicatorValue => switch (aiStatus.status) {
        AiServiceStatus.online  => AiStatusValue.online,
        AiServiceStatus.offline => AiStatusValue.offline,
        AiServiceStatus.loading => AiStatusValue.checking,
      };

  /// Apakah perlu menampilkan banner peringatan.
  bool get showBanner => !aiStatus.canScan;

  AiHealthLoaded copyWith({AiStatus? aiStatus, bool? isStreaming}) =>
      AiHealthLoaded(
        aiStatus: aiStatus ?? this.aiStatus,
        isStreaming: isStreaming ?? this.isStreaming,
      );

  @override
  List<Object?> get props => [aiStatus, isStreaming];
}

/// Pengecekan gagal (REST). State ini ditampilkan sebagai error penuh.
final class AiHealthFailure extends AiHealthState {
  const AiHealthFailure({required this.failure});

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

/// SSE stream terputus — status terakhir masih ada, tapi stream mati.
///
/// Cubit masih menyimpan status terakhir di layer atas sebagai konteks.
/// UI menampilkan warning kecil (bukan error penuh).
final class AiHealthStreamError extends AiHealthState {
  const AiHealthStreamError({
    required this.failure,
    this.lastKnownStatus,
  });

  final Failure failure;

  /// Status AI terakhir yang berhasil diterima sebelum stream terputus.
  final AiStatus? lastKnownStatus;

  @override
  List<Object?> get props => [failure, lastKnownStatus];
}
