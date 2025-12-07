import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:social_app/src/modules/search/domain/repositories/search_repository.dart';

abstract class SearchRemoteDataSource {
  // Đổi từ Future<Map<String, dynamic>> sang Future<dynamic>
  Future<dynamic> search(String query, SearchType type);
}

@LazySingleton(as: SearchRemoteDataSource)
class SearchRemoteDataSourceImpl implements SearchRemoteDataSource {
  final Dio _dio;

  SearchRemoteDataSourceImpl(this._dio);

  @override
  Future<dynamic> search(String query, SearchType type) async {
    try {
      String typeStr;
      switch (type) {
        case SearchType.posts: typeStr = 'posts'; break;
        case SearchType.users: typeStr = 'users'; break;
        case SearchType.all:
        default: typeStr = 'all'; break;
      }

      final response = await _dio.get(
        '/search/', 
        queryParameters: {
          'q': query,
          'type': typeStr,
        },
      );

      // Trả về nguyên gốc response.data (có thể là List hoặc Map)
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}