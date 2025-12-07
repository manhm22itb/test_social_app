import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../generated/colors.gen.dart';
import '../../../../common/utils/getit_utils.dart';
import '../../../app/app_router.dart';
import '../../domain/entities/blocked_user_entity.dart';
import '../../domain/usecase/get_block_list_usecase.dart';
import '../../domain/usecase/unblock_user_usecase.dart';

@RoutePage()
class BlockedUsersPage extends StatefulWidget {
  const BlockedUsersPage({super.key});

  @override
  State<BlockedUsersPage> createState() => _BlockedUsersPageState();
}

class _BlockedUsersPageState extends State<BlockedUsersPage> {
  bool _isLoading = true;
  String? _error;
  List<BlockedUserEntity> _items = [];

  late final GetBlockedUsersUseCase _getBlockedUsersUseCase;
  late final UnblockUserUseCase _unblockUserUseCase;

  @override
  void initState() {
    super.initState();
    _getBlockedUsersUseCase = getIt<GetBlockedUsersUseCase>();
    _unblockUserUseCase = getIt<UnblockUserUseCase>();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final list = await _getBlockedUsersUseCase();
      setState(() {
        _items = list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _unblockUser(BlockedUserEntity user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Unblock user'),
        content: Text('Do you want to unblock @${user.username}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Unblock'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final ok = await _unblockUserUseCase(user.userId);
      if (!mounted) return;

      if (ok) {
        setState(() {
          _items.removeWhere((e) => e.userId == user.userId);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unblocked @${user.username}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to unblock user')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorName.backgroundLight,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: ColorName.backgroundWhite,
        title: const Text(
          'Blocked accounts',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.router.pop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return ListView(
        children: [
          const SizedBox(height: 80),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Error: $_error',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      );
    }

    if (_items.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 80),
          Icon(
            Icons.block,
            size: 60,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              'No blocked accounts',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Users you block will appear here.\nThey can\'t follow or see your content.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _items.length,
      separatorBuilder: (_, __) => const Divider(
        height: 1,
        indent: 72,
        color: Color(0xFFE5E5E5),
      ),
      itemBuilder: (context, index) {
        final user = _items[index];
        final dateText = DateFormat('MMM d, yyyy').format(user.createdAt);

        return ListTile(
          leading: CircleAvatar(
            radius: 24,
            backgroundColor: Colors.grey.shade300,
            backgroundImage: (user.avatarUrl != null &&
                    (user.avatarUrl?.isNotEmpty ?? false))
                ? NetworkImage(user.avatarUrl!)
                : null,
            child: (user.avatarUrl == null || user.avatarUrl!.isEmpty)
                ? Text(
                    (user.username.isNotEmpty ? user.username[0] : '?')
                        .toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          title: Text(
            user.username,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          subtitle: Text(
            'Blocked · $dateText',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          trailing: OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            onPressed: () => _unblockUser(user),
            child: const Text(
              'Unblock',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        );
      },
    );
  }
}
