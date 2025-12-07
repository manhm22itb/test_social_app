import 'package:flutter/material.dart';

import '../../../home/presentation/models/post_data.dart';

class SearchResultsList extends StatelessWidget {
  final String searchQuery;

  const SearchResultsList({
    super.key,
    required this.searchQuery,
  });

  // Mock search results - In real app, this would come from API
  List<PostData> get _searchResults => [
        PostData(
          username: 'tech_guru',
          time: '2h',
          content:
              'Just built an amazing Flutter app with the new features! #Flutter #Dart',
          likes: 245,
          comments: 34,
          shares: 12,
          isLiked: false,
          isReposted: false,
          isPublic: true,
        ),
        PostData(
          username: 'flutter_dev',
          time: '4h',
          content:
              'Anyone else excited about the Flutter 3.0 release? The performance improvements are incredible!',
          likes: 567,
          comments: 89,
          shares: 45,
          isLiked: true,
          isReposted: false,
          isPublic: true,
        ),
        PostData(
          username: 'coding_wizard',
          time: '6h',
          content:
              'Working on a new social media app with Flutter. The hot reload feature is a game-changer!',
          likes: 123,
          comments: 23,
          shares: 8,
          isLiked: false,
          isReposted: true,
          isPublic: true,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    if (searchQuery.isEmpty) {
      return const Center(
        child: Text('Enter a search term to see results'),
      );
    }

    // Tạm thời không filter theo searchQuery, vì đang mock
    // Sau này dùng API thật thì lọc theo searchQuery ở đây
    final results = _searchResults;

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: results.length,
      itemBuilder: (context, index) {
        final post = results[index];
        return _SearchPostItem(post: post);
      },
    );
  }
}

class _SearchPostItem extends StatelessWidget {
  final PostData post;

  const _SearchPostItem({required this.post});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.grey.shade300,
        child: Text(
          post.username.isNotEmpty ? post.username[0].toUpperCase() : '?',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              post.username,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            post.time,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(
          post.content,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      onTap: () {
        // TODO: mở chi tiết post từ search nếu cần
      },
    );
  }
}
