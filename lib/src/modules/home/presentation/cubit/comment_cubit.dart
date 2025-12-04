import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/comment_entity.dart';
import '../../domain/usecases/get_comments_usecase.dart';
import '../../domain/usecases/create_comment_usecase.dart';
import '../../domain/usecases/update_comment_usecase.dart';
import '../../domain/usecases/delete_comment_usecase.dart';

part 'comment_state.dart';

@injectable
class CommentCubit extends Cubit<CommentState> {
  final GetCommentsUseCase _getCommentsUseCase;
  final CreateCommentUseCase _createCommentUseCase;
  final UpdateCommentUseCase _updateCommentUseCase;
  final DeleteCommentUseCase _deleteCommentUseCase;

  CommentCubit(
    this._getCommentsUseCase,
    this._createCommentUseCase,
    this._updateCommentUseCase,
    this._deleteCommentUseCase,
  ) : super(const CommentStateInitial());

  Future<void> loadComments(String postId) async {
    emit(const CommentStateLoading());
    try {
      final comments = await _getCommentsUseCase(postId);
      emit(CommentStateLoaded(comments: comments));
    } catch (e) {
      emit(CommentStateError(message: e.toString()));
    }
  }

  Future<void> createComment(String postId, String content, {String? parentId}) async {
    final current = state;
    try {
      final newComment = await _createCommentUseCase(postId, content, parentId: parentId);

      if (current is CommentStateLoaded) {
        emit(CommentStateLoaded(comments: [newComment, ...current.comments]));
      } else {
        emit(CommentStateLoaded(comments: [newComment]));
      }
    } catch (e) {
      emit(CommentStateError(message: e.toString()));
    }
  }

  Future<void> updateComment(String commentId, String content) async {
    final current = state;
    if (current is! CommentStateLoaded) return;

    try {
      final updatedComment = await _updateCommentUseCase(commentId, content);
      final updatedList = current.comments
          .map((comment) => comment.id == updatedComment.id ? updatedComment : comment)
          .toList();

      emit(CommentStateLoaded(comments: updatedList));
    } catch (e) {
      emit(CommentStateError(message: e.toString()));
    }
  }

  Future<void> deleteComment(String commentId) async {
    final current = state;
    if (current is! CommentStateLoaded) return;

    try {
      await _deleteCommentUseCase(commentId);
      final updatedList = current.comments
          .where((comment) => comment.id != commentId)
          .toList();

      emit(CommentStateLoaded(comments: updatedList));
    } catch (e) {
      emit(CommentStateError(message: e.toString()));
  }
}
}