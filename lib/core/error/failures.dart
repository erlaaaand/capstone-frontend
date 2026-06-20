import 'package:equatable/equatable.dart';
import 'package:mobile_app/core/constants/app_constants.dart';

sealed class Failure extends Equatable {
  const Failure(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

// ── Network Failures ─────────────────────────────────────────────────────────
class NoInternetFailure extends Failure {
  const NoInternetFailure()
      : super('Tidak ada koneksi internet. Periksa jaringan Anda.');
}

class TimeoutFailure extends Failure {
  const TimeoutFailure() : super('Koneksi ke server timeout. Coba lagi.');
}

class RequestCancelledFailure extends Failure {
  const RequestCancelledFailure() : super('Permintaan dibatalkan.');
}

// ── Auth Failures ─────────────────────────────────────────────────────────────
class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure() : super('Email atau password tidak valid.');
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure() : super('Sesi berakhir, silakan login kembali.');
}

class EmailAlreadyUsedFailure extends Failure {
  const EmailAlreadyUsedFailure({required String email})
      : super('Email \'$email\' sudah digunakan.');
}

class ValidationFailure extends Failure {
  const ValidationFailure({required String message}) : super(message);

  factory ValidationFailure.fromErrors(List<String> errors) =>
      ValidationFailure(message: errors.join('\n'));
}

// ── Resource Failures ──────────────────────────────────────────────────────────
class UserNotFoundFailure extends Failure {
  const UserNotFoundFailure() : super('User tidak ditemukan.');
}

class ForbiddenFailure extends Failure {
  const ForbiddenFailure()
      : super('Anda tidak memiliki izin untuk melakukan aksi ini.');
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({required String message}) : super(message);
}

// ── Storage Failures ──────────────────────────────────────────────────────────
class FileTooLargeFailure extends Failure {
  const FileTooLargeFailure()
      : super(
          'Ukuran file melebihi batas ${AppConstants.maxUploadSizeMb}MB. '
          'Pilih gambar yang lebih kecil.',
        );
}

class UnsupportedFileFailure extends Failure {
  const UnsupportedFileFailure()
      : super('Format tidak didukung. Gunakan JPG, PNG, atau WebP.');
}

class InvalidFileFailure extends Failure {
  const InvalidFileFailure({required String message}) : super(message);
}

// ── Prediction Failures ───────────────────────────────────────────────────────
class PredictionNotFoundFailure extends Failure {
  const PredictionNotFoundFailure() : super('Prediksi tidak ditemukan.');
}

class PredictionTimeoutFailure extends Failure {
  const PredictionTimeoutFailure()
      : super('Prediksi tidak selesai dalam waktu yang ditentukan. Coba lagi.');
}

class PredictionFailedFailure extends Failure {
  const PredictionFailedFailure({required String message}) : super(message);
}

// ── AI Health Failures ────────────────────────────────────────────────────────
class AiOfflineFailure extends Failure {
  const AiOfflineFailure()
      : super('AI service sedang offline. Prediksi tidak tersedia saat ini.');
}

// ── Rate Limit ────────────────────────────────────────────────────────────────
class RateLimitFailure extends Failure {
  const RateLimitFailure()
      : super('Terlalu banyak percobaan. Coba lagi dalam 1 menit.');
}

// ── Generic ───────────────────────────────────────────────────────────────────
class ServerFailure extends Failure {
  const ServerFailure({required String message}) : super(message);
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure()
      : super('Terjadi kesalahan yang tidak terduga. Coba lagi.');
}