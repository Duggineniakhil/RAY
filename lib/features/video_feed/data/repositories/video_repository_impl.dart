import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reelify/core/constants/app_constants.dart';
import 'package:reelify/features/ai_recommendation/data/recommendation_engine.dart';
import 'package:reelify/features/video_feed/domain/models/video_model.dart';
import 'package:reelify/features/video_feed/domain/repositories/video_repository.dart';

class VideoRepositoryImpl implements VideoRepository {
  final FirebaseFirestore _firestore;
  final RecommendationEngine _recommendationEngine;

  VideoRepositoryImpl({
    FirebaseFirestore? firestore,
    RecommendationEngine? recommendationEngine,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _recommendationEngine =
            recommendationEngine ?? RecommendationEngine();

  @override
  Future<List<VideoModel>> getVideoFeed({
    int limit = 10,
    String? lastVideoId,
  }) async {
    Query query = _firestore
        .collection(AppConstants.videosCollection)
        .orderBy('uploadTime', descending: true)
        .limit(limit);

    if (lastVideoId != null) {
      final lastDoc = await _firestore
          .collection(AppConstants.videosCollection)
          .doc(lastVideoId)
          .get();
      if (lastDoc.exists) {
        query = query.startAfterDocument(lastDoc);
      }
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => VideoModel.fromFirestore(doc)).toList();
  }

  @override
  Future<List<VideoModel>> getRecommendedVideos(String userId) async {
    // Fetch all available videos (paged, up to 50)
    final snapshot = await _firestore
        .collection(AppConstants.videosCollection)
        .orderBy('views', descending: true)
        .limit(50)
        .get();

    final allVideos =
        snapshot.docs.map((doc) => VideoModel.fromFirestore(doc)).toList();

    // Rank via AI recommendation engine
    return await _recommendationEngine.rankVideos(userId, allVideos);
  }

  @override
  Future<List<VideoModel>> getFollowingVideos(String userId) async {
    final followingSnapshot = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection('following')
        .get();

    if (followingSnapshot.docs.isEmpty) return [];

    final followingIds = followingSnapshot.docs.map((doc) => doc.id).toList();

    List<VideoModel> followingVideos = [];
    for (var i = 0; i < followingIds.length; i += 10) {
      final chunk = followingIds.sublist(i, i + 10 > followingIds.length ? followingIds.length : i + 10);
      final snapshot = await _firestore
          .collection(AppConstants.videosCollection)
          .where('creatorId', whereIn: chunk)
          .orderBy('uploadTime', descending: true)
          .get();
      followingVideos.addAll(snapshot.docs.map((doc) => VideoModel.fromFirestore(doc)));
    }
    
    followingVideos.sort((a, b) => b.uploadTime.compareTo(a.uploadTime));
    return followingVideos;
  }

  @override
  Future<List<VideoModel>> getVideosByCategory(String category) async {
    final snapshot = await _firestore
        .collection(AppConstants.videosCollection)
        .where('category', isEqualTo: category)
        .orderBy('uploadTime', descending: true)
        .limit(20)
        .get();
    return snapshot.docs.map((doc) => VideoModel.fromFirestore(doc)).toList();
  }

  @override
  Future<List<VideoModel>> searchVideos(String query) async {
    final lowerQuery = query.toLowerCase();
    final snapshot = await _firestore
        .collection(AppConstants.videosCollection)
        .orderBy('uploadTime', descending: true)
        .limit(30)
        .get();

    return snapshot.docs
        .map((doc) => VideoModel.fromFirestore(doc))
        .where((v) =>
            v.caption.toLowerCase().contains(lowerQuery) ||
            v.category.toLowerCase().contains(lowerQuery) ||
            v.hashtags.any((h) => h.toLowerCase().contains(lowerQuery)))
        .toList();
  }

  @override
  Future<void> likeVideo(String videoId, String userId) async {
    final batch = _firestore.batch();
    final videoRef = _firestore
        .collection(AppConstants.videosCollection)
        .doc(videoId);
    final likeRef = videoRef.collection('likes').doc(userId);
    batch.set(likeRef, {'userId': userId, 'timestamp': FieldValue.serverTimestamp()});
    batch.update(videoRef, {'likes': FieldValue.increment(1)});
    await batch.commit();
  }

  @override
  Future<void> unlikeVideo(String videoId, String userId) async {
    final batch = _firestore.batch();
    final videoRef = _firestore
        .collection(AppConstants.videosCollection)
        .doc(videoId);
    final likeRef = videoRef.collection('likes').doc(userId);
    batch.delete(likeRef);
    batch.update(videoRef, {'likes': FieldValue.increment(-1)});
    await batch.commit();
  }

  @override
  Future<void> incrementView(String videoId) async {
    await _firestore
        .collection(AppConstants.videosCollection)
        .doc(videoId)
        .update({'views': FieldValue.increment(1)});
  }

  @override
  Future<void> shareVideo(String videoId) async {
    await _firestore
        .collection(AppConstants.videosCollection)
        .doc(videoId)
        .update({'shares': FieldValue.increment(1)});
  }

  @override
  Future<VideoModel?> getVideoById(String videoId) async {
    final doc = await _firestore
        .collection(AppConstants.videosCollection)
        .doc(videoId)
        .get();
    if (!doc.exists) return null;
    return VideoModel.fromFirestore(doc);
  }

  @override
  Future<List<VideoModel>> getUserVideos(String userId, {bool likedOnly = false}) async {
    if (likedOnly) {
      final likesSnapshot = await _firestore
          .collectionGroup('likes')
          .where('userId', isEqualTo: userId)
          .get();
      
      if (likesSnapshot.docs.isEmpty) return [];

      final videoIds = likesSnapshot.docs.map((d) => d.reference.parent.parent!.id).toList();
      
      List<VideoModel> likedVideos = [];
      for (var i = 0; i < videoIds.length; i += 10) {
        final chunk = videoIds.sublist(i, i + 10 > videoIds.length ? videoIds.length : i + 10);
        final snapshot = await _firestore
            .collection(AppConstants.videosCollection)
            .where(FieldPath.documentId, whereIn: chunk)
            .get();
        likedVideos.addAll(snapshot.docs.map((doc) => VideoModel.fromFirestore(doc)));
      }
      likedVideos.sort((a, b) => b.uploadTime.compareTo(a.uploadTime)); // Sort locally
      return likedVideos;
    }

    final snapshot = await _firestore
        .collection(AppConstants.videosCollection)
        .where('creatorId', isEqualTo: userId)
        .get();
    final userVideos = snapshot.docs.map((doc) => VideoModel.fromFirestore(doc)).toList();
    userVideos.sort((a, b) => b.uploadTime.compareTo(a.uploadTime)); // Sort locally to avoid indexing issue
    return userVideos;
  }

  @override
  Future<void> deleteVideo(String videoId) async {
    await _firestore.collection(AppConstants.videosCollection).doc(videoId).delete();
  }

  @override
  Future<void> reportVideo(String videoId, String reason, String reporterId) async {
    await _firestore.collection('reports').add({
      'videoId': videoId,
      'reporterId': reporterId,
      'reason': reason,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'pending',
    });
  }
}
