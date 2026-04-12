import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

/// Value object Password dengan validasi sesuai constraint Swagger RegisterDto.
///
/// - Minimal 8, maksimal 128 karakter
/// - Harus mengandung huruf besar, huruf kecil, dan angka
class Password extends Equatable {
  const Password._(this.value);

  factory Password(String input) => Password._(_validate(input));

  /// Left = pesan error, Right = password valid (nilai asli, tidak di-hash).
  final Either<String, String> value;

  static const int _minLength = 8;
  static const int _maxLength = 128;

  static Either<String, String> _validate(String input) {
    if (input.isEmpty)            return left('Password tidak boleh kosong.');
    if (input.length < _minLength) return left('Password minimal $_minLength karakter.');
    if (input.length > _maxLength) return left('Password maksimal $_maxLength karakter.');
    if (!RegExp(r'[A-Z]').hasMatch(input)) {
      return left('Password harus mengandung minimal 1 huruf besar.');
    }
    if (!RegExp(r'[a-z]').hasMatch(input)) {
      return left('Password harus mengandung minimal 1 huruf kecil.');
    }
    if (!RegExp(r'[0-9]').hasMatch(input)) {
      return left('Password harus mengandung minimal 1 angka.');
    }
    return right(input);
  }

  bool get isValid => value.isRight();

  String getOrCrash() =>
      value.fold((_) => throw AssertionError('Password tidak valid'), id);

  String? getOrNull() => value.fold((_) => null, id);

  @override
  List<Object?> get props => [value];
}
