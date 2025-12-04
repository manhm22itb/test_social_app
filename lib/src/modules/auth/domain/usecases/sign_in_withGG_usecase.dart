import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:social_app/src/core/error/failures.dart';
import 'package:social_app/src/modules/auth/domain/entities/user_entity.dart';
import 'package:social_app/src/modules/auth/domain/repositories/auth_repository.dart';
@lazySingleton
class SignInWithggUsecase {
  
  final AuthRepository authRepository;
  SignInWithggUsecase(this.authRepository);

  Future<Either<Failure, UserEntity>> call() async {
    try{
      final user = await authRepository.signInWithGoogle();
      return Right(user);
    }on AuthFailure catch(e){
      return Left(e);
    }
  }
}
