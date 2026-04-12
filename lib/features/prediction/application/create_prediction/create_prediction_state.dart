import 'package:equatable/equatable.dart';
import 'package:mobile_app/core/error/failures.dart';
import 'package:mobile_app/features/prediction/domain/entities/prediction.dart';

sealed class CreatePredictionState extends Equatable {
  const CreatePredictionState();
}

/// State awal — belum ada gambar dipilih, siap untuk memulai scan baru.
final class CreatePredictionInitial extends CreatePredictionState {
  const CreatePredictionInitial();

  @override
  List<Object?> get props => [];
}

/// Gambar sedang diupload ke storage.
///
/// [progress] = 0.0 (indeterminate) hingga 1.0 (selesai).
final class CreatePredictionUploading extends CreatePredictionState {
  const CreatePredictionUploading({this.progress = 0.0});

  /// Progress upload 0.0–1.0. Nilai 0 = indeterminate.
  final double progress;

  @override
  List<Object?> get props => [progress];
}

/// Record prediksi sudah dibuat (PENDING), menunggu AI selesai memproses.
///
/// BLoC akan polling secara periodik hingga [maxAttempts] tercapai.
final class CreatePredictionProcessing extends CreatePredictionState {
  const CreatePredictionProcessing({
    required this.predictionId,
    required this.attempt,
    required this.maxAttempts,
    required this.imageUrl,
  });

  final String predictionId;

  /// Percobaan polling saat ini (0-based).
  final int attempt;

  /// Batas maksimal percobaan polling (dari [AppConstants.predictionPollMaxAttempts]).
  final int maxAttempts;

  /// URL gambar yang diupload — ditampilkan di UI selama proses.
  final String imageUrl;

  /// Progress 0.0–1.0 berdasarkan jumlah percobaan.
  double get progress => maxAttempts > 0 ? attempt / maxAttempts : 0.0;

  @override
  List<Object?> get props => [predictionId, attempt, maxAttempts, imageUrl];
}

/// Prediksi berhasil — AI sudah mengembalikan hasil.
final class CreatePredictionSuccess extends CreatePredictionState {
  const CreatePredictionSuccess(this.prediction);

  final Prediction prediction;

  @override
  List<Object?> get props => [prediction];
}

/// Terjadi kegagalan di salah satu tahap (upload / create / polling).
final class CreatePredictionFailure extends CreatePredictionState {
  const CreatePredictionFailure(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
