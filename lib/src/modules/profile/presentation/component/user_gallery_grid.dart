import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../newpost/presentation/cubit/post_cubit.dart';
import '../../../newpost/domain/entities/post_entity.dart';

class UserGalleryGrid extends StatelessWidget {
  final String userId;

  const UserGalleryGrid({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostCubit, PostState>(
      builder: (_, state) {
        if (state is! PostStateLoaded) return const SizedBox();

        // lọc ảnh
        final images = state.posts
            .where(
              (p) =>
                  p.authorId == userId &&
                  p.imageUrl != null &&
                  p.imageUrl!.isNotEmpty,
            )
            .toList();

        if (images.isEmpty) {
          return const Text("No photos yet.");
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemCount: images.length,
          itemBuilder: (_, i) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                images[i].imageUrl!,
                fit: BoxFit.cover,
              ),
            );
          },
        );
      },
    );
  }
}
