import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app/core/router/route_names.dart';
import 'package:mobile_app/core/theme/app_colors.dart';
import 'package:mobile_app/core/theme/app_dimensions.dart';
import 'package:mobile_app/core/theme/app_text_styles.dart';
import 'package:mobile_app/core/utils/validator.dart';
import 'package:mobile_app/core/widgets/app_button.dart';
import 'package:mobile_app/core/widgets/app_snackbar.dart';
import 'package:mobile_app/core/widgets/app_text_field.dart';
import 'package:mobile_app/features/auth/application/auth_bloc.dart';
import 'package:mobile_app/features/auth/application/auth_event.dart';
import 'package:mobile_app/features/auth/application/auth_state.dart';
import 'package:mobile_app/features/auth/presentation/widgets/auth_form_footer.dart';
import 'package:mobile_app/features/auth/presentation/widgets/auth_header.dart';

/// Halaman Login.
///
/// Validasi form dilakukan di client sebelum dispatch event ke [AuthBloc].
/// Error dari server ditampilkan via [AppSnackBar].
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    context.read<AuthBloc>().add(
          AuthLoginRequested(
            email: _emailCtrl.text.trim(),
            password: _passwordCtrl.text,
          ),
        );
  }

  // Navigasi ke register — dipanggil dari AuthFormFooter.
  void _goToRegister() => context.goNamed(RouteNames.register);

  // Placeholder untuk fitur lupa password.
  void _onForgotPassword() {
    // TODO(dev): navigasi ke halaman reset password setelah fitur tersedia.
  }

  // Callback kosong bertipe [VoidCallback] — digunakan saat loading
  // agar [AuthFormFooter.onAction] tetap mendapat non-null value.
  static void _noOp() {}

  @override
  Widget build(BuildContext context) {
    // BlocConsumer menggabungkan BlocListener + BlocBuilder dalam satu widget
    // sehingga menghindari nesting yang tidak perlu.
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.goNamed(RouteNames.scan);
        } else if (state is AuthFailureState) {
          AppSnackBar.showError(context, state.failure.message);
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.pagePaddingH,
                vertical: AppDimensions.pagePaddingV,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppDimensions.xl),

                    // ── Header ──────────────────────────────────────────
                    const AuthHeader(
                      title: 'Selamat Datang',
                      subtitle:
                          'Masuk untuk mulai mengidentifikasi\nvarietas durianmu',
                    ),
                    const SizedBox(height: AppDimensions.xxl),

                    // ── Email ───────────────────────────────────────────
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

                    // ── Password ────────────────────────────────────────
                    AppPasswordField(
                      controller: _passwordCtrl,
                      focusNode: _passwordFocus,
                      label: 'Password',
                      hint: 'Masukkan password',
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      enabled: !isLoading,
                      validator: Validator.loginPassword,
                    ),

                    // ── Lupa Password ───────────────────────────────────
                    Align(
                      alignment: Alignment.centerRight,
                      child: AppTextButton(
                        label: 'Lupa Password?',
                        onPressed: isLoading ? null : _onForgotPassword,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.lg),

                    // ── Submit ──────────────────────────────────────────
                    AppButton(
                      label: 'Masuk',
                      onPressed: isLoading ? null : _submit,
                      isLoading: isLoading,
                    ),
                    const SizedBox(height: AppDimensions.xl),

                    // ── Divider ─────────────────────────────────────────
                    const Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppDimensions.md,
                          ),
                          child: Text(
                            'atau',
                            style: AppTextStyles.bodySmall,
                          ),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.xl),

                    // ── Footer ──────────────────────────────────────────
                    AuthFormFooter(
                      question: 'Belum punya akun?',
                      actionLabel: 'Daftar Sekarang',
                      onAction: isLoading ? _noOp : _goToRegister,
                    ),
                    const SizedBox(height: AppDimensions.md),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
