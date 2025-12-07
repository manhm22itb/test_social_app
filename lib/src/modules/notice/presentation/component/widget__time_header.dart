import 'package:flutter/material.dart';

import '../../../../../generated/colors.gen.dart';



class WidgetTimeHeader extends StatelessWidget {
  final String title;
  const WidgetTimeHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorName.mint.withOpacity(0.4),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      alignment: Alignment.centerLeft,
      child: const _Title(),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title();

  @override
  Widget build(BuildContext context) {
    return Text(
      // truyền qua constructor nếu muốn tuỳ biến,
      // ở đây giữ nguyên style theo code gốc
      (context.findAncestorWidgetOfExactType<WidgetTimeHeader>()!).title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14,
        color: Color(0xFF333333),
      ),
    );
  }
}
