import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reelify/core/constants/app_constants.dart';
import 'package:reelify/features/video_feed/domain/models/video_model.dart';

class ExploreRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<VideoModel>> getTrendingVideos({String? category}) async {
    Query query = _firestore.collection(AppConstants.videosCollection);

    if (category != null && category.isNotEmpty) {
      query = query.where('category', isEqualTo: category);
    }

    // Ranking: Primary sort by likes (engagement), secondary by views.
    // Using two separate queries and merging client-side to avoid composite index requirements.
    final snapshot = await query
        .orderBy('likes', descending: true)
        .limit(30)
        .get();

    final videos = snapshot.docs.map((doc) => VideoModel.fromFirestore(doc)).toList();
    // Secondary sort by views for equal likes
    videos.sort((a, b) {
      if (b.likes != a.likes) return b.likes.compareTo(a.likes);
      return b.views.compareTo(a.views);
    });
    return videos.take(20).toList();
  }

  Future<List<VideoModel>> searchVideos(String searchTerm) async {
    final term = searchTerm.replaceAll('#', '').toLowerCase().trim();
    if (term.isEmpty) return [];

    // Search by hashtags match
    final hashtagSnap = await _firestore
        .collection(AppConstants.videosCollection)
        .where('hashtags', arrayContains: term)
        .limit(20)
        .get();

    final results = hashtagSnap.docs.map((doc) => VideoModel.fromFirestore(doc)).toList();

    // If no hashtag results, fall back to caption search (client-side)
    if (results.isEmpty) {
      final allSnap = await _firestore
          .collection(AppConstants.videosCollection)
          .orderBy('uploadTime', descending: true)
          .limit(50)
          .get();
      return allSnap.docs
          .map((doc) => VideoModel.fromFirestore(doc))
          .where((v) =>
              v.caption.toLowerCase().contains(term) ||
              v.category.toLowerCase().contains(term) ||
              v.creatorName.toLowerCase().contains(term))
          .take(20)
          .toList();
    }

    return results;
  }
}


