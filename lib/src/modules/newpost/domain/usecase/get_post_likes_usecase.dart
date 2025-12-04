import 'package:injectable/injectable.dart';

import '../repositories/post_repository.dart';

@injectable
class GetPostLikesUseCase {
  final PostRepository repository;

  GetPostLikesUseCase(this.repository);

  Future<List<String>> call(String postId) => repository.getPostLikes(postId);
}