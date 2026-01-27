import 'package:dartz/dartz.dart';
import 'package:real_amis/core/errors/failure.dart';
import 'package:real_amis/domain/entities/auth/user_entity.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, UserEntity>> signUpWithEmailPassword({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> logInWithEmailPassword({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> currentUser();

  Future<Either<Failure, UserEntity>> logOut();

  Future<Either<Failure, UserEntity>> passwordReset({
    required String email,
    required String redirectTo,
  });

  Future<Either<Failure, void>> passwordUpdate({required String newPassword});

  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<Either<Failure, UserEntity>> deleteAccount({required String id});
}
