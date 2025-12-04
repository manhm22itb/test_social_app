import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../generated/colors.gen.dart';
import '../../../app/app_router.dart';
import '../../../newpost/domain/entities/post_entity.dart';
import '../../../newpost/presentation/cubit/post_cubit.dart';
import '../../../home/presentation/widgets/post_item.dart';

class UserPostsTab extends StatelessWidget {
  final String userId; // nhận userId từ ProfilePage

  const UserPostsTab({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    return BlocBuilder<PostCubit, PostState>(
      builder: (context, state) {
        if (state is PostStateLoading || state is PostStateInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is PostStateError) {
          return Center(
            child: Text(
              'Error: ${state.message}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (state is PostStateLoaded) {
          // lọc post theo userId được truyền vào
          final posts = state.posts.where((p) => p.authorId == userId).toList();

          if (posts.isEmpty) {
            return const Center(child: Text('No posts yet'));
          }

          final cubit = context.read<PostCubit>();

          return ListView.separated(
            itemCount: posts.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: ColorName.borderLight),
            itemBuilder: (context, index) {
              final post = posts[index];
              final isOwner = currentUserId == post.authorId;

              return PostItem(
                post: post,
                onLikePressed: () => cubit.toggleLike(post.id),
                onCommentPressed: () {
                  context.router.push(CommentRoute(post: post));
                },
                onRepostPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Repost coming soon')),
                  );
                },
                onMorePressed: () => _showMoreBottomSheet(
                  context: context,
                  cubit: cubit,
                  post: post,
                  isOwner: isOwner,
                ),

                // 🔥 MỚI THÊM: click avatar / tên trong tab posts
                onAuthorPressed: () {
                  if (currentUserId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please log in to view profiles'),
                      ),
                    );
                    return;
                  }

                  if (currentUserId == post.authorId) {
                    // Đang xem bài của chính mình -> về trang profile chính
                    context.router.push(const ProfileRoute());
                  } else {
                    // Bài của user khác -> sang UserProfilePage
                    context.router.push(
                      UserProfileRoute(userId: post.authorId),
                    );
                  }
                },
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  // ==========================
  // BOTTOM SHEET: EDIT / DELETE
  // ==========================

  void _showMoreBottomSheet({
    required BuildContext context,
    required PostCubit cubit,
    required PostEntity post,
    required bool isOwner,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: ColorName.softBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: isOwner
                  ? _buildOwnerActions(ctx, cubit, post)
                  : _buildOtherActions(ctx),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildOwnerActions(
    BuildContext context,
    PostCubit cubit,
    PostEntity post,
  ) {
    return [
      ListTile(
        leading: const Icon(Icons.edit_outlined),
        title: const Text(
          'Edit post',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        onTap: () async {
          Navigator.pop(context);

          final result = await context.router.push(EditPostRoute(post: post));

          if (result == true && context.mounted) {
            context.read<PostCubit>().loadFeed();
          }
        },
      ),
      ListTile(
        leading: const Icon(Icons.delete_outline, color: Colors.red),
        title: const Text(
          'Delete post',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.red,
          ),
        ),
        onTap: () async {
          Navigator.pop(context);

          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Delete post'),
              content: const Text('Are you sure you want to delete this post?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Delete'),
                ),
              ],
            ),
          );

          if (confirm == true) {
            final ok = await cubit.deletePost(post.id);
            if (!context.mounted) return;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(ok ? 'Post deleted' : 'Failed to delete post'),
              ),
            );
          }
        },
      ),
    ];
  }

  List<Widget> _buildOtherActions(BuildContext context) {
    return [
      ListTile(
        leading: const Icon(Icons.flag_outlined),
        title: const Text(
          'Report post',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        onTap: () => Navigator.pop(context),
      ),
      ListTile(
        leading: const Icon(Icons.volume_off_outlined),
        title: const Text(
          'Mute this author',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        onTap: () => Navigator.pop(context),
      ),
    ];
  }
}
