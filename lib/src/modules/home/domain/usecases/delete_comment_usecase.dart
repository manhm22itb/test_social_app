import 'package:injectable/injectable.dart';

import '../repositories/comment_repository.dart';

@injectable
class DeleteCommentUseCase {
  final CommentRepository repository;

  DeleteCommentUseCase(this.repository);

  Future<void> call(String commentId) => repository.deleteComment(commentId);
}