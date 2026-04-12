import 'package:equatable/equatable.dart';
import 'package:mobile_app/core/error/failures.dart';
import 'package:mobile_app/features/storage/domain/entities/uploaded_file.dart';

/// State untuk [StorageCubit].
///
/// Flow normal:
/// ```
/// StorageInitial
///   → StorageUploading(progress: null)
///   → StorageUploading(progress: 0.0 .. 1.0)   ← update berkala
///   → StorageUploadSuccess(uploadedFile: ...)
/// ```
///
/// Flow hapus file:
/// ```
/// StorageInitial / StorageUploadSuccess
///   → StorageDeleting(fileKey: ...)
///   → StorageDeleteSuccess(fileKey: ...)
/// ```
///
/// Flow error (dari state mana pun):
/// ```
///   → StorageFailure(failure: ...)
/// ```
sealed class StorageState extends Equatable {
  const StorageState();

  @override
  List<Object?> get props => [];
}

/// State awal / setelah reset.
final class StorageInitial extends StorageState {
  const StorageInitial();
}

/// Sedang mengupload — [progress] null = indeterminate, 0.0–1.0 = determinate.
final class StorageUploading extends StorageState {
  const StorageUploading({this.progress});

  /// Nilai upload progress: 0.0 (mulai) – 1.0 (selesai). Null = indeterminate.
  final double? progress;

  @override
  List<Object?> get props => [progress];
}

/// Upload berhasil. [uploadedFile] siap digunakan untuk membuat prediksi.
final class StorageUploadSuccess extends StorageState {
  const StorageUploadSuccess({required this.uploadedFile});

  final UploadedFile uploadedFile;

  @override
  List<Object?> get props => [uploadedFile];
}

/// Sedang menghapus file dengan [fileKey] tertentu.
final class StorageDeleting extends StorageState {
  const StorageDeleting({required this.fileKey});

  final String fileKey;

  @override
  List<Object?> get props => [fileKey];
}

/// Hapus file berhasil.
final class StorageDeleteSuccess extends StorageState {
  const StorageDeleteSuccess({required this.fileKey});

  final String fileKey;

  @override
  List<Object?> get props => [fileKey];
}

/// Operasi gagal. [failure] berisi pesan siap tampil di UI.
final class StorageFailure extends StorageState {
  const StorageFailure({required this.failure});

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}