import 'package:injectable/injectable.dart';

import '../entities/post_entity.dart';
import '../repositories/post_repository.dart';

@injectable
class GetFeedUseCase {
  final PostRepository repo;

  GetFeedUseCase(this.repo);

  Future<List<PostEntity>> call({int page = 0, int limit = 20}) {
    return repo.getFeed(page: page, limit: limit);
  }
}
