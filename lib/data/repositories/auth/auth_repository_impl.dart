import 'package:dartz/dartz.dart';
import 'package:real_amis/core/constants/constants.dart';
import 'package:real_amis/core/errors/exceptions.dart';
import 'package:real_amis/core/errors/failure.dart';
import 'package:real_amis/core/network/connection_checker.dart';
import 'package:real_amis/data/models/auth/user_model.dart';
import 'package:real_amis/data/sources/auth/auth_supabase_data_source.dart';
import 'package:real_amis/domain/entities/auth/user_entity.dart';
import 'package:real_amis/domain/repositories/auth/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthSupabaseDataSource authSupabaseDataSource;
  final ConnectionChecker connectionChecker;
  AuthRepositoryImpl(this.authSupabaseDataSource, this.connectionChecker);

  @override
  Future<Either<Failure, UserEntity>> currentUser() async {
    try {
      if (!await (connectionChecker.isConnected)) {
        final session = authSupabaseDataSource.currentUserSession;

        if (session == null) {
          return left(Failure('User not logged in!'));
        }
        return right(
          UserModel(
            id: session.user.id,
            email: session.user.email ?? '',
            isAdmin: false,
          ),
        );
      }
      final user = await authSupabaseDataSource.getCurrentUserData();
      if (user == null) {
        final session = authSupabaseDataSource.currentUserSession;
        if (session != null) {
          return right(
            UserModel(
              id: session.user.id,
              email: session.user.email ?? '',
              isAdmin: false,
            ),
          );
        }
        return left(Failure('User not logged in!'));
      }

      return right(user);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> logInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    return _getUser(
      () async => await authSupabaseDataSource.logInWithEmailPassword(
        email: email,
        password: password,
      ),
    );
  }

  @override
  Future<Either<Failure, UserEntity>> signUpWithEmailPassword({
    required String email,
    required String password,
  }) async {
    return _getUser(
      () async => await authSupabaseDataSource.signUpWithEmailPassword(
        email: email,
        password: password,
      ),
    );
  }

  Future<Either<Failure, UserEntity>> _getUser(
    Future<UserEntity> Function() fn,
  ) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }
      final user = await fn();
      return right(user);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> logOut() async {
    try {
      await authSupabaseDataSource.logOut();
      return right(UserEntity(id: '', email: '', isAdmin: false));
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> passwordReset({
    required String email,
    required String redirectTo,
  }) async {
    try {
      await authSupabaseDataSource.sendPasswordResetEmail(
        email: email,
        redirectTo: redirectTo,
      );
      return right(UserEntity(id: '', email: '', isAdmin: false));
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> passwordUpdate({
    required String accessToken,
    required String newPassword,
  }) async {
    try {
      await authSupabaseDataSource.updatePasswordWithAccessToken(
        accessToken: accessToken,
        newPassword: newPassword,
      );
      return right(UserEntity(id: '', email: '', isAdmin: false));
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> deleteAccount({
    required String id,
  }) async {
    try {
      await authSupabaseDataSource.deleteAccount(id: id);
      return right(UserEntity(id: '', email: '', isAdmin: false));
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
