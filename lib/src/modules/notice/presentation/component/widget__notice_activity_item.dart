import 'package:flutter/material.dart';

import '../../../../../generated/colors.gen.dart';
import 'widget__notice_activity_tab.dart' show NoticeActivityItem, ActivityRightType;
import 'widget__right_button.dart';
import 'widget__right_icon.dart';
import 'widget__right_image.dart';

class WidgetNoticeActivityItem extends StatelessWidget {
  final NoticeActivityItem item;
  const WidgetNoticeActivityItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final right = _buildRight(item);

    return Container(
      color: ColorName.white,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon action nhỏ bên trái
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Icon(item.actionIcon, color: ColorName.grey600, size: 16),
          ),
          const SizedBox(width: 8),

          // Avatar
          CircleAvatar(radius: 24, backgroundImage: NetworkImage(item.imageUrl)),
          const SizedBox(width: 12),

          // Nội dung
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 14,
                      color: ColorName.grey800,
                      height: 1.4,
                    ),
                    children: [
                      TextSpan(
                        text: item.username,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: ColorName.black87,
                        ),
                      ),
                      TextSpan(text: ' ${item.action}'),
                    ],
                  ),
                ),
                Text(
                  item.time,
                  style: TextStyle(color: ColorName.grey600, fontSize: 12),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),
          right,
        ],
      ),
    );
  }

  Widget _buildRight(NoticeActivityItem it) {
    switch (it.right.type) {
      case ActivityRightType.button:
        return WidgetRightButton(text: it.right.text!);
      case ActivityRightType.image:
        return WidgetRightImage(url: it.right.imageUrl!);
      case ActivityRightType.icon:
        return WidgetRightIcon(icon: it.right.icon!);
    }
  }
}
