import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reelify/core/constants/app_constants.dart';

class DummyDataService {
  static Future<void> seedVideos() async {
    final firestore = FirebaseFirestore.instance;
    final videosCollection = firestore.collection(AppConstants.videosCollection);

    final snapshot = await videosCollection.limit(1).get();
    if (snapshot.docs.isNotEmpty) return; // Already has data

    // Seed users first so profile pages work
    await _seedUsers(firestore);

    final dummyVideos = [
      {
        'caption': 'Amazing sunset in the mountains! 🌄 #nature #travel',
        'videoUrl': 'https://assets.mixkit.co/videos/preview/mixkit-sun-setting-behind-a-mountain-range-4560-large.mp4',
        'thumbnail': 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&q=80&w=400',
        'creatorId': 'dummy_1',
        'creatorName': 'NatureLover',
        'type': 'video',
        'likes': 1250,
        'commentsCount': 45,
        'views': 5200,
        'shares': 88,
        'category': 'Nature',
        'hashtags': ['nature', 'travel'],
        'filterIndex': 0,
        'uploadTime': Timestamp.now(),
      },
      {
        'caption': 'Perfect morning coffee ☕ #aesthetic #morning',
        'videoUrl': 'https://assets.mixkit.co/videos/preview/mixkit-coffee-being-poured-into-a-cup-2325-large.mp4',
        'thumbnail': 'https://images.unsplash.com/photo-1541167760496-162955ed8a9f?auto=format&fit=crop&q=80&w=400',
        'creatorId': 'dummy_2',
        'creatorName': 'MorningVibes',
        'type': 'video',
        'likes': 890,
        'commentsCount': 12,
        'views': 4100,
        'shares': 34,
        'category': 'Lifestyle',
        'hashtags': ['aesthetic', 'morning', 'coffee'],
        'filterIndex': 0,
        'uploadTime': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 2))),
      },
      {
        'caption': 'Delicious home-made pasta 🍝 #cooking #food',
        'videoUrl': 'https://assets.mixkit.co/videos/preview/mixkit-pasta-boiling-in-a-pot-4265-large.mp4',
        'thumbnail': 'https://images.unsplash.com/photo-1473093226795-af9932fe5856?auto=format&fit=crop&q=80&w=400',
        'creatorId': 'dummy_3',
        'creatorName': 'ChefMario',
        'type': 'video',
        'likes': 2100,
        'commentsCount': 89,
        'views': 12000,
        'shares': 210,
        'category': 'Food',
        'hashtags': ['cooking', 'food', 'pasta'],
        'filterIndex': 0,
        'uploadTime': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 5))),
      },
      {
        'caption': 'New dance challenge! 💃 #dance #challenge #viral',
        'videoUrl': 'https://assets.mixkit.co/videos/preview/mixkit-very-fast-paced-modern-dance-4148-large.mp4',
        'thumbnail': 'https://images.unsplash.com/photo-1508700115892-45ecd05ae2ad?auto=format&fit=crop&q=80&w=400',
        'creatorId': 'dummy_4',
        'creatorName': 'DanceQueen',
        'type': 'video',
        'likes': 5400,
        'commentsCount': 210,
        'views': 45000,
        'shares': 980,
        'category': 'Dance',
        'hashtags': ['dance', 'challenge', 'viral'],
        'filterIndex': 0,
        'uploadTime': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 8))),
      },
      {
        'caption': 'Gaming setup goals 🎮 #gaming #setup',
        'videoUrl': 'https://assets.mixkit.co/videos/preview/mixkit-close-up-of-a-keyboard-and-mouse-with-lights-227-large.mp4',
        'thumbnail': 'https://images.unsplash.com/photo-1542751371-adc38448a05e?auto=format&fit=crop&q=80&w=400',
        'creatorId': 'dummy_5',
        'creatorName': 'GamerPro',
        'type': 'video',
        'likes': 3200,
        'commentsCount': 150,
        'views': 25000,
        'shares': 430,
        'category': 'Gaming',
        'hashtags': ['gaming', 'setup'],
        'filterIndex': 0,
        'uploadTime': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 12))),
      },
      {
        'caption': 'Breathtaking aerial view 🌊 #drone #ocean #travel',
        'videoUrl': 'https://assets.mixkit.co/videos/preview/mixkit-top-aerial-shot-of-seashore-with-rocks-1090-large.mp4',
        'thumbnail': 'https://images.unsplash.com/photo-1505118380757-91f5f5632de0?auto=format&fit=crop&q=80&w=400',
        'creatorId': 'dummy_1',
        'creatorName': 'NatureLover',
        'type': 'video',
        'likes': 4800,
        'commentsCount': 176,
        'views': 38000,
        'shares': 720,
        'category': 'Travel',
        'hashtags': ['drone', 'ocean', 'travel'],
        'filterIndex': 0,
        'uploadTime': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 1))),
      },
      {
        'caption': 'Cozy autumn vibes 🍂 #autumn #cozy #aesthetic',
        'videoUrl': 'https://assets.mixkit.co/videos/preview/mixkit-leaves-on-a-tree-branch-in-autumn-395-large.mp4',
        'thumbnail': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=400',
        'creatorId': 'dummy_2',
        'creatorName': 'MorningVibes',
        'type': 'video',
        'likes': 1900,
        'commentsCount': 64,
        'views': 16000,
        'shares': 290,
        'category': 'Lifestyle',
        'hashtags': ['autumn', 'cozy', 'aesthetic'],
        'filterIndex': 1,
        'uploadTime': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 1, hours: 6))),
      },
      {
        'caption': 'Quick workout routine 💪 #fitness #workout #gym',
        'videoUrl': 'https://assets.mixkit.co/videos/preview/mixkit-man-training-in-the-gym-4799-large.mp4',
        'thumbnail': 'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?auto=format&fit=crop&q=80&w=400',
        'creatorId': 'dummy_5',
        'creatorName': 'GamerPro',
        'type': 'video',
        'likes': 2700,
        'commentsCount': 98,
        'views': 22000,
        'shares': 380,
        'category': 'Fitness',
        'hashtags': ['fitness', 'workout', 'gym'],
        'filterIndex': 0,
        'uploadTime': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 2))),
      },
      {
        'caption': 'Street food in Bangkok 🇹🇭 #travel #food #street',
        'videoUrl': 'https://assets.mixkit.co/videos/preview/mixkit-chef-putting-food-on-a-wok-4773-large.mp4',
        'thumbnail': 'https://images.unsplash.com/photo-1555992336-03a23c7b20ee?auto=format&fit=crop&q=80&w=400',
        'creatorId': 'dummy_3',
        'creatorName': 'ChefMario',
        'type': 'video',
        'likes': 6100,
        'commentsCount': 232,
        'views': 55000,
        'shares': 1100,
        'category': 'Food',
        'hashtags': ['travel', 'food', 'street'],
        'filterIndex': 0,
        'uploadTime': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 2, hours: 3))),
      },
      {
        'caption': 'City night lights ✨ #city #nightlife #photography',
        'videoUrl': 'https://assets.mixkit.co/videos/preview/mixkit-city-street-in-the-rain-at-night-time-lapse-4152-large.mp4',
        'thumbnail': 'https://images.unsplash.com/photo-1477959858617-67f85cf4f1df?auto=format&fit=crop&q=80&w=400',
        'creatorId': 'dummy_4',
        'creatorName': 'DanceQueen',
        'type': 'video',
        'likes': 3900,
        'commentsCount': 144,
        'views': 32000,
        'shares': 560,
        'category': 'Photography',
        'hashtags': ['city', 'nightlife', 'photography'],
        'filterIndex': 2,
        'uploadTime': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 3))),
      },
    ];

    final batch = firestore.batch();
    final videoIds = <String>[];
    for (final v in dummyVideos) {
      final docRef = videosCollection.doc();
      videoIds.add(docRef.id);
      batch.set(docRef, v);
    }
    await batch.commit();

    // Seed comments after videos exist
    await _seedComments(firestore, videoIds);
  }

  static Future<void> _seedUsers(FirebaseFirestore firestore) async {
    final usersCollection = firestore.collection(AppConstants.usersCollection);

    final sampleUsers = [
      {
        'uid': 'dummy_1',
        'username': 'naturelover',
        'displayName': 'NatureLover',
        'email': 'naturelover@ray.app',
        'bio': '🌿 Exploring the world one frame at a time · Travel & Nature photographer',
        'profileImage': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=200',
        'followersCount': 12400,
        'followingCount': 320,
        'likesCount': 48000,
        'postsCount': 24,
        'isPrivate': false,
        'createdAt': Timestamp.now(),
      },
      {
        'uid': 'dummy_2',
        'username': 'morningvibes',
        'displayName': 'MorningVibes',
        'email': 'morningvibes@ray.app',
        'bio': '☕ Coffee addict · Lifestyle curator · Slow mornings, big dreams',
        'profileImage': 'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?auto=format&fit=crop&q=80&w=200',
        'followersCount': 8750,
        'followingCount': 180,
        'likesCount': 32000,
        'postsCount': 18,
        'isPrivate': false,
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 30))),
      },
      {
        'uid': 'dummy_3',
        'username': 'chefmario',
        'displayName': 'ChefMario',
        'email': 'chefmario@ray.app',
        'bio': '👨‍🍳 Home chef · Recipe creator · Food is love, food is life 🍝',
        'profileImage': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=200',
        'followersCount': 22100,
        'followingCount': 510,
        'likesCount': 95000,
        'postsCount': 47,
        'isPrivate': false,
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 60))),
      },
      {
        'uid': 'dummy_4',
        'username': 'dancequeenofficial',
        'displayName': 'DanceQueen',
        'email': 'dancequeen@ray.app',
        'bio': '💃 Dance is my language · Viral challenges · Teaching the world to move',
        'profileImage': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&q=80&w=200',
        'followersCount': 56800,
        'followingCount': 890,
        'likesCount': 280000,
        'postsCount': 93,
        'isPrivate': false,
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 120))),
      },
      {
        'uid': 'dummy_5',
        'username': 'gamerpro',
        'displayName': 'GamerPro',
        'email': 'gamerpro@ray.app',
        'bio': '🎮 Gaming setups · Reviews · Streaming daily · Pro since 2019',
        'profileImage': 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?auto=format&fit=crop&q=80&w=200',
        'followersCount': 34200,
        'followingCount': 650,
        'likesCount': 145000,
        'postsCount': 62,
        'isPrivate': false,
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 90))),
      },
    ];

    final batch = firestore.batch();
    for (final u in sampleUsers) {
      final docRef = usersCollection.doc(u['uid'] as String);
      // Only create if not present
      batch.set(docRef, u, SetOptions(merge: true));
    }
    await batch.commit();
  }

  static Future<void> _seedComments(
      FirebaseFirestore firestore, List<String> videoIds) async {
    final sampleComments = [
      {'text': 'This is absolutely stunning! 😍🔥', 'userId': 'dummy_2', 'username': 'morningvibes'},
      {'text': 'Can\'t stop watching this on loop! 🙌', 'userId': 'dummy_3', 'username': 'chefmario'},
      {'text': 'So talented! Keep it up 💯', 'userId': 'dummy_4', 'username': 'dancequeenofficial'},
      {'text': 'This made my day! ❤️✨', 'userId': 'dummy_5', 'username': 'gamerpro'},
      {'text': 'POV: me watching this for the 10th time 😂', 'userId': 'dummy_1', 'username': 'naturelover'},
      {'text': 'Absolutely love the vibes!! 🌟', 'userId': 'dummy_2', 'username': 'morningvibes'},
      {'text': 'Goals! 🎯🙏', 'userId': 'dummy_3', 'username': 'chefmario'},
      {'text': 'How did you even do this?! 🤯', 'userId': 'dummy_4', 'username': 'dancequeenofficial'},
    ];

    final batch = firestore.batch();
    for (final videoId in videoIds) {
      final commentsRef = firestore.collection(AppConstants.commentsCollection);

      // Add 3 random comments per video
      for (var i = 0; i < 3; i++) {
        final comment = sampleComments[(videoIds.indexOf(videoId) + i) % sampleComments.length];
        final docRef = commentsRef.doc();
        batch.set(docRef, {
          ...comment,
          'videoId': videoId,
          'userAvatar': 'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?auto=format&fit=crop&q=80&w=200',
          'timestamp': Timestamp.fromDate(
            DateTime.now().subtract(Duration(minutes: (i + 1) * 15)),
          ),
          'likes': (i + 1) * 7,
        });
      }
    }
    await batch.commit();
  }
}
