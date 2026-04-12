import 'package:mobile_app/core/theme/app_colors.dart';
import 'package:mobile_app/core/theme/app_dimensions.dart';
import 'package:mobile_app/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

enum AiStatusValue { online, offline, checking }

/// Indikator dot kecil ONLINE/OFFLINE untuk ditempatkan di AppBar atau header.
class AiStatusIndicator extends StatefulWidget {
  const AiStatusIndicator({
    super.key,
    required this.status,
    this.showLabel = true,
  });

  final AiStatusValue status;
  final bool showLabel;

  @override
  State<AiStatusIndicator> createState() => _AiStatusIndicatorState();
}

class _AiStatusIndicatorState extends State<AiStatusIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _updatePulse();
  }

  @override
  void didUpdateWidget(AiStatusIndicator old) {
    super.didUpdateWidget(old);
    if (old.status != widget.status) _updatePulse();
  }

  void _updatePulse() {
    if (widget.status == AiStatusValue.checking) {
      _pulse.repeat(reverse: true);
    } else {
      _pulse.stop();
      _pulse.value = 1;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Color get _dotColor => switch (widget.status) {
        AiStatusValue.online   => AppColors.aiOnline,
        AiStatusValue.offline  => AppColors.aiOffline,
        AiStatusValue.checking => AppColors.warning,
      };

  String get _label => switch (widget.status) {
        AiStatusValue.online   => 'AI Online',
        AiStatusValue.offline  => 'AI Offline',
        AiStatusValue.checking => 'Memeriksa...',
      };

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Dot beranimasi
          AnimatedBuilder(
            animation: _pulse,
            builder: (_, __) => Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _dotColor.withOpacity(
                  widget.status == AiStatusValue.checking
                      ? 0.4 + _pulse.value * 0.6
                      : 1.0,
                ),
                boxShadow: widget.status == AiStatusValue.online
                    ? [
                        BoxShadow(
                          color: AppColors.aiOnline.withOpacity(0.4),
                          blurRadius: 4,
                          spreadRadius: 1,
                        )
                      ]
                    : null,
              ),
            ),
          ),
          if (widget.showLabel) ...[
            const SizedBox(width: AppDimensions.xs),
            Text(
              _label,
              style: AppTextStyles.labelSmall.copyWith(
                color: _dotColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      );
}