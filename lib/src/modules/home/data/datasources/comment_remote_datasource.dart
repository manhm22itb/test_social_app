import '../../domain/entities/comment_entity.dart';

abstract class CommentRemoteDataSource {
  Future<List<CommentEntity>> getCommentsByPost(String postId);
  Future<CommentEntity> createComment(String postId, String content, {String? parentId});
  Future<CommentEntity> updateComment(String commentId, String content);
  Future<void> deleteComment(String commentId);
}