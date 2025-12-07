import 'package:injectable/injectable.dart';

import '../entities/blocked_user_entity.dart';
import '../repositories/block_repository.dart';

@injectable
class GetBlockedUsersUseCase {
  final BlockRepository _repository;

  GetBlockedUsersUseCase(this._repository);

  Future<List<BlockedUserEntity>> call() {
    return _repository.getBlockList();
  }
}
