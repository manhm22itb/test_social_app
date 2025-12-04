import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../../../newpost/domain/entities/post_entity.dart';
import '../../../../../generated/colors.gen.dart';

class PostItem extends StatelessWidget {
  final PostEntity post;
  final VoidCallback onLikePressed;
  final VoidCallback onCommentPressed;
  final VoidCallback onRepostPressed;
  final VoidCallback onMorePressed;

  /// 🔥 Callback khi bấm vào avatar hoặc tên tác giả
  final VoidCallback onAuthorPressed;

  const PostItem({
    super.key,
    required this.post,
    required this.onLikePressed,
    required this.onCommentPressed,
    required this.onRepostPressed,
    required this.onMorePressed,
    required this.onAuthorPressed,
  });

  String get _timeLabel {
    final dt = post.createdAt;
    final time = DateFormat('h:mm a').format(dt);
    final date = DateFormat('MMM d, yyyy').format(dt);
    return '$time · $date';
  }

  // 🔥 Icon theo visibility
  Widget _buildVisibilityIcon(String visibility) {
    switch (visibility) {
      case "public":
        return const Icon(
          Icons.public,
          size: 12,
          color: Colors.grey,
        );

      case "private":
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
    return Container(
      color: ColorName.backgroundWhite,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Header: avatar + name + time + more ---
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar (clickable)
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

              // Name + visibility icon + time
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
                              post.authorName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                          ),

                          // 🔥 Icon thay đổi theo visibility
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

          // --- Content text ---
          if (post.content.isNotEmpty)
            Text(
              post.content,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),

          // --- Image (nếu có) ---
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

          // --- Action bar ---
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
                onPressed: () {},
              ),
            ],
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
