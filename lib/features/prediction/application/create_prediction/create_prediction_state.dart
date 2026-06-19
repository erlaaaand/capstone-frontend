// features/prediction/application/create_prediction/create_prediction_state.dart
import 'package:equatable/equatable.dart';
import 'package:mobile_app/core/error/failures.dart';
import 'package:mobile_app/features/prediction/domain/entities/prediction.dart';

sealed class CreatePredictionState extends Equatable {
  const CreatePredictionState();
}

final class CreatePredictionInitial extends CreatePredictionState {
  const CreatePredictionInitial();

  @override
  List<Object?> get props => [];
}

final class CreatePredictionUploading extends CreatePredictionState {
  const CreatePredictionUploading({this.progress = 0.0});

  final double progress;

  @override
  List<Object?> get props => [progress];
}

final class CreatePredictionProcessing extends CreatePredictionState {
  const CreatePredictionProcessing();

  @override
  List<Object?> get props => [];
}

final class CreatePredictionSuccess extends CreatePredictionState {
  const CreatePredictionSuccess(this.prediction);

  final Prediction prediction;

  @override
  List<Object?> get props => [prediction];
}

final class CreatePredictionFailure extends CreatePredictionState {
  const CreatePredictionFailure(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}