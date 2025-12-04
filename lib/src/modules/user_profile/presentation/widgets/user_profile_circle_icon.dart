import 'package:flutter/material.dart';

class UserProfileCircleIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;

  const UserProfileCircleIcon({
    super.key,
    required this.icon,
    this.onTap,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black26,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          height: size,
          width: size,
          child: Icon(
            icon,
            color: Colors.white,
            size: size * 0.55,
          ),
        ),
      ),
    );
  }
}
