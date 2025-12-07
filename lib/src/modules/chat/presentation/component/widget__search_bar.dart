import 'package:flutter/material.dart';

import '../../../../../generated/colors.gen.dart'; // đổi theo package của bạn

class WidgetSearchBar extends StatelessWidget {
  const WidgetSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: ColorName.greyEb, // nền search bar
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: const Row(
        children: [
          Icon(Icons.search, color: ColorName.grey, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search for people and groups',
                hintStyle: TextStyle(color: ColorName.grey, fontSize: 15),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.only(bottom: 2),
              ),
              style: TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
