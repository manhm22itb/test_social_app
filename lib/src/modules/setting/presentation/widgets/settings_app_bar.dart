import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../../generated/colors.gen.dart';

class SettingsAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onBackPressed;

  const SettingsAppBar({
    super.key,
    required this.onBackPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: ColorName.backgroundWhite,
      elevation: 1,
      title: Text(
        'Settings',
        style: TextStyle(
          color: ColorName.textBlack,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      leading: IconButton(
        icon: const FaIcon(Icons.arrow_back_ios_new_rounded),
        onPressed: onBackPressed,
        color: ColorName.textBlack,
      ),
    );
  }
}