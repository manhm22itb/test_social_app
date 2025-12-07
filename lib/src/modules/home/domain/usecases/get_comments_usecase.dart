import 'package:injectable/injectable.dart';

import '../entities/comment_entity.dart';
import '../repositories/comment_repository.dart';

@injectable
class GetCommentsUseCase {
  final CommentRepository repository;

  GetCommentsUseCase(this.repository);

  Future<List<CommentEntity>> call(String postId) => repository.getCommentsByPost(postId);
}