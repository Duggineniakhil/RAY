import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reelify/core/constants/app_constants.dart';

class ProfileStatsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, int>> getUserStats(String userId) async {
    final doc = await _firestore.collection(AppConstants.usersCollection).doc(userId).get();
    if (!doc.exists) return {'followers': 0, 'following': 0, 'likes': 0, 'posts': 0};

    final data = doc.data()!;
    return {
      'followers': (data['followersCount'] as int?) ?? 0,
      'following': (data['followingCount'] as int?) ?? 0,
      'likes': (data['likesCount'] as int?) ?? 0,
      'posts': (data['postsCount'] as int?) ?? 0,
    };
  }

  // This would be called by Cloud Functions or on specific client actions
  Future<void> syncStats(String userId) async {
    final userRef = _firestore.collection(AppConstants.usersCollection).doc(userId);
    
    // Count posts
    final postsSnap = await _firestore
        .collection(AppConstants.videosCollection)
        .where('creatorId', isEqualTo: userId)
        .get();
    final postsCount = postsSnap.docs.length;

    // Count likes across all posts
    int totalLikes = 0;
    for (final doc in postsSnap.docs) {
      totalLikes += (doc.data()['likes'] as int?) ?? 0;
    }

    await userRef.update({
      'postsCount': postsCount,
      'likesCount': totalLikes,
    });
  }
}
