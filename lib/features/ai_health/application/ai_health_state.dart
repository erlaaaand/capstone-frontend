import 'package:equatable/equatable.dart';
import 'package:mobile_app/core/error/failures.dart';
import 'package:mobile_app/features/ai_health/domain/entities/ai_status.dart';

sealed class AiHealthState extends Equatable {
  const AiHealthState();

  @override
  List<Object?> get props => [];
}

final class AiHealthInitial extends AiHealthState {
  const AiHealthInitial();
}

final class AiHealthChecking extends AiHealthState {
  const AiHealthChecking();
}

final class AiHealthLoaded extends AiHealthState {
  const AiHealthLoaded({
    required this.aiStatus,
    this.isStreaming = false,
  });

  final AiStatus aiStatus;
  final bool isStreaming;

  bool get showBanner => !aiStatus.canScan;

  AiHealthLoaded copyWith({AiStatus? aiStatus, bool? isStreaming}) =>
      AiHealthLoaded(
        aiStatus: aiStatus ?? this.aiStatus,
        isStreaming: isStreaming ?? this.isStreaming,
      );

  @override
  List<Object?> get props => [aiStatus, isStreaming];
}

final class AiHealthFailure extends AiHealthState {
  const AiHealthFailure({required this.failure});

  final Failure failure;

  String get displayMessage =>
      failure.message.isNotEmpty ? failure.message : 'Terjadi kesalahan.';

  @override
  List<Object?> get props => [failure];
}

final class AiHealthStreamError extends AiHealthState {
  const AiHealthStreamError({
    required this.failure,
    this.lastKnownStatus,
  });

  final Failure failure;
  final AiStatus? lastKnownStatus;

  String get displayMessage =>
      failure.message.isNotEmpty ? failure.message : 'Koneksi stream terputus.';

  bool get isReconnecting => failure.message.contains('Mencoba menyambung');

  @override
  List<Object?> get props => [failure, lastKnownStatus];
}