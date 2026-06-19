import 'dart:io';
import 'package:crypto/crypto.dart';

class ImageHashUtils {
  ImageHashUtils._();

  static Future<String> computeHash(File file) async {
    final bytes = await file.readAsBytes();
    return md5.convert(bytes).toString();
  }

  static Future<bool> isDuplicate(File fileA, File fileB) async {
    if (!fileA.existsSync() || !fileB.existsSync()) return false;
    if (fileA.lengthSync() != fileB.lengthSync()) return false;
    final hashA = await computeHash(fileA);
    final hashB = await computeHash(fileB);
    return hashA == hashB;
  }

  static Future<bool> matchesHash(File file, String savedHash) async {
    final hash = await computeHash(file);
    return hash == savedHash;
  }
}

class LastImageHashCache {
  LastImageHashCache._();

  static String? _lastHash;
  static String? _lastPredictionId;

  static String? get lastHash => _lastHash;

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
