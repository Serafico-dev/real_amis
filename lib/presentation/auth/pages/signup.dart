import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_amis/common/helpers/is_dark_mode.dart';
import 'package:real_amis/common/widgets/appBar/app_bar_no_nav.dart';
import 'package:real_amis/common/widgets/button/basic_app_button.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';
import 'package:real_amis/core/utils/show_snackbar.dart';
import 'package:real_amis/presentation/auth/bloc/auth_bloc.dart';
import 'package:real_amis/presentation/auth/pages/signin.dart';
import 'package:real_amis/presentation/main/pages/main_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});
  static MaterialPageRoute route() =>
      MaterialPageRoute(builder: (_) => const SignupPage());

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleAuthSuccess() {
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(context, MainPage.route(), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final textPrimary = isDark
        ? AppColors.textDarkPrimary
        : AppColors.textLightPrimary;

    return Scaffold(
      appBar: AppBarNoNav(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
          child: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthFailure) {
                if (mounted) showSnackBar(context, state.message);
              } else if (state is AuthSuccess) {
                _handleAuthSuccess();
              }
            },
            builder: (context, state) {
              final isLoading = state is AuthLoading;

              return Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    Text(
                      'Unisciti al club',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _EmailField(controller: _emailController),
                    const SizedBox(height: 20),
                    _PasswordField(controller: _passwordController),
                    const SizedBox(height: 30),
                    BasicAppButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                context.read<AuthBloc>().add(
                                  AuthSignUp(
                                    email: _emailController.text.trim(),
                                    password: _passwordController.text.trim(),
                                  ),
                                );
                              }
                            },
                      title: isLoading ? 'Caricamento...' : 'Registrati',
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: const _SigninText(),
    );
  }
}

class _EmailField extends StatelessWidget {
  final TextEditingController controller;
  const _EmailField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        hintText: 'Email',
        filled: true,
        fillColor: context.isDarkMode
            ? AppColors.inputFillDark
            : AppColors.inputFillLight,
      ).applyDefaults(Theme.of(context).inputDecorationTheme),
      style: TextStyle(
        color: context.isDarkMode
            ? AppColors.textDarkPrimary
            : AppColors.textLightPrimary,
      ),
      validator: (v) =>
          v == null || v.trim().isEmpty ? 'Inserisci una email valida' : null,
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  const _PasswordField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        hintText: 'Password',
        filled: true,
        fillColor: context.isDarkMode
            ? AppColors.inputFillDark
            : AppColors.inputFillLight,
      ).applyDefaults(Theme.of(context).inputDecorationTheme),
      style: TextStyle(
        color: context.isDarkMode
            ? AppColors.textDarkPrimary
            : AppColors.textLightPrimary,
      ),
      validator: (v) => v == null || v.trim().length < 6
          ? 'Inserisci una password di almeno 6 caratteri'
          : null,
    );
  }
}

class _SigninText extends StatelessWidget {
  const _SigninText();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Fai già parte del club?',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: context.isDarkMode
                  ? AppColors.textDarkSecondary
                  : AppColors.textLightSecondary,
            ),
          ),
          TextButton(
            onPressed: () {
              if (context.mounted) {
                Navigator.pushReplacement(context, SigninPage.route());
              }
            },
            child: Text(
              'Accedi',
              style: TextStyle(
                color: context.isDarkMode
                    ? AppColors.tertiary
                    : AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
