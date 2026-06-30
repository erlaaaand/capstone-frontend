// features/prediction/application/create_prediction/create_prediction_event.dart
import 'dart:io';
import 'package:equatable/equatable.dart';

sealed class CreatePredictionEvent extends Equatable {
  const CreatePredictionEvent();
}

final class CreatePredictionStarted extends CreatePredictionEvent {
  const CreatePredictionStarted(this.imageFile);

  final File imageFile;

  @override
  List<Object?> get props => [imageFile.path];
}

final class CreatePredictionCanceled extends CreatePredictionEvent {
  const CreatePredictionCanceled();

  @override
  List<Object?> get props => [];
}

final class CreatePredictionReset extends CreatePredictionEvent {
  const CreatePredictionReset();

  @override
  List<Object?> get props => [];
}