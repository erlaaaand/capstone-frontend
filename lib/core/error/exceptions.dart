// ── Network ──────────────────────────────────────────────────────────────────
class ServerException implements Exception {
  const ServerException({
    required this.statusCode,
    required this.message,
    this.errors,
    this.module,
  });

  final int statusCode;
  final String message;
  final List<String>? errors;
  final String? module;

  @override
  String toString() =>
      'ServerException(statusCode: $statusCode, message: $message, '
      'module: $module)';
}

class UnauthorizedException extends ServerException {
  const UnauthorizedException({super.message = 'Sesi berakhir, silakan login kembali.'})
      : super(statusCode: 401);
}

class ForbiddenException extends ServerException {
  const ForbiddenException({super.message = 'Anda tidak memiliki akses.'})
      : super(statusCode: 403);
}

class NotFoundException extends ServerException {
  const NotFoundException({super.message = 'Data tidak ditemukan.'})
      : super(statusCode: 404);
}

class ConflictException extends ServerException {
  const ConflictException({required super.message}) : super(statusCode: 409);
}

class FileTooLargeException extends ServerException {
  const FileTooLargeException({
    super.message = 'Ukuran file melebihi batas 5MB.',
  }) : super(statusCode: 413);
}

class UnsupportedFileException extends ServerException {
  const UnsupportedFileException({
    super.message = 'Format file tidak didukung. Gunakan JPG, PNG, atau WebP.',
  }) : super(statusCode: 422);
}

class RateLimitException extends ServerException {
  const RateLimitException({
    super.message = 'Terlalu banyak percobaan. Coba lagi dalam 1 menit.',
  }) : super(statusCode: 429);
}

// ── Network Connectivity ─────────────────────────────────────────────────────

class NoInternetException implements Exception {
  const NoInternetException();

  @override
  String toString() => 'NoInternetException: Tidak ada koneksi internet.';
}

class TimeoutException implements Exception {
  const TimeoutException();

  @override
  String toString() => 'TimeoutException: Koneksi ke server timeout.';
}

// ── Local / Cache ─────────────────────────────────────────────────────────────
class StorageAccessException implements Exception {
  const StorageAccessException({required this.message});

  final String message;

  @override
  String toString() => 'StorageAccessException: $message';
}

// ── File ─────────────────────────────────────────────────────────────────────
class InvalidFileException implements Exception {
  const InvalidFileException({required this.message});

  final String message;

  @override
  String toString() => 'InvalidFileException: $message';
}

// ── Prediction ────────────────────────────────────────────────────────────────
class PredictionTimeoutException implements Exception {
  const PredictionTimeoutException();

  @override
  String toString() =>
      'PredictionTimeoutException: Prediksi tidak selesai dalam waktu yang ditentukan.';
}
