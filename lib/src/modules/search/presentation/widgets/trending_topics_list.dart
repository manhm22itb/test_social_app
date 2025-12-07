import 'package:flutter/material.dart';
import '../models/trending_topic.dart';
import 'trending_topic_item.dart';

class TrendingTopicsList extends StatelessWidget {
  final List<TrendingTopic> trendingTopics;

  const TrendingTopicsList({
    super.key,
    required this.trendingTopics,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: trendingTopics.length,
      itemBuilder: (context, index) {
        final topic = trendingTopics[index];
        return TrendingTopicItem(
          topic: topic,
          rank: index + 1,
        );
      },
    );
  }
}