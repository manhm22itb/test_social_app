class PostData {
  final String username;
  final String time;
  final String content;
  final int likes;
  final int comments;
  final int shares;
  final bool isLiked;
  final bool isReposted;
  final bool isPublic;
  final bool showThread;

  const PostData({
    required this.username,
    required this.time,
    required this.content,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.isLiked,
    required this.isReposted,
    required this.isPublic,
    this.showThread = false,
  });

  PostData copyWith({
    String? username,
    String? time,
    String? content,
    int? likes,
    int? comments,
    int? shares,
    bool? isLiked,
    bool? isReposted,
    bool? isPublic,
    bool? showThread,
  }) {
    return PostData(
      username: username ?? this.username,
      time: time ?? this.time,
      content: content ?? this.content,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      shares: shares ?? this.shares,
      isLiked: isLiked ?? this.isLiked,
      isReposted: isReposted ?? this.isReposted,
      isPublic: isPublic ?? this.isPublic,
      showThread: showThread ?? this.showThread,
    );
  }
}
