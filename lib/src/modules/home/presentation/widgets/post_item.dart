import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../../../newpost/domain/entities/post_entity.dart';
import '../../../../../generated/colors.gen.dart';

class PostItem extends StatelessWidget {
  final PostEntity post;

  final PostEntity? originalPost;

  final VoidCallback onLikePressed;
  final VoidCallback onCommentPressed;
  final VoidCallback onRepostPressed;
  final VoidCallback onMorePressed;
  final VoidCallback onSharePressed;

  final VoidCallback onAuthorPressed;

  final VoidCallback? onOriginalAuthorPressed;

  const PostItem({
    super.key,
    required this.post,
    this.originalPost,
    required this.onLikePressed,
    required this.onCommentPressed,
    required this.onRepostPressed,
    required this.onMorePressed,
    required this.onSharePressed,
    required this.onAuthorPressed,
    this.onOriginalAuthorPressed,
  });

  String get _timeLabel {
    final dt = post.createdAt;
    final time = DateFormat('h:mm a').format(dt);
    final date = DateFormat('MMM d, yyyy').format(dt);
    return '$time · $date';
  }

  Widget _buildVisibilityIcon(String visibility) {
    switch (visibility) {
      case 'public':
        return const Icon(
          Icons.public,
          size: 12,
          color: Colors.grey,
        );
      case 'private':
      default:
        return const Icon(
          Icons.lock,
          size: 12,
          color: Colors.grey,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isShared = post.type == 'shared' && originalPost != null;

    return Container(
      color: ColorName.backgroundWhite,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: onAuthorPressed,
                borderRadius: BorderRadius.circular(100),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: ColorName.grey,
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
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: onAuthorPressed,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              isShared
                                  ? '${post.authorName} shared a post'
                                  : post.authorName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          _buildVisibilityIcon(post.visibility),
                          const SizedBox(width: 4),
                          Text(
                            _timeLabel,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.more_horiz,
                  size: 20,
                  color: Colors.grey,
                ),
                onPressed: onMorePressed,
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (post.content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                post.content,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ),
          if (isShared && originalPost != null)
            _SharedPostCard(
              originalPost: originalPost!,
              onHeaderTap: onOriginalAuthorPressed,
            ),
          if (post.imageUrl != null && post.imageUrl!.isNotEmpty) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                post.imageUrl!,
                fit: BoxFit.fitWidth,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _ActionIcon(
                icon: FontAwesomeIcons.comment,
                count: post.commentCount ?? 0,
                onTap: onCommentPressed,
              ),
              _ActionIcon(
                icon: FontAwesomeIcons.retweet,
                count: 0,
                onTap: onRepostPressed,
              ),
              _ActionIcon(
                icon: post.isLiked
                    ? FontAwesomeIcons.solidHeart
                    : FontAwesomeIcons.heart,
                count: post.likeCount,
                onTap: onLikePressed,
                active: post.isLiked,
              ),
              IconButton(
                icon: const FaIcon(
                  FontAwesomeIcons.arrowUpFromBracket,
                  size: 16,
                  color: Colors.grey,
                ),
                onPressed: onSharePressed,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SharedPostCard extends StatelessWidget {
  final PostEntity originalPost;
  final VoidCallback? onHeaderTap;

  const _SharedPostCard({
    required this.originalPost,
    this.onHeaderTap,
  });

  String get _timeLabel {
    final dt = originalPost.createdAt;
    final time = DateFormat('h:mm a').format(dt);
    final date = DateFormat('MMM d, yyyy').format(dt);
    return '$time · $date';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 👉 NHẤN VÀO ĐÂY ĐỂ ĐI PROFILE CỦA USER GỐC
          InkWell(
            onTap: onHeaderTap,
            borderRadius: BorderRadius.circular(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.grey.shade400,
                  backgroundImage: (originalPost.authorAvatarUrl != null &&
                          originalPost.authorAvatarUrl!.isNotEmpty)
                      ? NetworkImage(originalPost.authorAvatarUrl!)
                      : null,
                  child: (originalPost.authorAvatarUrl == null ||
                          originalPost.authorAvatarUrl!.isEmpty)
                      ? Text(
                          (originalPost.authorName.isNotEmpty
                                  ? originalPost.authorName[0]
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
                        originalPost.authorName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _timeLabel,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (originalPost.content.isNotEmpty)
            Text(
              originalPost.content,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          if (originalPost.imageUrl != null &&
              originalPost.imageUrl!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  originalPost.imageUrl!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final int count;
  final VoidCallback onTap;
  final bool active;

  const _ActionIcon({
    required this.icon,
    required this.count,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? Colors.red : Colors.grey;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Row(
        children: [
          FaIcon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
