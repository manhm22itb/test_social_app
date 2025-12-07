import 'package:injectable/injectable.dart';

import '../../domain/entities/comment_entity.dart';
import '../../domain/repositories/comment_repository.dart';
import '../datasources/comment_remote_datasource.dart';

@LazySingleton(as: CommentRepository)
class CommentRepositoryImpl implements CommentRepository {
  final CommentRemoteDataSource remote;

  CommentRepositoryImpl(this.remote);

  @override
  Future<List<CommentEntity>> getCommentsByPost(String postId) {
    return remote.getCommentsByPost(postId);
  }

  @override
  Future<CommentEntity> createComment(String postId, String content, {String? parentId}) {
    return remote.createComment(postId, content, parentId: parentId);
  }

  @override
  Future<CommentEntity> updateComment(String commentId, String content) {
    return remote.updateComment(commentId, content);
  }

  @override
  Future<void> deleteComment(String commentId) {
    return remote.deleteComment(commentId);
  }
}