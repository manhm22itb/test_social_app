import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app/app_router.dart';
import '../../../newpost/domain/entities/post_entity.dart';
import '../../../newpost/presentation/cubit/post_cubit.dart';
import '../../../../../generated/colors.gen.dart';
import 'post_item.dart';

import '../cubit/comment_cubit.dart';

class PostList extends StatelessWidget {
  const PostList({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy id user hiện tại từ Supabase
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
          final posts = state.posts;
          if (posts.isEmpty) {
            return const Center(
              child: Text('No posts yet. Be the first to post!'),
            );
          }

          final cubit = context.read<PostCubit>();
          final commentCubit = context.read<CommentCubit>();

          return ListView.separated(
            itemCount: posts.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: ColorName.borderLight),
            itemBuilder: (context, index) {
              final PostEntity post = posts[index];

              // Xem có phải chủ bài viết không
              final bool isOwner =
                  currentUserId != null && currentUserId == post.authorId;

              return PostItem(
                post: post,
                onLikePressed: () {
                  cubit.toggleLike(post.id);

                  if (state is PostStateLikeLimitReached) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('You reached like limits to day (5 times)!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    return;
                  }
                },
                onCommentPressed: () {
                  // 🔥 ĐIỀU HƯỚNG ĐƠN GIẢN - TEST TRƯỚC
                    context.router.push(CommentRoute(post: post));
                },
                onRepostPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Repost coming soon')),
                  );
                },
                onMorePressed: () {
                  // 🔥 3 chấm: mở bottom sheet
                  _showMoreBottomSheet(
                    context: context,
                    cubit: cubit,
                    post: post,
                    isOwner: isOwner,
                  );
                },

                /// 🔥 Khi bấm avatar / tên tác giả
                onAuthorPressed: () {
                  if (currentUserId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please log in to view profiles'),
                      ),
                    );
                    return;
                  }

                  if (isOwner) {
                    // 👉 Đây là bài của chính mình -> đi tới trang profile chính
                    context.router.push(
                      const ProfileRoute(), // nếu route tên khác thì đổi lại
                    );
                  } else {
                    // 👉 Bài của người khác -> đi tới UserProfilePage (module user_profile)
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

void _handleCommentPressed(BuildContext context, CommentCubit commentCubit, PostEntity post) {
  _showCommentDialog(context, commentCubit, post);
}

void _showCommentDialog(BuildContext context, CommentCubit commentCubit, PostEntity post) {
  final TextEditingController commentController = TextEditingController();
  
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: ColorName.backgroundWhite,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Row(
                children: [
                  const Text(
                    'Add Comment',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            
            // Comment input
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: commentController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Write your comment...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            
            // Post button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final content = commentController.text.trim();
                    if (content.isEmpty) return;
                    
                    try {
                      await commentCubit.createComment(post.id, content);
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Comment posted!')),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to post comment: $e')),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorName.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Post Comment',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

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
                  : _buildOtherActions(ctx, post), // 👈 NHỚ TRUYỀN post VÀO
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

  List<Widget> _buildOtherActions(
    BuildContext context,
    PostEntity post,
  ) {
    return [
      ListTile(
        leading: const Icon(Icons.block),
        title: const Text(
          'Block this author',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        onTap: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Block author coming soon')),
          );
        },
      ),
      ListTile(
        leading: const Icon(Icons.link),
        title: const Text(
          'Copy link',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        onTap: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Copy link coming soon')),
          );
        },
      ),
    ];
  }
}
