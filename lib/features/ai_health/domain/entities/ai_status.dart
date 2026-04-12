import 'package:equatable/equatable.dart';

/// Status operasional AI service.
enum AiServiceStatus {
  /// Model loaded, siap menerima prediksi.
  online,

  /// Service tidak dapat dijangkau atau model gagal load.
  offline,

  /// Service menyala tapi model sedang di-load (startup phase).
  loading,
}

/// Snapshot status AI service FastAPI (diterima via NestJS proxy).
///
/// Digunakan oleh [AiStatusBanner] dan [AiStatusIndicator] untuk
/// menampilkan kondisi AI kepada user sebelum melakukan scan.
class AiStatus extends Equatable {
  const AiStatus({
    required this.status,
    required this.checkedAt,
    this.message,
    this.modelLoaded,
    this.uptime,
    this.supportedClasses,
  });

  /// Status operasional saat ini.
  final AiServiceStatus status;

  /// Waktu snapshot ini diambil (dari client atau dari server).
  final DateTime checkedAt;

  /// Pesan tambahan dari server (mis. alasan offline, versi model).
  final String? message;

  /// Apakah model AI sudah selesai di-load.
  final bool? modelLoaded;

  /// Uptime service dalam detik sejak terakhir restart.
  final double? uptime;

  /// Daftar kode varietas yang didukung model (dari FastAPI CLASS_NAMES).
  final List<String>? supportedClasses;

  // ── Helpers ──────────────────────────────────────────────────────────────

  bool get isOnline  => status == AiServiceStatus.online;
  bool get isOffline => status == AiServiceStatus.offline;
  bool get isLoading => status == AiServiceStatus.loading;

  /// Apakah user boleh melakukan scan saat ini.
  bool get canScan => isOnline && (modelLoaded ?? true);

  /// Pesan singkat untuk ditampilkan di UI.
  String get displayMessage {
    if (message != null && message!.isNotEmpty) return message!;
    return switch (status) {
      AiServiceStatus.online  => 'AI service siap digunakan.',
      AiServiceStatus.offline => 'AI service sedang offline. Fitur scan tidak tersedia.',
      AiServiceStatus.loading => 'AI service sedang memuat model...',
    };
  }

  @override
  List<Object?> get props => [
        status,
        checkedAt,
        message,
        modelLoaded,
        uptime,
        supportedClasses,
      ];

  @override
  String toString() =>
      'AiStatus(status: $status, modelLoaded: $modelLoaded, checkedAt: $checkedAt)';
}
