import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';

/// Utility untuk mendeteksi file gambar yang sama (duplikat)
/// berdasarkan MD5 hash dari konten file.
///
/// Digunakan sebelum upload untuk mencegah penyimpanan gambar berlebihan:
/// ```dart
/// final isDup = await ImageHashUtils.isDuplicate(newFile, lastFile);
/// if (isDup) { /* tampilkan dialog konfirmasi */ }
/// ```
class ImageHashUtils {
  ImageHashUtils._();

  /// Hitung MD5 hash dari konten file gambar.
  static Future<String> computeHash(File file) async {
    final bytes = await file.readAsBytes();
    return md5.convert(bytes).toString();
  }

  /// Bandingkan dua file — return true jika kontennya identik.
  static Future<bool> isDuplicate(File fileA, File fileB) async {
    if (!fileA.existsSync() || !fileB.existsSync()) return false;
    if (fileA.lengthSync() != fileB.lengthSync()) return false;
    final hashA = await computeHash(fileA);
    final hashB = await computeHash(fileB);
    return hashA == hashB;
  }

  /// Bandingkan file baru dengan hash yang sudah disimpan sebelumnya.
  static Future<bool> matchesHash(File file, String savedHash) async {
    final hash = await computeHash(file);
    return hash == savedHash;
  }
}

/// Menyimpan hash gambar terakhir yang di-upload secara in-memory
/// selama sesi berlangsung. Reset saat app restart.
class LastImageHashCache {
  LastImageHashCache._();

  static String? _lastHash;
  static String? _lastPredictionId;

  /// Hash gambar terakhir yang berhasil di-upload.
  static String? get lastHash => _lastHash;

  /// ID prediksi dari gambar terakhir (untuk referensi ke hasil sebelumnya).
  static String? get lastPredictionId => _lastPredictionId;

  static void save(String hash, String predictionId) {
    _lastHash = hash;
    _lastPredictionId = predictionId;
  }

  static void clear() {
    _lastHash = null;
    _lastPredictionId = null;
  }
}
