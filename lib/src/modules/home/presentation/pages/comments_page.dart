import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/post_data.dart';
import '../models/comment_data.dart';
import '../widgets/comment_button.dart';
import '../widgets/repost_button.dart';
import '../widgets/like_button.dart';
import '../widgets/action_button.dart';
import '../widgets/comment_item.dart';

import '../../../../../generated/colors.gen.dart';

class CommentsPage extends StatefulWidget {
  final PostData post;
  final VoidCallback onLikePressed;

  const CommentsPage({
    super.key,
    required this.post,
    required this.onLikePressed,
  });

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  final List<CommentData> _comments = [
    CommentData(
      username: 'user1',
      time: '2h',
      content: 'Great post! I totally agree with this.',
      likes: 5,
      isLiked: false,
    ),
    CommentData(
      username: 'user2',
      time: '1h',
      content: 'Thanks for sharing this information!',
      likes: 3,
      isLiked: true,
    ),
    CommentData(
      username: 'user3',
      time: '30m',
      content: 'This is very helpful, thank you!',
      likes: 1,
      isLiked: false,
    ),
  ];

  void _toggleCommentLike(int index) {
    setState(() {
      _comments[index] = _comments[index].copyWith(
        isLiked: !_comments[index].isLiked,
        likes: _comments[index].isLiked 
            ? _comments[index].likes - 1 
            : _comments[index].likes + 1,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorName.backgroundWhite,
        elevation: 1,
        title: const Text(
          'Comments',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Original Post
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ColorName.backgroundWhite,
              border: Border(
                bottom: BorderSide(color: ColorName.borderLight, width: 0.5),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: ColorName.primaryBlue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      widget.post.username[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
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
                            widget.post.username,
                            style: TextStyle(
                              color: ColorName.textBlack,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(width: 4),
                          
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.post.content,
                        style: TextStyle(
                          color: ColorName.textBlack,
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CommentButton(
                            commentCount: widget.post.comments,
                            onPressed: () {},
                          ),
                          RepostButton(
                            isReposted: widget.post.isReposted,
                            repostCount: widget.post.shares,
                            onPressed: () {},
                          ),
                          LikeButton(
                            isLiked: widget.post.isLiked,
                            likeCount: widget.post.likes,
                            onPressed: widget.onLikePressed,
                          ),
                          ActionButton(
                            icon: FontAwesomeIcons.share,
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Comments List
          Expanded(
            child: ListView(
              children: [
                for (int i = 0; i < _comments.length; i++)
                  CommentItem(
                    comment: _comments[i],
                    onLikePressed: () => _toggleCommentLike(i),
                  ),
              ],
            ),
          ),
          // Add Comment Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ColorName.backgroundWhite,
              border: Border(
                top: BorderSide(color: ColorName.borderLight, width: 0.5),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Write a comment...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: Color(0xFF1D9BF0)),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.paperPlane, color: Color(0xFF1D9BF0)),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}