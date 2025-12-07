import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/post_entity.dart';

part 'post_model.freezed.dart';
part 'post_model.g.dart';

@freezed
class PostModel with _$PostModel {
  const PostModel._(); // để dùng toEntity()

  const factory PostModel({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required String content,
    @JsonKey(name: 'image_url') String? imageUrl,
    required String visibility,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'updated_at') required String updatedAt,
    required String? username,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'like_count') @Default(0) int likeCount,
    @JsonKey(name: 'comment_count') @Default(0) int commentCount,
    @JsonKey(name: 'is_liked') @Default(false) bool isLiked,

    /// 🔥 thêm 2 field để hỗ trợ share
    @JsonKey(name: 'type') @Default('original') String type,
    @JsonKey(name: 'original_post_id') String? originalPostId,
  }) = _PostModel;

  factory PostModel.fromJson(Map<String, dynamic> json) =>
      _$PostModelFromJson(json);

  PostEntity toEntity() {
    return PostEntity(
      id: id,
      authorId: userId,
      authorName: username ?? 'Unknown',
      authorAvatarUrl: avatarUrl,
      imageUrl: imageUrl,
      content: content,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
      likeCount: likeCount,
      commentCount: commentCount,
      isLiked: isLiked,
      visibility: visibility,
      type: type, // 👈 map xuống entity
      originalPostId: originalPostId, // 👈 map xuống entity
    );
  }
}
