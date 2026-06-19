enum PredictionStatus {
  pending,
  success,
  failed;

  static PredictionStatus fromString(String raw) =>
      switch (raw.toUpperCase()) {
        'SUCCESS' => PredictionStatus.success,
        'FAILED'  => PredictionStatus.failed,
        _         => PredictionStatus.pending,
      };

  String get value => switch (this) {
        PredictionStatus.pending => 'PENDING',
        PredictionStatus.success => 'SUCCESS',
        PredictionStatus.failed  => 'FAILED',
      };

  bool get isPending  => this == PredictionStatus.pending;
  bool get isSuccess  => this == PredictionStatus.success;
  bool get isFailed   => this == PredictionStatus.failed;

  bool get isComplete => isSuccess || isFailed;
}
