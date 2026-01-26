import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_amis/common/helpers/is_dark_mode.dart';
import 'package:real_amis/common/widgets/appBar/app_bar_no_nav.dart';
import 'package:real_amis/common/widgets/button/basic_app_button.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';
import 'package:real_amis/core/utils/show_snackbar.dart';
import 'package:real_amis/presentation/auth/bloc/auth_bloc.dart';
import 'package:real_amis/presentation/auth/pages/forgot_password.dart';
import 'package:real_amis/presentation/auth/pages/signup.dart';
import 'package:real_amis/presentation/main/pages/main_page.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({super.key});
  static MaterialPageRoute route() =>
      MaterialPageRoute(builder: (_) => const SigninPage());

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleAuthSuccess() {
    if (!mounted) return;
    context.read<AuthBloc>().add(AuthIsUserLoggedIn());
    Navigator.pushAndRemoveUntil(context, MainPage.route(), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final textPrimary = isDark
        ? AppColors.textDarkPrimary
        : AppColors.textLightPrimary;
    final inputFill = isDark
        ? AppColors.inputFillDark
        : AppColors.inputFillLight;

    return Scaffold(
      appBar: AppBarNoNav(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthFailure) {
                if (mounted) {
                  final friendlyMsg = getFriendlyErrorMessage(state.message);
                  showSnackBar(context, friendlyMsg);
                }
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
                    const Text(
                      'Accedi',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                      ),
                    ),
                    const SizedBox(height: 40),
                    _EmailField(
                      controller: _emailController,
                      inputFill: inputFill,
                      textColor: textPrimary,
                    ),
                    const SizedBox(height: 20),
                    _PasswordField(
                      controller: _passwordController,
                      inputFill: inputFill,
                      textColor: textPrimary,
                    ),
                    const SizedBox(height: 30),
                    _LoginButton(
                      isLoading: isLoading,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          context.read<AuthBloc>().add(
                            AuthLogin(
                              email: _emailController.text.trim(),
                              password: _passwordController.text.trim(),
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    const _ForgotPasswordButton(),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: const _SignupText(),
    );
  }
}

class _EmailField extends StatelessWidget {
  final TextEditingController controller;
  final Color inputFill;
  final Color textColor;

  const _EmailField({
    required this.controller,
    required this.inputFill,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        hintText: 'Email',
        filled: true,
        fillColor: inputFill,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ).applyDefaults(Theme.of(context).inputDecorationTheme),
      validator: (v) =>
          v == null || v.trim().isEmpty ? 'Inserisci una email valida' : null,
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final Color inputFill;
  final Color textColor;

  const _PasswordField({
    required this.controller,
    required this.inputFill,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        hintText: 'Password',
        filled: true,
        fillColor: inputFill,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ).applyDefaults(Theme.of(context).inputDecorationTheme),
      validator: (v) =>
          v == null || v.trim().length < 6 ? 'Inserisci una password' : null,
    );
  }
}

class _LoginButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;
  const _LoginButton({required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return BasicAppButton(
      onPressed: isLoading ? null : onPressed,
      title: isLoading ? 'Caricamento...' : 'Accedi',
    );
  }
}

class _ForgotPasswordButton extends StatelessWidget {
  const _ForgotPasswordButton();

  @override
  Widget build(BuildContext context) {
    final color = context.isDarkMode ? AppColors.tertiary : AppColors.primary;

    return TextButton(
      onPressed: () {
        if (context.mounted) {
          Navigator.push(context, ForgotPasswordPage.route());
        }
      },
      child: Text('Password dimenticata?', style: TextStyle(color: color)),
    );
  }
}

class _SignupText extends StatelessWidget {
  const _SignupText();

  @override
  Widget build(BuildContext context) {
    final color = context.isDarkMode ? AppColors.tertiary : AppColors.primary;

    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Non sei ancora un membro?',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
          TextButton(
            onPressed: () {
              if (context.mounted) {
                Navigator.pushReplacement(context, SignupPage.route());
              }
            },
            child: Text('Registrati subito', style: TextStyle(color: color)),
          ),
        ],
      ),
    );
  }
}

String getFriendlyErrorMessage(String rawMessage) {
  final msg = rawMessage.toLowerCase();
  if (msg.contains('invalid login credentials') ||
      msg.contains('invalid password') ||
      msg.contains('email not found')) {
    return 'Email o password errata';
  } else if (msg.contains('user disabled')) {
    return 'Account disabilitato, contatta il supporto';
  } else if (msg.contains('network')) {
    return 'Errore di rete, controlla la connessione';
  }
  return 'Si è verificato un errore, riprova';
}
