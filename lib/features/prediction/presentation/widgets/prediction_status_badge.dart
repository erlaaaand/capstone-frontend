import 'package:flutter/material.dart';
import 'package:mobile_app/core/theme/app_colors.dart';
import 'package:mobile_app/core/theme/app_dimensions.dart';
import 'package:mobile_app/features/prediction/domain/entities/prediction.dart';

class PredictionStatusBadge extends StatefulWidget {
  const PredictionStatusBadge({
    super.key,
    this.prediction,
    this.rawStatus,
    this.compact = false,
  });

  factory PredictionStatusBadge.fromString(String raw, {bool compact = false}) {
    return PredictionStatusBadge(rawStatus: raw, compact: compact);
  }

  final Prediction? prediction;
  final String? rawStatus;
  final bool compact;

  @override
  State<PredictionStatusBadge> createState() => _PredictionStatusBadgeState();
}

class _PredictionStatusBadgeState extends State<PredictionStatusBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _spin;

  bool get _isPending {
    if (widget.prediction != null) return widget.prediction!.isPending;
    if (widget.rawStatus != null) return widget.rawStatus!.toUpperCase() == 'PENDING';
    return true;
  }

  @override
  void initState() {
    super.initState();
    _spin = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    if (_isPending) _spin.repeat();
  }

  @override
  void didUpdateWidget(PredictionStatusBadge old) {
    super.didUpdateWidget(old);
    if (_isPending) _spin.repeat();
    else _spin.stop();
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color fgColor;
    String label;
    IconData icon;

    if (widget.prediction != null) {
      final p = widget.prediction!;
      if (p.isStrictSuccess) {
        bgColor = AppColors.successLight; fgColor = AppColors.success; label = 'Berhasil'; icon = Icons.check_circle_outline_rounded;
      } else if (p.isSuccess && !p.hasHighConfidence) {
        bgColor = AppColors.warningLight; fgColor = AppColors.warning; label = 'Meragukan'; icon = Icons.help_outline_rounded;
      } else if (p.isFailed) {
        bgColor = AppColors.errorLight; fgColor = AppColors.error; label = 'Gagal'; icon = Icons.cancel_outlined;
      } else {
        bgColor = AppColors.warningLight; fgColor = AppColors.warning; label = 'Diproses'; icon = Icons.hourglass_top_rounded;
      }
    } 
    else {
      final raw = widget.rawStatus?.toUpperCase() ?? 'PENDING';
      if (raw == 'SUCCESS') {
        bgColor = AppColors.successLight; fgColor = AppColors.success; label = 'Berhasil'; icon = Icons.check_circle_outline_rounded;
      } else if (raw == 'FAILED') {
        bgColor = AppColors.errorLight; fgColor = AppColors.error; label = 'Gagal'; icon = Icons.cancel_outlined;
      } else {
        bgColor = AppColors.warningLight; fgColor = AppColors.warning; label = 'Diproses'; icon = Icons.hourglass_top_rounded;
      }
    }

    // Adaptasi Dark Mode
    if (Theme.of(context).brightness == Brightness.dark) {
      bgColor = fgColor.withOpacity(0.2);
    }

    final iconWidget = _isPending
        ? RotationTransition(turns: _spin, child: Icon(icon, size: 14, color: fgColor))
        : Icon(icon, size: 14, color: fgColor);

    if (widget.compact) {
      return Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: fgColor));
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.sm, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        border: Border.all(color: fgColor.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          iconWidget,
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: fgColor,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}