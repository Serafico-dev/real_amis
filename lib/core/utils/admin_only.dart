import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_amis/core/cubits/app_user/app_user_cubit.dart';

class AdminOnly extends StatelessWidget {
  final Widget child;
  const AdminOnly({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<AppUserCubit, AppUserState, bool>(
      selector: (s) => s is AppUserLoggedIn && s.user.isAdmin,
      builder: (_, isAdmin) => isAdmin ? child : const SizedBox.shrink(),
    );
  }
}
