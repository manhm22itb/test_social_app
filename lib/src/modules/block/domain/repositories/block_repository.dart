// lib/src/modules/block/domain/repositories/block_repository.dart
import '../entities/blocked_user_entity.dart';

abstract class BlockRepository {
  Future<bool> blockUser(String userId);
  Future<bool> unblockUser(String userId);
  Future<bool> isBlocked(String userId);
  Future<List<BlockedUserEntity>> getBlockList();
  Future<List<BlockedUserEntity>> getBlockedUsers();
}
