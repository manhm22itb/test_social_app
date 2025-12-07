import 'package:injectable/injectable.dart';

import '../entities/profile.dart';
import '../repositories/profile_repository.dart';

@injectable
class GetMyProfileUseCase {
  final ProfileRepository repository;

  GetMyProfileUseCase(this.repository);

  Future<Profile> call(String token) {
    return repository.getMyProfile(token);
  }
}
