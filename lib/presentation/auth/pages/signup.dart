import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_amis/common/helpers/is_dark_mode.dart';
import 'package:real_amis/common/widgets/appBar/app_bar_no_nav.dart';
import 'package:real_amis/common/widgets/button/basic_app_button.dart';
import 'package:real_amis/common/widgets/loader/loader.dart';
import 'package:real_amis/core/configs/assets/app_vectors.dart';
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
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarNoNav(title: Image.asset(AppVectors.logo, width: 50)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 30),
          child: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthFailure) {
                if (context.mounted) showSnackBar(context, state.message);
              } else if (state is AuthSuccess) {
                if (!context.mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MainPage.route(),
                  (route) => false,
                );
              }
            },
            builder: (context, state) {
              if (state is AuthLoading) {
                return const Loader();
              }
              return Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    _registerText(),
                    const SizedBox(height: 20),
                    _emailField(context),
                    const SizedBox(height: 20),
                    _passwordField(context),
                    const SizedBox(height: 20),
                    BasicAppButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          context.read<AuthBloc>().add(
                            AuthSignUp(
                              email: _email.text.trim(),
                              password: _password.text.trim(),
                            ),
                          );
                        }
                      },
                      title: 'Registrati',
                    ),
                    const SizedBox(height: 60),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: _signinText(context),
    );
  }

  Widget _registerText() {
    return const Text(
      'Unisciti al club',
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
    );
  }

  Widget _emailField(BuildContext context) {
    return TextFormField(
      controller: _email,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        hintText: 'Email',
      ).applyDefaults(Theme.of(context).inputDecorationTheme),
      validator: (v) =>
          v == null || v.trim().isEmpty ? 'Inserisci una email valida' : null,
    );
  }

  Widget _passwordField(BuildContext context) {
    return TextFormField(
      controller: _password,
      decoration: InputDecoration(
        hintText: 'Password',
      ).applyDefaults(Theme.of(context).inputDecorationTheme),
      obscureText: true,
      validator: (v) => v == null || v.trim().length < 6
          ? 'Inserisci una password di almeno 6 caratteri'
          : null,
    );
  }

  Widget _signinText(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Fai già parte del club?',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
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
