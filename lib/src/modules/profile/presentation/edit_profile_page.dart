import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../generated/colors.gen.dart';
import 'cubit/profile_cubit.dart';
import '../../../common/utils/getit_utils.dart';

@RoutePage()
class EditProfilePage extends StatefulWidget implements AutoRouteWrapper {
  const EditProfilePage({
    super.key,
    required this.initialUsername,
    this.initialBio,
    this.initialAvatarUrl,
  });

  final String initialUsername;
  final String? initialBio;
  final String? initialAvatarUrl;

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<ProfileCubit>(
      create: (_) => getIt<ProfileCubit>(),
      child: this,
    );
  }

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final TextEditingController _usernameController;
  late final TextEditingController _bioController;

  final _picker = ImagePicker();
  XFile? _pickedImage;
  bool _isSaving = false;

  // TODO: thay bằng token thật
  final String _dummyToken = 'YOUR_ACCESS_TOKEN';

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.initialUsername);
    _bioController = TextEditingController(text: widget.initialBio ?? '');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (image != null) {
      setState(() {
        _pickedImage = image;
      });
    }
  }

  Future<String?> _uploadAvatar(XFile file) async {
    final client = Supabase.instance.client;

    final bytes = await file.readAsBytes();
    final ext = file.path.split('.').last;
    final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.$ext';

    const bucket = 'avatars';
    final path = 'public/$fileName';

    await client.storage.from(bucket).uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );

    final publicUrl = client.storage.from(bucket).getPublicUrl(path);
    return publicUrl;
  }

  Future<void> _onSave() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      String? avatarUrl = widget.initialAvatarUrl;

      if (_pickedImage != null) {
        avatarUrl = await _uploadAvatar(_pickedImage!);
      }

      final username = _usernameController.text.trim();
      final bio = _bioController.text.trim();

      await context.read<ProfileCubit>().updateProfile(
            token: _dummyToken,
            username: username.isEmpty ? null : username,
            bio: bio.isEmpty ? null : bio,
            avatarUrl: avatarUrl,
          );

      if (mounted) {
        final updatedUsername =
            username.isEmpty ? widget.initialUsername : username;
        final updatedBio = bio.isEmpty ? null : bio;

        // 👇 Trả FULL thông tin mới về cho ProfilePage
        context.router.pop<Map<String, dynamic>>({
          'username': updatedUsername,
          'bio': updatedBio,
          'avatarUrl': avatarUrl,
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cập nhật thất bại: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatarRadius = 40.0;

    // 👇 sửa kiểu cho chuẩn ImageProvider
    late final ImageProvider currentAvatar;
    if (_pickedImage != null) {
      currentAvatar = FileImage(File(_pickedImage!.path));
    } else if (widget.initialAvatarUrl != null) {
      currentAvatar = NetworkImage(widget.initialAvatarUrl!);
    } else {
      currentAvatar = const AssetImage('assets/images/default_avatar.png');
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit profile'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _onSave,
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: avatarRadius,
                    backgroundImage: currentAvatar,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: _pickAvatar,
                      borderRadius: BorderRadius.circular(20),
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: ColorName.mint,
                        child: const Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _bioController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Bio',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
