import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/features/storage/application/storage_state.dart';
import 'package:mobile_app/features/storage/domain/use_cases/delete_file_use_case.dart';
import 'package:mobile_app/features/storage/domain/use_cases/upload_image_use_case.dart';

/// Mengelola state operasi storage (upload & delete).
///
/// Digunakan oleh [ScanPage] untuk mengupload gambar sebelum memulai prediksi,
/// dan oleh [PredictionHistoryPage] / [PredictionResultPage] untuk menghapus
/// file ketika prediksi dihapus.
///
/// Contoh penggunaan di widget:
/// ```dart
/// BlocProvider(
///   create: (_) => sl<StorageCubit>(),
///   child: BlocConsumer<StorageCubit, StorageState>(
///     listener: (context, state) {
///       if (state is StorageUploadSuccess) {
///         // Lanjut ke prediksi dengan state.uploadedFile
///       }
///       if (state is StorageFailure) {
///         AppSnackBar.showError(context, state.failure.message);
///       }
///     },
///     builder: (context, state) { ... },
///   ),
/// )
/// ```
class StorageCubit extends Cubit<StorageState> {
  StorageCubit({
    required UploadImageUseCase uploadImageUseCase,
    required DeleteFileUseCase deleteFileUseCase,
  })  : _uploadImageUseCase = uploadImageUseCase,
        _deleteFileUseCase = deleteFileUseCase,
        super(const StorageInitial());

  final UploadImageUseCase _uploadImageUseCase;
  final DeleteFileUseCase _deleteFileUseCase;

  // ── Upload ────────────────────────────────────────────────────────────────

  /// Upload [file] ke storage server.
  ///
  /// Emit [StorageUploading] (progress null) → [StorageUploading] (0.0–1.0)
  /// → [StorageUploadSuccess] atau [StorageFailure].
  ///
  /// Pastikan file sudah divalidasi via [FileUtils.validateImage] sebelum
  /// memanggil method ini.
  Future<void> uploadImage(File file) async {
    emit(const StorageUploading());

    final result = await _uploadImageUseCase(
      UploadImageParams(
        file: file,
        onProgress: _onUploadProgress,
      ),
    );

    if (isClosed) return;

    result.fold(
      (failure) => emit(StorageFailure(failure: failure)),
      (uploadedFile) => emit(StorageUploadSuccess(uploadedFile: uploadedFile)),
    );
  }

  // ── Delete ────────────────────────────────────────────────────────────────

  /// Hapus file dari storage berdasarkan [fileKey].
  ///
  /// Emit [StorageDeleting] → [StorageDeleteSuccess] atau [StorageFailure].
  Future<void> deleteFile(String fileKey) async {
    emit(StorageDeleting(fileKey: fileKey));

    final result = await _deleteFileUseCase(
      DeleteFileParams(fileKey: fileKey),
    );

    if (isClosed) return;

    result.fold(
      (failure) => emit(StorageFailure(failure: failure)),
      (_) => emit(StorageDeleteSuccess(fileKey: fileKey)),
    );
  }

  // ── Reset ─────────────────────────────────────────────────────────────────

  /// Reset ke [StorageInitial]. Dipanggil saat user memilih ulang gambar
  /// atau meninggalkan halaman scan.
  void reset() {
    if (!isClosed) emit(const StorageInitial());
  }

  // ── Internal ──────────────────────────────────────────────────────────────

  void _onUploadProgress(double progress) {
    if (!isClosed) emit(StorageUploading(progress: progress));
  }
}