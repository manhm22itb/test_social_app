import '../entities/profile.dart';

abstract class ProfileRepository {
  Future<Profile> getMyProfile(String token);
  Future<Profile> updateMyProfile({
    required String token,
    String? username,
    String? bio,
    String? avatarUrl,
  });
}
