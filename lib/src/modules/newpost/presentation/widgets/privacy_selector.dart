import 'package:flutter/material.dart';

class PrivacySelector extends StatelessWidget {
  final bool isPublic;
  final bool isFriends;
  final VoidCallback onPrivacyChanged;

  const PrivacySelector({
    super.key,
    required this.isPublic,
    required this.onPrivacyChanged, 
    required this.isFriends,
  });

  @override
  Widget build(BuildContext context) {
    String visibilityText;
    IconData iconData; // Thêm biến cho Icon

    if (isPublic) {
      visibilityText = 'Public';
      iconData = Icons.public; 
    } else if (isFriends) {
      visibilityText = 'Friends';
      iconData = Icons.people_outline; 
    } else { 
      visibilityText = 'Private';
      iconData = Icons.lock_outline;
    }
    return GestureDetector(
      onTap: onPrivacyChanged,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              iconData,
              size: 14,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              visibilityText,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}