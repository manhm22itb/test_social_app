import 'package:flutter/material.dart';

import '../../../../../generated/colors.gen.dart';
import '../model/message_model.dart';

class WidgetMessageBubble extends StatelessWidget {
  final Message message;

  const WidgetMessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final align = message.isMe ? Alignment.centerRight : Alignment.centerLeft;

    final color = message.isMe ? ColorName.mint : ColorName.white;
    final textColor = message.isMe ? ColorName.white : ColorName.black87;
    final border = BorderRadius.circular(16);

    return Align(
      alignment: align,
      child: Column(
        crossAxisAlignment:
            message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Bong bóng tin nhắn
          Container(
            margin: const EdgeInsets.only(top: 8, bottom: 2),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: color,
              borderRadius: border.copyWith(
                topRight: message.isMe
                    ? const Radius.circular(4)
                    : border.topRight,
                topLeft: message.isMe
                    ? border.topLeft
                    : const Radius.circular(4),
              ),
              boxShadow: message.isMe
                  ? []
                  : [
                      BoxShadow(
                        color: ColorName.black05, // thay vì Colors.black.withOpacity(0.05)
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Text(
              message.text,
              style: TextStyle(color: textColor, fontSize: 16),
            ),
          ),

          // Trạng thái (Sent, Delivered, v.v.)
          if (message.isMe && message.status != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
              child: Text(
                message.status!,
                style: TextStyle(
                  color: ColorName.grey500,
                  fontSize: 11,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
