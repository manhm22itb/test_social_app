import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/src/common/utils/getit_utils.dart';
import 'package:social_app/src/modules/app/app_router.dart'; // Import Router để dùng các Route (UserProfileRoute, CommentRoute)
import 'package:social_app/src/modules/home/presentation/widgets/post_item.dart';
import 'package:social_app/src/modules/search/domain/entities/search_result.dart';
import 'package:social_app/src/modules/search/presentation/cubit/search_cubit.dart';
import 'package:social_app/src/modules/search/presentation/cubit/search_state.dart';
import 'package:social_app/src/modules/search/presentation/widgets/search_app_bar.dart';
import 'package:social_app/src/modules/search/presentation/widgets/user_item.dart';

@RoutePage()
class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SearchCubit>(),
      child: const _SearchPageView(),
    );
  }
}

class _SearchPageView extends StatefulWidget {
  const _SearchPageView();

  @override
  State<_SearchPageView> createState() => _SearchPageViewState();
}

class _SearchPageViewState extends State<_SearchPageView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Lắng nghe sự kiện chuyển tab để gọi API lại
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        context.read<SearchCubit>().onTypeChanged(_tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SearchAppBar(
        controller: _searchController,
        tabController: _tabController,
        onBackPressed: () => context.router.back(),
        onChanged: (query) => context.read<SearchCubit>().onSearchChanged(query),
      ),
      body: BlocBuilder<SearchCubit, SearchState>(
        builder: (context, state) {
          return state.when(
            initial: () => const Center(child: Text("Enter keyword to search")),
            loading: () => const Center(child: CircularProgressIndicator()),
            failure: (msg) => Center(child: Text(msg)),
            success: (result) => TabBarView(
              controller: _tabController,
              children: [
                _buildAllTab(result),   // Tab 1: All
                _buildPostsList(result), // Tab 2: Posts
                _buildUsersList(result), // Tab 3: Users
              ],
            ),
          );
        },
      ),
    );
  }

  // --- Widgets hiển thị danh sách ---

  Widget _buildPostsList(SearchResult result) {
    if (result.posts.isEmpty) return const Center(child: Text("No posts found"));
    return ListView.separated(
      itemCount: result.posts.length,
      padding: const EdgeInsets.all(8),
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (ctx, i) {
        final post = result.posts[i];
        return PostItem(
          post: post,
          // 1. Thả tim: Gọi Cubit xử lý logic
          onLikePressed: (){
             context.read<SearchCubit>().toggleLike(post);
          },
          // 2. Bình luận: Chuyển sang CommentPage (truyền object PostEntity)
          onCommentPressed: (){
             context.router.push(CommentRoute(post: post));
          },
          onRepostPressed: (){},
          onMorePressed: (){},
          // 3. Tác giả: Chuyển sang UserProfilePage (truyền userId)
          onAuthorPressed: (){
             context.router.push(UserProfileRoute(userId: post.authorId));
          }, onSharePressed: () {  },
        );
      },
    );
  }

  Widget _buildUsersList(SearchResult result) {
    if (result.users.isEmpty) return const Center(child: Text("No users found"));
    return ListView.builder(
      itemCount: result.users.length,
      itemBuilder: (ctx, i) {
        final user = result.users[i];
        return UserItem(
          user: user, 
          // 4. Click vào User Item -> Chuyển sang Profile
          onTap: () {
            context.router.push(UserProfileRoute(userId: user.id));
          }
        );
      },
    );
  }

  Widget _buildAllTab(SearchResult result) {
    if (result.posts.isEmpty && result.users.isEmpty) {
      return const Center(child: Text("No results found"));
    }
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (result.users.isNotEmpty) ...[
            const Padding(padding: EdgeInsets.all(8.0), child: Text("Users", style: TextStyle(fontWeight: FontWeight.bold))),
            ...result.users.take(3).map((u) => UserItem(
              user: u, 
              onTap: (){
                context.router.push(UserProfileRoute(userId: u.id));
              }
            )), 
            if (result.users.length > 3) 
               TextButton(onPressed: () => _tabController.animateTo(2), child: const Text("See all users")),
            const Divider(),
          ],
          if (result.posts.isNotEmpty) ...[
             const Padding(padding: EdgeInsets.all(8.0), child: Text("Posts", style: TextStyle(fontWeight: FontWeight.bold))),
             ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: result.posts.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (ctx, i) {
                  final post = result.posts[i];
                  return PostItem(
                    post: post,
                    onLikePressed: (){
                       context.read<SearchCubit>().toggleLike(post);
                    },
                    onCommentPressed: (){
                       context.router.push(CommentRoute(post: post));
                    },
                    onRepostPressed: (){},
                    onMorePressed: (){},
                    onAuthorPressed: (){
                       context.router.push(UserProfileRoute(userId: post.authorId));
                    }, onSharePressed: () {  },
                  );
                },
             ),
          ]
        ],
      ),
    );
  }
}