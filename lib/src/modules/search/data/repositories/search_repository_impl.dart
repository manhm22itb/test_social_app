import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:social_app/src/core/error/failures.dart';
import 'package:social_app/src/modules/auth/domain/entities/user_entity.dart';
import 'package:social_app/src/modules/newpost/data/models/post_model.dart';
import 'package:social_app/src/modules/newpost/domain/entities/post_entity.dart';
import 'package:social_app/src/modules/search/data/datasources/search_remote_datasource.dart';
import 'package:social_app/src/modules/search/domain/entities/search_result.dart';
import 'package:social_app/src/modules/search/domain/repositories/search_repository.dart';

@LazySingleton(as: SearchRepository)
class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDataSource _datasource;

  SearchRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, SearchResult>> search(String query, SearchType type) async {
    try {
      final dynamic rawData = await _datasource.search(query, type);
      
      // In ra log để bạn kiểm tra cấu trúc thực tế (xem trong Debug Console)
      print("🔍 API Response Raw: $rawData");

      List<PostEntity> posts = [];
      List<UserEntity> users = [];

      // --- 1. Helper Function: Tìm List dữ liệu bất chấp cấu trúc ---
      // Hàm này sẽ cố gắng tìm ra một List từ rawData dựa trên key gợi ý (ví dụ 'posts', 'data')
      List<dynamic> findList(dynamic data, List<String> priorityKeys) {
        if (data is List) return data; // Nếu là List thì trả về luôn

        if (data is Map<String, dynamic>) {
          // 1. Ưu tiên tìm theo key được chỉ định (vd: 'posts')
          for (var key in priorityKeys) {
            if (data.containsKey(key) && data[key] is List) {
              return data[key];
            }
          }
          // 2. Nếu không thấy, tìm key 'data' (có thể lồng nhau)
          if (data.containsKey('data')) {
            var innerData = data['data'];
            if (innerData is List) return innerData;
            if (innerData is Map<String, dynamic>) {
               // Đệ quy: Nếu data là Map, tìm tiếp bên trong nó
               return findList(innerData, priorityKeys);
            }
          }
        }
        return []; // Không tìm thấy gì
      }

      // --- 2. Helper Parsing (Map từ JSON sang Entity) ---
      List<PostEntity> parsePosts(List<dynamic> list) {
        return list.map((e) {
          try {
            return PostModel.fromJson(e as Map<String, dynamic>).toEntity();
          } catch (_) { return null; } // Bỏ qua phần tử lỗi
        }).whereType<PostEntity>().toList();
      }

      List<UserEntity> parseUsers(List<dynamic> list) {
        return list.map((e) {
          try {
            return UserEntity.fromJson(e as Map<String, dynamic>);
          } catch (_) { return null; }
        }).whereType<UserEntity>().toList();
      }

      // --- 3. Thực thi Logic Search ---
      if (type == SearchType.all) {
        // Tìm list posts với key ưu tiên là 'posts'
        posts = parsePosts(findList(rawData, ['posts']));
        // Tìm list users với key ưu tiên là 'users'
        users = parseUsers(findList(rawData, ['users']));
      } 
      else if (type == SearchType.posts) {
        // Tìm list posts, ưu tiên key 'posts' hoặc 'data'
        posts = parsePosts(findList(rawData, ['posts', 'data']));
      } 
      else if (type == SearchType.users) {
        // Tìm list users, ưu tiên key 'users' hoặc 'data'
        users = parseUsers(findList(rawData, ['users', 'data']));
      }

      return Right(SearchResult(posts: posts, users: users));
    } catch (e) {
      print("❌ SearchRepository Error: $e");
      return Left(ServerFailure(e.toString()));
    }
  }
}