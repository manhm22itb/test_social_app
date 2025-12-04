import 'package:injectable/injectable.dart';

import '../entities/post_entity.dart';
import '../repositories/post_repository.dart';

@injectable
class ToggleLikeUseCase {
  final PostRepository repository;

  ToggleLikeUseCase(this.repository);

  Future<PostEntity> call(String postId) => repository.toggleLike(postId);
}
