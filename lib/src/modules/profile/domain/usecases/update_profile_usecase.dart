import 'package:injectable/injectable.dart';

import '../entities/profile.dart';
import '../repositories/profile_repository.dart';

@injectable
class UpdateProfileUseCase {
  final ProfileRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<Profile> call({
    required String token,
    String? username,
    String? bio,
    String? avatarUrl,
  }) {
    return repository.updateMyProfile(
      token: token,
      username: username,
      bio: bio,
      avatarUrl: avatarUrl,
    );
  }
}
