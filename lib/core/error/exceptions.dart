/// Semua exception yang dilempar dari layer [infrastructure].
///
/// Exception ini TIDAK boleh bocor ke layer [domain] maupun [presentation].
/// Konversi ke [Failure] dilakukan di repository implementation.

// ── Network ──────────────────────────────────────────────────────────────────

/// Exception umum dari Dio / HTTP.
class ServerException implements Exception {
  const ServerException({
    required this.statusCode,
    required this.message,
    this.errors,
    this.module,
  });

  /// HTTP status code dari respons server.
  final int statusCode;

  /// Pesan error dari server (bisa berupa String atau List<String>).
  final String message;

  /// Daftar error validasi jika ada (status 400).
  final List<String>? errors;

  /// Modul backend yang melempar error (auth, predictions, storage, dll).
  final String? module;

  @override
  String toString() =>
      'ServerException(statusCode: $statusCode, message: $message, '
      'module: $module)';
}

/// Server mengembalikan status 401 — token tidak ada / expired.
class UnauthorizedException extends ServerException {
  const UnauthorizedException({super.message = 'Sesi berakhir, silakan login kembali.'})
      : super(statusCode: 401);
}

/// Server mengembalikan status 403 — tidak punya izin.
class ForbiddenException extends ServerException {
  const ForbiddenException({super.message = 'Anda tidak memiliki akses.'})
      : super(statusCode: 403);
}

/// Server mengembalikan status 404 — resource tidak ditemukan.
class NotFoundException extends ServerException {
  const NotFoundException({super.message = 'Data tidak ditemukan.'})
      : super(statusCode: 404);
}

/// Server mengembalikan status 409 — konflik (mis. email sudah terdaftar).
class ConflictException extends ServerException {
  const ConflictException({required super.message}) : super(statusCode: 409);
}

/// Server mengembalikan status 413 — file terlalu besar (> 5 MB).
class FileTooLargeException extends ServerException {
  const FileTooLargeException({
    super.message = 'Ukuran file melebihi batas 5MB.',
  }) : super(statusCode: 413);
}

/// Server mengembalikan status 422 — format file tidak didukung.
class UnsupportedFileException extends ServerException {
  const UnsupportedFileException({
    super.message = 'Format file tidak didukung. Gunakan JPG, PNG, atau WebP.',
  }) : super(statusCode: 422);
}

/// Server mengembalikan status 429 — rate limit terlampaui.
class RateLimitException extends ServerException {
  const RateLimitException({
    super.message = 'Terlalu banyak percobaan. Coba lagi dalam 1 menit.',
  }) : super(statusCode: 429);
}

// ── Network Connectivity ─────────────────────────────────────────────────────

/// Tidak ada koneksi internet saat request dilakukan.
class NoInternetException implements Exception {
  const NoInternetException();

  @override
  String toString() => 'NoInternetException: Tidak ada koneksi internet.';
}

/// Request timeout (connect / receive / send).
class TimeoutException implements Exception {
  const TimeoutException();

  @override
  String toString() => 'TimeoutException: Koneksi ke server timeout.';
}

// ── Local / Cache ─────────────────────────────────────────────────────────────

/// Error saat mengakses secure storage.
class StorageAccessException implements Exception {
  const StorageAccessException({required this.message});

  final String message;

  @override
  String toString() => 'StorageAccessException: $message';
}

// ── File ─────────────────────────────────────────────────────────────────────

/// File yang dipilih user tidak valid (ukuran / format).
class InvalidFileException implements Exception {
  const InvalidFileException({required this.message});

  final String message;

  @override
  String toString() => 'InvalidFileException: $message';
}

// ── Prediction ────────────────────────────────────────────────────────────────

/// Polling prediksi sudah mencapai batas maksimal tanpa hasil SUCCESS.
class PredictionTimeoutException implements Exception {
  const PredictionTimeoutException();

  @override
  String toString() =>
      'PredictionTimeoutException: Prediksi tidak selesai dalam waktu yang ditentukan.';
}
