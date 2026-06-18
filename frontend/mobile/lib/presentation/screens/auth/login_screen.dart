import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asar_field_worker/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../../core/theme/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _rememberMe = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(AuthLoginRequested(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
        ),);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go('/schedule');
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 72),
                const _Logo(),
                const SizedBox(height: 48),
                _WelcomeText(l: l),
                const SizedBox(height: 32),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _EmailField(controller: _emailCtrl, l: l),
                      const SizedBox(height: 16),
                      _PasswordField(
                        controller: _passwordCtrl,
                        obscure: _obscure,
                        onToggle: () => setState(() => _obscure = !_obscure),
                        l: l,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                _RememberMeRow(
                  value: _rememberMe,
                  label: l.rememberMe,
                  onChanged: (v) => setState(() => _rememberMe = v ?? true),
                ),
                const SizedBox(height: 24),
                const _ErrorBanner(),
                const SizedBox(height: 8),
                _SignInButton(onPressed: _submit, label: l.signInButton),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Column(
      children: [
        Image.asset(
          'assets/icons/logo.png',
          width: 72,
          height: 72,
        ),
        const SizedBox(height: 14),
        Text(
          l.appTitle,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            fontFamily: 'IBMPlexSans',
            color: AppColors.operationalBlue,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l.appSubtitle,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.onSurfaceMuted,
            fontFamily: 'IBMPlexSans',
          ),
        ),
      ],
    );
  }
}

class _WelcomeText extends StatelessWidget {
  final AppLocalizations l;
  const _WelcomeText({required this.l});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.loginTitle,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            fontFamily: 'IBMPlexSans',
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l.loginSubtitle,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.onSurfaceMuted,
            fontFamily: 'IBMPlexSans',
          ),
        ),
      ],
    );
  }
}

class _EmailField extends StatelessWidget {
  final TextEditingController controller;
  final AppLocalizations l;
  const _EmailField({required this.controller, required this.l});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      autocorrect: false,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: l.fieldEmail,
        prefixIcon: const Icon(Icons.mail_outline),
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return l.validationEnterEmail;
        if (!v.contains('@')) return l.validationValidEmail;
        return null;
      },
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggle;
  final AppLocalizations l;

  const _PasswordField({
    required this.controller,
    required this.obscure,
    required this.onToggle,
    required this.l,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        labelText: l.fieldPassword,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          ),
          onPressed: onToggle,
        ),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return l.validationEnterPassword;
        return null;
      },
    );
  }
}

class _RememberMeRow extends StatelessWidget {
  final bool value;
  final String label;
  final ValueChanged<bool?> onChanged;
  const _RememberMeRow({
    required this.value,
    required this.label,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.operationalBlue,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontFamily: 'IBMPlexSans'),
        ),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthError) return const SizedBox.shrink();
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: AppColors.priorityCritical.withValues(alpha: 0.08),
            border: Border.all(
              color: AppColors.priorityCritical.withValues(alpha: 0.4),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.error_outline,
                color: AppColors.priorityCritical,
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  state.message,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.priorityCritical,
                    fontFamily: 'IBMPlexSans',
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SignInButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  const _SignInButton({required this.onPressed, required this.label});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                      fontFamily: 'IBMPlexSans',
                    ),
                  ),
          ),
        );
      },
    );
  }
}
