import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:social_app/src/modules/auth/domain/entities/user_entity.dart';
import 'package:social_app/src/modules/auth/domain/repositories/auth_repository.dart';

import '../../../../core/error/failures.dart';

@lazySingleton
class SignupUsecase {
  final AuthRepository authRepository;
  SignupUsecase(this.authRepository);

  Future<Either<Failure, UserEntity>> call({
    required String email, required String password 
  }){
    return authRepository.signUp(email: email, password: password);
  }
}