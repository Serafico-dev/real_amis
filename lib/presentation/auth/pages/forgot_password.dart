import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_amis/common/widgets/appBar/app_bar_yes_nav.dart';
import 'package:real_amis/common/widgets/button/basic_app_button.dart';
import 'package:real_amis/common/widgets/loader/loader.dart';
import 'package:real_amis/core/configs/assets/app_vectors.dart';
import 'package:real_amis/core/utils/show_snackbar.dart';
import 'package:real_amis/presentation/auth/bloc/auth_bloc.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});
  static MaterialPageRoute route() =>
      MaterialPageRoute(builder: (_) => const ForgotPasswordPage());

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarYesNav(title: Image.asset(AppVectors.logo, width: 50)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthPasswordResetEmailSent) {
                if (context.mounted) {
                  showSnackBar(
                    context,
                    'Email inviata: controlla la tua casella di posta',
                  );
                  Navigator.pop(context);
                }
              } else if (state is AuthPasswordResetFailure) {
                if (context.mounted) {
                  showSnackBar(context, state.message);
                }
              }
            },
            builder: (context, state) {
              if (state is AuthLoading) return const Loader();
              return Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 48),
                    const Text(
                      'Inserisci la tua email per ricevere il link di reset',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(hintText: 'Email'),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Inserisci email'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    BasicAppButton(
                      title: 'Invia email di recupero',
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          context.read<AuthBloc>().add(
                            AuthSendPasswordResetEmail(
                              email: _emailController.text.trim(),
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 48),
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
