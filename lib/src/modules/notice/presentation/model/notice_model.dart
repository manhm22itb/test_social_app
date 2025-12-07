import 'package:flutter/material.dart';

class NoticeItem {
  final String title;
  final String message;
  final String time;
  final bool unread;
  final String? avatarUrl;   // ưu tiên dùng avatar nếu có
  final IconData? icon;      // fallback nếu không có avatar

  const NoticeItem({
    required this.title,
    required this.message,
    required this.time,
    this.unread = false,
    this.avatarUrl,
    this.icon,
  });
}
