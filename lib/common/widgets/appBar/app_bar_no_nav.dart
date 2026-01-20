import 'package:flutter/material.dart';
import 'package:real_amis/common/helpers/is_dark_mode.dart';
import 'package:real_amis/core/configs/assets/app_vectors.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';

class AppBarNoNav extends StatelessWidget implements PreferredSizeWidget {
  final Color? backgroundColor;
  final Widget? title;
  final List<Widget>? actions;
  const AppBarNoNav({
    super.key,
    this.backgroundColor,
    this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: title ?? Image.asset(AppVectors.logo, height: 50),
      titleTextStyle: TextStyle(
        color: context.isDarkMode
            ? AppColors.textDarkPrimary
            : AppColors.textLightPrimary,
      ),
      leading: null,
      automaticallyImplyLeading: false,
      actions: actions,
      iconTheme: IconThemeData(
        color: context.isDarkMode ? AppColors.iconDark : AppColors.iconPrimary,
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
