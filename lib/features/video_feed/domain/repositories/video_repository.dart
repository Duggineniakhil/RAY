import 'package:reelify/features/video_feed/domain/models/video_model.dart';

abstract class VideoRepository {
  Future<List<VideoModel>> getVideoFeed({
    int limit = 10,
    String? lastVideoId,
  });
  Future<List<VideoModel>> getRecommendedVideos(String userId);
  Future<List<VideoModel>> getFollowingVideos(String userId);
  Future<List<VideoModel>> getVideosByCategory(String category);
  Future<List<VideoModel>> searchVideos(String query);
  Future<void> likeVideo(String videoId, String userId);
  Future<void> unlikeVideo(String videoId, String userId);
  Future<void> incrementView(String videoId);
  Future<void> shareVideo(String videoId);
  Future<VideoModel?> getVideoById(String videoId);
  Future<List<VideoModel>> getUserVideos(String userId, {bool likedOnly = false});
  Future<void> deleteVideo(String videoId);
  Future<void> reportVideo(String videoId, String reason, String reporterId);
}
