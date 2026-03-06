import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reelify/core/constants/app_constants.dart';

class DummyDataService {
  static Future<void> seedVideos() async {
    final firestore = FirebaseFirestore.instance;
    final videosCollection = firestore.collection(AppConstants.videosCollection);

    // Seed users first so profile pages work
    await _seedUsers(firestore);

    final dummyVideos = [
      {
        'caption': 'Big Buck Bunny! 🐰 #funny #animation',
        'videoUrl': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
        'thumbnail': 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&q=80&w=400',
        'creatorId': 'dummy_1',
        'creatorName': 'ratan.writes',
        'type': 'video',
        'likes': 1250,
        'commentsCount': 45,
        'views': 5200,
        'shares': 88,
        'category': 'Comedy',
        'hashtags': ['funny', 'animation'],
        'uploadTime': Timestamp.now(),
      },
      {
        'caption': 'Elephants Dream 🐘 #shortfilm #aesthetic',
        'videoUrl': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
        'thumbnail': 'https://images.unsplash.com/photo-1541167760496-162955ed8a9f?auto=format&fit=crop&q=80&w=400',
        'creatorId': 'dummy_2',
        'creatorName': 'john.captures',
        'type': 'video',
        'likes': 890,
        'commentsCount': 12,
        'views': 4100,
        'shares': 34,
        'category': 'Art',
        'hashtags': ['aesthetic', 'shortfilm', 'art'],
        'uploadTime': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 2))),
      },
      {
        'caption': 'For Bigger Blazes 🔥 #action #travel',
        'videoUrl': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
        'thumbnail': 'https://images.unsplash.com/photo-1473093226795-af9932fe5856?auto=format&fit=crop&q=80&w=400',
        'creatorId': 'dummy_3',
        'creatorName': 'ram.bites',
        'type': 'video',
        'likes': 2100,
        'commentsCount': 89,
        'views': 12000,
        'shares': 210,
        'category': 'Travel',
        'hashtags': ['action', 'travel', 'fire'],
        'uploadTime': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 5))),
      },
      {
        'caption': 'For Bigger Escapes 🏃 #escape #viral',
        'videoUrl': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
        'thumbnail': 'https://images.unsplash.com/photo-1508700115892-45ecd05ae2ad?auto=format&fit=crop&q=80&w=400',
        'creatorId': 'dummy_4',
        'creatorName': 'sri.moves',
        'type': 'video',
        'likes': 5400,
        'commentsCount': 210,
        'views': 45000,
        'shares': 980,
        'category': 'Action',
        'hashtags': ['escape', 'viral', 'action'],
        'uploadTime': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 8))),
      },
      {
        'caption': 'For Bigger Fun 🎮 #fun #gaming',
        'videoUrl': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
        'thumbnail': 'https://images.unsplash.com/photo-1542751371-adc38448a05e?auto=format&fit=crop&q=80&w=400',
        'creatorId': 'dummy_5',
        'creatorName': 'priya.fps',
        'type': 'video',
        'likes': 3200,
        'commentsCount': 150,
        'views': 25000,
        'shares': 430,
        'category': 'Gaming',
        'hashtags': ['gaming', 'setup', 'fun'],
        'uploadTime': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 12))),
      },
      {
        'caption': 'Joyrides! 🚗💨 #cars #travel',
        'videoUrl': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
        'thumbnail': 'https://images.unsplash.com/photo-1505118380757-91f5f5632de0?auto=format&fit=crop&q=80&w=400',
        'creatorId': 'dummy_1',
        'creatorName': 'ratan.writes',
        'type': 'video',
        'likes': 4800,
        'commentsCount': 176,
        'views': 38000,
        'shares': 720,
        'category': 'Travel',
        'hashtags': ['cars', 'ocean', 'travel'],
        'uploadTime': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 1))),
      },
      {
        'caption': 'Meltdowns... 🤯 #aesthetic #cozy',
        'videoUrl': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4',
        'thumbnail': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=400',
        'creatorId': 'dummy_2',
        'creatorName': 'john.captures',
        'type': 'video',
        'likes': 1900,
        'commentsCount': 64,
        'views': 16000,
        'shares': 290,
        'category': 'Lifestyle',
        'hashtags': ['autumn', 'cozy', 'aesthetic'],
        'uploadTime': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 1, hours: 6))),
      },
      {
        'caption': 'Sintel 🏹 #fantasy #adventure',
        'videoUrl': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4',
        'thumbnail': 'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?auto=format&fit=crop&q=80&w=400',
        'creatorId': 'dummy_6',
        'creatorName': 'karthik.lifts',
        'type': 'video',
        'likes': 2700,
        'commentsCount': 98,
        'views': 22000,
        'shares': 380,
        'category': 'Fantasy',
        'hashtags': ['fitness', 'workout', 'gym'],
        'uploadTime': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 2))),
      },
      {
        'caption': 'Tears of Steel 🤖✨ #city #nightlife #scifi',
        'videoUrl': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4',
        'thumbnail': 'https://images.unsplash.com/photo-1477959858617-67f85cf4f1df?auto=format&fit=crop&q=80&w=400',
        'creatorId': 'dummy_4',
        'creatorName': 'sri.moves',
        'type': 'video',
        'likes': 3900,
        'commentsCount': 144,
        'views': 32000,
        'shares': 560,
        'category': 'Photography',
        'hashtags': ['city', 'nightlife', 'photography'],
        'uploadTime': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 3))),
      },
      {
        'caption': 'Adrenaline pumping! #bullrun #excitement',
        'videoUrl': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WeAreGoingOnBullrun.mp4',
        'thumbnail': 'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?auto=format&fit=crop&q=80&w=400',
        'creatorId': 'dummy_7',
        'creatorName': 'ananya.pixels',
        'type': 'video',
        'likes': 11200,
        'views': 45000,
        'commentsCount': 890,
        'shares': 450,
        'category': 'Vlog',
        'hashtags': ['bullrun', 'excitement'],
        'uploadTime': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 3, hours: 2))),
      },
      {
        'caption': 'Budget car hunting 🚗 #cars #budget #review',
        'videoUrl': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WhatCarCanYouGetForAGrand.mp4',
        'thumbnail': 'https://images.unsplash.com/photo-1541899481282-d53bffe3c35d?auto=format&fit=crop&q=80&w=400',
        'creatorId': 'dummy_8',
        'creatorName': 'david.lens',
        'type': 'video',
        'likes': 15600,
        'views': 67000,
        'commentsCount': 420,
        'shares': 310,
        'category': 'Cars',
        'hashtags': ['cars', 'budget', 'review'],
        'uploadTime': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 4))),
      },
      {
        'caption': 'Is the GTI still the king? 🔥 #vw #gti #cars',
        'videoUrl': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/VolkswagenGTIReview.mp4',
        'thumbnail': 'https://images.unsplash.com/photo-1492144534655-ae79c964c9d7?auto=format&fit=crop&q=80&w=400',
        'creatorId': 'dummy_5',
        'creatorName': 'priya.fps',
        'type': 'video',
        'likes': 21000,
        'views': 95000,
        'commentsCount': 1200,
        'shares': 780,
        'category': 'Cars',
        'hashtags': ['vw', 'gti', 'cars'],
        'uploadTime': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 5))),
      },
      {
        'caption': 'Outback adventure! On and off-road 🌲 #subaru #adventure',
        'videoUrl': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4',
        'thumbnail': 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&q=80&w=400',
        'creatorId': 'dummy_3',
        'creatorName': 'ram.bites',
        'type': 'video',
        'likes': 9800,
        'views': 34000,
        'commentsCount': 210,
        'shares': 120,
        'category': 'Vlog',
        'hashtags': ['subaru', 'adventure', 'offroad'],
        'uploadTime': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 6))),
      },
      {
        'caption': 'The Jellyfish 🌊 #nature #ocean',
        'videoUrl': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
        'thumbnail': 'https://images.unsplash.com/photo-1544923246-77307dd654ca?auto=format&fit=crop&q=80&w=400',
        'creatorId': 'dummy_2',
        'creatorName': 'john.captures',
        'type': 'video',
        'likes': 15000,
        'views': 78000,
        'commentsCount': 190,
        'shares': 560,
        'category': 'Nature',
        'hashtags': ['nature', 'ocean', 'peace'],
        'uploadTime': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 7))),
      },
      {
        'caption': 'Morning coffee vibes ☕ #aesthetic #vlog',
        'videoUrl': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
        'thumbnail': 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?auto=format&fit=crop&q=80&w=400',
        'creatorId': 'dummy_1',
        'creatorName': 'ratan.writes',
        'type': 'video',
        'likes': 8200,
        'views': 29000,
        'commentsCount': 110,
        'shares': 88,
        'category': 'Vlog',
        'hashtags': ['coffee', 'morning', 'vlog'],
        'uploadTime': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 8))),
      },
    ];

    // Aggressive cleanup: Find and delete ANY duplicate dummy videos by URL
    final allDummies = await videosCollection
        .where('creatorId', isGreaterThanOrEqualTo: 'dummy_')
        .where('creatorId', isLessThanOrEqualTo: 'dummy_z')
        .get();
    
    final seenUrls = <String>{};
    final batchDelete = firestore.batch();
    bool deletedAny = false;

    for (var doc in allDummies.docs) {
      final url = doc.data()['videoUrl'] as String;
      if (seenUrls.contains(url)) {
        batchDelete.delete(doc.reference);
        deletedAny = true;
      } else {
        seenUrls.add(url);
      }
    }
    if (deletedAny) await batchDelete.commit();

    // Re-check count after cleanup
    final cleanDummies = await videosCollection
        .where('creatorId', isGreaterThanOrEqualTo: 'dummy_')
        .where('creatorId', isLessThanOrEqualTo: 'dummy_z')
        .limit(20)
        .get();

    if (cleanDummies.docs.length >= dummyVideos.length) {
      // Already has the full unique set
      return;
    }

    // Seed missing videos
    final existingUrls = cleanDummies.docs.map((d) => d.data()['videoUrl'] as String).toSet();
    final batch = firestore.batch();
    final videoIds = <String>[];
    
    for (final v in dummyVideos) {
      if (!existingUrls.contains(v['videoUrl'])) {
        final docRef = videosCollection.doc();
        videoIds.add(docRef.id);
        batch.set(docRef, v);
      }
    }
    
    if (videoIds.isNotEmpty) {
      await batch.commit();
      await _seedComments(firestore, videoIds);
    }
  }

  static Future<void> _seedUsers(FirebaseFirestore firestore) async {
    final usersCollection = firestore.collection(AppConstants.usersCollection);

    final sampleUsers = [
      {
        'uid': 'dummy_1',
        'username': 'ratan.writes',
        'displayName': 'Ratan',
        'email': 'ratan@ray.app',
        'bio': '🌿 Travel stories & golden sunsets · 12 countries and counting ✈️',
        'profileImage': 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&q=80&w=200',
        'followersCount': 12400,
        'followingCount': 320,
        'likesCount': 48000,
        'postsCount': 24,
        'isPrivate': false,
        'createdAt': Timestamp.now(),
      },
      {
        'uid': 'dummy_2',
        'username': 'john.captures',
        'displayName': 'John',
        'email': 'john@ray.app',
        'bio': '📷 Visual storyteller · Slow mornings, good coffee ☕',
        'profileImage': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=200',
        'followersCount': 8750,
        'followingCount': 180,
        'likesCount': 32000,
        'postsCount': 18,
        'isPrivate': false,
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 30))),
      },
      {
        'uid': 'dummy_3',
        'username': 'ram.bites',
        'displayName': 'Ram',
        'email': 'ram@ray.app',
        'bio': '👨‍🍳 Home chef · Recipe creator · Food is love, food is life 🍛',
        'profileImage': 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?auto=format&fit=crop&q=80&w=200',
        'followersCount': 22100,
        'followingCount': 510,
        'likesCount': 95000,
        'postsCount': 47,
        'isPrivate': false,
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 60))),
      },
      {
        'uid': 'dummy_4',
        'username': 'sri.moves',
        'displayName': 'Sri',
        'email': 'sri@ray.app',
        'bio': '💃 Dance is my language · Teaching the world to move 🌎',
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
        'username': 'priya.fps',
        'displayName': 'Priya',
        'email': 'priya@ray.app',
        'bio': '🎮 Gaming setups & reviews · Streaming daily 🕹️',
        'profileImage': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=200',
        'followersCount': 34200,
        'followingCount': 650,
        'likesCount': 145000,
        'postsCount': 62,
        'isPrivate': false,
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 90))),
      },
      {
        'uid': 'dummy_6',
        'username': 'karthik.lifts',
        'displayName': 'Karthik',
        'email': 'karthik@ray.app',
        'bio': '💪 Fitness coach · Making gains & good vibes 🌟',
        'profileImage': 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&q=80&w=200',
        'followersCount': 19500,
        'followingCount': 400,
        'likesCount': 78000,
        'postsCount': 38,
        'isPrivate': false,
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 75))),
      },
      {
        'uid': 'dummy_7',
        'username': 'ananya.pixels',
        'displayName': 'Ananya',
        'email': 'ananya@ray.app',
        'bio': '🎨 Digital artist & illustrator · Art is therapy ✨',
        'profileImage': 'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&q=80&w=200',
        'followersCount': 9100,
        'followingCount': 230,
        'likesCount': 41000,
        'postsCount': 29,
        'isPrivate': false,
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 45))),
      },
      {
        'uid': 'dummy_8',
        'username': 'david.lens',
        'displayName': 'David',
        'email': 'david@ray.app',
        'bio': '🌸 Street & portrait photographer · Film lover 📽️',
        'profileImage': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&q=80&w=200',
        'followersCount': 15600,
        'followingCount': 310,
        'likesCount': 62000,
        'postsCount': 41,
        'isPrivate': false,
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 55))),
      },
    ];

    final batch = firestore.batch();
    for (final u in sampleUsers) {
      final docRef = usersCollection.doc(u['uid'] as String);
      batch.set(docRef, u, SetOptions(merge: true));
    }
    await batch.commit();
  }

  static Future<void> _seedComments(
      FirebaseFirestore firestore, List<String> videoIds) async {
    final sampleComments = [
      {'text': 'This is absolutely stunning! 😍🔥', 'userId': 'dummy_2', 'username': 'kai_captures'},
      {'text': "Can't stop watching this on loop! 🙌", 'userId': 'dummy_3', 'username': 'luka.bites'},
      {'text': 'So talented! Keep it up 💯', 'userId': 'dummy_4', 'username': 'sofia.moves'},
      {'text': 'This made my day! ❤️✨', 'userId': 'dummy_5', 'username': 'aryan.fps'},
      {'text': 'POV: me watching this for the 10th time 😂', 'userId': 'dummy_1', 'username': 'zoya.writes'},
      {'text': 'Absolutely love the vibes!! 🌟', 'userId': 'dummy_6', 'username': 'mia.lifts'},
      {'text': 'Goals! 🎯🙏', 'userId': 'dummy_7', 'username': 'theo.pixels'},
      {'text': 'How did you even do this?! 🤯', 'userId': 'dummy_8', 'username': 'nina.lens'},
    ];

    final batch = firestore.batch();
    for (final videoId in videoIds) {
      final commentsRef = firestore.collection(AppConstants.commentsCollection);
      for (var i = 0; i < 3; i++) {
        final comment = sampleComments[(videoIds.indexOf(videoId) + i) % sampleComments.length];
        final docRef = commentsRef.doc();
        batch.set(docRef, {
          ...comment,
          'videoId': videoId,
          'userAvatar': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=200',
          'timestamp': Timestamp.fromDate(
            DateTime.now().subtract(Duration(minutes: (i + 1) * 15)),
          ),
          'likes': (i + 1) * 7,
        });
      }
    }
    await batch.commit();
  }

  // ─────────────────────────────────────────────────────────────
  // Messaging seed — 8 realistic conversations with full threads
  // ─────────────────────────────────────────────────────────────

  static Future<void> seedMessaging(String currentUserId,
      {bool forceReseed = false}) async {
    final firestore = FirebaseFirestore.instance;
    final conversationsCollection = firestore.collection('conversations');

    // Force seed the users so they exist in the database even if videos were already seeded.
    await _seedUsers(firestore);

    if (!forceReseed) {
      final existing = await conversationsCollection
          .where('participants', arrayContains: currentUserId)
          .limit(1)
          .get();
      if (existing.docs.isNotEmpty) return;
    }

    // All 8 dummy users and their chats
    final threads = [
      {
        'userId': 'dummy_1',
        'messages': [
          {'from': 'them', 'text': 'OMG your last video was 🔥🔥🔥 how do you even do that?!'},
          {'from': 'me', 'text': 'Thanks so much Zoya! Honestly it was just a lot of patience 😅'},
          {'from': 'them', 'text': 'Patience?? It looks so effortless lol'},
          {'from': 'me', 'text': 'Ha it took like 30 takes ngl'},
          {'from': 'them', 'text': 'We should totally collab sometime! I think our styles would go so well together 🙌'},
          {'from': 'me', 'text': 'YES! I\'ve been thinking the same thing. DM me on the weekend?'},
        ],
      },
      {
        'userId': 'dummy_2',
        'messages': [
          {'from': 'me', 'text': 'Hey Kai! loved the coffee aesthetic series 📸'},
          {'from': 'them', 'text': 'Thank you!! that one took forever to edit haha'},
          {'from': 'them', 'text': 'What camera do you use btw?'},
          {'from': 'me', 'text': 'Sony A7IV mostly. You?'},
          {'from': 'them', 'text': 'Same! Great minds 😄 What lens for close-ups?'},
          {'from': 'me', 'text': '50mm 1.8 — goat lens honestly'},
          {'from': 'them', 'text': 'Adding to cart RIGHT NOW 😂'},
        ],
      },
      {
        'userId': 'dummy_3',
        'messages': [
          {'from': 'them', 'text': 'Hey! tried your pasta recipe last night 🍝'},
          {'from': 'them', 'text': 'My family literally could not stop eating it 😭❤️'},
          {'from': 'me', 'text': 'That makes me SO happy to hear!! 🥹'},
          {'from': 'them', 'text': 'Any secret tips for the sauce?'},
          {'from': 'me', 'text': 'Low and slow is the key. And good quality San Marzano tomatoes!'},
          {'from': 'them', 'text': 'Got it! Making it again this weekend for sure'},
        ],
      },
      {
        'userId': 'dummy_4',
        'messages': [
          {'from': 'me', 'text': 'Sofia!! the viral dance challenge is EVERYWHERE now lol'},
          {'from': 'them', 'text': 'I know I can\'t believe it blew up like that 😭🙏'},
          {'from': 'me', 'text': 'You totally deserve it. The choreo is so fun'},
          {'from': 'them', 'text': 'Thank you!! you should try it and tag me 👀'},
          {'from': 'me', 'text': 'hahaha I have two left feet but maybe 👣'},
          {'from': 'them', 'text': 'I\'ll teach you!! it\'s easier than it looks 💃'},
        ],
      },
      {
        'userId': 'dummy_5',
        'messages': [
          {'from': 'them', 'text': 'Yo which monitor mount are you using in your latest setup video?'},
          {'from': 'me', 'text': 'The Ergotron LX — absolute game changer'},
          {'from': 'them', 'text': 'Looks clean. Cable management too is 👌'},
          {'from': 'me', 'text': 'Took a whole day to do lol. Worth it though'},
          {'from': 'them', 'text': 'Respect. That level of dedication shows 💯'},
        ],
      },
      {
        'userId': 'dummy_6',
        'messages': [
          {'from': 'me', 'text': 'Mia your workout content is so motivating! Started going to the gym because of you 💪'},
          {'from': 'them', 'text': 'That is literally everything to hear!! How long ago?'},
          {'from': 'me', 'text': 'About 2 months now. Already seeing gains 🙌'},
          {'from': 'them', 'text': 'Two months in!! Stay consistent, that\'s the golden rule'},
          {'from': 'me', 'text': 'Following your beginner program rn actually'},
          {'from': 'them', 'text': 'Love it! Feel free to ask me anything anytime 😊'},
        ],
      },
      {
        'userId': 'dummy_7',
        'messages': [
          {'from': 'them', 'text': 'Hey! Really love your content 🎨 What\'s your art style called?'},
          {'from': 'me', 'text': 'Thanks Theo! I mix digital watercolor with line art mostly'},
          {'from': 'them', 'text': 'Ahh that explains the softness. So beautiful!'},
          {'from': 'me', 'text': 'Yours is amazing too! The texture work is next level'},
          {'from': 'them', 'text': 'Appreciate it!! Procreate + a lot of layers haha'},
        ],
      },
      {
        'userId': 'dummy_8',
        'messages': [
          {'from': 'me', 'text': 'Nina! Your street photography is stunning 🌸'},
          {'from': 'them', 'text': 'Thank you so much!! I\'m always a bit nervous posting those'},
          {'from': 'me', 'text': 'No way, they\'re incredible. The light in the Amsterdam ones 😍'},
          {'from': 'them', 'text': 'Golden hour magic 🌅 It\'s all about the timing'},
          {'from': 'me', 'text': 'Worth waking up at 5am for?'},
          {'from': 'them', 'text': 'Every. Single. Time. 😂📷'},
        ],
      },
    ];

    final batch = firestore.batch();

    for (var i = 0; i < threads.length; i++) {
      final thread = threads[i];
      final them = thread['userId'] as String;
      final messages = thread['messages'] as List<Map<String, String>>;

      final convId = currentUserId.compareTo(them) < 0
          ? '${currentUserId}_$them'
          : '${them}_$currentUserId';

      final convRef = conversationsCollection.doc(convId);
      final lastMsg = messages.last['text']!;
      final lastSender = messages.last['from']!;
      final lastTime = Timestamp.fromDate(
          DateTime.now().subtract(Duration(minutes: i * 47 + 5)));

      final unreadForMe = lastSender == 'them' ? (i % 3 == 0 ? 2 : 1) : 0;

      batch.set(convRef, {
        'participants': [currentUserId, them],
        'lastMessage': lastMsg,
        'lastMessageTime': lastTime,
        'unread_$currentUserId': unreadForMe,
        'unread_$them': lastSender == 'me' ? 1 : 0,
      });

      final messagesRef = convRef.collection('messages');
      for (var j = 0; j < messages.length; j++) {
        final msg = messages[j];
        final isMe = msg['from'] == 'me';
        final msgRef = messagesRef.doc();
        batch.set(msgRef, {
          'senderId': isMe ? currentUserId : them,
          'text': msg['text'],
          'timestamp': Timestamp.fromDate(
            lastTime.toDate().subtract(
              Duration(minutes: (messages.length - j) * 3),
            ),
          ),
        });
      }
    }

    await batch.commit();
  }
}
