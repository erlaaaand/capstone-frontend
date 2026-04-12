import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:mobile_app/core/error/failures.dart';
import 'package:mobile_app/features/storage/domain/entities/uploaded_file.dart';

/// Kontrak repository untuk operasi storage.
///
/// Implementasi ada di [StorageRepositoryImpl] (layer infrastructure).
/// Use case hanya bergantung pada abstraksi ini — tidak pernah langsung
/// ke data source ataupun Dio.
abstract class StorageRepository {
  /// Upload gambar ke storage server.
  ///
  /// [file] — file yang sudah divalidasi via [FileUtils.validateImage].
  /// [onProgress] — callback opsional dengan nilai 0.0–1.0 untuk progress bar.
  ///
  /// Return [UploadedFile] yang berisi [fileKey] dan [url].
  ///
  /// Possible failures:
  /// - [FileTooLargeFailure] → HTTP 413
  /// - [UnsupportedFileFailure] → HTTP 422
  /// - [InvalidFileFailure] → validasi lokal gagal
  /// - [NoInternetFailure] → tidak ada koneksi
  /// - [TimeoutFailure] → upload timeout
  /// - [UnauthorizedFailure] → HTTP 401
  /// - [ServerFailure] → error lainnya
  Future<Either<Failure, UploadedFile>> uploadImage(
    File file, {
    void Function(double progress)? onProgress,
  });

  /// Hapus file dari storage berdasarkan [fileKey].
  ///
  /// [fileKey] — key file asli (BUKAN yang sudah di-encode).
  /// Encoding base64url dilakukan di layer infrastructure.
  ///
  /// Possible failures:
  /// - [NoInternetFailure]
  /// - [UnauthorizedFailure] → HTTP 401
  /// - [ServerFailure] → HTTP 404 / lainnya
  Future<Either<Failure, void>> deleteFile(String fileKey);
}
