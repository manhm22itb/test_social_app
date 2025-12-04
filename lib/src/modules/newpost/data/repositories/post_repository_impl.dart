import 'package:injectable/injectable.dart';

import '../../domain/entities/post_entity.dart';
import '../../domain/repositories/post_repository.dart';
import '../datasources/post_remote_datasource.dart';

@LazySingleton(as: PostRepository)
class PostRepositoryImpl implements PostRepository {
  final PostRemoteDataSource remote;

  PostRepositoryImpl(this.remote);

  @override
  Future<List<PostEntity>> getFeed({int page = 0, int limit = 10}) {
    return remote.getFeed(page: page, limit: limit);
  }

  @override
  Future<PostEntity> createPost(
    String content, {
    String? imageUrl,
    required String visibility,
  }) {
    return remote.createPost(
      content,
      imageUrl: imageUrl,
      visibility: visibility,
    );
  }

  @override
  Future<PostEntity> toggleLike(String postId) {
    return remote.toggleLike(postId);
  }

  @override
  Future<PostEntity> updatePost(
    String postId, {
    required String content,
    String? imageUrl,
  }) {
    return remote.updatePost(
      postId,
      content: content,
      imageUrl: imageUrl,
    );
  }

  @override
  Future<void> deletePost(String postId) {
    return remote.deletePost(postId);
  }

  @override
  Future<bool> getLikeStatus(String postId) {
    return remote.getLikeStatus(postId);
  }

  @override
  Future<Map<String, dynamic>> getDailyLimits() {
    return remote.getDailyLimits();
  }

  @override
  Future<int> getLikeCount(String postId) {
    return remote.getLikeCount(postId);
  }

  @override
  Future<List<String>> getPostLikes(String postId) {
    return remote.getPostLikes(postId);
  }

  @override
  Future<List<String>> getUserLikes() {
    return remote.getUserLikes();
  }
}
