import 'package:mobile_app/core/theme/app_colors.dart';
import 'package:mobile_app/core/theme/app_dimensions.dart';
import 'package:mobile_app/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

enum PredictionStatusDisplay { pending, success, failed }

/// Badge kecil berwarna untuk menampilkan status prediksi.
///
/// PENDING → amber berputar
/// SUCCESS → hijau
/// FAILED  → merah
class PredictionStatusBadge extends StatefulWidget {
  const PredictionStatusBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  factory PredictionStatusBadge.fromString(
    String raw, {
    bool compact = false,
  }) =>
      PredictionStatusBadge(
        status: _fromString(raw),
        compact: compact,
      );

  final PredictionStatusDisplay status;

  /// Compact: hanya dot tanpa label.
  final bool compact;

  static PredictionStatusDisplay _fromString(String raw) =>
      switch (raw.toUpperCase()) {
        'SUCCESS' => PredictionStatusDisplay.success,
        'FAILED'  => PredictionStatusDisplay.failed,
        _         => PredictionStatusDisplay.pending,
      };

  @override
  State<PredictionStatusBadge> createState() => _PredictionStatusBadgeState();
}

class _PredictionStatusBadgeState extends State<PredictionStatusBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _spin;

  @override
  void initState() {
    super.initState();
    _spin = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (widget.status == PredictionStatusDisplay.pending) {
      _spin.repeat();
    }
  }

  @override
  void didUpdateWidget(PredictionStatusBadge old) {
    super.didUpdateWidget(old);
    if (widget.status == PredictionStatusDisplay.pending) {
      _spin.repeat();
    } else {
      _spin.stop();
    }
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  _BadgeConfig get _config => switch (widget.status) {
        PredictionStatusDisplay.pending => const _BadgeConfig(
            icon: Icons.hourglass_top_rounded,
            label: 'Diproses',
            bg: AppColors.warningLight,
            fg: AppColors.warning,
          ),
        PredictionStatusDisplay.success => const _BadgeConfig(
            icon: Icons.check_circle_outline_rounded,
            label: 'Berhasil',
            bg: AppColors.successLight,
            fg: AppColors.success,
          ),
        PredictionStatusDisplay.failed => const _BadgeConfig(
            icon: Icons.cancel_outlined,
            label: 'Gagal',
            bg: AppColors.errorLight,
            fg: AppColors.error,
          ),
      };

  @override
  Widget build(BuildContext context) {
    final cfg = _config;
    final isPending = widget.status == PredictionStatusDisplay.pending;

    final iconWidget = isPending
        ? RotationTransition(
            turns: _spin,
            child: Icon(cfg.icon, size: 14, color: cfg.fg),
          )
        : Icon(cfg.icon, size: 14, color: cfg.fg);

    if (widget.compact) {
      return Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: cfg.fg,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.sm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: cfg.bg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        border: Border.all(color: cfg.fg.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          iconWidget,
          const SizedBox(width: 4),
          Text(
            cfg.label,
            style: AppTextStyles.labelSmall.copyWith(
              color: cfg.fg,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeConfig {
  const _BadgeConfig({
    required this.icon,
    required this.label,
    required this.bg,
    required this.fg,
  });

  final IconData icon;
  final String label;
  final Color bg;
  final Color fg;
}
