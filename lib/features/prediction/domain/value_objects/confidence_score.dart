import 'package:equatable/equatable.dart';

/// Value object untuk confidence score prediksi AI (0.0 – 1.0).
///
/// Immutable dan self-validating — tidak bisa dibuat dengan nilai di luar range.
///
/// ```dart
/// final score = ConfidenceScore.fromDouble(0.9231);
/// print(score.formatted); // "92.3%"
/// ```
class ConfidenceScore extends Equatable {
  const ConfidenceScore._(this.value);

  /// Buat [ConfidenceScore] dari nilai double 0.0–1.0.
  ///
  /// Nilai di-clamp otomatis ke range [0.0, 1.0].
  factory ConfidenceScore.fromDouble(double value) {
    return ConfidenceScore._(value.clamp(0.0, 1.0));
  }

  /// Nilai raw 0.0–1.0.
  final double value;

  /// Nilai dalam persen (0–100).
  double get percentage => value * 100;

  /// Nilai diformat sebagai string persentase. Contoh: `"92.3%"`
  String get formatted => '${(value * 100).toStringAsFixed(1)}%';

  /// Score tinggi (≥ 80%) — AI sangat yakin.
  bool get isHigh => value >= 0.8;

  /// Score sedang (50%–79%).
  bool get isMedium => value >= 0.5 && value < 0.8;

  /// Score rendah (< 50%) — AI kurang yakin.
  bool get isLow => value < 0.5;

  @override
  List<Object?> get props => [value];

  @override
  String toString() => 'ConfidenceScore($formatted)';
}
