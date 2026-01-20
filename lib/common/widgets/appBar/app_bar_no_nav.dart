import 'package:flutter/material.dart';
import 'package:real_amis/core/configs/assets/app_vectors.dart';

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
      leading: null,
      automaticallyImplyLeading: false,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
