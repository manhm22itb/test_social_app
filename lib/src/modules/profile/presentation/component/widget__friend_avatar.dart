import 'package:flutter/material.dart';

class WidgetFriendAvatar extends StatelessWidget {
  final String url;
  const WidgetFriendAvatar(this.url, {super.key});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 22,
      backgroundImage: NetworkImage(url),
    );
  }
}
