import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:real_amis/core/utils/show_snackbar.dart';
import 'package:real_amis/presentation/auth/providers/app_user_provider.dart';
import 'package:real_amis/presentation/auth/providers/app_user_state.dart';

class AdminOnly extends ConsumerWidget {
  final Widget child;
  final bool hideWhileLoading;

  const AdminOnly({
    super.key,
    required this.child,
    this.hideWhileLoading = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userStateAsync = ref.watch(appUserProvider);

    return userStateAsync.when(
      data: (userState) {
        if (userState is AppUserLoggedIn && userState.user.isAdmin) {
          return child;
        } else {
          return const SizedBox.shrink();
        }
      },
      loading: () => hideWhileLoading ? const SizedBox.shrink() : child,
      error: (err, st) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => showSnackBar(context, err.toString()),
        );
        return Center(child: Text('Errore: ${err.toString()}'));
      },
    );
  }
}
