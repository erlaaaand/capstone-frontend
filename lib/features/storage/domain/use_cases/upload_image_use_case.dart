import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile_app/core/error/failures.dart';
import 'package:mobile_app/core/usecases/usecase.dart';
import 'package:mobile_app/features/storage/domain/entities/uploaded_file.dart';
import 'package:mobile_app/features/storage/domain/repositories/storage_repository.dart';

/// Upload gambar ke storage dan kembalikan [UploadedFile].
///
/// Dipanggil dari [StorageCubit] sebelum membuat prediksi baru.
/// Validasi file (ukuran, format) dilakukan sebelum use case ini dipanggil
/// (di [FileUtils.validateImage] atau [AppImagePickerSheet]).
///
/// ```dart
/// final result = await uploadImageUseCase(
///   UploadImageParams(
///     file: file,
///     onProgress: (p) => print('${(p * 100).toInt()}%'),
///   ),
/// );
/// ```
class UploadImageUseCase extends UseCase<UploadedFile, UploadImageParams> {
  UploadImageUseCase(this._repository);

  final StorageRepository _repository;

  @override
  Future<Either<Failure, UploadedFile>> call(UploadImageParams params) =>
      _repository.uploadImage(
        params.file,
        onProgress: params.onProgress,
      );
}

/// Parameter untuk [UploadImageUseCase].
class UploadImageParams extends Equatable {
  const UploadImageParams({
    required this.file,
    this.onProgress,
  });

  /// File gambar yang akan di-upload.
  final File file;

  /// Callback progress upload (0.0 – 1.0). Opsional.
  ///
  /// Tidak diikutkan dalam [props] karena fungsi tidak bisa di-compare.
  final void Function(double progress)? onProgress;

  @override
  List<Object?> get props => [file.path];
}
