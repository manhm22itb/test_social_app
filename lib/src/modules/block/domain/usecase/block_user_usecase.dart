// lib/src/modules/block/domain/usecase/block_user_usecase.dart
import 'package:injectable/injectable.dart';
import '../repositories/block_repository.dart';

@injectable
class BlockUserUseCase {
  final BlockRepository _repo;

  BlockUserUseCase(this._repo);

  Future<bool> call(String userId) => _repo.blockUser(userId);
}
