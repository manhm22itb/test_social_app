import 'package:injectable/injectable.dart';

import '../repositories/post_repository.dart';

@injectable
class GetLikeStatusUseCase {
  final PostRepository repository;

  GetLikeStatusUseCase(this.repository);

  Future<bool> call(String postId) => repository.getLikeStatus(postId);
}