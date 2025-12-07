import 'package:flutter/material.dart';
import 'package:social_app/src/modules/auth/domain/entities/user_entity.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UserItem extends StatelessWidget {
  final UserEntity user;
  final VoidCallback onTap;

  const UserItem({super.key, required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundImage: user.avatarUrl != null 
            ? CachedNetworkImageProvider(user.avatarUrl!) 
            : null,
        child: user.avatarUrl == null ? const Icon(Icons.person) : null,
      ),
      title: Text(user.username ?? "Unknown User"),
    );
  }
}