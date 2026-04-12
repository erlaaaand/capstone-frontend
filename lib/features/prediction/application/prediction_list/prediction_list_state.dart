import 'package:equatable/equatable.dart';
import 'package:mobile_app/core/error/failures.dart';
import 'package:mobile_app/features/prediction/domain/entities/prediction.dart';

sealed class PredictionListState extends Equatable {
  const PredictionListState();
}

/// State awal — BLoC baru dibuat, belum ada fetch.
final class PredictionListInitial extends PredictionListState {
  const PredictionListInitial();

  @override
  List<Object?> get props => [];
}

/// Memuat halaman pertama (shimmer/skeleton tampil di UI).
final class PredictionListLoading extends PredictionListState {
  const PredictionListLoading();

  @override
  List<Object?> get props => [];
}

/// Data sudah dimuat — list bisa kosong atau berisi items.
///
/// [isLoadingMore] true saat sedang memuat halaman berikutnya
/// (pagination — spinner kecil di bawah list).
final class PredictionListPopulated extends PredictionListState {
  const PredictionListPopulated({
    required this.items,
    required this.hasNextPage,
    required this.currentPage,
    this.isLoadingMore = false,
  });

  final List<Prediction> items;

  /// Masih ada halaman berikutnya yang bisa di-load.
  final bool hasNextPage;

  /// Halaman terakhir yang sudah di-load.
  final int currentPage;

  /// Sedang memuat halaman berikutnya (infinite scroll).
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

/// Terjadi error saat fetch.
///
/// [previousItems] berisi data lama yang sudah ada (jika ada),
/// agar UI bisa tetap menampilkan data sebelumnya + pesan error inline.
final class PredictionListFailure extends PredictionListState {
  const PredictionListFailure({
    required this.failure,
    this.previousItems = const [],
  });

  final Failure failure;

  /// Item yang sudah dimuat sebelum error (bisa empty).
  final List<Prediction> previousItems;

  bool get hasPreviousData => previousItems.isNotEmpty;

  @override
  List<Object?> get props => [failure, previousItems];
}
