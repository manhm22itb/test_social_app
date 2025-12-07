import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../models/user_profile_model.dart';

@lazySingleton
class UserProfileApi {
  final Dio _dio;

  UserProfileApi(this._dio);

  /// Gọi API lấy profile người khác
  ///
  /// Backend: get_user_profile(current_user_id, target_user_id)
  /// Giả sử route: GET /profiles/{userId}
  Future<UserProfileModel> getUserProfile(String userId) async {
    final response = await _dio.get('/profile/$userId');

    return UserProfileModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}
