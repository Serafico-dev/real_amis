import 'package:flutter/material.dart';
import 'package:real_amis/common/helpers/is_dark_mode.dart';
import 'package:real_amis/core/configs/assets/app_vectors.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';

class AppBarYesNav extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final List<Widget>? actions;
  const AppBarYesNav({super.key, this.title, this.actions});

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
      leading: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.04),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.arrow_back_ios_new,
            size: 15,
            color: context.isDarkMode ? AppColors.tertiary : Colors.black,
          ),
        ),
      ),
      actions: actions,
      iconTheme: IconThemeData(
        color: context.isDarkMode ? AppColors.iconDark : AppColors.iconPrimary,
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
