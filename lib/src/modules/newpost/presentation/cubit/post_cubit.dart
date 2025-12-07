// lib/src/modules/newpost/presentation/cubit/post_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:social_app/src/modules/newpost/domain/usecase/share_post_usecase.dart';

import '../../domain/entities/post_entity.dart';
import '../../domain/usecase/create_post_usecase.dart';
import '../../domain/usecase/delete_post_usecase.dart';
import '../../domain/usecase/get_daily_limits_usecase.dart';
import '../../domain/usecase/get_feed_usecase.dart';
import '../../domain/usecase/get_like_count_usecase.dart';
import '../../domain/usecase/get_like_status_usecase.dart';
import '../../domain/usecase/get_post_likes_usecase.dart';
import '../../domain/usecase/get_user_likes_usecase.dart';
import '../../domain/usecase/toggle_like_usecase.dart';
import '../../domain/usecase/update_post_usecase.dart';

part 'post_state.dart';

@injectable
class PostCubit extends Cubit<PostState> {
  final GetFeedUseCase _getFeedUseCase;
  final CreatePostUseCase _createPostUseCase;
  final ToggleLikeUseCase _toggleLikeUseCase;
  final UpdatePostUseCase _updatePostUseCase;
  final DeletePostUseCase _deletePostUseCase;
  final GetLikeStatusUseCase _getLikeStatusUseCase;
  final GetDailyLimitsUseCase _getDailyLimitsUseCase;
  final GetLikeCountUseCase _getLikeCountUseCase;
  final GetPostLikesUseCase _getPostLikesUseCase;
  final SharePostUseCase _sharePostUseCase;
  final GetUserLikesUseCase _getUserLikesUseCase;

  PostCubit(
    this._getFeedUseCase,
    this._createPostUseCase,
    this._toggleLikeUseCase,
    this._updatePostUseCase,
    this._deletePostUseCase,
    this._getLikeStatusUseCase,
    this._getDailyLimitsUseCase,
    this._getLikeCountUseCase,
    this._getPostLikesUseCase,
    this._getUserLikesUseCase,
    this._sharePostUseCase,
  ) : super(const PostStateInitial());

  /// load danh sách bài viết
  Future<void> loadFeed() async {
    if (isClosed) { 
      print('⚠️ PostCubit is closed, cannot load feed');
      return;
    }
    
    emit(const PostStateLoading());
    
    try {
      final posts = await _getFeedUseCase();
      
      if (isClosed) return; 
      
      emit(PostStateLoaded(posts: posts));
    } catch (e) {
      if (isClosed) return; 
      
      emit(PostStateError(message: e.toString()));
    }
  }

  /// tạo post mới (có thể kèm imageUrl)
  Future<bool> createPost(String content, {String? imageUrl}) async {
    final current = state;
    try {
      final PostEntity newPost =
          await _createPostUseCase(content, imageUrl: imageUrl);

      if (isClosed) return false;

      if (current is PostStateLoaded) {
        emit(PostStateLoaded(posts: [newPost, ...current.posts]));
      } else {
        emit(PostStateLoaded(posts: [newPost]));
      }
      return true;
    } catch (e) {
      if (isClosed) return false;
      emit(PostStateError(message: e.toString()));
      return false;
    }
  }

  /// cập nhật post (text + image)
  Future<bool> editPost(
    String postId, {
    required String content,
    String? imageUrl,
  }) async {
    final current = state;
    try {
      final PostEntity updated = await _updatePostUseCase(
        postId,
        content: content,
        imageUrl: imageUrl,
      );

      if (current is PostStateLoaded) {
        final updatedList =
            current.posts.map((p) => p.id == updated.id ? updated : p).toList();
        emit(PostStateLoaded(posts: updatedList));
      } else {
        emit(PostStateLoaded(posts: [updated]));
      }
      return true;
    } catch (e) {
      emit(PostStateError(message: e.toString()));
      return false;
    }
  }

  /// helper: chỉ chỉnh text (nếu chỗ nào cũ còn gọi)
  Future<bool> editPostContent(String postId, String content) {
    return editPost(postId, content: content);
  }

  /// xoá post
  Future<bool> deletePost(String postId) async {
    final current = state;
    try {
      await _deletePostUseCase(postId);

      if (current is PostStateLoaded) {
        final updatedList = current.posts.where((p) => p.id != postId).toList();
        emit(PostStateLoaded(posts: updatedList));
      }
      return true;
    } catch (e) {
      emit(PostStateError(message: e.toString()));
      return false;
    }
  }

  /// toggle like 1 post
  Future<void> toggleLike(String postId) async {
    final current = state;
    if (current is! PostStateLoaded) return;

    final post = current.posts.firstWhere((p) => p.id == postId);

    // Nếu hành động là LIKE (không phải Unlike)
    final bool isTryingToLike = !post.isLiked;

    // Kiểm tra giới hạn like
    if (isTryingToLike) {
      final allowed = await _canLike();
      if (!allowed) {
        emit(PostStateLikeLimitReached());
        return;
      }
    }

    final updatedLocalPost = post.copyWith(
      isLiked: !post.isLiked,
      likeCount: post.isLiked 
          ? post.likeCount - 1 
          : post.likeCount + 1,
    );

    final newList = current.posts.map((p) {
      return p.id == postId ? updatedLocalPost : p;
    }).toList();

    if (isTryingToLike && !await _canLike()) {
      emit(PostStateLikeLimitReached());
      return;
    }


    // Gọi backend
    try {
      await _toggleLikeUseCase(postId);
    } catch (e) {
      print("toggle like API error: $e");
    }
  }

  /// share 1 post với visibility (public/private) + content kèm theo
  Future<bool> sharePost(
    String postId, {
    required String visibility,
    String? content,
  }) async {
    final current = state;
    try {
      final PostEntity sharedPost = await _sharePostUseCase(
        postId,
        visibility: visibility,
        content: content,
      );

      if (isClosed) return false;

      if (current is PostStateLoaded) {
        emit(PostStateLoaded(posts: [sharedPost, ...current.posts]));
      } else {
        emit(PostStateLoaded(posts: [sharedPost]));
      }

      return true;
    } catch (e) {
      if (isClosed) return false;
      emit(PostStateError(message: e.toString()));
      return false;
    }
  }

  Future<bool> _canLike() async {
    try {
      final limits = await _getDailyLimitsUseCase(); 
      final used = limits['likesUsed'] ?? 0;
      final limit = limits['likeLimit'] ?? 5;

      return used < limit;
    } catch (e) {
      print('Error checking like limit $e');
      return true; // an toàn: vẫn cho like nếu backend gặp lỗi
    }
  }


  Future<Map<String, dynamic>> getDailyLimits() async {
    try {
      return await _getDailyLimitsUseCase();
    } catch (e) {
      print('>>> [Cubit] getDailyLimits error: $e');
      rethrow;
    }
  }

  Future<int> getLikeCount(String postId) async {
    try {
      return await _getLikeCountUseCase(postId);
    } catch (e) {
      print('>>> [Cubit] getLikeCount error: $e');
      rethrow;
    }
  }

  Future<List<String>> getPostLikes(String postId) async {
    try {
      return await _getPostLikesUseCase(postId);
    } catch (e) {
      print('>>> [Cubit] getPostLikes error: $e');
      rethrow;
    }
  }

  Future<List<String>> getUserLikes() async {
    try {
      return await _getUserLikesUseCase();
    } catch (e) {
      print('>>> [Cubit] getUserLikes error: $e');
      rethrow;
    }
  }

}
