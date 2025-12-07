import 'package:injectable/injectable.dart';

import '../../domain/entities/post_entity.dart';
import '../../domain/repositories/post_repository.dart';
import '../datasources/post_remote_datasource.dart';

@LazySingleton(as: PostRepository)
class PostRepositoryImpl implements PostRepository {
  final PostRemoteDataSource _remote;

  PostRepositoryImpl(this._remote);

  @override
  Future<List<PostEntity>> getFeed({int page = 0, int limit = 20}) {
    // hiện tại remote đã hỗ trợ page/limit, bạn có thể dùng hoặc bỏ qua
    return _remote.getFeed(page: page, limit: limit);
  }

  @override
  Future<PostEntity> createPost(
    String content, {
    String? imageUrl,
    String visibility = 'public',
  }) {
    return _remote.createPost(
      content,
      imageUrl: imageUrl,
      visibility: visibility,
    );
  }

  @override
  Future<PostEntity> toggleLike(String postId) {
    return _remote.toggleLike(postId);
  }

  @override
  Future<PostEntity> updatePost(
    String postId, {
    String? content,
    String? imageUrl,
  }) {
    return _remote.updatePost(
      postId,
      content: content,
      imageUrl: imageUrl,
    );
  }

  @override
  Future<void> deletePost(String postId) {
    return _remote.deletePost(postId);
  }

  @override
  Future<PostEntity> sharePost(
    String postId, {
    required String visibility,
    String? content,
  }) {
    return _remote.sharePost(
      postId,
      visibility: visibility,
      content: content,
    );
  }
  
  @override
  Future<Map<String, dynamic>> getDailyLimits() {
    return _remote.getDailyLimits();
  }
  
  @override
  Future<int> getLikeCount(String postId) {
    // TODO: implement getLikeCount
    throw UnimplementedError();
  }
  
  @override
  Future<bool> getLikeStatus(String postId) {
    // TODO: implement getLikeStatus
    throw UnimplementedError();
  }
  
  @override
  Future<List<String>> getPostLikes(String postId) {
    // TODO: implement getPostLikes
    throw UnimplementedError();
  }
  
  @override
  Future<List<String>> getUserLikes() {
    // TODO: implement getUserLikes
    throw UnimplementedError();
  }
}
