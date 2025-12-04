import 'package:flutter/material.dart';

import '../../../../../generated/colors.gen.dart';

class WidgetSoftButton extends StatelessWidget {
  final String text;
  final Color background;
  final Color textColor;
  final bool hasBorder;

  const WidgetSoftButton({
    super.key,
    required this.text,
    required this.background,
    required this.textColor,
    this.hasBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(22),
        border: hasBorder
            ? Border.all(color: ColorName.greyE6eaea)
            : null,
        boxShadow: const [
          BoxShadow(
            color: ColorName.black10,
            offset: Offset(0, 6),
            blurRadius: 12,
          ),
        ],
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: textColor,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
