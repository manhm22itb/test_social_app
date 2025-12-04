// lib/src/modules/newpost/domain/usecase/delete_post_usecase.dart

import 'package:injectable/injectable.dart';

import '../repositories/post_repository.dart';

@injectable
class DeletePostUseCase {
  final PostRepository repository;

  DeletePostUseCase(this.repository);

  Future<void> call(String postId) async {
    return repository.deletePost(postId);
  }
}
