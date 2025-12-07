import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_entity.freezed.dart';
part 'post_entity.g.dart';

@freezed
class PostEntity with _$PostEntity {
  const factory PostEntity({
    required String id,
    required String authorId,
    required String authorName,
    String? authorAvatarUrl,
    required String content,
    String? imageUrl,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(0) int likeCount,
    @Default(0) int commentCount,
    @Default(false) bool isLiked,
    required String visibility,
    @Default('original') String type,
    String? originalPostId,
  }) = _PostEntity;

  factory PostEntity.fromJson(Map<String, dynamic> json) =>
      _$PostEntityFromJson(json);
}
