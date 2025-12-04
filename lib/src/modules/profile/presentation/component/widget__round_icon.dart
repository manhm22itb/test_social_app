import 'package:flutter/material.dart';

import '../../../../../generated/colors.gen.dart';
class WidgetRoundIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const WidgetRoundIcon({super.key, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ColorName.white,
      shape: const CircleBorder(),
      elevation: 4,
      shadowColor: ColorName.black38,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(icon, color: ColorName.black87),
        ),
      ),
    );
  }
}
