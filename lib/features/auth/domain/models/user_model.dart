import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String username;
  final String displayName;
  final String profileImage;
  final List<String> interests;
  final int followersCount;
  final int followingCount;
  final List<String> watchHistory;
  final DateTime createdAt;
  final String bio;
  final bool isVerified;
  final bool isPrivate;

  const UserModel({
    required this.id,
    required this.email,
    required this.username,
    required this.displayName,
    this.profileImage = '',
    this.interests = const [],
    this.followersCount = 0,
    this.followingCount = 0,
    this.watchHistory = const [],
    required this.createdAt,
    this.bio = '',
    this.isVerified = false,
    this.isPrivate = false,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      username: data['username'] ?? '',
      displayName: data['displayName'] ?? '',
      profileImage: data['profileImage'] ?? '',
      interests: List<String>.from(data['interests'] ?? []),
      followersCount: data['followersCount'] ?? 0,
      followingCount: data['followingCount'] ?? 0,
      watchHistory: List<String>.from(data['watchHistory'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      bio: data['bio'] ?? '',
      isVerified: data['isVerified'] ?? false,
      isPrivate: data['isPrivate'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'username': username,
      'displayName': displayName,
      'profileImage': profileImage,
      'interests': interests,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'watchHistory': watchHistory,
      'createdAt': Timestamp.fromDate(createdAt),
      'bio': bio,
      'isVerified': isVerified,
      'isPrivate': isPrivate,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? username,
    String? displayName,
    String? profileImage,
    List<String>? interests,
    int? followersCount,
    int? followingCount,
    List<String>? watchHistory,
    DateTime? createdAt,
    String? bio,
    bool? isVerified,
    bool? isPrivate,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      profileImage: profileImage ?? this.profileImage,
      interests: interests ?? this.interests,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      watchHistory: watchHistory ?? this.watchHistory,
      createdAt: createdAt ?? this.createdAt,
      bio: bio ?? this.bio,
      isVerified: isVerified ?? this.isVerified,
      isPrivate: isPrivate ?? this.isPrivate,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is UserModel && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
