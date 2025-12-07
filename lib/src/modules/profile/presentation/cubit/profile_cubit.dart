import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/usecases/get_my_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import 'profile_state.dart';

@injectable
class ProfileCubit extends Cubit<ProfileState> {
  final GetMyProfileUseCase getMyProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;

  ProfileCubit({
    required this.getMyProfileUseCase,
    required this.updateProfileUseCase,
  }) : super(const ProfileState.initial());

  Future<void> loadMyProfile(String token) async {
    if (isClosed) return;
    emit(const ProfileState.loading());
    try {
      final profile = await getMyProfileUseCase(token);
      if (!isClosed) { 
        emit(ProfileState.loaded(profile));
      }
    } catch (e) {
     if (!isClosed) {
        emit(ProfileState.error(e.toString()));
      }
    }
  }

  Future<void> updateProfile({
    required String token,
    String? username,
    String? bio,
    String? avatarUrl,
  }) async {
    state.whenOrNull(
      loaded: (profile) {
        emit(ProfileState.updating(profile));
      },
    );

    try {
      final updatedProfile = await updateProfileUseCase(
        token: token,
        username: username,
        bio: bio,
        avatarUrl: avatarUrl,
      );
      emit(ProfileState.loaded(updatedProfile));
    } catch (e) {
      emit(ProfileState.error(e.toString()));
    }
  }
}
