import 'package:equatable/equatable.dart';

sealed class PredictionListEvent extends Equatable {
  const PredictionListEvent();
}

final class PredictionListFetched extends PredictionListEvent {
  const PredictionListFetched();

  @override
  List<Object?> get props => [];
}

final class PredictionListNextPageFetched extends PredictionListEvent {
  const PredictionListNextPageFetched();

  @override
  List<Object?> get props => [];
}

final class PredictionListRefreshed extends PredictionListEvent {
  const PredictionListRefreshed();

  @override
  List<Object?> get props => [];
}

final class PredictionListItemDeleted extends PredictionListEvent {
  const PredictionListItemDeleted(this.predictionId);

  final String predictionId;

  @override
  List<Object?> get props => [predictionId];
}
