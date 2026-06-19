import 'package:equatable/equatable.dart';

class ConfidenceScore extends Equatable {
  const ConfidenceScore._(this.value);

  factory ConfidenceScore.fromDouble(double value) {
    return ConfidenceScore._(value.clamp(0.0, 1.0));
  }

  final double value;

  double get percentage => value * 100;

  String get formatted => '${(value * 100).toStringAsFixed(1)}%';

  bool get isHigh => value >= 0.8;

  bool get isMedium => value >= 0.5 && value < 0.8;

  bool get isLow => value < 0.5;

  @override
  List<Object?> get props => [value];

  @override
  String toString() => 'ConfidenceScore($formatted)';
}
