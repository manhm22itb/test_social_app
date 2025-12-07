import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/comment_entity.dart';
import '../../../../core/error/failures.dart';
import '../models/comment_model.dart';
import 'comment_remote_datasource.dart';

@LazySingleton(as: CommentRemoteDataSource)
class CommentRemoteDataSourceImpl implements CommentRemoteDataSource {
  final Dio _dio;
  final SupabaseClient _supabase;

  CommentRemoteDataSourceImpl(this._dio, this._supabase);

  Map<String, String> _authHeaders() {
    final token = _supabase.auth.currentSession?.accessToken;
    if (token == null) throw Exception('Not authenticated');
    return {
      'Authorization': 'Bearer $token',
      'accept': 'application/json',
      'content-type': 'application/json',
    };
  }

  @override
  Future<List<CommentEntity>> getCommentsByPost(String postId) async {
    try {
      final response = await _dio.get(
        '/comments/posts/$postId',
        options: Options(headers: _authHeaders()),
      );

      print('>>> [CommentDS] API Response for post $postId: ${response.data}');

      List<dynamic> items = [];

      if (response.data is List) {
        items = response.data as List<dynamic>;
      } else if (response.data is Map) {
        final dataMap = response.data as Map<String, dynamic>;
        if (dataMap['comments'] is List) {
          items = dataMap['comments'] as List<dynamic>;
        } else if (dataMap['data'] is List) {
          items = dataMap['data'] as List<dynamic>;
        } else {
          for (final key in dataMap.keys) {
            if (dataMap[key] is List) {
              items = dataMap[key] as List<dynamic>;
              break;
            }
          }
        }
      }

      print('>>> [CommentDS] Found ${items.length} items');

      final List<CommentEntity> comments = [];
      for (int i = 0; i < items.length; i++) {
        try {
          final item = items[i];
          if (item is Map<String, dynamic>) {
            // 🔥 PARSE COMMENT VỚI REPLIES
            final comment = _parseCommentWithReplies(item);
            comments.add(comment);
          } else {
            print('>>> [CommentDS] Item $i is not a Map: $item');
          }
        } catch (e, stack) {
          print('>>> [CommentDS] Error parsing item $i: $e');
          print('>>> [CommentDS] Item data: ${items[i]}');
          print('>>> [CommentDS] Stack: $stack');
        }
      }

      print('>>> [CommentDS] Successfully parsed ${comments.length} comments');
      return comments;
      
    } on DioException catch (e) {
      print('>>> [CommentDS] DioException: ${e.message}');
      print('>>> [CommentDS] DioException response: ${e.response?.data}');
      print('>>> [CommentDS] DioException type: ${e.type}');
      throw Exception('Failed to load comments: ${e.message}');
    } catch (e, stack) {
      print('>>> [CommentDS] Unexpected error: $e');
      print('>>> [CommentDS] Stack: $stack');
      throw Exception('Unexpected error: $e');
    }
  }

  // 🔥 THÊM HELPER METHOD ĐỂ PARSE COMMENT VỚI REPLIES
  CommentEntity _parseCommentWithReplies(Map<String, dynamic> json) {
    try {
      // Parse comment chính
      final comment = CommentModel.fromJson(json).toEntity();
      
      // 🔥 CHECK VÀ PARSE REPLIES NẾU CÓ
      if (json.containsKey('replies') && json['replies'] is List) {
        final repliesJson = json['replies'] as List<dynamic>;
        final List<CommentEntity> replies = [];
        
        for (final replyJson in repliesJson) {
          if (replyJson is Map<String, dynamic>) {
            try {
              final reply = CommentModel.fromJson(replyJson).toEntity();
              replies.add(reply);
            } catch (e) {
              print('>>> [CommentDS] Error parsing reply: $e');
              print('>>> [CommentDS] Reply data: $replyJson');
            }
          }
        }
        
        // Trả về comment với replies
        return comment.copyWith(replies: replies);
      }
      
      return comment;
      
    } catch (e, stack) {
      print('>>> [CommentDS] Error in _parseCommentWithReplies: $e');
      print('>>> [CommentDS] Stack: $stack');
      print('>>> [CommentDS] JSON data: $json');
      rethrow;
    }
  }
  @override
  Future<CommentEntity> createComment(
    String postId,
    String content, {
    String? parentId,
  }) async {
    try {
      final payload = {
        'post_id': postId,
        'content': content,
        if (parentId != null) 'parent_id': parentId,
      };

      final response = await _dio.post(
        '/comments/',
        data: payload,
        options: Options(headers: _authHeaders()),
      );

      final responseData = response.data as Map<String, dynamic>;

      if (responseData['success'] == false) {
        final errorMessage =
            responseData['error'] ??
            responseData['message'] ??
            'Failed to create comment';
        throw DailyLimitException(
          message: errorMessage,
          dailyRemaining: responseData['daily_comments_remaining'] as int? ?? 0,
        );
      }

      if (!responseData.containsKey('comment')) {
        throw Exception('No comment data in response');
      }

      final commentData = responseData['comment'] as Map<String, dynamic>;
      return CommentModel.fromJson(commentData).toEntity();
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data?['detail'] ??
          e.response?.data?['error'] ??
          e.response?.data?['message'] ??
          e.message ??
          'Unknown error';
      throw Exception('Failed to create comment: $errorMessage');
    }
  }

  @override
  Future<CommentEntity> updateComment(String commentId, String content) async {
    try {
      final payload = {'content': content};
      final response = await _dio.put(
        '/comments/$commentId',
        data: payload,
        options: Options(headers: _authHeaders()),
      );

      final responseData = response.data as Map<String, dynamic>;

      if (responseData.containsKey('error') && responseData['error'] != null) {
        throw Exception(responseData['error']);
      }

      final commentData = responseData['comment'] as Map<String, dynamic>;
      return CommentModel.fromJson(commentData).toEntity();
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data?['detail'] ??
          e.response?.data?['error'] ??
          e.message ??
          'Unknown error';
      throw Exception('Failed to update comment: $errorMessage');
    }
  }

  @override
  Future<void> deleteComment(String commentId) async {
    try {
      await _dio.delete(
        '/comments/$commentId',
        options: Options(headers: _authHeaders()),
      );
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data?['detail'] ??
          e.response?.data?['error'] ??
          e.message ??
          'Unknown error';
      throw Exception('Failed to delete comment: $errorMessage');
    }
  }
}
