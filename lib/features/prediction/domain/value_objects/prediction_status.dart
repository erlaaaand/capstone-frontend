/// Status prediksi dari server.
///
/// Nilai ini WAJIB sesuai dengan enum di backend NestJS.
enum PredictionStatus {
  pending,
  success,
  failed;

  /// Parse string dari API menjadi [PredictionStatus].
  ///
  /// Case-insensitive. Nilai tidak dikenal dianggap [pending].
  static PredictionStatus fromString(String raw) =>
      switch (raw.toUpperCase()) {
        'SUCCESS' => PredictionStatus.success,
        'FAILED'  => PredictionStatus.failed,
        _         => PredictionStatus.pending,
      };

  /// Nilai string yang dikirim ke / diterima dari API.
  String get value => switch (this) {
        PredictionStatus.pending => 'PENDING',
        PredictionStatus.success => 'SUCCESS',
        PredictionStatus.failed  => 'FAILED',
      };

  bool get isPending  => this == PredictionStatus.pending;
  bool get isSuccess  => this == PredictionStatus.success;
  bool get isFailed   => this == PredictionStatus.failed;

  /// Prediksi sudah selesai diproses (bukan PENDING).
  bool get isComplete => isSuccess || isFailed;
}
