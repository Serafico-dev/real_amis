import 'package:dartz/dartz.dart';
import 'package:real_amis/core/errors/failure.dart';
import 'package:real_amis/core/usecase/usecase.dart';
import 'package:real_amis/domain/entities/auth/user_entity.dart';
import 'package:real_amis/domain/repositories/auth/auth_repository.dart';

class PasswordResetComplete
    implements UseCase<UserEntity, PasswordResetCompleteParams> {
  final AuthRepository authRepository;
  const PasswordResetComplete(this.authRepository);

  @override
  Future<Either<Failure, UserEntity>> call(
    PasswordResetCompleteParams params,
  ) async {
    return await authRepository.passwordUpdate(
      accessToken: params.accessToken,
      newPassword: params.newPassword,
    );
  }
}

class PasswordResetCompleteParams {
  final String accessToken;
  final String newPassword;

  PasswordResetCompleteParams({
    required this.accessToken,
    required this.newPassword,
  });
}
