import 'package:cloud_firestore/cloud_firestore.dart';

class UserInteraction {
  final String id;
  final String userId;
  final String videoId;
  final String category;
  final double watchRatio; // 0.0 – 1.0
  final bool liked;
  final bool commented;
  final bool skipped;
  final DateTime timestamp;

  const UserInteraction({
    required this.id,
    required this.userId,
    required this.videoId,
    required this.category,
    this.watchRatio = 0,
    this.liked = false,
    this.commented = false,
    this.skipped = false,
    required this.timestamp,
  });

  factory UserInteraction.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return UserInteraction(
      id: doc.id,
      userId: d['userId'] ?? '',
      videoId: d['videoId'] ?? '',
      category: d['category'] ?? '',
      watchRatio: (d['watchRatio'] ?? 0).toDouble(),
      liked: d['liked'] ?? false,
      commented: d['commented'] ?? false,
      skipped: d['skipped'] ?? false,
      timestamp:
          (d['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory UserInteraction.fromMap(Map<String, dynamic> map) {
    return UserInteraction(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      videoId: map['videoId'] ?? '',
      category: map['category'] ?? '',
      watchRatio: (map['watchRatio'] ?? 0).toDouble(),
      liked: (map['liked'] ?? 0) == 1,
      commented: (map['commented'] ?? 0) == 1,
      skipped: (map['skipped'] ?? 0) == 1,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
          map['timestamp'] ?? 0),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'videoId': videoId,
        'category': category,
        'watchRatio': watchRatio,
        'liked': liked,
        'commented': commented,
        'skipped': skipped,
        'timestamp': Timestamp.fromDate(timestamp),
      };

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'videoId': videoId,
        'category': category,
        'watchRatio': watchRatio,
        'liked': liked ? 1 : 0,
        'commented': commented ? 1 : 0,
        'skipped': skipped ? 1 : 0,
        'timestamp': timestamp.millisecondsSinceEpoch,
      };
}
