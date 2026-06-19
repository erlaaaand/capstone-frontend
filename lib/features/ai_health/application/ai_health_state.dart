import 'package:equatable/equatable.dart';
import 'package:mobile_app/core/error/failures.dart';
import 'package:mobile_app/features/ai_health/domain/entities/ai_status.dart';
import 'package:mobile_app/features/ai_health/presentation/widgets/ai_status_indicator.dart';

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

  AiStatusValue get indicatorValue => switch (aiStatus.status) {
        AiServiceStatus.online  => AiStatusValue.online,
        AiServiceStatus.offline => AiStatusValue.offline,
        AiServiceStatus.loading => AiStatusValue.checking,
      };

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

  @override
  List<Object?> get props => [failure, lastKnownStatus];
}
