import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_amis/common/cubits/app_user/app_user_cubit.dart';
import 'package:real_amis/core/usecase/usecase.dart';
import 'package:real_amis/domain/entities/auth/user_entity.dart';
import 'package:real_amis/domain/usecases/auth/current_user.dart';
import 'package:real_amis/domain/usecases/auth/password_reset.dart';
import 'package:real_amis/domain/usecases/auth/password_reset_complete.dart';
import 'package:real_amis/domain/usecases/auth/user_login.dart';
import 'package:real_amis/domain/usecases/auth/user_logout.dart';
import 'package:real_amis/domain/usecases/auth/user_sign_up.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserSignUp _userSignUp;
  final UserLogin _userLogin;
  final CurrentUser _currentUser;
  final UserLogout _userLogout;
  final PasswordReset _passwordReset;
  final PasswordResetComplete _passwordResetComplete;
  final AppUserCubit _appUserCubit;

  AuthBloc({
    required UserSignUp userSignUp,
    required UserLogin userLogin,
    required CurrentUser currentUser,
    required UserLogout userLogout,
    required PasswordReset passwordReset,
    required PasswordResetComplete passwordResetComplete,
    required AppUserCubit appUserCubit,
  }) : _userSignUp = userSignUp,
       _userLogin = userLogin,
       _currentUser = currentUser,
       _userLogout = userLogout,
       _passwordReset = passwordReset,
       _passwordResetComplete = passwordResetComplete,
       _appUserCubit = appUserCubit,
       super(AuthInitial()) {
    on<AuthSignUp>(_onAuthSignUp);
    on<AuthLogin>(_onAuthLogin);
    on<AuthIsUserLoggedIn>(_onIsUserLoggedIn);
    on<AuthLogout>(_onAuthLogout);
    on<AuthSendPasswordResetEmail>(_onPasswordReset);
    on<AuthCompletePasswordReset>(_onPasswordUpdate);
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

  Future<void> _onIsUserLoggedIn(
    AuthIsUserLoggedIn event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final res = await _currentUser(NoParams());

    res.fold((l) {
      _appUserCubit.clearUser();
      emit(AuthFailure(l.message));
    }, (r) => _emitAuthChecked(r, emit));
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
      PasswordResetCompleteParams(
        accessToken: event.accessToken,
        newPassword: event.newPassword,
      ),
    );

    res.fold(
      (l) {
        _appUserCubit.clearUser();
        emit(AuthPasswordResetFailure(l.message));
      },
      (r) {
        emit(AuthPasswordResetCompleted());
      },
    );
  }

  void _emitAuthSuccess(UserEntity user, Emitter<AuthState> emit) {
    emit(AuthLoading());

    _appUserCubit.updateUser(user);
    emit(AuthSuccess(user));
  }

  void _emitAuthChecked(UserEntity user, Emitter<AuthState> emit) {
    emit(AuthLoading());

    _appUserCubit.updateUser(user);
    emit(AuthChecked(user));
  }
}
