import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reelify/features/video_feed/domain/models/video_model.dart';
import 'package:reelify/features/video_feed/presentation/widgets/video_card.dart';
import 'package:reelify/features/auth/presentation/providers/auth_provider.dart';
import 'package:reelify/features/video_feed/presentation/providers/video_feed_provider.dart';

class SingleVideoScreen extends ConsumerStatefulWidget {
  final List<VideoModel> videos;
  final int initialIndex;

  const SingleVideoScreen({
    super.key,
    required this.videos,
    this.initialIndex = 0,
  });

  @override
  ConsumerState<SingleVideoScreen> createState() => _SingleVideoScreenState();
}

class _SingleVideoScreenState extends ConsumerState<SingleVideoScreen> {
  late PageController _pageController;
  late int _currentIndex;
  bool _isScreenActive = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).valueOrNull;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
              // Increment view count for new video
              ref.read(videoRepositoryProvider).incrementView(widget.videos[index].id);
            },
            itemCount: widget.videos.length,
            itemBuilder: (context, index) {
              return VideoCard(
                index: index,
                video: widget.videos[index],
                isActive: index == _currentIndex && _isScreenActive,
                onLike: user != null
                    ? () => ref
                        .read(videoFeedProvider.notifier)
                        .toggleLike(widget.videos[index].id, user.id)
                    : null,
                onComment: () async {
                  setState(() => _isScreenActive = false);
                  await context.push('/home/comments/${widget.videos[index].id}');
                  if (mounted) setState(() => _isScreenActive = true);
                },
                onProfile: () async {
                  setState(() => _isScreenActive = false);
                  await context.push('/home/profile/${widget.videos[index].creatorId}');
                  if (mounted) setState(() => _isScreenActive = true);
                },
              );
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
