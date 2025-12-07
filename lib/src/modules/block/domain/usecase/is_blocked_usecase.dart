// lib/src/modules/block/domain/usecase/is_blocked_usecase.dart
import 'package:injectable/injectable.dart';
import '../repositories/block_repository.dart';

@injectable
class IsBlockedUseCase {
  final BlockRepository _repo;

  IsBlockedUseCase(this._repo);

  Future<bool> call(String userId) => _repo.isBlocked(userId);
}
