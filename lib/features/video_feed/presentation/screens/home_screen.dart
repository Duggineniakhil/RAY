import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reelify/core/theme/app_theme.dart';
import 'package:reelify/features/auth/presentation/providers/auth_provider.dart';
import 'package:reelify/features/video_feed/presentation/providers/video_feed_provider.dart';
import 'package:reelify/features/video_feed/presentation/widgets/video_card.dart';
import 'package:reelify/features/voice_assistant/voice_search_service.dart';
import 'package:reelify/widgets/custom_bottom_nav.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  int _navIndex = 0;
  final VoiceSearchService _voiceSearch = VoiceSearchService();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
    final feedState = ref.read(videoFeedProvider);
    // Load more when reaching near the end
    if (index >= feedState.videos.length - 3) {
      ref.read(videoFeedProvider.notifier).loadMore();
    }
    // Increment view count for the video
    if (index < feedState.videos.length) {
      ref
          .read(videoRepositoryProvider)
          .incrementView(feedState.videos[index].id);
    }
  }

  Future<void> _startVoiceSearch() async {
    final result = await _voiceSearch.listenForCommand();
    if (result != null && mounted) {
      ref.read(videoFeedProvider.notifier).searchVideos(result);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Searching: "$result"')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(videoFeedProvider);
    final user = ref.watch(authStateProvider).valueOrNull;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.qr_code_scanner_rounded,
              color: Colors.white),
          onPressed: () => context.push('/home/qr-scanner'),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTabButton('Following', false, feedState.isForYouFeed),
            const SizedBox(width: 24),
            _buildTabButton('For You', true, feedState.isForYouFeed),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.mic_rounded, color: Colors.white),
            onPressed: _startVoiceSearch,
            tooltip: 'Voice Search',
          ),
        ],
      ),
      body: feedState.videos.isEmpty && feedState.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : feedState.videos.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.video_library_outlined,
                          color: AppColors.textSecondary, size: 64),
                      const SizedBox(height: 16),
                      Text(
                        'No videos yet',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () =>
                            ref.read(videoFeedProvider.notifier).refreshFeed(),
                        child: const Text('Refresh'),
                      ),
                    ],
                  ),
                )
              : PageView.builder(
                  controller: _pageController,
                  scrollDirection: Axis.vertical,
                  onPageChanged: _onPageChanged,
                  itemCount: feedState.hasMore
                      ? feedState.videos.length + 1
                      : feedState.videos.length,
                  itemBuilder: (context, index) {
                    if (index >= feedState.videos.length) {
                      return const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primary),
                      );
                    }
                    return VideoCard(
                      video: feedState.videos[index],
                      isActive: index == _currentIndex,
                      onLike: user != null
                          ? () => ref
                              .read(videoFeedProvider.notifier)
                              .toggleLike(feedState.videos[index].id, user.id)
                          : null,
                      onComment: () => context.push(
                        '/home/comments/${feedState.videos[index].id}',
                      ),
                      onProfile: () => context.push(
                        '/home/profile/${feedState.videos[index].creatorId}',
                      ),
                    );
                  },
                ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _navIndex,
        onTap: (i) {
          setState(() => _navIndex = i);
          switch (i) {
            case 1:
              context.push('/home/explore');
              break;
            case 2:
              context.push('/home/upload');
              break;
            case 3:
              context.push('/home/messaging');
              break;
            case 4:
              if (user != null) {
                context.push('/home/profile/${user.id}');
              }
              break;
          }
        },
      ),
    );
  }

  Widget _buildTabButton(String text, bool isForYouTab, bool currentFeedState) {
    final isActive = isForYouTab == currentFeedState;
    return GestureDetector(
      onTap: () {
        ref.read(videoFeedProvider.notifier).setFeedSource(isForYouTab);
        if (_pageController.hasClients) {
           _pageController.jumpToPage(0);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.white60,
              fontWeight:
                  isActive ? FontWeight.bold : FontWeight.normal,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 2),
          if (isActive)
            Container(
              width: 24,
              height: 2,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
        ],
      ),
    );
  }
}
