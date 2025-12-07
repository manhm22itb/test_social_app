// lib/src/modules/block/data/datasources/block_remote_datasource.dart
import '../models/blocked_user_model.dart';

abstract class BlockRemoteDataSource {
  Future<void> blockUser(String userId);
  Future<void> unblockUser(String userId);
  Future<bool> isBlocked(String userId);

  Future<List<BlockedUserModel>> getBlockedUsers();
}
