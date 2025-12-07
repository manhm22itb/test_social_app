import 'package:injectable/injectable.dart';

import '../entities/comment_entity.dart';
import '../repositories/comment_repository.dart';

@injectable
class UpdateCommentUseCase {
  final CommentRepository repository;

  UpdateCommentUseCase(this.repository);

  Future<CommentEntity> call(String commentId, String content) =>
      repository.updateComment(commentId, content);
}