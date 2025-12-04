import 'package:flutter/material.dart';
import '../../../../../generated/colors.gen.dart';

import '../models/trending_topic.dart';

class TrendingTopicItem extends StatelessWidget {
  final TrendingTopic topic;
  final int rank;

  const TrendingTopicItem({
    super.key,
    required this.topic,
    required this.rank,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorName.backgroundWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorName.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Trending in ${topic.category}',
                style: TextStyle(
                  color: ColorName.textGray,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Text(
                '#$rank',
                style: TextStyle(
                  color: ColorName.navBackground,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            topic.title,
            style: TextStyle(
              color: ColorName.textBlack,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${topic.postsCount} posts',
            style: TextStyle(
              color: ColorName.textGray,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}