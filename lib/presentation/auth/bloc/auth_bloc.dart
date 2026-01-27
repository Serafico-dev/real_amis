import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_amis/core/cubits/app_user/app_user_cubit.dart';
import 'package:real_amis/core/usecase/usecase.dart';
import 'package:real_amis/domain/entities/auth/user_entity.dart';
import 'package:real_amis/domain/usecases/auth/change_password.dart';
import 'package:real_amis/domain/usecases/auth/password_reset.dart';
import 'package:real_amis/domain/usecases/auth/password_reset_complete.dart';
import 'package:real_amis/domain/usecases/auth/user_delete.dart';
import 'package:real_amis/domain/usecases/auth/user_login.dart';
import 'package:real_amis/domain/usecases/auth/user_logout.dart';
import 'package:real_amis/domain/usecases/auth/user_sign_up.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserSignUp _userSignUp;
  final UserLogin _userLogin;
  final UserLogout _userLogout;
  final PasswordReset _passwordReset;
  final PasswordResetComplete _passwordResetComplete;
  final ChangePassword _changePassword;
  final UserDelete _userDelete;
  final AppUserCubit _appUserCubit;

  AuthBloc({
    required UserSignUp userSignUp,
    required UserLogin userLogin,
    required UserLogout userLogout,
    required PasswordReset passwordReset,
    required PasswordResetComplete passwordResetComplete,
    required ChangePassword changePassword,
    required UserDelete userDelete,
    required AppUserCubit appUserCubit,
  }) : _userSignUp = userSignUp,
       _userLogin = userLogin,
       _userLogout = userLogout,
       _passwordReset = passwordReset,
       _passwordResetComplete = passwordResetComplete,
       _changePassword = changePassword,
       _userDelete = userDelete,
       _appUserCubit = appUserCubit,
       super(AuthInitial()) {
    on<AuthSignUp>(_onAuthSignUp);
    on<AuthLogin>(_onAuthLogin);
    on<AuthLogout>(_onAuthLogout);
    on<AuthSendPasswordResetEmail>(_onPasswordReset);
    on<AuthCompletePasswordReset>(_onPasswordUpdate);
    on<AuthChangePassword>(_onAuthChangePassword);
    on<AuthDeleteAccount>(_onAuthDeleteAccount);
  }

  Future<void> _onAuthSignUp(AuthSignUp event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final res = await _userSignUp(
      UserSignUpParams(email: event.email, password: event.password),
    );

    res.fold((l) {
      _appUserCubit.clearUser();
      emit(AuthFailure(l.message));
    }, (r) => _emitAuthSuccess(r, emit));
  }

  Future<void> _onAuthLogin(AuthLogin event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final res = await _userLogin(
      UserLoginParams(email: event.email, password: event.password),
    );

    res.fold((l) {
      _appUserCubit.clearUser();
      emit(AuthFailure(l.message));
    }, (r) => _emitAuthSuccess(r, emit));
  }

  Future<void> _onAuthLogout(AuthLogout event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final res = await _userLogout(NoParams());

    res.fold(
      (l) {
        _appUserCubit.clearUser();
        emit(AuthFailure(l.message));
      },
      (r) {
        _appUserCubit.clearUser();
        emit(AuthLoggedOut());
      },
    );
  }

  Future<void> _onPasswordReset(
    AuthSendPasswordResetEmail event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final redirectTo = 'myapp://reset-password';
    final res = await _passwordReset(
      PasswordResetParams(email: event.email, redirectTo: redirectTo),
    );

    res.fold(
      (l) {
        _appUserCubit.clearUser();
        emit(AuthPasswordResetFailure(l.message));
      },
      (r) {
        emit(AuthPasswordResetEmailSent());
      },
    );
  }

  Future<void> _onPasswordUpdate(
    AuthCompletePasswordReset event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final res = await _passwordResetComplete(
      PasswordResetCompleteParams(newPassword: event.newPassword),
    );

    res.fold(
      (l) {
        _appUserCubit.clearUser();
        emit(AuthPasswordResetFailure(l.message));
      },
      (_) {
        emit(AuthPasswordResetCompleted());
      },
    );
  }

  Future<void> _onAuthChangePassword(
    AuthChangePassword event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final res = await _changePassword(
      ChangePasswordParams(
        currentPassword: event.currentPassword,
        newPassword: event.newPassword,
      ),
    );

    res.fold(
      (l) => emit(AuthFailure(l.message)),
      (_) => emit(AuthPasswordChanged()),
    );
  }

  Future<void> _onAuthDeleteAccount(
    AuthDeleteAccount event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final res = await _userDelete(UserDeleteParams(id: event.id));

    res.fold(
      (l) {
        _appUserCubit.clearUser();
        emit(AuthFailure(l.message));
      },
      (r) {
        emit(AuthAccountDeleted());
      },
    );
  }

  void _emitAuthSuccess(UserEntity user, Emitter<AuthState> emit) {
    emit(AuthLoading());

    _appUserCubit.updateUser(user);
    _appUserCubit.refreshUser();

    emit(AuthSuccess(user));
  }
}
