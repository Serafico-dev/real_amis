import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:real_amis/common/helpers/app_info.dart';
import 'package:real_amis/common/helpers/is_dark_mode.dart';
import 'package:real_amis/common/helpers/open_support_contact.dart';
import 'package:real_amis/common/widgets/appBar/app_bar_no_nav.dart';
import 'package:real_amis/common/widgets/confirmDialog/styled_confirm_dialog.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';
import 'package:real_amis/presentation/auth/pages/change_password.dart';
import 'package:real_amis/presentation/auth/pages/signin.dart';
import 'package:real_amis/presentation/auth/providers/app_user_notifier.dart';
import 'package:real_amis/presentation/auth/providers/app_user_provider.dart';
import 'package:real_amis/presentation/choose_mode/providers/theme_provider.dart';
import 'package:real_amis/presentation/settings/pages/terms_privacy_page.dart';
import 'package:real_amis/presentation/settings/widgets/settings_tile.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  late ThemeMode _selectedTheme;

  @override
  void initState() {
    super.initState();
    _selectedTheme = ref.read(themeNotifierProvider);
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
    ref.read(themeNotifierProvider.notifier).updateTheme(mode);
  }

  Future<void> _onLogoutPressed() async {
    final confirm = await _showConfirmDialog(
      title: 'Conferma',
      message: 'Sei sicuro di voler effettuare il logout?',
      confirmLabel: 'Disconnettiti',
    );

    if (confirm == true && mounted) {
      await ref.read(appUserProvider.notifier).signOut();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(context, SigninPage.route(), (_) => false);
      });
    }
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

    final userState = ref.watch(appUserProvider);

    final userEmail = userState.maybeWhen(
      data: (state) => state is AppUserLoggedIn ? state.user.email : null,
      orElse: () => 'Non disponibile',
    );

    return Scaffold(
      backgroundColor: bgColor,
      appBar: const AppBarNoNav(),
      body: SingleChildScrollView(
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
              subtitle: userEmail,
              titleColor: textColor,
              subtitleColor: subtitleColor,
            ),

            const SizedBox(height: 4),

            SettingsTile(
              title: 'Cambia password',
              titleColor: textColor,
              trailing: IconButton(
                tooltip: 'Cambia password',
                onPressed: () =>
                    Navigator.push(context, ChangePasswordPage.route()),
                icon: Icon(Icons.lock_open, size: 26, color: textColor),
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
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 24,
                ),
                child: SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(
                      value: ThemeMode.light,
                      icon: Icon(Icons.light_mode_outlined),
                      label: Text('Chiaro'),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      icon: Icon(Icons.dark_mode_outlined),
                      label: Text('Scuro'),
                    ),
                    ButtonSegment(
                      value: ThemeMode.system,
                      icon: Icon(Icons.settings_suggest_outlined),
                      label: Text('Sistema'),
                    ),
                  ],
                  selected: {_selectedTheme},
                  onSelectionChanged: (selection) =>
                      _onThemeSelected(selection.first),
                  style: ButtonStyle(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                    backgroundColor: WidgetStateProperty.resolveWith((states) {
                      final isSelected = states.contains(WidgetState.selected);
                      if (isSelected) {
                        return isDarkMode
                            ? AppColors.tertiary.withValues(alpha: 0.35)
                            : AppColors.primary.withValues(alpha: 0.25);
                      }
                      return Colors.transparent;
                    }),
                    foregroundColor: WidgetStateProperty.resolveWith((states) {
                      final isSelected = states.contains(WidgetState.selected);
                      if (isSelected) {
                        return isDarkMode
                            ? AppColors.textDarkPrimary
                            : AppColors.textLightPrimary;
                      }
                      return isDarkMode
                          ? AppColors.textDarkSecondary
                          : AppColors.textLightSecondary;
                    }),
                    side: WidgetStateProperty.resolveWith((states) {
                      final isSelected = states.contains(WidgetState.selected);
                      return BorderSide(
                        color: isSelected
                            ? (isDarkMode
                                  ? AppColors.tertiary
                                  : AppColors.primary)
                            : (isDarkMode
                                  ? AppColors.textDarkSecondary.withValues(
                                      alpha: 0.3,
                                    )
                                  : AppColors.textLightSecondary.withValues(
                                      alpha: 0.3,
                                    )),
                        width: 1,
                      );
                    }),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    overlayColor: WidgetStateProperty.all(
                      (isDarkMode ? AppColors.tertiary : AppColors.primary)
                          .withValues(alpha: 0.08),
                    ),
                  ),
                ),
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
                  MaterialPageRoute(builder: (_) => const TermsPrivacyPage()),
                ),
                icon: Icon(Icons.description_outlined, color: textColor),
              ),
            ),

            const SizedBox(height: 4),

            SettingsTile(
              title: 'Contatta supporto',
              subtitle: 'invia feedback o segnala un problema',
              titleColor: textColor,
              subtitleColor: subtitleColor,
              trailing: IconButton(
                tooltip: 'Contatta supporto',
                onPressed: () => openSupportContact(context),
                icon: Icon(Icons.email_outlined, color: textColor),
              ),
            ),

            const Divider(height: 50, color: Colors.grey),

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
      ),
    );
  }
}
