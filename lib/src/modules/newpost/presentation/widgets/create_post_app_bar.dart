import 'package:flutter/material.dart';

import '../../../../../generated/colors.gen.dart';

class CreatePostAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool canPost;
  final VoidCallback? onPostPressed;
  final VoidCallback? onBackPressed;

  const CreatePostAppBar({
    super.key,
    required this.canPost,
    this.onPostPressed,
    this.onBackPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: ColorName.backgroundWhite,
      centerTitle: false,
      title: const Text(
        'Create Post',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: Colors.black,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: () {
          print('>>> [CreatePostAppBar] Back pressed');
          // dùng Navigator thuần, không AutoRoute, không AutoTabsRouter
          if (onBackPressed != null) {
            onBackPressed!();
          } else {
            Navigator.of(context).maybePop();
          }
        },
      ),
      actions: [
        TextButton(
          onPressed: canPost ? onPostPressed : null,
          style: TextButton.styleFrom(
            backgroundColor: canPost ? ColorName.mint : ColorName.grey100,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          child: Text(
            'Post',
            style: TextStyle(
              color: canPost ? Colors.white : ColorName.grey500,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
