import 'package:flutter/material.dart';

import '../../../../../generated/colors.gen.dart';



class WidgetRightButton extends StatelessWidget {
  final String text;
  const WidgetRightButton({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: ColorName.mint,
          foregroundColor: ColorName.white,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(text, style: const TextStyle(fontSize: 12)),
      ),
    );
  }
}
