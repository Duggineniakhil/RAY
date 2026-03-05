import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reelify/features/explore/data/repositories/explore_repository.dart';
import 'package:reelify/features/video_feed/domain/models/video_model.dart';

final exploreRepositoryProvider = Provider((ref) => ExploreRepository());

class ExploreState {
  final List<VideoModel> trendingVideos;
  final bool isLoading;
  final String? error;

  ExploreState({
    this.trendingVideos = const [],
    this.isLoading = false,
    this.error,
  });

  ExploreState copyWith({
    List<VideoModel>? trendingVideos,
    bool? isLoading,
    String? error,
  }) {
    return ExploreState(
      trendingVideos: trendingVideos ?? this.trendingVideos,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ExploreNotifier extends StateNotifier<ExploreState> {
  final ExploreRepository _repo;

  ExploreNotifier(this._repo) : super(ExploreState()) {
    loadTrending();
  }

  Future<void> loadTrending({String? category}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final videos = await _repo.getTrendingVideos(category: category);
      state = state.copyWith(trendingVideos: videos, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> search(String query) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final videos = await _repo.searchVideos(query);
      state = state.copyWith(trendingVideos: videos, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final exploreProvider = StateNotifierProvider<ExploreNotifier, ExploreState>((ref) {
  final repo = ref.watch(exploreRepositoryProvider);
  return ExploreNotifier(repo);
});
