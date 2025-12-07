import 'package:injectable/injectable.dart';

import '../entities/user_profile_entity.dart';
import '../repositories/user_profile_repository.dart';

@lazySingleton
class GetUserProfileUseCase {
  final UserProfileRepository _repository;

  GetUserProfileUseCase(this._repository);

  Future<UserProfileEntity> call(String userId) {
    return _repository.getUserProfile(userId);
  }
}
