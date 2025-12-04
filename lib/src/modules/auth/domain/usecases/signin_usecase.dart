

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class SigninUsecase {
  final AuthRepository authRepository;  
  SigninUsecase(this.authRepository);

  Future<Either<Failure, UserEntity>> call({
    required String email,
    required String password,
  }){
  return authRepository.signIn(email: email, password: password);
  }
}