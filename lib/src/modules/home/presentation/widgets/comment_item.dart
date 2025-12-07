import 'package:flutter/material.dart';

import '../../../../../generated/colors.gen.dart';

import '../models/comment_data.dart';
import 'like_button.dart';

class CommentItem extends StatelessWidget {
  final CommentData comment;
  final VoidCallback onLikePressed;

  const CommentItem({
    super.key,
    required this.comment,
    required this.onLikePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E5E5), width: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: ColorName.mint,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                comment.username[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.username,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 4),
                    
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.content,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    LikeButton(
                      isLiked: comment.isLiked,
                      likeCount: comment.likes,
                      onPressed: onLikePressed,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}