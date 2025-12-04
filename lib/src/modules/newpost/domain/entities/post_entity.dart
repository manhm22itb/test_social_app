import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_entity.freezed.dart';
part 'post_entity.g.dart';

@freezed
class PostEntity with _$PostEntity {
  const factory PostEntity({
    /// id bài post
    required String id,

    /// user_id từ backend -> tác giả bài viết
    @JsonKey(name: 'user_id') required String authorId,

    /// nội dung
    required String content,

    /// có thể null nếu không có ảnh
    @JsonKey(name: 'image_url') String? imageUrl,

    /// 'public' | 'private' | 'friends_only'
    @Default('public') String visibility,

    /// username từ backend
    @JsonKey(name: 'username') required String authorName,

    /// avatar của tác giả (có thể null)
    @JsonKey(name: 'avatar_url') String? authorAvatarUrl,
    @JsonKey(name: 'like_count') @Default(0) int likeCount,
    @JsonKey(name: 'comment_count') @Default(0) int commentCount,
    @JsonKey(name: 'is_liked') @Default(false) bool isLiked,

    /// backend trả ISO string, json_serializable tự parse sang DateTime
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _PostEntity;

  factory PostEntity.fromJson(Map<String, dynamic> json) =>
      _$PostEntityFromJson(json);
}
