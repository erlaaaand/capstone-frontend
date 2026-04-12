import 'dart:convert';

/// Utility untuk encode/decode fileKey yang diperlukan oleh
/// endpoint `DELETE /api/v1/storage/:fileKey`.
///
/// Sesuai dokumentasi API:
/// > `fileKey` harus di-encode sebagai **base64url** sebelum dimasukkan ke URL
/// > untuk menghindari konflik dengan path separator (`/`).
///
/// Contoh:
/// ```
/// Input : "predictions/userId/abc123.jpg"
/// Output: "cHJlZGljdGlvbnMvdXNlcklkL2FiYzEyMy5qcGc="
/// ```
class Base64Utils {
  Base64Utils._();

  /// Encode [fileKey] ke base64url-safe string.
  ///
  /// Menggunakan `base64Url` agar karakter `+` dan `/` tidak
  /// conflik dengan URL separator.
  static String encodeFileKey(String fileKey) {
    final bytes = utf8.encode(fileKey);
    return base64Url.encode(bytes);
  }

  /// Decode base64url string kembali ke fileKey asli.
  static String decodeFileKey(String encoded) {
    final bytes = base64Url.decode(encoded);
    return utf8.decode(bytes);
  }
}
