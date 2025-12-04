import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../generated/colors.gen.dart';

class LikeButton extends StatefulWidget {
  final bool isLiked;
  final int likeCount;
  final VoidCallback onPressed;

  const LikeButton({
    super.key,
    required this.isLiked,
    required this.likeCount,
    required this.onPressed,
  });

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _colorAnimation = ColorTween(
      begin: ColorName.textLightGray,
      end: ColorName.likeRed,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Set initial state
    if (widget.isLiked) {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(LikeButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLiked != oldWidget.isLiked) {
      if (widget.isLiked) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (!widget.isLiked) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: Row(
        children: [
          ScaleTransition(
            scale: _scaleAnimation,
            child: AnimatedBuilder(
              animation: _colorAnimation,
              builder: (context, child) {
                return FaIcon(
                  widget.isLiked ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
                  color: _colorAnimation.value,
                  size: 18,
                );
              },
            ),
          ),
          const SizedBox(width: 6),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              color: widget.isLiked ? ColorName.likeRed : ColorName.textLightGray,
              fontSize: 13,
            ),
            child: Text(
              _formatCount(widget.likeCount),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count < 1000) return count.toString();
    if (count < 1000000) return '${(count / 1000).toStringAsFixed(1)}K';
    return '${(count / 1000000).toStringAsFixed(1)}M';
  }
}