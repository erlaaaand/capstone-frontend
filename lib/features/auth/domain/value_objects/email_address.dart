import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class EmailAddress extends Equatable {
  const EmailAddress._(this.value);

  factory EmailAddress(String input) =>
      EmailAddress._(_validate(input.trim()));

  final Either<String, String> value;

  static const int _maxLength = 255;
  static final _pattern =
      RegExp(r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$');

  static Either<String, String> _validate(String input) {
    if (input.isEmpty) return left('Email tidak boleh kosong.');
    if (input.length > _maxLength) return left('Email maksimal $_maxLength karakter.');
    if (!_pattern.hasMatch(input)) return left('Format email tidak valid.');
    return right(input);
  }

  bool get isValid => value.isRight();

  String getOrCrash() => value.fold((_) => throw AssertionError('Email tidak valid'), id);

  String? getOrNull() => value.fold((_) => null, id);

  @override
  List<Object?> get props => [value];
}
