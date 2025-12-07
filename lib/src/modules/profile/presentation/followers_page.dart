import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../generated/colors.gen.dart';
import '../../../common/utils/getit_utils.dart';
import '../../app/app_router.dart';

class FollowerUserModel {
  final String id;
  final String username;
  final String email;
  final String? avatarUrl;
  final String? bio;

  FollowerUserModel({
    required this.id,
    required this.username,
    required this.email,
    this.avatarUrl,
    this.bio,
  });
}

@RoutePage()
class FollowersPage extends StatefulWidget {
  /// userId của profile đang xem (có thể là current user hoặc user khác)
  final String userId;

  const FollowersPage({
    super.key,
    required this.userId,
  });

  @override
  State<FollowersPage> createState() => _FollowersPageState();
}

class _FollowersPageState extends State<FollowersPage> {
  late Future<void> _future;

  final List<FollowerUserModel> _users = [];
  bool _hasChanged = false;

  bool get _isOwnProfile {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    return currentUserId != null && currentUserId == widget.userId;
  }

  @override
  void initState() {
    super.initState();
    _future = _loadFollowers();
  }

  /// 🔹 Lấy danh sách những người đang FOLLOW widget.userId
  ///
  /// Gọi backend:
  ///   GET /users/{user_id}/followers
  Future<void> _loadFollowers() async {
    final supa = Supabase.instance.client;

    // lấy accessToken để gọi backend
    final session = supa.auth.currentSession;
    final accessToken = session?.accessToken;

    if (accessToken == null) {
      setState(() {
        _users.clear();
      });
      return;
    }

    final dio = getIt<Dio>();

    try {
      final res = await dio.get(
        '/users/${widget.userId}/followers',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      final data = res.data as Map<String, dynamic>;
      final List followsJson = (data['follows'] as List?) ?? [];

      final List<FollowerUserModel> followers = [];

      for (final item in followsJson) {
        final map = item as Map<String, dynamic>;

        final followerId = map['follower_id'] as String?;
        if (followerId == null) continue;

        final followerUsername = map['follower_username'] as String?;
        final followerAvatar = map['follower_avatar'] as String?;

        followers.add(
          FollowerUserModel(
            id: followerId,
            username: followerUsername ?? '',
            email: followerUsername ?? '',
            avatarUrl: followerAvatar,
            bio: '', // sau này backend trả thêm bio thì map vào
          ),
        );
      }

      if (!mounted) return;
      setState(() {
        _users
          ..clear()
          ..addAll(followers);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _users.clear();
      });
      debugPrint('Load followers error: $e');
    }
  }

  /// 🔥 Remove follower:
  ///   - Người có id = followerId sẽ KHÔNG còn follow mình nữa
  ///   - Gọi backend:
  ///       DELETE /users/me/followers/{follower_id}
  Future<void> _removeFollower(String followerId) async {
    // chỉ cho remove khi đang xem profile của CHÍNH MÌNH
    if (!_isOwnProfile) return;

    final supa = Supabase.instance.client;

    final currentUserId = supa.auth.currentUser?.id;
    if (currentUserId == null) return;

    final session = supa.auth.currentSession;
    final accessToken = session?.accessToken;
    if (accessToken == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not authenticated')),
      );
      return;
    }

    final dio = getIt<Dio>();

    try {
      await dio.delete(
        '/users/me/followers/$followerId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      if (!mounted) return;
      setState(() {
        _users.removeWhere((u) => u.id == followerId);
        _hasChanged = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Removed follow')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final supa = Supabase.instance.client;
    final currentUserId = supa.auth.currentUser?.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Followers'),
        backgroundColor: ColorName.mint,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // trả result về ProfilePage / UserProfilePage để reload nếu cần
            context.router.pop(_hasChanged);
          },
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
              child: Text(
                'Error: ${snap.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          if (_users.isEmpty) {
            return const Center(child: Text('No followers yet'));
          }

          return ListView.separated(
            itemCount: _users.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final u = _users[index];
              final isMe = (currentUserId == u.id); // không remove chính mình

              return ListTile(
                leading: GestureDetector(
                  onTap: () {
                    context.router.push(UserProfileRoute(userId: u.id));
                  },
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
                  onTap: () {
                    context.router.push(UserProfileRoute(userId: u.id));
                  },
                  child: Text(u.username),
                ),
                subtitle: Text(
                  u.bio?.isNotEmpty == true ? u.bio! : u.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                // 👉 chỉ hiện nút "Remove follow" nếu:
                // - đang xem profile của CHÍNH MÌNH (_isOwnProfile)
                // - có currentUserId
                // - follower đó không phải bản thân mình
                trailing: (!_isOwnProfile || currentUserId == null || isMe)
                    ? null
                    : TextButton(
                        onPressed: () => _removeFollower(u.id),
                        child: const Text('Remove follow'),
                      ),
              );
            },
          );
        },
      ),
    );
  }
}
