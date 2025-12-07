import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../generated/colors.gen.dart';
import '../../../common/utils/getit_utils.dart';
import '../../app/app_router.dart';
import '../../newpost/presentation/cubit/post_cubit.dart';
import 'widgets/post_list.dart';

@RoutePage()
class HomePage extends StatefulWidget implements AutoRouteWrapper {
  const HomePage({super.key});

  /// Bọc HomePage bằng BlocProvider để inject PostCubit
  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<PostCubit>(
      create: (_) => getIt<PostCubit>()..loadFeed(),
      child: this,
    );
  }

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadMyAvatar();
  }

  Future<void> _loadMyAvatar() async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;

    if (user == null) return;

    try {
      final res = await client
          .from('profiles')
          .select('avatar_url')
          .eq('id', user.id)
          .maybeSingle();

      if (res != null && mounted) {
        setState(() {
          _avatarUrl = res['avatar_url'] as String?;
        });
      }
    } catch (_) {
      // không cần thông báo lỗi
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorName.backgroundWhite,
        title: RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            children: [
              TextSpan(
                text: 'City',
                style: TextStyle(color: Colors.black),
              ),
              TextSpan(
                text: ' Life',
                style: TextStyle(color: ColorName.mint),
              ),
            ],
          ),
        ),
        actions: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                color: Colors.grey.shade300,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const FaIcon(
                    FontAwesomeIcons.magnifyingGlass,
                    color: Colors.black,
                    size: 20,
                  ),
                  onPressed: () {
                    context.router.replace(const SearchRoute());
                  },
                ),
                IconButton(
                  icon: const FaIcon(
                    FontAwesomeIcons.bell,
                    color: Colors.black,
                    size: 20,
                  ),
                  onPressed: () {
                    context.router.navigate(const NoticeRoute());
                  },
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () async {
                    final changed =
                        await context.router.push<bool>(const ProfileRoute());

                    if (changed == true) {
                      _loadMyAvatar();
                    }
                  },
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage:
                        (_avatarUrl != null && _avatarUrl!.isNotEmpty)
                            ? NetworkImage(_avatarUrl!)
                            : null,
                    child: (_avatarUrl == null || _avatarUrl!.isEmpty)
                        ? const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 18,
                          )
                        : null,
                  ),
                ),
              ],
            ),
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: ColorName.borderLight,
                  width: 0.5,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: ColorName.mint,
              labelColor: ColorName.textBlack,
              unselectedLabelColor: ColorName.textGray,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w400,
              ),
              tabs: const [
                Tab(text: 'For You'),
                Tab(text: 'Following'),
              ],
            ),
          ),
        ),
      ),

      /// Body
      body: TabBarView(
        controller: _tabController,
        children: const [
          PostList(),
          PostList(), // sau này bạn tách feed Following riêng
        ],
      ),
    );
  }
}
