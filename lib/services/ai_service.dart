import 'package:reelify/features/ai_recommendation/data/recommendation_engine.dart';
import 'package:reelify/features/video_feed/domain/models/video_model.dart';

class AiService {
  AiService._();
  static final AiService instance = AiService._();

  final RecommendationEngine _engine = RecommendationEngine();

  /// Returns AI-ranked list of videos for the given user
  Future<List<VideoModel>> getRecommendedFeed(
      String userId, List<VideoModel> candidates) async {
    return await _engine.rankVideos(userId, candidates);
  }
}
