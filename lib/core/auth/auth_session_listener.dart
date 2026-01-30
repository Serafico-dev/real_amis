import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:real_amis/presentation/auth/providers/app_user_notifier.dart';
import 'package:real_amis/domain/entities/auth/user_entity.dart';

class AuthSessionListener {
  final SupabaseClient supabase;
  final AppUserNotifier appUserNotifier;

  AuthSessionListener({required this.supabase, required this.appUserNotifier});

  void start() {
    supabase.auth.onAuthStateChange.listen((data) async {
      final session = data.session;

      if (session == null) {
        appUserNotifier.setLoggedOut();
        return;
      }

      final user = UserEntity(
        id: session.user.id,
        email: session.user.email ?? '',
        isAdmin: false,
      );

      appUserNotifier.setLoggedIn(user);
    });
  }
}
