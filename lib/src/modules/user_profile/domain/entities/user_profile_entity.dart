import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile_entity.freezed.dart';
part 'user_profile_entity.g.dart';

@freezed
class UserProfileEntity with _$UserProfileEntity {
  const factory UserProfileEntity({
    required String id,
    required String username,
    required String email,
    String? avatarUrl,
    String? bio,
    required int followerCount,
    required int followingCount,
    required int postCount,
    required bool isMe,
    bool? isFollowing,
    DateTime? createdAt,
  }) = _UserProfileEntity;

  factory UserProfileEntity.fromJson(Map<String, dynamic> json) =>
      _$UserProfileEntityFromJson(json);
}
