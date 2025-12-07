// lib/src/modules/profile/presentation/profile_page.dart

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

import '../../../../generated/colors.gen.dart';
import '../../../common/utils/getit_utils.dart';
import '../../app/app_router.dart';
import '../../auth/presentation/cubit/auth_cubit.dart';
import '../../auth/presentation/cubit/auth_state.dart' as auth;
// Post + getIt
import '../../newpost/presentation/cubit/post_cubit.dart';
import 'component/user_gallery_grid.dart';
// 2 widget mới dùng PostCubit
import 'component/user_posts_tab.dart';
import 'component/widget__placeholder.dart';
import 'component/widget__section_title.dart';
import 'component/widget__stats_card.dart';
import 'cubit/profile_cubit.dart';

@RoutePage()
class ProfilePage extends StatefulWidget implements AutoRouteWrapper {
  const ProfilePage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // PostCubit cho tab Post / gallery
        BlocProvider<PostCubit>(
          create: (_) => getIt<PostCubit>()..loadFeed(),
        ),

        // 🔥 ProfileCubit để lấy stats thật (my profile)
        BlocProvider<ProfileCubit>(
          create: (_) {
            final cubit = getIt<ProfileCubit>();

            final token =
                Supabase.instance.client.auth.currentSession?.accessToken;

            if (token != null) {
              cubit.loadMyProfile(token);
            }
            return cubit;
          },
        ),
      ],
      child: this,
    );
  }

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const double _avatarRadius = 38;
  static const double _horizontalMargin = 24;
  static const double _tabBarHeight = 48;
  static final double _expandedHeight = 310 + _avatarRadius * 1.5;

  String? _profileBio; // bio hiện tại hiển thị trên profile
  String? _avatarUrl; // avatar hiện tại hiển thị trên profile
  String? _displayUsername; // ⭐ username lấy từ bảng profiles

  @override
  void initState() {
    super.initState();
    _loadProfileFromSupabase();
  }

  Future<void> _loadProfileFromSupabase() async {
    try {
      final client = Supabase.instance.client;
      final currentUser = client.auth.currentUser;
      if (currentUser == null) return;

      // ⭐ Lấy luôn username từ bảng profiles
      final res = await client
          .from('profiles')
          .select('username, bio, avatar_url')
          .eq('id', currentUser.id)
          .maybeSingle();

      final username = res?['username'] as String?;
      final bio = res?['bio'] as String?;
      final avatar = res?['avatar_url'] as String?;

      if (!mounted) return;
      setState(() {
        _displayUsername = username;
        _profileBio = bio;
        _avatarUrl = avatar;
      });
    } catch (_) {
      // ignore lỗi, giữ state cũ
    }
  }

  Future<void> _openEditProfile(BuildContext context) async {
    final authState = context.read<AuthCubit>().state;
    final user = authState.maybeWhen(
      userInfoLoaded: (u) => u,
      orElse: () => null,
    );

    if (user == null) return;

    // Dùng username từ profiles nếu có, fallback về AuthCubit
    final initialUsername = _displayUsername ?? user.username ?? '';

    final result = await context.router.push<String?>(
      EditProfileRoute(
        initialUsername: initialUsername,
        initialBio: _profileBio,
        initialAvatarUrl: _avatarUrl,
      ),
    );

    // ignore: avoid_print
    print('EditProfileRoute result = $result');

    if (!mounted) return;

    // Vẫn giữ logic cũ: nếu EditProfile trả về bio, cập nhật ngay
    if (result != null) {
      setState(() {
        _profileBio = result; // cập nhật bio từ màn edit (nếu có)
      });
    }

    // ⭐ Quan trọng: reload lại từ Supabase để lấy username & avatar mới
    await _loadProfileFromSupabase();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, auth.AuthState>(
      listener: (context, state) {
        state.whenOrNull(
          unauthenticated: (emailError, passwordError, errorMessage,
              isEmailValid, isPasswordValid) {
            context.router.replaceAll([const LoginRoute()]);
          },
          failure: (message) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message)),
            );
          },
        );
      },
      child: DefaultTabController(
        length: 4,
        child: Scaffold(
          backgroundColor: ColorName.softBg,
          body: NestedScrollView(
            headerSliverBuilder: (context, inner) => [
              SliverAppBar(
                pinned: true,
                expandedHeight: _expandedHeight,
                backgroundColor: ColorName.white,
                surfaceTintColor: ColorName.white,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Color(0xFF9CA3AF),
                    size: 22,
                  ),
                  onPressed: () => context.router.pop(),
                ),
                actions: [
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_horiz,
                      color: inner ? ColorName.black87 : ColorName.white,
                    ),
                    onSelected: (value) async {
                      if (value == 'logout') {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Logout'),
                            content:
                                const Text('Are you sure you want to logout?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(true),
                                child: const Text('Logout'),
                              ),
                            ],
                          ),
                        );

                        if (ok == true) {
                          context.read<AuthCubit>().signOut();
                        }
                      }
                    },
                    itemBuilder: (ctx) => const [
                      PopupMenuItem(
                        value: 'logout',
                        child: Text('Logout'),
                      ),
                    ],
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        'https://images.unsplash.com/photo-1495562569060-2eec283d3391?q=80&w=1600&auto=format&fit=crop',
                        fit: BoxFit.cover,
                      ),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              ColorName.black26,
                            ],
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: _horizontalMargin,
                            right: _horizontalMargin,
                            bottom: _avatarRadius - 6,
                          ),
                          child: _ProfileCard(
                            avatarRadius: _avatarRadius,
                            bio: _profileBio,
                            avatarUrl: _avatarUrl,
                            displayUsername: _displayUsername, // ⭐ dùng tên mới
                            onEditPressed: () => _openEditProfile(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(_tabBarHeight),
                  child: Container(
                    padding: const EdgeInsets.only(left: 8, right: 16),
                    color: ColorName.white,
                    child: const TabBar(
                      isScrollable: true,
                      labelColor: ColorName.black,
                      unselectedLabelColor: ColorName.black54,
                      indicatorColor: ColorName.black,
                      indicatorWeight: 2,
                      indicatorSize: TabBarIndicatorSize.label,
                      labelPadding: EdgeInsets.symmetric(horizontal: 20),
                      tabs: [
                        Tab(text: 'All'),
                        Tab(text: 'Post'),
                        Tab(text: 'Replies'),
                        Tab(text: 'Media'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            body: TabBarView(
              children: [
                const _AllTab(),
                Builder(
                  builder: (context) {
                    final userId = context
                            .read<AuthCubit>()
                            .state
                            .whenOrNull(userInfoLoaded: (u) => u.id) ??
                        '';
                    if (userId.isEmpty) {
                      return const Center(
                          child: Text('No user info loaded yet.'));
                    }
                    return UserPostsTab(userId: userId);
                  },
                ),
                const WidgetPlaceholder(text: 'Replies'),
                const WidgetPlaceholder(text: 'Media'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final double avatarRadius;
  final String? bio;
  final String? avatarUrl;
  final String? displayUsername; // ⭐ username override từ profiles
  final VoidCallback? onEditPressed;

  const _ProfileCard({
    super.key,
    required this.avatarRadius,
    this.bio,
    this.avatarUrl,
    this.displayUsername,
    this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    final double nameBlockTopPadding = 18;
    final double nameBlockHeight =
        (2 * avatarRadius) + nameBlockTopPadding + 10;

    return BlocBuilder<AuthCubit, auth.AuthState>(
      builder: (context, state) {
        final user =
            state.maybeWhen(userInfoLoaded: (user) => user, orElse: () => null);

        // ⭐ Ưu tiên username lấy từ profiles, fallback về AuthCubit
        final nameToShow = displayUsername ?? user?.username ?? 'User Name';

        // avatar cho header profile
        late final ImageProvider avatarImage;
        if (avatarUrl != null && avatarUrl!.isNotEmpty) {
          avatarImage = NetworkImage(avatarUrl!);
        } else {
          avatarImage = const AssetImage('assets/images/default_avatar.png');
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 0),
          padding: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            color: ColorName.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: ColorName.black15,
                blurRadius: 25,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: nameBlockHeight,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: 0,
                      right: 0,
                      top: avatarRadius + 5,
                      child: Column(
                        children: [
                          Text(
                            nameToShow,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: ColorName.black87,
                            ),
                          ),
                          Text(
                            user?.email ?? 'email@example.com',
                            style: TextStyle(
                              color: ColorName.grey600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      top: -avatarRadius,
                      child: Center(
                        child: CircleAvatar(
                          radius: avatarRadius,
                          backgroundImage: avatarImage,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Text(
                        bio ?? 'Viết đôi dòng giới thiệu về bạn…',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: ColorName.grey800,
                          height: 1.25,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 42,
                              child: ElevatedButton(
                                onPressed:
                                    (user == null || onEditPressed == null)
                                        ? null
                                        : onEditPressed,
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: ColorName.mint,
                                  foregroundColor: ColorName.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Edit',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () {
                              context.router.replace(const SettingsRoute());
                            },
                            child: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: ColorName.mint.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.settings_rounded,
                                color: ColorName.mint,
                                size: 22,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AllTab extends StatelessWidget {
  const _AllTab();

  @override
  Widget build(BuildContext context) {
    final userId = context
            .read<AuthCubit>()
            .state
            .whenOrNull(userInfoLoaded: (u) => u.id) ??
        '';

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
      children: [
        const WidgetSectionTitle('Followers'),
        const SizedBox(height: 8),
        _FollowersPreviewRow(userId: userId),
        const SizedBox(height: 16),
        _TwoColumnStatsAndGallery(userId: userId),
      ],
    );
  }
}

class _FollowersPreviewRow extends StatefulWidget {
  final String userId;

  const _FollowersPreviewRow({required this.userId});

  @override
  State<_FollowersPreviewRow> createState() => _FollowersPreviewRowState();
}

class _FollowerPreview {
  final String id;
  final String username;
  final String? avatarUrl;

  _FollowerPreview({
    required this.id,
    required this.username,
    this.avatarUrl,
  });
}

class _FollowersPreviewRowState extends State<_FollowersPreviewRow> {
  bool _loading = true;
  final List<_FollowerPreview> _followers = [];

  @override
  void initState() {
    super.initState();
    _loadFollowers();
  }

  Future<void> _loadFollowers() async {
    try {
      final client = Supabase.instance.client;

      // lấy tối đa 4 follower đầu tiên của userId
      final rows = await client
          .from('follows')
          .select('follower_id')
          .eq('following_id', widget.userId)
          .limit(4);

      final List data = (rows as List?) ?? [];
      if (data.isEmpty) {
        if (!mounted) return;
        setState(() {
          _followers.clear();
          _loading = false;
        });
        return;
      }

      final futures = data.map((e) async {
        final followerId = e['follower_id'] as String?;
        if (followerId == null) return null;

        final profile = await client
            .from('profiles')
            .select('id, username, avatar_url')
            .eq('id', followerId)
            .maybeSingle();

        if (profile == null) return null;

        return _FollowerPreview(
          id: profile['id'] as String,
          username: (profile['username'] as String?) ?? '',
          avatarUrl: profile['avatar_url'] as String?,
        );
      }).toList();

      final results = await Future.wait(futures);
      final valid = results.whereType<_FollowerPreview>().toList();

      if (!mounted) return;
      setState(() {
        _followers
          ..clear()
          ..addAll(valid);
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _followers.clear();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading && _followers.isEmpty) {
      return const SizedBox(
        height: 56,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Row(
      children: [
        if (_followers.isEmpty)
          const Text(
            'No followers yet',
            style: TextStyle(color: ColorName.grey600),
          )
        else
          ..._followers.map(
            (f) => Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: () {
                  context.router.push(
                    UserProfileRoute(userId: f.id),
                  );
                },
                child: CircleAvatar(
                  radius: 18,
                  backgroundImage:
                      (f.avatarUrl != null && f.avatarUrl!.isNotEmpty)
                          ? NetworkImage(f.avatarUrl!)
                          : null,
                  child: (f.avatarUrl == null || f.avatarUrl!.isEmpty)
                      ? Text(
                          f.username.isNotEmpty
                              ? f.username[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
              ),
            ),
          ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.more_horiz),
          tooltip: 'View all followers',
          onPressed: () {
            context.router.push(
              FollowersRoute(userId: widget.userId),
            );
          },
        ),
      ],
    );
  }
}

class _TwoColumnStatsAndGallery extends StatelessWidget {
  final String userId;
  const _TwoColumnStatsAndGallery({required this.userId});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final isNarrow = c.maxWidth < 360;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: isNarrow ? 96 : 110,
              child: WidgetStatsCard(
                onPostsTap: () {
                  final controller = DefaultTabController.of(context);
                  controller?.animateTo(1);
                },
                onFollowingTap: () async {
                  final changed = await context.router.push(
                    FollowingRoute(userId: userId),
                  );
                  if (changed == true && context.mounted) {
                    final token = Supabase
                        .instance.client.auth.currentSession?.accessToken;
                    if (token != null) {
                      context.read<ProfileCubit>().loadMyProfile(token);
                    }
                  }
                },
                onFollowersTap: () async {
                  final changed = await context.router.push(
                    FollowersRoute(userId: userId),
                  );
                  if (changed == true && context.mounted) {
                    final token = Supabase
                        .instance.client.auth.currentSession?.accessToken;
                    if (token != null) {
                      context.read<ProfileCubit>().loadMyProfile(token);
                    }
                  }
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: UserGalleryGrid(userId: userId),
            ),
          ],
        );
      },
    );
  }
}
