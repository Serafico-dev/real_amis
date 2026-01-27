import 'package:dartz/dartz.dart';
import 'package:real_amis/core/errors/failure.dart';
import 'package:real_amis/core/usecase/usecase.dart';
import 'package:real_amis/domain/repositories/auth/auth_repository.dart';

class PasswordResetComplete
    implements UseCase<void, PasswordResetCompleteParams> {
  final AuthRepository authRepository;

  const PasswordResetComplete(this.authRepository);

  @override
  Future<Either<Failure, void>> call(PasswordResetCompleteParams params) async {
    return await authRepository.passwordUpdate(newPassword: params.newPassword);
  }
}

class PasswordResetCompleteParams {
  final String newPassword;

  PasswordResetCompleteParams({required this.newPassword});
}
