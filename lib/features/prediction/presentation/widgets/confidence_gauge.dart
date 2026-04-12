import 'dart:math' as math;

import 'package:mobile_app/core/theme/app_colors.dart';
import 'package:mobile_app/core/theme/app_dimensions.dart';
import 'package:mobile_app/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

/// Gauge setengah lingkaran yang menampilkan confidence score AI.
///
/// Score 0.0–1.0 dipetakan ke sudut 0°–180°.
/// Warna berubah dari merah (rendah) → kuning (sedang) → hijau (tinggi).
///
/// ```dart
/// ConfidenceGauge(score: 0.9231, varietyCode: 'D197')
/// ```
class ConfidenceGauge extends StatefulWidget {
  const ConfidenceGauge({
    super.key,
    required this.score,
    this.varietyCode,
    this.size = AppDimensions.gaugeSize,
  });

  /// Confidence score dari API (0.0 – 1.0, 4 desimal).
  final double score;

  /// Kode varietas, ditampilkan di tengah gauge.
  final String? varietyCode;

  final double size;

  @override
  State<ConfidenceGauge> createState() => _ConfidenceGaugeState();
}

class _ConfidenceGaugeState extends State<ConfidenceGauge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = Tween<double>(begin: 0, end: widget.score).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(ConfidenceGauge old) {
    super.didUpdateWidget(old);
    if (old.score != widget.score) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.score,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _colorForScore(double s) {
    if (s < 0.5) {
      return Color.lerp(AppColors.confidenceLow, AppColors.confidenceMedium,
          s / 0.5)!;
    } else if (s < 0.8) {
      return Color.lerp(AppColors.confidenceMedium, AppColors.confidenceHigh,
          (s - 0.5) / 0.3)!;
    }
    return AppColors.confidenceHigh;
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _animation,
        builder: (_, __) {
          final s = _animation.value;
          final color = _colorForScore(s);
          final pct = (s * 100).toStringAsFixed(1);

          return SizedBox(
            width: widget.size,
            height: widget.size * 0.65,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                // Arc gauge
                CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: _GaugePainter(
                    score: s,
                    color: color,
                    strokeWidth: AppDimensions.gaugeStrokeWidth,
                  ),
                ),

                // Label tengah
                Positioned(
                  bottom: 0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$pct%',
                        style: AppTextStyles.confidenceScore.copyWith(
                          color: color,
                        ),
                      ),
                      if (widget.varietyCode != null)
                        Text(
                          widget.varietyCode!,
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
}

// ── Painter ───────────────────────────────────────────────────────────────────

class _GaugePainter extends CustomPainter {
  _GaugePainter({
    required this.score,
    required this.color,
    required this.strokeWidth,
  });

  final double score;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.78);
    final radius = size.width / 2 - strokeWidth;

    const startAngle = math.pi;       // 180° (kiri)
    const sweepFull  = math.pi;       // 180° (kanan)

    // Track (abu-abu)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepFull,
      false,
      Paint()
        ..color = AppColors.divider
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    // Fill (warna score)
    if (score > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepFull * score,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_GaugePainter old) =>
      old.score != score || old.color != color;
}
