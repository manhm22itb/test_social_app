import 'package:flutter/material.dart';

import 'widget__notice_activity_item.dart';
import 'widget__time_header.dart';

/// Data mẫu cho Activity theo “đúng UI gốc”
class WidgetNoticeActivityTab extends StatelessWidget {
  const WidgetNoticeActivityTab({super.key});

  @override
  Widget build(BuildContext context) {
    final today = [
      NoticeActivityItem(
        imageUrl:
            'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=200',
        username: 'Undred',
        action: 'like your post',
        time: '10m ago',
        actionIcon: Icons.reply,
        right: ActivityRight.image(
          'https://images.unsplash.com/photo-1595341888016-a392ef81b7de?w=200',
        ),
      ),
      NoticeActivityItem(
        imageUrl:
            'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=200',
        username: 'Diu Ly',
        action: 'started following you',
        time: '10m ago',
        actionIcon: Icons.chat_bubble_outline,
        right: const ActivityRight.button('Follow back'),
      ),
    ];

    final thisWeek = [
      NoticeActivityItem(
        imageUrl:
            'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=200',
        username: 'Minh Man',
        action: 'Mention you in this posts',
        time: '3d ago',
        actionIcon: Icons.reply,
        right: const ActivityRight.button('Reply'),
      ),
      NoticeActivityItem(
        imageUrl:
            'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=200',
        username: 'Minh Man',
        action: 'Like “Diu Ly dep qua”',
        time: '3d ago',
        actionIcon: Icons.person_outline,
        right: const ActivityRight.button('Follow'),
      ),
      NoticeActivityItem(
        imageUrl:
            'https://images.unsplash.com/photo-1520813792240-56fc4a3765a7?w=200',
        username: 'watched',
        action: 'Ho like your post',
        time: '5d ago',
        actionIcon: Icons.reply,
        right: ActivityRight.image(
          'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=200',
        ),
      ),
      NoticeActivityItem(
        imageUrl:
            'https://images.unsplash.com/photo-1520813792240-56fc4a3765a7?w=200',
        username: 'watched',
        action: 'Diu Ly accept your follow',
        time: '5d ago',
        actionIcon: Icons.person_outline,
        right: const ActivityRight.icon(Icons.handshake),
      ),
    ];

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const WidgetTimeHeader(title: 'Today'),
        ...today.map((e) => WidgetNoticeActivityItem(item: e)),
        const WidgetTimeHeader(title: 'This week'),
        ...thisWeek.map((e) => WidgetNoticeActivityItem(item: e)),
      ],
    );
  }
}

/// Model riêng cho tab Activity (không đụng tới NoticeItem cũ của bạn)
class NoticeActivityItem {
  final String imageUrl;
  final String username;
  final String action;
  final String time;
  final IconData actionIcon;
  final ActivityRight right;

  NoticeActivityItem({
    required this.imageUrl,
    required this.username,
    required this.action,
    required this.time,
    required this.actionIcon,
    required this.right,
  });
}

/// Right content: Button / Image / Icon
class ActivityRight {
  final ActivityRightType type;
  final String? text;
  final String? imageUrl;
  final IconData? icon;

  const ActivityRight._(this.type, {this.text, this.imageUrl, this.icon});

  const ActivityRight.button(this.text)
      : type = ActivityRightType.button,
        imageUrl = null,
        icon = null;

  ActivityRight.image(this.imageUrl)
      : type = ActivityRightType.image,
        text = null,
        icon = null;

  const ActivityRight.icon(this.icon)
      : type = ActivityRightType.icon,
        text = null,
        imageUrl = null;
}

enum ActivityRightType { button, image, icon }
