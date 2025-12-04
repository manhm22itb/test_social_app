import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile.freezed.dart';

@freezed
class Profile with _$Profile {
  const factory Profile({
    required String id,
    required String username,
    String? email,
    String? bio,
    String? avatarUrl,
    int? followerCount,
    int? followingCount,
    int? postCount,
    bool? isMe,
    bool? isFollowing,
  }) = _Profile;
}
