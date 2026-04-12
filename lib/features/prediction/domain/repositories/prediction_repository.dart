import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:mobile_app/core/error/failures.dart';
import 'package:mobile_app/features/prediction/domain/entities/prediction.dart';

/// Kontrak repository fitur prediksi.
///
/// Semua method mengembalikan [Either<Failure, T>] — tidak boleh throw.
/// Implementation ada di layer infrastructure.
abstract class PredictionRepository {
  // ── Storage ─────────────────────────────────────────────────────────────

  /// Upload gambar ke storage backend.
  ///
  /// Return record `(imageUrl, fileKey)` yang dipakai untuk membuat prediksi.
  /// [onProgress] dipanggil saat upload berlangsung (bytes sent / total).
  Future<Either<Failure, ({String imageUrl, String fileKey})>> uploadImage(
    File image, {
    void Function(int sent, int total)? onProgress,
  });

  // ── Predictions ──────────────────────────────────────────────────────────

  /// Buat record prediksi baru (status awal: PENDING).
  ///
  /// Dipanggil setelah upload berhasil.
  Future<Either<Failure, Prediction>> createPrediction({
    required String imageUrl,
    required String fileKey,
  });

  /// Ambil detail prediksi berdasarkan ID.
  ///
  /// Dipakai untuk polling hingga status SUCCESS / FAILED.
  Future<Either<Failure, Prediction>> getPredictionById(String id);

  /// Ambil list prediksi milik user (paginated).
  Future<Either<Failure, PaginatedPredictions>> getPredictions({
    int page = 1,
    int limit = 10,
  });

  /// Hapus prediksi dan file terkait.
  Future<Either<Failure, void>> deletePrediction(String id);
}
