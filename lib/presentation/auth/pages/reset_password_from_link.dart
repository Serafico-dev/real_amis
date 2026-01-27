import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_amis/common/helpers/is_dark_mode.dart';
import 'package:real_amis/common/widgets/appBar/app_bar_yes_nav.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';
import 'package:real_amis/core/utils/show_snackbar.dart';
import 'package:real_amis/presentation/auth/bloc/auth_bloc.dart';
import 'package:real_amis/presentation/auth/pages/signin.dart';
import 'package:real_amis/common/widgets/button/basic_app_button.dart';
import 'package:real_amis/common/widgets/loader/loader.dart';

class ResetPasswordFromLinkPage extends StatefulWidget {
  const ResetPasswordFromLinkPage({super.key});
  static MaterialPageRoute route() =>
      MaterialPageRoute(builder: (_) => const ResetPasswordFromLinkPage());

  @override
  State<ResetPasswordFromLinkPage> createState() =>
      _ResetPasswordFromLinkPageState();
}

class _ResetPasswordFromLinkPageState extends State<ResetPasswordFromLinkPage> {
  final _pwController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loadingLink = true;

  @override
  void initState() {
    super.initState();
    _loadingLink = false;
  }

  @override
  void dispose() {
    _pwController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final newPw = _pwController.text.trim();

    context.read<AuthBloc>().add(AuthCompletePasswordReset(newPassword: newPw));
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
      appBar: AppBarYesNav(title: const Text('Imposta nuova password')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthPasswordResetCompleted) {
              showSnackBar(context, 'Password aggiornata. Effettua il login.');
              Navigator.pushAndRemoveUntil(
                context,
                SigninPage.route(),
                (route) => false,
              );
            } else if (state is AuthPasswordResetFailure) {
              showSnackBar(context, state.message);
            }
          },
          builder: (context, state) {
            if (_loadingLink || state is AuthLoading) return const Loader();

            return Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _pwController,
                    obscureText: true,
                    style: TextStyle(color: textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Nuova password',
                      filled: true,
                      fillColor: inputFill,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ).applyDefaults(Theme.of(context).inputDecorationTheme),
                    validator: (v) =>
                        v == null || v.length < 6 ? 'Minimo 6 caratteri' : null,
                  ),
                  const SizedBox(height: 16),
                  BasicAppButton(
                    title: 'Aggiorna password',
                    onPressed: _onSubmit,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
