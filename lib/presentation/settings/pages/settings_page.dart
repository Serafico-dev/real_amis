import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_amis/common/helpers/is_dark_mode.dart';
import 'package:real_amis/common/widgets/appBar/app_bar_no_nav.dart';
import 'package:real_amis/common/widgets/loader/loader.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';
import 'package:real_amis/core/utils/show_snackbar.dart';
import 'package:real_amis/presentation/auth/bloc/auth_bloc.dart';
import 'package:real_amis/presentation/auth/pages/signin.dart';
import 'package:real_amis/presentation/choose_mode/bloc/theme_cubit.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool light = false;

  @override
  Widget build(BuildContext context) {
    const WidgetStateProperty<Color?> trackColor =
        WidgetStateProperty<Color?>.fromMap(<WidgetStatesConstraint, Color>{
          WidgetState.selected: AppColors.primary,
        });
    final WidgetStateProperty<Color?> overlayColor =
        WidgetStateProperty<Color?>.fromMap(<WidgetState, Color>{
          WidgetState.selected: AppColors.primary,
          WidgetState.disabled: AppColors.quaternary,
        });

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
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Loader();
          }
          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(15),
                  ),
                  tileColor: AppColors.tertiary,
                  leading: Text(
                    'Tema',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  trailing: Switch(
                    overlayColor: overlayColor,
                    trackColor: trackColor,
                    thumbColor: const WidgetStatePropertyAll<Color>(
                      AppColors.quaternary,
                    ),
                    thumbIcon: WidgetStatePropertyAll(Icon(Icons.sunny)),
                    value: light,
                    onChanged: (value) {
                      context.isDarkMode
                          ? context.read<ThemeCubit>().updateTheme(
                              ThemeMode.light,
                            )
                          : context.read<ThemeCubit>().updateTheme(
                              ThemeMode.dark,
                            );
                      light = value;
                    },
                  ),
                ),
                SizedBox(height: 5),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(15),
                  ),
                  tileColor: AppColors.tertiary,
                  leading: Text(
                    'Disconnettiti',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  trailing: IconButton(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Conferma'),
                          content: const Text(
                            'Sei sicuro di voler effettuare il logout?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Annulla'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Disconnettiti'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        context.read<AuthBloc>().add(AuthLogout());
                      }
                    },
                    icon: Icon(Icons.exit_to_app, size: 30),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
