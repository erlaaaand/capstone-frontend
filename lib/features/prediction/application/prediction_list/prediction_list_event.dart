import 'package:equatable/equatable.dart';

sealed class PredictionListEvent extends Equatable {
  const PredictionListEvent();
}

/// Load halaman pertama riwayat prediksi.
///
/// Dikirim saat halaman pertama kali dibuka.
final class PredictionListFetched extends PredictionListEvent {
  const PredictionListFetched();

  @override
  List<Object?> get props => [];
}

/// Load halaman berikutnya (infinite scroll / pagination).
///
/// Diabaikan jika tidak ada halaman berikutnya atau sedang loading.
final class PredictionListNextPageFetched extends PredictionListEvent {
  const PredictionListNextPageFetched();

  @override
  List<Object?> get props => [];
}

/// Refresh list dari awal (pull-to-refresh).
final class PredictionListRefreshed extends PredictionListEvent {
  const PredictionListRefreshed();

  @override
  List<Object?> get props => [];
}

/// Hapus prediksi dari list (swipe-to-delete).
///
/// Menggunakan optimistic update — item dihapus dari UI terlebih dahulu.
final class PredictionListItemDeleted extends PredictionListEvent {
  const PredictionListItemDeleted(this.predictionId);

  final String predictionId;

  @override
  List<Object?> get props => [predictionId];
}
