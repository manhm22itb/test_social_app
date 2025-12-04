// lib/src/modules/newpost/domain/usecase/update_post_usecase.dart
import 'package:injectable/injectable.dart';

import '../entities/post_entity.dart';
import '../repositories/post_repository.dart';

@injectable // 👈 cũng phải có để GetIt đăng ký
class UpdatePostUseCase {
  final PostRepository repository;

  UpdatePostUseCase(this.repository);

  Future<PostEntity> call(
    String postId, {
    required String content,
    String? imageUrl,
  }) {
    return repository.updatePost(
      postId,
      content: content,
      imageUrl: imageUrl,
    );
  }

  Future<void> delete(String postId) {
    return repository.deletePost(postId);
  }
}
