import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_amis/common/helpers/app_info.dart';
import 'package:real_amis/common/helpers/open_support_contact.dart';
import 'package:real_amis/common/widgets/appBar/app_bar_no_nav.dart';
import 'package:real_amis/common/widgets/confirmDialog/styled_confirm_dialog.dart';
import 'package:real_amis/common/widgets/loader/loader.dart';
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
  ThemeMode? _selectedTheme;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _selectedTheme = context.read<ThemeCubit>().state;
      setState(() {});
      context.read<AuthBloc>().add(AuthIsUserLoggedIn());
    });
  }

  Future<bool?> _showLogoutConfirm() {
    return showDialog<bool>(
      context: context,
      builder: (context) => const StyledConfirmDialog(
        title: 'Conferma',
        message: 'Sei sicuro di voler effettuare il logout?',
        cancelLabel: 'Annulla',
        confirmLabel: 'Disconnettiti',
      ),
    );
  }

  Future<bool?> _showDeleteAccountConfirm() {
    return showDialog<bool>(
      context: context,
      builder: (context) => const StyledConfirmDialog(
        title: 'Elimina account',
        message: 'Questa azione è irreversibile. Vuoi procedere?',
        cancelLabel: 'Annulla',
        confirmLabel: 'Elimina',
      ),
    );
  }

  void _onThemeSelected(ThemeMode mode) {
    setState(() => _selectedTheme = mode);
    context.read<ThemeCubit>().updateTheme(mode);
  }

  void _onLogoutPressed() async {
    final confirm = await _showLogoutConfirm();
    if (confirm == true && mounted) {
      context.read<AuthBloc>().add(AuthLogout());
    }
  }

  void _onDeleteAccountPressed() async {
    final confirm = await _showDeleteAccountConfirm();
    if (confirm == true && mounted) {
      context.read<AuthBloc>().add(AuthDeleteAccount(id: '' /*TODO*/));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarNoNav(),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            showSnackBar(context, state.message);
          } else if (state is AuthLoggedOut) {
            if (!mounted) return;
            Navigator.pushAndRemoveUntil(
              context,
              SigninPage.route(),
              (route) => false,
            );
          } else if (state is AuthAccountDeleted) {
            if (!mounted) return;
            Navigator.pushAndRemoveUntil(
              context,
              SigninPage.route(),
              (route) => false,
            );
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) return const Loader();

          final userEmail = (state is AuthChecked) ? state.user.email : null;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    'Account',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                SettingsTile(
                  title: 'Email',
                  subtitle: userEmail ?? 'Non disponibile',
                ),
                const SizedBox(height: 4),
                SettingsTile(
                  title: 'Cambia password',
                  trailing: IconButton(
                    tooltip: 'Cambia password',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ResetPasswordFromLinkPage(), //TODO
                        ),
                      );
                    },
                    icon: const Icon(Icons.lock_open, size: 26),
                  ),
                ),
                const SizedBox(height: 4),
                SettingsTile(
                  title: 'Elimina account',
                  subtitle: 'Rimuove definitivamente tutti i dati associati.',
                  trailing: TextButton(
                    onPressed: _onDeleteAccountPressed,
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                    ),
                    child: const Text('Elimina'),
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    'Tema',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
                Card(
                  color: Theme.of(context).colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      RadioGroup<ThemeMode>(
                        groupValue: _selectedTheme,
                        onChanged: (ThemeMode? v) {
                          if (v == null) return;
                          setState(() => _selectedTheme = v);
                          _onThemeSelected(v);
                        },
                        child: Column(
                          children: [
                            ListTile(
                              leading: Radio<ThemeMode>(value: ThemeMode.light),
                              title: const Text('Chiaro'),
                              onTap: () {
                                setState(
                                  () => _selectedTheme = ThemeMode.light,
                                );
                                _onThemeSelected(ThemeMode.light);
                              },
                            ),
                            ListTile(
                              leading: Radio<ThemeMode>(value: ThemeMode.dark),
                              title: const Text('Scuro'),
                              onTap: () {
                                setState(() => _selectedTheme = ThemeMode.dark);
                                _onThemeSelected(ThemeMode.dark);
                              },
                            ),
                            ListTile(
                              leading: Radio<ThemeMode>(
                                value: ThemeMode.system,
                              ),
                              title: const Text('Sistema'),
                              onTap: () {
                                setState(
                                  () => _selectedTheme = ThemeMode.system,
                                );
                                _onThemeSelected(ThemeMode.system);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    'Informazioni',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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
                    return SettingsTile(title: 'Versione', subtitle: ver);
                  },
                ),
                const SizedBox(height: 4),
                SettingsTile(
                  title: 'Termini e Privacy',
                  trailing: IconButton(
                    tooltip: 'Apri Termini e Privacy',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => TermsPrivacyPage()),
                      );
                    },
                    icon: const Icon(Icons.description_outlined),
                  ),
                ),
                const SizedBox(height: 4),
                SettingsTile(
                  title: 'Contatta supporto',
                  subtitle: 'invia feedback o segnala un problema',
                  trailing: IconButton(
                    tooltip: 'Contatta supporto',
                    onPressed: () => openSupportContact(),
                    icon: const Icon(Icons.email_outlined),
                  ),
                ),
                const Divider(),
                SettingsTile(
                  title: 'Esci',
                  trailing: IconButton(
                    tooltip: 'Disconnettiti',
                    onPressed: _onLogoutPressed,
                    icon: const Icon(Icons.exit_to_app, size: 28),
                    color: Theme.of(context).colorScheme.onSurface,
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
