import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reelify/features/video_feed/domain/models/video_model.dart';
import 'package:reelify/features/video_feed/presentation/widgets/video_card.dart';
import 'package:reelify/features/auth/presentation/providers/auth_provider.dart';
import 'package:reelify/features/video_feed/presentation/providers/video_feed_provider.dart';

class SingleVideoScreen extends ConsumerStatefulWidget {
  final VideoModel video;
  const SingleVideoScreen({super.key, required this.video});

  @override
  ConsumerState<SingleVideoScreen> createState() => _SingleVideoScreenState();
}

class _SingleVideoScreenState extends ConsumerState<SingleVideoScreen> {
  bool _isScreenActive = true;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).valueOrNull;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          VideoCard(
            video: widget.video,
            isActive: _isScreenActive,
            onLike: user != null
                ? () => ref
                    .read(videoFeedProvider.notifier)
                    .toggleLike(widget.video.id, user.id)
                : null,
            onComment: () async {
              setState(() => _isScreenActive = false);
              await context.push('/home/comments/${widget.video.id}');
              if (mounted) setState(() => _isScreenActive = true);
            },
            onProfile: () async {
              setState(() => _isScreenActive = false);
              await context.push('/home/profile/${widget.video.creatorId}');
              if (mounted) setState(() => _isScreenActive = true);
            },
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () => context.pop(),
            ),
          ),
        ],
      ),
    );
  }
}
