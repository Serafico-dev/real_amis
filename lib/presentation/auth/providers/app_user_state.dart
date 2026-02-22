import 'package:real_amis/domain/entities/auth/user_entity.dart';

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
