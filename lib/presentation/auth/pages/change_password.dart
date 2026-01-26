import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_amis/common/helpers/is_dark_mode.dart';
import 'package:real_amis/common/widgets/appBar/app_bar_yes_nav.dart';
import 'package:real_amis/common/widgets/button/basic_app_button.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';
import 'package:real_amis/core/utils/password_strength.dart';
import 'package:real_amis/core/utils/show_snackbar.dart';
import 'package:real_amis/presentation/auth/bloc/auth_bloc.dart';

import 'package:real_amis/presentation/auth/widgets/password_strength_indicator.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  static MaterialPageRoute route() =>
      MaterialPageRoute(builder: (_) => const ChangePasswordPage());

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  PasswordStrength _passwordStrength = PasswordStrength.empty;

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;

    context.read<AuthBloc>().add(
      AuthChangePassword(
        currentPassword: _currentPasswordController.text.trim(),
        newPassword: _newPasswordController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final textSecondary = isDark
        ? AppColors.textDarkSecondary
        : AppColors.textLightSecondary;

    final isPasswordValid =
        _passwordStrength == PasswordStrength.medium ||
        _passwordStrength == PasswordStrength.strong ||
        _passwordStrength == PasswordStrength.veryStrong;

    return Scaffold(
      appBar: AppBarYesNav(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthPasswordChanged) {
                showSnackBar(context, 'Password aggiornata con successo');
                Navigator.pop(context);
              }

              if (state is AuthFailure) {
                showSnackBar(context, state.message);
              }
            },
            builder: (context, state) {
              final isLoading = state is AuthLoading;

              return Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 32),

                    Text(
                      'Cambia password',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'Inserisci la password attuale e scegli una nuova password',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: textSecondary, fontSize: 15),
                    ),

                    const SizedBox(height: 32),

                    /// Password attuale
                    _PasswordField(
                      controller: _currentPasswordController,
                      hintText: 'Password attuale',
                      obscure: _obscureCurrent,
                      onToggleVisibility: () {
                        setState(() => _obscureCurrent = !_obscureCurrent);
                      },
                      validator: (v) => v == null || v.isEmpty
                          ? 'Inserisci la password attuale'
                          : null,
                    ),

                    const SizedBox(height: 12),

                    /// Nuova password
                    _PasswordField(
                      controller: _newPasswordController,
                      hintText: 'Nuova password',
                      obscure: _obscureNew,
                      onToggleVisibility: () {
                        setState(() => _obscureNew = !_obscureNew);
                      },
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Inserisci una nuova password';
                        }
                        if (v.length < 8) {
                          return 'Minimo 8 caratteri';
                        }
                        if (_passwordStrength == PasswordStrength.weak) {
                          return 'Password troppo debole';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {
                          _passwordStrength = evaluatePassword(value);
                        });
                      },
                    ),

                    const SizedBox(height: 8),

                    PasswordStrengthIndicator(strength: _passwordStrength),

                    const SizedBox(height: 12),

                    /// Conferma password
                    _PasswordField(
                      controller: _confirmPasswordController,
                      hintText: 'Conferma nuova password',
                      obscure: _obscureConfirm,
                      onToggleVisibility: () {
                        setState(() => _obscureConfirm = !_obscureConfirm);
                      },
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Conferma la nuova password';
                        }
                        if (v != _newPasswordController.text) {
                          return 'Le password non coincidono';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    BasicAppButton(
                      title: isLoading
                          ? 'Aggiornamento...'
                          : 'Aggiorna password',
                      onPressed: isLoading || !isPasswordValid
                          ? null
                          : _onSubmit,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscure;
  final VoidCallback onToggleVisibility;
  final String? Function(String?) validator;
  final ValueChanged<String>? onChanged;

  const _PasswordField({
    required this.controller,
    required this.hintText,
    required this.obscure,
    required this.onToggleVisibility,
    required this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: isDark ? AppColors.inputFillDark : AppColors.inputFillLight,
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: onToggleVisibility,
        ),
      ).applyDefaults(Theme.of(context).inputDecorationTheme),
      style: TextStyle(
        color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
      ),
    );
  }
}
