// lib/src/modules/newpost/presentation/widgets/post_content_field.dart

import 'package:flutter/material.dart';

import '../../../../../generated/colors.gen.dart';

class PostContentField extends StatelessWidget {
  final TextEditingController postController;
  final FocusNode focusNode;
  final String currentUsername;
  final bool isPublic; // 👈 chỉ còn 1 flag
  final VoidCallback onPrivacyChanged;
  final int characterCount;
  final int maxCharacters;

  const PostContentField({
    super.key,
    required this.postController,
    required this.focusNode,
    required this.currentUsername,
    required this.isPublic,
    required this.onPrivacyChanged,
    required this.characterCount,
    required this.maxCharacters,
  });

  @override
  Widget build(BuildContext context) {
    // Với 2 chế độ: nếu không public thì là private
    final String privacyLabel = isPublic ? 'Public' : 'Private';
    final IconData privacyIcon = isPublic ? Icons.public : Icons.lock;

    final isOverLimit = characterCount > maxCharacters;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hàng avatar + username + chip privacy
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: ColorName.mint.withOpacity(0.2),
              child: Text(
                (currentUsername.isNotEmpty ? currentUsername[0] : 'U')
                    .toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: ColorName.mint,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentUsername,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: onPrivacyChanged,
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: ColorName.grey100,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            privacyIcon,
                            size: 14,
                            color: ColorName.grey600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            privacyLabel,
                            style: const TextStyle(
                              fontSize: 12,
                              color: ColorName.grey700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Ô nhập nội dung
        TextField(
          controller: postController,
          focusNode: focusNode,
          maxLines: null,
          decoration: const InputDecoration(
            hintText: "What's happening?",
            border: InputBorder.none,
          ),
        ),
        const SizedBox(height: 8),
        // counter
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '$characterCount/$maxCharacters',
            style: TextStyle(
              fontSize: 12,
              color: isOverLimit ? Colors.red : ColorName.grey500,
            ),
          ),
        ),
      ],
    );
  }
}
