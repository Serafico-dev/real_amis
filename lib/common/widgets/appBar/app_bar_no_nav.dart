import 'package:flutter/material.dart';
import 'package:real_amis/common/helpers/is_dark_mode.dart';
import 'package:real_amis/core/configs/assets/app_vectors.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';

class AppBarNoNav extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final List<Widget>? actions;
  const AppBarNoNav({super.key, this.title, this.actions});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: context.isDarkMode
          ? AppColors.tertiary.withValues(alpha: 0.25)
          : AppColors.primary.withValues(alpha: 0.25),
      elevation: 0,
      centerTitle: true,
      title:
          title ??
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(AppVectors.logo, height: 48),
              const SizedBox(height: 6),
            ],
          ),
      titleTextStyle: TextStyle(
        color: context.isDarkMode
            ? AppColors.textDarkPrimary
            : AppColors.textLightPrimary,
      ),
      leading: null,
      automaticallyImplyLeading: false,
      actions: actions,
      iconTheme: IconThemeData(
        color: context.isDarkMode ? AppColors.iconDark : AppColors.iconLight,
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
