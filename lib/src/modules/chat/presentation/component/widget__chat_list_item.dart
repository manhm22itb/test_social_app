import 'package:flutter/material.dart';

import '../../../../../generated/colors.gen.dart'; // đổi theo package thật

class WidgetChatListItem extends StatelessWidget {
  final String imageUrl;
  final String username;
  final String handle;
  final String lastMessage;
  final String time;
  final bool isRead;

  const WidgetChatListItem({
    super.key,
    required this.imageUrl,
    required this.username,
    required this.handle,
    required this.lastMessage,
    required this.time,
    this.isRead = true,
  });

  @override
  Widget build(BuildContext context) {
    final itemColor = isRead ? ColorName.white : ColorName.greyF0;
    final messageColor = isRead ? ColorName.grey600 : ColorName.black87;

    return Container(
      color: itemColor,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          CircleAvatar(radius: 24, backgroundImage: NetworkImage(imageUrl)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      username,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: ColorName.black87,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      handle,
                      style: const TextStyle(
                        color: ColorName.grey600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  lastMessage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: messageColor,
                    fontWeight: isRead ? FontWeight.normal : FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              color: ColorName.grey600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
