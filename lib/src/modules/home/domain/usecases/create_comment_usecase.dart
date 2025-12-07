import 'package:injectable/injectable.dart';

import '../entities/comment_entity.dart';
import '../repositories/comment_repository.dart';

@injectable
class CreateCommentUseCase {
  final CommentRepository repository;

  CreateCommentUseCase(this.repository);

  Future<CommentEntity> call(String postId, String content, {String? parentId}) =>
      repository.createComment(postId, content, parentId: parentId);
}