import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../../generated/colors.gen.dart';

class SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final VoidCallback onBackPressed;
  final TabController tabController; // Thêm lại TabController

  const SearchAppBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onBackPressed,
    required this.tabController,
  });

  @override
  Size get preferredSize => const Size.fromHeight(100); // Tăng chiều cao để chứa TabBar

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: ColorName.backgroundWhite,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: ColorName.textBlack),
        onPressed: onBackPressed,
      ),
      titleSpacing: 0,
      title: Container(
        height: 40,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: ColorName.backgroundLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: ColorName.borderLight),
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          decoration: const InputDecoration(
            hintText: 'Search...',
            prefixIcon: Icon(FontAwesomeIcons.magnifyingGlass, size: 16, color: ColorName.textGray),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 8), 
            isDense: true,
          ),
        ),
      ),
      bottom: TabBar(
        controller: tabController,
        labelColor: ColorName.mint,
        unselectedLabelColor: ColorName.textGray,
        indicatorColor: ColorName.mint,
        tabs: const [
          Tab(text: "All"),
          Tab(text: "Posts"),
          Tab(text: "Users"),
        ],
      ),
    );
  }
}