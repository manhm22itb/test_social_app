import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ActionButton extends StatelessWidget {
  final IconData icon;
  final int? count;
  final VoidCallback onPressed;

  const ActionButton({
    super.key,
    required this.icon,
    this.count,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Row(
        children: [
          FaIcon(
            icon,
            color: Colors.grey,
            size: 18,
          ),
          if (count != null) ...[
            const SizedBox(width: 6),
            Text(
              _formatCount(count!),
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count < 1000) return count.toString();
    if (count < 1000000) return '${(count / 1000).toStringAsFixed(1)}K';
    return '${(count / 1000000).toStringAsFixed(1)}M';
  }
}