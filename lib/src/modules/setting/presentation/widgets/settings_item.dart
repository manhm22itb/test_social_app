import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../../generated/colors.gen.dart';

class SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool showArrow;
  final VoidCallback? onTap;
  final Widget? trailing;

  const SettingsItem({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.showArrow = true,
    this.onTap, this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: ColorName.borderLight, width: 0.5),
        ),
      ),
      child: ListTile(
        leading: FaIcon(
          icon,
          color: ColorName.mint,
          size: 20,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: ColorName.textBlack,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: ColorName.textGray,
            fontSize: 14,
          ),
        ),
        trailing: showArrow ? _buildTrailingArrow() : null,
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildTrailingArrow() {
    return FaIcon(
      FontAwesomeIcons.chevronRight,
      color: ColorName.textGray,
      size: 14,
    );
  }
}