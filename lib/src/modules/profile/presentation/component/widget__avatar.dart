import 'package:flutter/material.dart';

import '../../../../../generated/colors.gen.dart'; 
class WidgetAvatar extends StatelessWidget {
  final double radius;
  const WidgetAvatar({super.key, required this.radius});

  @override
  Widget build(BuildContext context) {
    const _avatarUrl =
        'https://images.unsplash.com/photo-1660304755869-325c2ff6f02d?ixlib=rb-4.1.0&auto=format&fit=crop&q=80&w=1118';

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: ColorName.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.25),
            blurRadius: 18,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundImage: const NetworkImage(_avatarUrl),
      ),
    );
  }
}
