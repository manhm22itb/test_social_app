import 'package:flutter/material.dart';

class WidgetRightImage extends StatelessWidget {
  final String url;
  const WidgetRightImage({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(radius: 16, backgroundImage: NetworkImage(url));
  }
}
