part of 'auth_bloc.dart';

@immutable
sealed class AuthState {
  const AuthState();
}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthSuccess extends AuthState {
  final UserEntity user;
  const AuthSuccess(this.user);
}

final class AuthChecked extends AuthState {
  final UserEntity user;
  const AuthChecked(this.user);
}

final class AuthFailure extends AuthState {
  final String message;
  const AuthFailure(this.message);
}

final class AuthLoggedOut extends AuthState {}

final class AuthPasswordResetEmailSent extends AuthState {}

final class AuthPasswordResetCompleted extends AuthState {}

final class AuthPasswordResetFailure extends AuthState {
  final String message;
  const AuthPasswordResetFailure(this.message);
}

final class AuthAccountDeleted extends AuthState {}
