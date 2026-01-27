import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_amis/core/cubits/app_user/app_user_cubit.dart';

class AdminOnly extends StatelessWidget {
  final Widget child;
  final bool hideWhileLoading;

  const AdminOnly({
    super.key,
    required this.child,
    this.hideWhileLoading = true,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppUserCubit, AppUserState>(
      builder: (context, state) {
        if (state is AppUserLoggedIn) {
          return state.user.isAdmin ? child : const SizedBox.shrink();
        } else if (state is AppUserInitial && hideWhileLoading) {
          return const SizedBox.shrink();
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
