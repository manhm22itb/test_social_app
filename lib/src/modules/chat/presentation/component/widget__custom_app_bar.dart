import 'package:flutter/material.dart';

import '../../../../../generated/colors.gen.dart';

class WidgetCustomAppBar extends StatelessWidget {
  const WidgetCustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        bottom: 8,
      ),
      color: ColorName.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 16.0),
            child: CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(
                'https://i.ibb.co/bF0bS0v/black-avatar.png',
              ),
            ),
          ),
          const Text(
            'Messages',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: ColorName.black87,
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.settings_outlined,
              color: ColorName.black54,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
