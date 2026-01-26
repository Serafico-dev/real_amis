import 'package:real_amis/core/cubits/app_user/app_user_cubit.dart';
import 'package:real_amis/data/models/auth/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthSessionListener {
  final SupabaseClient supabase;
  final AppUserCubit appUserCubit;

  AuthSessionListener({required this.supabase, required this.appUserCubit});

  void start() {
    supabase.auth.onAuthStateChange.listen((data) async {
      final session = data.session;

      if (session == null) {
        appUserCubit.clearUser();
        return;
      }

      final user = UserModel(
        id: session.user.id,
        email: session.user.email ?? '',
        isAdmin: false,
      );

      appUserCubit.updateUser(user);
    });
  }
}
