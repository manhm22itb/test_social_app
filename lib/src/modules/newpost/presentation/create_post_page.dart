// lib/src/modules/newpost/presentation/create_post_page.dart

import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../generated/colors.gen.dart';
import '../../../common/utils/getit_utils.dart';
import '../../auth/presentation/cubit/auth_cubit.dart';
import '../../auth/presentation/cubit/auth_state.dart';
import '../domain/usecase/create_post_usecase.dart';
import 'widgets/create_post_app_bar.dart';
import 'widgets/post_action_bar.dart';
import 'widgets/post_content_field.dart';

/// 2 chế độ hiển thị bài viết
enum PostVisibility { public, private }

extension PostVisibilityX on PostVisibility {
  String get label {
    switch (this) {
      case PostVisibility.public:
        return 'Public';
      case PostVisibility.private:
        return 'Private';
    }
  }

  IconData get icon {
    switch (this) {
      case PostVisibility.public:
        return Icons.public;
      case PostVisibility.private:
        return Icons.lock;
    }
  }

  /// Giá trị gửi lên backend: 'public' | 'private'
  String get backendValue {
    switch (this) {
      case PostVisibility.public:
        return 'public';
      case PostVisibility.private:
        return 'private';
    }
  }
}

@RoutePage()
class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final TextEditingController _postController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  static const int _maxCharacters = 280;
  int _characterCount = 0;

  bool _isSubmitting = false;

  /// Trạng thái hiển thị bài viết
  PostVisibility _visibility = PostVisibility.public;

  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;

  @override
  void initState() {
    super.initState();
    _postController.addListener(() {
      setState(() {
        _characterCount = _postController.text.length;
      });
    });
  }

  @override
  void dispose() {
    _postController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // chọn ảnh
  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = picked;
      });
    }
  }

  // upload ảnh lên Supabase bucket 'post-images'
  Future<String?> _uploadPostImage(XFile image) async {
    try {
      final client = Supabase.instance.client;
      final bytes = await image.readAsBytes();

      final fileExt = image.path.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = 'posts/$fileName';

      await client.storage.from('post-images').uploadBinary(
            filePath,
            bytes,
            fileOptions: FileOptions(
              contentType: 'image/$fileExt',
              upsert: false,
            ),
          );

      final publicUrl =
          client.storage.from('post-images').getPublicUrl(filePath);

      print('>>> [Create] Upload image success: $publicUrl');
      return publicUrl;
    } catch (e, st) {
      print('>>> [Create] Upload image ERROR: $e');
      print(st);
      return null;
    }
  }

  /// Bottom sheet chọn Public / Private
  Future<void> _showVisibilitySheet() async {
    final selected = await showModalBottomSheet<PostVisibility>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Icon(PostVisibility.public.icon),
                title: Text(PostVisibility.public.label),
                trailing: _visibility == PostVisibility.public
                    ? const Icon(Icons.check)
                    : null,
                onTap: () => Navigator.of(ctx).pop(PostVisibility.public),
              ),
              ListTile(
                leading: Icon(PostVisibility.private.icon),
                title: Text(PostVisibility.private.label),
                trailing: _visibility == PostVisibility.private
                    ? const Icon(Icons.check)
                    : null,
                onTap: () => Navigator.of(ctx).pop(PostVisibility.private),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );

    if (selected != null && selected != _visibility) {
      setState(() {
        _visibility = selected;
      });
    }
  }

  Future<void> _createPost() async {
    final content = _postController.text.trim();
    print(
        '>>> [Create] _createPost content="$content", visibility=${_visibility.backendValue}');

    if (content.isEmpty && _selectedImage == null) {
      _showErrorDialog(
        'Please write something or add a photo before posting.',
      );
      return;
    }

    if (_characterCount > _maxCharacters) {
      _showErrorDialog(
        'Post exceeds the character limit of $_maxCharacters.',
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      String? imageUrl;

      // nếu có ảnh thì upload trước
      if (_selectedImage != null) {
        imageUrl = await _uploadPostImage(_selectedImage!);
      }

      // gọi usecase trực tiếp qua getIt
      final createUseCase = getIt<CreatePostUseCase>();

      final newPost = await createUseCase(
        content,
        imageUrl: imageUrl,
        visibility: _visibility.backendValue, // 'public' | 'private'
      );

      print('>>> [Create] New post id=${newPost.id}');

      if (!mounted) return;

      // clear form
      _postController.clear();
      setState(() {
        _selectedImage = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      context.router.pop(true);
      // báo cho Home biết là vừa tạo post xong
      context.router.pop(true);
    } catch (e, st) {
      print('>>> [Create] ERROR: $e');
      print(st);
      if (!mounted) return;
      _showErrorDialog('Failed to create post. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cannot Post'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 Lấy thông tin user đang đăng nhập từ AuthCubit
    final authState = context.watch<AuthCubit>().state;

    final currentUser = authState.maybeWhen(
      userInfoLoaded: (user) => user,
      orElse: () => null,
    );

    final currentUsername = currentUser?.username ?? 'User';

    final canPost = !_isSubmitting &&
        (_postController.text.trim().isNotEmpty || _selectedImage != null) &&
        _characterCount <= _maxCharacters;

    return Scaffold(
      backgroundColor: ColorName.backgroundWhite,
      appBar: CreatePostAppBar(
        canPost: canPost,
        onPostPressed: _isSubmitting ? null : _createPost,
        onBackPressed: () {
          print('>>> [CreatePostPage] Back callback');
          context.router.maybePop(); // hoặc Navigator.of(context).maybePop();
        },
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  PostContentField(
                    postController: _postController,
                    focusNode: _focusNode,
                    currentUsername: currentUsername,
                    isPublic: _visibility == PostVisibility.public,
                    onPrivacyChanged:
                        _showVisibilitySheet, // 👈 bấm chip để chọn
                    characterCount: _characterCount,
                    maxCharacters: _maxCharacters,
                  ),
                  if (_selectedImage != null) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        File(_selectedImage!.path),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          PostActionBar(
            postController: _postController,
            onClearPost: () {
              _postController.clear();
              setState(() {
                _selectedImage = null;
              });
            },
            onAddPhoto: _pickImage,
            onAddMention: () {},
            onAddEmoji: () {},
          ),
        ],
      ),
    );
  }
}
