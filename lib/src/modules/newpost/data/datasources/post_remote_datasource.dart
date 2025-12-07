import '../../domain/entities/post_entity.dart';

abstract class PostRemoteDataSource {
  Future<List<PostEntity>> getFeed({int page = 0, int limit = 20});

  Future<PostEntity> createPost(
    String content, {
    String? imageUrl,
    required String visibility,
  });

  Future<PostEntity> toggleLike(String postId);

  Future<PostEntity> updatePost(
    String postId, {
    String? content,
    String? imageUrl,
  });

  Future<void> deletePost(String postId);

  Future<bool> getLikeStatus(String postId);

  Future<Map<String, dynamic>> getDailyLimits();

  Future<int> getLikeCount(String postId);

  Future<List<String>> getPostLikes(String postId);

  Future<List<String>> getUserLikes();


  Future<PostEntity> sharePost(
    String postId, {
    required String visibility,
    String? content,
  });
}
