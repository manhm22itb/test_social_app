import 'package:injectable/injectable.dart';

import '../entities/post_entity.dart';
import '../repositories/post_repository.dart';

@injectable
class SharePostUseCase {
  final PostRepository _repository;

  SharePostUseCase(this._repository);

  Future<PostEntity> call(
    String postId, {
    required String visibility,
    String? content,
  }) {
    return _repository.sharePost(
      postId,
      visibility: visibility,
      content: content,
    );
  }
}
