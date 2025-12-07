import 'package:injectable/injectable.dart';

import '../repositories/post_repository.dart';

@injectable
class GetLikeCountUseCase {
  final PostRepository repository;

  GetLikeCountUseCase(this.repository);

  Future<int> call(String postId) => repository.getLikeCount(postId);
}