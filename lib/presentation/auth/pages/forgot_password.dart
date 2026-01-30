import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:real_amis/common/helpers/is_dark_mode.dart';
import 'package:real_amis/common/widgets/appBar/app_bar_yes_nav.dart';
import 'package:real_amis/common/widgets/button/basic_app_button.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';
import 'package:real_amis/core/utils/show_snackbar.dart';
import 'package:real_amis/presentation/auth/providers/app_user_provider.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});
  static MaterialPageRoute route() =>
      MaterialPageRoute(builder: (_) => const ForgotPasswordPage());

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleEmailSent() {
    if (!mounted) return;
    showSnackBar(context, 'Email inviata: controlla la tua casella di posta');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final textSecondary = isDark
        ? AppColors.textDarkSecondary
        : AppColors.textLightSecondary;

    final asyncState = ref.watch(appUserProvider);

    final isLoading = asyncState is AsyncLoading;

    return Scaffold(
      appBar: AppBarYesNav(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 48),
                Text(
                  'Inserisci la tua email per ricevere il link di reset',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: textSecondary, fontSize: 16),
                ),
                const SizedBox(height: 12),
                _EmailField(controller: _emailController),
                const SizedBox(height: 12),
                BasicAppButton(
                  title: isLoading
                      ? 'Invio in corso...'
                      : 'Invia email di recupero',
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            try {
                              await ref
                                  .read(appUserProvider.notifier)
                                  .requestPasswordReset(
                                    email: _emailController.text.trim(),
                                  );
                              _handleEmailSent();
                            } catch (e) {
                              if (!context.mounted) return;
                              showSnackBar(
                                context,
                                'Errore durante l\'invio: $e',
                              );
                            }
                          }
                        },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmailField extends StatelessWidget {
  final TextEditingController controller;
  const _EmailField({required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        hintText: 'Email',
        filled: true,
        fillColor: isDark ? AppColors.inputFillDark : AppColors.inputFillLight,
      ).applyDefaults(Theme.of(context).inputDecorationTheme),
      style: TextStyle(
        color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
      ),
      validator: (v) =>
          v == null || v.trim().isEmpty ? 'Inserisci una email valida' : null,
    );
  }
}
