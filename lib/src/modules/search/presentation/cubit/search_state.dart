import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:social_app/src/modules/search/domain/entities/search_result.dart';

part 'search_state.freezed.dart';

@freezed
class SearchState with _$SearchState {
  const factory SearchState.initial() = _Initial;
  const factory SearchState.loading() = _Loading;
  const factory SearchState.success(SearchResult result) = _Success;
  const factory SearchState.failure(String message) = _Failure;
}