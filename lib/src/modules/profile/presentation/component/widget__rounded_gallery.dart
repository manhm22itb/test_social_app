import 'package:flutter/material.dart';

import '../../../../../generated/colors.gen.dart';

class WidgetRoundedGallery extends StatelessWidget {
  final List<String> images;
  const WidgetRoundedGallery({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        Container(
          decoration: BoxDecoration(
            color: ColorName.white,
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: ColorName.black38.withOpacity(.08),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: images.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemBuilder: (_, i) => ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.network(images[i], fit: BoxFit.cover),
            ),
          ),
        ),
      ],
    );
  }
}
