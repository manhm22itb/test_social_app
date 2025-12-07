import 'package:dartz/dartz.dart';
import 'package:social_app/src/core/error/failures.dart';
import 'package:social_app/src/modules/search/domain/entities/search_result.dart';

enum SearchType { all, posts, users }

abstract class SearchRepository {
  Future<Either<Failure, SearchResult>> search(String query, SearchType type);
}