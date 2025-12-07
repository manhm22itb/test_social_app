import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/user_profile_entity.dart';
import '../../../../../generated/colors.gen.dart';
import '../../../../common/utils/getit_utils.dart';
import '../../../app/app_router.dart'; // 👈 THÊM IMPORT NÀY
import '../../../newpost/presentation/cubit/post_cubit.dart';
import '../cubit/user_profile_cubit.dart';
import '../cubit/user_profile_state.dart';
import '../widgets/user_profile_header_stack.dart';
import '../widgets/user_profile_tabs.dart';

@RoutePage()
class UserProfilePage extends StatelessWidget {
  final String userId;

  const UserProfilePage({
    super.key,
    @PathParam('userId') required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // 🔹 Cubit cho profile
        BlocProvider(
          create: (_) => getIt<UserProfileCubit>()..loadUserProfile(userId),
        ),

        // 🔹 Cubit cho post (để UserPostsTab dùng lại)
        BlocProvider(
          create: (_) => getIt<PostCubit>()..loadFeed(),
        ),
      ],
      child: const _UserProfileView(),
    );
  }
}

class _UserProfileView extends StatelessWidget {
  const _UserProfileView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserProfileCubit, UserProfileState>(
      builder: (context, state) {
        return state.map(
          initial: (_) => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          loading: (_) => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          error: (s) => Scaffold(
            body: Center(
              child: Text(
                'Error: ${s.message}',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ),
          loaded: (s) {
            final profile = s.profile;
            const isUpdating = false;

            return _buildScaffold(
              context: context,
              profile: profile,
              isFollowUpdating: isUpdating,
            );
          },
          followUpdating: (s) {
            final profile = s.profile;
            const isUpdating = true;

            return _buildScaffold(
              context: context,
              profile: profile,
              isFollowUpdating: isUpdating,
            );
          },
        );
      },
    );
  }

  Widget _buildScaffold({
    required BuildContext context,
    required UserProfileEntity profile,
    required bool isFollowUpdating,
  }) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: ColorName.bgF4f7f7,
        body: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserProfileHeaderStack(
              profile: profile,
              onBack: () => Navigator.of(context).maybePop(),
              isFollowUpdating: isFollowUpdating,
              onFollowPressed: profile.isMe
                  ? null
                  : () {
                      context.read<UserProfileCubit>().toggleFollow();
                    },
              onFollowingTap: () {
                context.router.push(
                  FollowingRoute(userId: profile.id),
                );
              },
              onFollowersTap: () {
                context.router.push(
                  FollowersRoute(userId: profile.id),
                );
              },
            ),
            SizedBox(
              height: 500,
              child: UserProfileTabs(profile: profile),
            ),
          ],
        ),
      ),
    );
  }
}
