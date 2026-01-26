part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

final class AuthSignUp extends AuthEvent {
  final String email;
  final String password;

  AuthSignUp({required this.email, required this.password});
}

final class AuthLogin extends AuthEvent {
  final String email;
  final String password;

  AuthLogin({required this.email, required this.password});
}

final class AuthLogout extends AuthEvent {}

final class AuthSendPasswordResetEmail extends AuthEvent {
  final String email;

  AuthSendPasswordResetEmail({required this.email});
}

final class AuthCompletePasswordReset extends AuthEvent {
  final String accessToken;
  final String newPassword;

  AuthCompletePasswordReset({
    required this.accessToken,
    required this.newPassword,
  });
}

final class AuthChangePassword extends AuthEvent {
  final String currentPassword;
  final String newPassword;

  AuthChangePassword({
    required this.currentPassword,
    required this.newPassword,
  });
}

final class AuthDeleteAccount extends AuthEvent {
  final String id;

  AuthDeleteAccount({required this.id});
}
