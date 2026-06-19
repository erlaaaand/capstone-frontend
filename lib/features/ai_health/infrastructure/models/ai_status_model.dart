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

  final bool isAvailable;
  final String? statusRaw;
  final String? message;
  final bool? modelLoaded;
  final double? uptime;
  final List<String>? classes;
  final DateTime timestamp;

  factory AiStatusModel.fromJson(Map<String, dynamic> json) {
    final rawStatus = json['status'];
    final statusStr = rawStatus is String ? rawStatus.toLowerCase().trim() : null;
    
    final isAvailableRaw = json['isAvailable'] ?? json['is_available'];
    
    final mlRaw = json['modelLoaded'] ?? json['model_loaded'];
    final bool? modelLoaded = mlRaw is bool ? mlRaw : 
                              (mlRaw is String ? mlRaw.toLowerCase() == 'true' : null);

    final bool available = switch (statusStr) {
      'online'  => true,
      'offline' => false,
      'loading' => false,
      _         => switch (isAvailableRaw) {
          bool b   => b,
          String s => s.toLowerCase() == 'true',
          _        => modelLoaded ?? false,
        },
    };

    final tsRaw = json['timestamp'] ?? json['lastChecked'] ?? json['last_checked'];
    final timestamp = (tsRaw is String)
        ? DateTime.tryParse(tsRaw) ?? DateTime.now()
        : DateTime.now();

    final uptimeRaw = json['uptime'];
    final double? uptime = switch (uptimeRaw) {
      int u    => u.toDouble(),
      double u => u,
      String u => double.tryParse(u),
      _        => null,
    };

    final classesRaw = json['classes'];
    List<String>? classes;
    if (classesRaw is List) {
      classes = classesRaw.map((e) => e.toString()).toList();
    }

    final rawMessage = json['message'];
    final String? message = rawMessage is String ? rawMessage : null;

    return AiStatusModel(
      isAvailable: available,
      statusRaw: statusStr,
      message: message,
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