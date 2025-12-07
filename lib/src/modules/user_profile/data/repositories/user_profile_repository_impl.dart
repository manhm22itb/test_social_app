import 'package:injectable/injectable.dart';

import '../../domain/entities/user_profile_entity.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../datasources/user_profile_api.dart';
import '../models/user_profile_model.dart';

@LazySingleton(as: UserProfileRepository)
class UserProfileRepositoryImpl implements UserProfileRepository {
  final UserProfileApi api;

  UserProfileRepositoryImpl(this.api);

  @override
  Future<UserProfileEntity> getUserProfile(String userId) async {
    final UserProfileModel model = await api.getUserProfile(userId);

    return UserProfileEntity(
      id: model.id,
      username: model.username,
      email: model.email,
      avatarUrl: model.avatarUrl,
      bio: model.bio,
      followerCount: model.followerCount,
      followingCount: model.followingCount,
      postCount: model.postCount,
      isMe: model.isMe,
      isFollowing: model.isFollowing,
      createdAt:
          model.createdAt != null ? DateTime.tryParse(model.createdAt!) : null,
    );
  }
}
