import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:social_app/src/core/error/failures.dart';
import 'package:social_app/src/modules/search/domain/entities/search_result.dart'; // Đảm bảo đã tạo file này
import '../repositories/search_repository.dart'; // Chứa enum SearchType

@injectable
class SearchUseCase {
  final SearchRepository _repository;

  SearchUseCase(this._repository);

  // Hàm call nhận vào query và loại tìm kiếm (All, Posts, Users)
  Future<Either<Failure, SearchResult>> call(String query, SearchType type) {
    return _repository.search(query, type);
  }
}