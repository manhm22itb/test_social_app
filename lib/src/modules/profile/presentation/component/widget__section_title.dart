import 'package:flutter/material.dart';

class WidgetSectionTitle extends StatelessWidget {
  final String text;
  const WidgetSectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        height: 1,
      ),
    );
  }
}
