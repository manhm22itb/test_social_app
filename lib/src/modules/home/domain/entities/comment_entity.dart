import 'package:freezed_annotation/freezed_annotation.dart';

part 'comment_entity.freezed.dart';
part 'comment_entity.g.dart';

@freezed
class CommentEntity with _$CommentEntity {
  const factory CommentEntity({
    required String id,
    required String postId,
    required String userId,
    required String content,
    @JsonKey(name: 'username') required String authorName,
    @JsonKey(name: 'avatar_url') String? authorAvatarUrl,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    @JsonKey(name: 'parent_id') String? parentId, // For replies

    @JsonKey(name: 'reply_count') @Default(0) int replyCount,
    @Default(0) int depth,

    @Default([]) List<CommentEntity> replies,
  }) = _CommentEntity;

  factory CommentEntity.fromJson(Map<String, dynamic> json) =>
      _$CommentEntityFromJson(json);
}