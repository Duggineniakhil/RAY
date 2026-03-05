import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reelify/core/constants/app_constants.dart';
import 'package:reelify/features/ai_recommendation/domain/models/user_interaction.dart';
import 'package:reelify/features/video_feed/domain/models/video_model.dart';
import 'package:reelify/services/offline/sqlite_service.dart';

/// Hybrid recommendation engine combining:
/// 1. Content-Based Filtering: scores videos based on user's category preferences
/// 2. Collaborative Filtering: boosts videos popular among similar users
class RecommendationEngine {
  final FirebaseFirestore _firestore;

  RecommendationEngine({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Ranks videos for a given user using weighted scores
  Future<List<VideoModel>> rankVideos(
      String userId, List<VideoModel> candidates) async {
    if (candidates.isEmpty) return candidates;

    // Fetch user's interaction history
    final interactions = await _getUserInteractions(userId);

    if (interactions.isEmpty) {
      // Cold start: return by views descending
      return candidates
        ..sort((a, b) => b.views.compareTo(a.views));
    }

    // Build category preference weights
    final categoryWeights = _buildCategoryWeights(interactions);

    // Score each video
    final scored = candidates.map((video) {
      final score = _scoreVideo(video, interactions, categoryWeights);
      return _ScoredVideo(video: video, score: score);
    }).toList();

    // Sort descending by score
    scored.sort((a, b) => b.score.compareTo(a.score));

    return scored.map((s) => s.video).toList();
  }

  double _scoreVideo(
    VideoModel video,
    List<UserInteraction> interactions,
    Map<String, double> categoryWeights,
  ) {
    double score = 0;

    // Content-based: category match
    final catWeight =
        categoryWeights[video.category.toLowerCase()] ?? 0;
    score += catWeight * AppConstants.watchTimeWeight;

    // Popularity boost (normalized)
    final popularityScore =
        (video.likes * 0.4 + video.views * 0.3 + video.commentsCount * 0.3) /
            10000;
    score += popularityScore.clamp(0, 1) * 0.2;

    // Recency boost
    final hoursOld =
        DateTime.now().difference(video.uploadTime).inHours;
    final recencyScore = 1.0 / (1 + hoursOld / 24);
    score += recencyScore * 0.1;

    // Penalize previously watched
    final watched =
        interactions.any((i) => i.videoId == video.id && i.watchRatio > 0.8);
    if (watched) score -= 0.5;

    return score;
  }

  Map<String, double> _buildCategoryWeights(
      List<UserInteraction> interactions) {
    final weights = <String, double>{};

    for (final interaction in interactions) {
      final cat = interaction.category.toLowerCase();
      weights[cat] = (weights[cat] ?? 0) +
          interaction.watchRatio * AppConstants.watchTimeWeight +
          (interaction.liked ? AppConstants.likeWeight : 0) +
          (interaction.commented ? AppConstants.commentWeight : 0) -
          (interaction.skipped ? AppConstants.skipPenalty : 0);
    }

    // Normalize
    final maxWeight =
        weights.values.isEmpty ? 1 : weights.values.reduce((a, b) => a > b ? a : b);
    if (maxWeight > 0) {
      weights.updateAll((k, v) => v / maxWeight);
    }

    return weights;
  }

  Future<List<UserInteraction>> _getUserInteractions(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.interactionsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(100)
          .get();

      return snapshot.docs
          .map((doc) => UserInteraction.fromFirestore(doc))
          .toList();
    } catch (_) {
      // Fallback to SQLite
      return await SqliteService.instance.getInteractions(userId);
    }
  }
}

class _ScoredVideo {
  final VideoModel video;
  final double score;
  _ScoredVideo({required this.video, required this.score});
}
