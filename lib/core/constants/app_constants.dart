class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'RAY';
  static const String appVersion = '1.0.0';

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String videosCollection = 'videos';
  static const String commentsCollection = 'comments';
  static const String interactionsCollection = 'interactions';

  // Firebase Storage Paths
  static const String videosStoragePath = 'videos';
  static const String thumbnailsStoragePath = 'thumbnails';
  static const String profileImagesPath = 'profile_images';

  // Feed
  static const int feedPageSize = 10;
  static const int maxWatchHistorySize = 200;

  // Video Categories
  static const List<String> videoCategories = [
    'Comedy',
    'Dance',
    'Travel',
    'Food',
    'Education',
    'Music',
    'Sports',
    'Gaming',
    'Fashion',
    'Tech',
    'Nature',
    'DIY',
    'Pets',
    'Fitness',
    'Art',
  ];

  // AI Recommendation
  static const double watchTimeWeight = 0.4;
  static const double likeWeight = 0.3;
  static const double commentWeight = 0.2;
  static const double skipPenalty = 0.1;
  static const int minInteractionsForAI = 5;

  // SQLite
  static const String dbName = 'reelify.db';
  static const int dbVersion = 1;

  // FCM Topics
  static const String fcmNewFollower = 'new_follower';
  static const String fcmNewComment = 'new_comment';
  static const String fcmNewUpload = 'new_upload';

  // Shared Preferences Keys
  static const String prefUserId = 'user_id';
  static const String prefOnboarded = 'onboarded';
  static const String prefLanguage = 'language';

  // Durations
  static const Duration splashDuration = Duration(seconds: 3);
  static const Duration snackBarDuration = Duration(seconds: 3);
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 350);
  static const Duration animationSlow = Duration(milliseconds: 600);

  // UI
  static const double cardBorderRadius = 16.0;
  static const double buttonBorderRadius = 12.0;
  static const double iconSize = 28.0;
  static const double avatarRadius = 22.0;
}
