import 'package:flutter/material.dart';

import '../../../../../generated/colors.gen.dart';
import '../../domain/entities/user_profile_entity.dart';
// 👇 IMPORT LẠI TAB ĐÃ CÓ SẴN BÊN PROFILE
import '../../../profile/presentation/component/user_posts_tab.dart';

class UserProfileTabs extends StatelessWidget {
  final UserProfileEntity profile;

  const UserProfileTabs({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const TabBar(
          indicatorColor: ColorName.mint,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          tabs: [
            Tab(icon: Icon(Icons.grid_on), text: 'Posts'),
            Tab(icon: Icon(Icons.people_alt_outlined), text: 'Friends'),
            Tab(icon: Icon(Icons.info_outline), text: 'About'),
          ],
        ),
        SizedBox(
          height: 400, // vẫn giữ tạm; có thể đổi sau
          child: TabBarView(
            children: [
              // 🔥 DÙNG USER_POSTS_TAB ĐỂ LẤY BÀI THEO USER
              UserPostsTab(userId: profile.id),

              // hai tab sau để tạm, sau tính tiếp
              const Center(child: Text('Friends / followers coming soon')),
              const Center(child: Text('About user coming soon')),
            ],
          ),
        ),
      ],
    );
  }
}
