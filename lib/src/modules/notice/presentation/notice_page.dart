import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

// đổi theo package thật:
import '../../../../generated/colors.gen.dart';
import 'component/widget__notice_activity_tab.dart';
import 'component/widget__notice_app_bar.dart';
import 'component/widget__notice_list.dart';
import 'model/notice_model.dart';

@RoutePage()
class NoticePage extends StatelessWidget {
  const NoticePage({super.key});

  @override
  Widget build(BuildContext context) {

    return DefaultTabController(
      length: 3, // Activity, All, Mention
      child: Scaffold(
        backgroundColor: ColorName.softBg,
        appBar: const WidgetNoticeAppBar(),
        body: Column(
          children: const [
            _NoticeTabs(),
            Expanded(child: _NoticeTabViews()),
          ],
        ),
      ),
    );
  }
}

class _NoticeTabs extends StatelessWidget {
  const _NoticeTabs();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorName.white,
      child: const TabBar(
        isScrollable: true,
        labelColor: ColorName.black,
        unselectedLabelColor: ColorName.black54,
        indicatorColor: ColorName.black,
        indicatorWeight: 2,
        indicatorSize: TabBarIndicatorSize.label,
        padding: EdgeInsets.symmetric(horizontal: 16),
        tabs: [
          Tab(text: 'Activity'),
          Tab(text: 'All'),
          Tab(text: 'Mention'),
        ],
      ),
    );
  }
}

class _NoticeTabViews extends StatelessWidget {
  const _NoticeTabViews();

  @override
  Widget build(BuildContext context) {
    final noticesAll = <NoticeItem>[
      NoticeItem(
        title: 'User 1',
        message: 'liked your post',
        time: '10:02',
        unread: true,
        avatarUrl: 'https://i.pravatar.cc/80?img=1',
      ),
      NoticeItem(
        title: 'User 2',
        message: 'commented: "Nice work!"',
        time: '09:47',
        avatarUrl: 'https://i.pravatar.cc/80?img=2',
      ),
      NoticeItem(
        title: 'System',
        message: 'Your password was changed',
        time: 'Yesterday',
        icon: Icons.shield_outlined,
      ),
    ];

    final noticesMention = <NoticeItem>[
      NoticeItem(
        title: 'Minh Man',
        message: 'mentioned you in a post',
        time: '3m ago',
        avatarUrl: 'https://i.pravatar.cc/80?img=3',
        unread: true,
      ),
    ];

    return TabBarView(
      children: [
        const WidgetNoticeActivityTab(),
        SafeArea(child: WidgetNoticeList(items: noticesAll)),
        SafeArea(child: WidgetNoticeList(items: noticesMention)),
      ],
    );
  }
}
