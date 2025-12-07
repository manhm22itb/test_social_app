import 'package:flutter/material.dart';

class UserProfileAvatar extends StatelessWidget {
  final double radius;
  final String? avatarUrl;
  final String fallbackText;

  const UserProfileAvatar({
    super.key,
    required this.radius,
    this.avatarUrl,
    this.fallbackText = '?',
  });

  @override
  Widget build(BuildContext context) {
    final String text =
        fallbackText.isNotEmpty ? fallbackText[0].toUpperCase() : '?';

    final hasAvatar = avatarUrl != null && avatarUrl!.isNotEmpty;

    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey.shade300,
      backgroundImage: hasAvatar ? NetworkImage(avatarUrl!) : null,
      child: !hasAvatar
          ? Text(
              text,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
    );
  }
}
