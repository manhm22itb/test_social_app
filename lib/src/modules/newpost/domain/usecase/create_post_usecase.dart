import 'package:injectable/injectable.dart';

import '../entities/post_entity.dart';
import '../repositories/post_repository.dart';

@injectable
class CreatePostUseCase {
  final PostRepository repository;

  CreatePostUseCase(this.repository);

  /// visibility : 'public' | 'private' | 'friends_only'
  /// nếu quên truyền => 'public'
  Future<PostEntity> call(
    String content, {
    String? imageUrl,
    String visibility = 'public',
  }) {
    // Nếu ở đâu đó vẫn lỡ dùng 'friends' thì convert về 'friends_only'
    final normalizedVisibility =
        visibility == 'friends' ? 'friends_only' : visibility;

    return repository.createPost(
      content,
      imageUrl: imageUrl,
      visibility: normalizedVisibility,
    );
  }
}
