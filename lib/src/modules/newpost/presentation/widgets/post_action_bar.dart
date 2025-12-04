import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../../generated/colors.gen.dart';

import 'action_button.dart';

class PostActionBar extends StatelessWidget {
  final TextEditingController postController;
  final VoidCallback onClearPost;
  final VoidCallback onAddPhoto;
  final VoidCallback onAddMention;
  final VoidCallback onAddEmoji;

  const PostActionBar({
    super.key,
    required this.postController,
    required this.onClearPost,
    required this.onAddPhoto,
    required this.onAddMention,
    required this.onAddEmoji,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.blueGrey, width: 0.5),
        ),
      ),
      child: Column(
        children: [
          // Action buttons row
          Row(
            children: [
              // Add photo
              ActionButton(
                icon: FontAwesomeIcons.image,
                color: ColorName.navBackground,
                onPressed: onAddPhoto,
              ),
              const SizedBox(width: 16),
                                                         
              // Add mention
              ActionButton(
                icon: FontAwesomeIcons.at,
                color: ColorName.navBackground,
                onPressed: onAddMention,
              ),
              const SizedBox(width: 16),
              
              // Add emoji
              ActionButton(
                icon: FontAwesomeIcons.faceSmile,
                color: ColorName.navBackground,
                onPressed: onAddEmoji,
              ),
              
              const Spacer(),
              
              // Clear button
              if (postController.text.isNotEmpty)
                ActionButton(
                  icon: FontAwesomeIcons.trash,
                  onPressed: onClearPost,
                  color: Colors.red,
                ),
            ],
          ),
        ],
      ),
    );
  }
}