import 'package:equatable/equatable.dart';

enum AiServiceStatus {
  online,
  offline,
  loading,
}

class AiStatus extends Equatable {
  const AiStatus({
    required this.status,
    required this.checkedAt,
    this.message,
    this.modelLoaded,
    this.uptime,
    this.supportedClasses,
  });

  final AiServiceStatus status;

  final DateTime checkedAt;

  final String? message;

  final bool? modelLoaded;

  final double? uptime;

  final List<String>? supportedClasses;

  // ── Helpers ──────────────────────────────────────────────────────────────

  bool get isOnline  => status == AiServiceStatus.online;
  bool get isOffline => status == AiServiceStatus.offline;
  bool get isLoading => status == AiServiceStatus.loading;

  bool get canScan => isOnline && (modelLoaded ?? true);

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
