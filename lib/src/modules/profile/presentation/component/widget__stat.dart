import 'package:flutter/material.dart';

import '../../../../../generated/colors.gen.dart';

class WidgetStat extends StatelessWidget {
  final String number;
  final String label;
  const WidgetStat({super.key, required this.number, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          number,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: ColorName.grey700)),
      ],
    );
  }
}
