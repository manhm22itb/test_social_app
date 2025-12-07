import 'package:flutter/material.dart';
import '../../../../../generated/colors.gen.dart';

class SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SettingsSection({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(),
        _buildSectionContent(),
      ],
    );
  }

  Widget _buildSectionTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Text(
        title,
        style: TextStyle(
          color: ColorName.textGray,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSectionContent() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: ColorName.backgroundWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorName.borderLight),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}