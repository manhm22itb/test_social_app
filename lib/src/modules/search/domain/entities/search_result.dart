import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:social_app/src/modules/newpost/domain/entities/post_entity.dart';
import 'package:social_app/src/modules/auth/domain/entities/user_entity.dart';

part 'search_result.freezed.dart';

@freezed
class SearchResult with _$SearchResult {
  const factory SearchResult({
    @Default([]) List<PostEntity> posts,
    @Default([]) List<UserEntity> users,
  }) = _SearchResult;
}