import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:real_amis/domain/entities/auth/user_entity.dart';
import 'package:real_amis/data/sources/auth/auth_supabase_data_source.dart';

sealed class AppUserState {}

final class AppUserInitial extends AppUserState {}

final class AppUserLoggedIn extends AppUserState {
  final UserEntity user;
  AppUserLoggedIn(this.user);
}

final class AppUserLoggedOut extends AppUserState {}

extension AppUserStateX on AppUserState {
  bool get isLoggedIn => this is AppUserLoggedIn;
  UserEntity? get user =>
      this is AppUserLoggedIn ? (this as AppUserLoggedIn).user : null;
}

class AppUserNotifier extends StateNotifier<AsyncValue<AppUserState>> {
  final AuthSupabaseDataSource authDataSource;

  AppUserNotifier(this.authDataSource)
    : super(AsyncValue.data(AppUserLoggedOut())) {
    _loadUser();
  }

  void setLoggedIn(UserEntity user) {
    state = AsyncValue.data(AppUserLoggedIn(user));
  }

  void setLoggedOut() {
    state = AsyncValue.data(AppUserLoggedOut());
  }

  Future<void> _loadUser() async {
    try {
      final user = await authDataSource.getCurrentUserData();
      if (user != null) {
        setLoggedIn(user);
      } else {
        setLoggedOut();
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncValue.loading();
    try {
      final user = await authDataSource.logInWithEmailPassword(
        email: email,
        password: password,
      );
      setLoggedIn(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signUp({required String email, required String password}) async {
    state = const AsyncValue.loading();
    try {
      final user = await authDataSource.signUpWithEmailPassword(
        email: email,
        password: password,
      );
      setLoggedIn(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      await authDataSource.logOut();
      setLoggedOut();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refreshUser() async {
    try {
      final user = await authDataSource.getCurrentUserData();
      if (user != null) {
        setLoggedIn(user);
      } else {
        setLoggedOut();
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> requestPasswordReset({required String email}) async {
    state = const AsyncValue.loading();
    try {
      await authDataSource.sendPasswordResetEmail(
        email: email,
        redirectTo: 'yourapp://reset-password',
      );
      state = state;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> completePasswordReset({required String newPassword}) async {
    state = const AsyncValue.loading();
    try {
      await authDataSource.updatePassword(newPassword: newPassword);
      setLoggedOut();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<ChangePasswordResult> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    state = const AsyncValue.loading();
    try {
      await authDataSource.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return ChangePasswordResult(success: true);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return ChangePasswordResult(success: false, message: e.toString());
    }
  }
}

class ChangePasswordResult {
  final bool success;
  final String? message;
  ChangePasswordResult({required this.success, this.message});
}
