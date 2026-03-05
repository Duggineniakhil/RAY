import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reelify/features/ai_recommendation/data/recommendation_engine.dart';
import 'package:reelify/features/auth/presentation/providers/auth_provider.dart';
import 'package:reelify/features/video_feed/data/repositories/video_repository_impl.dart';
import 'package:reelify/features/video_feed/domain/models/video_model.dart';
import 'package:reelify/features/video_feed/domain/repositories/video_repository.dart';

// Repository provider
final videoRepositoryProvider = Provider<VideoRepository>((ref) {
  return VideoRepositoryImpl(
    recommendationEngine: RecommendationEngine(),
  );
});

// Video Feed State
class VideoFeedState {
  final List<VideoModel> videos;
  final bool isLoading;
  final bool hasMore;
  final String? error;
  final String? lastVideoId;
  final bool isForYouFeed;

  const VideoFeedState({
    this.videos = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.error,
    this.lastVideoId,
    this.isForYouFeed = true,
  });

  VideoFeedState copyWith({
    List<VideoModel>? videos,
    bool? isLoading,
    bool? hasMore,
    String? error,
    String? lastVideoId,
    bool? isForYouFeed,
  }) {
    return VideoFeedState(
      videos: videos ?? this.videos,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      error: error,
      lastVideoId: lastVideoId ?? this.lastVideoId,
      isForYouFeed: isForYouFeed ?? this.isForYouFeed,
    );
  }
}

// Feed Notifier
class VideoFeedNotifier extends StateNotifier<VideoFeedState> {
  final VideoRepository _repo;
  final String? _userId;

  VideoFeedNotifier(this._repo, this._userId)
      : super(const VideoFeedState()) {
    loadFeed();
  }

  Future<void> loadFeed({bool refresh = false}) async {
    if (state.isLoading) return;
    if (!state.hasMore && !refresh) return;

    state = state.copyWith(
      isLoading: true,
      error: null,
      videos: refresh ? [] : null,
      lastVideoId: refresh ? null : state.lastVideoId,
    );

    try {
      List<VideoModel> newVideos;
      if (!state.isForYouFeed && _userId != null) {
        // Fetch "Following" feed
        newVideos = await _repo.getFollowingVideos(_userId!);
      } else if (_userId != null && state.videos.isEmpty) {
        // Use AI recommendations for first load of For You feed
        newVideos = await _repo.getRecommendedVideos(_userId!);
      } else {
        newVideos = await _repo.getVideoFeed(
          limit: 10,
          lastVideoId: state.lastVideoId,
        );
      }

      final allVideos = refresh
          ? newVideos
          : [...state.videos, ...newVideos];

      state = state.copyWith(
        videos: allVideos,
        isLoading: false,
        hasMore: newVideos.length == 10,
        lastVideoId:
            newVideos.isNotEmpty ? newVideos.last.id : state.lastVideoId,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refreshFeed() => loadFeed(refresh: true);

  Future<void> loadMore() => loadFeed();

  void setFeedSource(bool isForYou) {
    if (state.isForYouFeed == isForYou) return;
    state = state.copyWith(isForYouFeed: isForYou);
    refreshFeed();
  }

  Future<void> toggleLike(String videoId, String userId) async {
    final index = state.videos.indexWhere((v) => v.id == videoId);
    if (index == -1) return;

    final video = state.videos[index];
    final isLiked = video.isLikedByCurrentUser;

    // Optimistic update
    final updatedVideos = List<VideoModel>.from(state.videos);
    updatedVideos[index] = video.copyWith(
      isLikedByCurrentUser: !isLiked,
      likes: isLiked ? video.likes - 1 : video.likes + 1,
    );
    state = state.copyWith(videos: updatedVideos);

    try {
      if (isLiked) {
        await _repo.unlikeVideo(videoId, userId);
      } else {
        await _repo.likeVideo(videoId, userId);
      }
    } catch (e) {
      // Revert on error
      updatedVideos[index] = video;
      state = state.copyWith(videos: updatedVideos);
    }
  }

  Future<void> filterByCategory(String category) async {
    state = state.copyWith(isLoading: true, videos: [], error: null);
    try {
      final videos = await _repo.getVideosByCategory(category);
      state = state.copyWith(videos: videos, isLoading: false, hasMore: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> searchVideos(String query) async {
    if (query.trim().isEmpty) return refreshFeed();
    state = state.copyWith(isLoading: true, videos: [], error: null);
    try {
      final videos = await _repo.searchVideos(query);
      state = state.copyWith(videos: videos, isLoading: false, hasMore: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void incrementCommentCount(String videoId) {
    final index = state.videos.indexWhere((v) => v.id == videoId);
    if (index == -1) return;

    final video = state.videos[index];
    final updatedVideos = List<VideoModel>.from(state.videos);
    updatedVideos[index] = video.copyWith(
      commentsCount: video.commentsCount + 1,
    );
    state = state.copyWith(videos: updatedVideos);
  }
}

final videoFeedProvider =
    StateNotifierProvider<VideoFeedNotifier, VideoFeedState>((ref) {
  final repo = ref.watch(videoRepositoryProvider);
  final user = ref.watch(authStateProvider).valueOrNull;
  return VideoFeedNotifier(repo, user?.id);
});
