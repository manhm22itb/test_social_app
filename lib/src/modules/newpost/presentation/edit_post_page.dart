// lib/src/modules/newpost/presentation/edit_post_page.dart

import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../generated/colors.gen.dart';
import '../../../common/utils/getit_utils.dart';
import '../domain/entities/post_entity.dart';
import '../domain/usecase/update_post_usecase.dart';
import 'widgets/create_post_app_bar.dart';
import 'widgets/post_content_field.dart';

@RoutePage()
class EditPostPage extends StatefulWidget {
  final PostEntity post;

  const EditPostPage({
    super.key,
    required this.post,
  });

  @override
  State<EditPostPage> createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  final TextEditingController _postController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  static const int _maxCharacters = 280;
  int _characterCount = 0;
  bool _isSubmitting = false;

  // dùng tạm giống CreatePostPage
  bool _isPublic = true;
  bool _isFriend = true;

  // xử lý image
  final ImagePicker _picker = ImagePicker();
  XFile? _newSelectedImage; // ảnh mới chọn
  bool _removeOldImage = false; // user muốn bỏ ảnh cũ

  @override
  void initState() {
    super.initState();
    _postController.text = widget.post.content;
    _characterCount = widget.post.content.length;

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

  Future<void> _pickNewImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _newSelectedImage = picked;
        _removeOldImage = false; // đã chọn ảnh mới thì không “remove” nữa
      });
    }
  }

  void _removeImage() {
    setState(() {
      _newSelectedImage = null;
      _removeOldImage = true; // bỏ ảnh cũ
    });
  }

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

      print('>>> [Edit] Upload image success: $publicUrl');
      return publicUrl;
    } catch (e, st) {
      print('>>> [Edit] Upload image ERROR: $e');
      print(st);
      return null;
    }
  }

  Future<void> _savePost() async {
    final newContent = _postController.text.trim();

    if (newContent.isEmpty && !_removeOldImage && _newSelectedImage == null) {
      _showErrorDialog(
          'Please write something or keep/add a photo before saving.');
      return;
    }

    if (newContent.length > _maxCharacters) {
      _showErrorDialog(
        'Post exceeds the character limit of $_maxCharacters.',
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      String? finalImageUrl;

      // 1. nếu chọn ảnh mới → upload
      if (_newSelectedImage != null) {
        finalImageUrl = await _uploadPostImage(_newSelectedImage!);
      } else if (_removeOldImage) {
        // 2. user muốn bỏ ảnh → gửi null
        finalImageUrl = null;
      } else {
        // 3. giữ ảnh cũ như backend đang có
        finalImageUrl = widget.post.imageUrl;
      }

      // Gọi usecase trực tiếp, KHÔNG dùng PostCubit nữa
      final updateUseCase = getIt<UpdatePostUseCase>();

      final updatedPost = await updateUseCase(
        widget.post.id,
        content: newContent,
        imageUrl: finalImageUrl,
      );

      print('>>> [Edit] Updated post = ${updatedPost.id}');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // pop(true) để Home có thể reload nếu muốn
      context.router.pop(true);
    } catch (e, st) {
      print('>>> [Edit] ERROR: $e');
      print(st);
      if (!mounted) return;
      _showErrorDialog('Failed to update post. Please try again.');
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
        title: const Text('Cannot Save'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canSave = !_isSubmitting &&
        (_postController.text.trim().isNotEmpty ||
            !_removeOldImage ||
            _newSelectedImage != null) &&
        _characterCount <= _maxCharacters;

    return Scaffold(
      backgroundColor: ColorName.backgroundWhite,
      appBar: CreatePostAppBar(
        canPost: canSave,
        onPostPressed: _isSubmitting ? null : _savePost,
        onBackPressed: () => context.router.pop(),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PostContentField(
                    postController: _postController,
                    focusNode: _focusNode,
                    currentUsername: widget.post.authorName,
                    isPublic: _isPublic,
                    onPrivacyChanged: () {},
                    characterCount: _characterCount,
                    maxCharacters: _maxCharacters,
                  ),
                  const SizedBox(height: 12),

                  // preview ảnh
                  if (_newSelectedImage != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        File(_newSelectedImage!.path),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ] else if (!_removeOldImage &&
                      widget.post.imageUrl != null &&
                      widget.post.imageUrl!.isNotEmpty) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        widget.post.imageUrl!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],

                  const SizedBox(height: 8),

                  // nút Change / Remove
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: _isSubmitting ? null : _pickNewImage,
                        icon: const Icon(Icons.photo_outlined),
                        label: const Text('Change photo'),
                      ),
                      const SizedBox(width: 8),
                      if (widget.post.imageUrl != null &&
                              widget.post.imageUrl!.isNotEmpty ||
                          _newSelectedImage != null)
                        TextButton.icon(
                          onPressed: _isSubmitting ? null : _removeImage,
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          label: const Text(
                            'Remove',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
