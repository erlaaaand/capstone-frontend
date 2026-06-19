import 'package:equatable/equatable.dart';
import 'package:mobile_app/core/error/failures.dart';
import 'package:mobile_app/features/prediction/domain/entities/prediction.dart';

sealed class PredictionListState extends Equatable {
  const PredictionListState();
}

final class PredictionListInitial extends PredictionListState {
  const PredictionListInitial();

  @override
  List<Object?> get props => [];
}

final class PredictionListLoading extends PredictionListState {
  const PredictionListLoading();

  @override
  List<Object?> get props => [];
}

final class PredictionListPopulated extends PredictionListState {
  const PredictionListPopulated({
    required this.items,
    required this.hasNextPage,
    required this.currentPage,
    this.isLoadingMore = false,
  });

  final List<Prediction> items;

  final bool hasNextPage;

  final int currentPage;

  final bool isLoadingMore;

  bool get isEmpty => items.isEmpty;

  PredictionListPopulated copyWith({
    List<Prediction>? items,
    bool? hasNextPage,
    int? currentPage,
    bool? isLoadingMore,
  }) =>
      PredictionListPopulated(
        items: items ?? this.items,
        hasNextPage: hasNextPage ?? this.hasNextPage,
        currentPage: currentPage ?? this.currentPage,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      );

  @override
  List<Object?> get props => [items, hasNextPage, currentPage, isLoadingMore];
}

final class PredictionListFailure extends PredictionListState {
  const PredictionListFailure({
    required this.failure,
    this.previousItems = const [],
  });

  final Failure failure;

  final List<Prediction> previousItems;

  bool get hasPreviousData => previousItems.isNotEmpty;

  @override
  List<Object?> get props => [failure, previousItems];
}
