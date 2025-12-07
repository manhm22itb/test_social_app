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

      // In ra log để kiểm tra cấu trúc thực tế
      print("🔍 API Response Raw: $rawData");

      List<PostEntity> posts = [];
      List<UserEntity> users = [];

      // --- 1. Helper Function: Tìm List dữ liệu bất chấp cấu trúc ---
      List<dynamic> findList(dynamic data, List<String> priorityKeys) {
        if (data is List) return data; 

        if (data is Map<String, dynamic>) {
          // 1. Ưu tiên tìm theo key được chỉ định
          for (var key in priorityKeys) {
            if (data.containsKey(key) && data[key] is List) {
              return data[key];
            }
          }
          
          // 2. Nếu không thấy, tìm key 'data' (đệ quy)
          if (data.containsKey('data')) {
            var innerData = data['data'];
            if (innerData is List) return innerData;
            if (innerData is Map<String, dynamic>) {
               return findList(innerData, priorityKeys);
            }
          }
        }
        return [];
      }

      // --- 2. Helper Parsing (Map từ JSON sang Entity & Vá lỗi thiếu trường) ---
      
      List<PostEntity> parsePosts(List<dynamic> list) {
        return list.map((e) {
          try {
            // Tạo bản sao của map để có thể chỉnh sửa dữ liệu (vì e có thể là read-only)
            Map<String, dynamic> item = Map<String, dynamic>.from(e);

            // --- VÁ LỖI DỮ LIỆU (DATA PATCHING) ---
            // PostModel yêu cầu các trường này không được null, nhưng API Search bị thiếu
            
            // 1. Thiếu user_id
            if (item['user_id'] == null) {
              item['user_id'] = ''; 
            }
            
            // 2. Thiếu visibility
            if (item['visibility'] == null) {
              item['visibility'] = 'public'; 
            }

            // 3. Thiếu updated_at -> lấy created_at hoặc thời gian hiện tại bù vào
            if (item['updated_at'] == null) {
              item['updated_at'] = item['created_at'] ?? DateTime.now().toIso8601String();
            }

            return PostModel.fromJson(item).toEntity();
          } catch (error) {
            // In lỗi chi tiết để debug nếu vẫn còn sai sót
            print("❌ Lỗi parse Post (ID: ${e['id']}): $error");
            return null; 
          }
        }).whereType<PostEntity>().toList();
      }

      List<UserEntity> parseUsers(List<dynamic> list) {
        return list.map((e) {
          try {
            Map<String, dynamic> item = Map<String, dynamic>.from(e);

            // --- VÁ LỖI DỮ LIỆU ---
            // UserEntity yêu cầu email, nhưng API Search public thường ẩn email
            if (item['email'] == null) {
              item['email'] = ''; // Gán rỗng để không bị crash
            }

            return UserEntity.fromJson(item);
          } catch (error) {
            print("❌ Lỗi parse User (ID: ${e['id']}): $error");
            return null; 
          }
        }).whereType<UserEntity>().toList();
      }

      // --- 3. Thực thi Logic Search ---
      if (type == SearchType.all) {
        posts = parsePosts(findList(rawData, ['posts']));
        users = parseUsers(findList(rawData, ['users']));
      } 
      else if (type == SearchType.posts) {
        posts = parsePosts(findList(rawData, ['posts', 'data']));
      } 
      else if (type == SearchType.users) {
        users = parseUsers(findList(rawData, ['users', 'data']));
      }

      return Right(SearchResult(posts: posts, users: users));
    } catch (e) {
      print("❌ SearchRepository Error: $e");
      return Left(ServerFailure(e.toString()));
    }
  }
}