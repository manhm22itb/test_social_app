import 'package:injectable/injectable.dart';

import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';
import '../models/profile_model.dart';
import '../models/update_profile_request.dart';

@LazySingleton(as: ProfileRepository)
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remote;

  ProfileRepositoryImpl({required this.remote});

  @override
  Future<Profile> getMyProfile(String token) async {
    final ProfileModel model = await remote.getMyProfile(token);
    return model.toEntity();
  }

  @override
  Future<Profile> updateMyProfile({
    required String token,
    String? username,
    String? bio,
    String? avatarUrl,
  }) async {
    final request = UpdateProfileRequest(
      username: username,
      bio: bio,
      avatarUrl: avatarUrl,
    );

    final ProfileModel model = await remote.updateMyProfile(
      token: token,
      request: request,
    );

    return model.toEntity();
  }
}
