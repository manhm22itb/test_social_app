import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:social_app/src/modules/auth/domain/entities/user_entity.dart';
import 'package:social_app/src/modules/auth/domain/repositories/auth_repository.dart';

import '../../../../core/error/failures.dart';

@lazySingleton
class GetUserUsecase{
  final AuthRepository authRepository;
  GetUserUsecase(this.authRepository);

  Future<Either<Failure, UserEntity>> call() async {
    return authRepository.getUserInfo();
  }
}