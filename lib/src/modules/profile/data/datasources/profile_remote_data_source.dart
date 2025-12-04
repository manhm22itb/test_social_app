import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../models/profile_model.dart';
import '../models/update_profile_request.dart';

@lazySingleton
class ProfileRemoteDataSource {
  final Dio dio;

  ProfileRemoteDataSource({required this.dio});

  /// GET /profile/me  -> lấy profile của chính mình
  Future<ProfileModel> getMyProfile(String token) async {
    try {
      final response = await dio.get(
        '/profile/me', // ✅ KHỚP backend: prefix "/profile" + "/me"
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return ProfileModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to get profile');
    } catch (e) {
      throw Exception('Failed to get profile: $e');
    }
  }

  /// PUT /profile/  -> update profile của chính mình
  Future<ProfileModel> updateMyProfile({
    required String token,
    required UpdateProfileRequest request,
  }) async {
    try {
      final response = await dio.put(
        '/profile/', // ✅ KHỚP backend: @router.put("/") => /profile/
        data: request.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return ProfileModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['detail'] ?? 'Failed to update profile',
      );
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }
}
