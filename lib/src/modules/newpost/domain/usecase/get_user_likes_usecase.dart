import 'package:injectable/injectable.dart';

import '../repositories/post_repository.dart';

@injectable
class GetUserLikesUseCase {
  final PostRepository repository;

  GetUserLikesUseCase(this.repository);

  Future<List<String>> call() => repository.getUserLikes();
}