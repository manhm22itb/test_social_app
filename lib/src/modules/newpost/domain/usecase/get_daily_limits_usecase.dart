import 'package:injectable/injectable.dart';

import '../repositories/post_repository.dart';

@injectable
class GetDailyLimitsUseCase {
  final PostRepository repository;

  GetDailyLimitsUseCase(this.repository);

  Future<Map<String, dynamic>> call() => repository.getDailyLimits();
}