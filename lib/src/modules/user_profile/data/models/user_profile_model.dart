import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/user_profile_entity.dart';

part 'user_profile_model.freezed.dart';
part 'user_profile_model.g.dart';

@freezed
class UserProfileModel with _$UserProfileModel {
  const factory UserProfileModel({
    required String id,
    required String username,
    required String email,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    String? bio,
    @JsonKey(name: 'follower_count') required int followerCount,
    @JsonKey(name: 'following_count') required int followingCount,
    @JsonKey(name: 'post_count') required int postCount,
    @JsonKey(name: 'is_me') required bool isMe,
    @JsonKey(name: 'is_following') bool? isFollowing,
    @JsonKey(name: 'created_at') String? createdAt,
  }) = _UserProfileModel;

  factory UserProfileModel.fromJson(Map<String, dynamic> json) =>
      _$UserProfileModelFromJson(json);
}

extension UserProfileModelX on UserProfileModel {
  UserProfileEntity toEntity() {
    return UserProfileEntity(
      id: id,
      username: username,
      email: email,
      avatarUrl: avatarUrl,
      bio: bio,
      followerCount: followerCount,
      followingCount: followingCount,
      postCount: postCount,
      isMe: isMe,
      isFollowing: isFollowing,
      createdAt: createdAt != null ? DateTime.tryParse(createdAt!) : null,
    );
  }
}
