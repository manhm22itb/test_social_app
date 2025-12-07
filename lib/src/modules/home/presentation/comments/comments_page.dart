import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../generated/colors.gen.dart';
import '../../../newpost/domain/entities/post_entity.dart';
import '../../../../common/utils/getit_utils.dart';
import '../cubit/comment_cubit.dart';
import '../../domain/entities/comment_entity.dart';
import '../../../../core/error/failures.dart';
import '../cubit/comment_state.dart';

@RoutePage()
class CommentPage extends StatefulWidget {
  final PostEntity post;

  const CommentPage({super.key, required this.post});

  @override
  State<CommentPage> createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  final TextEditingController _commentController = TextEditingController();
  late final CommentCubit _commentCubit;
  CommentEntity? _replyingTo;
  String _replyIndicator = '';
  String? _currentUserId;
  bool _showDailyLimitError = false;

  String? _expandedCommentId;
  Map<String, List<CommentEntity>> _commentReplies = {};
  Map<String, bool> _loadingReplies = {};

  @override
  void initState() {
    super.initState();
    _commentCubit = getIt<CommentCubit>();
    _commentCubit.loadComments(widget.post.id);
    _getCurrentUserId();
  }

  void _getCurrentUserId() {
    final user = Supabase.instance.client.auth.currentUser;
    setState(() {
      _currentUserId = user?.id;
    });
  }

  @override
  void dispose() {
    _commentCubit.close();
    super.dispose();
  }

  bool _isCurrentUserComment(CommentEntity comment) {
    return comment.userId == _currentUserId;
  }

  void _postComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    setState(() {
      _showDailyLimitError = false;
    });

    try {
      if (_replyingTo != null) {
        await _commentCubit.createComment(
          widget.post.id,
          content,
          parentId: _replyingTo!.id,
        );

        if (_expandedCommentId == _replyingTo!.id) {
          await _loadCommentReplies(_replyingTo!.id);
        }

      } else {
        await _commentCubit.createComment(widget.post.id, content);
      }

      _commentController.clear();
      _clearReply();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Comment posted!'),
          backgroundColor: ColorName.mint,
        ),
      );

      _commentCubit.loadComments(widget.post.id);
    } on DailyLimitException catch (e) {
      setState(() {
        _showDailyLimitError = true;
      });

      // Hiển thị snackbar thông báo
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    FontAwesomeIcons.circleExclamation,
                    size: 16,
                    color: Colors.orange.shade100,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Daily Limit Reached',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(e.message, style: const TextStyle(fontSize: 12)),
            ],
          ),
          backgroundColor: Colors.orange.shade700,
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to post comment: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  Future<void> _loadCommentReplies(String commentId) async {
    if (_loadingReplies[commentId] == true) return;

    setState(() {
      _loadingReplies[commentId] = true;
    });

    try {
      // 🔥 LẤY REPLIES TỪ FIELD CÓ SẴN TRONG COMMENT
      final allComments = _commentCubit.state is CommentStateLoaded
          ? (_commentCubit.state as CommentStateLoaded).comments
          : [];

      // Tìm comment chính
      final parentComment = allComments.firstWhere(
        (comment) => comment.id == commentId,
        orElse: () => CommentEntity(
          id: '',
          postId: '',
          userId: '',
          content: '',
          authorName: '',
          createdAt: DateTime.now(),
          replies: [],
        ),
      );

      setState(() {
        _commentReplies[commentId] = parentComment.replies;
        _loadingReplies[commentId] = false;
      });
    } catch (e) {
      setState(() {
        _loadingReplies[commentId] = false;
      });
      print('>>> Error loading replies: $e');
    }
  }

  //  TOGGLE HIỂN THỊ REPLIES
  void _toggleCommentReplies(String commentId) {
    setState(() {
      _expandedCommentId = _expandedCommentId == commentId ? null : commentId;
    });
  }

  void _startReply(CommentEntity comment) {
    setState(() {
      _replyingTo = comment;
      // _replyIndicator = 'Replying to @${comment.authorName}';
    });

    _commentController.text = '@${comment.authorName} ';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(FocusNode());
    });
  }

  void _clearReply() {
    setState(() {
      _replyingTo = null;
      _replyIndicator = '';
    });
    _commentController.clear();
  }

  void _showEditDialog(CommentEntity comment) {
    final controller = TextEditingController(text: comment.content);

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Comment',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: ColorName.textBlack,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Edit your comment...',
                    hintStyle: TextStyle(color: ColorName.grey500),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: ColorName.greyE5e7eb),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: ColorName.mint),
                    ),
                    filled: true,
                    fillColor: ColorName.backgroundWhite,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: ColorName.grey600),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () async {
                        final newContent = controller.text.trim();
                        if (newContent.isEmpty ||
                            newContent == comment.content) {
                          Navigator.pop(context);
                          return;
                        }

                        try {
                          await _commentCubit.updateComment(
                            comment.id,
                            newContent,
                          );
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Comment updated!'),
                              backgroundColor: ColorName.mint,
                            ),
                          );
                        } catch (e) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to update: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorName.mint,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteDialog(CommentEntity comment) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  FontAwesomeIcons.trashCan,
                  size: 48,
                  color: Colors.red.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'Delete Comment',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: ColorName.textBlack,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Are you sure you want to delete this comment? This action cannot be undone.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: ColorName.grey600),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: ColorName.greyE5e7eb),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: ColorName.grey700),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            await _commentCubit.deleteComment(comment.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Comment deleted'),
                                backgroundColor: ColorName.mint,
                              ),
                            );

                            Navigator.pop(context);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to delete: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade400,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Delete'),
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
  }

  Widget _buildDailyLimitError() {
    if (!_showDailyLimitError) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.orange.shade200, width: 1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            FontAwesomeIcons.circleExclamation,
            size: 20,
            color: Colors.orange.shade700,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Comment Limit Reached',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.orange.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'You have reached your daily comment limit (3 comments per day). Please try again tomorrow.',
                  style: TextStyle(fontSize: 13, color: Colors.orange.shade700),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              FontAwesomeIcons.xmark,
              size: 16,
              color: Colors.orange.shade600,
            ),
            onPressed: () {
              setState(() {
                _showDailyLimitError = false;
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CommentCubit>.value(
      value: _commentCubit,
      child: Scaffold(
        backgroundColor: ColorName.backgroundWhite,
        appBar: AppBar(
          backgroundColor: ColorName.backgroundWhite,
          elevation: 0.5,
          leading: IconButton(
            icon: Icon(
              FontAwesomeIcons.chevronLeft,
              size: 18,
              color: ColorName.textBlack,
            ),
            onPressed: () => context.router.pop(),
          ),
          title: Text(
            'Comments',
            style: TextStyle(
              color: ColorName.textBlack,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: false,
        ),
        body: Column(
          children: [
            _buildPostCard(),

            // 🔥 THÊM THÔNG BÁO DAILY LIMIT Ở ĐÂY
            _buildDailyLimitError(),

            if (_replyingTo != null) _buildReplyIndicator(),

            Expanded(
              child: BlocBuilder<CommentCubit, CommentState>(
                builder: (context, state) {
                  if (state is CommentStateLoaded && mounted) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      final repliesMap = <String, List<CommentEntity>>{};
                      for (final comment in state.comments) {
                        if (comment.replies.isNotEmpty) {
                          repliesMap[comment.id] = comment.replies;
                        }
                      }
                      
                      // Chỉ update nếu có thay đổi
                      if (_commentReplies.length != repliesMap.length) {
                        setState(() {
                          _commentReplies = repliesMap;
                        });
                      }
                    });
                  }

                  return _buildCommentsList(state);
                },
              ),
            ),

            _buildCommentInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard() {
    return Container(
      decoration: BoxDecoration(
        color: ColorName.backgroundWhite,
        border: Border(
          bottom: BorderSide(color: ColorName.borderLight, width: 1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildUserAvatar(
                  avatarUrl: widget.post.authorAvatarUrl,
                  username: widget.post.authorName,
                  size: 40,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.post.authorName,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: ColorName.textBlack,
                        ),
                      ),
                      Text(
                        _formatTime(widget.post.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: ColorName.textLightGray,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Text(
              widget.post.content,
              style: TextStyle(
                fontSize: 15,
                height: 1.4,
                color: ColorName.textBlack,
              ),
            ),

            if (widget.post.imageUrl != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  widget.post.imageUrl!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReplyIndicator() {
    return Container(
      // padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      // decoration: BoxDecoration(
      //   color: ColorName.mint.withOpacity(0.08),
      //   border: Border(
      //     bottom: BorderSide(color: ColorName.mint.withOpacity(0.2)),
      //   ),
      // ),
      // child: Row(
      //   children: [
      //     Icon(FontAwesomeIcons.reply, size: 14, color: ColorName.mint),
      //     const SizedBox(width: 8),
      //     Expanded(
      //       child: Text(
      //         _replyIndicator,
      //         style: TextStyle(
      //           color: ColorName.mint,
      //           fontSize: 13,
      //           fontWeight: FontWeight.w500,
      //         ),
      //       ),
      //     ),
      //     GestureDetector(

      //     ),
      //   ],
      // ),
    );
  }

  Widget _buildCommentsList(CommentState state) {
    if (state is CommentStateLoading) {
      return Center(child: CircularProgressIndicator(color: ColorName.mint));
    }

    if (state is CommentStateError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FontAwesomeIcons.circleExclamation,
              size: 48,
              color: ColorName.grey500,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 16,
                color: ColorName.textBlack,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: TextStyle(color: ColorName.grey600),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _commentCubit.loadComments(widget.post.id),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorName.mint,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (state is CommentStateLoaded) {
      final comments = state.comments;

      if (comments.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                FontAwesomeIcons.commentDots,
                size: 56,
                color: ColorName.greyE5e7eb,
              ),
              const SizedBox(height: 16),
              Text(
                'No comments yet',
                style: TextStyle(
                  fontSize: 17,
                  color: ColorName.textBlack,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Be the first to comment on this post!',
                style: TextStyle(color: ColorName.textLightGray),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        color: ColorName.mint,
        onRefresh: () async {
          await _commentCubit.loadComments(widget.post.id);
        },
        child: ListView.separated(
          padding: const EdgeInsets.only(top: 8),
          itemCount: comments.length,
          separatorBuilder: (context, index) =>
              Divider(height: 1, color: ColorName.borderLight, indent: 72),
          itemBuilder: (context, index) {
            final comment = comments[index];
            return _buildCommentItem(comment);
          },
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildUserAvatar({
    required String? avatarUrl,
    required String username,
    double size = 36,
  }) {
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: ColorName.greyE5e7eb, width: 1.5),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(size / 2),
          child: Image.network(
            avatarUrl,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildAvatarFallback(username, size);
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return _buildAvatarFallback(username, size);
            },
          ),
        ),
      );
    }

    return _buildAvatarFallback(username, size);
  }

  Widget _buildAvatarFallback(String username, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: ColorName.mint, shape: BoxShape.circle),
      child: Center(
        child: Text(
          username.isNotEmpty ? username[0].toUpperCase() : 'U',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: size * 0.35,
          ),
        ),
      ),
    );
  }

  Widget _buildCommentItem(CommentEntity comment) {
    final isCurrentUser = _isCurrentUserComment(comment);
    final isReply = comment.parentId != null;
    final isExpanded = _expandedCommentId == comment.id;
    final hasReplies = comment.replyCount > 0;
    final replies = isExpanded ? comment.replies : [];

    return Container(
      padding: EdgeInsets.only(
        left: isReply ? 48.0 : 16.0,
        right: 16.0,
        top: 12,
        bottom: 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isReply) ...[
                Icon(
                  FontAwesomeIcons.reply,
                  size: 12,
                  color: ColorName.grey500,
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildUserAvatar(
                          avatarUrl: comment.authorAvatarUrl,
                          username: comment.authorName,
                          size: 36,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    comment.authorName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: ColorName.textBlack,
                                    ),
                                  ),
                                  if (isCurrentUser) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: ColorName.mint.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'You',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: ColorName.mint,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              Text(
                                _formatTime(comment.createdAt),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: ColorName.textLightGray,
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: Icon(
                            FontAwesomeIcons.ellipsisVertical,
                            size: 14,
                            color: ColorName.grey500,
                          ),
                          position: PopupMenuPosition.under,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          surfaceTintColor: ColorName.backgroundWhite,
                          itemBuilder: (context) => [
                            if (isCurrentUser) ...[
                              PopupMenuItem<String>(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(
                                      FontAwesomeIcons.penToSquare,
                                      size: 14,
                                      color: ColorName.grey700,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Edit',
                                      style: TextStyle(
                                        color: ColorName.textBlack,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuItem<String>(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(
                                      FontAwesomeIcons.trashCan,
                                      size: 14,
                                      color: Colors.red.shade400,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Delete',
                                      style: TextStyle(
                                        color: Colors.red.shade400,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                          onSelected: (value) {
                            switch (value) {
                              case 'edit':
                                _showEditDialog(comment);
                                break;
                              case 'delete':
                                _showDeleteDialog(comment);
                                break;
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      comment.content,
                      style: TextStyle(
                        fontSize: 14,
                        color: ColorName.textBlack,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        // REPLY BUTTON
                        GestureDetector(
                          onTap: () => _startReply(comment),
                          child: Row(
                            children: [
                              Icon(
                                FontAwesomeIcons.reply,
                                size: 12,
                                color: ColorName.grey600,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Reply',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: ColorName.grey600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),

                        //COMMENT COUNT ICON
                          if (hasReplies)
                            GestureDetector(
                              onTap: () => _toggleCommentReplies(comment.id),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isExpanded
                                      ? ColorName.mint.withOpacity(0.1)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isExpanded
                                        ? ColorName.mint
                                        : ColorName.greyE5e7eb,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isExpanded
                                          ? FontAwesomeIcons.comments
                                          : FontAwesomeIcons.comment,
                                      size: 11,
                                      color: isExpanded
                                          ? ColorName.mint
                                          : ColorName.grey600,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${comment.replyCount}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isExpanded
                                            ? ColorName.mint
                                            : ColorName.grey600,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (isExpanded) ...[
                                      const SizedBox(width: 4),
                                      Icon(
                                        _loadingReplies[comment.id] == true
                                            ? FontAwesomeIcons.spinner
                                            : FontAwesomeIcons.chevronUp,
                                        size: 10,
                                        color: ColorName.mint,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

          //  HIỂN THỊ REPLIES NẾU ĐANG MỞ
          if (isExpanded && comment.replies.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildRepliesSection(comment, comment.replies),
          ],
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    final currentUser = Supabase.instance.client.auth.currentUser;
    final currentUserName = currentUser?.email?.split('@').first ?? 'User';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColorName.backgroundWhite,
        border: Border(top: BorderSide(color: ColorName.borderLight, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_replyingTo != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: ColorName.backgroundLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(FontAwesomeIcons.reply, size: 12, color: ColorName.mint),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Replying to @${_replyingTo!.authorName}',
                      style: TextStyle(
                        fontSize: 11,
                        color: ColorName.mint,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _clearReply,
                    child: Icon(
                      FontAwesomeIcons.xmark,
                      size: 12,
                      color: ColorName.grey600,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // _buildUserAvatar(
              //   avatarUrl: null,
              //   username: currentUserName,
              //   size: 40,
              // ),
              // const SizedBox(width: 12),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: ColorName.backgroundLight,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: ColorName.greyE5e7eb),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          maxLines: null,
                          minLines: 1,
                          maxLength: 450,
                          decoration: InputDecoration(
                            hintText: _replyingTo != null
                                ? 'Write your reply...'
                                : 'Write a comment...',
                            hintStyle: TextStyle(
                              color: ColorName.textLightGray,
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            counterText: '',
                          ),
                          style: TextStyle(
                            fontSize: 14,
                            color: ColorName.textBlack,
                          ),
                          onChanged: (text) {
                            setState(() {});
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _commentController.text.trim().isNotEmpty
                                ? ColorName.mint
                                : ColorName.greyE5e7eb,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(
                              FontAwesomeIcons.paperPlane,
                              size: 16,
                              color: _commentController.text.trim().isNotEmpty
                                  ? Colors.white
                                  : ColorName.grey500,
                            ),
                            onPressed: _commentController.text.trim().isNotEmpty
                                ? _postComment
                                : null,
                            padding: const EdgeInsets.all(8),
                            constraints: const BoxConstraints(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // METHOD HIỂN THỊ REPLIES
  Widget _buildRepliesSection(
    CommentEntity parentComment,
    List<CommentEntity> replies,
  ) {
    if (_loadingReplies[parentComment.id] == true) {
      return Padding(
        padding: const EdgeInsets.only(left: 48),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: ColorName.mint,
            ),
          ),
        ),
      );
    }

    if (replies.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(left: 48),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: ColorName.backgroundLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                FontAwesomeIcons.commentSlash,
                size: 14,
                color: ColorName.grey500,
              ),
              const SizedBox(width: 8),
              Text(
                'No replies yet. Be the first to reply!',
                style: TextStyle(fontSize: 12, color: ColorName.grey600),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        for (final reply in replies)
          Container(
            margin: const EdgeInsets.only(bottom: 8, left: 48),
            child: _buildReplyItem(reply),
          ),
      ],
    );
  }

  // METHOD HIỂN THỊ REPLY ITEM
  Widget _buildReplyItem(CommentEntity reply) {
    final isCurrentUser = _isCurrentUserComment(reply);

    return Container(
      decoration: BoxDecoration(
        color: ColorName.backgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorName.greyE5e7eb, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUserAvatar(
                  avatarUrl: reply.authorAvatarUrl,
                  username: reply.authorName,
                  size: 28,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            reply.authorName,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: ColorName.textBlack,
                            ),
                          ),
                          if (isCurrentUser) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: ColorName.mint.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Text(
                                'You',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: ColorName.mint,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(width: 6),
                          Text(
                            _formatTime(reply.createdAt),
                            style: TextStyle(
                              fontSize: 10,
                              color: ColorName.textLightGray,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        reply.content,
                        style: TextStyle(
                          fontSize: 13,
                          color: ColorName.textBlack,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(
                    FontAwesomeIcons.ellipsisVertical,
                    size: 12,
                    color: ColorName.grey500,
                  ),
                  position: PopupMenuPosition.under,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  surfaceTintColor: ColorName.backgroundWhite,
                  itemBuilder: (context) => [
                    if (isCurrentUser) ...[
                      PopupMenuItem<String>(
                        value: 'edit_reply',
                        child: Row(
                          children: [
                            Icon(
                              FontAwesomeIcons.penToSquare,
                              size: 12,
                              color: ColorName.grey700,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Edit',
                              style: TextStyle(
                                color: ColorName.textBlack,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'delete_reply',
                        child: Row(
                          children: [
                            Icon(
                              FontAwesomeIcons.trashCan,
                              size: 12,
                              color: Colors.red.shade400,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Delete',
                              style: TextStyle(
                                color: Colors.red.shade400,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                  onSelected: (value) {
                    switch (value) {
                      case 'edit_reply':
                        _showEditDialog(reply);
                        break;
                      case 'delete_reply':
                        _showDeleteDialog(reply);
                        break;
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _startReply(reply),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    FontAwesomeIcons.reply,
                    size: 11,
                    color: ColorName.grey600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Reply',
                    style: TextStyle(
                      fontSize: 11,
                      color: ColorName.grey600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';

    final formatter = DateFormat('MMM d');
    return formatter.format(dateTime);
  }
}
