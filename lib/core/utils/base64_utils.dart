import 'dart:convert';

/// ```
class Base64Utils {
  Base64Utils._();

  static String encodeFileKey(String fileKey) {
    final bytes = utf8.encode(fileKey);
    return base64Url.encode(bytes);
  }

  static String decodeFileKey(String encoded) {
    final bytes = base64Url.decode(encoded);
    return utf8.decode(bytes);
  }
}
