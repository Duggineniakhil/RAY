import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reelify/core/constants/app_constants.dart';

class DummyDataService {
  static Future<void> seedVideos() async {
    final firestore = FirebaseFirestore.instance;
    final videosCollection = firestore.collection(AppConstants.videosCollection);
    
    final snapshot = await videosCollection.limit(1).get();
    if (snapshot.docs.isNotEmpty) return; // Already has data

    final dummyVideos = [
      {
        'caption': 'Amazing sunset in the mountains! #nature #travel',
        'videoUrl': 'https://assets.mixkit.co/videos/preview/mixkit-sun-setting-behind-a-mountain-range-4560-large.mp4',
        'thumbnail': 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&q=80&w=400',
        'creatorId': 'dummy_1',
        'creatorName': 'NatureLover',
        'likes': 1250,
        'commentsCount': 45,
        'views': 5200,
        'category': 'Nature',
        'hashtags': ['nature', 'travel'],
        'uploadTime': Timestamp.now(),
      },
      {
        'caption': 'Perfect morning coffee ☕ #aesthetic #morning',
        'videoUrl': 'https://assets.mixkit.co/videos/preview/mixkit-coffee-being-poured-into-a-cup-2325-large.mp4',
        'thumbnail': 'https://images.unsplash.com/photo-1541167760496-162955ed8a9f?auto=format&fit=crop&q=80&w=400',
        'creatorId': 'dummy_2',
        'creatorName': 'MorningVibes',
        'likes': 890,
        'commentsCount': 12,
        'views': 4100,
        'category': 'Entertainment',
        'hashtags': ['aesthetic', 'morning'],
        'uploadTime': Timestamp.now(),
      },
      {
        'caption': 'Delicious home-made pasta recipes 🍝 #cooking #food',
        'videoUrl': 'https://assets.mixkit.co/videos/preview/mixkit-pasta-boiling-in-a-pot-4265-large.mp4',
        'thumbnail': 'https://images.unsplash.com/photo-1473093226795-af9932fe5856?auto=format&fit=crop&q=80&w=400',
        'creatorId': 'dummy_3',
        'creatorName': 'ChefMario',
        'likes': 2100,
        'commentsCount': 89,
        'views': 12000,
        'category': 'Food',
        'hashtags': ['cooking', 'food'],
        'uploadTime': Timestamp.now(),
      },
      {
        'caption': 'New dance challenge! 💃 #dance #challenge',
        'videoUrl': 'https://assets.mixkit.co/videos/preview/mixkit-very-fast-paced-modern-dance-4148-large.mp4',
        'thumbnail': 'https://images.unsplash.com/photo-1508700115892-45ecd05ae2ad?auto=format&fit=crop&q=80&w=400',
        'creatorId': 'dummy_4',
        'creatorName': 'DanceQueen',
        'likes': 5400,
        'commentsCount': 210,
        'views': 45000,
        'category': 'Dance',
        'hashtags': ['dance', 'challenge'],
        'uploadTime': Timestamp.now(),
      },
      {
        'caption': 'Gaming setup goals 🎮 #gaming #setup',
        'videoUrl': 'https://assets.mixkit.co/videos/preview/mixkit-close-up-of-a-keyboard-and-mouse-with-lights-227-large.mp4',
        'thumbnail': 'https://images.unsplash.com/photo-1542751371-adc38448a05e?auto=format&fit=crop&q=80&w=400',
        'creatorId': 'dummy_5',
        'creatorName': 'GamerPro',
        'likes': 3200,
        'commentsCount': 150,
        'views': 25000,
        'category': 'Gaming',
        'hashtags': ['gaming', 'setup'],
        'uploadTime': Timestamp.now(),
      },
    ];

    final batch = firestore.batch();
    for (final v in dummyVideos) {
      final docRef = videosCollection.doc();
      batch.set(docRef, v);
    }
    await batch.commit();
  }
}
