import 'package:cloud_firestore/cloud_firestore.dart';

class VideoModel {
  final String id;
  final String videoUrl;
  final String thumbnail;
  final String creatorId;
  final String creatorName;
  final String creatorAvatar;
  final String category;
  final String caption;
  final List<String> hashtags;
  final int likes;
  final int commentsCount;
  final int views;
  final int shares;
  final DateTime uploadTime;
  final double duration; // seconds
  final bool isLikedByCurrentUser;
  final String type; // 'image' or 'video'
  final int filterIndex;

  const VideoModel({
    required this.id,
    required this.videoUrl,
    this.thumbnail = '',
    required this.creatorId,
    this.creatorName = '',
    this.creatorAvatar = '',
    required this.category,
    this.caption = '',
    this.hashtags = const [],
    this.likes = 0,
    this.commentsCount = 0,
    this.views = 0,
    this.shares = 0,
    required this.uploadTime,
    this.duration = 0,
    this.isLikedByCurrentUser = false,
    this.type = 'video',
    this.filterIndex = 0,
  });

  factory VideoModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VideoModel(
      id: doc.id,
      videoUrl: data['videoUrl'] ?? '',
      thumbnail: data['thumbnail'] ?? '',
      creatorId: data['creatorId'] ?? '',
      creatorName: data['creatorName'] ?? '',
      creatorAvatar: data['creatorAvatar'] ?? '',
      category: data['category'] ?? 'General',
      caption: data['caption'] ?? '',
      hashtags: List<String>.from(data['hashtags'] ?? []),
      likes: data['likes'] ?? 0,
      commentsCount: data['commentsCount'] ?? 0,
      views: data['views'] ?? 0,
      shares: data['shares'] ?? 0,
      uploadTime:
          (data['uploadTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      duration: (data['duration'] ?? 0).toDouble(),
      type: data['type'] ?? 'video',
      filterIndex: data['filterIndex'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'videoUrl': videoUrl,
      'thumbnail': thumbnail,
      'creatorId': creatorId,
      'creatorName': creatorName,
      'creatorAvatar': creatorAvatar,
      'category': category,
      'caption': caption,
      'hashtags': hashtags,
      'likes': likes,
      'commentsCount': commentsCount,
      'views': views,
      'shares': shares,
      'uploadTime': Timestamp.fromDate(uploadTime),
      'duration': duration,
      'type': type,
      'filterIndex': filterIndex,
    };
  }

  VideoModel copyWith({
    String? id,
    String? videoUrl,
    String? thumbnail,
    String? creatorId,
    String? creatorName,
    String? creatorAvatar,
    String? category,
    String? caption,
    List<String>? hashtags,
    int? likes,
    int? commentsCount,
    int? views,
    int? shares,
    DateTime? uploadTime,
    double? duration,
    bool? isLikedByCurrentUser,
    String? type,
    int? filterIndex,
  }) {
    return VideoModel(
      id: id ?? this.id,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnail: thumbnail ?? this.thumbnail,
      creatorId: creatorId ?? this.creatorId,
      creatorName: creatorName ?? this.creatorName,
      creatorAvatar: creatorAvatar ?? this.creatorAvatar,
      category: category ?? this.category,
      caption: caption ?? this.caption,
      hashtags: hashtags ?? this.hashtags,
      likes: likes ?? this.likes,
      commentsCount: commentsCount ?? this.commentsCount,
      views: views ?? this.views,
      shares: shares ?? this.shares,
      uploadTime: uploadTime ?? this.uploadTime,
      duration: duration ?? this.duration,
      isLikedByCurrentUser:
          isLikedByCurrentUser ?? this.isLikedByCurrentUser,
      type: type ?? this.type,
      filterIndex: filterIndex ?? this.filterIndex,
    );
  }
}
