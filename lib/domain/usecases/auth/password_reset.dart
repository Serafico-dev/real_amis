import 'package:dartz/dartz.dart';
import 'package:real_amis/core/errors/failure.dart';
import 'package:real_amis/core/usecase/usecase.dart';
import 'package:real_amis/domain/entities/auth/user_entity.dart';
import 'package:real_amis/domain/repositories/auth/auth_repository.dart';

class PasswordReset implements UseCase<UserEntity, PasswordResetParams> {
  final AuthRepository authRepository;
  const PasswordReset(this.authRepository);

  @override
  Future<Either<Failure, UserEntity>> call(PasswordResetParams params) async {
    return await authRepository.passwordReset(
      email: params.email,
      redirectTo: params.redirectTo,
    );
  }
}

class PasswordResetParams {
  final String email;
  final String redirectTo;

  PasswordResetParams({required this.email, required this.redirectTo});
}
