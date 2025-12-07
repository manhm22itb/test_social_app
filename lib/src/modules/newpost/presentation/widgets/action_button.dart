import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../../generated/colors.gen.dart';

class ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;

  const ActionButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: FaIcon(
        icon,
        color: color ?? ColorName.primaryBlue,
        size: 20,
      ),
      splashRadius: 20,
    );
  }
}