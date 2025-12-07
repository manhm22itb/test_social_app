import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/profile.dart';

part 'profile_model.freezed.dart';
part 'profile_model.g.dart';

@freezed
class ProfileModel with _$ProfileModel {
  const factory ProfileModel({
    required String id,
    required String username,
    String? email,
    String? bio,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'follower_count') int? followerCount,
    @JsonKey(name: 'following_count') int? followingCount,
    @JsonKey(name: 'post_count') int? postCount,
    @JsonKey(name: 'is_me') bool? isMe,
    @JsonKey(name: 'is_following') bool? isFollowing,
  }) = _ProfileModel;

  factory ProfileModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileModelFromJson(json);
}

/// 👇 Chính extension này tạo ra hàm toEntity()
extension ProfileModelX on ProfileModel {
  Profile toEntity() {
    return Profile(
      id: id,
      username: username,
      email: email,
      bio: bio,
      avatarUrl: avatarUrl,
      followerCount: followerCount,
      followingCount: followingCount,
      postCount: postCount,
      isMe: isMe,
      isFollowing: isFollowing,
    );
  }
}
