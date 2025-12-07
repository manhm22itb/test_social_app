import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/blocked_user_model.dart';
import 'block_remote_datasource.dart';

@LazySingleton(as: BlockRemoteDataSource)
class BlockRemoteDataSourceImpl implements BlockRemoteDataSource {
  final Dio _dio;
  final SupabaseClient _supabase;

  BlockRemoteDataSourceImpl(this._dio, this._supabase);

  Map<String, String> _headers() {
    final token = _supabase.auth.currentSession?.accessToken;
    if (token == null) {
      throw Exception('Not authenticated');
    }

    return {
      'Authorization': 'Bearer $token',
      'accept': 'application/json',
      'content-type': 'application/json',
    };
  }

  @override
  Future<void> blockUser(String userId) async {
    final res = await _dio.post(
      '/users/$userId/block',
      options: Options(headers: _headers()),
    );

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception(
        'Block user failed: status=${res.statusCode}, data=${res.data}',
      );
    }
  }

  @override
  Future<void> unblockUser(String userId) async {
    final res = await _dio.delete(
      '/users/$userId/block',
      options: Options(headers: _headers()),
    );

    if (res.statusCode != 200 &&
        res.statusCode != 202 &&
        res.statusCode != 204) {
      throw Exception(
        'Unblock user failed: status=${res.statusCode}, data=${res.data}',
      );
    }
  }

  /// Lấy danh sách user đã block (trả về MODEL)
  @override
  Future<List<BlockedUserModel>> getBlockedUsers() async {
    final res = await _dio.get(
      '/users/blocks',
      options: Options(headers: _headers()),
    );

    final data = res.data;
    List<dynamic> raw;

    if (data is Map<String, dynamic>) {
      // backend: { blocks: [...], total: ... }
      raw = (data['blocks'] as List<dynamic>? ?? []);
    } else if (data is List<dynamic>) {
      // fallback: backend trả thẳng list
      raw = data;
    } else {
      throw Exception('Unexpected blocks response: ${data.runtimeType}');
    }

    return raw
        .map(
          (e) => BlockedUserModel.fromJson(
            e as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  @override
  Future<bool> isBlocked(String userId) async {
    final list = await getBlockedUsers();
    return list.any((e) => e.userId == userId);
  }
}
