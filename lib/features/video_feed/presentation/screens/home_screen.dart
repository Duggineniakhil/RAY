import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:reelify/generated/app_localizations.dart';
import 'package:reelify/features/auth/presentation/providers/auth_provider.dart';
import 'package:reelify/features/video_feed/presentation/providers/video_feed_provider.dart';
import 'package:reelify/features/video_feed/presentation/widgets/video_card.dart';
import 'package:reelify/features/voice_assistant/voice_search_service.dart';
import 'package:reelify/services/offline/sqlite_service.dart';
import 'package:reelify/widgets/custom_bottom_nav.dart';
import 'package:reelify/core/services/dummy_data_service.dart';

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
  bool _isOffline = false;
  bool _isScreenActive = true;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _seedDummyDataIfNeeded();
    });
  }

  Future<void> _seedDummyDataIfNeeded() async {
    final feedState = ref.read(videoFeedProvider);
    if (!feedState.isLoading && feedState.videos.isEmpty) {
      await DummyDataService.seedVideos();
      if (mounted) {
        ref.read(videoFeedProvider.notifier).refreshFeed();
      }
    }
  }

  Future<void> _checkConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    if (mounted) {
      setState(() => _isOffline = result.first == ConnectivityResult.none);
    }
    Connectivity().onConnectivityChanged.listen((results) {
      if (mounted) {
        final offline = results.first == ConnectivityResult.none;
        setState(() => _isOffline = offline);
        if (!offline && _isOffline) {
          ref.read(videoFeedProvider.notifier).refreshFeed();
        }
      }
    });
  }

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
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.qr_code_scanner_rounded,
              color: Colors.white),
          onPressed: () async {
            setState(() => _isScreenActive = false);
            await context.push('/home/qr-scanner');
            if (mounted) setState(() => _isScreenActive = true);
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTabButton(l10n.following, false, feedState.isForYouFeed),
            const SizedBox(width: 24),
            _buildTabButton(l10n.forYou, true, feedState.isForYouFeed),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.mic_rounded, color: Colors.white),
            onPressed: _startVoiceSearch,
            tooltip: l10n.voiceSearch,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main feed body
          feedState.videos.isEmpty && feedState.isLoading
              ? Center(
                  child: CircularProgressIndicator(color: theme.colorScheme.primary))
              : feedState.videos.isEmpty
                  ? _isOffline
                      ? _buildOfflineFallback(theme, l10n)
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.video_library_outlined,
                                  color: theme.hintColor, size: 64),
                              const SizedBox(height: 16),
                              Text(
                                l10n.noVideosYet,
                                style: theme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () =>
                                    ref.read(videoFeedProvider.notifier).refreshFeed(),
                                child: Text(l10n.refresh),
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
                      return Center(
                        child: CircularProgressIndicator(
                            color: theme.colorScheme.primary),
                      );
                    }
                    return VideoCard(
                      video: feedState.videos[index],
                      isActive: index == _currentIndex && _isScreenActive,
                      onLike: user != null
                          ? () => ref
                              .read(videoFeedProvider.notifier)
                              .toggleLike(feedState.videos[index].id, user.id)
                          : null,
                      onComment: () async {
                        setState(() => _isScreenActive = false);
                        await context.push(
                          '/home/comments/${feedState.videos[index].id}',
                        );
                        if (mounted) setState(() => _isScreenActive = true);
                      },
                      onProfile: () async {
                        setState(() => _isScreenActive = false);
                        await context.push(
                          '/home/profile/${feedState.videos[index].creatorId}',
                        );
                        if (mounted) setState(() => _isScreenActive = true);
                      },
                    );
                  },
                ),
          // Offline banner
          if (_isOffline)
            Positioned(
              top: kToolbarHeight + MediaQuery.of(context).padding.top + 4,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wifi_off_rounded, size: 14, color: Colors.white),
                    const SizedBox(width: 6),
                    Text(l10n.noInternet,
                        style: const TextStyle(color: Colors.white, fontSize: 11)),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _navIndex,
        onTap: (i) async {
          setState(() {
            _navIndex = i;
            _isScreenActive = false;
          });
          switch (i) {
            case 1:
              await context.push('/home/explore');
              break;
            case 2:
              await context.push('/home/upload');
              break;
            case 3:
              await context.push('/home/messaging');
              break;
            case 4:
              if (user != null) {
                await context.push('/home/profile/${user.id}');
              }
              break;
          }
          if (mounted) {
            setState(() {
              _isScreenActive = true;
              _navIndex = 0; // Reset to Home nav icon since we are back
            });
          }
        },
      ),
    );
  }

  Widget _buildOfflineFallback(ThemeData theme, AppLocalizations l10n) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: SqliteService.instance.getCachedVideos(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: theme.colorScheme.primary));
        }
        final cached = snapshot.data ?? [];
        if (cached.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.wifi_off_rounded, color: theme.hintColor, size: 64),
                const SizedBox(height: 12),
                Text(l10n.noInternet, style: TextStyle(color: theme.colorScheme.onSurface)),
              ],
            ),
          );
        }
        return GridView.builder(
          padding: const EdgeInsets.all(1),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 1,
            crossAxisSpacing: 1,
            childAspectRatio: 0.6,
          ),
          itemCount: cached.length,
          itemBuilder: (context, i) => Container(
            color: theme.colorScheme.surface,
            child: cached[i]['thumbnail'] != null && (cached[i]['thumbnail'] as String).isNotEmpty
                ? Image.network(cached[i]['thumbnail'], fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(Icons.play_circle_outline_rounded, color: theme.hintColor))
                : Icon(Icons.play_circle_outline_rounded, color: theme.hintColor),
          ),
        );
      },
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
