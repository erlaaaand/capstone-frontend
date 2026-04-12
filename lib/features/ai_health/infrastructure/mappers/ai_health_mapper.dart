import 'package:mobile_app/features/ai_health/domain/entities/ai_status.dart';
import 'package:mobile_app/features/ai_health/infrastructure/models/ai_status_model.dart';

/// Konversi [AiStatusModel] (infrastructure) → [AiStatus] (domain).
class AiHealthMapper {
  AiHealthMapper._();

  static AiStatus toEntity(AiStatusModel model) {
    final serviceStatus = _resolveStatus(model);

    return AiStatus(
      status: serviceStatus,
      checkedAt: model.timestamp,
      message: model.message,
      modelLoaded: model.modelLoaded,
      uptime: model.uptime,
      supportedClasses: model.classes,
    );
  }

  // ── Internal ──────────────────────────────────────────────────────────────

  static AiServiceStatus _resolveStatus(AiStatusModel model) {
    // Jika server mengirim status string eksplisit, gunakan itu
    return switch (model.statusRaw) {
      'online'  => AiServiceStatus.online,
      'loading' => AiServiceStatus.loading,
      'offline' => AiServiceStatus.offline,
      // Fallback: derive dari isAvailable + modelLoaded
      _ => switch ((model.isAvailable, model.modelLoaded)) {
          (true, true)  => AiServiceStatus.online,
          (true, false) => AiServiceStatus.loading,
          (true, null)  => AiServiceStatus.online,
          _             => AiServiceStatus.offline,
        },
    };
  }
}
