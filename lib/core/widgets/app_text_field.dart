import 'package:mobile_app/core/theme/app_colors.dart';
import 'package:mobile_app/core/theme/app_dimensions.dart';
import 'package:mobile_app/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AppTextField — text input standar
// ─────────────────────────────────────────────────────────────────────────────

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.helperText,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onEditingComplete,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.focusNode,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.obscureText = false,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? errorText;
  final String? helperText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final FocusNode? focusNode;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final int? maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null) ...[
            Text(label!, style: AppTextStyles.labelLarge),
            const SizedBox(height: AppDimensions.xs),
          ],
          TextFormField(
            controller: controller,
            focusNode: focusNode,
            obscureText: obscureText, // Meneruskan nilai obscureText ke TextFormField
            onChanged: onChanged,
            onEditingComplete: onEditingComplete,
            validator: validator,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            autofillHints: autofillHints,
            enabled: enabled,
            readOnly: readOnly,
            autofocus: autofocus,
            maxLines: obscureText ? 1 : maxLines, // maxLines wajib 1 jika obscureText true
            maxLength: maxLength,
            inputFormatters: inputFormatters,
            style: AppTextStyles.bodyMedium,
            decoration: InputDecoration(
              hintText: hint,
              errorText: errorText,
              helperText: helperText,
              helperMaxLines: 2,
              errorMaxLines: 2,
              prefixIcon: prefixIcon != null
                  ? Icon(prefixIcon,
                      size: AppDimensions.iconSm + 4, color: AppColors.textHint)
                  : null,
              suffixIcon: suffixIcon,
              counterText: '',
            ),
          ),
        ],
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// AppPasswordField — text field dengan toggle show/hide
// ─────────────────────────────────────────────────────────────────────────────

class AppPasswordField extends StatefulWidget {
  const AppPasswordField({
    super.key,
    this.controller,
    this.label = 'Password',
    this.hint = 'Masukkan password',
    this.errorText,
    this.onChanged,
    this.validator,
    this.textInputAction,
    this.autofillHints,
    this.focusNode,
    this.enabled = true,
  });

  final TextEditingController? controller;
  final String label;
  final String hint;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final FocusNode? focusNode;
  final bool enabled;

  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) => AppTextField(
        controller: widget.controller,
        label: widget.label,
        hint: widget.hint,
        errorText: widget.errorText,
        onChanged: widget.onChanged,
        validator: widget.validator,
        textInputAction: widget.textInputAction,
        autofillHints: widget.autofillHints ?? const [AutofillHints.password],
        focusNode: widget.focusNode,
        obscureText: _obscure, // Diubah menjadi _obscure (mengikuti state)
        enabled: widget.enabled,
        prefixIcon: Icons.lock_outline_rounded,
        keyboardType: TextInputType.visiblePassword,
        suffixIcon: IconButton(
          icon: Icon(
            _obscure
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            size: AppDimensions.iconSm + 4,
            color: AppColors.textHint,
          ),
          onPressed: () => setState(() => _obscure = !_obscure),
          tooltip: _obscure ? 'Tampilkan password' : 'Sembunyikan password',
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// AppSearchField — search bar ringan tanpa border bawah
// ─────────────────────────────────────────────────────────────────────────────

class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    this.controller,
    this.hint = 'Cari...',
    this.onChanged,
    this.onClear,
  });

  final TextEditingController? controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        onChanged: onChanged,
        style: AppTextStyles.bodyMedium,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: const Icon(Icons.search_rounded,
              size: AppDimensions.iconMd, color: AppColors.textHint),
          suffixIcon: controller?.text.isNotEmpty == true
              ? IconButton(
                  icon: const Icon(Icons.close_rounded,
                      size: AppDimensions.iconSm + 4,
                      color: AppColors.textHint),
                  onPressed: () {
                    controller?.clear();
                    onClear?.call();
                  },
                )
              : null,
        ),
      );
}