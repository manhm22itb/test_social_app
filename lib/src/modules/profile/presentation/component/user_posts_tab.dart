import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../generated/colors.gen.dart';
import '../../../app/app_router.dart';
import '../../../home/presentation/widgets/post_item.dart';
import '../../../newpost/domain/entities/post_entity.dart';
import '../../../newpost/presentation/cubit/post_cubit.dart';

import '../../../../common/utils/getit_utils.dart';
import '../../../block/domain/usecase/block_user_usecase.dart';
import '../../../block/domain/usecase/unblock_user_usecase.dart';
import '../../../block/domain/usecase/is_blocked_usecase.dart';

class UserPostsTab extends StatelessWidget {
  final String userId;

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

                // 👉 giống Home: share với UI đẹp
                onSharePressed: () {
                  _onSharePost(
                    context: context,
                    cubit: cubit,
                    post: post,
                    currentUserId: currentUserId,
                  );
                },

                // click avatar / tên
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
                    context.router.push(const ProfileRoute());
                  } else {
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

  Future<void> _onSharePost({
    required BuildContext context,
    required PostCubit cubit,
    required PostEntity post,
    required String? currentUserId,
  }) async {
    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to share posts'),
        ),
      );
      return;
    }

    final result = await _showShareBottomSheet(context, post);
    if (result == null) return;

    final String visibility = result['visibility'] as String;
    String? content = result['content'] as String?;
    content =
        (content != null && content.trim().isNotEmpty) ? content.trim() : null;

    final ok = await cubit.sharePost(
      post.id,
      visibility: visibility,
      content: content,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Share post thành công' : 'Share post thất bại'),
      ),
    );
  }

  Future<Map<String, dynamic>?> _showShareBottomSheet(
    BuildContext context,
    PostEntity post,
  ) {
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
        final theme = Theme.of(ctx);
        final TextEditingController controller = TextEditingController();
        String visibility = 'public';

        return StatefulBuilder(
          builder: (ctx, setState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: bottomInset + 16,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.18),
                      blurRadius: 24,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Share post',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx, null),
                          splashRadius: 22,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.grey.shade300,
                          backgroundImage: (post.authorAvatarUrl != null &&
                                  post.authorAvatarUrl!.isNotEmpty)
                              ? NetworkImage(post.authorAvatarUrl!)
                              : null,
                          child: (post.authorAvatarUrl == null ||
                                  post.authorAvatarUrl!.isEmpty)
                              ? Text(
                                  (post.authorName.isNotEmpty
                                          ? post.authorName[0]
                                          : '?')
                                      .toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                post.authorName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  ChoiceChip(
                                    label: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Icon(Icons.public,
                                            size: 14, color: Colors.white),
                                        SizedBox(width: 4),
                                        Text('Public'),
                                      ],
                                    ),
                                    selected: visibility == 'public',
                                    labelStyle: TextStyle(
                                      color: visibility == 'public'
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                    selectedColor: Colors.deepPurple,
                                    backgroundColor: Colors.grey[100],
                                    onSelected: (_) =>
                                        setState(() => visibility = 'public'),
                                  ),
                                  const SizedBox(width: 8),
                                  ChoiceChip(
                                    label: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Icon(Icons.lock,
                                            size: 14, color: Colors.black87),
                                        SizedBox(width: 4),
                                        Text('Private'),
                                      ],
                                    ),
                                    selected: visibility == 'private',
                                    selectedColor: Colors.deepPurple.shade50,
                                    backgroundColor: Colors.grey[100],
                                    labelStyle: TextStyle(
                                      color: visibility == 'private'
                                          ? Colors.deepPurple
                                          : Colors.black87,
                                    ),
                                    onSelected: (_) =>
                                        setState(() => visibility = 'private'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: TextField(
                        controller: controller,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          isCollapsed: true,
                          border: InputBorder.none,
                          hintText: 'Viết gì đó về bài viết này...',
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: Colors.grey.shade400,
                            backgroundImage: (post.authorAvatarUrl != null &&
                                    post.authorAvatarUrl!.isNotEmpty)
                                ? NetworkImage(post.authorAvatarUrl!)
                                : null,
                            child: (post.authorAvatarUrl == null ||
                                    post.authorAvatarUrl!.isEmpty)
                                ? Text(
                                    (post.authorName.isNotEmpty
                                            ? post.authorName[0]
                                            : '?')
                                        .toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  post.authorName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                if (post.content.isNotEmpty)
                                  Text(
                                    post.content,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black87,
                                    ),
                                  ),
                                if (post.imageUrl != null &&
                                    post.imageUrl!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        height: 80,
                                        color: Colors.grey[300],
                                        child: Image.network(
                                          post.imageUrl!,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, null),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 28,
                              vertical: 10,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(ctx, {
                              'visibility': visibility,
                              'content': controller.text,
                            });
                          },
                          child: const Text(
                            'Share',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showMoreBottomSheet({
    required BuildContext context,
    required PostCubit cubit,
    required PostEntity post,
    required bool isOwner,
  }) async {
    bool isBlocked = false;
    if (!isOwner) {
      try {
        final isBlockedUseCase = getIt<IsBlockedUseCase>();
        isBlocked = await isBlockedUseCase(post.authorId);
      } catch (_) {}
    }

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
                  : _buildOtherActions(ctx, post, isBlocked),
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
    bool isBlocked,
  ) {
    return [
      ListTile(
        leading: Icon(
          isBlocked ? Icons.undo : Icons.block,
          color: isBlocked ? Colors.blue : Colors.red,
        ),
        title: Text(
          isBlocked ? 'Unblock this author' : 'Block this author',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        onTap: () async {
          Navigator.pop(context);

          final blockUseCase = getIt<BlockUserUseCase>();
          final unblockUseCase = getIt<UnblockUserUseCase>();

          bool? confirm;

          if (isBlocked) {
            // ✅ confirm UNBLOCK
            confirm = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Unblock this author?'),
                content: Text('Do you want to unblock @${post.authorName}?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Unblock'),
                  ),
                ],
              ),
            );
          } else {
            // ✅ confirm BLOCK
            confirm = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Block this author?'),
                content: Text(
                  'Do you really want to block @${post.authorName}?\n'
                  'You will no longer see this user and their posts.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Block'),
                  ),
                ],
              ),
            );
          }

          if (confirm != true) return;

          bool ok;
          if (isBlocked) {
            ok = await unblockUseCase(post.authorId);
          } else {
            ok = await blockUseCase(post.authorId);
          }

          if (!context.mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                ok
                    ? (isBlocked
                        ? 'Đã bỏ chặn @${post.authorName}'
                        : 'Đã chặn @${post.authorName}')
                    : 'Thao tác thất bại, thử lại sau',
              ),
            ),
          );

          // 🔥 reload feed chung để tab này update
          if (ok) {
            context.read<PostCubit>().loadFeed();
          }
        },
      ),
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
