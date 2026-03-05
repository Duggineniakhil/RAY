import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reelify/core/theme/app_theme.dart';
import 'package:reelify/features/video_feed/domain/models/video_model.dart';

class ActionButtons extends StatelessWidget {
  final VideoModel video;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onProfile;

  const ActionButtons({
    super.key,
    required this.video,
    this.onLike,
    this.onComment,
    this.onShare,
    this.onProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Creator avatar
        GestureDetector(
          onTap: onProfile,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  image: video.creatorAvatar.isEmpty
                      ? null
                      : DecorationImage(
                          image: NetworkImage(video.creatorAvatar),
                          fit: BoxFit.cover,
                        ),
                  color: AppColors.surface,
                ),
                child: video.creatorAvatar.isEmpty
                    ? const Icon(Icons.person_rounded,
                        color: Colors.white, size: 28)
                    : null,
              ),
              Positioned(
                bottom: -6,
                left: 12,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                    border: Border.all(color: Colors.black, width: 1.5),
                  ),
                  child: const Icon(Icons.add_rounded,
                      color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Like button
        _ActionItem(
          icon: video.isLikedByCurrentUser
              ? Icons.favorite_rounded
              : Icons.favorite_border_rounded,
          color: video.isLikedByCurrentUser ? AppColors.like : Colors.white,
          count: video.likes,
          onTap: () {
            HapticFeedback.lightImpact();
            onLike?.call();
          },
        ),

        const SizedBox(height: 20),

        // Comment button
        _ActionItem(
          icon: Icons.chat_bubble_outline_rounded,
          color: Colors.white,
          count: video.commentsCount,
          onTap: onComment,
        ),

        const SizedBox(height: 20),

        // Share button
        _ActionItem(
          icon: Icons.reply_rounded,
          color: Colors.white,
          count: video.shares,
          onTap: onShare,
          mirrorIcon: true,
        ),

        const SizedBox(height: 20),

        // More options
        GestureDetector(
          onTap: () {},
          child: const Column(
            children: [
              Icon(Icons.more_horiz_rounded, color: Colors.white, size: 28),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final int count;
  final VoidCallback? onTap;
  final bool mirrorIcon;

  const _ActionItem({
    required this.icon,
    required this.color,
    required this.count,
    this.onTap,
    this.mirrorIcon = false,
  });

  String _formatCount(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Transform(
            alignment: Alignment.center,
            transform: mirrorIcon
                ? Matrix4.rotationY(3.14159)
                : Matrix4.identity(),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 4),
          Text(
            _formatCount(count),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              shadows: [
                Shadow(blurRadius: 4, color: Colors.black54),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
