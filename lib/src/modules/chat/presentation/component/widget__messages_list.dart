import 'package:flutter/material.dart';
import '../model/message_model.dart';
import 'widget__message_bubble.dart';

class WidgetMessagesList extends StatelessWidget {
  final List<Message> messages;
  const WidgetMessagesList({super.key, required this.messages});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      reverse: true,
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final msg = messages[messages.length - 1 - index];
        return WidgetMessageBubble(message: msg);
      },
    );
  }
}
