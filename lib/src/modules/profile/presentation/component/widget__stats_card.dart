import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../generated/colors.gen.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';

class WidgetStatsCard extends StatelessWidget {
  final VoidCallback? onPostsTap;
  final VoidCallback? onFollowingTap;
  final VoidCallback? onFollowersTap;

  const WidgetStatsCard({
    super.key,
    this.onPostsTap,
    this.onFollowingTap,
    this.onFollowersTap,
  });

  String _formatNumber(int n) {
    if (n >= 1000000) {
      final value = n / 1000000;
      return '${value.toStringAsFixed(value >= 10 ? 0 : 1)}M';
    }
    if (n >= 1000) {
      final value = n / 1000;
      return '${value.toStringAsFixed(value >= 10 ? 0 : 1)}K';
    }
    return n.toString();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        int posts = 0;
        int following = 0;
        int followers = 0;

        state.maybeWhen(
          loaded: (profile) {
            posts = profile.postCount ?? 0;
            following = profile.followingCount ?? 0;
            followers = profile.followerCount ?? 0;
          },
          updating: (profile) {
            posts = profile.postCount ?? 0;
            following = profile.followingCount ?? 0;
            followers = profile.followerCount ?? 0;
          },
          orElse: () {},
        );

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
          decoration: BoxDecoration(
            color: ColorName.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: ColorName.black10,
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _StatItem(
                value: _formatNumber(posts),
                label: 'Posts',
                onTap: onPostsTap,
              ),
              const SizedBox(height: 14),
              _StatItem(
                value: _formatNumber(following),
                label: 'Following',
                onTap: onFollowingTap,
              ),
              const SizedBox(height: 14),
              _StatItem(
                value: _formatNumber(followers),
                label: 'Followers',
                onTap: onFollowersTap,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final VoidCallback? onTap;

  const _StatItem({
    required this.value,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
