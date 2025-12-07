import 'package:flutter/material.dart';

import '../../../../../generated/colors.gen.dart';
import 'widget__rounded_gallery.dart';


const _demoImages = [
  'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=1200',
  'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=1200',
  'https://images.unsplash.com/photo-1501785888041-af3ef285b470?w=1200',
];

const _demoImagesPhotos = [
  'https://images.unsplash.com/photo-1518091043644-c1d4457512c6?w=1200',
  'https://images.unsplash.com/photo-1595341888016-a392ef81b7de?w=1200',
  'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=1200',
];

class WidgetTabAndContent extends StatelessWidget {
  const WidgetTabAndContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F9F9),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const TabBar(
            labelColor: ColorName.black,
            unselectedLabelColor: ColorName.black45,
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(width: 2, color: ColorName.black),
              insets: EdgeInsets.symmetric(horizontal: 22),
            ),
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Photos'),
              Tab(text: 'Videos'),
            ],
          ),
        ),
        SizedBox(
          height: 700,
          child: const TabBarView(
            physics: NeverScrollableScrollPhysics(),
            children: [
              WidgetRoundedGallery(images: _demoImages),
              WidgetRoundedGallery(images: _demoImagesPhotos),
              Center(child: Text('Videos — Coming soon')),
            ],
          ),
        ),
      ],
    );
  }
}
