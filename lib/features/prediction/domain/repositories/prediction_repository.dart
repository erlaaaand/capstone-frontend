import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:mobile_app/core/error/failures.dart';
import 'package:mobile_app/features/prediction/domain/entities/prediction.dart';

abstract class PredictionRepository {
  // ── Storage ─────────────────────────────────────────────────────────────

  Future<Either<Failure, ({String imageUrl, String fileKey})>> uploadImage(
    File image, {
    void Function(int sent, int total)? onProgress,
  });

  // ── Predictions ──────────────────────────────────────────────────────────
  Future<Either<Failure, Prediction>> createPrediction({
    required String imageUrl,
    required String fileKey,
  });

  Future<Either<Failure, Prediction>> getPredictionById(String id);

  Future<Either<Failure, PaginatedPredictions>> getPredictions({
    int page = 1,
    int limit = 10,
  });

  Future<Either<Failure, void>> deletePrediction(String id);
}
