import 'package:mobile_app/core/theme/app_colors.dart';
import 'package:mobile_app/core/theme/app_dimensions.dart';
import 'package:mobile_app/core/theme/app_text_styles.dart';
import 'package:mobile_app/core/widgets/app_text_field.dart';
import 'package:flutter/material.dart';

/// Field password dengan indikator kekuatan password (khusus Register).
/// Untuk Login, gunakan [AppPasswordField] langsung.
class PasswordStrengthField extends StatefulWidget {
  const PasswordStrengthField({
    super.key,
    required this.controller,
    this.errorText,
    this.onChanged,
    this.validator,
    this.showStrengthIndicator = true,
    this.label = 'Password',
    this.hint = 'Min. 8 karakter, huruf besar, huruf kecil, angka',
  });

  final TextEditingController controller;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final bool showStrengthIndicator;
  final String label;
  final String hint;

  @override
  State<PasswordStrengthField> createState() => _PasswordStrengthFieldState();
}

class _PasswordStrengthFieldState extends State<PasswordStrengthField> {
  _PasswordStrength _strength = _PasswordStrength.empty;

  void _evaluate(String value) {
    setState(() {
      _strength = _PasswordStrengthX.evaluate(value);
    });
    widget.onChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppPasswordField(
            controller: widget.controller,
            label: widget.label,
            hint: widget.hint,
            errorText: widget.errorText,
            onChanged: _evaluate,
            validator: widget.validator,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.newPassword],
          ),
          if (widget.showStrengthIndicator &&
              _strength != _PasswordStrength.empty) ...[
            const SizedBox(height: AppDimensions.sm),
            _StrengthBar(strength: _strength),
          ],
        ],
      );
}

// ── Strength Model ────────────────────────────────────────────────────────────

enum _PasswordStrength { empty, weak, medium, strong }

extension _PasswordStrengthX on _PasswordStrength {
  static _PasswordStrength evaluate(String value) {
    if (value.isEmpty) return _PasswordStrength.empty;
    int score = 0;
    if (value.length >= 8) score++;
    if (value.length >= 12) score++;
    if (RegExp(r'[A-Z]').hasMatch(value)) score++;
    if (RegExp(r'[a-z]').hasMatch(value)) score++;
    if (RegExp(r'[0-9]').hasMatch(value)) score++;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(value)) score++;

    if (score <= 2) return _PasswordStrength.weak;
    if (score <= 4) return _PasswordStrength.medium;
    return _PasswordStrength.strong;
  }

  Color get color => switch (this) {
        _PasswordStrength.empty  => AppColors.divider,
        _PasswordStrength.weak   => AppColors.error,
        _PasswordStrength.medium => AppColors.warning,
        _PasswordStrength.strong => AppColors.success,
      };

  String get label => switch (this) {
        _PasswordStrength.empty  => '',
        _PasswordStrength.weak   => 'Lemah',
        _PasswordStrength.medium => 'Sedang',
        _PasswordStrength.strong => 'Kuat',
      };

  int get filledBars => switch (this) {
        _PasswordStrength.empty  => 0,
        _PasswordStrength.weak   => 1,
        _PasswordStrength.medium => 2,
        _PasswordStrength.strong => 3,
      };
}

// ── Strength Bar Widget ───────────────────────────────────────────────────────

class _StrengthBar extends StatelessWidget {
  const _StrengthBar({required this.strength});

  final _PasswordStrength strength;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: Row(
              children: List.generate(3, (i) {
                final filled = i < strength.filledBars;
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
                    decoration: BoxDecoration(
                      color: filled ? strength.color : AppColors.divider,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(width: AppDimensions.sm),
          Text(
            strength.label,
            style: AppTextStyles.labelSmall.copyWith(
              color: strength.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
}
