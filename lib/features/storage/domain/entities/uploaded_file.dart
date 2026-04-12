import 'package:equatable/equatable.dart';

/// Representasi file yang berhasil di-upload ke storage.
///
/// Returned dari [StorageRepository.uploadImage] dan digunakan
/// oleh [PredictionRepository] untuk membuat prediksi baru.
class UploadedFile extends Equatable {
  const UploadedFile({
    required this.fileKey,
    required this.url,
    required this.originalName,
    required this.mimeType,
    required this.size,
  });

  /// Key unik file di storage (mis. `predictions/userId/abc123.jpg`).
  /// Digunakan sebagai referensi untuk DELETE dan membuat prediksi.
  final String fileKey;

  /// URL publik / presigned untuk akses file.
  final String url;

  /// Nama file asli yang di-upload oleh user.
  final String originalName;

  /// MIME type file (mis. `image/jpeg`).
  final String mimeType;

  /// Ukuran file dalam bytes.
  final int size;

  @override
  List<Object?> get props => [fileKey, url, originalName, mimeType, size];

  @override
  String toString() =>
      'UploadedFile(fileKey: $fileKey, originalName: $originalName, '
      'size: $size, mimeType: $mimeType)';
}
