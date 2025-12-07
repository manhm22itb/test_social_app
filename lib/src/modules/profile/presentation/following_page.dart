// lib/src/modules/profile/presentation/following_page.dart

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../generated/colors.gen.dart';
import '../../app/app_router.dart';

class FollowingUserModel {
  final String id;
  final String username;
  final String email;
  final String? avatarUrl;
  final String? bio;

  FollowingUserModel({
    required this.id,
    required this.username,
    required this.email,
    this.avatarUrl,
    this.bio,
  });
}

@RoutePage()
class FollowingPage extends StatefulWidget {
  /// ID của profile đang được xem (có thể là mình, có thể là user khác)
  final String userId;

  const FollowingPage({
    super.key,
    required this.userId,
  });

  @override
  State<FollowingPage> createState() => _FollowingPageState();
}

class _FollowingPageState extends State<FollowingPage> {
  late Future<void> _future;
  final List<FollowingUserModel> _users = [];
  Set<String> _followingIds = {};
  bool _hasChanged = false;

  bool get _isOwnProfile {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    return currentUserId != null && currentUserId == widget.userId;
  }

  @override
  void initState() {
    super.initState();
    _future = _loadFollowing();
  }

  /// 🔹 Load những người mà widget.userId đang follow
  Future<void> _loadFollowing() async {
    final client = Supabase.instance.client;

    // user mà ta muốn xem following của họ (có thể là mình, có thể là người khác)
    final followerId = widget.userId;

    try {
      final followsRes = await client
          .from('follows')
          .select('following_id')
          .eq('follower_id', followerId);

      final List data = (followsRes as List?) ?? [];
      if (data.isEmpty) {
        setState(() {
          _users.clear();
          _followingIds.clear();
        });
        return;
      }

      final followingIds = data
          .map((e) => e['following_id'] as String)
          .where((id) => id.isNotEmpty)
          .toList();

      final futures = followingIds.map((id) async {
        final row = await client
            .from('profiles')
            .select('id, username, email, avatar_url, bio')
            .eq('id', id)
            .maybeSingle();

        if (row == null) return null;

        return FollowingUserModel(
          id: row['id'] as String,
          username: (row['username'] as String?) ?? '',
          email: (row['email'] as String?) ?? '',
          avatarUrl: row['avatar_url'] as String?,
          bio: row['bio'] as String?,
        );
      }).toList();

      final results = await Future.wait(futures);
      final users = results.whereType<FollowingUserModel>().toList();

      setState(() {
        _users
          ..clear()
          ..addAll(users);
        _followingIds = users.map((u) => u.id).toSet();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load following: $e')),
      );
    }
  }

  /// 🔥 Unfollow – chỉ cho phép khi đang xem profile của CHÍNH MÌNH
  Future<void> _toggleFollow(String targetUserId) async {
    if (!_isOwnProfile) return; // không cho unfollow hộ người khác

    final client = Supabase.instance.client;
    final currentUserId = client.auth.currentUser?.id;
    if (currentUserId == null || currentUserId == targetUserId) return;

    try {
      final before = await client
          .from('follows')
          .select('follower_id, following_id')
          .eq('follower_id', currentUserId)
          .eq('following_id', targetUserId);

      print('>>> [FollowingPage] BEFORE toggle: $before');

      final isFollowing = (before as List).isNotEmpty;
      if (!isFollowing) return;

      final deleteRes = await client
          .from('follows')
          .delete()
          .eq('follower_id', currentUserId)
          .eq('following_id', targetUserId);

      print('>>> [FollowingPage] DELETE result: $deleteRes');

      final after = await client
          .from('follows')
          .select('follower_id, following_id')
          .eq('follower_id', currentUserId)
          .eq('following_id', targetUserId);

      print('>>> [FollowingPage] AFTER delete: $after');

      if ((after as List).isEmpty) {
        if (!mounted) return;
        setState(() {
          _followingIds.remove(targetUserId);
          _users.removeWhere((u) => u.id == targetUserId);
          _hasChanged = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unfollowed')),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unfollow failed on server')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      print('>>> [FollowingPage] toggleFollow ERROR: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final client = Supabase.instance.client;
    final currentUserId = client.auth.currentUser?.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Following'),
        backgroundColor: ColorName.mint,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.router.pop(_hasChanged),
        ),
      ),
      body: FutureBuilder<void>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting &&
              _users.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snap.hasError) {
            return Center(
              child: Text('Error: ${snap.error}'),
            );
          }

          if (_users.isEmpty) {
            return const Center(
              child: Text('No following yet'),
            );
          }

          return ListView.separated(
            itemCount: _users.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final u = _users[index];
              final isMe = currentUserId == u.id;
              final isFollowing = _followingIds.contains(u.id);

              return ListTile(
                leading: GestureDetector(
                  onTap: () => context.router.push(
                    UserProfileRoute(userId: u.id),
                  ),
                  child: CircleAvatar(
                    backgroundColor: Colors.grey[300],
                    backgroundImage:
                        (u.avatarUrl != null && u.avatarUrl!.isNotEmpty)
                            ? NetworkImage(u.avatarUrl!)
                            : null,
                    child: (u.avatarUrl == null || u.avatarUrl!.isEmpty)
                        ? Text(
                            u.username.isNotEmpty
                                ? u.username[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                ),
                title: GestureDetector(
                  onTap: () => context.router.push(
                    UserProfileRoute(userId: u.id),
                  ),
                  child: Text(u.username),
                ),
                subtitle: Text(
                  u.bio?.isNotEmpty == true ? u.bio! : u.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                // 👉 chỉ hiện Unfollow nếu:
                // - đang xem profile của chính mình (_isOwnProfile)
                // - có currentUserId
                // - không phải bản thân mình
                trailing: (!_isOwnProfile || currentUserId == null || isMe)
                    ? null
                    : TextButton(
                        onPressed: () => _toggleFollow(u.id),
                        child: Text(isFollowing ? 'Unfollow' : 'Follow'),
                      ),
              );
            },
          );
        },
      ),
    );
  }
}
