import 'dart:io';

import 'package:mobile_app/core/constants/app_constants.dart';
import 'package:mobile_app/core/error/exceptions.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;

class FileUtils {
  FileUtils._();

  static void validateImage(File file) {
    if (!file.existsSync()) {
      throw const InvalidFileException(message: 'File tidak ditemukan.');
    }

    final sizeBytes = file.lengthSync();
    if (sizeBytes == 0) {
      throw const InvalidFileException(message: 'File kosong atau rusak.');
    }
    if (sizeBytes > AppConstants.maxUploadSizeBytes) {
      final sizeMb = (sizeBytes / (1024 * 1024)).toStringAsFixed(2);
      throw InvalidFileException(
        message: 'Ukuran file ${sizeMb}MB melebihi batas '
            '${AppConstants.maxUploadSizeMb}MB.',
      );
    }

    final mimeType = lookupMimeType(file.path);
    if (mimeType == null ||
        !AppConstants.allowedMimeTypes.contains(mimeType)) {
      throw InvalidFileException(
        message: 'Format tidak didukung ($mimeType). '
            'Gunakan JPG, PNG, atau WebP.',
      );
    }
  }

  static String getFileName(String filePath) => path.basename(filePath);

  static String getExtension(String filePath) =>
      path.extension(filePath).replaceFirst('.', '').toLowerCase();

  static String? getMimeType(String filePath) => lookupMimeType(filePath);

  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}