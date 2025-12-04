import 'package:flutter/material.dart';
import '../../../../../generated/colors.gen.dart';

class UserAvatar extends StatelessWidget {
  final String username;

  const UserAvatar({
    super.key,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: ColorName.primaryBlue,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Center(
        child: Text(
          username[0].toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}