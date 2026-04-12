import 'package:equatable/equatable.dart';

/// Representasi kegagalan di layer [domain].
///
/// Failure TIDAK mengandung detail teknis — hanya pesan yang siap tampil di UI.
/// Repository implementation bertanggung jawab konversi Exception → Failure.
sealed class Failure extends Equatable {
  const Failure(this.message);

  /// Pesan yang akan ditampilkan ke user.
  final String message;

  @override
  List<Object?> get props => [message];
}

// ── Network Failures ─────────────────────────────────────────────────────────

/// Tidak ada koneksi internet.
class NoInternetFailure extends Failure {
  const NoInternetFailure()
      : super('Tidak ada koneksi internet. Periksa jaringan Anda.');
}

/// Request timeout.
class TimeoutFailure extends Failure {
  const TimeoutFailure() : super('Koneksi ke server timeout. Coba lagi.');
}

// ── Auth Failures ─────────────────────────────────────────────────────────────

/// Login gagal — email/password salah.
class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure()
      : super('Email atau password tidak valid.');
}

/// Sesi berakhir / token expired.
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure()
      : super('Sesi berakhir, silakan login kembali.');
}

/// Email sudah terdaftar.
class EmailAlreadyUsedFailure extends Failure {
  const EmailAlreadyUsedFailure({required String email})
      : super('Email \'$email\' sudah digunakan.');
}

/// Validasi form gagal (password lemah, format email salah, dll).
class ValidationFailure extends Failure {
  const ValidationFailure({required String message}) : super(message);

  /// Buat dari list error validasi NestJS (status 400).
  factory ValidationFailure.fromErrors(List<String> errors) =>
      ValidationFailure(message: errors.join('\n'));
}

// ── User Failures ─────────────────────────────────────────────────────────────

/// User tidak ditemukan.
class UserNotFoundFailure extends Failure {
  const UserNotFoundFailure() : super('User tidak ditemukan.');
}

/// Tidak boleh mengakses / mengubah profil user lain.
class ForbiddenFailure extends Failure {
  const ForbiddenFailure()
      : super('Anda tidak memiliki izin untuk melakukan aksi ini.');
}

// ── Storage Failures ──────────────────────────────────────────────────────────

/// File yang dipilih terlalu besar (> 5 MB).
class FileTooLargeFailure extends Failure {
  const FileTooLargeFailure()
      : super('Ukuran file melebihi batas 5MB. Pilih gambar yang lebih kecil.');
}

/// Format file tidak didukung.
class UnsupportedFileFailure extends Failure {
  const UnsupportedFileFailure()
      : super('Format tidak didukung. Gunakan JPG, PNG, atau WebP.');
}

/// File tidak valid (ukuran 0, corrupt, dll).
class InvalidFileFailure extends Failure {
  const InvalidFileFailure({required String message}) : super(message);
}

// ── Prediction Failures ───────────────────────────────────────────────────────

/// Prediksi tidak ditemukan.
class PredictionNotFoundFailure extends Failure {
  const PredictionNotFoundFailure() : super('Prediksi tidak ditemukan.');
}

/// Polling prediksi timeout — AI tidak merespons dalam waktu ditentukan.
class PredictionTimeoutFailure extends Failure {
  const PredictionTimeoutFailure()
      : super('Prediksi tidak selesai dalam waktu yang ditentukan. Coba lagi.');
}

/// AI gagal memproses gambar (status FAILED dari server).
class PredictionFailedFailure extends Failure {
  const PredictionFailedFailure({required String message}) : super(message);
}

// ── AI Health Failures ────────────────────────────────────────────────────────

/// AI service sedang offline.
class AiOfflineFailure extends Failure {
  const AiOfflineFailure()
      : super('AI service sedang offline. Prediksi tidak tersedia saat ini.');
}

// ── Rate Limit ────────────────────────────────────────────────────────────────

/// Rate limit terlampaui (5 req/menit untuk auth endpoint).
class RateLimitFailure extends Failure {
  const RateLimitFailure()
      : super('Terlalu banyak percobaan. Coba lagi dalam 1 menit.');
}

// ── Generic ───────────────────────────────────────────────────────────────────

/// Kegagalan server yang tidak terklasifikasi.
class ServerFailure extends Failure {
  const ServerFailure({required String message}) : super(message);
}

/// Kegagalan yang tidak terduga (runtime error, null safety, dll).
class UnexpectedFailure extends Failure {
  const UnexpectedFailure()
      : super('Terjadi kesalahan yang tidak terduga. Coba lagi.');
}
