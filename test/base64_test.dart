import 'package:mobile_app/core/utils/base64_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Base64Utils', () {
    group('encodeFileKey', () {
      test('harus encode path dengan slash menjadi base64url', () {
        const input = 'predictions/user-id/abc123.jpg';
        final encoded = Base64Utils.encodeFileKey(input);

        // Tidak boleh mengandung karakter yang tidak URL-safe
        expect(encoded.contains('/'), isFalse);
        expect(encoded.contains('+'), isFalse);
        expect(encoded.isNotEmpty, isTrue);
      });

      test('harus bisa di-decode kembali ke nilai asli', () {
        const input = 'predictions/userId/abc12345.jpg';
        final encoded = Base64Utils.encodeFileKey(input);
        final decoded = Base64Utils.decodeFileKey(encoded);

        expect(decoded, equals(input));
      });

      test('contoh dari dokumentasi API harus menghasilkan output yang benar', () {
        // Sesuai contoh Swagger:
        // encode 'predictions/userId/abc123.jpg' → base64url
        const input = 'predictions/userId/abc123.jpg';
        final encoded = Base64Utils.encodeFileKey(input);
        final decoded = Base64Utils.decodeFileKey(encoded);

        expect(decoded, equals(input));
      });

      test('harus handle string kosong tanpa throw', () {
        final encoded = Base64Utils.encodeFileKey('');
        expect(encoded, isA<String>());
      });
    });
  });
}
