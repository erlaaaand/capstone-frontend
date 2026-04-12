import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app/core/router/route_names.dart';
import 'package:mobile_app/core/theme/app_colors.dart';
import 'package:mobile_app/core/theme/app_dimensions.dart';
import 'package:mobile_app/core/utils/validator.dart';
import 'package:mobile_app/core/widgets/app_button.dart';
import 'package:mobile_app/core/widgets/app_snackbar.dart';
import 'package:mobile_app/core/widgets/app_text_field.dart';
import 'package:mobile_app/features/auth/application/auth_bloc.dart';
import 'package:mobile_app/features/auth/application/auth_event.dart';
import 'package:mobile_app/features/auth/application/auth_state.dart';
import 'package:mobile_app/features/auth/presentation/widgets/auth_form_footer.dart';
import 'package:mobile_app/features/auth/presentation/widgets/auth_header.dart';
import 'package:mobile_app/features/auth/presentation/widgets/password_field.dart';

/// Halaman Register.
///
/// Field: nama lengkap (opsional), email, password, konfirmasi password.
/// Validasi menggunakan [Validator] sesuai constraint Swagger RegisterDto.
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    context.read<AuthBloc>().add(
          AuthRegisterRequested(
            email: _emailCtrl.text.trim(),
            password: _passwordCtrl.text,
            fullName: _nameCtrl.text.trim().isNotEmpty
                ? _nameCtrl.text.trim()
                : null,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.goNamed(RouteNames.scan);
        } else if (state is AuthFailureState) {
          AppSnackBar.showError(context, state.failure.message);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        body: SafeArea(
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final isLoading = state is AuthLoading;

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.pagePaddingH,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Header ────────────────────────────────────────
                      const AuthHeader(
                        title: 'Buat Akun',
                        subtitle: 'Daftar gratis dan mulai\nmengidentifikasi varietas durian',
                      ),
                      const SizedBox(height: AppDimensions.xl),

                      // ── Nama Lengkap (opsional) ───────────────────────
                      AppTextField(
                        controller: _nameCtrl,
                        focusNode: _nameFocus,
                        label: 'Nama Lengkap (opsional)',
                        hint: 'Masukkan nama lengkap',
                        prefixIcon: Icons.person_outline_rounded,
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.name],
                        enabled: !isLoading,
                        onEditingComplete: () =>
                            FocusScope.of(context).requestFocus(_emailFocus),
                        validator: Validator.fullName,
                      ),
                      const SizedBox(height: AppDimensions.md),

                      // ── Email ─────────────────────────────────────────
                      AppTextField(
                        controller: _emailCtrl,
                        focusNode: _emailFocus,
                        label: 'Email',
                        hint: 'nama@email.com',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                        enabled: !isLoading,
                        onEditingComplete: () =>
                            FocusScope.of(context).requestFocus(_passwordFocus),
                        validator: Validator.email,
                      ),
                      const SizedBox(height: AppDimensions.md),

                      // ── Password dengan strength indicator ───────────
                      PasswordStrengthField(
                        controller: _passwordCtrl,
                        validator: Validator.password,
                        showStrengthIndicator: true,
                      ),
                      const SizedBox(height: AppDimensions.md),

                      // ── Konfirmasi Password ───────────────────────────
                      AppPasswordField(
                        controller: _confirmCtrl,
                        focusNode: _confirmFocus,
                        label: 'Konfirmasi Password',
                        hint: 'Ulangi password',
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.newPassword],
                        enabled: !isLoading,
                        validator: (v) =>
                            Validator.confirmPassword(v, _passwordCtrl.text),
                      ),
                      const SizedBox(height: AppDimensions.xl),

                      // ── Submit ────────────────────────────────────────
                      AppButton(
                        label: 'Daftar',
                        onPressed: isLoading ? null : _submit,
                        isLoading: isLoading,
                      ),
                      const SizedBox(height: AppDimensions.lg),

                      // ── Footer ────────────────────────────────────────
                      AuthFormFooter(
                        question: 'Sudah punya akun?',
                        actionLabel: 'Masuk',
                        onAction: isLoading
                            ? () {}
                            : () => context.goNamed(RouteNames.login),
                      ),
                      const SizedBox(height: AppDimensions.xl),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
