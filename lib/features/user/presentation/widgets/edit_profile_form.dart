import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/core/theme/app_colors.dart';
import 'package:mobile_app/core/theme/app_dimensions.dart';
import 'package:mobile_app/core/theme/app_text_styles.dart';
import 'package:mobile_app/core/utils/validator.dart';
import 'package:mobile_app/core/widgets/app_button.dart';
import 'package:mobile_app/core/widgets/app_text_field.dart';
import 'package:mobile_app/features/user/application/profile_bloc.dart';
import 'package:mobile_app/features/user/application/profile_event.dart';
import 'package:mobile_app/features/user/application/profile_state.dart';
import 'package:mobile_app/features/user/domain/entities/user.dart';

// ─────────────────────────────────────────────────────────────────────────────
// EditNameSection
// ─────────────────────────────────────────────────────────────────────────────

/// Section form untuk mengubah nama lengkap.
class EditNameSection extends StatefulWidget {
  const EditNameSection({super.key, required this.user});

  final User user;

  @override
  State<EditNameSection> createState() => _EditNameSectionState();
}

class _EditNameSectionState extends State<EditNameSection> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.user.fullName ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _submit(bool isUpdating) {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    context.read<ProfileBloc>().add(
          ProfileNameUpdateRequested(
            userId: widget.user.id,
            fullName: _nameCtrl.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final isUpdating = state is ProfileUpdating;

        return _SectionCard(
          title: 'Nama Lengkap',
          icon: Icons.person_outline_rounded,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  controller: _nameCtrl,
                  hint: 'Masukkan nama lengkap',
                  prefixIcon: Icons.badge_outlined,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.name],
                  enabled: !isUpdating,
                  maxLength: 100,
                  validator: Validator.fullName,
                ),
                const SizedBox(height: AppDimensions.md),
                AppButton(
                  label: 'Simpan Nama',
                  onPressed: isUpdating ? null : () => _submit(isUpdating),
                  isLoading: isUpdating,
                  height: AppDimensions.buttonHeightSm,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EditPasswordSection
// ─────────────────────────────────────────────────────────────────────────────

/// Section form untuk mengubah password.
class EditPasswordSection extends StatefulWidget {
  const EditPasswordSection({super.key, required this.userId});

  final String userId;

  @override
  State<EditPasswordSection> createState() => _EditPasswordSectionState();
}

class _EditPasswordSectionState extends State<EditPasswordSection> {
  final _formKey = GlobalKey<FormState>();
  final _currentPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  @override
  void dispose() {
    _currentPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    context.read<ProfileBloc>().add(
          ProfilePasswordUpdateRequested(
            userId: widget.userId,
            currentPassword: _currentPassCtrl.text,
            newPassword: _newPassCtrl.text,
          ),
        );
  }

  void _clearFields() {
    _currentPassCtrl.clear();
    _newPassCtrl.clear();
    _confirmPassCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listenWhen: (_, current) =>
          current is ProfileUpdateSuccess || current is ProfileFailure,
      listener: (_, state) {
        if (state is ProfileUpdateSuccess &&
            state.message.contains('Password')) {
          _clearFields();
        }
      },
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          final isUpdating = state is ProfileUpdating;

          return _SectionCard(
            title: 'Ubah Password',
            icon: Icons.lock_outline_rounded,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Password saat ini
                  AppPasswordField(
                    controller: _currentPassCtrl,
                    label: 'Password Saat Ini',
                    hint: 'Masukkan password saat ini',
                    textInputAction: TextInputAction.next,
                    enabled: !isUpdating,
                    validator: Validator.loginPassword,
                  ),
                  const SizedBox(height: AppDimensions.md),

                  // Password baru
                  AppPasswordField(
                    controller: _newPassCtrl,
                    label: 'Password Baru',
                    hint: 'Min. 8 karakter, huruf besar, huruf kecil, angka',
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.newPassword],
                    enabled: !isUpdating,
                    validator: Validator.password,
                  ),
                  const SizedBox(height: AppDimensions.md),

                  // Konfirmasi password baru
                  AppPasswordField(
                    controller: _confirmPassCtrl,
                    label: 'Konfirmasi Password Baru',
                    hint: 'Ulangi password baru',
                    textInputAction: TextInputAction.done,
                    enabled: !isUpdating,
                    validator: (v) =>
                        Validator.confirmPassword(v, _newPassCtrl.text),
                  ),
                  const SizedBox(height: AppDimensions.md),

                  AppButton(
                    label: 'Ubah Password',
                    onPressed: isUpdating ? null : _submit,
                    isLoading: isUpdating,
                    height: AppDimensions.buttonHeightSm,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SectionCard — container card seragam untuk setiap section form
// ─────────────────────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(AppDimensions.md),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppDimensions.xs),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                  ),
                  child: Icon(
                    icon,
                    size: AppDimensions.iconSm + 4,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppDimensions.sm),
                Text(title, style: AppTextStyles.titleLarge),
              ],
            ),
            const SizedBox(height: AppDimensions.md),
            const Divider(height: 1),
            const SizedBox(height: AppDimensions.md),
            child,
          ],
        ),
      );
}
