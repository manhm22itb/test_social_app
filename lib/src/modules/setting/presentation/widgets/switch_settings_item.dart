import 'package:flutter/material.dart';

import '../../../../../generated/colors.gen.dart';
import 'settings_item.dart';

class SwitchSettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final Function(bool) onChanged;

  const SwitchSettingsItem({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsItem(
      icon: icon,
      title: title,
      subtitle: subtitle,
      showArrow: false,
      onTap: null,
      trailing: _buildSwitch(),
    );
  }

  Widget _buildSwitch() {
    return Switch(
      value: value,
      onChanged: onChanged,
      activeColor: ColorName.mint,
    );
  }
}