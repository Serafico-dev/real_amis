import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_amis/common/helpers/app_info.dart';
import 'package:real_amis/common/helpers/is_dark_mode.dart';
import 'package:real_amis/common/helpers/open_support_contact.dart';
import 'package:real_amis/common/widgets/appBar/app_bar_no_nav.dart';
import 'package:real_amis/common/widgets/confirmDialog/styled_confirm_dialog.dart';
import 'package:real_amis/common/widgets/loader/loader.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';
import 'package:real_amis/core/utils/show_snackbar.dart';
import 'package:real_amis/presentation/auth/bloc/auth_bloc.dart';
import 'package:real_amis/presentation/auth/pages/reset_password_from_link.dart';
import 'package:real_amis/presentation/auth/pages/signin.dart';
import 'package:real_amis/presentation/choose_mode/bloc/theme_cubit.dart';
import 'package:real_amis/presentation/settings/pages/terms_privacy_page.dart';
import 'package:real_amis/presentation/settings/widgets/settings_tile.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late ThemeMode _selectedTheme;

  @override
  void initState() {
    super.initState();
    _selectedTheme = context.read<ThemeCubit>().state;
    context.read<AuthBloc>().add(AuthIsUserLoggedIn());
  }

  Future<bool?> _showConfirmDialog({
    required String title,
    required String message,
    required String confirmLabel,
    String cancelLabel = 'Annulla',
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => StyledConfirmDialog(
        title: title,
        message: message,
        cancelLabel: cancelLabel,
        confirmLabel: confirmLabel,
      ),
    );
  }

  void _onThemeSelected(ThemeMode mode) {
    setState(() => _selectedTheme = mode);
    context.read<ThemeCubit>().updateTheme(mode);
  }

  void _redirectToSignin() {
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(context, SigninPage.route(), (route) => false);
  }

  Future<void> _onLogoutPressed() async {
    final confirm = await _showConfirmDialog(
      title: 'Conferma',
      message: 'Sei sicuro di voler effettuare il logout?',
      confirmLabel: 'Disconnettiti',
    );
    if (confirm == true && mounted) {
      context.read<AuthBloc>().add(AuthLogout());
    }
  }

  Future<void> _onDeleteAccountPressed() async {
    final confirm = await _showConfirmDialog(
      title: 'Elimina account',
      message: 'Questa azione è irreversibile. Vuoi procedere?',
      confirmLabel: 'Elimina',
    );
    if (confirm == true && mounted) {
      context.read<AuthBloc>().add(AuthDeleteAccount(id: '' /*TODO*/));
    }
  }

  Widget _buildThemeTile(ThemeMode mode, String label) {
    final isDarkMode = context.isDarkMode;
    final textColor = isDarkMode
        ? AppColors.textDarkPrimary
        : AppColors.textLightPrimary;

    return ListTile(
      leading: RadioGroup<ThemeMode>(
        groupValue: _selectedTheme,
        onChanged: (m) {
          if (m != null) _onThemeSelected(m);
        },
        child: Radio<ThemeMode>(value: mode),
      ),
      title: Text(label, style: TextStyle(color: textColor)),
      onTap: () => _onThemeSelected(mode),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.isDarkMode;
    final bgColor = isDarkMode ? AppColors.bgDark : AppColors.bgLight;
    final textColor = isDarkMode
        ? AppColors.textDarkPrimary
        : AppColors.textLightPrimary;
    final subtitleColor = isDarkMode
        ? AppColors.textDarkSecondary
        : AppColors.textLightSecondary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBarNoNav(),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) showSnackBar(context, state.message);
          if (state is AuthLoggedOut || state is AuthAccountDeleted) {
            _redirectToSignin();
          }
        },
        builder: (context, state) {
          final userEmail = (state is AuthChecked) ? state.user.email : null;
          if (state is AuthLoading) return const Loader();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'Account',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
                SettingsTile(
                  title: 'Email',
                  subtitle: userEmail ?? 'Non disponibile',
                  titleColor: textColor,
                  subtitleColor: subtitleColor,
                ),
                const SizedBox(height: 4),
                SettingsTile(
                  title: 'Cambia password',
                  titleColor: textColor,
                  trailing: IconButton(
                    tooltip: 'Cambia password',
                    onPressed: () {
                      Navigator.push(
                        context,
                        ResetPasswordFromLinkPage.route(),
                      );
                    },
                    icon: Icon(Icons.lock_open, size: 26, color: textColor),
                  ),
                ),
                const SizedBox(height: 4),
                SettingsTile(
                  title: 'Elimina account',
                  subtitle: 'Rimuove definitivamente tutti i dati associati.',
                  titleColor: textColor,
                  subtitleColor: subtitleColor,
                  trailing: TextButton(
                    onPressed: _onDeleteAccountPressed,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.logoRed,
                    ),
                    child: const Text('Elimina'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'Tema',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                ),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: isDarkMode ? AppColors.cardDark : AppColors.cardLight,
                  child: Column(
                    children: [
                      _buildThemeTile(ThemeMode.light, 'Chiaro'),
                      _buildThemeTile(ThemeMode.dark, 'Scuro'),
                      _buildThemeTile(ThemeMode.system, 'Sistema'),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'Informazioni',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                ),
                FutureBuilder<String>(
                  future: AppInfo.versionWithBuildAsync(),
                  builder: (context, snap) {
                    final ver =
                        snap.data ??
                        (snap.connectionState == ConnectionState.waiting
                            ? 'Caricamento...'
                            : 'N/A');
                    return SettingsTile(
                      title: 'Versione',
                      subtitle: ver,
                      titleColor: textColor,
                      subtitleColor: subtitleColor,
                    );
                  },
                ),
                const SizedBox(height: 4),
                SettingsTile(
                  title: 'Termini e Privacy',
                  titleColor: textColor,
                  trailing: IconButton(
                    tooltip: 'Apri Termini e Privacy',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => TermsPrivacyPage()),
                    ),
                    icon: Icon(Icons.description_outlined, color: textColor),
                  ),
                ),
                const SizedBox(height: 4),
                SettingsTile(
                  title: 'Contatta supporto',
                  titleColor: textColor,
                  subtitle: 'invia feedback o segnala un problema',
                  subtitleColor: subtitleColor,
                  trailing: IconButton(
                    tooltip: 'Contatta supporto',
                    onPressed: openSupportContact,
                    icon: Icon(Icons.email_outlined, color: textColor),
                  ),
                ),
                const Divider(color: Colors.grey),
                SettingsTile(
                  title: 'Esci',
                  titleColor: textColor,
                  trailing: IconButton(
                    tooltip: 'Disconnettiti',
                    onPressed: _onLogoutPressed,
                    icon: Icon(Icons.exit_to_app, size: 28, color: textColor),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}
