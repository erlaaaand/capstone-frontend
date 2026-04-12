/// Model JSON dari endpoint `GET /ai/status/current` dan SSE `GET /ai/status`.
///
/// NestJS memproxy response FastAPI. Format yang mungkin diterima:
/// ```json
/// {
///   "isAvailable": true,
///   "status": "online",
///   "modelLoaded": true,
///   "uptime": 1234.56,
///   "message": "FastAPI running",
///   "classes": ["D101", "D13", "D197", "D2", "D200", "D24"],
///   "timestamp": "2024-01-01T10:00:00.000Z"
/// }
/// ```
///
/// Field `status` bisa berupa string (`"online"`, `"offline"`, `"loading"`)
/// atau boolean `isAvailable`. Keduanya ditangani di [fromJson].
class AiStatusModel {
  const AiStatusModel({
    required this.isAvailable,
    required this.timestamp,
    this.statusRaw,
    this.message,
    this.modelLoaded,
    this.uptime,
    this.classes,
  });

  /// Apakah service tersedia (komposit dari status + modelLoaded).
  final bool isAvailable;

  /// Status string mentah dari server: `"online"`, `"offline"`, `"loading"`.
  final String? statusRaw;

  final String? message;
  final bool? modelLoaded;

  /// Uptime dalam detik.
  final double? uptime;

  /// Kelas durian yang didukung (dari FastAPI CLASS_NAMES).
  final List<String>? classes;

  /// Waktu event dari server (ISO 8601). Fallback ke `DateTime.now()`.
  final DateTime timestamp;

  factory AiStatusModel.fromJson(Map<String, dynamic> json) {
    // Resolve status dari berbagai field yang mungkin dikirim server
    final statusStr = (json['status'] as String?)?.toLowerCase().trim();
    final isAvailableRaw = json['isAvailable'] ?? json['is_available'];
    final modelLoaded = json['modelLoaded'] as bool? ?? json['model_loaded'] as bool?;

    // Tentukan availability: prioritas field `status`, fallback ke `isAvailable`
    final bool available = switch (statusStr) {
      'online'  => true,
      'offline' => false,
      'loading' => false,
      _         => switch (isAvailableRaw) {
          bool b   => b,
          String s => s == 'true',
          _        => modelLoaded ?? false,
        },
    };

    // Parse timestamp — bisa dari `timestamp`, `lastChecked`, `last_checked`
    final tsRaw = json['timestamp'] as String? ??
        json['lastChecked'] as String? ??
        json['last_checked'] as String?;
    final timestamp = tsRaw != null
        ? DateTime.tryParse(tsRaw) ?? DateTime.now()
        : DateTime.now();

    // Parse uptime — bisa int atau double
    final uptimeRaw = json['uptime'];
    final double? uptime = switch (uptimeRaw) {
      int u    => u.toDouble(),
      double u => u,
      String u => double.tryParse(u),
      _        => null,
    };

    // Parse classes list
    final classesRaw = json['classes'] as List<dynamic>?;
    final classes = classesRaw?.map((e) => e.toString()).toList();

    return AiStatusModel(
      isAvailable: available,
      statusRaw: statusStr,
      message: json['message'] as String?,
      modelLoaded: modelLoaded,
      uptime: uptime,
      classes: classes,
      timestamp: timestamp,
    );
  }

  Map<String, dynamic> toJson() => {
        'isAvailable': isAvailable,
        if (statusRaw != null) 'status': statusRaw,
        if (message != null) 'message': message,
        if (modelLoaded != null) 'modelLoaded': modelLoaded,
        if (uptime != null) 'uptime': uptime,
        if (classes != null) 'classes': classes,
        'timestamp': timestamp.toIso8601String(),
      };

  @override
  String toString() =>
      'AiStatusModel(isAvailable: $isAvailable, statusRaw: $statusRaw, '
      'modelLoaded: $modelLoaded, timestamp: $timestamp)';
}
