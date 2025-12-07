import 'package:injectable/injectable.dart';

import '../repositories/block_repository.dart';

@injectable
class UnblockUserUseCase {
  final BlockRepository _repository;

  UnblockUserUseCase(this._repository);

  Future<bool> call(String userId) {
    return _repository.unblockUser(userId);
  }
}
