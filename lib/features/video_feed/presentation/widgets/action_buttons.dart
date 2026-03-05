import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reelify/features/video_feed/domain/models/video_model.dart';
import 'package:reelify/features/auth/presentation/providers/auth_provider.dart';
import 'package:reelify/features/video_feed/presentation/providers/video_feed_provider.dart';

class ActionButtons extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
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
                  color: Theme.of(context).colorScheme.surface,
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
                    color: Theme.of(context).colorScheme.primary,
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
          color: video.isLikedByCurrentUser ? const Color(0xFFFF2D55) : Colors.white,
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
          onTap: () => _showOptions(context, ref),
          child: const Column(
            children: [
              Icon(Icons.more_horiz_rounded, color: Colors.white, size: 28),
            ],
          ),
        ),
      ],
    );
  }

  void _showOptions(BuildContext context, WidgetRef ref) {
    final currentUser = ref.read(authStateProvider).valueOrNull;
    final isOwner = currentUser?.id == video.creatorId;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              if (isOwner)
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                  title: const Text('Delete Video', style: TextStyle(color: Colors.red)),
                  onTap: () async {
                    Navigator.pop(context);
                    await ref.read(videoRepositoryProvider).deleteVideo(video.id);
                    ref.read(videoFeedProvider.notifier).refreshFeed();
                  },
                ),
              ListTile(
                leading: const Icon(Icons.flag_outlined, color: Colors.white),
                title: const Text('Report', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _showReportDialog(context, ref, currentUser?.id ?? 'anonymous');
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _showReportDialog(BuildContext context, WidgetRef ref, String reporterId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text('Report Video', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ['Spam', 'Inappropriate content', 'Harassment']
                .map((r) => ListTile(
                      title: Text(r, style: const TextStyle(color: Colors.white)),
                      onTap: () async {
                        Navigator.pop(context);
                        await ref.read(videoRepositoryProvider).reportVideo(video.id, r, reporterId);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Video reported')),
                          );
                        }
                      },
                    ))
                .toList(),
          ),
          actions: [
             TextButton(
               onPressed: () => Navigator.pop(context),
               child: const Text('Cancel')
             )
          ]
        );
      }
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
