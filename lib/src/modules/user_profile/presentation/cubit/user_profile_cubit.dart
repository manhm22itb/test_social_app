import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:social_app/src/common/utils/getit_utils.dart'; // 👈 Lấy Dio từ getIt

import '../../domain/usecases/get_user_profile_usecase.dart';
import 'user_profile_state.dart';

@injectable
class UserProfileCubit extends Cubit<UserProfileState> {
  final GetUserProfileUseCase _getUserProfile;

  // 👇 Constructor giữ nguyên 1 tham số như ban đầu
  UserProfileCubit(this._getUserProfile)
      : super(const UserProfileState.initial());

  Future<void> loadUserProfile(String userId) async {
    emit(const UserProfileState.loading());
    try {
      final profile = await _getUserProfile(userId);
      emit(UserProfileState.loaded(profile));
    } catch (e) {
      emit(UserProfileState.error(e.toString()));
    }
  }

  /// 🔥 Follow / Unfollow user đang xem trong user_profile
  ///
  /// - Lấy profile hiện tại từ state
  /// - Lấy access token từ Supabase
  /// - Lấy Dio từ getIt (đã config baseUrl ở chỗ khác)
  /// - Gọi:
  ///     POST   /users/{user_id}/follow   -> FOLLOW
  ///     DELETE /users/{user_id}/follow   -> UNFOLLOW
  /// - Cập nhật lại isFollowing + followerCount local
  Future<void> toggleFollow() async {
    // Lấy profile hiện tại từ state (loaded hoặc followUpdating)
    final profile = state.maybeWhen(
      loaded: (p) => p,
      followUpdating: (p) => p,
      orElse: () => null,
    );

    if (profile == null) return;

    // Không cho tự follow chính mình
    if (profile.isMe) return;

    // Lấy access token từ Supabase
    final session = Supabase.instance.client.auth.currentSession;
    final accessToken = session?.accessToken;

    if (accessToken == null) {
      emit(const UserProfileState.error('Not authenticated'));
      emit(UserProfileState.loaded(profile));
      return;
    }

    final targetUserId = profile.id;
    final isCurrentlyFollowing = profile.isFollowing ?? false;

    // Lấy Dio từ getIt (đã đăng ký ở chỗ khác)
    final dio = getIt<Dio>();

    // Cho UI biết đang xử lý (disable nút, cho phép show loading)
    emit(UserProfileState.followUpdating(profile));

    try {
      if (isCurrentlyFollowing) {
        // 👇 UNFOLLOW: DELETE /users/{userId}/follow
        await dio.delete(
          '/users/$targetUserId/follow',
          options: Options(
            headers: {
              'Authorization': 'Bearer $accessToken',
            },
          ),
        );
      } else {
        // 👇 FOLLOW: POST /users/{userId}/follow
        await dio.post(
          '/users/$targetUserId/follow',
          options: Options(
            headers: {
              'Authorization': 'Bearer $accessToken',
            },
          ),
        );
      }

      // ✅ Nếu API thành công -> cập nhật followerCount + isFollowing local
      final newFollowerCount =
          profile.followerCount + (isCurrentlyFollowing ? -1 : 1);

      final updatedProfile = profile.copyWith(
        isFollowing: !isCurrentlyFollowing,
        followerCount: newFollowerCount < 0 ? 0 : newFollowerCount,
      );

      emit(UserProfileState.loaded(updatedProfile));
    } catch (e) {
      emit(UserProfileState.error('Failed to update follow: $e'));
      emit(UserProfileState.loaded(profile));
    }
  }
}
