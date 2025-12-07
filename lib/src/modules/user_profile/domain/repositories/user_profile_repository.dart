import '../entities/user_profile_entity.dart';

abstract class UserProfileRepository {
  Future<UserProfileEntity> getUserProfile(String userId);
}
