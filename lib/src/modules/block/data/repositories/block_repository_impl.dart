// lib/src/modules/block/data/repositories/block_repository_impl.dart
import '../../domain/entities/blocked_user_entity.dart';
import '../../domain/repositories/block_repository.dart';
import '../datasources/block_remote_datasource.dart';
import '../models/blocked_user_model.dart';
import 'package:injectable/injectable.dart';



@LazySingleton(as: BlockRepository) 
class BlockRepositoryImpl implements BlockRepository {
  final BlockRemoteDataSource _remote;

  BlockRepositoryImpl(this._remote);

  @override
  Future<bool> blockUser(String userId) async {
    await _remote.blockUser(userId);
    return true;
  }

  @override
  Future<bool> unblockUser(String userId) async {
    await _remote.unblockUser(userId);
    return true;
  }

  @override
  Future<bool> isBlocked(String userId) {
    return _remote.isBlocked(userId);
  }

  /// alias cho getBlockedUsers nếu bạn vẫn giữ cả 2 hàm trong interface
  @override
  Future<List<BlockedUserEntity>> getBlockList() {
    return getBlockedUsers();
  }

  @override
  Future<List<BlockedUserEntity>> getBlockedUsers() async {
    final List<BlockedUserModel> models = await _remote.getBlockedUsers();
    return models.map((m) => m.toEntity()).toList();
  }
}
