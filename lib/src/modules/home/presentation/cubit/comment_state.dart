import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/comment_entity.dart';

part 'comment_state.freezed.dart';

@freezed
class CommentState with _$CommentState {
  const factory CommentState.initial() = CommentStateInitial;
  
  const factory CommentState.loading() = CommentStateLoading;
  
  const factory CommentState.loaded({
    required List<CommentEntity> comments,
    String? message,
    String? error,
    @Default(false) bool isOptimistic,
  }) = CommentStateLoaded;
  
  const factory CommentState.error({
    required String message,
  }) = CommentStateError;
}