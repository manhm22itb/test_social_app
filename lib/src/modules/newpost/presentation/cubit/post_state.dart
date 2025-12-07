
part of 'post_cubit.dart';

abstract class PostState {
  const PostState();
}

class PostStateInitial extends PostState {
  const PostStateInitial();
}

class PostStateLoading extends PostState {
  const PostStateLoading();
}

class PostStateLoaded extends PostState {
  final List<PostEntity> posts;

  const PostStateLoaded({required this.posts});
}

class PostStateError extends PostState {
  final String message;

  const PostStateError({required this.message});
}
class PostStateLikeLimitReached extends PostState {
  const PostStateLikeLimitReached();
}
