import 'package:flutter/material.dart';
import 'widget__section_title.dart';

class WidgetGalleryGrid extends StatelessWidget {
  const WidgetGalleryGrid({super.key});

  final _images = const [
    'https://images.unsplash.com/photo-1595341888016-a392ef81b7de?w=800',
    'https://images.unsplash.com/photo-1495567720989-cebdbdd97913?w=800',
    'https://images.unsplash.com/photo-1503023345310-bd7c1de61c7d?w=800',
    'https://images.unsplash.com/photo-1517649763962-0c623066013b?w=800',
    'https://images.unsplash.com/photo-1501785888041-af3ef285b470?w=800',
    'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=800',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const WidgetSectionTitle('Gallery'),
        const SizedBox(height: 8),
        GridView.count(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1,
          children: _images
              .map((u) => ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(u, fit: BoxFit.cover),
                  ))
              .toList(),
        ),
      ],
    );
  }
}
