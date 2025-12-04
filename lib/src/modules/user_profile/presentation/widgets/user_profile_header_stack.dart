import 'package:flutter/material.dart';

import '../../domain/entities/user_profile_entity.dart';
import '../../../../../generated/colors.gen.dart';

class UserProfileHeaderStack extends StatelessWidget {
  final UserProfileEntity profile;
  final VoidCallback? onBack;

  /// 🔥 callback Follow / Unfollow
  final VoidCallback? onFollowPressed;

  /// 🔥 mở list Following
  final VoidCallback? onFollowingTap;

  /// 🔥 mở list Followers
  final VoidCallback? onFollowersTap;

  /// 🔥 đang xử lý API follow/unfollow
  final bool isFollowUpdating;

  const UserProfileHeaderStack({
    super.key,
    required this.profile,
    this.onBack,
    this.onFollowPressed,
    this.onFollowingTap,
    this.onFollowersTap,
    this.isFollowUpdating = false,
  });

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    const double coverHeight = 220;
    const double panelTop = 160;
    const double avatarRadius = 36;

    return SizedBox(
      height: panelTop + 280,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Cover ảnh nền
          Positioned.fill(
            top: 0,
            bottom: null,
            child: SizedBox(
              height: coverHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(28),
                      bottomRight: Radius.circular(28),
                    ),
                    child: Image.network(
                      'https://images.unsplash.com/photo-1761901175711-b6e3dd720a66?w=1600&auto=format&fit=crop',
                      fit: BoxFit.cover,
                    ),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, ColorName.black26],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Nút Back
          Positioned(
            left: 16,
            top: top + 12,
            child: _CircleIconButton(
              icon: Icons.arrow_back,
              onTap: onBack ?? () => Navigator.of(context).maybePop(),
            ),
          ),

          // Nút mail (demo)
          Positioned(
            right: 16,
            top: top + 12,
            child: _CircleIconButton(
              icon: Icons.mail_outline,
              onTap: () {},
            ),
          ),

          // Panel trắng
          Positioned(
            left: 0,
            right: 0,
            top: panelTop,
            child: Container(
              padding: const EdgeInsets.fromLTRB(
                16,
                avatarRadius + 18,
                16,
                16,
              ),
              decoration: const BoxDecoration(
                color: ColorName.bgF4f7f7,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(35),
                  topRight: Radius.circular(35),
                ),
              ),
              child: _PanelContent(
                profile: profile,
                onFollowPressed: onFollowPressed,
                onFollowingTap: onFollowingTap,
                onFollowersTap: onFollowersTap,
                isFollowUpdating: isFollowUpdating,
              ),
            ),
          ),

          // Avatar
          Positioned(
            top: panelTop - avatarRadius,
            left: 0,
            right: 0,
            child: _Avatar(radius: avatarRadius, profile: profile),
          ),
        ],
      ),
    );
  }
}

/// ============================
/// Avatar
/// ============================
class _Avatar extends StatelessWidget {
  final double radius;
  final UserProfileEntity profile;

  const _Avatar({
    required this.radius,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final avatarUrl = profile.avatarUrl;

    return Center(
      child: CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey[300],
        backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
            ? NetworkImage(avatarUrl)
            : null,
        child: (avatarUrl == null || avatarUrl.isEmpty)
            ? Text(
                profile.username.isNotEmpty
                    ? profile.username[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
      ),
    );
  }
}

/// ============================
/// Panel nội dung
/// ============================
class _PanelContent extends StatelessWidget {
  final UserProfileEntity profile;
  final VoidCallback? onFollowPressed;
  final VoidCallback? onFollowingTap;
  final VoidCallback? onFollowersTap;
  final bool isFollowUpdating;

  const _PanelContent({
    required this.profile,
    this.onFollowPressed,
    this.onFollowingTap,
    this.onFollowersTap,
    this.isFollowUpdating = false,
  });

  @override
  Widget build(BuildContext context) {
    final isMe = profile.isMe;
    final isFollowing = profile.isFollowing ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Tên + email
        Text(
          profile.username,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          profile.email,
          style: TextStyle(
            color: ColorName.grey600,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 12),

        // Bio
        if (profile.bio != null && profile.bio!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              profile.bio!,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: ColorName.grey800,
                height: 1.25,
              ),
            ),
          )
        else
          const Text(
            'No bio yet',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
        const SizedBox(height: 16),

        // Stats: Posts - Following - Followers
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _StatItem(
              label: 'Posts',
              value: profile.postCount.toString(),
              onTap: null, // nếu muốn thì sau này nhảy sang tab Posts
            ),
            _StatItem(
              label: 'Following',
              value: profile.followingCount.toString(),
              onTap: onFollowingTap,
            ),
            _StatItem(
              label: 'Followers',
              value: profile.followerCount.toString(),
              onTap: onFollowersTap,
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Follow / Unfollow / (nếu là mình thì ẩn hoặc sau này thay bằng Edit)
        if (!isMe)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (onFollowPressed == null || isFollowUpdating)
                  ? null
                  : onFollowPressed,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: isFollowing ? ColorName.white : ColorName.mint,
                foregroundColor: isFollowing ? ColorName.mint : ColorName.white,
                side: BorderSide(
                  color: ColorName.mint,
                  width: 1.2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isFollowUpdating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      isFollowing ? 'Unfollow' : 'Follow',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
      ],
    );
  }
}

/// ============================
/// Item thống kê
/// ============================
class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _StatItem({
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );

    if (onTap == null) return content;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4),
        child: content,
      ),
    );
  }
}

/// ============================
/// Nút tròn nhỏ
/// ============================
class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _CircleIconButton({
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black26,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Icon(
            icon,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
    );
  }
}
