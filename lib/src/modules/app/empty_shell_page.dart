// lib/src/modules/app/empty_shell_page.dart
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../common/widgets/bottom_navigation.dart';
import '../../common/utils/getit_utils.dart';
import '../newpost/presentation/cubit/post_cubit.dart';
import 'app_router.dart';

@RoutePage()
class EmptyShellPage extends StatefulWidget implements AutoRouteWrapper {
  const EmptyShellPage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<PostCubit>(
      create: (_) =>
          getIt<PostCubit>()..loadFeed(), // chỉ load 1 lần khi vào app
      child: this,
    );
  }

  @override
  State<EmptyShellPage> createState() => _EmptyShellPageState();
}

class _EmptyShellPageState extends State<EmptyShellPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const AutoRouter(), // current child route
      bottomNavigationBar: WidgetBottomNav(
        currentIndex: _currentIndex,
        onTap: _onNavItemTapped,
      ),
    );
  }

  void _onNavItemTapped(int index) {
    if (index == 2) {
      context.router.push(const CreatePostRoute());
      return;
    }

    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0: // Home
        context.router.replace(const HomeRoute());
        break;
      case 1: // Chat
        context.router.replace(const ChatRoute());
        break;
      case 3: // Notice
        context.router.replace(const NoticeRoute());
        break;
      case 4: // Profile
        context.router.replace(const ProfileRoute());
        break;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateCurrentIndex();
  }

  void _updateCurrentIndex() {
    final currentPath = context.router.currentPath;

    if (currentPath.contains('home')) {
      _currentIndex = 0;
    } else if (currentPath.contains('chat')) {
      _currentIndex = 1;
    } else if (currentPath.contains('notice')) {
      _currentIndex = 3;
    } else if (currentPath.contains('profile')) {
      _currentIndex = 4;
    }

    if (mounted) setState(() {});
  }
}
