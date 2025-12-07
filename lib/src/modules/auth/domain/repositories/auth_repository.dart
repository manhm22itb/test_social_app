
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> signIn({
    required String email,
    required String password,
  });
  Future<UserEntity> signInWithGoogle();
  Future<Either<Failure, UserEntity>> signUp({
    required String email,
    required String password,
  });
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, void>> resetPassword({ 
    required String email,
  });
  Future<Either<Failure, void>> updatePasswprd({
    required String newPassword
  });

  Future<Either<Failure, UserEntity>> getUserInfo();



}