part of 'comment_cubit.dart';

abstract class CommentState {
  const CommentState();
}

class CommentStateInitial extends CommentState {
  const CommentStateInitial();
}

class CommentStateLoading extends CommentState {
  const CommentStateLoading();
}

class CommentStateLoaded extends CommentState {
  final List<CommentEntity> comments;
  const CommentStateLoaded({required this.comments});
}

class CommentStateError extends CommentState {
  final String message;
  const CommentStateError({required this.message});
}