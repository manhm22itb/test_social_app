import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:social_app/src/modules/auth/domain/repositories/auth_repository.dart';

import '../../../../core/error/failures.dart';
@lazySingleton
class ResetPasswordUsecase {
  final AuthRepository authRepository;
  ResetPasswordUsecase(this.authRepository);

  Future<Either<Failure, void>> call({required String email}){
    return authRepository.resetPassword(email: email);
  }
}