import 'package:flutter/material.dart';

import '../../domain/entities/user_profile_entity.dart';
import '../../../../../generated/colors.gen.dart';

class UserProfilePanelContent extends StatelessWidget {
  final UserProfileEntity profile;
  final VoidCallback? onFollowToggle;

  const UserProfilePanelContent({
    super.key,
    required this.profile,
    this.onFollowToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isFollowing = profile.isFollowing ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Username + email
        Text(
          profile.username,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          profile.email,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),

        const SizedBox(height: 12),

        // Stats
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _StatItem(label: 'Posts', value: profile.postCount),
            _StatItem(label: 'Followers', value: profile.followerCount),
            _StatItem(label: 'Following', value: profile.followingCount),
          ],
        ),

        const SizedBox(height: 12),

        // Bio
        if ((profile.bio ?? '').isNotEmpty) ...[
          Text(
            profile.bio!,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Follow / Unfollow button (chỉ khi không phải chính mình)
        if (!profile.isMe)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isFollowing ? Colors.white : ColorName.mint,
                foregroundColor:
                    isFollowing ? ColorName.mint : Colors.white,
                side: BorderSide(
                  color: ColorName.mint,
                  width: 1.2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              onPressed: onFollowToggle,
              child: Text(
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

class _StatItem extends StatelessWidget {
  final String label;
  final int value;

  const _StatItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$value',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
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
  }
}
