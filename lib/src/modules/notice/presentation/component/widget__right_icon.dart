import 'package:flutter/material.dart';

import '../../../../../generated/colors.gen.dart';



class WidgetRightIcon extends StatelessWidget {
  final IconData icon;
  const WidgetRightIcon({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: ColorName.mint.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: ColorName.mint, size: 20),
    );
  }
}
