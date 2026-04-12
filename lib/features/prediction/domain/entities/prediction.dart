import 'package:equatable/equatable.dart';
import 'package:mobile_app/features/prediction/domain/value_objects/confidence_score.dart';
import 'package:mobile_app/features/prediction/domain/value_objects/prediction_status.dart';

/// Entity prediksi durian di layer domain.
///
/// Tidak mengandung detail teknis (JSON, Dio, dll) — hanya data murni.
class Prediction extends Equatable {
  const Prediction({
    required this.id,
    required this.userId,
    required this.imageUrl,
    required this.fileKey,
    required this.status,
    this.predictedClass,
    this.confidence,
    this.allScores,
    this.errorMessage,
    required this.createdAt,
    required this.updatedAt,
  });

  /// UUID prediksi.
  final String id;

  /// UUID user pemilik prediksi.
  final String userId;

  /// URL gambar yang diupload (dapat digunakan langsung di Image widget).
  final String imageUrl;

  /// Key file di storage (untuk keperluan delete).
  final String fileKey;

  /// Status pemrosesan prediksi.
  final PredictionStatus status;

  /// Kode varietas yang diprediksi AI. Null jika masih PENDING.
  ///
  /// Contoh: `"D197"` untuk Musang King.
  final String? predictedClass;

  /// Confidence score prediksi. Null jika masih PENDING atau FAILED.
  final ConfidenceScore? confidence;

  /// Skor untuk semua kelas varietas. Null jika masih PENDING.
  ///
  /// Key = kode varietas, Value = score 0.0–1.0.
  final Map<String, double>? allScores;

  /// Pesan error dari AI jika status FAILED.
  final String? errorMessage;

  final DateTime createdAt;
  final DateTime updatedAt;

  // ── Convenience getters ────────────────────────────────────────────────────

  bool get isSuccess  => status.isSuccess;
  bool get isPending  => status.isPending;
  bool get isFailed   => status.isFailed;
  bool get isComplete => status.isComplete;

  @override
  List<Object?> get props => [
        id,
        userId,
        imageUrl,
        fileKey,
        status,
        predictedClass,
        confidence,
        allScores,
        errorMessage,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() =>
      'Prediction(id: $id, status: ${status.value}, class: $predictedClass)';
}

/// Hasil paginated list prediksi.
///
/// Digunakan di halaman riwayat dan use case [GetPredictionsUseCase].
class PaginatedPredictions extends Equatable {
  const PaginatedPredictions({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  final List<Prediction> items;
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  bool get hasNextPage => page < totalPages;
  bool get isFirstPage => page == 1;
  bool get isEmpty     => items.isEmpty;

  @override
  List<Object?> get props => [items, page, limit, total, totalPages];
}
