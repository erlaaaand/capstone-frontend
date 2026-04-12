import 'dart:io';

import 'package:mobile_app/core/constants/app_constants.dart';
import 'package:mobile_app/core/error/exceptions.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;

/// Utility untuk validasi dan manipulasi file gambar sebelum upload.
class FileUtils {
  FileUtils._();

  /// Validasi file sesuai constraint API:
  /// - Format: JPG, PNG, WebP
  /// - Ukuran: maks 5 MB
  ///
  /// Melempar [InvalidFileException] jika tidak valid.
  static void validateImage(File file) {
    // Cek file exists
    if (!file.existsSync()) {
      throw const InvalidFileException(message: 'File tidak ditemukan.');
    }

    // Cek ukuran
    final sizeBytes = file.lengthSync();
    if (sizeBytes == 0) {
      throw const InvalidFileException(message: 'File kosong atau rusak.');
    }
    if (sizeBytes > AppConstants.maxUploadSizeBytes) {
      final sizeMb = (sizeBytes / (1024 * 1024)).toStringAsFixed(2);
      throw InvalidFileException(
        message: 'Ukuran file ${sizeMb}MB melebihi batas 5MB.',
      );
    }

    // Cek MIME type berdasarkan konten file (bukan hanya ekstensi)
    final mimeType = lookupMimeType(file.path);
    if (mimeType == null ||
        !AppConstants.allowedMimeTypes.contains(mimeType)) {
      throw InvalidFileException(
        message: 'Format tidak didukung ($mimeType). '
            'Gunakan JPG, PNG, atau WebP.',
      );
    }
  }

  /// Ambil nama file dari path.
  static String getFileName(String filePath) => path.basename(filePath);

  /// Ambil ekstensi file (tanpa titik, lowercase).
  static String getExtension(String filePath) =>
      path.extension(filePath).replaceFirst('.', '').toLowerCase();

  /// Ambil MIME type berdasarkan path.
  static String? getMimeType(String filePath) => lookupMimeType(filePath);

  /// Format ukuran bytes ke string yang mudah dibaca.
  static String formatFileSize(int bytes) {
    if (bytes < 1024)        return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}
