import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/comment_entity.dart';

part 'comment_model.freezed.dart';
part 'comment_model.g.dart';

@freezed
class CommentModel with _$CommentModel {
  const CommentModel._();

  const factory CommentModel({
    required String id,
    @JsonKey(name: 'post_id') required String postId,
    @JsonKey(name: 'user_id') required String userId,
    required String content,
    required String? username,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
    @JsonKey(name: 'parent_id') String? parentId,
    @JsonKey(name: 'reply_count') @Default(0) int replyCount,
    @Default(0) int depth,

    @Default([]) List<CommentModel> replies,
  }) = _CommentModel;

  factory CommentModel.fromJson(Map<String, dynamic> json) =>
      _$CommentModelFromJson(json);

  CommentEntity toEntity() {
    return CommentEntity(
      id: id,
      postId: postId,
      userId: userId,
      content: content,
      authorName: username ?? 'Unknown',
      authorAvatarUrl: avatarUrl,
      createdAt: DateTime.parse(createdAt),
      updatedAt: updatedAt != null ? DateTime.parse(updatedAt!) : null,
      parentId: parentId,
      replyCount: replyCount,
      depth: depth,
      replies: replies.map((reply) => reply.toEntity()).toList(),
    );
  }
}