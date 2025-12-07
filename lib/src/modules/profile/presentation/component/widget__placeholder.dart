import 'package:flutter/material.dart';

import '../../../../../generated/colors.gen.dart';

class WidgetPlaceholder extends StatelessWidget {
  final String text;
  const WidgetPlaceholder({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('$text tab — Coming soon',
          style: TextStyle(fontSize: 16, color: ColorName.black54)),
    );
  }
}
