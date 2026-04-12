import 'package:dartz/dartz.dart';
import 'package:mobile_app/core/error/failures.dart';
import 'package:mobile_app/features/ai_health/domain/entities/ai_status.dart';

/// Kontrak repository untuk mengambil status AI service.
///
/// Dua mode akses:
/// 1. [getCurrentStatus] — REST GET snapshot (untuk initial check saat buka app/halaman).
/// 2. [streamStatus]     — SSE long-lived stream (untuk update real-time).
///
/// Implementasi ada di [AiHealthRepositoryImpl].
abstract class AiHealthRepository {
  /// Ambil snapshot status AI satu kali via `GET /ai/status/current`.
  ///
  /// Tidak membutuhkan autentikasi.
  ///
  /// Possible failures:
  /// - [AiOfflineFailure]  → service tidak merespons
  /// - [NoInternetFailure]
  /// - [TimeoutFailure]
  /// - [ServerFailure]
  Future<Either<Failure, AiStatus>> getCurrentStatus();

  /// Stream status AI via SSE `GET /ai/status`.
  ///
  /// Emit [AiStatus] setiap kali server mengirim event baru.
  /// Emit [Left(Failure)] jika koneksi terputus atau error.
  ///
  /// Stream bersifat *infinite* sampai subscriber cancel.
  /// Tidak membutuhkan autentikasi.
  Stream<Either<Failure, AiStatus>> streamStatus();
}
