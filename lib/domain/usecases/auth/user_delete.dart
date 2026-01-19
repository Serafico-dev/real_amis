import 'package:dartz/dartz.dart';
import 'package:real_amis/core/errors/failure.dart';
import 'package:real_amis/core/usecase/usecase.dart';
import 'package:real_amis/domain/entities/auth/user_entity.dart';
import 'package:real_amis/domain/repositories/auth/auth_repository.dart';

class UserDelete implements UseCase<UserEntity, UserDeleteParams> {
  final AuthRepository authRepository;
  const UserDelete(this.authRepository);

  @override
  Future<Either<Failure, UserEntity>> call(UserDeleteParams params) async {
    return await authRepository.deleteAccount(id: params.id);
  }
}

class UserDeleteParams {
  final String id;

  UserDeleteParams({required this.id});
}
